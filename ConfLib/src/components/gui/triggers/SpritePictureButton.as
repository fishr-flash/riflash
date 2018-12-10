package components.gui.triggers
{
	public class SpritePictureButton extends SpriteVisualButton
	{
		/** used and set up for only picture, without text	*/
		public function SpritePictureButton(cls:Class)
		{
			super(cls, true);
			
			tName.visible = false;
		}
	}
}