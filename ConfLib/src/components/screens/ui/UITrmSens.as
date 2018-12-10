package components.screens.ui
{
	import components.abstract.functions.loc;
	import components.basement.UIRadioDeviceRoot;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.protocol.statics.OPERATOR;
	import components.screens.opt.OptRctrlTermoSens;
	import components.static.CMD;
	import components.static.RF_FUNCT;
	import components.system.SavePerformer;
	
	public class UITrmSens extends UIRadioDeviceRoot
	{
		/// указывает номер сенсора разница температуры на указанную величину которого пишется 
		// в историю, только один сенсор может учитываться в историю 
		public static var ID_REC_SENS:int = 0;
		public static const CPRM_908:int = OPERATOR.getSchema( CMD.RF_CTRL_TEMP ).Parameters.length;;
		
		public function UITrmSens()
		{
			label = loc("navi_sensor");
			labelParentPadejM = loc("ui_termosensor_padejm")
			labelParentPadejS = loc("ui_termosensor_padejs")
			labelParentPadejR = loc("navi_sensor").toLowerCase();
			LOCALE_NOT_FOUND = loc("ui_trinket_found");
			label_construct = loc("navi_sensor")+" ";
			cmd = CMD.RF_CTRL_TEMP;
			
			deviceType = RF_FUNCT.TYPE_TERMOSENSOR;
			DEVICE_MAX = 4;
			
			fwidth = 518;;
			fheight = 192;
			
			opt = new OptRctrlTermoSens;
			
			super();
			
			addChild( opt );
			opt.visible = false;
			
			starterCMD = cmd;
		}
		
		override public function put(p:Package):void
		{
			
			
			searchIDRecSensor( p.data );
			
			
			super.put( p );
			
		}
		private function upstate():void
		{
			
			
				RequestAssembler.getInstance().fireEvent( new Request( CMD.RF_SENSOR, openDeviceSuccess, currentActionDeviceId+1 ));
			
		}
		
		override public function close():void
		{
			super.close();
			( opt as OptRctrlTermoSens ).close();
		}
		
		override protected function removeDevice( p:Package = null ):void 
		{
			
			
			
			
			if( p  )
			{
				if ( p.success ) {
					
					nonRefundable = oldies.indexOf( int( p.request.data[ 1 ] ) ) > -1;
					doState( true );
					label_second_current = loc("g_removing")+" "+labelParentPadejS+"...";
					RequestAssembler.getInstance().fireEvent( new Request( CMD.RF_CTRL_TEMP, pastRemoved ) );
					
				} else if ( p.error )
					doState( false );
				
			}
			else
			{
				super.removeDevice( );
			}
			
		}
		override protected function openDeviceSuccess(p:Package):void
		{
			
			if ( !p.error ) {
				SavePerformer.closePage();
				if (NEED_DEFAULTS) {
					NEED_DEFAULTS = false;
					
					/*RequestAssembler.getInstance().fireEvent( new Request( CMD.RF_FUNCT, response, currentActionDeviceId+1,
						[1, PartitionServant.getAllPartitionBitmask(), 0x4023, 0x4021, 0 ] ));*/
					upstate(  );
					//label_second_current = label_second_construct+ (currentActionDeviceId+1);
				} else {
					
					if( OPERATOR.getData( CMD.RF_CTRL_TEMP ) ) 
						searchIDRecSensor( OPERATOR.getData( CMD.RF_CTRL_TEMP ) ); 
					oDevices[currentActionDeviceId] = p.getStructure();
					
					var fake:Package = new Package;
					fake.structure = currentActionDeviceId+1;
					fake.data = p.getStructure();
					
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
		
		private function pastRemoved( p:Package ):void
		{
			searchIDRecSensor( OPERATOR.getData( CMD.RF_CTRL_TEMP ) );
			
			//removeDevice( p );
			
			
		}
		
		private function searchIDRecSensor( params:Array  ):void
		{
			var len:int = OPERATOR.getSchema( cmd ).StructCount;
			ID_REC_SENS = 0;
			
			for (var i:int=0; i<len; i++) {
				if( int( params[ i ][ 0 ] ) == 1 || int( params[ i ][ 0 ] ) == 2 )
				{
					if( int( params[ i ][ 4 ] ) != 0 && int( params[ i ][ 4 ] ) != 0xFF)
					{
						ID_REC_SENS = i * CPRM_908 + 5;
						break;
					}
					if( int( params[ i ][ 7 ] ) != 0 && int( params[ i ][ 7 ] ) != 0xFF )
					{
						ID_REC_SENS = i * CPRM_908 + 8;
						break;
					}
				}
				
			}
			
			
			
		}
	}
}
// 494 