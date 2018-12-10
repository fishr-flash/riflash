package components.gui
{
	import flash.display.Sprite;
	import flash.events.KeyboardEvent;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	
	import mx.core.UIComponent;
	
	import components.abstract.functions.loc;
	import components.abstract.servants.KeyWatcher;
	import components.abstract.servants.ResizeWatcher;
	import components.abstract.servants.TabOperator;
	import components.gui.triggers.TextButton;
	import components.interfaces.IKeyUser;
	import components.interfaces.IResizeDependant;
	import components.static.COLOR;
	import components.static.KEYS;
	
	public class PopUp extends UIComponent implements IResizeDependant, IKeyUser
	{
		public static const BUTTON_OK:int =0x01;
		public static const BUTTON_CANCEL:int =0x02;
		public static const BUTTON_YES:int =0x04;
		public static const BUTTON_NO:int =0x08;
		
		public var PARAM_CLOSE_ITSELF:Boolean = true;
		
		private var offlineMessage:Array;
		
		private var bg:Sprite;
		private var mess:TextField;
		private var title:TextField;
		private var buttons:Vector.<TextButton>;
		private var delegate:Array;
		
		private static var inst:PopUp;
		public static function getInstance():PopUp
		{
			if (!inst) inst = new PopUp;
			return inst;
		}
		
		public function PopUp()
		{
			super();
			
			bg = new Sprite;
			addChild( bg );
			
			var tf:TextFormat = new TextFormat;
			tf.align = "center";
			tf.size = 12;
			
			
			title = new TextField;
			addChild( title );
			title.x = 10;
			title.y = 5;
			title.width = 655;
			title.height = 30;
//				title.border = true;
			title.selectable = false;
			title.defaultTextFormat = tf;
			
			mess = new TextField;
			addChild( mess );
			mess.x = 10;
			mess.y = 35;
			mess.width = 655;
			mess.height = 200;
//				mess.border = true;
			mess.selectable = false;
			mess.wordWrap = true;
			mess.defaultTextFormat = tf;
			
			buttons = new Vector.<TextButton>;
			
			this.visible = false;
		}
		public function close():void
		{
			this.visible = false;
			ResizeWatcher.removeDependent(this);
			TabOperator.getInst().removePopUp();
			KeyWatcher.remove(this);
			
			if (mess.selectable) {
				mess.type = TextFieldType.DYNAMIC;
				mess.selectable = false;
				mess.displayAsPassword = false;
				mess.border = false;
				mess.x = 10;
				mess.maxChars = 0;
			}
		}
		public function open():void
		{
			ResizeWatcher.addDependent(this);
			TabOperator.getInst().addPopUp( buttons );
			this.visible = true;
		}
		public function localResize(w:int, h:int, real:Boolean=false):void
		{
			this.height = h-2;
			this.width = w;
			
			title.width = this.width-20;
			title.y = h/2-100;
			if( mess.selectable ) {
				mess.width = 210;
				mess.height = 20;
				mess.x = this.width/2 - 105;
			} else {
				mess.width = this.width-20;
				mess.height = mess.textHeight+30;
			}
			mess.y = title.y+30;
			
			bg.graphics.clear();
			bg.graphics.beginFill( COLOR.WHITE );
			bg.graphics.drawRect(0,0,this.width,this.height);
			bg.graphics.endFill();
			
			var p:int = w/2 - ((buttons.length-1)*100/2);
			for(var i:int=0; i<buttons.length; ++i) {
				buttons[i].x = i*100-(buttons[i].getPrecisionWidth()/2)+p;
				buttons[i].y = mess.y + mess.height;
			}
		}
		
		public function releaseOfflineMsg():void
		{
			if (offlineMessage) {
				PARAM_CLOSE_ITSELF = true;
				construct( offlineMessage[0], offlineMessage[1], PopUp.BUTTON_OK );
				open();
				offlineMessage = null;
			}
		}
		public function composeOfflineMessage(_title:Wrapper, _msg:Wrapper):void
		{
			offlineMessage = [_title, _msg];
		}
		public function construct(_title:Wrapper, _msg:Wrapper, _buttons:int=0, _delegate:Array=null, customttl:Array=null ):void
		{
			title.htmlText = _title.result;
			if (_msg.input) {
				mess.type = TextFieldType.INPUT;
				mess.selectable = true;
				if (_msg.secured)
					mess.displayAsPassword = true;
				mess.border = true;
				mess.maxChars = 32;
				KeyWatcher.add(this);
			}
			mess.htmlText = _msg.result;
			delegate = _delegate;
			
			if(buttons.length>0) {
				for(i=0; i<buttons.length; ++i) {
					removeChild( buttons[i] );
					buttons[i] = null;
				}
				buttons = new Vector.<TextButton>;
			}
			var b:TextButton;
			for(var i:int=0; i<4; ++i) {
				if( (_buttons & 1<<i) > 0 )
					b = aseembleButton( 1<<i );
				if( b && customttl && customttl.length > 0)
					b.setName(customttl.shift());
				b = null;
			}
		}
		private function fire(num:int):void
		{
			if( PARAM_CLOSE_ITSELF )
				this.close();
			if ( delegate && delegate[num] is Function )
				delegate[num]();
			else if ( delegate && delegate[num] is Object )	// в случе если передается объект, а не функция, это означает что надо передать содержимое mess.text как аргумент
				delegate[num].f(mess.text);
		}
		private function aseembleButton(param:int):TextButton
		{
			var b:TextButton = new TextButton;
			switch( param ) {
				case BUTTON_OK:
					b.setUp( loc("g_ok"), fire, buttons.length );
					break;
				case BUTTON_CANCEL:
					b.setUp( loc("g_cancel"), fire, buttons.length );
					break;
				case BUTTON_YES:
					b.setUp( loc("g_yes"), fire, buttons.length );
					break;
				case BUTTON_NO:
					b.setUp( loc("g_no"), fire, buttons.length );
					break;
			}
			buttons.push( b );
			b.setFormat(true,16 );
			addChild( b );
			b.y = 70;
			return b;
		}
		public static function wrapHeader(msg:String):Wrapper
		{
			return new Wrapper(msg,true,false);
		}
		public static function wrapMessage(msg:String, input:Boolean=false, secured:Boolean=true):Wrapper
		{
			return new Wrapper(msg,false,input,secured);
		}
		public function onKeyUp(ev:KeyboardEvent):void
		{
			if (ev.keyCode == KEYS.Enter)
				fire(0);
		}
	}
}
import components.abstract.functions.loc;
import components.static.COLOR;

class Wrapper 
{
	private var root:String;
	public var result:String;
	public var input:Boolean=false;
	public var secured:Boolean;
	
	public function Wrapper(msg:String, header:Boolean=true, _input:Boolean=false, _secured:Boolean=true )
	{
		root = msg;
		input = _input;
		secured = _secured;
		if (header)
			result = "<b><font face='Tahoma' size='16' color='#"+COLOR.RED.toString(16)+"'>" + loc(msg) + "</font></b>";
		else
			result = "<b><font face='Tahoma' size='14' color='#"+COLOR.SATANIC_GREY.toString(16)+"'>" + loc(msg) + "</font></b>";
	}
}