package foundation.functions
{
	import components.protocol.statics.SERVER;

	
	public function passLocalRules():Boolean
	{	// 16 Контакт, проверка верхняя или нижняя плата подключены
		SERVER.DUAL_DEVICE = Boolean( SERVER.HARDWARE_VER.charAt(0) == "2");
		
		if ( !SERVER.DUAL_DEVICE )
			createMenu();
		
		if ( SERVER.HARDWARE_VER.charAt(0) == "1" || SERVER.HARDWARE_VER.charAt(0) == "2")
			return true;
		return false;
	}
}