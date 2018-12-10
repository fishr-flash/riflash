///********************************************************************
///* Copyright © 2013 fishr (fishr.flash@gmail.com)  
///********************************************************************
package su.fishr.display 
{
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.getTimer;
	
   /**
	 *   Является базовым для объектов в которых необходимо
	 * различие между нажатием мыши и кликом.
	 * 
	 * @playerversion          Flash 9
	 * @langversion            3.0
	 * @author                 fishr
	 * @created                5/17/2013 12:50 
	 * @since                  5/17/2013 12:50 
	 */
	
	public  class SpriteDiffMouseEvent extends Sprite
	{
		[Event (name="diffMouseDown", type="su.fishr.display.SpriteDiffMouseEvent")];
		[Event (name = "diffMouseClick", type = "su.fishr.display.SpriteDiffMouseEvent")];
		
	/**-------------------------------------------------------------------------------
	* 
	*	   						V A R I A B L E ' S 	
	* 
	* --------------------------------------------------------------------------------
	*/
	//{
		
		static public const DIFF_MOUSE_DOWN:String = "diffMouseDown";
		static public const DIFF_MOUSE_CLICK:String = "diffMouseClick";
		
	    static private const AUTHOR:String = "fishr (fishr.flash@gmail.com)";	
		private const DIFF_DELAY:int = 200;
		
		public var addToParent:Boolean = false;
		
		private var _enabledDiff:Boolean = true;
		private var _startMouse:Array;
		private var _startTime:int;
		
		
	//}
	
	/**-------------------------------------------------------------------------------
	* 
	*	 						P R O P E R T I E S 	
	* 
	* --------------------------------------------------------------------------------
	*/
	//{
	
		public function get enabledDiff():Boolean 
		{
			return _enabledDiff;
		}
		
		public function set enabledDiff(value:Boolean):void 
		{
			_enabledDiff = value;
			
			activateDiff();
		}
	//}
	/**-------------------------------------------------------------------------------
	* 
	*								P U B L I C 	
	* 
	* --------------------------------------------------------------------------------
	*/
	//{
		public function SpriteDiffMouseEvent()
		{
			super();
			
			
			init();
			
			
		}
	//}
	
	/**-------------------------------------------------------------------------------
	* 
	*								P R I V A T E 	
	* 
	* --------------------------------------------------------------------------------
	*/	
	//{
		
		private function init():void
		{
			this.addEventListener( MouseEvent.MOUSE_DOWN, mouseDown );
			this.addEventListener(MouseEvent.CLICK, clickMouse );
		}
		
		private function clickMouse(evt:MouseEvent):void 
		{
			this.dispatchEvent( new Event( SpriteDiffMouseEvent.DIFF_MOUSE_CLICK ) );
			activateDiff();
			
		}
		
		private function mouseDown(evt:MouseEvent):void 
		{
			if( evt )evt.target.removeEventListener( evt.type, arguments.callee );
			
			this.addEventListener(MouseEvent.MOUSE_OUT, mouseOut );
			_startMouse = [ evt.localX, evt.localY ];
			_startTime = getTimer();
			
			this.addEventListener(Event.ENTER_FRAME, enterFrame );
			
		}
		
		private function mouseOut(evt:MouseEvent):void 
		{
			this.removeEventListener(Event.ENTER_FRAME, enterFrame );
			activateDiff();
		}
		
		private function enterFrame(evt:Event):void 
		{
			if ( this.mouseX !== _startMouse[ 0 ] ||
				this.mouseY !== _startMouse[ 1 ] ||
				( getTimer() - _startTime ) > DIFF_DELAY )
			{
				if( evt )evt.target.removeEventListener( evt.type, arguments.callee );
				
				if( addToParent ) this.parent.addChild( this );
				
				this.dispatchEvent( new Event( SpriteDiffMouseEvent.DIFF_MOUSE_DOWN ) );
				this.removeEventListener(MouseEvent.CLICK, clickMouse );
				
				this.addEventListener(MouseEvent.MOUSE_UP, mouseUp );
				
			}
			
		}
		
		private function mouseUp(evt:MouseEvent):void 
		{
			this.addEventListener( MouseEvent.MOUSE_DOWN, mouseDown );
		}
		
		private function activateDiff():void
		{
			if ( _enabledDiff )
			{
				this.addEventListener( MouseEvent.MOUSE_DOWN, mouseDown );
				this.addEventListener(MouseEvent.CLICK, clickMouse );
			}
			else
			{
				this.removeEventListener( MouseEvent.MOUSE_DOWN, mouseDown );
				this.removeEventListener(MouseEvent.CLICK, clickMouse );
				
			}
			
			this.removeEventListener(Event.ENTER_FRAME, enterFrame );
		}
		
		
	
	
	//}

	}

}