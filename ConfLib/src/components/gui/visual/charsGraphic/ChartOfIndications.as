package components.gui.visual.charsGraphic 
{
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	
	import components.gui.visual.charsGraphic.DiapasonAdapterHor;
	import components.gui.visual.charsGraphic.components.BaseLine;
	import components.gui.visual.charsGraphic.components.CellularField;
	import components.gui.visual.charsGraphic.components.HBarLine;
	import components.gui.visual.charsGraphic.components.HLine;
	
	/**
	 * ...
	 * @author  
	 */
	public class ChartOfIndications extends Sprite 
	{
		
		private var _hLines:Vector.<HLine> = new Vector.<HLine>();
		private var _mainSizes:Rectangle;
		private var _adapt:DiapasonAdapterHor;
		
		/**
		 * т.к. горизонтальная ось не является шкалой времени, а шагов-изменений
		 * нет смысла рисовать одинаковые данные, рисуем только изменения
		 * ( годится только когда у нас только один график такого типа )
		 */
		public function get lastBarY():Number
		{
			return _lastBarY;
		}
		
		private var _callback:Function;
		private var _hBLines:Vector.<HBarLine> = new Vector.<HBarLine>;
		private var _lastBarY:Number = 0;
		private var _callDragRect:Function;
		public function ChartOfIndications() 
		{
			super();
			
		}
		
		public function initField( relMin:Number
								   , relMax:Number
									 , legend:Array
									   , rect:Rectangle = null
										 , callDragRect:Function = null
										   , callback:Function = null):void
		{
			if ( !rect ) rect = new Rectangle( 0, 0, 600, 400 );
			
			
			_mainSizes = rect;
			_callback = callback;
			_adapt = new DiapasonAdapterHor( relMin, relMax, _mainSizes );
			_callDragRect = callDragRect;
			this.addChild( new CellularField( rect, legend, _adapt ) );
			
			
		}
		
		public function createHLine( name:String
									 , vpos:Number
									   , color:uint
										 , dragable:Boolean = false
										   , lbl:String = ""
											 , legend:String = ""
											   , valign:String = "valignTop"
												 
		):void
		{
			if( getLineOfName( name ) )
									return;
			
			var line:HLine = new HLine( _mainSizes.width, color, dragable, valign );
			line.y = _adapt.getVPixSize( vpos );
			line.name = name;
			_hLines.push( line );
			this.addChild( line );
			line.setCustomInfo( lbl, legend );
			if ( dragable )
			{
				line.dragRect = new Rectangle( 0, 0, 0, _mainSizes.height );
				line.addEventListener( ChartEvent.DRAG_LINE, dragLine );
				line.addEventListener( ChartEvent.LINE_ONM, changeLine );
				line.addEventListener( ChartEvent.LINE_UPM, changeLine );
				
			}
			
			changeValign( line );
		}
		
		public function createHBarLine( name:String, color:uint, drawStep:int = 1 ):void 
		{
			// если линия с таким именем уже есть ничео 
			// создано не будет
			if( getBLineOfName( name ) )
										return;
			if ( !_hBLines ) _hBLines = new Vector.<HBarLine>
			const bLine:HBarLine = new HBarLine(name
				,_mainSizes
				, _adapt
				, color 
				, drawStep
			)
			_hBLines.push( bLine );
			this.addChildAt( bLine, 0 );
			
			
		}
		
		public function removeHBarLine( name:String ):void 
		{
			if( !_hBLines || !_hBLines.length ) 
											return;
			var line:HBarLine;
			
			const len:int = _hBLines.length;
			for ( var i:int = 0; i < len; i++ )
			{
				
				if ( _hBLines[ i ].name == name )
				{
					line = _hBLines.splice( i, 1 )[ 0 ];
					break;
				}
			}
			
			
			
			if ( line  )
			{
				
				line.destruct();
				line.parent.removeChild( line );
				line = null;
			}
			
			
		}
		
		public function setBar( name:String, rel:Number, lbl:String = ""):void 
		{
			
			
			_lastBarY = rel;
			
			var line:HBarLine = null;
			const len:int = _hBLines.length;
			for ( var i:int = 0; i < len; i++ )
			{
				
				if ( _hBLines[ i ].name == name )
				{
					line = _hBLines[ i ];
					break;
				}
			}
			
			
			
			if ( line  )
			{
				var py:Number = _adapt.getVPixSize( rel );
				if ( py > _mainSizes.height ) py = _mainSizes.height;
				if ( py < 0 ) py = 0;
				line.setYPos( py , lbl );
				
				
				
				
				
			}
		}
		
		/**
		 *  *если линия по имени не будет найдена ничего на графике не изменится
		 * @param	name
		 * @param	yp
		 */
		public function setLinePos(name:String, yp:Number, lbl:String, legend:String = "" ):void
		{
			var line:HLine = getLineOfName( name );
			if ( line )
			{
				
				line.setYPos( _adapt.getVPixSize( yp ) );
				line.setCustomInfo( lbl, legend );
			}
			
			changeValign( line );
		}
		
		public function setLineInfo(name:String, lbl:String, legend:String):void 
		{
			var line:HLine = getLineOfName( name );
			
			
			
			if ( line )
			{
				
				
				line.setCustomInfo( lbl, legend );
			}
			
			changeValign( line );
		}
		
		public function getRealYOfLine( name:String ):Number
		{
			const line:HLine = getLineOfName( name );
			
			if ( line ) return line.y;
			else return NaN;
			
		}
		
		public function getRealSize( rel:Number ):Number
		{
			return _adapt.getHPixSize( rel );
		}
		public function getRealPosition( rel:Number ):Number
		{
			return _adapt.getVPixSize( rel );
		}
		
		public function setDragForLine( name:String, dragRect:Rectangle ):void
		{
			const line:HLine = getLineOfName( name );
			
			
			if ( line )
				line.dragRect = dragRect;
		}
		
		
		protected function changeLine(event:ChartEvent):void
		{
			
			
			var len:int = _hLines.length;
			for (var i:int = 0; i < len; i++) {
				
				if( _hLines[ i ].name != event.data.name )
				{
					if( event.type == ChartEvent.LINE_ONM )
						_hLines[ i ].startSilent();
					else
						_hLines[ i ].stopSilent();
					
				}
				else if( event.type == ChartEvent.LINE_ONM && _callDragRect != null )
				{
					
					_hLines[ i ].dragRect = _callDragRect( _hLines[ i ].name, _hLines[ i ].dragRect );
				}
				
				
			}
		}
		
		
		
		
		
		protected function dragLine(e:ChartEvent):void 
		{
			
			
			const hLine:HLine = e.currentTarget as HLine;
			
			changeValign( hLine )
			//if ( Number( v ) > 8 )
			//{
			//
			//HLine( e.currentTarget ).setYPos( _adapt.getPixSize( 8 ) );
			//v = "8";
			//}
			if ( _callback != null ) 
			{
				var v:String = _adapt.getRelative( e.data.ypos ) + "";
				_callback( hLine.name, v );
			}
			
			//HLine( e.currentTarget ).setCustomInfo( v + "B" );
		}
		
		private function changeValign( hLine:HLine ):void
		{
			
			if ( hLine.y + hLine.height > _mainSizes.height ) hLine.replaceValign( HLine.VALIGN_TOP )
			else if ( hLine.y - hLine.height <= 0 ) hLine.replaceValign( HLine.VALIGN_BOTTOM )
			else hLine.replaceValign( "" );
		}
		
		private function getLineOfName( name:String ):HLine
		{
			if( !_hLines ) return null;
			
			var line:HLine = null;
			const len:int = _hLines.length;
			for ( var i:int = 0; i < len; i++ )
			{
				
				if ( _hLines[ i ].name == name )
				{
					line = _hLines[ i ];
					break;
				}
			}
			
			return line;
			
			
		}
		
		private function getBLineOfName( name:String ):HBarLine
		{
			if( !_hBLines ) return null;
			
			var line:HBarLine = null;
			const len:int = _hBLines.length;
			for ( var i:int = 0; i < len; i++ )
			{
				
				if ( _hBLines[ i ].name == name )
				{
					line = _hBLines[ i ];
					break;
				}
			}
			
			return line;
			
			
		}
		
	}
	
}