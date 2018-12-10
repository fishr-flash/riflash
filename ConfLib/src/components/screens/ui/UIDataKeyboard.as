package components.screens.ui
{
	import components.abstract.functions.loc;
	import components.abstract.sysservants.PartitionServant;
	import components.basement.UIRadioDeviceRoot;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.screens.opt.OptDataKeyboard;
	import components.static.CMD;
	import components.static.RF_FUNCT;
	import components.system.SavePerformer;

	public class UIDataKeyboard extends UIRadioDeviceRoot
	{
		public function UIDataKeyboard(limit:int)
		{
			label = loc("ui_key_title");
			labelParentPadejM = loc("ui_key_padejm");
			labelParentPadejS = loc("ui_key_padejs");
			labelParentPadejR = loc("ui_key_padejr");
			LOCALE_NOT_FOUND = loc("ui_key_found");
			label_construct = loc("ui_key_title")+" ";
			cmd = CMD.DATA_KEY;
			deviceType = RF_FUNCT.TYPE_DATA_KEYBOARD;
			DEVICE_MAX = limit;
			fwidth = 518+26;
			fheight = 518 + 90;
			
			opt = new OptDataKeyboard;
			
			super();
			
			state = CMD.DATA_KEY_STATE;
			
			navi.setXOffset( 20 );
			
			addChild( opt );
			opt.visible = false;
			
			starterCMD = cmd;
		}
		override protected function overwriteState():void
		{
			RequestAssembler.getInstance().fireEvent( new Request( state, null, 1,[0,0] ));
		}
		override protected function assembleFunct(action:int):void
		{
			switch(action)
			{
				case RF_FUNCT.DO_CANCEL:
					RequestAssembler.getInstance().fireEvent( new Request( 
						CMD.DATA_KEY_FUNCT, cancelSuccess, 1,[ currentActionDeviceId+1, RF_FUNCT.DO_CANCEL ] ));
					break;
				case RF_FUNCT.DO_ADD:
					RequestAssembler.getInstance().fireEvent( new Request( 
						CMD.DATA_KEY_FUNCT, addDevice, 1,[ currentActionDeviceId+1, RF_FUNCT.DO_ADD ] ));
					break;
				case RF_FUNCT.DO_DEL:
					RequestAssembler.getInstance().fireEvent( new Request( 
						CMD.DATA_KEY_FUNCT, removeDevice, 1,[ navi.selection+1, RF_FUNCT.DO_DEL ] ));
					break;
				case  RF_FUNCT.DO_RESTORE:
					RequestAssembler.getInstance().fireEvent( new Request( 
						CMD.DATA_KEY_FUNCT, restoreDevice, 1,[ deletedDevice.structure, RF_FUNCT.DO_RESTORE ] ));
					break;
			}
		}
		override protected function getStateStatus(re:Array):int
		{
			return re[1];
		}
		override protected function isDeviceValid(re:Array):Boolean
		{
			return true;
		}
		override protected function getStruct(re:Array):int
		{
			return re[0];
		}
		override protected function isActive(v:int):Boolean
		{
			return Boolean(v == 1);
		}
		override protected function openDeviceSuccess(p:Package):void
		{
			
			SavePerformer.closePage();
			if (NEED_DEFAULTS) {
				NEED_DEFAULTS = false;
				
				var allpartition:int = PartitionServant.getAllPartitionBitmask();
				
				RequestAssembler.getInstance().fireEvent( new Request( CMD.DATA_KEY_BZI, null, currentActionDeviceId+1,
					[1,1] ));
				RequestAssembler.getInstance().fireEvent( new Request( CMD.DATA_KEY_BZP, null, currentActionDeviceId+1,
					[allpartition,4,4,0,7,4,0] ));
				RequestAssembler.getInstance().fireEvent( new Request( cmd, response, currentActionDeviceId+1,
					[1,allpartition , 0, 0, 0, 0x04, 0,0  ] ));
			} else {
				oDevices[currentActionDeviceId] = p.getStructure();
				
				var fake:Package = new Package;
				fake.structure = currentActionDeviceId+1;
				fake.data = p.getStructure();
				
				opt.putData( fake );
				opt.visible = true;
				tNotify.visible = false;
				//blockButtons(false);
				forgotten.visible = opt.old;
				
				label_second_current = loc("g_setting")+" "+ labelParentPadejS+" "+ (currentActionDeviceId+1);
				changeSecondLabel( loc("g_setting")+" "+ labelParentPadejS+" "+ (currentActionDeviceId+1) + label_jumper );
				
				/*label_second_current = "Настройка "+ labelParentPadejS+" "+ (currentActionDeviceId+1);
				changeSecondLabel( "Настройка "+ labelParentPadejS+" "+ (currentActionDeviceId+1) + label_jumper );
				//navi.disable(false);*/
			}
		//	super.openDeviceSuccess(p);
		}
		private function response(p:Package):void
		{
			RequestAssembler.getInstance().fireEvent( new Request( cmd, openDeviceSuccess, currentActionDeviceId+1 ));
		}
	}
}