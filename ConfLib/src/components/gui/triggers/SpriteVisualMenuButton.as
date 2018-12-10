package components.gui.triggers
{
	public class SpriteVisualMenuButton extends SpriteVisualButton
	{
		public function SpriteVisualMenuButton(cls:Class, clickable:Boolean=false)
		{
			super(cls, clickable);
			
			defaultPlaceX = 0;
			defaultPlaceY = 0;
			shiftPlaceX = 1;
			shiftPlaceY = 1;
			tName.x = defaultPlaceX;
			tName.y = defaultPlaceY;
			
			pic.y = 4;
			
			picDefaultPlaceY = pic.y;
			picShiftPlaceY = picDefaultPlaceY + 1;
		}
	}
}