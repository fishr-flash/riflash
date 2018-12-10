package components.screens.ui
{
	import flash.display.DisplayObject;
	import flash.events.KeyboardEvent;
	
	import components.abstract.servants.KeyWatcher;
	import components.abstract.servants.TaskManager;
	import components.basement.UI_BaseComponent;
	import components.gui.SimpleTextField;
	import components.gui.triggers.SpriteMovieClipButton;
	import components.interfaces.IKeyUser;
	import components.interfaces.ITask;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.static.CMD;
	import components.static.KEYS;
	import components.system.GraphicsLibrary;
	
	public class UIScreenKeyboard extends UI_BaseComponent implements IKeyUser
	{
		private var keys:Vector.<SpriteMovieClipButton>;
		private var pinput:DisplayObject;
		private var tinput:SimpleTextField;
		private var msg:String;
		private var task:ITask;
		private var sendtask:ITask;
		// 68x58
		
		public function UIScreenKeyboard()
		{
			super();
			
			pinput = new GraphicsLibrary.cKey_input; 
			addChild( pinput );
			pinput.x = globalX;
			pinput.y = globalY;
			
			tinput = new SimpleTextField("", 150 );
			addChild( tinput );
			tinput.setSimpleFormat( "left", 0, 28 );
			tinput.height = 50;
			tinput.x = globalX;
			tinput.y = globalY;
			tinput.text = "";
			globalY += 61;
			
			keys = new Vector.<SpriteMovieClipButton>;
			for (var i:int=1; i<13; i++) {
				keys.push( add(i) );
			}
		}
		override public function open():void
		{
			super.open();
			
			msg = "";
			tinput.text = "";
			KeyWatcher.add(this);
			
			loadComplete();
		}
		override public function close():void
		{
			super.close();
			
			if( task )
				task.kill();
			task = null;
		}
		private function add(n:int):SpriteMovieClipButton
		{
			var s:SpriteMovieClipButton;
			switch(n) {
				case 10:
					s = new SpriteMovieClipButton(GraphicsLibrary["cKey_asterisk"]);
					
					break;
				case 11:
					s = new SpriteMovieClipButton(GraphicsLibrary["cKey_0"]);
					
					break;
				case 12:
					s = new SpriteMovieClipButton(GraphicsLibrary["cKey_cancel"]);
					break;
				
				
				default:
					s = new SpriteMovieClipButton(GraphicsLibrary["cKey_"+n]);
					break;
			}
				
			addChild( s );
			s.setUp("", onClick, n );
			
			s.y = globalY + 62 * int((n-1)/3);
			s.x = globalX + ((n-1)-int((n-1)/3)*3)*64;
			return s;
		}
		private function onClick(n:int):void
		{
			switch(n) {
				case 10:
					write("*");
					break;
				case 12:
					write(null);
					break;
				case 11:
					write("0");
					break;
				default:
					write(n.toString());
					break;
			}
		}
		private function write(s:String):void
		{ 
			const partCapture:Boolean = msg.substr(0, 2 ) == "*0";
			const noAsterisk:Boolean = msg.indexOf( "*" ) < 1;
			
			if (!s)
				msg = "";
			else if (( msg.length == 4 && partCapture == false && noAsterisk ) || ( partCapture == true && msg.length == 8 )) {
				
				if (sendtask)
					sendtask.kill();
				sendtask = null;
				msg = s;
			} else
				msg += s;
			
			if( noAsterisk == false || ( msg.length > 4 && partCapture == false ) || msg.length > 8 )
				msg = "";
			
			tinput.text = "";
			
			
			var len:int	= msg.length;
			for (var i:int=0; i<len; i++) {
				tinput.appendText("*");
			}
			
			
			
			
			if ( ( msg.length == 4 && partCapture == false && noAsterisk ) || ( partCapture == true && msg.length == 8 )) {
				RequestAssembler.getInstance().fireEvent( new Request(CMD.SEND_KEYBOARD, null, 1, [msg]));
				if (!sendtask)
					sendtask = TaskManager.callLater( onSend, TaskManager.DELAY_1SEC );
				else
					sendtask.repeat();
				//tinput.text = "****";
			} else{
				
				if (sendtask) {
					sendtask.kill();
					sendtask = null;
				}
			}
			
			if (!task)
				task = TaskManager.callLater( clear, TaskManager.DELAY_30SEC );
			task.repeat();
		}
		private function onSend():void
		{
			msg = "";
			tinput.text = "";
			sendtask = null;
		}
		private function clear():void
		{
			msg = "";
			tinput.text = "";
		}
		public function onKeyUp(ev:KeyboardEvent):void
		{
			
			switch(ev.keyCode) {
				case 48:
				case 96:
					write("0");
					break;
				case 49:
				case 97:
					write("1");
					break;
				case 50:
				case 98:
					write("2");
					break;
				/*case 51:
				case 99:
					if (ev.shiftKey)
						write("#");
					else
						write("3");
					break;*/
				case 56:
					if (ev.shiftKey == false)
					{
						write( "8" );
						break;
					}
						
				case 100:
					write("*");
					break;
				case 52:
				case 106:
					write("4");
					break;
				case 53:
				case 101:
					write("5");
					break;
				case 54:
				case 102:
					write("6");
					break;
				case 55:
				case 103:
					write("7");
					break;
				case 56:
				case 104:
					write("8");
					break;
				case 57:
				case 105:
					write("9");
					break;
				case KEYS.ESC:
					write(null);
					break;
			}
		}
	}
}