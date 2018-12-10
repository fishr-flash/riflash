package components.screens.ui
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextFormatAlign;
	
	import components.abstract.GroupOperator;
	import components.abstract.RegExpCollection;
	import components.abstract.functions.loc;
	import components.abstract.servants.BitMasterMind;
	import components.abstract.servants.TaskManager;
	import components.basement.UI_BaseComponent;
	import components.events.GUIEvents;
	import components.gui.PopUp;
	import components.gui.SimpleTextField;
	import components.gui.fields.FSCheckBox;
	import components.gui.fields.FSRadioGroup;
	import components.gui.fields.FSRadioGroupH;
	import components.gui.fields.FSShadow;
	import components.gui.fields.FSSimple;
	import components.gui.triggers.TextButton;
	import components.interfaces.IFormString;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.protocol.statics.CLIENT;
	import components.protocol.statics.OPERATOR;
	import components.screens.opt.OptLinkChannelK1M;
	import components.screens.opt.OptLinkTime;
	import components.static.CMD;
	import components.static.COLOR;
	import components.static.DS;
	import components.static.MISC;
	import components.static.PAGE;
	import components.system.CONST;
	import components.system.Controller;
	import components.system.Library;
	import components.system.SavePerformer;
	import components.system.UTIL;
	
	public class UILinkChannelsK9 extends UI_BaseComponent
	{
		public static var MASTER:Boolean = false;
		
		private var fsRgroup:FSRadioGroup;
		private var group:Vector.<FSRadioGroupH>; // Группа объектов радиобуттонов
		private var oArrows:Object;
		private var groups:Array;
		private var opts:Vector.<OptLinkChannelK1M>;
		private var gprs:Vector.<IFormString>;
		private var linksNeedResave:Boolean = false;	// true, когда были изменены либо каналы либо группы, надо пройтись по списку и выключить/выключить группы
		private var colors:Array = [COLOR.WIRE_LIGHT_BROWN, COLOR.CIAN, COLOR.GREEN_EMERALD, COLOR.YELLOW_SIGNAL, COLOR.VIOLET, COLOR.SATANIC_INVERT_GREY, COLOR.GLAMOUR, COLOR.BLUE ];
		
		private var bitmm:BitMasterMind;
		private var bExtend:TextButton;
		private var go:GroupOperator;
		private var optsTime:Vector.<OptLinkTime>;
		private var needClearHistory:Boolean=false;
		private var _firewall:Sprite;
		
		public function UILinkChannelsK9()
		{
			super();
			
			gprs = new Vector.<IFormString>;
			bitmm = new BitMasterMind;
			
			addui( new FSShadow,CMD.K9_BIT_SWITCHES, "", null, 1 );
			bitmm.addContainer( getLastElement() );
			gprs.push( getLastElement() );
			addui( new FSShadow,CMD.K9_BIT_SWITCHES, "", null, 2 );
			bitmm.addContainer( getLastElement() );			
			gprs.push( getLastElement() );
			
			var w:int = 450;
			
			addui( new FSCheckBox, 0, loc("ui_linkch_gprs_sim1"), null, 2 );
			attuneElement( w );
			bitmm.addController( getLastElement(), 1, 3, updateGprs );
			

			
			if ( CLIENT.SIM_SLOT_COUNT > 1) {
				addui( new FSCheckBox, 0, loc("ui_linkch_gprs_sim2"), null, 3 );
				attuneElement( w );
				bitmm.addController( getLastElement(), 1, 4, updateGprs);
			}
			drawSeparator(w+53+250);
			
			group = new Vector.<FSRadioGroupH>(9);
			oArrows = new Object;
			
			var opt:OptLinkChannelK1M;
			opts = new Vector.<OptLinkChannelK1M>(9);
			
			for( var i:int; i<8; ++i ) {
				if (i>0) {
					group[ UTIL.hash_0To1(i) ] = new FSRadioGroupH( [{label:loc("ui_linkch_and"), selected:true, id:0x01},{label:loc("ui_linkch_or"), selected:false, id:0x02}],i );
					addChild( (group[ UTIL.hash_0To1(i) ] as FSRadioGroupH) );
					(group[ UTIL.hash_0To1(i) ] as FSRadioGroupH).setUp( links );
					(group[ UTIL.hash_0To1(i) ] as FSRadioGroupH).switchFormat( FSRadioGroupH.F_RADIO_RETURNS_OBJECT );
					(group[ UTIL.hash_0To1(i) ] as FSRadioGroupH).x = 42 + 50 + 72;
					(group[ UTIL.hash_0To1(i) ] as FSRadioGroupH).y = opt.y +34
					
					oArrows[ UTIL.hash_0To1(i) ] = new Library.cLinkArrow;
					addChild( oArrows[ UTIL.hash_0To1(i) ] );
					oArrows[ UTIL.hash_0To1(i) ].x = 12;
					oArrows[ UTIL.hash_0To1(i) ].visible = false;
					oArrows[ UTIL.hash_0To1(i) ].y = opt.y + 8;
				}
				opt = new OptLinkChannelK1M( UTIL.hash_0To1(i) );
				addChild( opt );
				opt.y = (opt.getHeight()+25)*i+ globalY;
				opt.x = PAGE.CONTENT_LEFT_SHIFT + 10;
				opt.addEventListener( GUIEvents.EVOKE_CHANGE, onLinkChange );
				opt.addEventListener( GUIEvents.EVOKE_CHANGE_PARAM, onTelChange );
				opts[ UTIL.hash_0To1(i) ] = opt;
			}
			
			globalY += 400-19;
			
			drawSeparator(w+53+250);
			
			fsRgroup = new FSRadioGroup( [ {label:loc("ui_linkch_stay_one_dir"), selected:false, id:0x01 },
				{label:loc("ui_linkch_go_next_dir"), selected:false, id:0x00 }], 1, 30 );
			fsRgroup.y = globalY;
			fsRgroup.x = PAGE.CONTENT_LEFT_SHIFT;
			fsRgroup.width = 700;
			addChild( fsRgroup );
			addUIElement( fsRgroup, 0, 3, null );
			bitmm.addController( fsRgroup, 1, 2 );
			
			globalY += 60;
			
			addui( new FSCheckBox, CMD.K9_IMEI_IDENT, loc("ui_linkch_send_imei"), null, 1 );
			attuneElement( w + 250 );
			
			addui( new FSSimple, CMD.PING_SET_TIME, loc("test_ping") + ", 20-240)", null, 1, null, "0-9", 3, new RegExp(RegExpCollection.REF_20to240) );
			attuneElement( w + 200, 60 );
			
			go = new GroupOperator;
			
			bExtend = new TextButton;
			addChild( bExtend );
			bExtend.setUp("+ "+loc("g_additional"), onClick);
			bExtend.x = globalX;
			bExtend.y = globalY;
			
			globalY += 35;
			var anchor:int = globalY;
			
			globalY = anchor;
			
			addui( new FSShadow, CMD.K5_AND_OR, "", null, 1 );
			addui( new FSShadow, CMD.K5_AND_OR, "", null, 2 );
			addui( new FSShadow, CMD.K5_AND_OR, "", null, 3 );
			addui( new FSShadow, CMD.K5_AND_OR, "", null, 4 );
			addui( new FSShadow, CMD.K5_AND_OR, "", null, 5 );
			addui( new FSShadow, CMD.K5_AND_OR, "", null, 6 );
			addui( new FSShadow, CMD.K5_AND_OR, "", null, 7 );
			addui( new FSShadow, CMD.K5_AND_OR, "", null, 8 );
			
			height = 650;
			
			super.manualResize();
			
			starterCMD = [CMD.K9_BIT_SWITCHES, CMD.PING_SET_TIME, CMD.K5_APHONE, CMD.K9_DIRECTIONS, CMD.K5_AND_OR, CMD.K9_IMEI_IDENT, 
				CMD.CH_COM_TIME_PARAM_COUNT, CMD.CH_COM_TIME_PARAM  ];
			
			MASTER = true;
			if( DS.isfam( DS.K9 ) || ( DS.isDevice( DS.K1M ) && int( DS.app ) > 6  ) )starterCMD.push( CMD.CH_COM_LINK_LOCK );
			
		}
		override public function put(p:Package):void
		{
			var len:int, i:int;
			switch(p.cmd) {
				case CMD.CH_COM_LINK_LOCK:
					
					if( CONST.DEBUG )
						break;
					var obj:Object;
					
					
					if( p.data[ 0 ] == 0x00 )
						createFirewall();
					else if( _firewall && _firewall.parent )
						_firewall.parent.removeChild( _firewall );
					
					
					break;
				case CMD.K9_BIT_SWITCHES:
					
					needClearHistory = false;
					
					refreshCells(p.cmd);
					SavePerformer.trigger( {after:after, cmd:cmd } );
					Controller.hook = onSave;
					LOADING = true;	// влияет на updateGprs(), чтобы могли прогрузиться поля без необходимости стирать историю
					bitmm.put(p);
					LOADING = false;
					
					break;
				case CMD.K9_IMEI_IDENT:
					distribute( p.getStructure(), p.cmd );
					MASTER = false;
					break;
				case CMD.K5_APHONE:
					len = opts.length;
					for (i=0; i<len; i++) {
						if (opts[i]) {
							opts[i].putPhone(p.getStructure(i));
						}
					}
					break;
				case CMD.K9_DIRECTIONS:
					
					len = opts.length;
					for (i=0; i<len; i++) {
						if (opts[i]) {
							opts[i].putDirection(p.getStructure(i)[0]);
						}
					}
					break;
				case CMD.K5_AND_OR:
					
					needClearHistory = true;
					
					var links:Array = p.getStructure();
					len = links.length;
					var gnum:int=2, gsize:int, ltotal:int;
					for (i=0; i<len; i++) {
						if( links[i] > 0) {
							gsize = links[i];
							while(true) {
								if (gnum >= group.length ) {
									if (gsize>0)
										ltotal++;
									break;
								}
								if (gsize == 1) {
									ltotal++;
									(group[gnum] as IFormString).setCellInfo(1);
									//	oArrows[gnum].visible = false;
									gnum++;
									break;
								}
								if( group[gnum] ) {
									ltotal++;
									(group[gnum] as IFormString).setCellInfo(2);
									//	oArrows[gnum].visible = true;									
								} else
									break;
								gsize--;
								gnum++;
							}
						} else
							break;
					}
				//	colorize(links);
					if (ltotal < 8) {
						len = opts.length;
						for (i=1+ltotal; i<len; i++) {
							if (opts[i])
								opts[i].active = false;
						}
					}
					linksDisabler();
					
					break;
				case CMD.CH_COM_TIME_PARAM:
					len = OPERATOR.dataModel.getData(CMD.CH_COM_TIME_PARAM_COUNT)[0][0];
					
					if (!optsTime)
						optsTime = new Vector.<OptLinkTime>(len);
					
					for (i=0; i<len; i++) {
						if( !optsTime[i] ) {
							optsTime[i] = new OptLinkTime(i+1);
							addChild( optsTime[i] );
							optsTime[i].x = globalX;
							optsTime[i].y = globalY;
							globalY += 25;
							optsTime[i].visible = false;
							go.add("ext",optsTime[i]);
						}
						optsTime[i].putData(p);
					}
					loadComplete();
					
					this.links();
					
					break;
				case CMD.PING_SET_TIME:
					
					pdistribute(p);
					break;
			}
			
			
		}
		override public function close():void
		{
			super.close();
			Controller.hook = null;
		}
		private function colorize(links:Array):void
		{
			// 2,2,1,1,1,0,0,0 - расшифровывается как группа из 2х каналов, группа из 2х каналов, группа из 1 канала .....
			// необходимо перебрать все группы, увеличивая на 1 индекс массива цвета.
			var a:Array = links.slice();
			var colorindex:int;
			var counter:int = 0;
			for (var i:int=0; i<8; i++) {
				opts[i+1].setColor( colors[colorindex] );
				counter++;
				if (counter==a[colorindex]) {
					counter=0;
					colorindex++;
				} else {
					trace();
				}
			}
		}
		private function onSave():void
		{
			if (!needClearHistory || (MISC.COPY_DEBUG && (CLIENT.DELETE_HISTORY == 0)) ) {	// убираем запрос удаления истории
				loadComplete();
				blockNaviSilent = false;
				SavePerformer.save();
			} else { 
				popup = PopUp.getInstance();
				popup.construct( PopUp.wrapHeader("sys_attention"), PopUp.wrapMessage("his_delete_when_save"), PopUp.BUTTON_OK | PopUp.BUTTON_CANCEL, [onDoSave, onDoCancel] );
				popup.open();
			}
		}
		private function onDoSave():void
		{
			loadStart();
			blockNaviSilent = true;
			SavePerformer.save();
			//RequestAssembler.getInstance().fireEvent( new Request( CMD.HISTORY_DELETE, doClear, 1 ,[UIHistory.HIS_DELETE] ));
		}
		/*private function onSaveSuccess():void
		{
			RequestAssembler.getInstance().fireEvent( new Request( CMD.HISTORY_DELETE, doClear, 1 ,[UIHistory.HIS_DELETE] ));
		}*/
		private function onDoCancel():void
		{
			SavePerformer.rememberBlank();
		}
		private function doClear(p:Package):void
		{
			if (p.success) {
				TaskManager.callLater( sendHistoryRequest, 30000 );
				RequestAssembler.getInstance().doPing(false);
			} else {
				if( p.getStructure()[0] == 2 ) {
					loadComplete();
					blockNaviSilent = false;
//					SavePerformer.save();
				} else {
					TaskManager.callLater( sendHistoryRequest, TaskManager.DELAY_2SEC );
				}
			}
		}
		private function sendHistoryRequest():void
		{
			RequestAssembler.getInstance().fireEvent( new Request( CMD.HISTORY_DELETE, doClear ));
			RequestAssembler.getInstance().doPing(MISC.DEBUG_DO_PING==1);
		}
		private function linksMixer(n:Number=NaN):void
		{
			
			if (!isNaN(n)) {
				if ( (opts[n-1] && opts[n-1].active) && opts[n].active )
					return;
			}
			
			needClearHistory = true;
			
			var len:int = opts.length;
			var telrecover:Array;
			var needremix:Boolean=false;
			var foundgasp:Boolean=false;
			for (var i:int=1; i<len; i++) {
				if (opts[i]) {
					if (telrecover) {
						if (opts[i].getDir() == 0)
							foundgasp = true;	// если найдено поле с 0, возможно это конец направлений
						else if (foundgasp)
							needremix = true;	// если был найден конец направлений и опять валидный канал, значит был разрыв, надо переформировать направления
						opts[i-1].putDirection( opts[i].getDir() );
						opts[i-1].putPhone( opts[i].getTel() );
						opts[i-1].rememberchange();
						if (i+1 == len) {
							opts[i].putDirection( opts[i].emptyvalue );
							opts[i].putPhone( telrecover );
							opts[i].rememberchange();
						}
					} else if( !opts[i].active ) {
						telrecover = opts[i].getTel();
					}
				}
			}
			
			var foundinactive:Boolean = false;
			for (i=1; i<len; i++) {
				if (opts[i] && opts[i].active && foundinactive) {
					needremix = true;
					break;
				}
				if (opts[i] && !opts[i].active )
					foundinactive = true;
			}
			
			if (needremix)
				linksMixer();
		}
		private function linksDisabler():void
		{
			var len:int = opts.length;
			var foundlast:Boolean = false;
			for (var i:int=1; i<len; i++) {
				if (opts[i]) {
					if (foundlast) {
						opts[i].active = false;
					} else if( !opts[i].active )
						foundlast = true;
				}
			}
		}
		private function links():void
		{
			var g:Array = [0];
			var gpos:int, value:int;
			for( var key:String in group) {
				if (group[key]) {
					value = int((group[key] as IFormString).getCellInfo());
					if (value == 2) {
						g[gpos]++;
					} else {
						g[gpos]++;
						g.push(0);
						gpos++;
					}
				}
			}
			var a:Array = [];
			var last:int;
			for (var i:int=0; i<8; i++) {
				
				if (g[i]) {
					value = g[i];
				} else {
					value = 0;
				}
				getField(CMD.K5_AND_OR,i+1).setCellInfo( g[i] );
				a[i] = value;
			}
			colorize(a);
			
			
			
		}
		private function onLinkChange(e:Event):void
		{
			MASTER = true;
			//linksDisabler();
			needClearHistory = true;
			linksMixer((e.target as OptLinkChannelK1M).getStructure());
			links();
			remember( getField(CMD.K5_AND_OR,1) );
			MASTER = false;
		}
		private function onTelChange(e:Event):void
		{
			needClearHistory = true;
		}
		private function onClick():void
		{
			if( optsTime[0].visible ) {
				bExtend.setName( "+ "+loc("g_additional"));
				height = 650;
			} else {
				bExtend.setName( "- "+loc("g_additional"));
				height = 800;
			}
			
			go.visible("ext", !optsTime[0].visible);
		}
		private function updateGprs(o:Object=null):void
		{
			
			if (!LOADING)
				needClearHistory = true;
			
			var len:int = opts.length;
			var b1:Boolean = bitmm.getBit(1,3);
			var b2:Boolean = bitmm.getBit(1,4);
			
			for (var i:int=1; i<len; i++) 
			{
				
				opts[i].setList( b1, b2 ); 
			}
		}
		private function before():void
		{
			RequestAssembler.getInstance().fireEvent( new Request( CMD.HISTORY_DELETE, null, 1 ,[UIHistory.HIS_DELETE] ));
		}
		private function after():void
		{
			if (linksNeedResave) {
				var a:Array = [null];
				for (var i:int=2; i<9; i++) {
					a.push( int(group[i].getCellInfo()) );
				}
				var len:int = opts.length;
				var foundlast:Boolean = false;
				var newgroups:Array = [0];
				for (i=1; i<len; i++) {
					if (opts[i]) {
						if ( opts[i].active ) {
							newgroups[newgroups.length-1] += 1;
							if (a[i] == 1)
								newgroups.push( 0 );
						}
					}
				}
				if (newgroups.length < 8) {
					for (i=newgroups.length; i<8; i++) {
						newgroups.push(0);
					}
				}
				RequestAssembler.getInstance().fireEvent( new Request(CMD.K5_AND_OR, null, 1, newgroups, 0, Request.PARAM_SAVE ));
			}
			linksNeedResave = false;
			
			if (needClearHistory || (MISC.COPY_DEBUG && (CLIENT.DELETE_HISTORY == 0)))
				RequestAssembler.getInstance().fireEvent( new Request( CMD.HISTORY_DELETE, doClear, 1 ,[UIHistory.HIS_DELETE] ));
		}
		private function cmd(value:Object):int
		{	// проверяем были ли изменены группы или каналы связи,если да то надо переформировать группы
			if (value is int ) {
				if (int(value) == CMD.K5_AND_OR) {
					linksNeedResave = true;
					return SavePerformer.CMD_TRIGGER_TRUE;
				}
				if (int(value) == CMD.K9_DIRECTIONS) {
					linksNeedResave = true;
					return SavePerformer.CMD_TRIGGER_FALSE;
				}
			} else
				return SavePerformer.CMD_TRIGGER_CONTINUE;
			return SavePerformer.CMD_TRIGGER_FALSE;
		}
		
		private function createFirewall():Sprite
		{
			_firewall = new Sprite();
			_firewall.graphics.beginFill( 0xFFFFFF, .75 );
			_firewall.graphics.drawRect(0, 0, this.width, this.height );
			
			this.addChild( _firewall );
			
			const label:SimpleTextField = new SimpleTextField( loc("warning_settings_blocked"), 650, 0xBB0000 );
			label.setSimpleFormat( TextFormatAlign.CENTER, 0, 20, true );
			_firewall.addChild( label );
			label.x = 150;
			label.y = 200;
			
			
			return _firewall;
		}
	}
}