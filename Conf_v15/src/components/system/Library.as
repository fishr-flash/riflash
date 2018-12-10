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
		
		[Embed(source='../../assets/voyager15_lib.swf', symbol="button_eye")]
		public static var cButtonEye:Class;
		[Embed(source='../../assets/voyager15_lib.swf', symbol="button_save")]
		public static var cButtonSave:Class;
		[Embed(source='../../assets/voyager15_lib.swf', symbol="button_refresh")]
		public static var cButtonRefresh:Class;
		[Embed(source='../../assets/voyager15_lib.swf', symbol="button_plus")]
		public static var cButtonPlus:Class;
		[Embed(source='../../assets/voyager15_lib.swf', symbol="button_minus")]
		public static var cButtonMinus:Class;
		[Embed(source='../../assets/voyager15_lib.swf', symbol="button_gear")]
		public static var cButtonGear:Class;
		
		[Embed(source='../../assets/k15lib.swf', symbol="size")]
		public static var c_size:Class;
		[Embed(source='../../assets/k15lib.swf', symbol="video_file")]
		public static var c_videfile:Class;
		[Embed(source='../../assets/k15lib.swf', symbol="date")]
		public static var c_date:Class;
		[Embed(source='../../assets/k15lib.swf', symbol="pb_bg_left")]
		public static var c_pb_bg_left:Class;
		[Embed(source='../../assets/k15lib.swf', symbol="pb_bg_right")]
		public static var c_pb_bg_right:Class;
		[Embed(source='../../assets/k15lib.swf', symbol="pb_bg")]
		public static var c_pb_bg:Class;
		[Embed(source='../../assets/k15lib.swf', symbol="pb_fill_left")]
		public static var c_pb_fill_left:Class;
		[Embed(source='../../assets/k15lib.swf', symbol="pb_fill_right")]
		public static var c_pb_fill_right:Class;
		[Embed(source='../../assets/k15lib.swf', symbol="pb_fill")]
		public static var c_pb_fill:Class;
		
		// K7
		[Embed(source='../../assets/k7lib.swf', symbol="klemm")]
		public static var wire:Class;
	}
}