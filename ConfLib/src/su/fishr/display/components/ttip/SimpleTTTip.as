///********************************************************************
///* Copyright © 2012 fishr (fishr.flash@gmail.com)  
///********************************************************************
package su.fishr.display.components.ttip 
{
	
	import flash.display.DisplayObjectContainer;
	import flash.display.Graphics;
	import flash.display.InteractiveObject;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.filters.DropShadowFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.utils.Timer;
	import su.fishr.display.AlignCenter;
	
   /**
	 *  Всплывающая подсказка.
	 * 
	 * @playerversion          Flash 9
	 * @langversion            3.0
	 * @author                 fishr
	 * @created                25.07.2012 7:02
	 * @since                  25.07.2012 7:02
	 */
	
	public  class SimpleTTTip extends Sprite
	{
	
	/**-------------------------------------------------------------------------------
	* 
	*	   						V A R I A B L E ' S 	
	* 
	* --------------------------------------------------------------------------------
	*/
	//{
	    static private const AUTHOR:String = "fishr (fishr.flash@gmail.com)";	
		
		static public const ALIGN_TOP:String = "alignTop";
		static public const ALIGN_RIGHT:String = "alignRight";
		static public const ALIGN_BOTTOM:String = "alignBottom";
		static public const ALIGN_LEFT:String = "alignLeft";
		static public const ALIGN_AUTO:String = "";
		
		protected var _shift:Number = 2;
		
		/// Указывает следует ли в качестве
		/// точки отсчета позиционирования
		/// использовать стороны объекта 
		/// или точку над которой находится
		/// курсор
		public var mouseOrientation:Boolean;
		
		
		public var align:String = SimpleTTTip.ALIGN_AUTO;
		
		protected var _colorBack:uint = 0x000000;
		protected var _colorFront:uint = 0xFFFFCC;
		
		protected var _ttField:TextField;
		protected var _stageP:Array;
		protected var _autoAlign:String;
		protected var _distance:int = 20;
		
		
		private const _TIMER_WAIT:Timer = new Timer( 400 );
		private const _TIMER_SHOW:Timer = new Timer( 4000 );
		private var _listenIObject:InteractiveObject;
		private var _parentTarget:DisplayObjectContainer;
		private var _parentRect:Rectangle;
		
	//}
	
	/**-------------------------------------------------------------------------------
	* 
	*	 						P R O P E R T I E S 	
	* 
	* --------------------------------------------------------------------------------
	*/
	//{
		public function set defaultTextFormat( tFormat:TextFormat ):void
		{
			_ttField.defaultTextFormat = tFormat;
		}
		
		public function get defaultTextFormat():TextFormat
		{
			return _ttField.defaultTextFormat;
		}
		
		public function set text( str:String ):void
		{
			
			_ttField.text = str;
			
			configVisual();
		}
		
		public function get text():String
		{
			return _ttField.text;
		}
		
		public function set htmlText( htmlStr:String ):void
		{
			_ttField.htmlText = htmlStr;
			configVisual();
		}
		
		public function get htmlText():String
		{
			return _ttField.htmlText;
		}
		
		public function get parentTarget():DisplayObjectContainer 
		{
			return _parentTarget;
		}
		
		public function set parentTarget(value:DisplayObjectContainer):void 
		{
			if ( _parentTarget === value ) return;
			
			_parentTarget = value;
			_parentRect = new Rectangle( 0, 0, 
										_parentTarget is Stage?Stage( _parentTarget ).stageWidth:_parentTarget.width,
										_parentTarget is Stage?Stage( _parentTarget ).stageHeight:_parentTarget.height );
		}
		
		public function get listenIObject():InteractiveObject 
		{
			return _listenIObject;
		}
		
		public function set listenIObject(value:InteractiveObject):void 
		{
			if ( _listenIObject === value ) return;
			/// Отключаем слушатели старого объекта
			outHandler( null );
			_listenIObject.removeEventListener( MouseEvent.ROLL_OVER, overHandler );
			
			
			_listenIObject = value;
			/// Подключаем слушатели нового
			_listenIObject.addEventListener( MouseEvent.ROLL_OVER, overHandler );
			_listenIObject.addEventListener( Event.REMOVED_FROM_STAGE, listenObjRemoved );
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
		 *  Конструктор.
		 * 
		 * @param	listenIntObject  обслуживаемый интерактивный объект.
		 * @param	container  отображаемый объект относительно которого выравнивается подсказка
		 * @param	tttext  текст подсказки ( в режиме text, #htmlText можно задать чере сеттер )
		 */
		public function SimpleTTTip( listenIntObject:InteractiveObject, container:DisplayObjectContainer, tttext:String, mouseOrient:Boolean = true  )
		{
			super();
			
			init( listenIntObject, container, tttext, mouseOrient );
	
		}
	//}
	
	/**-------------------------------------------------------------------------------
	* 
	*								P R O T E C T E D 	
	* 
	* --------------------------------------------------------------------------------
	*/	
	//{
		protected function configVisual():void
		{
			if ( this.contains( _ttField ) ) this.removeChild( _ttField );
			drawBack();
			
			this.addChild( _ttField );
			
			
			
			const dropsh:DropShadowFilter = new DropShadowFilter( 2, 45, 0x00, .5, 3, 3 );
			this.filters = [ dropsh ];
		}
		
	//}
	
	/**-------------------------------------------------------------------------------
	* 
	*								P R I V A T E 	
	* 
	* --------------------------------------------------------------------------------
	*/	
	//{
		
		protected function init( listenIntObject:InteractiveObject, container:DisplayObjectContainer, tttext:String, mouseOrient:Boolean ):void
		{
			mouseOrientation = mouseOrient;
			
			_parentTarget = container;
			_parentRect = new Rectangle( 0, 0, 
										_parentTarget is Stage?Stage( _parentTarget ).stageWidth:_parentTarget.width,
										_parentTarget is Stage?Stage( _parentTarget ).stageHeight:_parentTarget.height );
			
			_listenIObject = listenIntObject;
			
			this.mouseChildren = false;
			
			configureTField( tttext );
			
			configVisual();
			
			_listenIObject.addEventListener( MouseEvent.ROLL_OVER, overHandler );
			_listenIObject.addEventListener( Event.REMOVED_FROM_STAGE, listenObjRemoved );
			
		}
		
		
		
		private function analisisPositionThis():Array
		{
			const margin:int = 5;
			var posY:int = _stageP[ 1 ];
			var posX:int = _stageP[ 0 ];
			
			_autoAlign = ALIGN_TOP;
			if( !mouseOrientation ) _stageP = translationPoint( _listenIObject.width / 2, 0 );
			/// пробуем расположить эл-т сверху
			posY = _stageP[ 1 ] - this.height - _distance;
			if ( !align && posY - margin > 0 || align === SimpleTTTip.ALIGN_TOP )
			{
				posX = selectHorizontal();
				return [ posX, posY ];
			}
			
			_autoAlign = ALIGN_BOTTOM;
			if( !mouseOrientation ) _stageP = translationPoint( _listenIObject.width / 2, _listenIObject.height );
			/// пробуем расположить снизу
			posY = _stageP[ 1 ] + ( _distance * 1.5 );
			if ( !align &&  posY + this.height + margin < _parentRect.height  || align === SimpleTTTip.ALIGN_BOTTOM   )
			{
				posX = selectHorizontal();
				return [ posX, posY ];
			}
			
			_autoAlign = ALIGN_LEFT;
			if( !mouseOrientation ) _stageP = translationPoint( 0,  (_listenIObject.height )  / 2  );
			/// пробуем слева
			posX = _stageP[ 0 ] - this.width - _distance;
			if ( !align && posX - margin > _parentRect.x || align === SimpleTTTip.ALIGN_LEFT )
			{
				posY = selectVertical();
				return [ posX, posY ];
			}
			
			_autoAlign = ALIGN_RIGHT;
			if ( !mouseOrientation ) _stageP = translationPoint( _listenIObject.width,  (_listenIObject.height  / 2 )  );
			
			/// пробуем справа
			posX = _stageP[ 0 ] + _distance;
			if ( !align &&  posX + this.width + margin < _parentRect.width || align === SimpleTTTip.ALIGN_RIGHT )
			{
				posY = selectVertical();
				return [ posX, posY ];
			}
			
			_autoAlign = ALIGN_TOP;
			if( !mouseOrientation ) _stageP = translationPoint( _listenIObject.width / 2, 0 );
			/// если не подошел ни один случай размещаем дефолтно
			posY = _stageP[ 1 ] - this.height - _distance;
			posX = _stageP[ 0 ] - ( this.width / 2 );
			
			
			return [ posY, posX ];
			
		}
		
		/**
		 * 	Центрируем размещаемую сверху или снизу
		 * от курсора подсказку по горизонтали
		 * 
		 * @return позицию по X-оси
		 */
		private function selectHorizontal():int
		{
			
			const margin:int = 5;
			var posX:int = _stageP[ 0 ] - ( this.width / 2 );
			if ( posX + this.width + margin > _parentRect.width )
			{
				posX = _parentRect.width - this.width - margin;
			}
				
				if ( posX - margin < _parentRect.x ) posX = _parentRect.x + margin;
				
			return posX;
		}
		
		/**
		 *  Центрируем по вертикали подсказку
		 * размещаемую слева или справа от курсора
		 * 
		 * @return позицию по оси Y
		 */
		
		private function selectVertical():int
		{
			
			const margin:int = 5;
			
			var posY:int = _stageP[ 1 ] - ( this.height / 2 );
			if ( posY - margin < _parentRect.y ) posY = _parentRect.y + margin;
			if ( posY + this.height + margin > _parentRect.height )
			{
				posY = _parentRect.height - this.height - margin;
			}
			
			return posY;
		}
		
		private function translationPoint( xx:Number, yy:Number ):Array
		{
			const global:Point = _listenIObject.localToGlobal( new Point( xx, yy ) );
			const local:Point = _parentTarget.globalToLocal( global );
			
			return [ local.x, local.y ];
		}
		
		/**-------------------------------------------------------------------------------
		* 
		*	   						L I S T E N E R ' S
		*
		* --------------------------------------------------------------------------------
		*/
		//{
		
		
		protected function overHandler(e:MouseEvent):void 
		{
			_listenIObject.removeEventListener( MouseEvent.ROLL_OVER, overHandler );
			_listenIObject.addEventListener( MouseEvent.ROLL_OUT, outHandler );
			_listenIObject.addEventListener( MouseEvent.MOUSE_DOWN, outHandler );
			_listenIObject.addEventListener(MouseEvent.MOUSE_MOVE, moveMouse );
			
			
			
			
			_TIMER_WAIT.addEventListener( TimerEvent.TIMER, timerWaiteComplete );
			_TIMER_WAIT.reset();
			_TIMER_WAIT.start();
		}
		
		
		
		protected function timerWaiteComplete(e:TimerEvent):void 
		{
			_listenIObject.removeEventListener(MouseEvent.MOUSE_MOVE, moveMouse );
			_TIMER_WAIT.removeEventListener( TimerEvent.TIMER, timerWaiteComplete );
			_TIMER_WAIT.reset();
			_TIMER_WAIT.stop();
			
			
			_parentRect = new Rectangle( 0, 0, 
										_parentTarget is Stage?Stage( _parentTarget ).stageWidth:_parentTarget.width,
										_parentTarget is Stage?Stage( _parentTarget ).stageHeight:_parentTarget.height );
										
			if ( mouseOrientation )_stageP = [ _parentTarget.mouseX, _parentTarget.mouseY ];
			else _stageP = translationPoint( _listenIObject.width / 2, 0 );
			
			const position:Array = analisisPositionThis();
			
			this.x = position[ 0 ];
			this.y = position[ 1 ];
			
			_parentTarget.addChild( this );
			_TIMER_SHOW.addEventListener(TimerEvent.TIMER, outHandler );
			_TIMER_SHOW.start();
		}
		
		private function moveMouse(e:MouseEvent):void 
		{
			if ( mouseOrientation )_stageP = [ _parentTarget.mouseX, _parentTarget.mouseY ];
			else _stageP = translationPoint( _listenIObject.width / 2, 0 );
		}
		
		protected function outHandler( e:Event ):void 
		{
			_TIMER_SHOW.stop();
			_TIMER_WAIT.stop();
			_TIMER_SHOW.removeEventListener(TimerEvent.TIMER, outHandler );
			_TIMER_WAIT.removeEventListener( TimerEvent.TIMER, timerWaiteComplete );
			_listenIObject.removeEventListener( MouseEvent.ROLL_OUT, outHandler );
			_listenIObject.removeEventListener( MouseEvent.MOUSE_DOWN, outHandler );
			_listenIObject.removeEventListener(MouseEvent.MOUSE_MOVE, moveMouse );
			
			if( _listenIObject.stage.contains( this ) )this.parent.removeChild( this );
			
			_listenIObject.addEventListener( MouseEvent.ROLL_OVER, overHandler );
			
			
		}
		
		private function listenObjRemoved(e:Event):void 
		{
			removeEventListener(Event.REMOVED_FROM_STAGE, listenObjRemoved);
			outHandler( null );
			_listenIObject.removeEventListener( MouseEvent.ROLL_OVER, overHandler );
			_listenIObject.addEventListener(Event.ADDED_TO_STAGE, listenObjAdded, false, 0, true );
			
		}
		
		private function listenObjAdded(e:Event):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, listenObjAdded);
			_listenIObject.addEventListener( MouseEvent.ROLL_OVER, overHandler );
			_listenIObject.addEventListener( Event.REMOVED_FROM_STAGE, listenObjRemoved );
		}
		
		//}
		
		/**-------------------------------------------------------------------------------
		* 
		*	   					S T Y L E ' S	
		*
		* --------------------------------------------------------------------------------
		*/
		//{

			protected function configureTField( tttext:String ):void 
			{
				_ttField = new TextField();
				_ttField.autoSize = TextFieldAutoSize.CENTER;
				_ttField.type = TextFieldType.DYNAMIC;
				_ttField.selectable = false;
				_ttField.condenseWhite = true;
				_ttField.defaultTextFormat = new TextFormat( "_sans" );
				
				_ttField.text = tttext;
				
			}
			
			protected function drawBack( graphics:Graphics = null):void 
			{
				if ( !graphics ) graphics = this.graphics;
				graphics.clear();
				graphics.beginFill( _colorBack );
				graphics.drawRect( 0, 0, _ttField.width + 20, _ttField.height + 5 );
				graphics.beginFill( _colorFront );
				graphics.drawRect( _shift / 2, _shift / 2, _ttField.width + 20 - _shift, _ttField.height + 5 - _shift );
				graphics.endFill();
			}
		//}
	
	//}

	}
	
	

}
