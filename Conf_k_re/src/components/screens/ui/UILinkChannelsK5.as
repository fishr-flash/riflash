package components.screens.ui
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.system.System;
	import flash.text.TextFormatAlign;
	
	import components.abstract.RegExpCollection;
	import components.abstract.adapters.DigitalCallAdapter;
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
	import components.screens.opt.OptLinkChannel;
	import components.static.CMD;
	import components.static.DS;
	import components.static.MISC;
	import components.static.PAGE;
	import components.system.CONST;
	import components.system.Controller;
	import components.system.Library;
	import components.system.SavePerformer;
	import components.system.UTIL;
	
	public class UILinkChannelsK5 extends UI_BaseComponent
	{
		public static var MASTER:Boolean = false;
		
		private var fsRgroup:FSRadioGroup;
		private var group:Vector.<FSRadioGroupH>; // Группа объектов радиобуттонов
		private var oArrows:Object;
		private var groups:Array;
		private var opts:Vector.<OptLinkChannel>;
		private var linksNeedResave:Boolean = false;	// true, когда были изменены либо каналы либо группы, надо пройтись по списку и выключить/выключить группы
		private var gprs:Vector.<IFormString>;
		
		private var bitmm:BitMasterMind;
		private var _firewall:Sprite;

		private var _encryptKey:FSSimple;

		private var _copyButton:TextButton;
		
		public function UILinkChannelsK5()
		{
			super();
			
			bitmm = new BitMasterMind;
			
			addui( new FSShadow,CMD.K5_BIT_SWITCHES, "", null, 1 );
			bitmm.addContainer(getLastElement());
			addui( new FSShadow,CMD.K5_BIT_SWITCHES, "", null, 2 );
			bitmm.addContainer(getLastElement());
			addui( new FSShadow,CMD.K5_BIT_SWITCHES, "", null, 3 );
			bitmm.addContainer(getLastElement());
			
			var w:int = 600;
			if( DS.alias == DS.K5
				|| DS.isDevice(DS.A_BRD ) 
				|| DS.isDevice(DS.K53G) )
			{
				addui( new FSCheckBox, 0, loc("ui_linkch_lanonline"), null, 1 );
				attuneElement( w );
				bitmm.addController( getLastElement(), 2, 4 );
			}
			
			
			gprs = new Vector.<IFormString>;
			
			addui( new FSCheckBox, 0, loc("ui_linkch_gprs_sim1"), null, 2 );
			attuneElement( w );
			bitmm.addController( getLastElement(), 3, 1, updateGprs );
			gprs.push(getLastElement());
			
			addui( new FSCheckBox, 0, loc("ui_linkch_gprs_sim2"), null, 3 );
			attuneElement( w );
			bitmm.addController( getLastElement(), 3, 2, updateGprs );
			gprs.push(getLastElement());
			
			addui( new FSSimple, CMD.K5_DIG_TIME, loc("ui_linkch_wait_while_digital_call"), null, 1, null, "0-9", 3, new RegExp(RegExpCollection.REF_10to240) );
			attuneElement( w - 48, 60 );
			getLastElement().setAdapter( new DigitalCallAdapter );
			
			if (DS.release >= 3 || MISC.COPY_DEBUG) { 
				addui( new FSSimple, CMD.CH_COM_GPRS_TIMEOUT_SERVER, loc("ui_linkch_time_gprs_connect"), null, 1, null, "0-9", 3, new RegExp(RegExpCollection.REF_10to120) );
				attuneElement( w - 48, 60 );
				getLastElement().setAdapter(new DoubleAdapter);
			}
			
			if (DS.release >= 6 || MISC.COPY_DEBUG) { 
				addui( new FSSimple, CMD.PING_SET_TIME, loc("test_ping"), null, 1, null, "0-9", 3, new RegExp(RegExpCollection.REF_20to250) );
				attuneElement( w - 48, 60 );
			}
			
			addui( new FSCheckBox, 0, loc("ui_linkch_send_imei"), null, 5 );
			attuneElement( w);
			bitmm.addController( getLastElement(), 1, 5 );
			
			if( DS.alias == DS.K5|| DS.isDevice(DS.K53G) )
			{
				addui( new FSCheckBox, 0, loc("options_slower_dtmf"), null, 6 );
				attuneElement( w);
				bitmm.addController( getLastElement(), 1, 1 );
			}
			
			const wlabel:int = 310;
			const secw:int = 300;
			if( DS.release > 16 )
			{
				addui( new FSCheckBox, CMD.GPRS_ENCRYPTION, loc("encrypt_exchange_of_server"), dlgCheckEncrypt, 1 );
				attuneElement( w);
	
				FLAG_SAVABLE = false;
				const regexp:RegExp = /^\w{32}$/;
				_encryptKey = addui( new FSSimple, 0, loc( "key_encrypt_xtea" ), dlgtEnctyptKey, 1, null, "0-9 A-F", 32, regexp ) as FSSimple;
				attuneElement( wlabel, secw );
				_encryptKey.disabled = true;
				FLAG_SAVABLE = true;
			
				const reg:RegExp = /^\d+$/;
				
				addui( new FSSimple, CMD.GPRS_ENCRYPTION, "", null, 2, null, "0-9 A-F", 3, reg );
				getLastElement().visible = false;
				
				var len:int = OPERATOR.getSchema( CMD.GPRS_ENCRYPTION ).Parameters.length + 1;
				for (var j:int=3; j<len; j++) {
					addui( new FSShadow, CMD.GPRS_ENCRYPTION, "", null, j, null, "0-9 A-F", 3, reg );
				}
			
				
			
				_copyButton = new TextButton();
				_copyButton.setUp( loc("g_copy_to_clip" ), onCopyCriptKey );
				_copyButton.x = 660;
				_copyButton.y = _encryptKey.y;
				
				this.addChild( _copyButton );
				
				drawSeparator(w+53);
			}
			
			group = new Vector.<FSRadioGroupH>(9);
			oArrows = new Object;
			
			var opt:OptLinkChannel;
			opts = new Vector.<OptLinkChannel>(9);
			
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
				opt = new OptLinkChannel( UTIL.hash_0To1(i) );
				addChild( opt );
				opt.y = (opt.getHeight()+25)*i+ globalY;
				opt.x = PAGE.CONTENT_LEFT_SHIFT + 10;
				opt.addEventListener( GUIEvents.EVOKE_CHANGE, onLinkChange );
				opts[ UTIL.hash_0To1(i) ] = opt;
			}
			
			globalY += 400-19;
			
			drawSeparator(w+53);
			
			fsRgroup = new FSRadioGroup( [ {label:loc("ui_linkch_stay_one_dir"), selected:false, id:0x01 },
				{label:loc("ui_linkch_go_next_dir"), selected:false, id:0x00 }], 1, 30 );
			fsRgroup.y = globalY;
			fsRgroup.x = PAGE.CONTENT_LEFT_SHIFT;
			fsRgroup.width = 700;
			addChild( fsRgroup );
			addUIElement( fsRgroup, 0, 4 );
			bitmm.addController( fsRgroup, 3, 4 );
			
			addui( new FSShadow, CMD.K5_AND_OR, "", null, 1 );
			addui( new FSShadow, CMD.K5_AND_OR, "", null, 2 );
			addui( new FSShadow, CMD.K5_AND_OR, "", null, 3 );
			addui( new FSShadow, CMD.K5_AND_OR, "", null, 4 );
			addui( new FSShadow, CMD.K5_AND_OR, "", null, 5 );
			addui( new FSShadow, CMD.K5_AND_OR, "", null, 6 );
			addui( new FSShadow, CMD.K5_AND_OR, "", null, 7 );
			addui( new FSShadow, CMD.K5_AND_OR, "", null, 8 );
			
			if (DS.release >= 3 || MISC.COPY_DEBUG)
				height = 765;
			else
				height = 730;
			
			if (DS.release >= 3 || MISC.COPY_DEBUG)
				starterCMD = [CMD.K5_BIT_SWITCHES, CMD.K5_APHONE, CMD.K5_DIRECTIONS, CMD.K5_AND_OR, CMD.CH_COM_GPRS_TIMEOUT_SERVER, CMD.K5_DIG_TIME];
			else
				starterCMD = [CMD.K5_BIT_SWITCHES, CMD.K5_APHONE, CMD.K5_DIRECTIONS, CMD.K5_AND_OR, CMD.K5_DIG_TIME];
			
			if (DS.release >= 6 || MISC.COPY_DEBUG)
				starterRefine( CMD.PING_SET_TIME, true );
			
			
			if (DS.release > 9 )starterRefine( CMD.CH_COM_LINK_LOCK, true );
			if( DS.release > 16  )
			{
				starterRefine( CMD.GPRS_ENCRYPTION, true );
				
			}
			
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
				case CMD.K5_BIT_SWITCHES:
					refreshCells(p.cmd);
					SavePerformer.trigger( {after:after, cmd:cmd } );
					Controller.hook = onSave;
					
					MASTER = true;
					bitmm.put(p);
					updateGprs();
					break;
				case CMD.K5_DIG_TIME:
					distribute( p.getStructure(), p.cmd );
					loadComplete();
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
				case CMD.K5_DIRECTIONS:
					len = opts.length;
					for (i=0; i<len; i++) {
						if (opts[i]) {
							opts[i].putDirection(p.getStructure(i)[0]);
						}
					}
					
					
					break;
				case CMD.K5_AND_OR:
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
					if (ltotal < 8) {
						len = opts.length;
						for (i=1+ltotal; i<len; i++) {
							if (opts[i])
								opts[i].active = false;
						}
					}
					linksDisabler();
					break;
				case CMD.GPRS_ENCRYPTION:
					pdistribute( p );
					updateEncryptionField();
					break;
				case CMD.CH_COM_GPRS_TIMEOUT_SERVER:
				case CMD.PING_SET_TIME:
					pdistribute( p );
					break;
			}
		}
		
		
		override public function close():void
		{
			super.close();
			Controller.hook = null;
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
					//SavePerformer.save();
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
		private function updateGprs(o:Object=null):void
		{
			var len:int = opts.length;
			for (var i:int=1; i<len; i++) {
				opts[i].setList( gprs[0].getCellInfo() == 1, gprs[1].getCellInfo() == 1 ); 
			}
		}
		private function linksMixer(n:Number=NaN):void
		{
			if (!isNaN(n)) {
				if ( (opts[n-1] && opts[n-1].active) && opts[n].active )
					return;
			}
			
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
			for (var i:int=0; i<8; i++) {
				if (g[i])
					getField(CMD.K5_AND_OR,i+1).setCellInfo( g[i] );
				else
					getField(CMD.K5_AND_OR,i+1).setCellInfo( 0 );
			}
			remember( getField(CMD.K5_AND_OR,1) );
			
		}
		private function onLinkChange(e:Event):void
		{
			MASTER = true;
			//linksDisabler();
			linksMixer((e.target as OptLinkChannel).getStructure());
			links();
			MASTER = false;
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
		}
		private function cmd(value:Object):int
		{	// проверяем были ли изменены группы или каналы связи,если да то надо переформировать группы
			if (value is int ) {
				if (int(value) == CMD.K5_AND_OR) {
					linksNeedResave = true;
					return SavePerformer.CMD_TRIGGER_TRUE;
				}
				if (int(value) == CMD.K5_DIRECTIONS) {
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
		
		private function dlgtEnctyptKey( t:IFormString = null  ):void
		{
			
			if( !_encryptKey.isValid() ||  _encryptKey.disabled )
			{
				
				_copyButton.disabled = true;
				getField(CMD.GPRS_ENCRYPTION, 2 ).setCellInfo( "xx" );
				
			}
			else
			{
				var hexWord:String = _encryptKey.getCellInfo() as String;
				var hex:String = "";
				
				var len:int = OPERATOR.getSchema( CMD.GPRS_ENCRYPTION ).Parameters.length;
				var it:int = 0;
				for (var j:int=1; j<len; j++) {
					it = j * 2;
					hex = hexWord.charAt( it - 2 ) + hexWord.charAt( it - 1 );
					
					getField( CMD.GPRS_ENCRYPTION, j + 1 ).setCellInfo( UTIL.hexToDec( hex ) );
					remember( getField( CMD.GPRS_ENCRYPTION, j + 1 ) );
					
					
					
				}
				
				
				_copyButton.disabled = false;
			}
			
			
			
			
			
			
		}
		
		private function updateEncryptionField():void
		{
			var hexWord:String = "";
			var len:int = OPERATOR.getSchema( CMD.GPRS_ENCRYPTION ).Parameters.length + 1;
			for (var j:int=2; j<len; j++) {
				
				hexWord += Number( getField( CMD.GPRS_ENCRYPTION, j ).getCellInfo() ).toString( 16 ).toLocaleUpperCase();
			}
			
			_encryptKey.setCellInfo( hexWord );
			
			
				
				
		}
		private function onCopyCriptKey():void
		{
			System.setClipboard( _encryptKey.getCellInfo().toString() );
			
		}	
		
		private function dlgCheckEncrypt( t:IFormString = null):void
		{
			
			getField(CMD.GPRS_ENCRYPTION, 2 ).disabled = _encryptKey.disabled = t.getCellInfo() == 0;
			dlgtEnctyptKey( _encryptKey as IFormString );
			remember( t );
		}	
	}
}
import components.interfaces.IDataAdapter;
import components.interfaces.IFormString;

class DoubleAdapter implements IDataAdapter
{
	public function adapt(value:Object):Object
	{
		return int(int(value)/2);
	}
	public function change(value:Object):Object
	{
		return value;
	}
	public function perform(field:IFormString):void	{	}
	public function recover(value:Object):Object
	{
		return int(value)*2;
	}
}