package components.gui.triggers
{
	import flash.display.Sprite;

	/**
	 *  Расширение MButton добаляющее окрашивающий
	 * слой сверху обычной кнопки
	 */
	internal class ClrMButton extends MButton
	{
		
		public function ClrMButton(name:String, f:Function, id:int=-1, color:uint = 0 )
		{
			super(name, f, id);
			
			init( color );
		}
		
		private function init(color:uint):void
		{
			if( !color ) return;
			const round:Number = 2;
			const clrLayer:Sprite = new Sprite;
			clrLayer.graphics.beginFill( color, .5 );
			clrLayer.graphics.drawRoundRect( round - .5, round, this.width - ( round * 2 ), this.height - ( round * 2 ), round, round );
			clrLayer.graphics.endFill();
			this.addChild( clrLayer );
		}
	}
}