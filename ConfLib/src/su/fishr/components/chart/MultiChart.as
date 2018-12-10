///********************************************************************
///* Copyright © 2012 fishr (fishr.flash@gmail.com)  
///********************************************************************
package su.fishr.components.chart 
{
	
	import flash.display.CapsStyle;
	import flash.display.LineScaleMode;
	import flash.display.Sprite;
	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	import su.fishr.components.chart.charts_area.SeriesField;
	import su.fishr.components.chart.gui.BtnAll;
	import su.fishr.components.chart.gui.scale.Scale;
	import su.fishr.display.DrawFrame;
	
   /**
	 * ...
	 * @playerversion          Flash 9
	 * @langversion            3.0
	 * @author                 fishr
	 * @created                20.07.2012 22:35
	 * @since                  20.07.2012 22:35
	 */
	
	public  class MultiChart extends Sprite
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
		public const RADIUS:int = 6;
		private const _TAGS:Array = new Array();
		private var _arrSeries:Array;
		private var _chartArea:Rectangle;
		private var _seriesField:SeriesField;
		private var _arrTags:Array;
		private var _rows:int;
		private var _mousePositionX:Number;
		private var _scale:Scale;
		private var _btnAll:BtnAll;

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
		public function MultiChart( wdth:int, hght:int, arrSeries:Array, rows:int = 10 )
		{
			super();
			
			DrawFrame( wdth, hght, this );
			_arrSeries = arrSeries;
			_rows = rows;
			
			if(stage)init()
			else this.addEventListener(Event.ADDED_TO_STAGE, init)
			
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
			
			_chartArea = new Rectangle( 70, 30, this.width - 80, this.height - 40 );
			_seriesField = new SeriesField( _chartArea.width, _chartArea.height, _arrSeries, RADIUS, _rows, this );
			_seriesField.addEventListener(MouseEvent.MOUSE_DOWN, mouseDawnField );
			_seriesField.nowWidth = _chartArea.width;
			
			_seriesField.x = _chartArea.x;
			_seriesField.y = _chartArea.y;
			_seriesField.scrollRect = new Rectangle( 0, 0, _chartArea.width, _chartArea.height );
			this.addChild( _seriesField );
			
			_arrTags = drawConture();
			
			createTags();
			
			_scale = new Scale();
			_scale.x = _chartArea.x + _chartArea.width - _scale.width;
			_scale.y = _chartArea.y - _scale.height - 5;
			this.addChild( _scale );
			
			_btnAll = new BtnAll();
			_btnAll.x = _scale.x - _btnAll.width - 10;
			_btnAll.y = _chartArea.y - _btnAll.height - 1;
			this.addChild( _btnAll );
			
			_btnAll.addEventListener(MouseEvent.CLICK, clickBtnAll );
			_scale.addEventListener(Scale.ON_MAGNIFF, onMagniff );
			this.addEventListener( ChrtEvent.SELECT_SERIES, selectSeries, true );
			
			
		}
		
		private function clickBtnAll( e:MouseEvent ):void
		{
			_btnAll.enable = false;
			_seriesField.onAll();
			
			const step:Number = ( 100 / ( _arrTags.length - 1 ) );
			for ( var i:int = 0; i < _TAGS.length; i++ )
			{
				_TAGS[ i ].text =  Math.ceil( ( ( i ) * step ) ) + "";
				_TAGS[ i ].x = _arrTags[ i ][ 0 ] - _TAGS[ i ].width - 5;
			}
		}
		
		private function onMagniff( e:DataEvent ):void 
		{
			
			_scale.removeEventListener(Scale.ON_MAGNIFF, onMagniff );
			
			
			
			/**
			 * Добавляем смещение точки на поле графиков находящейся в середине окна графиков
			 * чтобы удерживать её в середине окна.
			 * 
			 * 
			 */

			/// место в данный момент в середине окна
			const centerWindow:Number = _seriesField.scrollRect.x + ( _chartArea.width / 2 );
			
			const nowWidthSField:Number = _seriesField.magniffied( Number( e.data ) );
			
			const diff:Number = ( ( nowWidthSField / _seriesField.nowWidth ) );
			
			var nowX:Number = ( centerWindow * diff ) - ( _chartArea.width / 2 ) ;
	
			if ( nowX < 0 ) nowX = 0;
			if ( nowWidthSField - nowX < _chartArea.width ) nowX = nowWidthSField - _chartArea.width;
			
			
			
			_seriesField.scrollRect = new Rectangle( nowX,
													_seriesField.scrollRect.y,
													_seriesField.scrollRect.width,
													_seriesField.scrollRect.height );
														
			_seriesField.nowWidth = nowWidthSField;
			
			
			
			_scale.addEventListener(Scale.ON_MAGNIFF, onMagniff );
		
		}
	
		private function mouseDawnField(e:MouseEvent):void 
		{
			_seriesField.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDawnField );
			
			_mousePositionX = e.stageX;
			
			
			
			this.stage.addEventListener(MouseEvent.MOUSE_UP, upMouseStage );
			this.stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMovieStage );
			this.stage.addEventListener(Event.MOUSE_LEAVE, upMouseStage );
		}
		
		private function mouseMovieStage(e:MouseEvent):void 
		{
			
			const diff:Number = _mousePositionX - e.stageX;
			if ( _seriesField.scrollRect.x + diff <= 0 || 
						_seriesField.nowWidth - _seriesField.scrollRect.x - diff < _chartArea.width) return;
			_seriesField.scrollRect = new Rectangle(  _seriesField.scrollRect.x + diff, _seriesField.scrollRect.y, _seriesField.scrollRect.width, _seriesField.scrollRect.height );
			
			
			_mousePositionX = e.stageX;
		}
		
		private function upMouseStage(e:MouseEvent):void 
		{
			this.stage.removeEventListener(Event.MOUSE_LEAVE, upMouseStage );
			this.stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMovieStage );
			this.stage.removeEventListener(MouseEvent.MOUSE_UP, upMouseStage );
			_seriesField.addEventListener(MouseEvent.MOUSE_DOWN, mouseDawnField );
		}
		
		private function selectSeries(e:ChrtEvent ):void 
		{
			
			_btnAll.enable = true;
			const stepVert:Number = e.data.stepY;
			
			for (var i:int = 0; i < _arrTags.length; i++) 
			{
				const value:int = ( Math.ceil( ( _chartArea.y + _chartArea.height - RADIUS * 2  ) - ( _arrTags[ i ][ 1 ] ) ) / stepVert )  + Math.ceil( e.data.minValue);
				
				_TAGS[ i ].text = value;
				_TAGS[ i ].x = _arrTags[ i ][ 0 ] - _TAGS[ i ].width - 5;
								
			}
		}
		
		private function createTags():void 
		{
			
			const step:Number = ( 100 / ( _arrTags.length - 1 ) );
			
			for ( var i:int = 0; i < _arrTags.length; i++ )
			{
				const tf:TextField = new TextField();
				tf.autoSize = TextFieldAutoSize.LEFT;
				tf.defaultTextFormat = new TextFormat( null, null, 0xAAAADD, true );
				tf.text =  Math.ceil( ( ( i ) * step ) ) + "";
				tf.x = _arrTags[ i ][ 0 ] - tf.width - 5;
				tf.y = _arrTags[ i ][ 1 ] - ( tf.height / 2 );
				
				_TAGS.push( tf );
				this.addChild( tf );
			}
			
		}
		
		private function drawConture():Array
		{
			const thickness:Number = 3;
			const arrTags:Array = new Array();
			const cellSize:int = _chartArea.height / _rows;
			
			this.graphics.lineStyle( thickness / 3, 0xAAAADD, 1, false );
			this.graphics.moveTo( _chartArea.x - ( thickness / 2 ), _chartArea.y - (thickness / 2 ) );
			this.graphics.lineTo( _chartArea.width + _chartArea.x + (thickness / 2 ), _chartArea.y - (thickness / 2 ) );
			this.graphics.lineTo( _chartArea.width + _chartArea.x + (thickness / 2 ), _chartArea.height + _chartArea.y + (thickness / 2 ) );
			this.graphics.lineStyle( thickness, 0xAAAADD, 1, false, LineScaleMode.NORMAL, CapsStyle.NONE );
			this.graphics.lineTo( _chartArea.x - (thickness / 2 ), _chartArea.height + _chartArea.y + (thickness / 2 ));
			this.graphics.lineTo( _chartArea.x - ( thickness / 2 ), _chartArea.y - (thickness / 2 ) );
			
			var j:uint = ( _chartArea.height / cellSize ) + 1;
			while ( j-- )
			{
				this.graphics.moveTo( _chartArea.x - ( thickness / 2 ), _chartArea.y + ( cellSize * ( j ) ) );
				this.graphics.lineTo( _chartArea.x - 3 - ( thickness / 2 ), _chartArea.y + ( cellSize * ( j  ) ) );
				
				arrTags.push( [ _chartArea.x - ( thickness / 2 ), _chartArea.y + ( cellSize * ( j ) ) ] );
				
			}
			
			return arrTags;
		}
	
	
	//}

	}

}