package components.screens.ui
{
	import components.abstract.LOC;
	import components.abstract.functions.loc;
	import components.basement.UI_BaseComponent;
	import components.gui.MFlexList;
	import components.gui.fields.FSRadioGroup;
	import components.gui.fields.FormString;
	import components.gui.triggers.TextButton;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.protocol.statics.OPERATOR;
	import components.screens.opt.OptApnBaseLine;
	import components.screens.opt.OptSimApn;
	import components.static.CMD;
	import components.static.DS;
	import components.system.SavePerformer;
	
	public class UISimApn extends UI_BaseComponent
	{
		private var simcards:Vector.<OptSimApn>;
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
		
		/** команда CMD.GPRS_APN_BASE не сохраняется посредством SavePerformer, а только после триггера after
		 * потому что необходимо проверять валидность всех полей команды и всех структур	*/ 
		
		public function UISimApn()
		{
			super();
			simcards = new Vector.<OptSimApn>;
			
			
			//MODEM_NETWORK_CTRL

			if (DS.isVoyager() || DS.isfam( DS.K15 ) )
				starterCMD = [CMD.NO_GPRS_ROAMING, CMD.GPRS_SIM, CMD.GPRS_APN_BASE, CMD.GPRS_APN_AUTO, CMD.GPRS_APN_SELECT];
			else
				starterCMD = [CMD.GPRS_SIM, CMD.GPRS_APN_BASE, CMD.GPRS_APN_AUTO, CMD.GPRS_APN_SELECT];
			
			if( DS.isDevice( DS.K16_3G ) )
			{
					(starterCMD as Array).push( CMD.MODEM_NETWORK_CTRL );
			}
			
			this.width = 480;
		}
		override public function put(p:Package):void
		{
			
			var len:int;
			var i:int;
			switch(p.cmd) {
				case CMD.GPRS_SIM:
					len = p.length;
					if (simcards.length < p.length)
						simcards.length = p.length;
					
					var roaming:Array = OPERATOR.dataModel.getData( CMD.NO_GPRS_ROAMING );
					
					for( i=0; i<len; ++i ) {
						if (simcards[i] == null) {
							//if (i>0)
							simcards[i] = new OptSimApn(i+1,roaming is Array, len==1);
							addChild( simcards[i] );
							simcards[i].x = globalX;
							simcards[i].y = globalY;
							globalY += simcards[i].height;
							drawSeparator(461+80);
						}
						simcards[i].putData( p.detach(i+1));
						if (roaming)
							simcards[i].putRoaming( roaming[i][0] );
						
						
					}
					
					
					if( DS.isDevice( DS.K16_3G ) && getField( CMD.MODEM_NETWORK_CTRL, 1 ) == null  ){
						addSelectorModemMod();
					}
				//	this.height = simcards[len-1].y + simcards[len-1].height + 20;
					break;
				case CMD.MODEM_NETWORK_CTRL:
					
					pdistribute( p );
					break;
				case CMD.GPRS_APN_BASE:
					
					if ( !tExpand ) {
						
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
						flist.width = 885;
						flist.height = 150;
						flist.y = globalY;
						flist.x = globalX;
						flist.visible = false;
					}
					
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
					
					flist.height = flist.getActualHeight();
					if( flist.visible )
						height = flist.y + flist.height + 20;
					else
						height = flist.y;
					SavePerformer.trigger({cmd:cmd, after:after});
					break;
				case CMD.GPRS_APN_AUTO:
				case CMD.GPRS_APN_SELECT:
					len = p.length;
					for( i=0; i<len; ++i ) {
						simcards[i].putData( p.detach(i+1));
					}
					loadComplete();
					break;
			}
		}
		
		private function addSelectorModemMod():void
		{
			FLAG_VERTICAL_PLACEMENT = true;
			
			
			//globalX = 30;
			
			
			
			
			
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
			
			
			fsRGroup.x = globalX;
			fsRGroup.y = globalY;
			fsRGroup.width = 400;
			this.addChild( fsRGroup );
			globalY += fsRGroup.height;
			
			addUIElement( fsRGroup, CMD.MODEM_NETWORK_CTRL, 1);
			
			drawSeparator( 461+80 )
			
			
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
			tApnDefaults.visible = !tApnDefaults.visible;
			if (LOC.language != LOC.RU)
				tApnDefaults.visible = false;
			if( flist.visible )
				height = flist.y + flist.height + 20;
			else
				height = flist.y;
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
	}
}