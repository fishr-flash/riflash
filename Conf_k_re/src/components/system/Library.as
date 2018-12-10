package components.system
{
	import flash.utils.getDefinitionByName;
	
	import components.abstract.LOC;

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
		
		// UI LinkChannels
		[Embed(source='../../assets/k5lib.swf', symbol="_8sensors")]
		public static var cw8sensors:Class;
		[Embed(source='../../assets/k5lib.swf', symbol="_16sensors")]
		public static var cw16sensors:Class;
		[Embed(source='../../assets/k5lib.swf', symbol="firealarm")]
		public static var cwfirealarm:Class;
		[Embed(source='../../assets/k5lib.swf', symbol="firecrash")]
		public static var cwfirecrash:Class;
		[Embed(source='../../assets/k5lib.swf', symbol="firenorm")]
		public static var cwfirenorm:Class;
		[Embed(source='../../assets/k5lib.swf', symbol="sensoralarm")]
		public static var cwsensoralarm:Class;
		[Embed(source='../../assets/k5lib.swf', symbol="sensorcrash")]
		public static var cwsensorcrash:Class;
		[Embed(source='../../assets/k5lib.swf', symbol="sensornorm")]
		public static var cwsensornorm:Class;
		// K9
		[Embed(source='../../assets/k5lib.swf', symbol="_3sensors")]
		public static var cw3sensors:Class;
		
		[Embed(source='../../assets/k5lib.swf', symbol="_6sensors")]
		public static var cw6sensors:Class;
		
		[Embed(source='../../assets/c2000events_ru.json', mimeType="application/octet-stream")]
		public static var c2000evt_ru_RU:Class;
		[Embed(source='../../assets/c2000events_en.json', mimeType="application/octet-stream")]
		public static var c2000evt_en_US:Class;
		[Embed(source='../../assets/c2000events_it.json', mimeType="application/octet-stream")]
		public static var c2000evt_it_IT:Class;
		
		
		
	}
}