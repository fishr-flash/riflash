package components.gui.visual
{
	import components.static.COLOR;
	
	import flash.display.Sprite;
	
	public class Zebra extends Sprite
	{
		public function Zebra(n:int, h:int=33, w:int=600)
		{
			super();
			
			for(var i:int=1; i<n; ++i ) {
				this.graphics.beginFill( COLOR.ZEBRA_GREY );
				this.graphics.drawRect( 0, i*h, w, h );
				this.graphics.endFill();
				i++;
			}
		}
	}
}