package components.gui
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import components.abstract.Warning;
	import components.abstract.functions.loc;
	import components.gui.triggers.SpriteMovieClipButton;
	import components.static.COLOR;
	import components.static.GuiLib;
	import components.static.MISC;
	import components.static.PAGE;
	import components.system.UTIL;
	
	public class StatusBar extends Sprite
	{
		private var isExtended:Boolean = false;
		private var history:String = "";
		
		private const short:int = 20;
		private const extended:int = 68;
		private const versionShinft:int = PAGE.MAINMENU_WIDTH;
		private const scroll_up:int = 1;
		private const scroll_down:int = 2;
		private const scroll_fast_down:int = 3;

		private var scrollAllowed:Boolean = true;
		
		private var aLines:Array;
		
		private var connection:String=loc("sys_no_connection");
		private var connectionColor:String="C60000";
		//private var device:String=loc("sys_unidentified");
		private var _device:String=null;
		public function set device(value:String):void
		{
			_device = value;
		}
		public function get device():String 
		{
			if (_device)
				return _device;
			return loc("sys_unidentified");
		}
		private var deviceColor:String="C60000";
		
		private var tVersion:TextField;
		private var tStatus:TextField;
		private var tWriteStatus:MovingTextField;		// статус сообщает идет ли запись на прибор или нет
		
		private var bUp:SpriteMovieClipButton;
		private var bDown:SpriteMovieClipButton;
		private var bFastDown:SpriteMovieClipButton;
		
		public function StatusBar()
		{
			super();
			
			var tf:TextFormat = new TextFormat;
			//tf.leading = -7;
			
			tVersion = new TextField;
			addChild( tVersion );
			with (tVersion) {
				defaultTextFormat = tf; 
				width = 100;
				height = 20;
				border = true;
				borderColor = 0xcccccc;
				background = true;
				backgroundColor = 0xecf0f6;
				addEventListener( MouseEvent.CLICK, extend );
				multiline = true;
				selectable = false;
			}
			
			tStatus = new TextField;
			addChild( tStatus );
			with (tStatus) {
				x = versionShinft;
				defaultTextFormat = tf; 
				width = 500;
				height = 20;
				addEventListener( MouseEvent.CLICK, extend );
				multiline = true;
				selectable = false;
			}
			
			var note:String = "<font face='"+PAGE.MAIN_FONT+"' size='12' color='#" + COLOR.BLACK.toString(16) + "'>\r   "+
				loc("sys_do_not_close_while_save1")+"\r   "+
				loc("sys_do_not_close_while_save2")+"\r   "+
				loc("sys_do_not_close_while_save3")+"</font>";
			
			var a:Array = ["<b><font face='"+PAGE.MAIN_FONT+"' size='12' color='#" + getColor(Warning.TYPE_ERROR) + "'>   "+loc("sys_save_inprogress")+"</font></b>"+note,
				"<b><font face='"+PAGE.MAIN_FONT+"' size='12' color='#" + getColor(Warning.TYPE_SUCCESS) + "'>   "+loc("sys_save_inprogress")+".</font></b>"+note,
				"<b><font face='"+PAGE.MAIN_FONT+"' size='12' color='#" + getColor(Warning.TYPE_ERROR) + "'>   "+loc("sys_save_inprogress")+"..</font></b>"+note,
				"<b><font face='"+PAGE.MAIN_FONT+"' size='12' color='#" + getColor(Warning.TYPE_SUCCESS) + "'>   "+loc("sys_save_inprogress")+"...</font></b>"+note];
			tWriteStatus = new MovingTextField(a);
			addChild( tWriteStatus );
			with (tWriteStatus) {
				x = versionShinft;
				defaultTextFormat = tf; 
				height = 20;
				addEventListener( MouseEvent.CLICK, extend );
				multiline = false;
				selectable = false;
				width = textWidth+30;
				backgroundColor = 0xecf0f6;
				borderColor = 0xcccccc;
				visible = false;
			}
			
			bUp = new SpriteMovieClipButton(GuiLib.m_scroll_up);
			bUp.setUp("", onScroll, scroll_up );
			bUp.x = 227;
			bUp.y = 5;
			
			bDown = new SpriteMovieClipButton(GuiLib.m_scroll_down);
			bDown.setUp("", onScroll, scroll_down );
			bDown.x = 227;
			bDown.y = 23;
			
			bFastDown = new SpriteMovieClipButton(GuiLib.m_scroll_fast_down);
			bFastDown.setUp("", onScroll, scroll_fast_down );
			bFastDown.x = 227;
			bFastDown.y = 44;
			
			aLines = new Array;
		}
		public function show( _text:String, _type:int, _status:int ):void
		{
			
			switch( _status ) {
				case Warning.STATUS_CONNECTION:
					connection = _text;
					connectionColor = getColor(_type);
					break;
				case Warning.STATUS_DEVICE:
					device = _text;
					deviceColor = getColor(_type);
					break;
				default:
					var waschanged:Boolean = false;
					if (!tWriteStatus.visible && _type == Warning.TYPE_ERROR ) // активировать надо только первый раз, когда появляется
						waschanged = true;
					tWriteStatus.visible = _type == Warning.TYPE_ERROR;
					if (waschanged)	// на момент настройки статус должен быть visible
						writeStatusBgManagement();
					return;
			}
			
			var date:Date = new Date;
			var dateStamp:String = "("+ UTIL.formateZerosInFront(date.getHours(),2)+":"+
				UTIL.formateZerosInFront(date.getMinutes(),2)+":"+
				UTIL.formateZerosInFront(date.getSeconds(),2) +") ";
			
			if ( connectionColor == "C60000" && deviceColor == "339900" )
				deviceColor = "cc9900";

			var msg:String = "<b><font face='"+PAGE.MAIN_FONT+"' size='12' color='#000000'>"+dateStamp +
				"</font><font face='"+PAGE.MAIN_FONT+"' size='12' color='#" + connectionColor + "'>" + connection + "</font>" + " > " + 
				"</font><font face='"+PAGE.MAIN_FONT+"' size='12' color='#" + deviceColor + "'>" + device + "</font></b>";
			
			var len:int = aLines.length;
			if ( len == 0 || !( (aLines[len-1] as String).slice(60) == msg.slice(60) ) )
				aLines.push( msg );
			
			history="";
			for( var key:String in aLines ) {
				if ( key == "0" )
					history += aLines[key];
				else
					history += "\r"+aLines[key];
			}
			tStatus.htmlText = history;
			if (scrollAllowed)
				tStatus.scrollV = tStatus.maxScrollV;
			
			if( aLines.length > 25 )
				aLines.shift();
			
			if (isExtended && aLines.length > 4 && !this.contains(bUp) ) {
				addChild( bUp );
				addChild( bDown );
				addChild( bFastDown );
			}
			
			var ver:String = "<b><font face='"+PAGE.MAIN_FONT+"' size='12' color='#000000'>["+loc("sys_version")+" " + MISC.COPY_CLIENT_VERSION+ "]</font></b>";
			tVersion.htmlText = ver;
			
			
		}
		private function getColor(_type:int):String
		{
			switch( _type ) {
				case Warning.TYPE_ERROR:
					return "C60000";
				case Warning.TYPE_SUCCESS:
					return "339900";
			}
			return "000000";
		}
		private function extend(ev:MouseEvent):void
		{
			var delta:int = extended - short;
			if ( isExtended ) {
				if (this.contains(bUp) ) {
					removeChild( bUp );
					removeChild( bDown );
					removeChild( bFastDown );
				}
				this.height = short;
				this.y += delta;
				tStatus.htmlText = history;
			} else {
				this.y -= delta;
				this.height = extended;
				if (aLines.length > 4) {
					addChild( bUp );
					addChild( bDown );
					addChild( bFastDown );
				}
			}
			isExtended = !isExtended;
			scrollAllowed = true;
			tStatus.scrollV = tStatus.maxScrollV;
			
			this.dispatchEvent( new Event( MISC.EVENT_RESIZE_IMPACT ));
		}
		override public function set height(value:Number):void
		{
			if (tStatus) {
				tStatus.height = value;
				tVersion.height = value;
				tWriteStatus.height = value;
			}
		}
		override public function set width(value:Number):void
		{
			if (tStatus) {
				tStatus.width = value-versionShinft;
				tVersion.width = value;
				tWriteStatus.x = value-tWriteStatus.width;
				
				writeStatusBgManagement();
			}
		}
		private function writeStatusBgManagement():void
		{
			if (tWriteStatus.visible && tStatus.textWidth + tStatus.x > tWriteStatus.x) {
				tWriteStatus.border = true;
				tWriteStatus.background = true;
			} else {
				tWriteStatus.border = false;
				tWriteStatus.background = false;
			}	
		}
		private function onScroll(num:int):void
		{
			var c:Number = tStatus.maxScrollV;
			
			switch(num) {
				case scroll_up:
					tStatus.scrollV -= 2;
					break;
				case scroll_down:
					tStatus.scrollV += 2;
					break;
				case scroll_fast_down:
					tStatus.scrollV = tStatus.maxScrollV;
					break;
			}
			scrollAllowed = (tStatus.scrollV == tStatus.maxScrollV)
		}
	}
}