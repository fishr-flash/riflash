///********************************************************************
///* Copyright © 2012 fishr (fishr.flash@gmail.com)  
///********************************************************************
package su.fishr.components.chart.gui.scale 
{
	
	import flash.display.CapsStyle;
	import flash.display.GradientType;
	import flash.display.Graphics;
	import flash.display.LineScaleMode;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	
	import su.fishr.display.AlignCenter;
	import su.fishr.display.DrawFrame;
	
   /**
	 * ...
	 * @playerversion          Flash 9
	 * @langversion            3.0
	 * @author                 fishr
	 * @created                23.07.2012 6:18
	 * @since                  23.07.2012 6:18
	 */
	
	public  class Scale extends Sprite
	{
		
		[Event (name="onMagniff", type="su.fishr.components.chart.scale.Scale")];
	/**-------------------------------------------------------------------------------
	* 
	*	   						V A R I A B L E ' S 	
	* 
	* --------------------------------------------------------------------------------
	*/
	//{
		static public const ON_MAGNIFF:String = "onMagniff";
	    static private const AUTHOR:String = "fishr (fishr.flash@gmail.com)";	
		private const _WIDTH:int = 120;
		private var minPosRunner:int;
		private var maxPosRunner:int; 
		private var _runner:Runner;
		private var _magniff:Number;
	//}
	
	/**-------------------------------------------------------------------------------
	* 
	*	 						P R O P E R T I E S 	
	* 
	* --------------------------------------------------------------------------------
	*/
	//{

	//}
	/**-------------------------------------------------------------------------------
	* 
	*								P U B L I C 	
	* 
	* --------------------------------------------------------------------------------
	*/
	//{
		public function Scale()
		{
			super();
			
			
			init( );
			
		}
	//}
	
	/**-------------------------------------------------------------------------------
	* 
	*								P R I V A T E 	
	* 
	* --------------------------------------------------------------------------------
	*/	
	//{
		
		private function init():void
		{
			drawableWith();
			
			_runner = new Runner();
			minPosRunner -= _runner.width ;
			
			_runner.x = maxPosRunner;
			_runner.y = this.height - 2 - _runner.height;
			_runner.addEventListener(MouseEvent.MOUSE_DOWN, downMouse );
			
			this.addChild( _runner );
			
			
			
		}
		
		private function downMouse(e:MouseEvent):void 
		{
			_runner.removeEventListener(MouseEvent.MOUSE_DOWN, downMouse );
			this.stage.addEventListener(MouseEvent.MOUSE_UP, upMouse );
			this.stage.addEventListener(Event.MOUSE_LEAVE, upMouse );
			this.stage.addEventListener(MouseEvent.MOUSE_MOVE, moveMouse);

			_runner.startDrag( false, new Rectangle( maxPosRunner, _runner.y, minPosRunner - maxPosRunner, 1) );
			
		}
		
		private function moveMouse(e:MouseEvent):void 
		{
			_magniff = ( ( _runner.x - maxPosRunner ) / ( minPosRunner - maxPosRunner ) );
			this.dispatchEvent( new DataEvent( Scale.ON_MAGNIFF, false, false, _magniff + "" ) )
		}
		
		private function upMouse(e:MouseEvent):void 
		{
			this.stage.removeEventListener(MouseEvent.MOUSE_UP, upMouse );
			this.stage.removeEventListener(Event.MOUSE_LEAVE, upMouse );
			this.stage.removeEventListener(MouseEvent.MOUSE_MOVE, moveMouse);
			_runner.stopDrag();
			_runner.addEventListener(MouseEvent.MOUSE_DOWN, downMouse );
		}
		
		private function drawableWith():void 
		{
			DrawFrame( _WIDTH, 15, this );
			const scale:Shape = new Shape();
			
			drawScale( scale.graphics, 101 );
			this.addChild( scale );
			AlignCenter( scale );
			
			minPosRunner = scale.x + scale.width;
			maxPosRunner = scale.x;
			const plus:Shape = new Shape();
			drawPlus( plus.graphics, scale.x - 4 );
			this.addChild( plus );
			AlignCenter( plus );
			plus.x = this.width - plus.width;
			
			const minus:Shape = new Shape();
			drawMinus( minus.graphics, scale.x - 4 );
			this.addChild( minus );
			AlignCenter( minus );
			
			minus.x = 0;
			
			
		}
		
		private function drawMinus(graphics:Graphics, wdth:Number ):void 
		{
			graphics.lineStyle( 2, 0xA8A8DB, 1, false, LineScaleMode.NORMAL, CapsStyle.NONE );
			graphics.moveTo( 0, wdth / 2 );
			graphics.lineTo( wdth, wdth / 2 );
			graphics.lineStyle( 2, 0xA8A8DB, 0, false, LineScaleMode.NORMAL, CapsStyle.NONE );
			graphics.moveTo( wdth / 2, 0 );
			graphics.lineTo( wdth / 2, wdth );
			graphics.endFill();
		}
		
		private function drawPlus(graphics:Graphics, wdth:Number):void 
		{
			graphics.lineStyle( 2, 0xA8A8DB, 1, false, LineScaleMode.NORMAL, CapsStyle.NONE );
			graphics.moveTo( 0, wdth / 2 );
			graphics.lineTo( wdth, wdth / 2 );
			graphics.moveTo( wdth / 2, 0 );
			graphics.lineTo( wdth / 2, wdth );
			graphics.endFill();
		}
		
		private function drawScale( grph:Graphics,  wdth:int ):void 
		{
			const matrx:Matrix = new Matrix();
			const rad:Number = 90 * (  Math.PI / 180 );
			const hght:Number = 20;
			const hghtSlot:Number = 7;
			
			grph.clear();
			matrx.createGradientBox( wdth, hghtSlot, rad, 0, hght - hghtSlot );
			grph.beginGradientFill( GradientType.LINEAR, [ 0xFFFFFF, 0xA8A8DB, 0x222222, 0x222222, 0xA8A8DB, 0xFFFFFF], [ 1, 1, 1, 1, 1, 1 ], [ 0, 50, 100, 150, 200, 255 ], matrx );
			
			grph.drawRect( 0, hght - hghtSlot, wdth,  hghtSlot  );
			grph.beginFill( 0xA8A8DB );
			
			const frame:int = 2;
			const wPunct:Number = .5;
			var hPunct:Number;
			const countFrame:int = wdth / frame;
			const hulf:int = wdth / 2;
			const qarter:int = hulf / 2;
			const quaver:Number =  qarter / 2 ;
			

			for ( var i:int; i <= wdth; i += frame )
			{
				if ( ( i / hulf ) is int ) hPunct = 8;
				else if ( ( ( i  + 1 ) / qarter ) is int ) hPunct = 6;
				else if ( ( ( i + .5) / quaver ) is int || ( ( i + 1.5) / quaver ) is int  ) hPunct = 5;
				else hPunct = 4;
				
				grph.drawRect( i, hght - hghtSlot - .5 - hPunct, wPunct, hPunct );
			}
			
			grph.endFill();
		}
	
	
	//}

	}

}