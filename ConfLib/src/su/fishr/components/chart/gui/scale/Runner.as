///********************************************************************
///* Copyright © 2012 fishr (fishr.flash@gmail.com)  
///********************************************************************
package su.fishr.components.chart.gui.scale 
{
	
	import flash.display.GradientType;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.filters.DropShadowFilter;
	import flash.geom.Matrix;
	
   /**
	 * ...
	 * @playerversion          Flash 9
	 * @langversion            3.0
	 * @author                 fishr
	 * @created                23.07.2012 19:03
	 * @since                  23.07.2012 19:03
	 */
	
	public  class Runner extends Sprite
	{
	
	/**-------------------------------------------------------------------------------
	* 
	*	   						V A R I A B L E ' S 	
	* 
	* --------------------------------------------------------------------------------
	*/
	//{
	    static private const AUTHOR:String = "fishr (fishr.flash@gmail.com)";	
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
		public function Runner()
		{
			super();
			
			init();
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
			drawRunner();
			
			this.buttonMode = true;

		}
		
		
		
		private function drawRunner():void
		{
			const runner:Shape = new Shape();
			graphicsFront( runner.graphics );
			
			const backRunner:Shape = new Shape();
			drawBackRunner( backRunner.graphics );
			
			runner.x = 15;
			runner.y = 5;
			
			const simbRunner:Sprite = new Sprite();
			simbRunner.addChild( backRunner );
			simbRunner.addChild( runner );
			
			simbRunner.height = 15;
			simbRunner.scaleX = simbRunner.scaleY;
			
			var dropShad:DropShadowFilter = new DropShadowFilter( 2, 225, 0x333333, .7, 3, 3, 1);
			simbRunner.filters = [ dropShad ];
			
			this.addChild( simbRunner );
		}
		
		private function graphicsFront(graphics:Graphics):void 
		{
			const matrixFill:Matrix = new Matrix();
			matrixFill.createGradientBox( 100, 135, Math.PI / 2 );
			graphics.lineStyle( 1, 0x333333, 0 );
			graphics.beginGradientFill( GradientType.LINEAR, [ 0xA8A8DB, 0x333333 ], [ 1, .9 ], [ 0xCC, 0xFF ], matrixFill );
			graphics.moveTo( 25, 35 );
			graphics.lineTo( 60, 0 );
			graphics.lineTo( 100, 35 );
			graphics.lineTo( 100, 70 );
			curveThrough3Pts( graphics, 100, 69, 98, 108, 78, 135 );
			graphics.lineTo( 0, 135 );
			curveThrough3Pts( graphics, 0, 135, 23, 108, 25, 70 );
			graphics.lineTo( 25, 35 );
			graphics.endFill();
		}
		
		private function drawBackRunner(graphics:Graphics):void 
		{
			const matrixFill:Matrix = new Matrix();
			matrixFill.createGradientBox( 100, 135 );
			graphics.lineStyle( 1, 0x333333, 0 );
			graphics.beginGradientFill( GradientType.LINEAR, [  0x333333, 0xA8A8DB ], [ 1, .9 ], [ 0x22, 0xAA ], matrixFill );
			graphics.moveTo( 25, 35 );
			graphics.lineTo( 60, 0 );
			graphics.lineTo( 76, 6 );
			graphics.lineTo( 100, 35 );
			graphics.lineTo( 100, 70 );
			curveThrough3Pts( graphics, 100, 69, 98, 108, 78, 135 );
			graphics.lineTo( 14, 140 );
			graphics.lineTo( 0, 135 );
			curveThrough3Pts( graphics, 0, 135, 23, 108, 25, 70 );
			graphics.lineTo( 25, 35 );
			graphics.endFill();
		}
		
		
		
		// Адаптированный метод drawCurve3Pts( ) Роберта Пеннера (Robert Penner) 
		public function curveThrough3Pts (g:Graphics,startX:Number, startY:Number, 
												throughX:Number, throughY:Number, 
															endX:Number, endY:Number):void
		{ 
			var controlX:Number = ( 2 * throughX) - .5 * (startX + endX); 
			var controlY:Number = ( 2 * throughY) - .5 * (startY + endY); 
			//g.moveTo(startX, startY); 
			g.curveTo(controlX, controlY, endX, endY); 
		} 
	
	
	//}

	}

}