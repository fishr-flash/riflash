package foundation.functions
{
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.protocol.statics.OPERATOR;
	import components.static.CMD;
	import components.static.DS;
	import components.system.CONST;
	import components.system.SavePerformer;

	public function attuneCmd():void
	{	// функция не может операться на аппаратную версию прибора, она загружается позже
		

		switch(CONST.VERSION) {
			/*case DEVICES.K1M:
				if( int( DEVICES.app ) > 6 && DEVICES.release  > 10 ) 
					OPERATOR.getSchema( CMD.K5_SMS_TEXT).StructCount = 68;
				
				
				break;*/
			case DS.KLAN + "_and_" + DS.A_ETH:
				OPERATOR.getSchema( CMD.PART_STATE_ALL).StructCount = 17;
				
				SavePerformer.addAftersave( function():void
					{
						RequestAssembler.getInstance().fireEvent( new Request(CMD.LAN_SET_UP,null,1,[1]));
					} );
				break;
			case DS.K5RT1:
			case DS.K5RT13G:
			case DS.K5RT1L:
			case DS.K5RT1 + "_and_" + DS.K5RT1L + "_and_" + DS.K5RT13G:
				OPERATOR.getSchema( CMD.K5_OUT_DRIVE).StructCount = 2;
				OPERATOR.getSchema( CMD.K5RT_AWIRE_TYPE).StructCount = 2;
				
				break;
			case DS.K5 + "_and_" + DS.K5A + "_and_" + DS.K53G + "_and_" + DS.K5GL + "_and_" + DS.A_BRD:
			case DS.isfam( DS.K5 ):
				/*OPERATOR.getSchema( CMD.K5_OUT_DRIVE).StructCount = 5;
				if( int( DEVICES.release ) < 12 )
					OPERATOR.getSchema( CMD.K5_SMS_TEXT).StructCount = 55;
				if( int( DEVICES.release ) == 12 )
					OPERATOR.getSchema( CMD.K5_SMS_TEXT).StructCount = 66;
				if( int( DEVICES.release ) > 12 )
					OPERATOR.getSchema( CMD.K5_SMS_TEXT).StructCount = 67;*/
				OPERATOR.getSchema( CMD.K5_ADC_TRESH).StructCount = 8;
				
				break;
			case DS.K9 + "_and_" + DS.K9A + "_and_" + DS.K9M + "_and_" + DS.K9K:
			case DS.K9A:
			case DS.K9M:
			case DS.K9K:
				OPERATOR.getSchema( CMD.K5_OUT_DRIVE).StructCount = 2;
				OPERATOR.getSchema( CMD.K5_SMS_TEXT).StructCount = 78;
				OPERATOR.getSchema( CMD.K5_KBD_KEY).StructCount = 10;
				OPERATOR.getSchema( CMD.K5_ADC_TRESH).StructCount = 3;
				OPERATOR.getSchema( CMD.K5_TM_KEY).StructCount = 16;
				break;
			
		}
	}
}