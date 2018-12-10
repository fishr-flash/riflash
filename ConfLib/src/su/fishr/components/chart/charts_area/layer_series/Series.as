///********************************************************************
///* Copyright © 2012 fishr (fishr.flash@gmail.com)  
///********************************************************************
package su.fishr.components.chart.charts_area.layer_series 
{
	
	import flash.display.CapsStyle;
	import flash.display.DisplayObjectContainer;
	import flash.display.GradientType;
	import flash.display.Graphics;
	import flash.display.LineScaleMode;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	import su.fishr.display.DrawFrame;
	import su.fishr.components.chart.ChrtEvent;
	
   /**
	 *  Интерактивная линия графика.
	 * Размещает в себе объекты Punct
	 * соединяет их линиями. Перерисовывается
	 * при демасштабировании.
	 * 
	 * @playerversion          Flash 9
	 * @langversion            3.0
	 * @author                 fishr
	 * @created                20.07.2012 5:30
	 * @since                  20.07.2012 5:30
	 */
	
	public  class Series extends Sprite
	{
		[Event (name="overPunct", type="su.fishr.components.chart.ChrtEvent")];
	/**-------------------------------------------------------------------------------
	* 
	*	   						V A R I A B L E ' S 	
	* 
	* --------------------------------------------------------------------------------
	*/
	//{
	    static private const AUTHOR:String = "fishr (fishr.flash@gmail.com)";
		public var arrPuncts:Array;
		private var _wdth:int;
		private var _hght:int;
		private var _series:Object;
		private var _stepY:Number;
		private var _stepX:Number;
		private var _radius:int;
		private var _minValue:Number;
		private var _container:DisplayObjectContainer;
		
	//}
	
	/**-------------------------------------------------------------------------------
	* 
	*	 						P R O P E R T I E S 	
	* 
	* --------------------------------------------------------------------------------
	*/
	//{
		public function get stepY():Number 
		{
			return _stepY;
		}
		
		public function get minValue():Number 
		{
			return _minValue;
		}
	//}
	/**-------------------------------------------------------------------------------
	* 
	*								P U B L I C 	
	* 
	* --------------------------------------------------------------------------------
	*/
	//{
	
		/**
		 *  Конструктор. Определяет первичную визуализацию
		 * серии данных в виде пунктов-точек соединенных линиями.
		 * Объект класса может в последствии динамически демасштабироваться
		 * см. <a href="#setSize" >setSize</a>.
		 * 
		 * @param	wdth первоначальная ширина
		 * @param	hght первоначальная высота
		 * @param	series объект данных содержащих необходимые сведения для
		 * визуализации отдельного чарта. Объект имеет следующую структуру:
		 * <ul>
		 * 	<li> name - имя данных которое будет использовано в поясняющих вспл. окнах </li>
		 * 	<li> color - цвет виз.элементов отображающих данный чарт</li>
		 * 	<li> dates - необязательный параметр, массив дат ( объекты Date ) также используется 
		 * 		в поясняющих надписях ( ось x данных строится не по датам, а по кол-ву данных) </li>
		 * 	<li> arrValues - непосредственно массив данных в формате Number на основе которого будет
		 *      строится кривая чарта</li>
		 * </ul>
		 */
		public function Series( wdth:int, hght:int, series:Object, radius:int, container:DisplayObjectContainer )
		{
			super();
			_wdth = wdth;
			_hght = hght;
			_series = series;
			_radius = radius;
			_container = container;

			this.addEventListener(Event.ADDED_TO_STAGE, init)
			
		}
		
		/**
		 *  Выполняет динамическое демасштабирование чарта
		 * по полученным аргументам вызова.
		 * 
		 * @param	wdth новая ширина поля отведенного под чарт
		 * @param	hght новая высота поля отведенного под визуализацию чарта
		 */
		public function setSize( wdth:int = 0, hght:int = 0 ):void
		{
			while ( this.numChildren ) this.removeChildAt( 0 );
			this.graphics.clear();
			DrawFrame( wdth || _wdth, hght || _hght, this );
			
			selectStep();
			
			drawChart();

		}
		
		
	//}
	
	/**-------------------------------------------------------------------------------
	* 
	*								P R I V A T E 	
	* 
	* --------------------------------------------------------------------------------
	*/	
	//{
		
		private function init(e:Event = null):void
		{
			this.removeEventListener(Event.ADDED_TO_STAGE, init);
			
			
			setSize();
		}
		
		private function selectStep():void
		{
			const arr:Array = _series.arrValues.slice();
			arr.sort( Array.NUMERIC );
			
			_minValue = arr[ 0 ] === arr[ arr.length - 1 ]?arr[ 0 ] / 2:arr[ 0 ];
			var maxValue:Number = arr[ 0 ] === arr[ arr.length - 1 ]?arr[ 0 ] * 2:arr[ arr.length - 1 ];
			
			if ( arr[ 0 ] + arr[ arr.length - 1 ] == 0 )
			{
				maxValue = 10;
				_minValue = 0;
			}

			_stepY =( _hght - ( _radius * 4 ) ) / ( maxValue - _minValue );
			_stepX = this.width / ( arr.length );
		}
		
		private function drawChart():void 
		{
			arrPuncts = new Array();
			
			var i:uint = _series.arrValues.length;
			while( i-- )
			{
				const label:String = _series.name + "\r " + _series.date[ i ] + " \r " + _series.arrValues[ i ];
				const punct:Punct = new Punct( label, _radius, _container, _series.color );
				punct.x = _stepX * (i + .3 );
				punct.y = ( _hght - _radius * 2 ) - ( _stepY * ( _series.arrValues[ i ] - _minValue ) );
				
				arrPuncts.push( punct );
				
				this.addChild( punct );
				
				if ( i < _series.arrValues.length - 1 ) drawLines( arrPuncts[ _series.arrValues.length - i - 1 ], arrPuncts[ _series.arrValues.length - i - 2 ] );
			}
		}
		
		private function drawLines( punct1:Punct, punct2:Punct):void 
		{
	
			this.graphics.lineStyle( 5, _series.color, 1, false, LineScaleMode.NORMAL, CapsStyle.NONE );
			
			this.graphics.moveTo( punct1.x, punct1.y );
			this.graphics.lineTo( punct2.x, punct2.y );
			this.graphics.endFill();
			
		}
		
		
		
	
	
	//}

	}

}