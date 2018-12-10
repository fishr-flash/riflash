package components.gui.visual
{
	import mx.controls.ProgressBar;
	
	public class ProgressBarExt extends ProgressBar
	{
		public function ProgressBarExt()
		{
			super();
		}
		override public function set visible(value:Boolean):void
		{
			if (this.visible != value)
				super.visible = value;
		}
	}
}