///********************************************************************
///* Copyright © 2012 fishr (fishr.flash@gmail.com)  
///********************************************************************
package su.fishr.display 
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
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.utils.Timer;
	
   /**
	* 	[ deprecated ]
	* 
	 *  Всплывающая подсказка.
	 *
	 *  используйте одну из подсказок
	 * в пакете su.fishr.display.components/ttip
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
		
		protected var _ttField:TextField;
		protected var _parentPP:Array;
		
		private const _TIMER_WAIT:Timer = new Timer( 400 );
		private const _TIMER_SHOW:Timer = new Timer( 4000 );

		private var _listenIObject:InteractiveObject;
		private var _parent:DisplayObjectContainer;
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
			_ttField.text = text;
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
		public function SimpleTTTip( listenIntObject:InteractiveObject, container:DisplayObjectContainer, tttext:String  )
		{
			super();
			
			init( listenIntObject, container, tttext );
	
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
			
			
			drawBack();
			
			this.addChild( _ttField );
			AlignCenter( _ttField );
			
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
		
		private function init( listenIntObject:InteractiveObject, container:DisplayObjectContainer, tttext:String ):void
		{
			_parent = container;
			_parentRect = new Rectangle( 0, 0, 
										_parent is Stage?Stage( _parent ).stageWidth:_parent.width,
										_parent is Stage?Stage( _parent ).stageHeight:_parent.height );
			
			_listenIObject = listenIntObject;
			
			this.mouseChildren = false;
			
			configureTField( tttext );
			
			configVisual();
			
			_listenIObject.addEventListener( MouseEvent.ROLL_OVER, overHandler );
			_listenIObject.addEventListener( Event.REMOVED_FROM_STAGE, listenObjRemoved );
			
		}
		
		
		
		private function analisisPositionThis():Array
		{
			const distance:int = 20;
			const margin:int = 5;
			var posY:int = _parent.mouseY;
			var posX:int = _parent.mouseX;
			
			/// пробуем расположить эл-т сверху
			posY = _parent.mouseY - this.height - distance;
			if ( posY - margin > 0 )
			{
				posX = selectHorizontal();
				return [ posX, posY ];
			}
			
			/// пробуем расположить снизу
			posY = _parent.mouseY + ( distance * 1.5 );
			if ( posY + this.height + margin < _parentRect.height )
			{
				posX = selectHorizontal();
				return [ posX, posY ];
			}
			
			/// пробуем слева
			posX = _parent.mouseX - this.width - distance;
			if ( posX - margin > _parentRect.x )
			{
				posY = selectVertical();
				return [ posX, posY ];
			}
			
			/// пробуем справа
			posX = _parent.mouseX + distance;
			if ( posX + this.width + margin < _parentRect.width )
			{
				posY = selectVertical();
				return [ posX, posY ];
			}
			
			/// если не подошел ни один случай размещаем дефолтно
			posY = _parent.mouseY - this.height - distance;
			posX = _parent.mouseX - ( this.width / 2 );
			
			
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
			const distance:int = 20;
			const margin:int = 5;
			var posX:int = _parentPP[ 0 ] - ( this.width / 2 );
				
				if ( this.width + ( margin * 2 ) <= _parentRect.width )
				{
					
					if ( posX - margin < _parentRect.x ) posX = _parentRect.x + margin;
					if ( posX + this.width + margin > _parentRect.width )
					{
						
						posX = _parentRect.width - this.width - margin;
					}
				}
				
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
			const distance:int = 20;
			const margin:int = 5;
			
			var posY:int = _parent.mouseY - ( this.width / 2 );
			if ( posY - margin < _parentRect.y ) posY = _parentRect.y + margin;
			if ( posY + this.height + margin > _parentRect.height )
			{
				posY = _parentRect.height - this.height - margin;
			}
			
			return posY;
		}
		
		/**-------------------------------------------------------------------------------
		* 
		*	   						L I S T E N E R ' S
		*
		* --------------------------------------------------------------------------------
		*/
		//{
		
		
		private function overHandler(e:MouseEvent):void 
		{
			_listenIObject.removeEventListener( MouseEvent.ROLL_OVER, overHandler );
			_listenIObject.addEventListener( MouseEvent.ROLL_OUT, outHandler );
			_listenIObject.addEventListener( MouseEvent.MOUSE_DOWN, outHandler );
			_listenIObject.addEventListener(MouseEvent.MOUSE_MOVE, moveMouse );
			
			_parentPP = [ _parent.mouseX, _parent.mouseY ];
			
			_TIMER_WAIT.addEventListener( TimerEvent.TIMER, timerWaiteComplete );
			_TIMER_WAIT.reset();
			_TIMER_WAIT.start();

		}
		
		
		
		private function timerWaiteComplete(e:TimerEvent):void 
		{
			_listenIObject.removeEventListener(MouseEvent.MOUSE_MOVE, moveMouse );
			_TIMER_WAIT.removeEventListener( TimerEvent.TIMER, timerWaiteComplete );
			_TIMER_WAIT.reset();
			_TIMER_WAIT.stop();
			
			drawBack();
			
			
			const position:Array = analisisPositionThis();
			
			this.x = position[ 0 ];
			this.y = position[ 1 ];
			
			_parent.addChild( this );
			_TIMER_SHOW.addEventListener(TimerEvent.TIMER, outHandler );
			_TIMER_SHOW.start();
		}
		
		private function moveMouse(e:MouseEvent):void 
		{
			_parentPP = [ _parent.mouseX, _parent.mouseY ];
		}
		
		private function outHandler( e:Event ):void 
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

			private function configureTField( tttext:String ):void 
			{
				_ttField = new TextField();
				_ttField.autoSize = TextFieldAutoSize.CENTER;
				_ttField.type = TextFieldType.DYNAMIC;
				_ttField.selectable = false;
				_ttField.defaultTextFormat = new TextFormat( "_sans" );
				_ttField.text = tttext + " ";
				
			}
			
			protected function drawBack( graphics:Graphics = null ):void 
			{
				if ( !graphics ) graphics = this.graphics;
				graphics.clear();
				graphics.beginFill( 0x000000 );
				graphics.drawRect( 0, 0, _ttField.width + 10, _ttField.height + 5 );
				graphics.beginFill( 0xFFFFCC );
				graphics.drawRect( 1, 1, this.width - 2, this.height - 2 );
				graphics.endFill();
			}
		//}
	
	//}

	}
	
	

}
