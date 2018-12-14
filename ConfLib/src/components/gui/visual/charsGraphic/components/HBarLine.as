package components.gui.visual.charsGraphic.components 
{
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import components.gui.visual.charsGraphic.DiapasonAdapterHor;
	
	/**
	 * ...
	 * @author  
	 */
	public class HBarLine extends BaseLine 
	{
		private var _currentStep:int;
		private var _drawStep:int;
		private var _adapter:DiapasonAdapterHor;
		private var _ownerRect:Rectangle;
		private var _bars:Vector.<Shape> = new Vector.<Shape>;
		private var _color:uint;
		private var _lastYPos:Number;
		private var _fineLine:Shape;
		private var _tf:TextField;
		
		public function HBarLine( name:String, rect:Rectangle, adapt:DiapasonAdapterHor, color:uint, drawStep:int = 1 ) 
		{
			super();
			this.name = name;
			_ownerRect = rect;
			_adapter = adapt;
			_drawStep = drawStep;
			_currentStep = 0;
			_color = color;
			
			
			_fineLine = new Shape;
			_fineLine.graphics.lineStyle( 1, _color, .35 );
			
			_tf = createTFInfo( color );
			_tf.alpha = .6;
		}
		
		public function setYPos(vPixSize:Number, lbl:String ):void 
		{
			
			const shape:Shape = new Shape;
			shape.graphics.lineStyle( 2, _color );
			shape.graphics.lineTo( _drawStep, vPixSize - _lastYPos );
			shape.graphics.endFill();
			shape.cacheAsBitmap = true;
			
			if ( !_bars ) _bars = new Vector.<Shape>;
			_bars.push( shape );
			
			shape.x = _currentStep;
			shape.y = _lastYPos;
			this.addChild( shape );
			
			_lastYPos = vPixSize;
			
			
			if ( _currentStep > _ownerRect.width * .85 )
				updateChine();
			_currentStep += _drawStep;
			
			if ( _bars.length )
			{
				_fineLine.x = _currentStep;
				_fineLine.y = vPixSize;
				if ( _fineLine.width !=  _ownerRect.width - _currentStep + 5 )
				{
					_fineLine.graphics.clear();
					_fineLine.graphics.lineStyle( 1, _color , .35 );
					_fineLine.graphics.lineTo( _ownerRect.width - _currentStep + 85, 0 );
				}
				
				this.addChild( _fineLine );
			}
			
			_tf.text = lbl;
			_tf.x = _fineLine.x + _fineLine.width + 5;
			_tf.y = _fineLine.y - ( _tf.height / 2 );
			this.addChild( _tf );
			
			
		}
		
		public function destruct():void 
		{
			var shape:Shape;
			while ( _bars.length )
			{
				shape = _bars.shift();
				shape.graphics.clear();
				shape.parent.removeChild( shape );
				shape = null;
			}
			
			if( _tf )
			{
				_tf.parent.removeChild( _tf );
				_tf = null;
			}
			
			if( _fineLine )
			{
				_fineLine.graphics.clear();
				_fineLine.parent.removeChild( _fineLine );
				_fineLine = null;
			}
			
			
		}
		
		
		private function updateChine():void 
		{
			const prevBar:Shape = _bars.shift();
			prevBar.parent.removeChild( prevBar );
			_currentStep = 0;
			
			var currentYPos:Number;
			
			const len:int = _bars.length;
			for ( var i:int = 0; i < len; i++ )
			{
				
				_bars[ i ].x = _currentStep;
				_currentStep += _drawStep;
				
			}
			
			_currentStep -= _drawStep;
		}
		
		private function createTFInfo( color:uint ):TextField 
		{
			const tfInfo:TextField = new TextField()
			tfInfo.width = 20;
			tfInfo.height = 20;
			tfInfo.autoSize = TextFieldAutoSize.LEFT;
			
			tfInfo.wordWrap = false;
			tfInfo.type = TextFieldType.DYNAMIC;
			//tfInfo.border = true;
			//tfInfo.borderColor = 0xff;
			tfInfo.defaultTextFormat = new TextFormat( "Verdana", 12, color, false,null, null, null, null, TextFormatAlign.CENTER );
			tfInfo.mouseEnabled  = false;
			
			return tfInfo;
		}
	}
	
}