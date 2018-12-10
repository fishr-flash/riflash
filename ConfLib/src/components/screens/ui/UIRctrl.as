package components.screens.ui
{
	import components.abstract.functions.loc;
	import components.abstract.sysservants.PartitionServant;
	import components.basement.UIRadioDeviceRoot;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.screens.opt.OptRctrl;
	import components.static.CMD;
	import components.static.RF_FUNCT;
	import components.system.SavePerformer;
	
	public class UIRctrl extends UIRadioDeviceRoot
	{
		public function UIRctrl()
		{
			label = loc("ui_trinket");
			labelParentPadejM = loc("ui_trinket_padejm")
			labelParentPadejS = loc("ui_trinket_padejs")
			labelParentPadejR = loc("ui_trinket_padejr");
			LOCALE_NOT_FOUND = loc("ui_trinket_found");
			label_construct = loc("ui_trinket")+" ";
			cmd = CMD.RF_RCTRL;
			deviceType = RF_FUNCT.TYPE_RADIOBRELOK;
			DEVICE_MAX = 32;
			
			fwidth = 518;;
			fheight = 192;
			
			opt = new OptRctrl;
			
			super();
			
			addChild( opt );
			opt.visible = false;
			
			starterCMD = cmd;
		}
		private function response(p:Package):void
		{
			if ( !p.error ) {
				RequestAssembler.getInstance().fireEvent( new Request( CMD.RF_RCTRL, openDeviceSuccess, currentActionDeviceId+1 ));
			}
		}
		override protected function openDeviceSuccess(p:Package):void
		{
			if ( !p.error ) {
				SavePerformer.closePage();
				if (NEED_DEFAULTS) {
					NEED_DEFAULTS = false;
					
					RequestAssembler.getInstance().fireEvent( new Request( CMD.RF_RCTRL, response, currentActionDeviceId+1,
						[1, PartitionServant.getAllPartitionBitmask(), 0x4023, 0x4021, 0 ] ));
					//label_second_current = label_second_construct+ (currentActionDeviceId+1);
				} else {
					oDevices[currentActionDeviceId] = p.getStructure();
					
					var fake:Package = new Package;
					fake.structure = currentActionDeviceId+1;
					fake.data = p.getStructure();
					fake.data.push( deviceType );
					
					opt.putData( fake );//Array( [currentActionDeviceId, oDevices[currentActionDeviceId] ] );
					opt.visible = true;
					tNotify.visible = false;
					blockButtons(false);
					forgotten.visible = opt.old; 
					label_second_current = loc("g_setting")+" "+ labelParentPadejS+" "+ (currentActionDeviceId+1);
					changeSecondLabel( loc("g_setting")+" "+ labelParentPadejS+" "+ (currentActionDeviceId+1) + label_jumper );
					navi.disable(false);
				}
			}
		}
	}
}
// 494 