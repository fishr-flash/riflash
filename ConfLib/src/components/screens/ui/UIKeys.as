package components.screens.ui
{
	import components.abstract.LOC;
	import components.abstract.functions.loc;
	import components.abstract.servants.ResizeWatcher;
	import components.abstract.servants.TabOperator;
	import components.abstract.sysservants.PartitionServant;
	import components.basement.UIRadioDeviceRoot;
	import components.gui.triggers.TextButton;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.protocol.statics.CLIENT;
	import components.screens.opt.OptTMKey;
	import components.static.CMD;
	import components.static.DS;
	import components.static.RF_FUNCT;
	import components.system.SavePerformer;

	public class UIKeys extends UIRadioDeviceRoot
	{
		public static var LAST_PARTITION:int = 0xFFFFFF;
		
		private var bAddRemotely:TextButton;
		
		public function UIKeys()
		{
			label = loc("ui_tmkey");
			labelParentPadejM = loc("ui_tmkey_padejm");
			labelParentPadejS = loc("ui_tmkey_padejs");
			labelParentPadejR = loc("ui_tmkey_padejr");
			LOCALE_NOT_FOUND = loc("ui_tmkey_found");
			label_construct = loc("ui_tmkey_label")+" ";
			cmd = CMD.TM_KEY;
			deviceType = RF_FUNCT.TYPE_KEY_TM;
			DEVICE_MAX = DS.isfam( DS.K16 )?128:16;
			fwidth = 432;
			fheight = 140;
			
			opt = new OptTMKey;
			
			super();
			
			globalY = 10;
			
			bAddRemotely = new TextButton;
			getCont().addChild( bAddRemotely );
			bAddRemotely.setUp(loc("ui_tmkey_add_manually"), addRemotely );
			bAddRemotely.setFormat(true, 12);
			bAddRemotely.x = 10;
			bAddRemotely.y = globalY;
			TabOperator.getInst().add(bAddRemotely);
			
			globalY += bAddRemotely.getHeight();
			
			bAddDevice.y = globalY;
			globalY += bAddDevice.getHeight(); 
			
			bRemoveDevice.y = globalY;
			globalY += bRemoveDevice.getHeight(); 
			
			bRestoreDevice.y = globalY;
			globalY += bRestoreDevice.getHeight();
			
			state = CMD.TM_KEY_STATE;
			
			navi.setXOffset( 50 );
			
			addChild( opt );
			opt.visible = false;
			
			starterCMD = CMD.TM_KEY;
		}
		override public function open():void
		{
			super.open();
			
			bAddRemotely.visible = false;
		}
		override public function put(p:Package):void
		{
			super.put(p);
			
			bAddRemotely.visible = true;
		}
		override protected function assembleFunct(action:int):void
		{
			switch(action)
			{
				case RF_FUNCT.DO_CANCEL:
					RequestAssembler.getInstance().fireEvent( new Request(
						CMD.TM_KEY_FUNCT, cancelSuccess, 1,[ currentActionDeviceId+1, RF_FUNCT.DO_CANCEL ] ));
					break;
				case RF_FUNCT.DO_ADD:
					RequestAssembler.getInstance().fireEvent( new Request(
						CMD.TM_KEY_FUNCT, addDevice, 1,[ currentActionDeviceId+1, RF_FUNCT.DO_ADD ] ));
					break;
				case RF_FUNCT.DO_DEL:
					RequestAssembler.getInstance().fireEvent( new Request(
						CMD.TM_KEY_FUNCT, removeDevice, 1,[ navi.selection+1, RF_FUNCT.DO_DEL ] ));
					break;
				case  RF_FUNCT.DO_RESTORE:
					RequestAssembler.getInstance().fireEvent( new Request(
						CMD.TM_KEY_FUNCT, restoreDevice, 1,[ deletedDevice.structure, RF_FUNCT.DO_RESTORE ] ));
					break;
				case  RF_FUNCT.DO_REMOTELY:
					RequestAssembler.getInstance().fireEvent( new Request(
						CMD.TM_KEY_FUNCT, restoreDevice, 1,[ currentActionDeviceId+1, RF_FUNCT.DO_REMOTELY] ));
					break;
			}
		}
		override protected function overwriteState():void
		{
			RequestAssembler.getInstance().fireEvent( new Request( state, null, 1,[0,0] ));
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
			return Boolean(v==1);
		}
		private function response(p:Package):void
		{
			if ( !p.error ) {
				RequestAssembler.getInstance().fireEvent( new Request( CMD.TM_KEY, openDeviceSuccess, currentActionDeviceId+1 ));
			}
		}
		override protected function openDeviceSuccess(p:Package):void
		{
			if ( !p.error ) {
				SavePerformer.closePage();
				if (NEED_DEFAULTS) {
					var arr:Array = p.getStructure().slice();
					var bit:int = 0;
					if(LAST_PARTITION > 0xffff) {
						for( var key:String in PartitionServant.PARTITION ) {
							bit |= 1<<(int(key)-1);
						}
					} else
						bit = LAST_PARTITION;
					arr[9] = bit;
					arr[10] = currentActionDeviceId+1;
					NEED_DEFAULTS = false;
					RequestAssembler.getInstance().fireEvent( new Request( CMD.TM_KEY, response, currentActionDeviceId+1, arr ));
				} else {
					oDevices[currentActionDeviceId] = p.getStructure();
					opt.putData( Package.create( oDevices[currentActionDeviceId], currentActionDeviceId+1 ));
					opt.visible = true;
					tNotify.visible = false;
					buttonsEnabler();
					forgotten.visible = opt.old; 
					
					navi.disable(false);
					blockButtons(false);
					
					label_second_current = loc("g_setting")+" "+labelParentPadejS+" "+ (currentActionDeviceId+1);
					changeSecondLabel( loc("g_setting")+" "+labelParentPadejS +" "+(currentActionDeviceId+1) + label_jumper );
				}
			}
		}
		override protected function buttonsEnabler():void 
		{
			super.buttonsEnabler();
			
			bAddRemotely.disabled = WAIT_FOR_STATE || CLIENT.JUMPER_BLOCK || isMaximum() || BLOCK_BUTTONS;
		}
		override protected function set listEmptyVisible(b:Boolean):void
		{
			super.listEmptyVisible = b;
			
			globalY = b ? 10:-20;	
			globalY += 10;
			
			bAddRemotely.y = globalY;
			
			globalY += bAddRemotely.getHeight();
			
			bAddDevice.y = globalY;
			globalY += bAddDevice.getHeight(); 
			
			bRemoveDevice.y = globalY;
			globalY += bRemoveDevice.getHeight(); 
			
			bRestoreDevice.y = globalY;
			globalY += bRestoreDevice.getHeight();
			
			getCont().height = globalY + 50;
			
			ResizeWatcher.doResizeMe(this);
		}
		private function addRemotely( p:Package = null ):void 
		{// если массив !null значит это ответ с сервера, иначе запрос на fireEvent
			if ( p ) {
				if ( p.success ) {
					doState( true );
					label_second_current = loc("g_adding")+" "+labelParentPadejS+"...";
				} else if ( p.error ) {
					doState( false );
				}
			} else {
				currentActionDeviceId = getFreeSpaceNumber();
				if ( currentActionDeviceId > -1 ) {
					doState( true );
					navi.disable(true);
					opt.visible = false;
					forgotten.visible = false;
					assembleFunct( RF_FUNCT.DO_REMOTELY );
				} 
			}
		}
		/** LOC	**/
		override protected function locNoDevices():String
		{
			if (LOC.language == LOC.IT)
				return loc("spec_no_tm_keys");//loc("rfd_no_registered")+" "+labelParentPadejM.toLowerCase()+" "+loc("rfd_in_device");
			return super.locNoDevices();
		}
	}
}