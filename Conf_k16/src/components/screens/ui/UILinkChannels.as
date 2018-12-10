package components.screens.ui
{
	import flash.utils.Timer;
	
	import components.abstract.LOC;
	import components.abstract.RegExpCollection;
	import components.abstract.Utility;
	import components.abstract.functions.loc;
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
	import components.interfaces.ITask;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.protocol.SocketProcessor;
	import components.protocol.models.CommandSchemaModel;
	import components.protocol.models.ParameterSchemaModel;
	import components.protocol.statics.CLIENT;
	import components.protocol.statics.OPERATOR;
	import components.screens.opt.OptLinkChannel;
	import components.static.CMD;
	import components.static.DS;
	import components.static.GuiLib;
	import components.system.CONST;
	import components.system.SavePerformer;
	
	/**	Редакция для 16м с посылкой REBOOT после удаления истории
	 * ребут должен быть обязательно в одном пакете	с удалением	*/	
	
	public class UILinkChannels extends UI_BaseComponent
	{
		public static const REBOOT:int = 0x01;
		public static const WAS_UPDATE:int = 0x01;
		
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
		
		private var timerDeleting:Timer;
		
		public function UILinkChannels()
		{
			super();
			
			aItems = new Array;
			var opt:OptLinkChannel;
			
			var header:Header = new Header( [{label:loc("ui_linkch_comm_channel"), width:160, xpos:20, align:"left"},{label:loc("ui_linkch_connect_settings"), width:200, xpos:260},
				{label:loc("ui_linkch_conn_try"), width:100, xpos:450}, {label:loc("g_object"), width:100, xpos:548}, {label:loc("g_partition"), width:100, xpos:662},
				{label:loc("ui_linkch_sen_user"), width:100, xpos:770},{label:loc("g_event"), width:100, xpos:916} ] );
			addChild( header );
			header.x = 70;
			header.y = 10;
			
			oGroup = new Object;
			oArrows = new Object;
			
			for( var i:int; i<CONST.LINK_CHANNELS_NUM; ++i ) {
				if (i>0) {
					oGroup[ Utility.hash_0To1(i) ] = new FSRadioGroupH( [{label:loc("ui_linkch_and"), selected:true, id:0x01},{label:loc("ui_linkch_or"), selected:false, id:0x02}],i );
					addChild( (oGroup[ Utility.hash_0To1(i) ] as FSRadioGroupH) );
					(oGroup[ Utility.hash_0To1(i) ] as FSRadioGroupH).setUp( links );
					(oGroup[ Utility.hash_0To1(i) ] as FSRadioGroupH).switchFormat( FSRadioGroupH.F_RADIO_RETURNS_OBJECT );
					(oGroup[ Utility.hash_0To1(i) ] as FSRadioGroupH).x = 42;
					(oGroup[ Utility.hash_0To1(i) ] as FSRadioGroupH).y = opt.y +34
					
					oArrows[ Utility.hash_0To1(i) ] = new GuiLib.cLinkArrow;
					addChild( oArrows[ Utility.hash_0To1(i) ] );
					oArrows[ Utility.hash_0To1(i) ].x = 12;
					oArrows[ Utility.hash_0To1(i) ].visible = false;
					oArrows[ Utility.hash_0To1(i) ].y = opt.y + 8;
				}
				opt = new OptLinkChannel( Utility.hash_0To1(i) );
				addChild( opt );
				opt.y = (opt.getHeight()+25)*i+50;
				opt.x = 40;
				aItems[ Utility.hash_0To1(i) ] = opt;
			}
			
			var sep1:Separator = new Separator( 910 );
			sep1.x = 10;
			sep1.y = opt.y  + opt.getHeight()+ 25;
			addChild( sep1 );
			
			globalY = sep1.y +20;
			
			createUIElement( new FSComboBox, CMD.CH_COM_ADD,loc("ui_linkch_interrupt_conn"),null,1,
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
				"",2,new RegExp("^(([1-9])|([1-5]\\d)|60|"+loc("ui_linkch_no_interrupt")+")$") ).x = 40;
			attuneElement( 750, 120 );
			var sep2:Separator = new Separator( 910 );
			sep2.x = 10;
			sep2.y = sep1.y +60;
			addChild( sep2 );
			
			var stext1:SimpleTextField = new SimpleTextField( loc("ui_linkch_direction_type"), 400 );
			stext1.setSimpleFormat("left",0,16,true);
			addChild( stext1 );
			stext1.x = 40;
			stext1.y = sep2.y + 10;
			
			var fsRgroup:FSRadioGroup = new FSRadioGroup( [ {label:loc("ui_linkch_stay_one_dir"), selected:false, id:0x01 },
				{label:loc("ui_linkch_go_next_dir"), selected:false, id:0x02 }], 1, 30 );
			fsRgroup.y = stext1.y + 30;
			fsRgroup.x = 40;
			fsRgroup.width = 700;
			addChild( fsRgroup );
			addUIElement( fsRgroup, CMD.CH_COM_ADD, 2);
			
			globalY = fsRgroup.y + fsRgroup.getHeight()-7;
			
			drawSeparator(910);
			globalY-=8;
			
			addui( new FSCheckBox, CMD.CH_SEND_IMEI, loc("ui_linkch_send_imei"), null, 1 ).x = 40;
			attuneElement( 700 );
			globalY-=9;
			drawSeparator(910);
			
			//globalY += 30;
			
			var stext2:SimpleTextField = new SimpleTextField( loc("ui_linkch_channel_desc"), 900 );
			addChild( stext2 );
			stext2.x = 40;
			stext2.y = globalY;
			globalY += stext2.height;
			
			if (DS.release < 6) {	// с 6го релиза
				var stext3:SimpleTextField = new SimpleTextField( loc("ui_linkch_change_clear_history"), 900, 0xff0000 );
				addChild( stext3 );
				stext3.x = 40;
				stext3.y = stext2.y + 40;
				globalY += stext3.height;
			}
			
			getInfoChanges = new Vector.<Boolean>;
			getInfoChanges.length = 8;
			getInfoChanges.fixed = true;
			
			
			if (DS.release >= 11 ) { 
				addui( new FSSimple, CMD.PING_SET_TIME, loc("test_ping") + " 20...120)", null, 1, null, "0-9", 3, new RegExp(RegExpCollection.REF_20to120) ).x = 40;
				attuneElement( 700+79,60 );
			}
			
			starterCMD = [CMD.CH_SEND_IMEI, CMD.CH_COM_MAX_INFO, CMD.CH_COM_LINK_LOCK];
			width = 1105;
			height = 770;
			
			if (DS.release >= 11 ) { 
				starterRefine( CMD.PING_SET_TIME, true );
				
			}
			
			
			
			if( DS.isDevice( DS.K16_3G ))
			{
				starterCMD = [ CMD.MODEM_NETWORK_CTRL ].concat( starterCMD );
			}
			
			
		}
		override public function open():void
		{
			super.open();
			LOADING = true;
		}
		override public function close():void
		{
			super.close();
			isGPRSOnline = false;
			if(timerDeleting)
				timerDeleting.stop();
		}
		override public function put(p:Package):void
		{
			if ( !GUIEventDispatcher.getInstance().hasEventListener(GUIEvents.onGPRSOnline) )
				GUIEventDispatcher.getInstance().addEventListener( GUIEvents.onGPRSOnline, gprsOnlineChanged );
			
			switch(p.cmd) {
				case CMD.CH_COM_LINK_LOCK:
					if( CONST.DEBUG )
						break;
					var obj:Object;
					
					if( p.data[ 0 ] == 0x00 )
					{
						for each( obj in aItems )OptLinkChannel( obj ).onDisableOfBlockWriters( true );
						for each( obj in oGroup )FSRadioGroupH( obj ).block( null );
					}
					else
					{
						for each( obj in aItems )OptLinkChannel( obj ).onDisableOfBlockWriters( false );
						for each( obj in oGroup )FSRadioGroupH( obj ).deblock();
					}
					
					
					
					break;
				case CMD.CH_SEND_IMEI:
					distribute( p.getStructure(), p.cmd );
					break;
				case CMD.MODEM_NETWORK_CTRL:
					
					
					var len:int = aItems.length;
					var opt:OptLinkChannel;
					for(var i:int=1; i<len; ++i ) {
						opt = aItems[i];
						if ( opt ) {
							opt.putAtypicalData( p.cmd, p.data );
						}
					}

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
					
					if (CH_INFO_MAXEVENT == 0xffff || CH_INFO_MAXZONE == 0xffff ) {
						loadComplete();
						loadStart();
						popup = PopUp.getInstance();
						popup.construct( PopUp.wrapHeader("sys_incorrect_data"), PopUp.wrapMessage("sys_page_would_not_load"), PopUp.BUTTON_OK );
						popup.open();
						return;
					}
					
					// Обновляем информацию о реальном количестве структур
					OPERATOR.getSchema( CMD.CH_COM_OBJ ).StructCount = CH_INFO_MAXOBJ;
					OPERATOR.getSchema( CMD.CH_COM_EVENT).StructCount = CH_INFO_MAXEVENT;
					OPERATOR.getSchema( CMD.CH_COM_ZONE).StructCount = CH_INFO_MAXZONE;
					OPERATOR.getSchema( CMD.CH_COM_PART ).StructCount = CH_INFO_MAXPART;
					
					SavePerformer.trigger( {"before":erase, "after":fill, "cmd":refine, "prepare":prepare, "error":error} );
					RequestAssembler.getInstance().fireEvent( new Request( CMD.CH_COM_GET_INFO, put ));
					break;
				case CMD.CH_COM_GET_INFO:
					calcMaxValuesForCH(p.data.slice() );
					
					RequestAssembler.getInstance().fireEvent( new Request( CMD.CH_COM_LINK, put ) );
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
					var lenn:int = aItems.length;
					var optt:OptLinkChannel;
					for(var ii:int=1; ii<lenn; ++ii ) {
						optt = aItems[ii];
						if ( optt ) {
							optt.putAuto( p.getStructure(ii), p.cmd );
							
							if (aTypical && p.structure <= getMaxStructureValue(p.cmd,ii) )
								optt.putAtypicalData( p.cmd, aTypical[ii] );
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
					LOADING = false;
					testInterruption();
					loadComplete();
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
			
			// Если была чистка памяти - выставляем значения в 0, т.е. не выбрано ничего
			
			for(var key:String in arr) {
				
				CH_INFO_MAXOBJ_LAST_STRUCTURES[Utility.hash_0To1(key)] = CH_INFO_MAXOBJ<arr[key][0] ? CH_INFO_MAXOBJ : arr[key][0];
				CH_INFO_MAXEVENT_LAST_STRUCTURES[Utility.hash_0To1(key)] = CH_INFO_MAXEVENT<arr[key][1] ? CH_INFO_MAXEVENT : arr[key][1];
				CH_INFO_MAXPART_LAST_STRUCTURES[Utility.hash_0To1(key)] = CH_INFO_MAXPART<arr[key][2] ? CH_INFO_MAXPART : arr[key][2];
				CH_INFO_MAXZONE_LAST_STRUCTURES[Utility.hash_0To1(key)] = CH_INFO_MAXZONE<arr[key][3] ? CH_INFO_MAXZONE : arr[key][3];
				
				if (arr[key][0] > CH_INFO_MAXOBJ_LAST) {
					if ( arr[key][0] == 0xff )
						CH_INFO_MAXOBJ_LAST = 0;
					else if (CH_INFO_MAXOBJ<arr[key][0])
						CH_INFO_MAXOBJ_LAST = CH_INFO_MAXOBJ;
					else
						CH_INFO_MAXOBJ_LAST = arr[key][0];
				}
				if (arr[key][1] > CH_INFO_MAXEVENT_LAST) {
					if ( arr[key][1] == 0xffff )
						CH_INFO_MAXEVENT_LAST = 0;
					else if( CH_INFO_MAXEVENT<arr[key][1] )
						CH_INFO_MAXEVENT_LAST = CH_INFO_MAXEVENT;
					else
						CH_INFO_MAXEVENT_LAST = arr[key][1];
				}
				if (arr[key][2] > CH_INFO_MAXPART_LAST) {
					if( arr[key][2] == 0xff )
						CH_INFO_MAXPART_LAST = 0;
					else if( CH_INFO_MAXPART<arr[key][2] )
						CH_INFO_MAXPART_LAST = CH_INFO_MAXPART;
					else
						CH_INFO_MAXPART_LAST = arr[key][2];
				}
				if (arr[key][3] > CH_INFO_MAXZONE_LAST) {
					if( arr[key][3] == 0xffff )
						CH_INFO_MAXZONE_LAST = 0;
					else if( CH_INFO_MAXZONE<arr[key][3] )
						CH_INFO_MAXZONE_LAST = CH_INFO_MAXZONE;
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
			var key:String;
			if( ev.isGPRSOnline() ) {
				isGPRSOnline = true;
				
				getField( CMD.CH_COM_ADD,1 ).disabled = !isAtLeast2ChannelsEnabled();
			} else {
				// Если был выбра канал OFFLINE надо проверить если все остальные каналы OFFLINE то разблокировать радиогруп
				getField( CMD.CH_COM_ADD,1 ).disabled = true;
				for( key in aItems ) {
					if( (aItems[key] as OptLinkChannel).isGprsOnline() ) {
						getField( CMD.CH_COM_ADD,1 ).disabled = !isAtLeast2ChannelsEnabled();
						return;
					}
				}
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
				// Теперь все кто не принадлежит этой группе ставятся оффлайн
				for( key in aItems ) {
					if ( (aItems[key] as OptLinkChannel).getField(CMD.CH_COM_LINK,1).getCellInfo() != currentGroupOnline )
						(aItems[key] as OptLinkChannel).setGPRSoffline();
				}
			}
			
			if ( isGPRSOnline ) {
				(getField( CMD.CH_COM_ADD,2 ) as FSRadioGroup).block([0]);
				if ( (getField( CMD.CH_COM_ADD,2 ) as FSRadioGroup).getCellInfo() != "2" && ev.getStructure() is int && !LOADING )
					SavePerformer.remember( getStructure(),getField( CMD.CH_COM_ADD,2 ));
				(getField( CMD.CH_COM_ADD,2 ) as FSRadioGroup).setCellInfo("2");
			} else
				(getField( CMD.CH_COM_ADD,2 ) as FSRadioGroup).block();
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
								if( (CH_INFO_MAXOBJ_LAST_STRUCTURES[Utility.hash_0To1(p)] < Utility.hash_0To1(s)) )
									canProcessData = false;
								break;
							case CMD.CH_COM_ZONE:
								if( (CH_INFO_MAXZONE_LAST_STRUCTURES[Utility.hash_0To1(p)] < Utility.hash_0To1(s)) )
									canProcessData = false;
								break;
							case CMD.CH_COM_EVENT:
								if( (CH_INFO_MAXEVENT_LAST_STRUCTURES[Utility.hash_0To1(p)] < Utility.hash_0To1(s)) )
									canProcessData = false;
								break;
							case CMD.CH_COM_PART:
								if( (CH_INFO_MAXPART_LAST_STRUCTURES[Utility.hash_0To1(p)] < Utility.hash_0To1(s)) )
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
							(oMatrix[cmd][s][param] as FSShadow).setCellInfo( data[ Utility.hash_1To0(s) ] );
							if(!offsetDone && param < OPERATOR.getSchema(cmd).Parameters.length ) {
								for(var mgd:int=1; mgd<=masterGroupOffset; ++mgd) {
									(oMatrix[cmd][s][param + mgd] as FSShadow).setCellInfo( data[ Utility.hash_1To0(s) ] );
								}
								offsetDone = true;
							}
						}
						SavePerformer.remember(int(s),(oMatrix[cmd][s][p] as FSShadow),false,false);
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
		private function linksFirstRun():void
		{
			var groupNum:int = 1;
			
			var prevOpt:OptLinkChannel;
			var currentOpt:OptLinkChannel;
			var prevField:IFormString;
			var currentField:IFormString;
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
					
					// Если предыдущая группа равна current ставим стрелочки visible=true					
					if ( prevField.getCellInfo() == currentField.getCellInfo() ) {
						(oGroup[key] as FSRadioGroupH).setCellInfo("2");
						oArrows[key].visible = true;
						currentOpt.slave = true;
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
		}
		private function links():void
		{
			var prevOpt:OptLinkChannel;
			var currentOpt:OptLinkChannel;
			var prevField:IFormString;
			var currentField:IFormString;
			var onlineGroup:String=""; // Первая группа которая содержит GPRS онлайн
			
			var masterOpt:OptLinkChannel;
			var dataDistribution:Vector.<OptLinkChannel>;
			
			for( var key:String in oGroup ) {
				prevOpt = aItems[ int(key)-1 ] as OptLinkChannel;
				currentOpt = aItems[key] as OptLinkChannel;
				
				prevField = prevOpt.getField(CMD.CH_COM_LINK,1);
				currentField = currentOpt.getField(CMD.CH_COM_LINK,1);
				
				// Если в радиоботтоне поставили ИЛИ
				if( int((oGroup[key] as FSRadioGroupH).getCellInfo()) == 2) {
					
					if( !prevOpt.slave )
						masterOpt = prevOpt;
					currentField.setCellInfo( prevField.getCellInfo().toString() );
					if( oArrows[key].visible != true ) {
						if (!dataDistribution)
							dataDistribution = new Vector.<OptLinkChannel>;
						dataDistribution.push( masterOpt );
					}
					
					oArrows[key].visible = true;
					SavePerformer.remember( currentOpt.getStructure(), currentField );
					currentOpt.slave = true;
				// А если И
				} else {
					
					currentOpt.slave = false;
					
					if ( currentField.getCellInfo() == prevField.getCellInfo() ) {
						
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
				if (key == "2" && prevOpt.isGprsOnline() ) 
					onlineGroup = String( prevOpt.getField(CMD.CH_COM_LINK,1).getCellInfo() );
				
				if(onlineGroup == "") {
					if( currentOpt.isGprsOnline() ) 
						onlineGroup = String( currentOpt.getField(CMD.CH_COM_LINK,1).getCellInfo() );
				} else {
					if( currentOpt.getField(CMD.CH_COM_LINK,1).getCellInfo() != onlineGroup )
						currentOpt.setGPRSoffline();
				}
			}
			if (dataDistribution) {
				var len:int = dataDistribution.length;
				for(var i:int=0; i<len; ++i ) {
					dataDistribution[i].callDataDistributionOnSlaves();
				}
			}
		}
		private function erase():void
		{
			for(var i:int=0; i<8; ++i ) {
				if ( getInfoChanges[i] == true )
					RequestAssembler.getInstance().fireEvent( new Request( CMD.CH_COM_GET_INFO, null,i+1,[0,0,0,0]));
			}
		}
		private function error(cmd:int):Boolean
		{
			
			popup = PopUp.getInstance();
			popup.construct( PopUp.wrapHeader("sys_save_error"), PopUp.wrapMessage("ui_linkch_not_saved"), PopUp.BUTTON_OK);
			popup.open();
			GUIEventDispatcher.getInstance().fireEvent( GUIEvents, GUIEvents.onNeedScreenBlock );
			blockNavi = false;
			return false;
		}
		private function prepare():void
		{
			if (CLIENT.DELETE_HISTORY == 1) {
				GUIEventDispatcher.getInstance().fireEvent( GUIEvents, GUIEvents.onNeedScreenBlock, 
					{getScreenMode:ScreenBlock.MODE_LOADING_TEXT, getScreenMsg:LOC.loc("his_wait_for_delete_mins")} );
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
						onlineGroup = opt.group;
						break;
					}
				}
				if (onlineGroup) {			// если онлайн группа существует
					var sorted:Array = [];
					var shift:int = 0;
					var needSort:Boolean = false;
					var onlineChanged:Boolean = false;
					var lastOffline:Boolean = false;
					var linkOrderShift:int = 0;
					for (i=1; i<len; ++i) {		
						opt = aItems[i] as OptLinkChannel;
						if(opt.group == onlineGroup) {	// находим нужный канал связи
							if (shift==0)
								shift = i;
							if (opt.isGprsOnline())	{	// если он онлайн - пихаем в начало
								sorted.splice( linkOrderShift, 0, opt.linkData );
								linkOrderShift++;
								if( lastOffline )		// если до онлайна шел оффлайн значит надо делать сортировку
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
					
					CH_INFO_MAXOBJ_LAST_STRUCTURES[Utility.hash_0To1(i)] = getMatrixRealLineMaxValue(CMD.CH_COM_OBJ,i+1);
					CH_INFO_MAXEVENT_LAST_STRUCTURES[Utility.hash_0To1(i)] = getMatrixRealLineMaxValue(CMD.CH_COM_EVENT,i+1);
					CH_INFO_MAXPART_LAST_STRUCTURES[Utility.hash_0To1(i)] = getMatrixRealLineMaxValue(CMD.CH_COM_PART,i+1);
					CH_INFO_MAXZONE_LAST_STRUCTURES[Utility.hash_0To1(i)] = getMatrixRealLineMaxValue(CMD.CH_COM_ZONE,i+1);
					
					//trace( "CH_INFO_MAXOBJ_LAST_STRUCTURES = "+CH_INFO_MAXOBJ_LAST_STRUCTURES[Utility.hash_0To1(i)] );
					if ( CH_INFO_MAXOBJ_LAST_STRUCTURES[Utility.hash_0To1(i)] == 0 &&
						CH_INFO_MAXEVENT_LAST_STRUCTURES[Utility.hash_0To1(i)] == 0 &&
						CH_INFO_MAXPART_LAST_STRUCTURES[Utility.hash_0To1(i)] == 0 &&
						CH_INFO_MAXZONE_LAST_STRUCTURES[Utility.hash_0To1(i)] == 0 ) {
						continue;
					}
					
					RequestAssembler.getInstance().fireEvent( new Request( CMD.CH_COM_GET_INFO, null, i+1, 
						[	CH_INFO_MAXOBJ_LAST_STRUCTURES[Utility.hash_0To1(i)],
							CH_INFO_MAXEVENT_LAST_STRUCTURES[Utility.hash_0To1(i)],
							CH_INFO_MAXPART_LAST_STRUCTURES[Utility.hash_0To1(i)],
							CH_INFO_MAXZONE_LAST_STRUCTURES[Utility.hash_0To1(i)] ]));
				}
			}
			
			var r:int = DS.release;
			
			if (DS.release >= 6) {	// с 6го релиза
				RequestAssembler.getInstance().fireEvent( new Request( CMD.CH_COM_UPDATE, onUpdateOk, 1, [WAS_UPDATE] ));
				
				GUIEventDispatcher.getInstance().fireEvent( GUIEvents, GUIEvents.onNeedScreenBlock, 
					{getScreenMode:ScreenBlock.MODE_LOADING_TEXT, getScreenMsg:loc("linkch_apply_channels")} );
				blockNavi = true;
			} else {
				// Удаление истории
				if (CLIENT.DELETE_HISTORY == 1) {
					RequestAssembler.getInstance().fireEvent( new Request( CMD.HISTORY_DELETE, onDeleteSuccess, 1, [UIHistory.HIS_DELETE] ));
					
					GUIEventDispatcher.getInstance().fireEvent( GUIEvents, GUIEvents.onNeedScreenBlock, 
						{getScreenMode:ScreenBlock.MODE_LOADING_TEXT, getScreenMsg:loc("ui_linkch_his_delete_reload")} );
					blockNavi = true;
				}
			}
		}
		/***************** RELEASE 6+ ******************************************/
		
		private function onUpdateOk(p:Package):void
		{
			CLIENT.NOT_REQUEST_WHILE_IDLE = true;
			RequestAssembler.getInstance().fireEvent( new Request( CMD.PING, onPingOk, 1, [WAS_UPDATE] ));
		}
		private function onPingOk(p:Package):void
		{
			TaskManager.callLater( doRelease, TaskManager.DELAY_10SEC ); 
			CLIENT.NOT_REQUEST_WHILE_IDLE = false;
		}
		private function doRelease():void
		{
			loadComplete();
			blockNavi = false;
		}
		
		/***************** RELEASE < 6 *****************************************/
		
		private var task:ITask;
		private function onDeleteSuccess(p:Package):void
		{
			task = TaskManager.callLater( doClear, 5000 );
		}
		private function doClear():void
		{
			RequestAssembler.getInstance().fireEvent( new Request( CMD.HISTORY_DELETE, doCheckHistoryDelete ));
			task.repeat();
		}
		private function doCheckHistoryDelete(p:Package):void
		{
			if(p.getStructure()[0] == UIHistory.HIS_DELETE_SUCCESS) {
				RequestAssembler.getInstance().fireEvent( new Request( CMD.REBOOT, null, 1, [REBOOT] ));
				
				task.stop();
				TaskManager.callLater( function():void{ SocketProcessor.getInstance().reConnect()}, TaskManager.DELAY_1SEC*5 );  
			} else {
				doClear();
				task.repeat();
			}
		}
	}
}