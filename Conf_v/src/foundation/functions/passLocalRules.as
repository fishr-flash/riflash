package foundation.functions
{
	import components.protocol.statics.OPERATOR;
	import components.static.CMD;
	import components.static.DS;

	public function passLocalRules():Boolean
	{
		switch(DS.alias) {
			case DS.V2:
			case DS.V2_3G:
			case DS.V2T:
				if (DS.release <= 34)
					OPERATOR.getSchema( CMD.VR_SPEED_ALARM).StructCount = 3;
				else if (DS.release >= 35) {
					OPERATOR.getSchema( CMD.VR_SPEED_ALARM).StructCount = 5;
				}
				break;
			case DS.VL3:
			case DS.VL3_3G:
				OPERATOR.getSchema( CMD.VR_INPUT_TYPE).StructCount = 1;
				OPERATOR.getSchema( CMD.VR_INPUT_DIGITAL).StructCount = 1;
				OPERATOR.getSchema( CMD.GPRS_SIM).StructCount = 1;
				OPERATOR.getSchema( CMD.VER_INFO1 ).StructCount = 1;
				OPERATOR.getSchema( CMD.GPRS_APN_AUTO).StructCount = 1;
				OPERATOR.getSchema( CMD.NO_GPRS_ROAMING).StructCount = 1;
				OPERATOR.getSchema( CMD.VR_SPEED_ALARM).StructCount = 5;
				break;
		}
		return true;
	}
}