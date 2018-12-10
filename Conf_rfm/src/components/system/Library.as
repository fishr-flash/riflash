package components.system
{
	public class Library
	{
		// UNIVERSAL
		[Embed(source='../../assets/graphic.swf', symbol="tree_icon")]
		public static var cIcon:Class;
		[Embed(source='../../assets/graphic.swf', symbol="popup_window")]
		public static var cPopup:Class;
		
		// UIVerInfo
		[Embed(source='../../assets/graphic.swf', symbol="sim_signal")]
		public static var cSignal:Class;
		
		// RF RCTRL
		[Embed(source='../../assets/b_lock.png')]
		public static var cLock:Class
		[Embed(source='../../assets/b_unlock.png')]
		public static var cUnlock:Class
		[Embed(source='../../assets/b_star.png')]
		public static var cStar:Class
		
		[Embed(source='../../assets/rdk_devices.json', mimeType="application/octet-stream")]
		public static var RdkDevices:Class;
		
		
	}
}