package foundation.functions
{
	import components.protocol.statics.OPERATOR;
	import components.static.CMD;
	import components.system.CONST;

	public function attuneCmd():void
	{
		OPERATOR.getSchema( CMD.MAPRF_KEY).StructCount = CONST.RFKEY_NUM;
		OPERATOR.getSchema( CMD.RF_KEY).StructCount = CONST.RFKEY_NUM;
		OPERATOR.getSchema( CMD.RF_KEY_BZI ).StructCount = CONST.RFKEY_NUM;
		OPERATOR.getSchema( CMD.RF_KEY_BZP ).StructCount = CONST.RFKEY_NUM;
	}
}