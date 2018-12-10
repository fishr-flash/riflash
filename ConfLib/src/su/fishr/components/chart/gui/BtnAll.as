///********************************************************************
///* Copyright © 2012 fishr (fishr.flash@gmail.com)  
///********************************************************************
package su.fishr.components.chart.gui 
{
	
	import flash.display.GradientType;
	import flash.display.Graphics;
	import flash.display.InterpolationMethod;
	import flash.display.Shape;
	import flash.display.SpreadMethod;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import su.fishr.display.DrawFrame;
	
   /**
	 * ...
	 * @playerversion          Flash 9
	 * @langversion            3.0
	 * @author                 fishr
	 * @created                24.07.2012 13:26
	 * @since                  24.07.2012 13:26
	 */
	
	public  class BtnAll extends Sprite
	{
	
	/**-------------------------------------------------------------------------------
	* 
	*	   						V A R I A B L E ' S 	
	* 
	* --------------------------------------------------------------------------------
	*/
	//{
	    static private const AUTHOR:String = "fishr (fishr.flash@gmail.com)";	
		private var _tf:TextField;
		private var _enableShape:Shape;
		
	//}
	
	/**-------------------------------------------------------------------------------
	* 
	*	 						P R O P E R T I E S 	
	* 
	* --------------------------------------------------------------------------------
	*/
	//{
		public function get enable():Boolean
		{
			return this.buttonMode;
		}
		
		public function set enable( flag:Boolean ):void
		{
			this.buttonMode = this.mouseEnabled = flag;
			_enableShape.alpha = flag?0:0.5;
		}
	//}
	/**-------------------------------------------------------------------------------
	* 
	*								P U B L I C 	
	* 
	* --------------------------------------------------------------------------------
	*/
	//{
		public function BtnAll()
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
			this.buttonMode = false;
			this.mouseChildren = false;
			this.mouseEnabled = false;
			
			_tf = new TextField();
			_tf.autoSize = TextFieldAutoSize.CENTER;
			_tf.type = TextFieldType.DYNAMIC;
			_tf.defaultTextFormat = new TextFormat( null, null, 0xA8A8DB, true );
			_tf.text = "All";
			this.addChild( _tf );

			drawMe( this.graphics );
			_tf.x = 0;
			
			_enableShape = new Shape();
			drawEnbShape( _enableShape.graphics );
			_enableShape.x = _enableShape.y = - 1;
			_enableShape.alpha = .5;
			this.addChild( _enableShape );
			
		}
		
		private function drawMe(graphics:Graphics):void 
		{
			const matrixFill:Matrix = new Matrix();
			matrixFill.createGradientBox( this.width * 1.5, this.height * 1.5, Math.PI / 2 );
			const matrixStroke:Matrix = new Matrix();
			matrixStroke.createGradientBox( this.width / 2, this.height / 2 );
			graphics.beginGradientFill( GradientType.LINEAR, [ 0xFFFFFF, 0xA8A8DB ], [ 1, 1 ], [ 0x55, 0xFF], matrixFill );
			graphics.lineStyle( 1, 0x999999, 0 );
			graphics.lineGradientStyle( GradientType.RADIAL, [ 0xAAAAAA,  0xA8A8DB ], [ 1, 1], [ 0x00, 0xFF], matrixStroke, SpreadMethod.REFLECT, InterpolationMethod.RGB, 0);
			graphics.drawCircle( this.width / 2, this.height / 2, this.height / 1.7 );
			graphics.endFill();
			
		}
		
		private function drawEnbShape( graphics:Graphics ):void
		{
			graphics.clear();
			graphics.beginFill( 0xFFFFFF );
			graphics.drawRect( 0, 0, this.width + 2, this.height + 2 );
			graphics.endFill();
		}
	
	
	//}

	}

}