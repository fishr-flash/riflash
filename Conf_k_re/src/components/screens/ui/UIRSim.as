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
	import components.gui.fields.FSRadioGroup;
	import components.gui.fields.FormString;
	import components.gui.triggers.TextButton;
	import components.gui.visual.HLine;
	import components.interfaces.IResizeDependant;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.protocol.statics.OPERATOR;
	import components.screens.opt.OptApnBaseLine;
	import components.screens.opt.OptRSim;
	import components.screens.page.GprsServer;
	import components.static.CMD;
	import components.static.DS;
	import components.system.CONST;
	import components.system.SavePerformer;
	
	public class UIRSim extends UI_BaseComponent implements IResizeDependant
	{
		private var simcards:Vector.<OptRSim>;
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
		private var _firewall:Sprite;
		
		public function UIRSim()
		{
			super();
			
			var anchor:int = globalX;
			
			uiserver = new GprsServer;
			addChild( uiserver );
			uiserver.x = globalX + 390 + 40;
			uiserver.y = globalY;
			
			simcards = new Vector.<OptRSim>;
			
			var h:HLine = new HLine(370+200-113);
			h.rotate();
			addChild( h );
			h.x = globalX + 410;
			
			width = 840;
			height = 626;
			
		
			starterCMD = [CMD.K5_G_SRV_IP, CMD.K5_G_SRV_PORT, CMD.K5_G_SRV_PASS,
				CMD.K5_G_PHONE, CMD.K5_G_APN, CMD.K5_G_APN_LOG, CMD.K5_G_APN_PASS, CMD.K5_G_TRY_TIME,
				CMD.GPRS_APN_BASE, CMD.GPRS_APN_AUTO, CMD.GPRS_APN_SELECT];
			
			if( ( DS.alias != DS.K5 && !DS.isDevice(DS.K53G) )  || DS.release > 9 ) 
								starterCMD.push( CMD.CH_COM_LINK_LOCK );
		
			
			if (DS.isfam( DS.K5 ))
			{
				(starterCMD as Array).splice( 0,0, CMD.K5_BIT_SWITCHES );
				starterCMD.push( CMD.K5RT_GPRS_ADD );
			}
			else if (DS.isfam(DS.K9))
				(starterCMD as Array).splice( 0,0, CMD.K9_BIT_SWITCHES );
			
			if(  DS.isDevice( DS.K53G ) )
				(starterCMD as Array).splice( (starterCMD as Array).indexOf( CMD.GPRS_APN_BASE ) + 1,0, CMD.MODEM_NETWORK_CTRL );
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
				case CMD.CH_COM_LINK_LOCK:
					
					if( CONST.DEBUG )
						break;
					var obj:Object;
					
					
					if( p.data[ 0 ] == 0x00 )
						createFirewall();
					else if( _firewall && _firewall.parent )
						_firewall.parent.removeChild( _firewall );
					
					
					break;
				case CMD.K5_G_PHONE:
					if (simcards.length < p.length)
						simcards.length = p.length;
					
					var coory:Array; 
					
					for( i=0; i<len; ++i ) {
						if (simcards[i] == null) {
							if (i>0) {
								drawSeparator(421);
							}
							simcards[i] = new OptRSim(i+1);
							if (!coory)
								coory = [ globalY + simcards[i].height + 30, globalY  ];
							addChild( simcards[i] );
							simcards[i].x = globalX;
							simcards[i].y = coory[i];//globalY;
							globalY += simcards[i].height;
						}
						simcards[i].putData( p.detach(getStr(i+1)));
						
						function getStr(num:int):int
						{
							if(num==1)
								return 1;
							return 2;
						}
						//globalY += simcards[i].height;
					}
			//		this.height = simcards[len-1].y + simcards[len-1].height + 20;
					break;
				case CMD.K5_G_APN_PASS:
				case CMD.K5_G_APN:
				case CMD.K5_G_APN_LOG:
					for( i=0; i<len; ++i ) {
						simcards[i].putData( p.detach(i+1))
					}
					break;
				case CMD.K5RT_GPRS_ADD:
					for( i=0; i<len; ++i ) {
						simcards[i].putData( p.detach(i+1))
					}
					uiserver.put(p);
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
						if(  DS.isDevice( DS.K53G ) )addSelectorModemMod();
						
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
						onApnDefaults();//flist.put( p, true, true );
					SavePerformer.trigger({cmd:cmd, after:after});
					break;
				case CMD.MODEM_NETWORK_CTRL:
					pdistribute( p );
					break
				case CMD.GPRS_APN_SELECT:
					autoDistrtibute();
					
					loadComplete();
				case CMD.GPRS_APN_AUTO:
					len = p.length;
					for( i=0; i<len; ++i ) {
						simcards[i].putData( p.detach(i+1));
					}
					/*
					simcards[0].putData( p.detach(2));
					simcards[1].putData( p.detach(1));*/
					break;
			}
		}
		
		private function addSelectorModemMod():void
		{
			FLAG_VERTICAL_PLACEMENT = true;
			
			/*globalY += 10;
			globalX = 10;*/
			
			
			drawSeparator( this.width ).x = globalX;
			
			
			addui( new FormString, 0, loc( "mode_work_modem" ), null, 1 ); 
			attuneElement( NaN, NaN, FormString.F_TEXT_BOLD );
			
			globalY += 10;
			
			
			const arr:Array = 
				[
					{ label:loc( "Auto" ), selected:true, id:0 },
					{ label:loc( "GSM 2G" ), selected:false, id:1 },
					{ label:loc( "WCDMA 3G" ), selected: false, id:2 }
				]
			
			const fsRGroup:FSRadioGroup = new FSRadioGroup( arr, 1, 24 );
			
			
			fsRGroup.x = 10;
			fsRGroup.y = globalY;
			fsRGroup.width = 400;
			this.addChild( fsRGroup );
			globalY += fsRGroup.height;
			
			addUIElement( fsRGroup, CMD.MODEM_NETWORK_CTRL, 1);
			
			
			
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
				if (apnauto[i][0] == 1) {
					simnum = getSim(i);
					if (apnselect[i][0] == 0) {
						simcards[simnum].putRawData( [loc("ui_gprs_operator_not_defined")," ","",""] );
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
		public function localResize(w:int, h:int, real:Boolean=false):void
		{
			if (h - flist.y - 20 > 69)
				flist.height = h - flist.y - 20;
			else
				flist.height = 69;
			
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