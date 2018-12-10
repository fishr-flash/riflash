package foundation.functions
{
	import components.protocol.statics.OPERATOR;
	import components.static.CMD;
	import components.system.CONST;

	public function attuneCmd():void
	{	// функция не может операться на аппаратную версию прибора, она загружается позже
		OPERATOR.getSchema( CMD.CONNECT_SERVER).StructCount = 2;
		OPERATOR.getSchema( CMD.SEND_RUBBER_HISTORY_SERVER).StructCount = 65535;
		OPERATOR.getSchema( CMD.SEND_SELECT_HISTORY).StructCount = 65535;
		
		switch(CONST.VERSION) {
			case "V-L1":
			case "V-L2":
			case "V-L1_and_V-L2_and_V-L1-3G_and_V-L2-3G":
				OPERATOR.getSchema( CMD.GPRS_SIM).StructCount = 1;
				OPERATOR.getSchema( CMD.VER_INFO1 ).StructCount = 1;
				OPERATOR.getSchema( CMD.CONNECT_SERVER).StructCount = 2;
				OPERATOR.getSchema( CMD.VR_INPUT_TYPE ).StructCount = 1;
				OPERATOR.getSchema( CMD.VR_INPUT_DIGITAL ).StructCount = 1;
				break;
			case "V-2":
			case "V-2_and_V-L3":
				OPERATOR.getSchema( CMD.GPRS_SIM).StructCount = 2;
				OPERATOR.getSchema( CMD.VER_INFO1 ).StructCount = 2;
				OPERATOR.getSchema( CMD.CONNECT_SERVER).StructCount = 4;
				OPERATOR.getSchema( CMD.VR_INPUT_TYPE ).StructCount = 4;
				OPERATOR.getSchema( CMD.GPRS_APN_AUTO).StructCount = 2;
				OPERATOR.getSchema( CMD.NO_GPRS_ROAMING).StructCount = 2;
				break;
			case "V-3":
			case "V-3_and_V-3L":
				OPERATOR.getSchema( CMD.NO_GPRS_ROAMING).StructCount = 1;
				break;
			case "V-4":
				OPERATOR.getSchema( CMD.GPRS_SIM).StructCount = 1;
				OPERATOR.getSchema( CMD.VER_INFO1 ).StructCount = 1;
				break;
			case "V-5":
				OPERATOR.getSchema( CMD.GPRS_SIM).StructCount = 2;
				OPERATOR.getSchema( CMD.VER_INFO1 ).StructCount = 2;
				OPERATOR.getSchema( CMD.GPRS_APN_AUTO).StructCount = 2;
				OPERATOR.getSchema( CMD.NO_GPRS_ROAMING).StructCount = 2;
				break;
			case "V-6":
				OPERATOR.getSchema( CMD.GPRS_SIM).StructCount = 1;
				OPERATOR.getSchema( CMD.VER_INFO1 ).StructCount = 1;
				break;
		}
	}
}