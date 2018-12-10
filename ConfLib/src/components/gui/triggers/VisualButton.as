package components.gui.triggers
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;

	public class VisualButton extends ListButton
	{
		private var pic:DisplayObject;
		private var over:ColorTransform;
		private var normal:ColorTransform;
		
		public function VisualButton(cls:Class)
		{
			super();
			
			pic = new cls;
			if (pic is MovieClip)
				(pic as MovieClip).gotoAndStop(1);
			addChild( pic );
			
			defaultPlaceX = pic.width + 5;
			shiftPlaceX = defaultPlaceX+1;
			
			fillH = 18;
			fillW = 112;
			
			textFormat.underline = false;
			tName.defaultTextFormat = textFormat;
			
			if( pic.height < fillH ) {
				pic.y = int((fillH - pic.height)/2); 
			}
			tName.x = defaultPlaceX;
			tName.y = defaultPlaceY;
			
			over = new ColorTransform(1.3,1.3,1.3);
			normal = new ColorTransform;
		}
		override protected function rollOver( ev:MouseEvent ):void 
		{
			super.rollOver(ev);
			pic.transform.colorTransform = over;
		}
		override protected function rollOut( ev:MouseEvent ):void 
		{
			super.rollOut(ev);
			pic.transform.colorTransform = normal;
		}
		public function set frame(value:int):void
		{
			(pic as MovieClip).gotoAndStop(value);
		}
		public function set onlyPicture(b:Boolean):void
		{
			tName.visible = false;
		}
		public function setPicX(value:int):void
		{
			pic.x = value;
		}
		public function showLayer(layer:String, value:Boolean):void
		{
			pic[layer].visible = value;
		}
		public function attuneAsMenuButton(offset:Number=NaN):void	// делает ширину селекта равно ширине subMenu
		{
			fillW=247;
			if (!isNaN(offset)) {
				defaultPlaceX = offset;
				shiftPlaceX = offset + 1;
				tName.x = offset;
			}
		}
	}
}