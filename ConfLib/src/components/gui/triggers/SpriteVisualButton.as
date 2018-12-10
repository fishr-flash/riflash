package components.gui.triggers
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	
	import components.gui.triggers.SpriteButton;
	
	public class SpriteVisualButton extends SpriteButton
	{
		protected var pic:DisplayObject;
		private var over:ColorTransform;
		private var normal:ColorTransform;
		private var isClickable:Boolean;
		private var multiFrame:Boolean;
		protected var picDefaultPlaceX:int;
		protected var picDefaultPlaceY:int;
		protected var picShiftPlaceX:int;
		protected var picShiftPlaceY:int;
		
		public function SpriteVisualButton(cls:Class, clickable:Boolean=false, multiframe:Boolean=false)
		{
			super();
			
			pic = new cls;
			if (pic is MovieClip)
				(pic as MovieClip).gotoAndStop(1);
			addChild( pic );
			
			defaultPlaceX = pic.width + 5;
			shiftPlaceX = defaultPlaceX+1;
			
			//fillH = 18;
			//fillW = 112;
			
			textFormat.underline = false;
			tName.defaultTextFormat = textFormat;
			
			/*if( pic.height < fillH ) {
				pic.y = int((fillH - pic.height)/2); 
			}*/
			tName.x = defaultPlaceX;
			tName.y = defaultPlaceY;
			
			over = new ColorTransform(1.3,1.3,1.3);
			normal = new ColorTransform;
			
			multiFrame = multiframe;
			isClickable = clickable;
			if (isClickable) {
				picDefaultPlaceX = pic.x;
				picDefaultPlaceY = pic.y;
				picShiftPlaceX = picDefaultPlaceX + 1;
				picShiftPlaceY = picDefaultPlaceY + 1;
			}
		}
		override protected function rollOver( ev:MouseEvent ):void 
		{
			super.rollOver(ev);
			if (isClickable)
				pic.transform.colorTransform = over;
			if (multiFrame)
				(pic as MovieClip).gotoAndStop( 3 );
		}
		override protected function rollOut( ev:MouseEvent ):void 
		{
			super.rollOut(ev);
			if (isClickable)
				pic.transform.colorTransform = normal;
			mUp(null);
			if (multiFrame)
				(pic as MovieClip).gotoAndStop( 1 );
		}
		override protected function mDown( ev:MouseEvent ):void 
		{
			super.mDown(ev);
			if (isClickable) {
				pic.x = picShiftPlaceX;
				pic.y = picShiftPlaceY;
			}
			if (multiFrame)
				(pic as MovieClip).gotoAndStop( 5 );
		}
		override protected function mUp( ev:MouseEvent ):void 
		{
			super.mUp(ev);
			if (isClickable) {
				pic.x = picDefaultPlaceX;
				pic.y = picDefaultPlaceY;
			}
			if (multiFrame)
				(pic as MovieClip).gotoAndStop( 3 );
		}
		public function set frame(value:int):void
		{
			(pic as MovieClip).gotoAndStop(value);
		}
		public function set onlyPicture(b:Boolean):void
		{
			tName.visible = false;
		}
		public function showLayer(layer:String, value:Boolean):void
		{
			pic[layer].visible = value;
		}
		public function setPicX(value:int):void
		{
			pic.x = value;
			picDefaultPlaceX = pic.x;
			picShiftPlaceX = picDefaultPlaceX + 1;
		}
	}
}