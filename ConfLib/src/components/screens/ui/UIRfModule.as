package components.screens.ui
{
	import flash.events.Event;
	
	import components.abstract.functions.loc;
	import components.abstract.servants.ResizeWatcher;
	import components.basement.UIRadioModulesRoot;
	import components.events.GUIEventDispatcher;
	import components.events.GUIEvents;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.screens.opt.rf_modules.OptModule;
	import components.static.CMD;
	import components.static.RF_FUNCT;
	import components.system.SavePerformer;
	
	public class UIRfModule extends UIRadioModulesRoot
	{
		public function UIRfModule(limit:int)
		{
			label = loc("navi_rf_modules");
			labelParentPadejM = loc("ui_rfmodule_padejm");
			labelParentPadejS = loc("ui_rfmodule_padejs");
			labelParentPadejR = loc("ui_rfmodule_padejr");
			LOCALE_NOT_FOUND = loc("ui_rfmodule_found");
			label_construct = loc("navi_rf_modules")+" ";
			cmd = CMD.RF_CTRL;
			deviceType = RF_FUNCT.TYPE_RFMODULE;
			devicesValid = [ RF_FUNCT.TYPE_RFSIREN, RF_FUNCT.TYPE_RFRELAY, RF_FUNCT.TYPE_RFBOARD, RF_FUNCT.TYPE_RFMODULE ];
			DEVICE_MAX = limit;
			fwidth = 518+26;
			fheight = 590;
			
			opt = new OptModule();
			
			super();
			
			navi.setXOffset( 20 );
			
			addChild( opt );
			opt.visible = false;
			
			starterCMD = cmd;
			
			
			GUIEventDispatcher.getInstance().addEventListener(GUIEvents.ON_RESIZE, changeTemplateSize );
			GUIEventDispatcher.getInstance().addEventListener(GUIEvents.CHANGE_RFMODULE_TEMPLATE, changeTemplateSize );
		}
		
		protected function changeTemplateSize(event:Event):void
		{
			
			ResizeWatcher.doResizeMe(this);
		}
		override protected function openDeviceSuccess(p:Package):void
		{
			
			if ( !p.error ) {
				SavePerformer.closePage();
				
					opt.loading = false;
					oDevices[currentActionDeviceId] = p.getStructure();
					
					var fake:Package = new Package;
					fake.structure = currentActionDeviceId+1;
					fake.data = oDevices[currentActionDeviceId];
					fake.cmd = p.cmd;
					
					opt.putData( fake );
					opt.visible = true;
					tNotify.visible = false;
					forgotten.visible = opt.old;
					
					label_second_current = loc("g_setting")+" "+ ( opt as OptModule ).labelParentPadejS+" "+ (currentActionDeviceId+1);
					changeSecondLabel( loc("navi_tuning")+" "+ ( opt as OptModule ).labelParentPadejS+" "+ (currentActionDeviceId+1) + label_jumper );
				/*}*/
				
			}
			
		}
		
		
		
		override public function close():void
		{
			( opt as OptModule ).close();	
			super.close();
			
		}
		
		private function response(p:Package):void
		{
			if ( !p.error ) {
				RequestAssembler.getInstance().fireEvent( new Request( cmd, openDeviceSuccess, currentActionDeviceId+1 ));
			}
		}
	}
}