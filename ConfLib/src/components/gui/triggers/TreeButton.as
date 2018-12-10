package components.gui.triggers
{
	import flash.display.Sprite;

	public class TreeButton extends ListButton
	{
		[Embed(source='../../../assets/gui_library.swf', symbol="tree_bridge")]
		private var cBridge:Class;
		private var bridge:Sprite;
		
		public function TreeButton()
		{
			super(0);
			
			bridge = new cBridge;
			addChild( bridge );
			bridge.x = -18;
			bridge.y = -6;
			
			textFormat.underline = false;
			tName.defaultTextFormat = textFormat;
			
			setUpFill( fillColor, 110,18);
		}
	}
}