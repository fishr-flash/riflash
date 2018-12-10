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
		
		// UINotify
		[Embed(source='../../assets/voyager_lib.swf', symbol="v_call1")]
		public static var v_call1:Class;
		[Embed(source='../../assets/voyager_lib.swf', symbol="v_call2")]
		public static var v_call2:Class;
		[Embed(source='../../assets/voyager_lib.swf', symbol="v_alarm")]
		public static var v_alarm:Class;
		
		
		[Embed(source='../../assets/sms/symbol_2423.png')]
		public static var symbol_2423:Class
		[Embed(source='../../assets/sms/symbol_21b2.png')]
		public static var symbol_21b2:Class
		[Embed(source='../../assets/sms/symbol_dot.png')]
		public static var symbol_dot:Class
		[Embed(source='../../assets/sms/symbol_comma.png')]
		public static var symbol_comma:Class
		[Embed(source='../../assets/sms/symbol_slash.png')]
		public static var symbol_slash:Class
		[Embed(source='../../assets/sms/symbol_minus.png')]
		public static var symbol_minus:Class
		[Embed(source='../../assets/sms/symbol_star.png')]
		public static var symbol_star:Class
		[Embed(source='../../assets/sms/symbol_colon.png')]
		public static var symbol_colon:Class
		[Embed(source='../../assets/sms/symbol_underline.png')]
		public static var symbol_underline:Class
	}
}