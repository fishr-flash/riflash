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
		
		// UI LinkChannels
		[Embed(source='../../assets/library.swf', symbol="link_arrow")]
		public static var cLinkArrow:Class;
		
		// UINotify
		[Embed(source='../../assets/voyager_lib.swf', symbol="v_call1")]
		public static var v_call1:Class;
		[Embed(source='../../assets/voyager_lib.swf', symbol="v_call2")]
		public static var v_call2:Class;
		[Embed(source='../../assets/voyager_lib.swf', symbol="v_alarm")]
		public static var v_alarm:Class;
		
		[Embed(source='../../assets/pic_bg.png')]
		public static var cZoneButtons:Class
		
		[Embed(source='../../assets/sensors/rsd.png')]
		public static var cRsd:Class
		[Embed(source='../../assets/sensors/rmd.png')]
		public static var cRmd:Class
		[Embed(source='../../assets/sensors/ripr.png')]
		public static var cRipr:Class
		[Embed(source='../../assets/sensors/rgd.png')]
		public static var cRgd:Class
		[Embed(source='../../assets/sensors/rdd3.png')]
		public static var cRdd3:Class
		[Embed(source='../../assets/sensors/rdd1.png')]
		public static var cRdd1:Class
		[Embed(source='../../assets/animal.png')]
		public static var cAnimal:Class
		[Embed(source='../../assets/noanimal.png')]
		public static var cNoAnimal:Class
		
	}
}