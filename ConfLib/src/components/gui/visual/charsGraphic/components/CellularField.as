package components.gui.visual.charsGraphic.components 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	import components.gui.visual.charsGraphic.DiapasonAdapterHor;
	
	public class CellularField extends Sprite{
		
		private const _WIDTH_CELL:uint = 20;
		private const _HEIGHT_CELL:uint = 10;
		private const _LEDGE_LINE:uint = 5;
		private const _COLOR_LINE:uint = 0xBBBBBB;
		private const _MAIN_COLOR:uint = 0x999999;
		
		private var _mainTwinkess:Number = 2;
		private var _targetW:uint;
		private var _targetH:uint;
		private var _adapt:DiapasonAdapterHor;
		
		
		
		public function CellularField( rect:Rectangle, legend:Array, adapt:DiapasonAdapterHor )
		{
			
			super();
			_adapt = adapt;
			_targetW = rect.width;
			_targetH = rect.height;
			drawFrame();
			createCell( legend );
			
			
		}
		
		
		
		private function drawFrame(  ):void
		{
			this.graphics.lineStyle( _mainTwinkess, _MAIN_COLOR, 1 );
			this.graphics.drawRect( 0, 0, _targetW, _targetH );
			this.graphics.endFill();
		}
		
		private function createCell( legend:Array ):void 
		{
			this.graphics.lineStyle( .7, _COLOR_LINE, .7 );
			const vSize:Number = legend[ 1 ].data - legend[ 0 ].data;
			const hSize:Number = selectHSize();
			
			function selectHSize():int
			{
				var size:int = _adapt.getHPixSize( vSize * 1.3 );
				
				while ( _targetW % size > 5 )
					size++;
				
				return  size;
				
				
			}
			
			const len:int = legend.length;
			for ( var i:int = 0; i < len; i++ )
				drawHorisontalLine( legend[ i ] );
			
			var yp:int = 0;
			for ( i = 0; yp <  _targetW - hSize; i++, yp = ( hSize * i ) )
				drawVerticalLine( yp );
			
		}
		
		private function drawVerticalLine( xp:int ):void
		{
			this.graphics.moveTo( xp, 0 );
			this.graphics.lineTo( xp, _targetH  );
		}
		
		private function drawHorisontalLine( legendItem:Object ):void
		{
			
			const yp:int = _adapt.getVPixSize( legendItem.data );
			
			this.graphics.moveTo( -_LEDGE_LINE, yp );
			this.graphics.lineTo( _targetW,  yp);
			const tf:TextField = createTFInfo( legendItem.label );
			tf.x = -( tf.width + _LEDGE_LINE );
			tf.y =  yp  -( tf.height ) / 2;
			this.addChild( tf );
		}
		
		private function createTFInfo( text:String ):TextField 
		{
			const tfInfo:TextField = new TextField()
			tfInfo.width = 20;
			tfInfo.height = 20;
			tfInfo.autoSize = TextFieldAutoSize.LEFT;
			tfInfo.wordWrap = false;
			tfInfo.type = TextFieldType.DYNAMIC;
			//tfInfo.border = true;
			//tfInfo.borderColor = 0xff;
			tfInfo.defaultTextFormat = new TextFormat( "Verdana", 12, _MAIN_COLOR, false );
			tfInfo.mouseEnabled  = false;
			tfInfo.text = text;
			
			return tfInfo;
		}
	}
	
	
}