///********************************************************************
///* Copyright © 2012 fishr (fishr.flash@gmail.com)  
///********************************************************************
package su.fishr.components.chart.charts_area 
{
	
	import flash.display.DisplayObjectContainer;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.Graphics;
	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import su.fishr.components.chart.ChrtEvent;
	import su.fishr.components.chart.charts_area.layer_series.Series
	import su.fishr.display.DrawFrame;
	
   /**
	 *  Контейнер линий графика.
	 * Задает доступные размеры для рисования
	 * линий для экземпляров Series().
	 * Слушает события наведения мыши на пункты
	 * для перемещения активного Series() на
	 * передний план.
	 * 
	 * @playerversion          Flash 9
	 * @langversion            3.0
	 * @author                 fishr
	 * @created                20.07.2012 18:28
	 * @since                  20.07.2012 18:28
	 */
	
	public  class SeriesField extends Sprite
	{
		[Event (name="selectSeries", type="su.fishr.components.chart.ChrtEvent")];
	/**-------------------------------------------------------------------------------
	* 
	*	   						V A R I A B L E ' S 	
	* 
	* --------------------------------------------------------------------------------
	*/
	//{
	    static private const AUTHOR:String = "fishr (fishr.flash@gmail.com)";	
		private var _maxPunctScreen:int = 5;
		private var _maxWidthScreen:int;
		private var _arrLines:Array;
		private var _shapeHidden:Shape = new Shape();
		private var _flagAlphaCells:Boolean = true;
		private var _rows:int;
		private var _normalWidth:int;
		private var _nowWidth:Number;
	//}
	
	/**-------------------------------------------------------------------------------
	* 
	*	 						P R O P E R T I E S 	
	* 
	* --------------------------------------------------------------------------------
	*/
	//{

		public function get maxPunctScreen():int 
		{
			return _maxPunctScreen;
		}
		
		public function set maxPunctScreen(value:int):void 
		{
			_maxPunctScreen = value;
		}
		
		public function get maxWidthScreen():int 
		{
			return _maxWidthScreen;
		}
		
		public function get nowWidth():Number
		{
			return _nowWidth;
		}
		
		public function set nowWidth(value:Number):void 
		{
			_nowWidth = value;
		}
		

		
	//}
	/**-------------------------------------------------------------------------------
	* 
	*								P U B L I C 	
	* 
	* --------------------------------------------------------------------------------
	*/
	//{
		public function SeriesField( wdth:int, hght:int, arrSeries:Array, radius:int, rows:int, container:DisplayObjectContainer )
		{
			super();
			
			init( wdth, hght, arrSeries, radius, rows, container );
		}
		
		public function magniffied( degree:Number ):Number
		{
			var wdth:Number = _normalWidth + ( _maxWidthScreen - _normalWidth ) * degree;
			resizeArea( wdth );
			
			return wdth;
		}
		
		public function onAll():void
		{
			_flagAlphaCells = true;
			drawField( _nowWidth, this.height );
			_shapeHidden.alpha = .1;
			this.addChild( _shapeHidden );
		}
	//}
	
	/**-------------------------------------------------------------------------------
	* 
	*								P R I V A T E 	
	* 
	* --------------------------------------------------------------------------------
	*/	
	//{
		
		private function init( wdth:int, hght:int, arrSeries:Array, radius:int, rows:int, container:DisplayObjectContainer ):void
		{
			_normalWidth = wdth;
			_rows = rows;
			drawField( wdth, hght );
			drawShapeMask( _shapeHidden.graphics, wdth );
			_shapeHidden.cacheAsBitmap = true;
			
			
			_arrLines = new Array();
			
			///Определяем макс. ширину в развернутом состоянии
			var _maxPuncts:int = 0;
			for each( var series:Object in arrSeries )
			{
				if ( series.arrValues.length > _maxPuncts ) _maxPuncts = series.arrValues.length;
				
				const lineSeries:Series = new Series( wdth * .95, hght, series, radius, container );
				_arrLines.push( lineSeries );
				lineSeries.addEventListener( ChrtEvent.OVER_PUNCT, selectLineSeries, true );
				this.addChild( lineSeries );
				
			}
			
			_shapeHidden.alpha = .01;
			this.addChild( _shapeHidden );
			_maxWidthScreen = wdth * ( _maxPuncts / _maxPunctScreen );
			if ( _maxWidthScreen < wdth ) _maxWidthScreen = wdth;
			
			
			
			
		}
		
		private function resizeArea( nowWidth:Number ):void 
		{
			
			drawField( nowWidth, this.height );
			drawShapeMask( _shapeHidden.graphics, nowWidth );
			
			for each (var item:Series in _arrLines ) 
			{
				item.setSize( nowWidth * .9, this.height );
			}
		}
		
		private function selectLineSeries(e:ChrtEvent):void 
		{
			
			const lineSeries:Series = e.currentTarget as Series;
			
			
			var i:uint = _arrLines.length;
			while( i-- )
			{
				if ( _arrLines[ i ] === lineSeries )
				{
					const dataPunct:Object = { stepY: lineSeries.stepY, minValue: lineSeries.minValue };
					this.dispatchEvent( new ChrtEvent( ChrtEvent.SELECT_SERIES, false, false, dataPunct ));
				}
			}
			
			if ( _flagAlphaCells )
			{
				_flagAlphaCells = false;
				drawField( _nowWidth, this.height );
			}
			_shapeHidden.alpha = 1;
			this.addChild( _shapeHidden );
			this.addChild( lineSeries );
			
			
		}
		
		private function drawField( wdth:int, hght:int ):void 
		{
			this.graphics.clear();
			DrawFrame( wdth, hght, this );
			
			const cellSize:Number = hght / _rows;

			this.graphics.lineStyle( .5, _flagAlphaCells?0xDDDDFF:0x6666AA, _flagAlphaCells?.6:1 , true );
			
			const wCellSize:int = cellSize * 2.5;
			var i:uint = wdth / wCellSize;
			
			do
			{
				this.graphics.moveTo( wCellSize * i, 0 );
				this.graphics.lineTo( wCellSize * i, hght );
			}
			while ( i-- )
			
			this.graphics.moveTo( wdth, 0 );
			this.graphics.lineTo( wdth, hght );
			
			var j:uint = Math.ceil( hght / cellSize );
			while ( --j )
			{
				this.graphics.moveTo( 0, cellSize * j );
				this.graphics.lineTo( wdth, cellSize * j );
			}
			
			this.graphics.moveTo( 0, hght );
			this.graphics.lineTo( wdth, hght );
			
			this.graphics.endFill();
			
			
			
		}
		
		private function drawShapeMask( graphics:Graphics, nowWidth:int ):void
		{
			graphics.clear();
			graphics.beginFill( 0xFFFFFF, .8 );
			graphics.drawRect( 0, 0, nowWidth + 2, this.height + 2 );
			graphics.endFill();
		}
	
	
	//}

	}

}