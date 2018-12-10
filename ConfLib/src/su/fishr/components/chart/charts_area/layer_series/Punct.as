///********************************************************************
///* Copyright © 2012 fishr (fishr.flash@gmail.com)  
///********************************************************************
package su.fishr.components.chart.charts_area.layer_series 
{
	
	import flash.display.DisplayObjectContainer;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Rectangle;
	import flash.events.Event;
	import flash.utils.Timer;
	import su.fishr.components.chart.ChrtEvent
	import su.fishr.display.SimpleTTTip;

   /**
	 *  Является самой элементарной точкой графика.
	 * Отражает местоположение и легенду отдельно взятого
	 * значения из ряда значений.
	 * 
	 * @playerversion          Flash 9
	 * @langversion            3.0
	 * @author                 fishr
	 * @created                19.07.2012 23:20
	 * @since                  19.07.2012 23:20
	 */
	
	internal class Punct extends Sprite
	{
	
	/**-------------------------------------------------------------------------------
	* 
	*	   						V A R I A B L E ' S 	
	* 
	* --------------------------------------------------------------------------------
	*/
	//{
	    static private const AUTHOR:String = "fishr (fishr.flash@gmail.com)";	
		private const _TIMER_ON:Timer = new Timer( 300 );
		private var _color:uint;
		private var _tttipe:SimpleTTTip;
		private var _label:String;
		private var _radius:int;
		private var _container:DisplayObjectContainer;
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
		public function Punct( label:String, radius:int, container:DisplayObjectContainer, color:uint = 0x000000 )
		{
			super();
			_radius = radius;
			_color = color;
			_label = label;
			_container = container;
			this.addEventListener(Event.ADDED_TO_STAGE, init );

		}
	//}
	
	/**-------------------------------------------------------------------------------
	* 
	*								P R I V A T E 	
	* 
	* --------------------------------------------------------------------------------
	*/	
	//{
		
		private function init( evt:Event  ):void
		{
			this.removeEventListener(Event.ADDED_TO_STAGE, init );
			this.buttonMode = true;
			this.mouseChildren = false;
			
			_tttipe = new SimpleTTTip( this, _container, _label );

			drawPunct( _radius );
			
			
			this.addEventListener(MouseEvent.MOUSE_OVER, mouseOver );
		}
		
		
		
		
		
		private function mouseOver(e:MouseEvent):void 
		{
			this.removeEventListener(MouseEvent.MOUSE_OVER, mouseOver );
			this.addEventListener(MouseEvent.MOUSE_OUT, mouseOut );
			
			_TIMER_ON.addEventListener(TimerEvent.TIMER, onTimerOn);
			
			_TIMER_ON.start();
			onExpansion( true );
			
		}
		
		private function onTimerOn(e:TimerEvent):void 
		{
			_TIMER_ON.removeEventListener(TimerEvent.TIMER, onTimerOn);
			this.dispatchEvent( new ChrtEvent( ChrtEvent.OVER_PUNCT ) );
			_TIMER_ON.reset();
		}
		
		private function mouseOut(e:MouseEvent):void 
		{
			this.addEventListener(MouseEvent.MOUSE_OVER, mouseOver );
			this.removeEventListener(MouseEvent.MOUSE_OUT, mouseOut );
			if ( _TIMER_ON.running )
			{
				_TIMER_ON.reset();
				_TIMER_ON.removeEventListener(TimerEvent.TIMER, onTimerOn);
			}
			onExpansion()
		}
		
		private function onExpansion( over:Boolean = false ):void
		{
			const prev:Rectangle = this.getBounds( this );
			drawPunct( over?_radius * 1.5:_radius );
			const second:Rectangle = this.getBounds( this );
		}
		
		private function drawPunct(  rad:Number ):void
		{
			this.graphics.clear();
			this.graphics.beginFill( _color );
			this.graphics.drawCircle( 0, 0, rad );
			this.graphics.lineStyle( _radius * .2, _color, 1, false );
			this.graphics.beginFill( 0xFFFFFF, 1 );
			this.graphics.drawCircle( 0 , 0 , rad * .6 );
			this.graphics.endFill();
		}
	
	
	//}

	}

}