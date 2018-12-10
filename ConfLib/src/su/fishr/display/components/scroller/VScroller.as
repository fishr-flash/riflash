///********************************************************************
///* Copyright © 2013 fishr (fishr.flash@gmail.com)  
///********************************************************************
package su.fishr.display.components.scroller 
{
	
	import flash.display.BitmapData;
	import flash.display.InteractiveObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.Event;
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
	
	public  class VScroller extends Sprite
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
		public var defaultWidth:int = 10;
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
		
		
		protected var _heightTrack:Number;
		protected var _realBounds:Rectangle;
		protected var _client:InteractiveObject;
		
		private var _scalableRunner:Boolean = true;
		private var _oldMouseY:Number;
		private var _minHeightRunner:Number;
		
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
		public function get heightTrack():Number 
		{
			return _heightTrack;
		}
		
		/**
		 * Задает высоту трека.
		 * После изменения этого свойства
		 * вызывается метод update(), для учета
		 * сделаных изменений.
		 * 
		 */
		public function set heightTrack(value:Number):void 
		{
			_heightTrack = value;
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
		public function VScroller()
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
			
			if ( !_heightTrack ) _heightTrack = _client.scrollRect.height;
			if ( !runner ) makeRunner();
			if ( !track ) makeTrack();
			
			_minHeightRunner = runner.height;
			
			this.addChild( track );
			runner.x = ( track.width - runner.width ) / 2;
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
			
			runner.y = 0;
			const rect:Rectangle = _client.scrollRect;
			rect.y = 0;
			_client.scrollRect = rect;
			
			_realBounds = getFullBounds( _client );
				
			if ( _realBounds.height <= rect.height )
			{
				
				this.visible = false;
				runner.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDown );
				track.removeEventListener(MouseEvent.CLICK, clickTrack );
				_client.removeEventListener(MouseEvent.MOUSE_WHEEL, mouseWheelClient );
				_client.removeEventListener(MouseEvent.MOUSE_WHEEL, mouseWheelClient, true );
				
				
			}
			else
			{
				this.visible = true;
				
				
				if ( _scalableRunner )
				{
					const newHeight:Number = track.height * ( _client.scrollRect.height / _realBounds.height );
					runner.height = newHeight > _minHeightRunner?newHeight:_minHeightRunner;
				}
				
				runner.addEventListener(MouseEvent.MOUSE_DOWN, mouseDown );
				track.addEventListener(MouseEvent.CLICK, clickTrack );
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
			rnr.graphics.drawRect( 0, 0, defaultWidth, _heightTrack / 10 );
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
				drawRect( 0, 0, defaultWidth, _heightTrack );
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
			track.removeEventListener(MouseEvent.CLICK, clickTrack );
			
			this.stage.addEventListener(MouseEvent.MOUSE_UP, mouseUp );
			this.stage.addEventListener(Event.MOUSE_LEAVE, mouseUp );
			
			
			_oldMouseY = this.stage.mouseY;
			this.addEventListener(Event.ENTER_FRAME, handlerMovieRunner );
		}
		
		private function handlerMovieRunner(evt:Event):void 
		{
			var newPos:Number = runner.y -( _oldMouseY - this.stage.mouseY );
			
			selectRectY( newPos );
			
			_oldMouseY = this.stage.mouseY;
		}
		
		private function mouseUp(evt:MouseEvent):void 
		{
			runner.addEventListener(MouseEvent.MOUSE_DOWN, mouseDown );
			track.addEventListener(MouseEvent.CLICK, clickTrack );
			
			
			this.stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUp );
			this.stage.removeEventListener(Event.MOUSE_LEAVE, mouseUp );
			this.removeEventListener(Event.ENTER_FRAME, handlerMovieRunner );
		}
	
		private function clickTrack(evt:MouseEvent):void 
		{
			var posY:Number = track.mouseY - ( runner.height / 2 );
			
			selectRectY( posY );
		}
		
		private function mouseWheelClient(evt:MouseEvent):void 
		{
			
			
			const diff:Number = ( track.height  - runner.height ) * ( mouseWheelStep / _realBounds.height );
			const posY:Number = runner.y +(  evt.delta > 0? - diff:diff );
			
			
			selectRectY( posY );
			
		}
		
		private function selectRectY( pos:Number ):void
		{
			if ( pos < 0 ) pos = 0;
			if ( pos > ( track.height - runner.height ) ) pos = ( track.height - runner.height );
			
			runner.y = pos;
			
			const rect:Rectangle = _client.scrollRect;
			
			rect.y = ( ( _realBounds.height - _client.height )  * ( runner.y / ( track.height - runner.height ) ) ) ;
			
			
			
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