package components.gui.triggers
{
	public class SpriteMovieClipButton extends SpriteVisualButton
	{
		/** used and set up for only picture, without text	*/
		public function SpriteMovieClipButton(cls:Class)
		{
			super(cls, false, true);
			
			tName.visible = false;
		}
	}
}