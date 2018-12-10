package components.screens.ui
{
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import components.abstract.RegExpCollection;
	import components.abstract.functions.loc;
	import components.abstract.servants.CIDServant;
	import components.abstract.servants.TaskManager;
	import components.basement.UI_BaseComponent;
	import components.events.GUIEventDispatcher;
	import components.events.GUIEvents;
	import components.gui.Header;
	import components.gui.PopUp;
	import components.gui.SimpleTextField;
	import components.gui.fields.FSCheckBox;
	import components.gui.fields.FSComboBox;
	import components.gui.fields.FSRadioGroup;
	import components.gui.fields.FSRadioGroupH;
	import components.gui.fields.FSShadow;
	import components.gui.fields.FSSimple;
	import components.gui.visual.ScreenBlock;
	import components.gui.visual.Separator;
	import components.interfaces.IFormString;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.protocol.models.CommandSchemaModel;
	import components.protocol.models.ParameterSchemaModel;
	import components.protocol.statics.CLIENT;
	import components.protocol.statics.OPERATOR;
	import components.protocol.statics.SERVER;
	import components.screens.opt.OptLinkChannel;
	import components.static.CMD;
	import components.static.DS;
	import components.static.MISC;
	import components.system.CONST;
	import components.system.Controller;
	import components.system.GraphicsLibrary;
	import components.system.SavePerformer;
	import components.system.UTIL;
	
	public class UILinkChannels extends UI_BaseComponent
	{
		private var oGroup:Object; // Группа объектов радиобуттонов
		private var oArrows:Object;
		private var oMatrix:Object;
		private var getInfoChanges:Vector.<Boolean>;// new <Boolean>[false,false,false,false,false,false,false,false];
		
		private var isGPRSOnline:Boolean=false;
		
		private var CH_INFO_MAXOBJ:int;
		private var CH_INFO_MAXPART:int; 
		private var CH_INFO_MAXZONE:int; 
		private var CH_INFO_MAXEVENT:int;
		private var CH_INFO_MAXOBJ_LAST:int;
		private var CH_INFO_MAXPART_LAST:int; 
		private var CH_INFO_MAXZONE_LAST:int; 
		private var CH_INFO_MAXEVENT_LAST:int;
		
		public static var CH_INFO_MAXOBJ_LAST_STRUCTURES:Object = {1:0,2:0,3:0,4:0,5:0,6:0,7:0,8:0};
		public static var CH_INFO_MAXPART_LAST_STRUCTURES:Object = {1:0,2:0,3:0,4:0,5:0,6:0,7:0,8:0}; 
		public static var CH_INFO_MAXZONE_LAST_STRUCTURES:Object = {1:0,2:0,3:0,4:0,5:0,6:0,7:0,8:0}; 
		public static var CH_INFO_MAXEVENT_LAST_STRUCTURES:Object = {1:0,2:0,3:0,4:0,5:0,6:0,7:0,8:0};
		
		public static var EVENTS:Array;
		
		private var timerDeleting:Timer;
		private var loadOnlineChannel:OptLinkChannel;

		private var fsRgroup:FSRadioGroup;
		
		/// Если требуется передача большого кол-ва записией, событий например, 
		/// обработка на приборе становится такая длительная, что он не успевает 
		/// прислать ответ в положенное время, для того чтобы сократить время обработки
		/// сокращаем объем пересылаемой информации, но не прямо, а путем изменения
		/// размера значения объема буфера присылаемого с прибора
		/// при выходе со страницы объем выставляем прежний
		private static var TOP_BUF_SIZE_SEND_MAIN:int;
		private static var TOP_BUF_SIZE_SEND_TEMP:int = 256;
		private static var TOP_BUF_SIZE_RECEIVE_MAIN:int;
		private static var TOP_BUF_SIZE_RECEIVE_TEMP:int = 256;
		
		public function UILinkChannels()
		{
			super();

			aItems = new Array;
			var opt:OptLinkChannel;
			
			var header:Header = new Header( [{label:loc("ui_linkch_comm_channel"), width:160, xpos:20, align:"left"},{label:loc("ui_linkch_connect_settings"), width:200, xpos:260},
				{label:loc("ui_linkch_conn_try"), width:100, xpos:450}, {label:loc("g_object"), width:100, xpos:548}, {label:loc("g_partition"), width:100, xpos:662},
				{label:loc("ui_linkch_userzone"), width:150, xpos:770},{label:loc("g_event"), width:100, xpos:916} ] );
			addChild( header );
			header.x = 40;
			header.y = 10;
			
			oGroup = new Object;
			oArrows = new Object;
			
			for( var i:int; i<CONST.LINK_CHANNELS_NUM; ++i ) {
				if (i>0) {
					oGroup[ UTIL.hash_0To1(i) ] = new FSRadioGroupH( [{label:loc("ui_linkch_and"), selected:true, id:0x01},{label:loc("ui_linkch_or"), selected:false, id:0x02}],i );
					addChild( (oGroup[ UTIL.hash_0To1(i) ] as FSRadioGroupH) );
					(oGroup[ UTIL.hash_0To1(i) ] as FSRadioGroupH).setUp( links );
					(oGroup[ UTIL.hash_0To1(i) ] as FSRadioGroupH).switchFormat( FSRadioGroupH.F_RADIO_RETURNS_OBJECT );
					(oGroup[ UTIL.hash_0To1(i) ] as FSRadioGroupH).x = 42;
					(oGroup[ UTIL.hash_0To1(i) ] as FSRadioGroupH).y = opt.y +34
					
					oArrows[ UTIL.hash_0To1(i) ] = new GraphicsLibrary.cLinkArrow;
					addChild( oArrows[ UTIL.hash_0To1(i) ] );
					oArrows[ UTIL.hash_0To1(i) ].x = 12;
					oArrows[ UTIL.hash_0To1(i) ].visible = false;
					oArrows[ UTIL.hash_0To1(i) ].y = opt.y + 8;
				}
				opt = new OptLinkChannel( UTIL.hash_0To1(i) );
				addChild( opt );
				opt.y = (opt.getHeight()+25)*i+50;
				opt.x = 40;
				aItems[ UTIL.hash_0To1(i) ] = opt;
			}
			
			var sep1:Separator = new Separator( 910 );
			sep1.x = 10;
			sep1.y = opt.y  + opt.getHeight()+ 25;
			addChild( sep1 );
			
			globalY = sep1.y +20;
			
			createUIElement( new FSComboBox, CMD.CH_COM_ADD,loc("ui_linkch_cut_connect"),null,1,
				[{label:"1", data:1}
					,{label:"2", data:2}
					,{label:"3", data:3}
					,{label:"4", data:4}
					,{label:"5", data:5}
					,{label:"10", data:10}
					,{label:"20", data:20}
					,{label:"30", data:30}
					,{label:"40", data:40}
					,{label:"50", data:50}
					,{label:"60", data:60}],
				"",2,new RegExp("^(\\d|([1-5]\\d)|60)$") ).x = 40;
			
			attuneElement( 750, 120 );
			var sep2:Separator = new Separator( 910 );
			sep2.x = 10;
			sep2.y = sep1.y +60;
			addChild( sep2 );
			
			var stext1:SimpleTextField = new SimpleTextField( loc("ui_linkch_direction_type"), 400 );
			stext1.setSimpleFormat("left",0,16,true);
			addChild( stext1 );
			stext1.x = 40;
			stext1.y = sep2.y + 11;
			
			fsRgroup = new FSRadioGroup( [ {label:loc("ui_linkch_stay_one_dir"), selected:false, id:0x01 },
				{label:loc("ui_linkch_go_next_dir"), selected:false, id:0x02 }], 1, 30 );
			fsRgroup.y = stext1.y + 30;
			fsRgroup.x = 40;
			fsRgroup.width = 700+157;
			addChild( fsRgroup );
			addUIElement( fsRgroup, CMD.CH_COM_ADD, 2);
			
			globalY = fsRgroup.y + fsRgroup.getHeight()-7;
			
			drawSeparator(910);
			globalY-=8;
			
			addui( new FSCheckBox, CMD.CH_SEND_IMEI, loc("ui_linkch_send_imei"), null, 1 ).x = 40;
			attuneElement( 700+157 );
			globalY-=9;
			
			if( DS.isfam( DS.K14W ) )
			{
				addui( new FSCheckBox, CMD.CH_COM_DUBLE_ONLINE, loc("use_double_chanell"), null, 1 ).x = 40;
				attuneElement( 700+157 );
				globalY-=9;
			}
			
			
			drawSeparator(910);
			
			if (DS.release >= 9 || MISC.COPY_DEBUG) { 
				addui( new FSSimple, CMD.PING_SET_TIME, loc("test_ping") + " 20...120)", null, 1, null, "0-9", 3, new RegExp(RegExpCollection.REF_20to120) ).x = 40;
				attuneElement( 700+79,60 );
			}
			
			var stext2:SimpleTextField = new SimpleTextField( loc("ui_linkch_channel_desc"), 900 );
			addChild( stext2 );
			stext2.x = 40;
			//stext2.y = fsRgroup.y + fsRgroup.getHeight() + 10;
			stext2.y = globalY-8;
			
			var stext3:SimpleTextField = new SimpleTextField( loc("ui_linkch_change_clear_history"), 900, 0xff0000 );
			addChild( stext3 );
			stext3.x = 40;
			stext3.y = stext2.y + 40;
			
			getInfoChanges = new Vector.<Boolean>;
			getInfoChanges.length = 8;
			getInfoChanges.fixed = true;
			
			starterCMD = [  CMD.CH_SEND_IMEI, CMD.CH_COM_MAX_INFO  ];
			width = 1075;
			height = 770;
			
			if( DS.isfam( DS.K14W ) )
			{
				starterRefine( CMD.CH_COM_DUBLE_ONLINE, true );
			}
			
			if (DS.release >= 9 || MISC.COPY_DEBUG) {
				starterRefine( CMD.PING_SET_TIME, true );
				height = 785;
			}
			if (DS.release >= 10 ) {
				starterCMD.push( CMD.CH_COM_LINK_LOCK );
			}
		}
		override public function open():void
		{
			super.open();
			LOADING = true;
			Controller.getInstance().changeLabel(loc("ui_linkch_attention_unsave"));
			TOP_BUF_SIZE_SEND_MAIN = SERVER.TOP_BUF_SIZE_SEND;
			TOP_BUF_SIZE_RECEIVE_MAIN = SERVER.TOP_BUF_SIZE_RECEIVE;
			
			SERVER.TOP_BUF_SIZE_SEND = TOP_BUF_SIZE_RECEIVE_TEMP;
			SERVER.TOP_BUF_SIZE_RECEIVE = TOP_BUF_SIZE_RECEIVE_TEMP;
		}
		override public function close():void
		{
			super.close();
			isGPRSOnline = false;
			Controller.getInstance().changeLabel();
			GUIEventDispatcher.getInstance().removeEventListener( GUIEvents.onGPRSOnline, gprsOnlineChanged );
			GUIEventDispatcher.getInstance().removeEventListener( GUIEvents.onChangeObject, readMatrix );
			SERVER.TOP_BUF_SIZE_SEND = TOP_BUF_SIZE_SEND_MAIN;
			SERVER.TOP_BUF_SIZE_RECEIVE = TOP_BUF_SIZE_RECEIVE_MAIN;
		}
		override public function put(p:Package):void
		{
			if ( !GUIEventDispatcher.getInstance().hasEventListener(GUIEvents.onGPRSOnline) )
				GUIEventDispatcher.getInstance().addEventListener( GUIEvents.onGPRSOnline, gprsOnlineChanged );
			
			switch(p.cmd) {
				case CMD.CH_COM_LINK_LOCK:
					
					if( CONST.DEBUG )
							break;
					
					SERVER.TOP_BUF_SIZE_SEND = TOP_BUF_SIZE_RECEIVE_TEMP;
					SERVER.TOP_BUF_SIZE_RECEIVE = TOP_BUF_SIZE_RECEIVE_TEMP;
					var obj:Object;
					
					if( p.data[ 0 ] == 0x00 )
					{
						for each( obj in aItems )OptLinkChannel( obj ).onDisableOfBlockWriters( true );
						for each( obj in oGroup )FSRadioGroupH( obj ).block( null );
						fsRgroup.block( null );
					}
					else
					{
						for each( obj in aItems )OptLinkChannel( obj ).onDisableOfBlockWriters( false );
						for each( obj in oGroup )FSRadioGroupH( obj ).deblock();
						fsRgroup.enabled = true;
					}
					
					
					
					break;
				case CMD.CH_SEND_IMEI:
					distribute( p.getStructure(), p.cmd );
					break;
				case CMD.CH_COM_DUBLE_ONLINE:
					//distribute( p.getStructure(), p.cmd );
					pdistribute( p );
					break;
				case CMD.CH_COM_MAX_INFO:
					/** Команда CH_COM_GET_INFO - получить информацию о фильтре событий CID  в 
					 
					 Для структур 1-8 (номер структуры = номеру канала связи):
					 Параметр 1 - записанное количество объектов для канала связи 1-8 ( CH_COM_OBJ )
					 Параметр 2 - записанное количество событий ContactID для  канала связи 1-8 ( CH_COM_EVENT )
					 Параметр 3 - записанное количество разделов для канала связи 1-8 ( CH_COM_PART )
					 Параметр 4 - записанное количество зон для одного канала связи 1-8 ( CH_COM_ZONE )
					 
					 Для структуры 9:
					 Параметр 1 - (C1) максимальное количество возможных объектов для одного канала связи ( CH_COM_OBJ )
					 Параметр 2 - (C2) максимальное количество возможных событий ContactID для одного канала связи ( CH_COM_EVENT )
					 Параметр 3 - (C3) максимальное количество возможных разделов для одного канала связи ( CH_COM_PART )
					 Параметр 4 - (C4) максимальное количество возможных зон для одного канала связи ( CH_COM_ZONE ) */
					
					CH_INFO_MAXOBJ = p.getStructure()[0];
					CH_INFO_MAXEVENT = p.getStructure()[1];
					CH_INFO_MAXPART = p.getStructure()[2];
					CH_INFO_MAXZONE = p.getStructure()[3];
					
					for (var j:int=0; j<9; j++) {
						if( aItems[j] is OptLinkChannel )
							aItems[j].maxItems = {obj:CH_INFO_MAXOBJ,event:CH_INFO_MAXEVENT,part:CH_INFO_MAXPART,zone:CH_INFO_MAXZONE};
					}
					
					
					if (CH_INFO_MAXEVENT == 0xffff || CH_INFO_MAXZONE == 0xffff ) {
						loadComplete();
						loadStart();
						popup = PopUp.getInstance();
						popup.construct( PopUp.wrapHeader(loc("sys_incorrect_data")), PopUp.wrapMessage(loc("sys_page_not_load")), PopUp.BUTTON_OK );
						popup.open();
						return;
					}
					
					// Обновляем информацию о реальном количестве структур
					OPERATOR.getSchema( CMD.CH_COM_OBJ ).StructCount = CH_INFO_MAXOBJ;
					OPERATOR.getSchema( CMD.CH_COM_EVENT).StructCount = CH_INFO_MAXEVENT;
					OPERATOR.getSchema( CMD.CH_COM_ZONE).StructCount = CH_INFO_MAXZONE;
					OPERATOR.getSchema( CMD.CH_COM_PART ).StructCount = CH_INFO_MAXPART;
					
					SavePerformer.trigger( {"before":erase, "after":fill, "cmd":refine, "prepare":prepare} );
					RequestAssembler.getInstance().fireEvent( new Request( CMD.CH_COM_GET_INFO, put ));
					break;
				case CMD.CH_COM_GET_INFO:
					calcMaxValuesForCH(p.data.slice() );
					
					RequestAssembler.getInstance().fireEvent( new Request( CMD.USER_PASS, put ));
					RequestAssembler.getInstance().fireEvent( new Request( CMD.RF_SENSOR, put ));
					if (MISC.COPY_VER != DS.K7)
						RequestAssembler.getInstance().fireEvent( new Request( CMD.ALARM_KEY, put ));
					RequestAssembler.getInstance().fireEvent( new Request( CMD.RF_RCTRL, put ));
					break;
				case CMD.RF_SENSOR:
					EVENTS = CIDServant.getRawEvent( CIDServant.RAWCID_SYSTEM_EVENTS_LINKCHANNELS).slice();
					EVENTS = EVENTS.concat( extractEvent( [8,9], p.data, true, true ) );
					break;
				case CMD.ALARM_KEY:
					EVENTS = EVENTS.concat( extractEvent( [1], p.data ) );
					break;
				case CMD.RF_RCTRL:
					EVENTS = EVENTS.concat( extractEvent( [3,4,5], p.data, true ) );
					
					EVENTS = cleanClones(EVENTS);
					
					RequestAssembler.getInstance().fireEvent( new Request( CMD.CH_COM_LINK, put ));
					RequestAssembler.getInstance().fireReadSequence(CMD.CH_COM_OBJ,put,CH_INFO_MAXOBJ_LAST);
					RequestAssembler.getInstance().fireReadSequence(CMD.CH_COM_ZONE,put,CH_INFO_MAXZONE_LAST);
					RequestAssembler.getInstance().fireReadSequence(CMD.CH_COM_EVENT,put,CH_INFO_MAXEVENT_LAST);
					RequestAssembler.getInstance().fireReadSequence(CMD.CH_COM_PART,put,CH_INFO_MAXPART_LAST);
					
					RequestAssembler.getInstance().fireEvent( new Request( CMD.CH_COM_ADD, put ));
					
					break;
				case CMD.CH_COM_OBJ:
				case CMD.CH_COM_ZONE:
				case CMD.CH_COM_EVENT:
				case CMD.CH_COM_PART:
					var aTypical:Object = createMatrix( p.cmd, p.getStructure().slice() );
				case CMD.CH_COM_LINK:
					
					SavePerformer.LOADING = true;
					var len:int = aItems.length;
					var opt:OptLinkChannel;
					for(var i:int=1; i<len; ++i ) {
						opt = aItems[i];
						if ( opt ) {
							
							if( opt.putAuto( p.getStructure(i), p.cmd ) ) loadOnlineChannel = opt;
							
							if (aTypical && p.structure <= getMaxStructureValue(p.cmd,i) )
								opt.putAtypicalData( p.cmd, aTypical[i] );
						}
					}
					
					
					SavePerformer.LOADING = false;
					
					break;
				case CMD.CH_COM_ADD:
					getField( p.cmd,1 ).setCellInfo( String( p.getStructure()[0] ) );
					if ( isGPRSOnline && p.getStructure()[1] == 1 ) {
						var f:IFormString = getField( p.cmd,2 );
						if ( f.getCellInfo() != "2" ) { 
							f.setCellInfo( "2" );
							SavePerformer.remember(1,f);
						}
					} else
						getField( p.cmd,2 ).setCellInfo( String( p.getStructure()[1] ) );
					
					linksFirstRun();
					
					if( loadOnlineChannel ) loadOnlineChannel.fictiveDispatch();
					loadComplete();
					LOADING = false;
					GUIEventDispatcher.getInstance().addEventListener( GUIEvents.onChangeObject, readMatrix );
					break;
				case CMD.PING_SET_TIME:
					pdistribute(p);
					break;
			}
		}
		private function calcMaxValuesForCH(arr:Array):void
		{
			CH_INFO_MAXOBJ_LAST = 0;
			CH_INFO_MAXEVENT_LAST = 0;
			CH_INFO_MAXPART_LAST = 0;
			CH_INFO_MAXZONE_LAST = 0;
			
			for(var key:String in arr) {
				
				CH_INFO_MAXOBJ_LAST_STRUCTURES[UTIL.hash_0To1(key)] = CH_INFO_MAXOBJ<arr[key][0] ? 0 : arr[key][0];
				CH_INFO_MAXEVENT_LAST_STRUCTURES[UTIL.hash_0To1(key)] = CH_INFO_MAXEVENT<arr[key][1] ? 0 : arr[key][1];
				CH_INFO_MAXPART_LAST_STRUCTURES[UTIL.hash_0To1(key)] = CH_INFO_MAXPART<arr[key][2] ? 0 : arr[key][2];
				CH_INFO_MAXZONE_LAST_STRUCTURES[UTIL.hash_0To1(key)] = CH_INFO_MAXZONE<arr[key][3] ? 0 : arr[key][3];
				
				if (arr[key][0] > CH_INFO_MAXOBJ_LAST) {
					if (CH_INFO_MAXOBJ<arr[key][0]) {
						CH_INFO_MAXOBJ_LAST = CH_INFO_MAXOBJ_LAST > 0 ? CH_INFO_MAXOBJ_LAST : 0;
					} else
						CH_INFO_MAXOBJ_LAST = arr[key][0];
				}
				if (arr[key][1] > CH_INFO_MAXEVENT_LAST) {
					if( CH_INFO_MAXEVENT<arr[key][1] )
						CH_INFO_MAXEVENT_LAST = CH_INFO_MAXEVENT_LAST > 0 ? CH_INFO_MAXEVENT_LAST : 0
					else
						CH_INFO_MAXEVENT_LAST = arr[key][1];
				}
				if (arr[key][2] > CH_INFO_MAXPART_LAST) {
					
					if( CH_INFO_MAXPART<arr[key][2] )
						CH_INFO_MAXPART_LAST = CH_INFO_MAXPART_LAST > 0 ? CH_INFO_MAXPART_LAST : 0
					else
						CH_INFO_MAXPART_LAST = arr[key][2];
				}
				if (arr[key][3] > CH_INFO_MAXZONE_LAST) {
					if( CH_INFO_MAXZONE<arr[key][3] )
						CH_INFO_MAXZONE_LAST = CH_INFO_MAXZONE_LAST > 0 ? CH_INFO_MAXZONE_LAST : 0
					else
						CH_INFO_MAXZONE_LAST = arr[key][3];
				}
			}
			
			
		}
		private function testInterruption():void
		{	// проверяем выключать чекбокс или нет - вызывается только при загрузке страницы
			var key:String;
			getField( CMD.CH_COM_ADD,1 ).disabled = true;
			for( key in aItems ) {
				if( (aItems[key] as OptLinkChannel).isGprsOnline() ) {
					getField( CMD.CH_COM_ADD,1 ).disabled = !isAtLeast2ChannelsEnabled();
					return;
				}
			}
		}
		private function gprsOnlineChanged(ev:GUIEvents):void
		{
			updateBlocks();
			
			var key:String;
			
			// все кто не принадлежит этой группе ставятся оффлайн
			var groupId:*;
			for( key in aItems ) {
				groupId = (aItems[key] as OptLinkChannel).getField(CMD.CH_COM_LINK,1).getCellInfo();
				
				if ( groupId !=  "1"  )(aItems[key] as OptLinkChannel).setGPRSoffline();
				else (aItems[key] as OptLinkChannel).createOnlineOptions();
				
			}
			
			if( ev.isGPRSOnline() ) {
				isGPRSOnline = true;
				getField( CMD.CH_COM_ADD,1 ).disabled = !isAtLeast2ChannelsEnabled();
			} else {
				getField( CMD.CH_COM_ADD,1 ).disabled = true;
				// необходимо переформировать линки
				links();
				// Если был выбра канал OFFLINE надо проверить если все остальные каналы OFFLINE то разблокировать радиогруп
				for( key in aItems ) {
					if( (aItems[key] as OptLinkChannel).isGprsOnline() ) {
						getField( CMD.CH_COM_ADD,1 ).disabled = !isAtLeast2ChannelsEnabled();
						return;
					}
				}
				
				/// включаем онлайн опции всех каналов
				for( key in aItems ) OptLinkChannel( aItems[ key ] ).createOnlineOptions(  );
					
				
				(getField( CMD.CH_COM_ADD,2 ) as FSRadioGroup).block();
				return;
			}
			
			if ( ev.getStructure() is int ) { 
				// Сначала вычисляется группа которая вызвала GPRS онлайн
				var currentGroupOnline:String;
				for( key in aItems ) {
					if( (aItems[key] as OptLinkChannel).getStructure() == ev.getStructure() )
						
						currentGroupOnline = String( (aItems[key] as OptLinkChannel).getField(CMD.CH_COM_LINK,1).getCellInfo() );
				}
				
				
			}
			
			
			
			if ( isGPRSOnline ) {
				(getField( CMD.CH_COM_ADD,2 ) as FSRadioGroup).block([0]);
				if ( (getField( CMD.CH_COM_ADD,2 ) as FSRadioGroup).getCellInfo() != "2" && ev.getStructure() is int && !LOADING )
					SavePerformer.remember( getStructure(),getField( CMD.CH_COM_ADD,2 ));
				(getField( CMD.CH_COM_ADD,2 ) as FSRadioGroup).setCellInfo("2");
			} else
				(getField( CMD.CH_COM_ADD,2 ) as FSRadioGroup).block();
			
			
			
			links();
			
		}
		private function updateBlocks():void
		{
			var l:int = 0;
			var prevKey:String;
			var channel:*;
			for( var key0:String in oGroup ) 
			{
				
				channel = (aItems[++l] as OptLinkChannel).getField(CMD.CH_COM_LINK, 5 ).getCellInfo();
				
				if( channel == 25 || channel == 26 )
				{
					if( prevKey )( oGroup[ prevKey ] as FSRadioGroupH ).block( null );
					( oGroup[ key0 ] as FSRadioGroupH ).block( null );
					
				}
				else
				{
					( oGroup[ key0 ] as FSRadioGroupH ).deblock();
				}
				
				prevKey = key0;
				
			}
			channel = (aItems[++l] as OptLinkChannel).getField(CMD.CH_COM_LINK, 5 ).getCellInfo();
			/// проверяем последний канал
			if( channel == 25 || channel == 26 )
				( oGroup[ prevKey ] as FSRadioGroupH ).block( null );
		}
		private function isAtLeast2ChannelsEnabled():Boolean
		{	// проверяем есть ли как минимум 2 невыключенных канала из 8
			var key:String;
			var total:int = 0;
			for( key in aItems ) {
				if( (aItems[key] as OptLinkChannel).isEnabled() )
					total++;
				if (total > 1)
					return true;
			}
			return false;
		}
		private function createMatrix(cmd:int,data:Array):Object
		{
			if(!oMatrix)
				oMatrix = new Object;
			if(!oMatrix[cmd])
				oMatrix[cmd] = new Object;
			
			var arr:Array = OPERATOR.dataModel.getData(cmd);
			var atypicalParams:Object = new Object;
			var aTypes:Array;
			
			for(var s:String in arr) {
				
				if(!oMatrix[cmd][int(s)+1])
					oMatrix[cmd][int(s)+1] = new Object;
				
				// Задаем структуру чтобы адекватно сохранились поля
				structureID = int(s)+1;
				for( var p:String in arr[s] ) {
					
					var canProcessData:Boolean = true;
					if( arr[s][p] > 0 ) {
						switch(cmd) {
							case CMD.CH_COM_OBJ:
								if( (CH_INFO_MAXOBJ_LAST_STRUCTURES[UTIL.hash_0To1(p)] < UTIL.hash_0To1(s)) )
									canProcessData = false;
								break;
							case CMD.CH_COM_ZONE:
								if( (CH_INFO_MAXZONE_LAST_STRUCTURES[UTIL.hash_0To1(p)] < UTIL.hash_0To1(s)) )
									canProcessData = false;
								break;
							case CMD.CH_COM_EVENT:
								if( (CH_INFO_MAXEVENT_LAST_STRUCTURES[UTIL.hash_0To1(p)] < UTIL.hash_0To1(s)) )
									canProcessData = false;
								break;
							case CMD.CH_COM_PART:
								if( (CH_INFO_MAXPART_LAST_STRUCTURES[UTIL.hash_0To1(p)] < UTIL.hash_0To1(s)) )
									canProcessData = false;
								break;
						}
					}
					
					var value:String = arr[s][p];
					if(!canProcessData)
						value = "0";
					
					oMatrix[cmd][int(s)+1][int(p)+1] = createUIElement(new FSShadow,cmd,value,null,int(p)+1);
					
					if(!atypicalParams[int(p)+1])
						atypicalParams[int(p)+1] = new Object;
					if(value != "0")
						atypicalParams[int(p)+1][s] = value;
				}
			}
			// Обязательно возвращаем структуру на место
			structureID = 1;
			return atypicalParams;
		}
		private function getMaxStructureValue(cmd:int,s:int):int
		{
			
			switch(cmd) {
				case CMD.CH_COM_OBJ:
					return CH_INFO_MAXOBJ_LAST_STRUCTURES[s];
				case CMD.CH_COM_ZONE:
					return CH_INFO_MAXZONE_LAST_STRUCTURES[s];
				case CMD.CH_COM_EVENT:
					return CH_INFO_MAXEVENT_LAST_STRUCTURES[s];							
				case CMD.CH_COM_PART:
					return CH_INFO_MAXPART_LAST_STRUCTURES[s];
			}
			return 0;
		}
		private function readMatrix(ev:GUIEvents):void
		{
			var param:int = ev.getData().param;
			var data:Array = ev.getData().data;
			var cmd:int = ev.getData().cmd;
			
			getInfoChanges[param-1] = true;
			
			// Если при загрузке матрица не была создана - надо ее создать в процессее считывания.
			if(!oMatrix || !oMatrix[cmd] || !oMatrix[cmd][data.length] || !oMatrix[cmd][data.length][param] ) {
				if(!oMatrix)
					oMatrix = new Object;
				if(!oMatrix[cmd])
					oMatrix[cmd] = new Object;
				
				for(var str:String in data) {
					structureID = int(str)+1;
					if ( !oMatrix[cmd][int(str)+1] )
						oMatrix[cmd][int(str)+1] = new Object;
					for(var i:int=0; i< CONST.LINK_CHANNELS_NUM; ++i ) {
						var value:String = param == i+1 ? data[str]:"";
						
						// Если данные не совпадают с той ячейкой в которй должны быть, в ячейку не записывается ничего
						if ( !oMatrix[cmd][int(str)+1][i+1] )
							oMatrix[cmd][int(str)+1][i+1] = createUIElement(new FSShadow,cmd,value,null,i+1);
						else if (value != "")
							(oMatrix[cmd][int(str)+1][i+1] as FSShadow).setCellInfo( value );
					}
				}
				structureID = 1;
			}
			
			// Выставляем значение комбобоксов у ведомых каналов
			var masterGroup:int = int( (aItems[param] as OptLinkChannel).getField(CMD.CH_COM_LINK,1).getCellInfo() );
			var masterGroupOffset:int=0; // Величина на сколько надо смещаться по параметрам и клонировать информацию
			
			for( var key:String in aItems ) {
				if( (aItems[key] as OptLinkChannel).getField(CMD.CH_COM_LINK,1).getCellInfo() ==  masterGroup && (aItems[key] as OptLinkChannel).slave ) {
					masterGroupOffset++;
					getInfoChanges[int(key)-1] = true;
					(aItems[key] as OptLinkChannel).putAtypicalData(cmd,data);
				}
			}
			
			/*
			for( var key:String in aItems ) {
			if ( int(key) > param ) {
			if( (aItems[key] as OptLinkChannel).getField(CMD.CH_COM_LINK,1).getCellInfo() ==  masterGroup ) {
			masterGroupOffset++;
			getInfoChanges[int(key)-1] = true;
			(aItems[key] as OptLinkChannel).putAtypicalData(cmd,data);
			} else
			break;
			} else
			continue;
			}
			*/
			
			// Сохраняем матрицу
			var offsetDone:Boolean = false; 	// Отмечает было ли сделано клонирование инфы для параметров в цикле
			if(oMatrix && oMatrix[cmd]) {
				var isNothingSaved:Boolean = true; // Если комбобокс пустой, то есть сохранять нечего, но надо отправить зануления
				
				for(var s:String in oMatrix[cmd]) {
					if (int(s) > getMaxStructureValue(cmd,param) )
						break;
					
					isNothingSaved = false;
					offsetDone = false;
					
					for(var p:String in oMatrix[cmd][s]) {
						
						if ( param == int(p) ) {
							(oMatrix[cmd][s][param] as FSShadow).setCellInfo( data[ UTIL.hash_1To0(s) ] );
							if(!offsetDone && param < OPERATOR.getSchema(cmd).Parameters.length ) {
								for(var mgd:int=1; mgd<=masterGroupOffset; ++mgd) {
									/* fix: если существует группа и у первой строки поставить "не используется", длина группы не изменится, но событие
										по изменению придет с другой структуры, может выпасть null	*/
									if (oMatrix[cmd][s][param + mgd]) 									
										(oMatrix[cmd][s][param + mgd] as FSShadow).setCellInfo( data[ UTIL.hash_1To0(s) ] );
								}
								offsetDone = true;
							}
						}
						
						SavePerformer.remember(int(s),(oMatrix[cmd][s][p] as FSShadow));
					}
				}
				if( isNothingSaved )
					SavePerformer.rememberBlank();
			}
		}
		private function getMatrixRealLineMaxValue(cmd:int, param:int):int
		{
			var counter:int=0;
			if(oMatrix && oMatrix[cmd]) {
				for(var s:String in oMatrix[cmd]) {
					if (int(s) > getMaxStructureValue(cmd,param) )
						return counter;
					// Нельзя проверять на ноль обьекты пототму что это наобро "все"
					if ( (oMatrix[cmd][s][param] as FSShadow).getCellInfo() != "0" && (oMatrix[cmd][s][param] as FSShadow).getCellInfo() != "" ) {
						if( counter < int(s) )
							counter = int(s)
					}
				}
			}
			return counter;
		}
		private function getMatrixRealCMDMaxValue(cmd:int):int
		{
			var total:int=0;
			var line:int=0;
			for(var i:int; i<8; ++i) {
				line = getMatrixRealLineMaxValue(cmd,i+1);
				if( total < line)
					total = line;
			}
			return total;
		}
		/**
		 * Срабатывает только при загрузке страницы
		 */
		private function linksFirstRun():void
		{
			var groupNum:int = 1;
			
			var prevOpt:OptLinkChannel;
			var currentOpt:OptLinkChannel;
			var prevField:IFormString;
			var currentField:IFormString;
			
			var directon:Object = {};
			var dnum:int;
			
			for( var key:String in aItems ) {
				
				if (oArrows[key] != null)
					oArrows[key].visible = false;
				if (oGroup[key] != null)
					(oGroup[key] as FSRadioGroupH).setCellInfo("1");
				
				prevOpt = aItems[ int(key)-1 ] as OptLinkChannel;
				currentOpt = aItems[key] as OptLinkChannel;
				currentField = currentOpt.getField(CMD.CH_COM_LINK,1);
				
				
				
				
				if (prevOpt is OptLinkChannel) {
					prevField = prevOpt.getField(CMD.CH_COM_LINK,1);
					
					dnum = int(prevField.getCellInfo());
					
					// Если предыдущая группа равна current ставим стрелочки visible=true					
					if ( prevField.getCellInfo() == currentField.getCellInfo() ) {
						
						(oGroup[key] as FSRadioGroupH).setCellInfo("2");
						oArrows[key].visible = true;
						
						currentOpt.slave = true;
						if (!directon[dnum]) {
							if( !prevOpt.isUiDisabled() ) {
								directon[dnum] = true;
								prevOpt.slave = false;
							} else if (!currentOpt.isUiDisabled() ){
								directon[dnum] = true;
								prevOpt.slave = true;
								currentOpt.slave = false;
							} else
								prevOpt.slave = true;
						}
						
						currentOpt.enableCallOpts = false;
						prevOpt.enableCallOpts = false;
					} else
						currentOpt.slave = false;
				} else
					currentOpt.slave = false;
				// Если группа !0<группа<8 то ставим группы соответственно номеру
				if ( int(currentField.getCellInfo()) < 1 || int(currentField.getCellInfo()) > 8 ) {
					currentField.setCellInfo( groupNum.toString() );
					SavePerformer.remember( currentOpt.getStructure(), currentField );
				}
				groupNum++;
			}
			
			var lenj:int = aItems.length;
			var o:OptLinkChannel;
			for (var j:int=0; j<lenj; ++j) {
				if (aItems[j] is OptLinkChannel) {
					o = aItems[j];
					if( o.group == "1" )o.createOnlineOptions();
					else o.setGPRSoffline();
					var s1:String = o.slave==true?"s":"M";
					var s2:String = o.isUiDisabled()==true?"disabled":"";
					var gru:String = o.getField(CMD.CH_COM_LINK,1).getCellInfo().toString();
					trace( "f "+key+" g"+gru+" " + s1 + " " + s2 );
				}
			}
			
			updateBlocks();
		}
		
		
		private function links():void
		{
			if (LOADING)
				return;
			
			var prevOpt:OptLinkChannel;
			var currentOpt:OptLinkChannel;
			var prevField:IFormString;
			var currentField:IFormString;
			var onlineGroup:String=""; // Первая группа которая содержит GPRS онлайн
			
			var masterOpt:OptLinkChannel;
			var dataDistribution:Vector.<OptLinkChannel>;
			
			var directon:Object = {};
			var dnum:int;	// номер направления
			/**
			 * Инфы о том, что канал является шлейфом не сохраняется, поэтому сохраняем 
			 * и на следущей итерации он уже не представляется шлейфом :( 
			 * сохраняем инфу о каналах которые назначены шлейфами чтобы скрыть
			 * из опций возможность Звонок
			 */
			var slaves:Array = new Array();
			
			for( var key:String in oGroup ) {
				prevOpt = aItems[ int(key)-1 ] as OptLinkChannel;
				currentOpt = aItems[key] as OptLinkChannel;
				
				prevField = prevOpt.getField(CMD.CH_COM_LINK,1);
				currentField = currentOpt.getField(CMD.CH_COM_LINK,1);
				
				
				
				
				
				// Если в радиоботтоне поставили ИЛИ ( объединение )
				if( int((oGroup[key] as FSRadioGroupH).getCellInfo()) == 2) {
					
					
					currentField.setCellInfo( prevField.getCellInfo().toString() );
					oArrows[key].visible = true;
					
					dnum = int(currentField.getCellInfo());
					if (directon[dnum] == null) {
						directon[dnum] = false;
						masterOpt = null;
						
					}
					
					
					
					currentOpt.slave = true;
					
					//prevOpt.slave = true;
					if( !directon[dnum] ) {
						if( !prevOpt.isUiDisabled() )
						{
							masterOpt = prevOpt;
							
						}
						else if ( !currentOpt.isUiDisabled() ) {
							prevOpt.slave = true;
							masterOpt = currentOpt;
						}
						
						if (masterOpt) {
							masterOpt.slave = false;
							directon[dnum] = true;
							if (!dataDistribution)
								dataDistribution = new Vector.<OptLinkChannel>;
							dataDistribution.push( masterOpt );
							//masterOpt = null;
						} else
							prevOpt.slave = true;
					}
					
					
					
					SavePerformer.remember( currentOpt.getStructure(), currentField );
					
					currentOpt.enableCallOpts = false;
					prevOpt.enableCallOpts = false;
					
					slaves.push( currentOpt.getStructure() );
					
					// А если И
				} else {
					
					
					
					currentOpt.slave = false;
					
					if( slaves.indexOf( prevOpt.getStructure() ) == -1 )prevOpt.enableCallOpts = true;
					currentOpt.enableCallOpts = true;
					
					
					if ( currentField.getCellInfo() == prevField.getCellInfo() ) {
						
						//prevOpt.enableCallOpts = true;
						for( var item:String in aItems ) {
							if (int(item)<int(key))
								continue;
							
							var pfield:IFormString = (aItems[int(item)-1] as OptLinkChannel).getField(CMD.CH_COM_LINK,1);
							var field:IFormString = (aItems[item] as OptLinkChannel).getField(CMD.CH_COM_LINK,1);
							if( int(field.getCellInfo()) > int(pfield.getCellInfo()) )
								break;
							field.setCellInfo( String(int(field.getCellInfo())+1) );
							
							SavePerformer.remember( (aItems[item] as OptLinkChannel).getStructure(), field );
						}
						
						
					}
					oArrows[key].visible = false;
					
					
				}
				
				
				// Проверяем чтобы только 1 группа имела Online GPRS
				/*if (key == "2" && prevOpt.isGprsOnline() ) 
					onlineGroup = prevOpt.group
				
				if(onlineGroup == "") {
					if( currentOpt.isGprsOnline() ) 
					{
						onlineGroup = currentOpt.group;
						currentOpt.createOnlineOptions();
						
					}
						
					
					
				} 
				else if( currentOpt.group != onlineGroup ) 
				{
					
						currentOpt.setGPRSoffline();
				}
				else currentOpt.createOnlineOptions();*/
			}
			
			if (dataDistribution) {
				var len:int = dataDistribution.length;
				for(var i:int=0; i<len; ++i ) {
					dataDistribution[i].callDataDistributionOnSlaves();
				}
			}
			
			var lenj:int = aItems.length;
			var o:OptLinkChannel;
			for (var j:int=0; j<lenj; ++j) {
				if (aItems[j] is OptLinkChannel) {
					o = aItems[j];
					if( o.group == "1" )o.createOnlineOptions();
					else o.setGPRSoffline();
					
					var s1:String = o.slave==true?"s":" M";
					var s2:String = o.isUiDisabled()==true?"\tdisabled":"";
					trace( j+" " + s1 + " " + s2 );
				}
			}
		}
		private function erase():void
		{
			
			for(var i:int=0; i<8; ++i ) {
				if ( getInfoChanges[i] == true )
					RequestAssembler.getInstance().fireEvent( new Request( CMD.CH_COM_GET_INFO, null,i+1,[0,0,0,0], Request.NORMAL, Request.PARAM_SAVE ));
			}
		}
		private function prepare():void
		{
			if (CLIENT.DELETE_HISTORY == 1) {
				var txt:String = loc("sys_process_take_awhile");
				GUIEventDispatcher.getInstance().fireEvent( GUIEvents, GUIEvents.onNeedScreenBlock, 
					{getScreenMode:ScreenBlock.MODE_LOADING_TEXT, getScreenMsg:txt} );
				blockNavi = true;
			}
			
			if ( SavePerformer.oNeedToSave[CMD.CH_COM_LINK] != null ) {		// 	если в объекте сохранения есть команда CMD.CH_COM_LINK, 
				//	значит ее меняли и надо проверить нуждается ли группа в сортировке
				
				var saveObj:Object = SavePerformer.oNeedToSave[CMD.CH_COM_LINK];
				
				var len:int = aItems.length;
				var onlineGroup:String;
				var opt:OptLinkChannel
				
				for (var i:int=1; i<len; ++i) {		// выявляем онлайн группу 
					opt = aItems[i] as OptLinkChannel;
					if (opt.isGprsOnline()) {
						if (!onlineGroup)
							onlineGroup = opt.group;
						if (opt.isWifiOnline())
							onlineGroup = opt.group;
						
						//break;
					}
				}
				if (onlineGroup) {			// если онлайн группа существует
					var sorted:Array = [];
					var shift:int = 0;
					var needSort:Boolean = false;
					var onlineChanged:Boolean = false;
					var lastOffline:Boolean = false;
					var linkOrderShift:int = 0;
					var linkWiFiOrderShift:int = 0;
					var std:Boolean;
					for (i=1; i<len; ++i) {		
						opt = aItems[i] as OptLinkChannel;
						
						
						if(opt.group == onlineGroup) {	// находим нужный канал связи
							if (shift==0)
								shift = i;
							
							if (opt.isGprsOnline())	{	// если он онлайн - пихаем в начало
								
								if( opt.isWifiOnline() )
								{
									
									sorted.splice( linkWiFiOrderShift, 0, opt.linkData );
										
									linkWiFiOrderShift++;
									
								}
								else
								{
									sorted.splice( linkOrderShift + linkWiFiOrderShift, 0, opt.linkData );
									linkOrderShift++;
									
								}
								
								
								if( lastOffline || opt.isWifiOnline() )		// если до онлайна шел оффлайн значит надо делать сортировку
									needSort = true;
									
							} else {					// если если нет, то в конец
								sorted.push( opt.linkData );
								
								lastOffline = true;
								
							}
							
							
							if ( !onlineChanged && saveObj[i] )	// проверяем менялась ли онлайн группа или какая то другая
								onlineChanged = true;
						}
					}
					if (sorted.length > 1 && onlineChanged && needSort) {	// 	нет смысла сортировать когда в группе 1 элемент 
						//	или !onlineChanged, т.е. изменений в группе с онлайном не было
						//	или !needSort, т.е. сортировки не было, все на своих местах и так
						var v:Vector.<Object>;
						var rule:CommandSchemaModel = OPERATOR.getSchema(CMD.CH_COM_LINK);
						for (i=0; i<len; ++i) {
							v = sorted.shift();
							(aItems[i+shift] as OptLinkChannel).linkData = v;
							
							var len2:int = v.length;
							if (!saveObj[i+shift]) {
								saveObj[String(i+shift)] = {};
							}
							for (var l:int=0; l<len2; ++l) {	// приведение вектора объектов к объекту сохранения 
								if( (rule.Parameters[l] as ParameterSchemaModel).Type == "Decimal" )
									saveObj[String(i+shift)][l] = int(v[l]);
								else
									saveObj[String(i+shift)][l] = String(v[l]);
							}
							if (sorted.length == 0)		// когда sorted.length == 0 значит все отсортировано
								break;
						}
						links();
					}
				}
			}
		}
		private function refine(value:Object):int
		{
			if(value is int) {
				switch(value) {
					case CMD.CH_COM_OBJ:
					case CMD.CH_COM_EVENT:
					case CMD.CH_COM_PART:
					case CMD.CH_COM_ZONE:
						return SavePerformer.CMD_TRIGGER_TRUE;
				}
			} else {
				var finalcmd:int = value.cmd;
				var cap:int = getMatrixRealCMDMaxValue(finalcmd);
				//trace(cap+ " " + value.struct);
				if( cap < value.struct )
					return SavePerformer.CMD_TRIGGER_BREAK;
			}
			return SavePerformer.CMD_TRIGGER_FALSE;
		}
		private function fill():void
		{
			for(var i:int; i<8; ++i ) {
				//trace( "getInfoChanges["+i+"] = "+ getInfoChanges[i])
				if ( getInfoChanges[i] == true ) {
					getInfoChanges[i] = false;
					
					CH_INFO_MAXOBJ_LAST_STRUCTURES[UTIL.hash_0To1(i)] = getMatrixRealLineMaxValue(CMD.CH_COM_OBJ,i+1);
					CH_INFO_MAXEVENT_LAST_STRUCTURES[UTIL.hash_0To1(i)] = getMatrixRealLineMaxValue(CMD.CH_COM_EVENT,i+1);
					CH_INFO_MAXPART_LAST_STRUCTURES[UTIL.hash_0To1(i)] = getMatrixRealLineMaxValue(CMD.CH_COM_PART,i+1);
					CH_INFO_MAXZONE_LAST_STRUCTURES[UTIL.hash_0To1(i)] = getMatrixRealLineMaxValue(CMD.CH_COM_ZONE,i+1);
					
					//trace( "CH_INFO_MAXOBJ_LAST_STRUCTURES = "+CH_INFO_MAXOBJ_LAST_STRUCTURES[UTIL.hash_0To1(i)] );
					if ( CH_INFO_MAXOBJ_LAST_STRUCTURES[UTIL.hash_0To1(i)] == 0 &&
						CH_INFO_MAXEVENT_LAST_STRUCTURES[UTIL.hash_0To1(i)] == 0 &&
						CH_INFO_MAXPART_LAST_STRUCTURES[UTIL.hash_0To1(i)] == 0 &&
						CH_INFO_MAXZONE_LAST_STRUCTURES[UTIL.hash_0To1(i)] == 0 ) {
						continue;
					}
					
					RequestAssembler.getInstance().fireEvent( new Request( CMD.CH_COM_GET_INFO, null, 
						i+1,[	CH_INFO_MAXOBJ_LAST_STRUCTURES[UTIL.hash_0To1(i)],
							CH_INFO_MAXEVENT_LAST_STRUCTURES[UTIL.hash_0To1(i)],
							CH_INFO_MAXPART_LAST_STRUCTURES[UTIL.hash_0To1(i)],
							CH_INFO_MAXZONE_LAST_STRUCTURES[UTIL.hash_0To1(i)] ], Request.NORMAL, Request.PARAM_SAVE));
				}
			}
			RequestAssembler.getInstance().fireEvent( new Request( CMD.CH_COM_UPDATE, null, 1, [1], Request.NORMAL, Request.PARAM_SAVE ));
			// Удаление истории
			if (CLIENT.DELETE_HISTORY == 1)
			{
				RequestAssembler.getInstance().fireEvent( new Request( CMD.HISTORY_DELETE, onDeleteSuccess, 1, [UIHistory.HIS_DELETE], Request.NORMAL, Request.PARAM_SAVE ));
			}
				
		}
		private function onDeleteSuccess(p:Package):void
		{
			if (p.success)
			{
				TaskManager.callLater( doClear, 5000 );
				
			}
				
		}
		private function doClear():void
		{
			RequestAssembler.getInstance().doPing(false);
			RequestAssembler.getInstance().fireEvent( new Request( CMD.HISTORY_DELETE, processState ));
			
			timerDeleting = new Timer( 25000, 1 );
			
			timerDeleting.addEventListener( TimerEvent.TIMER_COMPLETE, deleteIncomplete );
			timerDeleting.reset();
			timerDeleting.start();
		}
		override protected function processState(p:Package):void
		{
			super.processState(p);
			if(p.getStructure()[0] == UIHistory.HIS_DELETE_SUCCESS) {
				timerDeleting.stop();
				timerDeleting.removeEventListener( TimerEvent.TIMER_COMPLETE, deleteIncomplete );
				//Warning.show( "Подключен "+SERVER.READABLE_VER+", История успешно удалена", Warning.TYPE_SUCCESS, Warning.STATUS_DEVICE );
				
				GUIEventDispatcher.getInstance().fireEvent( GUIEvents, GUIEvents.onNeedScreenBlock );
				blockNavi = false;
				RequestAssembler.getInstance().doPing(true);
			}
		}
		private function deleteIncomplete(ev:TimerEvent):void
		{
			//Warning.show( "Подключен "+SERVER.READABLE_VER+", Ошибка удаления истории", Warning.TYPE_ERROR, Warning.STATUS_DEVICE );
			GUIEventDispatcher.getInstance().fireEvent( GUIEvents, GUIEvents.onNeedScreenBlock );
			blockNavi = false;
			RequestAssembler.getInstance().doPing(true);
		}
		private function extractEvent(params:Array, data:Array, checkExistance:Boolean=false, addResoreEvent:Boolean=false):Array
		{	// параметры в params укаываются с 1, а не с 0 
			var e:Array = [];
			var len:int = data.length;
			var lenj:int;
			for (var i:int=0; i<len; ++i) {
				lenj= params.length;
				for (var j:int=0; j<lenj; ++j) {
					if (checkExistance) {
						if ( ( data[i][0] == 1 || data[i][0] == 2 ) && data[i][params[j]-1] != 0 && data[i][params[j]-1] != 0xffff) {
							e.push( data[i][params[j]-1] );
							if (addResoreEvent) {
								var evrest:int = int( (data[i][params[j]-1] as int).toString(16).slice(0,3) + "3");
								var cid:Array = CIDServant.getEvent();
								
								var lenk:int = cid.length;
								for (var k:int=0; k<lenk; ++k) {
									if( cid[k].data == evrest ) {
										e.push( int("0x"+evrest) );
										break;
									}
								}
							}
						}
					} else {					
						if ( data[i][params[j]-1] != 0 && data[i][params[j]-1] != 0xffff)
							e.push( data[i][params[j]-1] );
					}
				}
			}
			return e;
		}
		private function cleanClones(a:Array):Array
		{
			var e:Array = [];
			var unique:Boolean;
			var len:int = a.length;
			for (var i:int=0; i<len; ++i) {
				var lenj:int = e.length;
				unique = true;
				for (var j:int=0; j<lenj; ++j) {
					if ( a[i] == e[j] ) {
						unique = false;
						break;
					}
				}
				if (unique)
					e.push( a[i] );
			}
			return e;
		}
	}
}