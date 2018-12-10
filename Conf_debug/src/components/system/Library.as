package components.system
{
	public class Library
	{
		// UNIVERSAL
		[Embed(source='../../assets/graphic.swf', symbol="tree_icon")]
		public static var cIcon:Class;
		[Embed(source='../../assets/graphic.swf', symbol="popup_window")]
		public static var cPopup:Class;
		
		// RF RCTRL
		[Embed(source='../../assets/b_lock.png')]
		public static var cLock:Class
		[Embed(source='../../assets/b_unlock.png')]
		public static var cUnlock:Class
		[Embed(source='../../assets/b_star.png')]
		public static var cStar:Class
		
		// UI LinkChannels
		[Embed(source='../../assets/library.swf', symbol="link_arrow")]
		public static var cLinkArrow:Class;

		// UIVerInfo
		[Embed(source='../../assets/graphic.swf', symbol="sim_signal")]
		public static var cSignal:Class;
		
		// UI Keyboard
		[Embed(source='../../assets/b_fire.png')]
		public static var cFire:Class
		[Embed(source='../../assets/b_medical.png')]
		public static var cMedical:Class
		[Embed(source='../../assets/b_panic.png')]
		public static var cPanic:Class
		[Embed(source='../../assets/b_exit.png')]
		public static var cExit:Class
		[Embed(source='../../assets/b_stay.png')]
		public static var cStay:Class
		
		// UI RF Rele
		[Embed(source='../../assets/rele/rele.png')]
		public static var cRele:Class
		
		[Embed(source='../../assets/library.swf', symbol="rele_wire")]
		public static var cWire:Class;
		[Embed(source='../../assets/library.swf', symbol="rele_relay")]
		public static var cRelay:Class;
		[Embed(source='../../assets/library.swf', symbol="rele_power")]
		public static var cPower:Class;
		[Embed(source='../../assets/library.swf', symbol="rele_antenna")]
		public static var cAntenna:Class;
		[Embed(source='../../assets/library.swf', symbol="rele_cell_number")]
		public static var cCell:Class;
	}
}