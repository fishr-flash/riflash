package components.screens.ui
{
	import flash.events.Event;
	
	import components.abstract.functions.loc;
	import components.basement.UI_BaseComponent;
	import components.gui.fields.FSCheckBox;
	import components.gui.fields.FSShadow;
	import components.gui.fields.FormString;
	import components.gui.visual.Separator;
	import components.interfaces.IFormString;
	import components.protocol.Package;
	import components.protocol.statics.OPERATOR;
	import components.screens.opt.OptSysEvents;
	import components.static.CMD;
	import components.system.SavePerformer;
	
	public class UISysEvents extends UI_BaseComponent
	{
		private var autoTest:Vector.<OptSysEvents>;
		
		public function UISysEvents()
		{
			super();
			
			globalY = 40;
			//	globalX = 10;
			FLAG_SAVABLE = false;
			createUIElement( new FormString, 0, loc("ui_sysev_gen_autotest"), null, 1);
			attuneElement(400,NaN, FormString.F_MULTYLINE);
			globalY += 30;
			
			var sep1:Separator = new Separator(550);;
			addChild( sep1 );
			sep1.y = globalY;
			sep1.x = 10;
			globalY += 50;
			
			attuneElement(400,NaN,FormString.F_MULTYLINE);
			
			globalY += 10;
			var sep2:Separator = new Separator(550);
			addChild( sep2 );
			sep2.y = globalY;
			sep2.x = 10;
			globalY += 20;
			FLAG_SAVABLE = true;
			
			autoTest = new Vector.<OptSysEvents>(4);
			
			var opt:OptSysEvents;
			for(var i:int=0; i<4; ++i) {
				if(i<3) {
					opt = new OptSysEvents(loc("k5_sysev_at")+" "+(i+1),100,(i+1));
					addChild( opt );
					opt.x = 370;
					opt.y = 10+30*i;
					opt.addEventListener( Event.CHANGE, onControlBlock );
				} else {
					opt = new OptSysEvents(loc("ui_sysev_gen_ad_autotest_n"),440,4, true);
					addChild( opt );
					opt.x = globalX;
					opt.y = 125;
				}
				autoTest[i] = opt;
			}
			
			addui( new FSCheckBox, 1, loc("ui_sysev_gen_acu_low"), onPower, 1 );
			attuneElement( 497 );
			addui( new FSCheckBox, CMD.OP_r_HISTORY_EVENT_RESTART, loc("ui_sysev_gen_ev_restart"), null, 1 );
			attuneElement( 497 );
			
			addui( new FSShadow, CMD.OP_PO_POWER, "", null, 1 );
			addui( new FSShadow, CMD.OP_AN_AUTOTEST_COUNT, "", null, 1 );
			
			starterCMD = [CMD.OP_AH_AUTOTEST_HOURS, CMD.OP_AM_AUTOTEST_MINUTES, CMD.OP_AN_AUTOTEST_COUNT,
				CMD.OP_AA_ADDITIONAL_AUTOTEST, CMD.OP_PO_POWER, CMD.OP_r_HISTORY_EVENT_RESTART];
			
			width = 580;
		}
		override public function put(p:Package):void
		{
			var i:int;
			switch(p.cmd) {
				case CMD.OP_AM_AUTOTEST_MINUTES:
					var a1:Object = OPERATOR.dataModel.getData( CMD.OP_AH_AUTOTEST_HOURS );
					var h:String = OPERATOR.dataModel.getData( CMD.OP_AH_AUTOTEST_HOURS )[0][0];
					var m:String = OPERATOR.dataModel.getData( CMD.OP_AM_AUTOTEST_MINUTES )[0][0];
					var hours:Array = h.split(" ");
					var minutes:Array = m.split(" ");
					for (i=0; i<3; i++) {
						autoTest[i].putRaw( [hours[i], minutes[i]] );
					}
					break;
				case CMD.OP_AN_AUTOTEST_COUNT:
					var count:int = int(p.getStructure()[0]);
					distribute( p.getStructure(), p.cmd );
					for (i=0; i<3; i++) {
						if (count == 0)
							autoTest[i].none();
						else if (count < 0)
							autoTest[i].disable = true;
						count--;
					}
					break;
				case CMD.OP_AA_ADDITIONAL_AUTOTEST:
					autoTest[3].putRaw( p.getStructure() );
					break;
				case CMD.OP_PO_POWER:
					var value:String = String(p.getStructure()[0]);
					getField(1,1).setCellInfo( value == "0011" ? 1: 0);
					break;
				case CMD.OP_r_HISTORY_EVENT_RESTART:
					distribute( p.getStructure(), p.cmd );
					SavePerformer.trigger({cmd:cmd});
					loadComplete();
					break;
			}
		}
		private function cmd(value:Object):int
		{
			if (value is int ) {
				if (int(value) == CMD.OP_AA_ADDITIONAL_AUTOTEST)
					return SavePerformer.CMD_TRIGGER_TRUE;
			} else {
				var info:String = value.array[0];
				if (info.length < 2) {
					info = "0" + info;
					value.array[0] = info;
				}
			}
			return SavePerformer.CMD_TRIGGER_FALSE;
		}
		private function onControlBlock(e:Event):void
		{
			var disable:Boolean;
			var total:int;
			var i:int;
			for (i=0; i<3; i++) {
				if (disable) {
					autoTest[i].disable = true;
				} else {
					autoTest[i].disable = false;
					if( !autoTest[i].active )
						disable = true;
				}
			}
			for (i=0; i<3; i++) {
				if ( autoTest[i].active )
					total++;
			}
			
			var f:IFormString = getField( CMD.OP_AN_AUTOTEST_COUNT, 1 );
			f.setCellInfo(total);
			remember( f );
		}
		private function onPower(t:IFormString):void
		{
			var r:int = int(getField(1,1).getCellInfo());
			getField( CMD.OP_PO_POWER, 1 ).setCellInfo( r == 1 ? "0010":"0000" );
			remember( getField( CMD.OP_PO_POWER, 1 ) );
		}
	}
}