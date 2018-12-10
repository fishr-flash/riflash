package foundation.functions
{
	import components.protocol.statics.OPERATOR;
	import components.protocol.statics.SERVER;
	import components.static.CMD;

	public function passLocalRules():Boolean
	{
	/*	if( int(SERVER.HARDWARE_VER) == 7 )	// на 7 аппаратной редакции есть ЕГТС, больше нигде нет
			OPERATOR.getSchema( CMD.CONNECT_SERVER).StructCount = 4;*/
		return true;
	}
}