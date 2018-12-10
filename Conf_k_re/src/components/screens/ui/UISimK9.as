package components.screens.ui
{
	import flash.display.Sprite;
	import flash.text.TextFormatAlign;
	
	import components.abstract.LOC;
	import components.abstract.functions.loc;
	import components.abstract.servants.ResizeWatcher;
	import components.basement.UI_BaseComponent;
	import components.gui.MFlexList;
	import components.gui.SimpleTextField;
	import components.gui.fields.FSCheckBox;
	import components.gui.triggers.TextButton;
	import components.gui.visual.HLine;
	import components.interfaces.IFormString;
	import components.interfaces.IResizeDependant;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.protocol.statics.OPERATOR;
	import components.screens.opt.OptApnBaseLine;
	import components.screens.opt.OptRSimK9;
	import components.screens.page.GprsServer;
	import components.static.CMD;
	import components.system.CONST;
	import components.system.SavePerformer;
	
	public class UISimK9 extends UI_BaseComponent implements IResizeDependant
	{
		private var simcards:Vector.<OptRSimK9>;
		private var uiserver:GprsServer;
		
		private var flist:MFlexList;
		private var tExpand:TextButton;
		private var tApnDefaults:TextButton;
		private var header:OptApnBaseLine;
		private var saveApnData:Boolean;
		private const defaultApn:Array = [
			["25001","MTS","internet.mts.ru","mts","mts"],
			["25002","Megafon","internet","",""],
			["25099","Beeline","internet.beeline.ru","beeline","beeline"],
			["25020","TELE2","internet.tele2.ru","tele2","tele2"]
		];

		private var chkBoxs:Vector.<FSCheckBox>;
		private var _firewall:Sprite;
		
		
		public function UISimK9()
		{
			super();
			
			var anchor:int = globalX;
			
			uiserver = new GprsServer;
			addChild( uiserver );
			uiserver.x = globalX + 390 + 40;
			uiserver.y = globalY;
			
			simcards = new Vector.<OptRSimK9>;
			
			
			
			
			var h:HLine = new HLine(370+200-113);
			h.rotate();
			addChild( h );
			h.x = globalX + 410;
			
			chkBoxs = new Vector.<FSCheckBox>( 2 );
			
			const yy:int = globalY;
			
			/// Чекбоксы переставлены местами, т.к. в приборе перепутана запись в настройки симок
			chkBoxs[ 0 ] = addui( new FSCheckBox, CMD.GPRS_APN_AUTO, loc("ui_gprs_autoset_apn_setting"), onApn, 1 ) as FSCheckBox;
			attuneElement( 408-40 );
			
			chkBoxs[ 1 ] = addui( new FSCheckBox, CMD.GPRS_APN_AUTO, loc("ui_gprs_autoset_apn_setting"), onApn, 1 ) as FSCheckBox;
			attuneElement( 408-40 );
			
			
			chkBoxs[ 0 ].y = 44;
			chkBoxs[ 1 ].y = 272;
			
			globalY = yy;
			
			
			width = 840;
			height = 626;
			
			starterCMD = [CMD.K9_BIT_SWITCHES, CMD.K5_G_SRV_IP, CMD.K5_G_SRV_PORT, CMD.K5_G_SRV_PASS,
				CMD.K5_G_PHONE, CMD.K5_G_APN, CMD.K5_G_APN_LOG, CMD.K5_G_APN_PASS, CMD.K5_G_TRY_TIME,
				CMD.GPRS_APN_BASE, CMD.GPRS_APN_AUTO, CMD.GPRS_APN_SELECT ];
			
			starterCMD.push( CMD.CH_COM_LINK_LOCK );
			
		}
		
		
		override public function close():void
		{
			super.close();
			ResizeWatcher.removeDependent(this);
		}
		override public function put(p:Package):void
		{
			var len:int;
			var i:int;
			len = p.length;
			
			switch(p.cmd) {
				case CMD.K5_G_PHONE:
					if (simcards.length < p.length)
						simcards.length = p.length;
					
					for( i=0; i<len; ++i ) {
						if (simcards[i] == null) {
							if (i>0) {
								drawSeparator(421);
							}
							/// Последний парам, отвечает за смену симок между собой
							simcards[i] = new OptRSimK9(i?2:1,false, true);
							addChild( simcards[i] );
							simcards[i].x = globalX;
							simcards[i].y = globalY;
							globalY += simcards[i].height;
						}
						simcards[i].putData( p.detach(i+1));
						
						
					}
					
					/// Меняем позиции расположения симок в соотв. с перепутаными симками в приборе
					
					if( simcards[ 1 ].y > simcards[ 0 ].y )
					{
						const yy:int = simcards[ 0 ].y;
						simcards[ 0 ].y = simcards[ 1 ].y;
						simcards[ 1 ].y = yy;
						
						
					}
					
				break;
				
				case CMD.CH_COM_LINK_LOCK:
					
					if( CONST.DEBUG )
						break;
					var obj:Object;
					
					
					if( p.data[ 0 ] == 0x00 )
						createFirewall();
					else if( _firewall && _firewall.parent )
						_firewall.parent.removeChild( _firewall );
					
					
					break;
				
				
				case CMD.K5_G_APN_PASS:
				case CMD.K5_G_APN:
				case CMD.K5_G_APN_LOG:
					for( i=0; i<len; ++i ) {
						simcards[i].putData( p.detach(i+1))
					}
					break;
				case CMD.K5_BIT_SWITCHES:
				case CMD.K9_BIT_SWITCHES:
				case CMD.K5_G_SRV_IP:
				case CMD.K5_G_SRV_PORT:
				case CMD.K5_G_SRV_PASS:
				case CMD.K5_G_TRY_TIME:
					uiserver.put(p);
					break;
				case CMD.GPRS_APN_BASE:
					if ( !tExpand ) {
						
						globalY += 20;
						drawSeparator(500+291+20);
						
						tExpand = new TextButton;
						addChild( tExpand );
						tExpand.x = globalX;
						tExpand.y = globalY;
						tExpand.setUp( loc("g_additional"), onExpand );
						
						tApnDefaults = new TextButton;
						addChild( tApnDefaults );
						tApnDefaults.x = globalX + 200;
						tApnDefaults.y = globalY;
						tApnDefaults.setUp( loc("g_revert_defaults"), onApnDefaults );
						tApnDefaults.visible = false;
						
						globalY += 30;
						
						header = new OptApnBaseLine(0);
						addChild( header );
						header.x = globalX;
						header.y = globalY;
						globalY += header.height;
						header.visible = false;
						
						flist = new MFlexList(OptApnBaseLine);
						addChild( flist );
						flist.width = 865;
						flist.height = 150;
						flist.y = globalY;
						flist.x = globalX;
						flist.visible = false;
					}
					ResizeWatcher.addDependent(this);
					
					var valid:Boolean = true;
					var wasGap:Boolean = false;
					var t:int;
					len = p.length;
					for (i=0; i<len; i++) {
						t = p.getStructure(i+1)[0];
						if ( t == 0 && i == 0 ) {
							valid = false; 
							break;
						}
						if ( t == 0 && i > 0 )
							wasGap = true;
						if ( t > 0 && wasGap ) {
							valid = false;
							break; 
						}
					}
					if (valid)
						flist.put( p );
					else
						onApnDefaults();
					SavePerformer.trigger({ cmd:cmd, after:after});
					
					
					break;
				case CMD.GPRS_APN_SELECT:
					autoDistrtibute();
					loadComplete();
					
					break;
				case CMD.GPRS_APN_AUTO:
					len = p.length;
					
					const pDetach1:Package = p.detach( 2 );
					
					simcards[ 0 ].putData( pDetach1 );
					chkBoxs[ 1 ].setCellInfo( pDetach1.data[ 1 ][ 0 ]);
					
					const pDetach2:Package = p.detach( 1 );
					simcards[ 1 ].putData( pDetach2 );
					chkBoxs[ 0 ].setCellInfo( pDetach2.data[ 0 ][ 0 ]);
					
					
					break;
			}
			
			
		}
		
		
		
		private function autoDistrtibute():void
		{
			var apnbase:Array = OPERATOR.getData(CMD.GPRS_APN_BASE);
			var apnselect:Array = OPERATOR.getData(CMD.GPRS_APN_SELECT);
			var apnauto:Array = OPERATOR.getData(CMD.GPRS_APN_AUTO);
			var index:int;
			var len:int = simcards.length;
			var simnum:int;
			for (var i:int=0; i<len; i++) {
				/// из за перепутанных симок 
				if (apnauto[i][0] == 1) {
					simnum = getSim(i?0:1);
					if (apnselect[i][0] == 0) {
						///...
					} else if (apnselect[i][0] == 0xff) {
						simcards[simnum].putRawData( [loc("Нет Симкарты")," ","",""] );
					} else {
						index = apnselect[i][0] - 1;
						simcards[simnum].putRawData( [apnbase[index][1],apnbase[index][2],apnbase[index][3],apnbase[index][4]] );
					}
				}
			}
			function getSim(num:int):int
			{
				if(num==1)
					return 1;
				return 0;
			}
		}
		private function onApnDefaults():void
		{
			
			var cmdLength:int = OPERATOR.dataModel.getData(CMD.GPRS_APN_BASE).length;
			var p:Package = new Package;
			p.cmd = CMD.GPRS_APN_BASE;
			
			var a:Array = [].concat(defaultApn);
			var len:int = flist.length;
			for (var i:int=a.length; i<cmdLength; i++) {
				a.push(["","","","",""])
			}
			p.data = a;
			flist.put( p,true,true );
		}
		private function onExpand():void
		{
			flist.visible = !flist.visible;
			header.visible = !header.visible;
			
			if (LOC.language == LOC.RU)
				tApnDefaults.visible = !tApnDefaults.visible;
			else
				tApnDefaults.visible = false;
		}
		private function cmd(value:Object):int
		{
			if (value is int ) {
				if (int(value) == CMD.GPRS_APN_BASE)
					return SavePerformer.CMD_TRIGGER_TRUE;
			} else {
				saveApnData = true;
					return SavePerformer.CMD_TRIGGER_CONTINUE;
			}
			return SavePerformer.CMD_TRIGGER_FALSE;
		}
		private function after():void
		{
			if (saveApnData) {
				var a:Array = flist.extract();
				var len:int = flist.length;
				for (var i:int=0; i<len; i++) {
					if (a[i]) {
						if ( int(a[i][0]) == 0 ) {
							a.splice(i,1);
							i--;
						}
					}
				}
				if (a.length == 0) {
					onApnDefaults();
					a = flist.extract();
					len = a.length;
				} else {
					len = OPERATOR.dataModel.getData(CMD.GPRS_APN_BASE).length;
					for (i=a.length; i<len; i++) {
						a.push(["","","","",""])
					}
				}
				for (i=0; i<len; i++) {
					RequestAssembler.getInstance().fireEvent( new Request(CMD.GPRS_APN_BASE, null, i+1, a[i] ));
				}
				
				var p:Package = new Package;
				p.cmd = CMD.GPRS_APN_BASE;
				p.data = a;
				flist.put(p);
			}
			saveApnData = false;
		}
		
		private function onApn( t:IFormString ):void
		{
			const first:int = chkBoxs.indexOf( t )?0:1; 
			const last:int = first?0:1; 
			
			simcards[ first ].onApn( t );
			simcards[ last ].changeStateChkBox( t.getCellInfo() );
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
		public function localResize(w:int, h:int, real:Boolean=false):void
		{
			if (h - flist.y - 20 > 69)
				flist.height = h - flist.y - 20;
			else
				flist.height = 69;
			
		}
	}
}