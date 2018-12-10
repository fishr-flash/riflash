///********************************************************************
///* Copyright © 2013 fishr (fishr.flash@gmail.com)  
///********************************************************************
package su.fishr.display.components.scroller 
{
	
	import flash.display.InteractiveObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.geom.Transform;
	
   /**
	 *  Примитивный элемент gui, вертикальный
	 * скроллер. Каретка скроллера масшатбируется
	 * пропорционально отношению клиентского
	 * объекта к его scrollRect-у ( опционально ). Клиентский
	 * объект перемещается в своей видимой
	 * области с помощью перемещения каретки
	 * скроллера по вертикали, клика на треке скроллера,
	 * вращением колесика мыши над клиентским объектом.
	 * 
	 * Инициализация скроллера происходит после вызова
	 * метода <code>setClient()</code> и добавления скроллера
	 * на сцену. 
	 * 
	 * @playerversion          Flash 9
	 * @langversion            3.0
	 * @author                 fishr
	 * @created                5/23/2013 10:55 
	 * @since                  5/23/2013 10:55 
	 */
	
	public  class HScroller extends Sprite
	{
	
	/**-------------------------------------------------------------------------------
	* 
	*	   						V A R I A B L E ' S 	
	* 
	* --------------------------------------------------------------------------------
	*/
	//{
	    static private const AUTHOR:String = "fishr (fishr.flash@gmail.com)";	
		/**
		 *  Ширина дорожки скроллера 
		 * по умолчанию
		 */
		public var defaultHeight:int = 10;
		/**
		 * Каретка скроллера
		 */
		public var runner:InteractiveObject;
		/**
		 * Трек перемещения каретки.
		 */
		public var track:InteractiveObject;
		/**
		 * Устанавливает шаг при прокрутке
		 * клиентского объекта колесиком мыши.
		 * Шаг равен отношению заданного значения
		 * к полной высоте клиентского объекта .
		 */
		public var mouseWheelStep:Number = 10;
		
		
		protected var _widthTrack:Number;
		protected var _realBounds:Rectangle;
		protected var _client:InteractiveObject;
		
		private var _scalableRunner:Boolean = true;
		private var _oldMouseX:Number;
		private var _minWidthRunner:Number;
		
	//}
	
	/**-------------------------------------------------------------------------------
	* 
	*	 						P R O P E R T I E S 	
	* 
	* --------------------------------------------------------------------------------
	*/
	//{
		/**
		 *  Возвращает высоту трека
		 */
		public function get widthTrack():Number 
		{
			return _widthTrack;
		}
		
		/**
		 * Задает высоту трека.
		 * После изменения этого свойства
		 * вызывается метод update(), для учета
		 * сделаных изменений.
		 * 
		 */
		public function set widthTrack(value:Number):void 
		{
			_widthTrack = value;
			update();
			
		}
		
		/**
		 *  Возвращает текущее значение
		 * флага указывающего на то - должна 
		 * ли карректа масштабироваться относительно
		 * клиентских данных.
		 * 
		 */
		public function get scalableRunner():Boolean 
		{
			return _scalableRunner;
		}
		
		/**
		 * Устанавливает значение флага
		 * указывающего на то - должна 
		 * ли карректа масштабироваться относительно
		 * клиентских данных.
		 * 
		 * После изменения вызывается метод update(),
		 * для учета нового свойства.
		 * 
		 */
		public function set scalableRunner(value:Boolean):void 
		{
			_scalableRunner = value;
			update();
		}
	//}
	/**-------------------------------------------------------------------------------
	* 
	*								P U B L I C 	
	* 
	* --------------------------------------------------------------------------------
	*/
	//{
		public function HScroller()
		{
			super();
		}
		
		/**
		 *  Метод с вызова которого начинается инициализация
		 * работы компонента.
		 * 
		 * @param	obj клиентский объект прокруткой которого
		 * будет управлять компонент. Объект должен иметь
		 * непустое свойство scrollRect.
		 */
		public function setClient( obj:InteractiveObject ):void
		{
			
			_client = obj;
			
			if ( !_widthTrack ) _widthTrack = _client.scrollRect.width;
			if ( !runner ) makeRunner();
			if ( !track ) makeTrack();
			
			_minWidthRunner = runner.width;
			
			this.addChild( track );
			runner.y = ( track.height - runner.height ) / 2;
			this.addChild( runner );
			
			update();
			
			this.addEventListener(Event.REMOVED_FROM_STAGE, removeFromStage );
		}
		
		
		
		
		/**
		 *  Вызывается в произвольный момент, 
		 * когда изменены данные клиентского
		 * объекта или собственные данные скроллера.
		 * 
		 */
		public function update():void 
		{
			if( !this.stage ) this.addEventListener(Event.ADDED_TO_STAGE, addedToStage );
			if ( !_client ) return;
			
			runner.x = 0;
			const rect:Rectangle = _client.scrollRect;
			rect.x = 0;
			_client.scrollRect = rect;
			
			_realBounds = getFullBounds( _client );
				
			if ( _realBounds.width <= rect.width )
			{
				
				this.visible = false;
				runner.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDown );
				track.removeEventListener(MouseEvent.MOUSE_DOWN, clickTrack );
				_client.removeEventListener(MouseEvent.MOUSE_WHEEL, mouseWheelClient );
				_client.removeEventListener(MouseEvent.MOUSE_WHEEL, mouseWheelClient, true );
				
				
			}
			else
			{
				this.visible = true;
				
				
				if ( _scalableRunner )
				{
					const newWidth:Number = track.width * ( _client.scrollRect.width / _realBounds.width );
					runner.width = newWidth > _minWidthRunner?newWidth:_minWidthRunner;
				}
				
				runner.addEventListener(MouseEvent.MOUSE_DOWN, mouseDown );
				track.addEventListener(MouseEvent.MOUSE_DOWN, clickTrack );
				_client.addEventListener(MouseEvent.MOUSE_WHEEL, mouseWheelClient );
				_client.addEventListener(MouseEvent.MOUSE_WHEEL, mouseWheelClient, true );
			}
			
		}
		
	//}
	
	/**-------------------------------------------------------------------------------
	* 
	*								P R I V A T E 	
	* 
	* --------------------------------------------------------------------------------
	*/	
	//{
		
		/**
		 *  Переопределяемый в подклассах
		 * метод добавления и рисования каретки
		 */
		protected function makeRunner():void
		{
			const rnr:Sprite = new Sprite();
			rnr.graphics.clear();
			rnr.graphics.beginFill( 0x333333 );
			rnr.graphics.drawRect( 0, 0, _widthTrack / 10, defaultHeight );
			rnr.graphics.endFill();
			
			runner = rnr;
			
		}
		
		/**
		 *  Переопределяемый в подклассах
		 * метод добавления и рисования трека
		 * 
		 */
		protected function makeTrack():void
		{
			const trk:Sprite = new Sprite();
			
			with ( trk.graphics )
			{
				clear();
				beginFill( 0x999999 );
				drawRect( 0, 0, _widthTrack, defaultHeight );
				endFill();
			}
			
			track = trk;
		}
		
		private function addedToStage(evt:Event):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, addedToStage);
			update();
		}
		
		private function mouseDown(evt:MouseEvent):void 
		{
			if ( evt ) evt.target.removeEventListener( evt.type, arguments.callee );
			track.removeEventListener(MouseEvent.MOUSE_DOWN, clickTrack );
			
			this.stage.addEventListener(MouseEvent.MOUSE_UP, mouseUp );
			this.stage.addEventListener(Event.MOUSE_LEAVE, mouseUp );
			
			
			_oldMouseX = this.stage.mouseX;
			this.addEventListener(Event.ENTER_FRAME, handlerMovieRunner );
		}
		
		private function handlerMovieRunner(evt:Event):void 
		{
			if ( _oldMouseX === this.stage.mouseX ) return;
			
			var newPos:Number = runner.x - ( _oldMouseX - this.stage.mouseX );
			
			
			selectRectX( newPos );
			
			_oldMouseX = this.stage.mouseX;
		}
		
		private function mouseUp(evt:MouseEvent):void 
		{
			runner.addEventListener(MouseEvent.MOUSE_DOWN, mouseDown );
			track.addEventListener(MouseEvent.MOUSE_DOWN, clickTrack );
			
			
			this.stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUp );
			this.stage.removeEventListener(Event.MOUSE_LEAVE, mouseUp );
			this.removeEventListener(Event.ENTER_FRAME, handlerMovieRunner );
		}
	
		private function clickTrack(evt:MouseEvent):void 
		{
			if ( evt.target != track ) return;
			
			var posX:Number = track.mouseX - ( runner.width / 2 );
			
			selectRectX( posX );
		}
		
		private function mouseWheelClient(evt:MouseEvent):void 
		{
			
			
			const diff:Number = ( track.width  - runner.width ) * ( mouseWheelStep / _realBounds.width );
			const posX:Number = runner.x +(  evt.delta > 0? - diff:diff );
			
			
			selectRectX( posX );
			
		}
		
		private function selectRectX( pos:Number ):void
		{
			if ( pos < 0 ) pos = 0;
			if ( pos > ( track.width - runner.width ) ) pos = ( track.width - runner.width );
			
			runner.x = pos;
			
			const rect:Rectangle = _client.scrollRect;
			
			rect.x = ( ( _realBounds.width - _client.width )  * ( runner.x / ( track.width - runner.width ) ) ) ;
			
			
			
			_client.scrollRect = rect;
		}
		
		private function removeFromStage(evt:Event):void 
		{
			removeEventListener(Event.REMOVED_FROM_STAGE, removeFromStage);
			this.stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUp );
			this.stage.removeEventListener(Event.MOUSE_LEAVE, mouseUp );
			this.removeEventListener(Event.ENTER_FRAME, handlerMovieRunner );
			if( _client ) _client.removeEventListener(MouseEvent.MOUSE_WHEEL, mouseWheelClient );
			if( _client ) _client.removeEventListener(MouseEvent.MOUSE_WHEEL, mouseWheelClient, true );
			this.addEventListener(Event.ADDED_TO_STAGE, addedToStage );
		}
		
		public function getFullBounds ( displayObject:InteractiveObject ) :Rectangle
		{
			var bounds:Rectangle, transform:Transform,
								toGlobalMatrix:Matrix, currentMatrix:Matrix;
		 
			transform = displayObject.transform;
			currentMatrix = transform.matrix;
			toGlobalMatrix = transform.concatenatedMatrix;
			toGlobalMatrix.invert();
			transform.matrix = toGlobalMatrix;
		 
			bounds = transform.pixelBounds.clone();
		 
			transform.matrix = currentMatrix;
		 
			return bounds;
		}
	//}

	}

}


