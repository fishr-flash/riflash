package components.screens.ui
{
	import components.abstract.RegExpCollection;
	import components.abstract.functions.loc;
	import components.basement.UI_BaseComponent;
	import components.gui.fields.FSCheckBox;
	import components.gui.fields.FSComboBox;
	import components.gui.fields.FSShadow;
	import components.gui.fields.FormString;
	import components.gui.visual.Separator;
	import components.interfaces.IFocusable;
	import components.interfaces.IFormString;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.screens.opt.OptSysEvents;
	import components.static.CMD;
	import components.system.SavePerformer;

	public class UISysEvents extends UI_BaseComponent
	{
		private var autoTest:Vector.<OptSysEvents>;
		
		public function UISysEvents()
		{
			super();
			structureID = 1;
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
			
			createUIElement( new FSCheckBox, CMD.SYS_NOTIF, loc("ui_sysev_gen_acu_fail"), null, 5 );
			attuneElement( 497 );
			(getLastElement() as IFocusable).focusgroup = 10;
			
			createUIElement( new FSCheckBox, CMD.SYS_NOTIF, loc("ui_sysev_gen_acu_low"), null, 6 );
			attuneElement( 497 );
			(getLastElement() as IFocusable).focusgroup = 10;
			
			globalY += 10;
			var time_list220:Array = [ {label:loc("g_no"),data:"00:00"},
				{label:"01:00", data:"01:00"},{label:"05:00", data:"05:00"},
				{label:"15:00", data:"15:00"},{label:"30:00", data:"30:00"} ];
			
			createUIElement( new FSComboBox, CMD.SYS_NOTIF, loc("ui_sysev_gen_no_220_time"), onAction, 3,
				time_list220, "0-9:",5, new RegExp( RegExpCollection.REF_TIME_0005to3000));
			attuneElement( 440,70,FSComboBox.F_COMBOBOX_TIME );
			(getLastElement() as IFocusable).focusgroup = 10;
			
			var sep3:Separator = new Separator(550);;
			addChild( sep3 );
			sep3.y = globalY+10;
			sep3.x = 10;
			globalY += 30;

			createUIElement( new FSCheckBox, CMD.SYS_NOTIF, loc("ui_sysev_gen_ev_restart"), null, 1 );
			attuneElement( 497 );
			(getLastElement() as IFocusable).focusgroup = 10;

			createUIElement( new FSShadow, CMD.SYS_NOTIF, loc("ui_sysev_gen_no_220"), null, 2 );
			
			autoTest = new Vector.<OptSysEvents>(4);
			
			var opt:OptSysEvents;
			for(var i:int=0; i<4; ++i) {
				if(i<3) {
					opt = new OptSysEvents(loc("ui_sysev_autotest")+(i+1),100,(i+1));
					addChild( opt );
					opt.x = 370;
					opt.y = 10+30*i;
				} else {
					opt = new OptSysEvents(loc("ui_sysev_gen_ad_autotest"),440,4, true);
					addChild( opt );
					opt.x = globalX;
					opt.y = 125;
				}
				autoTest[i] = opt;
			}
			width = 530;
		}
		override public function open():void
		{
			super.open();
			RequestAssembler.getInstance().fireEvent( new Request( CMD.AUTOTEST, put ));
			RequestAssembler.getInstance().fireEvent( new Request( CMD.SYS_NOTIF, put ));
		}
		override public function put(p:Package):void
		{
			switch( p.cmd ) {
				case CMD.AUTOTEST:
					var len:int = autoTest.length;
					for(var i:int=0; i<len; ++i) {
						autoTest[i].putRaw( p.getStructure(i+1) );
					}
					break;
				case CMD.SYS_NOTIF:
					var cmd:int = CMD.SYS_NOTIF;
					
					getField( cmd,1).setCellInfo( String( p.getStructure()[0]) );
					getField( cmd,2).setCellInfo( String( p.getStructure()[1]) );
					getField( cmd,3).setCellInfo( mergeIntoTime( p.getStructure()[2], p.getStructure()[3]) );
					getField( cmd,5).setCellInfo( String( p.getStructure()[4]) );
					getField( cmd,6).setCellInfo( String( p.getStructure()[5]) );
					
					loadComplete();
					break;
			}
		}
		private function onAction(t:IFormString):void
		{
			var time:Array = t.getCellInfo() as Array;
			if( int(time[0]) + int(time[1]) > 0 ) {
				getField(t.cmd,2).setCellInfo(1);
			} else
				getField(t.cmd,2).setCellInfo(0);
			SavePerformer.remember(structureID, t );
		}
	}
}