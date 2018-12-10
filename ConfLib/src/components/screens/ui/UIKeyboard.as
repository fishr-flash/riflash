package components.screens.ui
{
	import components.abstract.functions.loc;
	import components.abstract.sysservants.PartitionServant;
	import components.basement.UIRadioDeviceRoot;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.protocol.statics.OPERATOR;
	import components.protocol.statics.SERVER;
	import components.screens.opt.OptKeyboard;
	import components.static.CMD;
	import components.static.DS;
	import components.static.RF_FUNCT;
	import components.system.SavePerformer;
	
	public class UIKeyboard extends UIRadioDeviceRoot
	{
		
		public function UIKeyboard(limit:int)
		{
			label = loc("ui_rfkey");
			labelParentPadejM = loc("ui_rfkey_padejm");
			labelParentPadejS = loc("ui_rfkey_padejs");
			labelParentPadejR = loc("ui_rfkey_padejr");
			LOCALE_NOT_FOUND = loc("ui_rfkey_found");
			label_construct = loc("ui_rfkey")+" ";
			cmd = CMD.RF_KEY;
			deviceType = RF_FUNCT.TYPE_KEYBOARDS;
			DEVICE_MAX = limit;
			fwidth = 618+56;
			fheight = 590;
			
			opt = new OptKeyboard(true);
			
			super();
			
			navi.setXOffset( 10 );
			navi.width = 240;
			
			
			addChild( opt );
			opt.visible = false;
			
			
			
			starterCMD = [ cmd ];
			
			
			if( DS.isfam( DS.K14 ) || ( DS.isfam( DS.K16 ) && SERVER.BOTTOM_RELEASE > 17 ) )
							starterRefine( CMD.RF_TYPE_KEYB, true );
			
		}
		
		override public function open():void
		{
			super.open();
			
			
		}
		override protected function getLabel( str:int, device_type:int = 0 ):String
		{
			
			
			///Убрано взаимодействие с учетом ЛСД клавиатуры
			if(  DS.isfam( DS.K16 ) && SERVER.BOTTOM_RELEASE < 18 )
							return super.getLabel( str, device_type );
			var type:int = device_type
				
			type = device_type == 0?OPERATOR.getData( CMD.RF_TYPE_KEYB )[ str ]:device_type; 
			
			
			
			//if( !DS.isfam( DS.K16 ) )deviceType = OPERATOR.getData( CMD.RF_TYPE_KEYB )[ str ];
			
			
			if( type == RF_FUNCT.TYPE_RADIOKLAVIATURA )
				return loc( "ui_rfkey" );
			else 
				return loc( "ui_rfkey_lcd" );
			
			
			
			
			
		}
		override protected function openDeviceSuccess(p:Package):void
		{
			if ( !p.error ) {
				SavePerformer.closePage();
				if (NEED_DEFAULTS) {
					NEED_DEFAULTS = false;
					
					var allpartition:int = PartitionServant.getAllPartitionBitmask();
					
					RequestAssembler.getInstance().fireEvent( new Request( CMD.RF_KEY_BZI, response, currentActionDeviceId+1,
						[1,1] ));
					RequestAssembler.getInstance().fireEvent( new Request( CMD.RF_KEY_BZP, response, currentActionDeviceId+1,
						[allpartition,4,4,0,7,4,0] ));
					if( DS.isfam( DS.K14 ) || ( DS.isfam( DS.K16 ) && SERVER.BOTTOM_RELEASE > 17 ) )
							RequestAssembler.getInstance().fireEvent( new Request( CMD.RF_TYPE_KEYB, response, currentActionDeviceId+1 ));
					
					RequestAssembler.getInstance().fireEvent( new Request( cmd, response, currentActionDeviceId+1,
						[1,allpartition , 0, 0, 0, 0x04, 0,0  ] ));
					
					
					
					
				} else {
					oDevices[currentActionDeviceId] = p.getStructure();
					
					//if( !DS.isfam( DS.K16 ) )deviceType = OPERATOR.getData( CMD.RF_TYPE_KEYB )[ currentActionDeviceId ];
					
					var fake:Package = new Package;
					fake.structure = currentActionDeviceId+1;
					fake.data = p.getStructure();
					if( DS.isfam( DS.K14 ) || (DS.isfam( DS.K16 ) && SERVER.BOTTOM_RELEASE > 17 ))
							fake.data.push( OPERATOR.getData( CMD.RF_TYPE_KEYB )[ currentActionDeviceId ] );
					
					opt.putData( fake );
					opt.visible = true;
					tNotify.visible = false;
					//blockButtons(false);
					forgotten.visible = opt.old; 
					label_second_current = loc("g_setting")+" "+ labelParentPadejS+" "+ (currentActionDeviceId+1);
					changeSecondLabel( loc("g_setting")+" "+ labelParentPadejS+" "+ (currentActionDeviceId+1) + label_jumper );
					//navi.disable(false);
				}
			}
		}
		private function response(p:Package):void
		{
			if ( !p.error ) {
				
				RequestAssembler.getInstance().fireEvent( new Request( cmd, openDeviceSuccess, currentActionDeviceId+1 ));
			}
		}
		
		override protected function isDeviceValid(re:Array):Boolean
		{
			return (re[0] == deviceType 
				|| re[0] == RF_FUNCT.TYPE_RADIOKLAVIATURA 
				|| re[0] == RF_FUNCT.TYPE_KEYBOARDS 
				|| re[0] == RF_FUNCT.TYPE_RADIOKLAVIATURA_LCD  );
			
		}
		
	}
}