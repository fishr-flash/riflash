package components.screens.ui
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextFormatAlign;
	
	import components.abstract.RegExpCollection;
	import components.abstract.functions.loc;
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
	import components.interfaces.IFormString;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.protocol.statics.CLIENT;
	import components.screens.opt.OptLinkChannelRT1;
	import components.static.CMD;
	import components.static.DS;
	import components.static.MISC;
	import components.static.PAGE;
	import components.system.CONST;
	import components.system.Controller;
	import components.system.Library;
	import components.system.SavePerformer;
	import components.system.UTIL;
	
	public class UILinkChannelsRT1 extends UI_BaseComponent
	{
		public static var MASTER:Boolean = false;
		
		private var group:Vector.<FSRadioGroupH>; // Группа объектов радиобуттонов
		private var opts:Vector.<OptLinkChannelRT1>;
		private var oArrows:Object;
		private var linksNeedResave:Boolean = false;	// true, когда были изменены либо каналы либо группы, надо пройтись по списку и выключить/выключить группы
		private var gprs:Vector.<IFormString>;

		private var fsRgroup:FSRadioGroup;

		
		private var _firewall:Sprite;
		
		public function UILinkChannelsRT1()
		{
			super();
			var w:int = 450;
			
			gprs = new Vector.<IFormString>(2);
			
			addui( new FSCheckBox, CMD.K5RT_CH_ONLINE, loc("ui_linkch_lanonline"), null, 1 );
			attuneElement( 437 );
			gprs[0] = addui( new FSCheckBox, CMD.K5RT_CH_ONLINE, loc("ui_linkch_gprs_sim1"), updateGprs, 2 ) as IFormString;
			attuneElement( 437 );
			gprs[1] = addui( new FSCheckBox, CMD.K5RT_CH_ONLINE, loc("ui_linkch_gprs_sim2"), updateGprs, 3 ) as IFormString;
			attuneElement( 437 );
			addui( new FSShadow, CMD.K5RT_CH_ONLINE, "", null, 4 );
			addui( new FSShadow, CMD.K5RT_CH_ONLINE, "", null, 5 );
			
			drawSeparator(w+53+248);
			
			group = new Vector.<FSRadioGroupH>(9);
			oArrows = new Object;
			
			var opt:OptLinkChannelRT1;
			opts = new Vector.<OptLinkChannelRT1>(9);
			
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
				opt = new OptLinkChannelRT1( UTIL.hash_0To1(i) );
				addChild( opt );
				opt.y = (opt.getHeight()+25)*i+ globalY;
				opt.x = PAGE.CONTENT_LEFT_SHIFT + 10;
				opt.addEventListener( GUIEvents.EVOKE_CHANGE, onLinkChange );
				opts[ UTIL.hash_0To1(i) ] = opt;
			}
			
			globalY += 400-19;
			
			drawSeparator(w+53+248);
			
			/**"Команда K5RT_DIR_CHANGE - Тип перехода по направлениям
			 Параметр 1 - тип перехода по направлениям ( 0 - оставаться в одном направлении, 1 - переходить на следующее направление )*/
			
			fsRgroup = new FSRadioGroup( [ {label:loc("ui_linkch_stay_one_dir"), selected:false, id:0 },
				{label:loc("ui_linkch_go_next_dir"), selected:false, id:1 }], 1, 30 );
			fsRgroup.y = globalY;
			fsRgroup.x = globalX;
			fsRgroup.width = 702;
			addChild( fsRgroup );
			addUIElement( fsRgroup, CMD.K5RT_DIR_CHANGE, 1);
			globalY += fsRgroup.getHeight();
			
			/**"Команда K9_IMEI_IDENT - команда для включения IDENT протокола при передаче CSD и SMS (передается IMEI модема)
			 Параметр 1 - значение 0 - протокол отключен, 1 - протокол включен */
			
			addui( new FSCheckBox, CMD.K9_IMEI_IDENT, loc("ui_linkch_send_imei"), null, 1 );
			attuneElement( 702 );
			
			addui( new FSSimple, CMD.PING_SET_TIME, loc("test_ping")+", 20-240)", null, 1, null, "0-9", 3, new RegExp(RegExpCollection.REF_20to240) );
			attuneElement( w - 48 + 525-273, 60 );
			
			/** "Команда K5RT_CH_ONLINE - активация online-каналов передачи
			 Параметр 1 - LAN, 1 - включен, 0 - отключен
			 Параметр 2 - GPRS SIM1, 1 - включен, 0 - отключен
			 Параметр 3 - GPRS SIM2, 1 - включен, 0 - отключен
			 Параметр 4 - резерв
			 Параметр 5 - резерв	*/
			
			height = 685;
			
			starterCMD = [CMD.K5RT_CH_ONLINE, CMD.K9_IMEI_IDENT, CMD.K5RT_DIR_CHANGE, CMD.PING_SET_TIME, CMD.K5RT_DIRECTIONS];
			
			
			starterCMD.push( CMD.CH_COM_LINK_LOCK );
			
		}
		
		override public function open():void
		{
			super.open();
			
			Controller.hook = onSave;
		}
		
		override public function close():void
		{
			Controller.hook = null;	
			if( _firewall && _firewall.parent )
					_firewall.parent.removeChild( _firewall );
		}
		
		override public function put(p:Package):void
		{
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
				case CMD.K5RT_CH_ONLINE:
					pdistribute(p);
					updateGprs();
					break;
				case CMD.K5RT_DIR_CHANGE:
				case CMD.K9_IMEI_IDENT:
				case CMD.PING_SET_TIME:
					pdistribute(p);
					break;
				case CMD.K5RT_DIRECTIONS:
					var len:int = p.length;
					var links:Array = [];
					for (var i:int=0; i<8; i++) {
						opts[i+1].putData(p);
						links.push( p.getParamInt(1,i+1));
					}
					var ltotal:int;
					
					
					for (i=1; i<len; i++) {
						if( links[i] == links[i-1])
							group[i+1].setCellInfo(2);
						else
							group[i+1].setCellInfo(1);
					}
				/*	if (ltotal < 8) {
						len = opts.length;
						for (i=1+ltotal; i<len; i++) {
							if (opts[i])
								opts[i].active = false;
						}
					}*/
					linksDisabler();
					
					loadComplete();
					
					break;
			}
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
		private function updateGprs(t:IFormString=null):void
		{
			var len:int = opts.length;
			for (var i:int=1; i<len; i++) {
				opts[i].setList( gprs[0].getCellInfo() == 1, gprs[1].getCellInfo() == 1 ); 
			}
			if (t)
				remember(t);
		}
		private function onLinkChange(e:Event):void
		{
			MASTER = true;
			//linksDisabler();
			linksMixer((e.target as OptLinkChannelRT1).getStructure());
			links();
			MASTER = false;
		}
		private function links():void
		{
			var g:Array = [1];
			var len:int = group.length;
			var gnum:int = 1, value:int;
			for (var i:int=2; i<len; i++) {
				value = int(group[i].getCellInfo());
				switch(value) {
					case 2:
						g.push(gnum);
						break;
					default:
						g.push(++gnum);
						break;
				}
			}
			
			for (i=0; i<8; i++) {
				if (g[i])
					opts[i+1].group = g[i];
				else
					opts[i+1].group = 0;
			}
		}
		private function linksMixer(n:Number=NaN):void
		{
			if (!isNaN(n)) {
				if ( (opts[n-1] && opts[n-1].active) && opts[n].active )
					return;
			}
			
			var len:int = opts.length;
			var telrecover:String;
			var needremix:Boolean=false;
			var foundgasp:Boolean=false;
			for (var i:int=1; i<len; i++) {
				if (opts[i]) {
					if (telrecover) {
						trace(i + " true \'"+ telrecover +"\'")
					} else {
						trace(i + " false \'"+ telrecover +"\'")
					}
					if (telrecover != null) {
						if (opts[i].getDir() == 0)
							foundgasp = true;	// если найдено поле с 0, возможно это конец направлений
						else if (foundgasp)
							needremix = true;	// если был найден конец направлений и опять валидный канал, значит был разрыв, надо переформировать направления
						opts[i-1].putDirection( opts[i].getDir() );
						opts[i-1].putPhone( opts[i].getTel() );
						opts[i-1].rememberchange();
						if (i+1 == len) {
							opts[i].putDirection( 0 );
							opts[i].putPhone( telrecover );
							opts[i].rememberchange();
						}
					} else if( !opts[i].active ) {
						telrecover = opts[i].getTel();
					}
				}
			}
			if (needremix)
				linksMixer();
		}
		
		private function onSave():void
		{
			if (MISC.COPY_DEBUG && (CLIENT.DELETE_HISTORY == 0)) {	// убираем запрос удаления истории
				loadComplete();
				blockNaviSilent = false;
				SavePerformer.save();
			} else { 
				popup = PopUp.getInstance();
				popup.construct( PopUp.wrapHeader("sys_attention"), PopUp.wrapMessage("his_delete_when_save"), PopUp.BUTTON_OK | PopUp.BUTTON_CANCEL, [onDoSave] );
				popup.open();
			}
		}
		
		private function onDoSave():void
		{
			SavePerformer.save();
			loadStart();
			blockNaviSilent = true;
			RequestAssembler.getInstance().fireEvent( new Request( CMD.HISTORY_DELETE, doClear, 1 ,[UIHistory.HIS_DELETE] ));
			
			
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