package components.gui.triggers
{
	/** Added bg & positioning	*/
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.Timer;
	
	import mx.core.UIComponent;
	
	import components.abstract.functions.loc;
	import components.gui.SimpleTextField;
	import components.static.COLOR;
	import components.static.MISC;
	
	public class ButtonSave extends UIComponent
	{
		public const CONSTANT_HEIGHT:int = 50;
		private var LABEL:String = loc("misc_transition_without_save");
		
		private var timer:Timer;
		private var normalColor:int = 0x287bbf;
		private var overColor:int = 0x000000;
		
		private var defaultPlaceX:int = 0;
		private var defaultPlaceY:int = 0;
		
		private var _enabled:Boolean=true;
		
		private var tLabel:TextField;
		private var tNote:SimpleTextField;
		
		public function ButtonSave()
		{
			super();
			
			tLabel = new TextField;
			addChild( tLabel );
			tLabel.border = false;
			tLabel.selectable = false;
			tLabel.height = 50;
			tLabel.width = 300;
			tLabel.textColor = normalColor;
			
			var textFormat:TextFormat = new TextFormat;
			textFormat.font = "Verdana";
			textFormat.underline = true;
			textFormat.bold = true;
			textFormat.size = "20";
			textFormat.align = "center";
			
			tLabel.defaultTextFormat = textFormat;
			
			tNote = new SimpleTextField(LABEL);
			addChild( tNote );
			tNote.setSimpleFormat("center");
			tNote.height = 20;
			tNote.y = 30;
			
			timer = new Timer(50,1);
			
			this.addEventListener( MouseEvent.ROLL_OVER, rollOver);
			this.addEventListener( MouseEvent.ROLL_OUT, rollOut);
			this.addEventListener( MouseEvent.MOUSE_DOWN, mDown );
			this.addEventListener( MouseEvent.MOUSE_UP, mUp );
			
			defaultPlaceX = 0;
			tLabel.x = defaultPlaceX;
		}
		private function rollOver( ev:MouseEvent ):void 
		{
			tLabel.textColor = overColor;
		}
		private function rollOut( ev:MouseEvent ):void 
		{
			tLabel.textColor = normalColor;
			tLabel.x = defaultPlaceX;
			tLabel.y = defaultPlaceY;
		}
		public function setName( _name:String ):void
		{
			tLabel.text = _name;
		}
		public function setLabel( s:String ):void
		{
			if (!s)
				tNote.text = LABEL;
			else
				tNote.text = s;
			tNote.width = 2000;
		}
		private function mDown( ev:MouseEvent ):void 
		{
			if (!_enabled)
				return;
			tLabel.x = defaultPlaceX-1;
			tLabel.y = defaultPlaceY+1;
		}
		private function mUp( ev:MouseEvent ):void 
		{
			if (!_enabled)
				return;
			tLabel.x = defaultPlaceX;
			tLabel.y = defaultPlaceY;
		}
		override public function set visible(value:Boolean):void
		{
			if ( value && !this.visible) {
				this.alpha = 0;
				show()
			}
			super.visible = value;
			this.dispatchEvent( new Event( MISC.EVENT_RESIZE_IMPACT ));
		}
		private function show():void
		{
			timer.addEventListener( TimerEvent.TIMER_COMPLETE, doVisibility );
			timer.reset();
			timer.start();
		}
		private function doVisibility( ev:TimerEvent ):void
		{
			if ( this.alpha < 1 ) {
				this.alpha += 0.05;
				timer.reset();
				timer.start();				
			} else {
				this.alpha = 1;
				timer.stop();
				timer.removeEventListener( TimerEvent.TIMER_COMPLETE, doVisibility );
				this.dispatchEvent( new Event( MISC.EVENT_RESIZE_IMPACT ));
			}
		}
		override public function set enabled(value:Boolean):void
		{
			if (!tLabel)
				super.enabled = value;
			else {
				if( value ) {
					tLabel.textColor = 0x287bbf;
					normalColor = 0x287bbf;
					setName( loc("misc_save_changes") );
				} else {
					
					tLabel.textColor = 0x990000;
					normalColor = 0x990000;
					setName( loc("misc_save_impossible") );
				}
				_enabled = value;
			}
		}
		override public function get enabled():Boolean
		{
			if ( MISC.DEBUG_IGNORE_FIELD_ERRORS == 1)
				return true;
			return _enabled;
		}
		override public function set width(value:Number):void
		{
			super.width = value;
			
			this.graphics.clear();
			this.graphics.beginFill( COLOR.WHITE_GREY );
			this.graphics.drawRect(0,0,width,CONSTANT_HEIGHT);
			
			defaultPlaceX = int(this.width/2 - tLabel.width/2);
			tLabel.x = defaultPlaceX;
			
			tNote.x = int(this.width/2 - tNote.width/2);
		}
		override public function get height():Number
		{
			if (this.alpha == 1 && this.visible)
				return CONSTANT_HEIGHT;
			return 0; 
		}
	}
}