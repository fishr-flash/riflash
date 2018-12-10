package components.gui
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import mx.core.UIComponent;
	
	import components.abstract.GroupOperator;
	import components.abstract.functions.loc;
	import components.gui.triggers.TextButton;
	import components.screens.opt.OptVEvents;
	
	public class SubsetVrgEvents extends UIComponent
	{

		public static const PREV_COLOUMN_WIDTH:int = 450;
		public static const SECOND_COLOUMN_WIDTH:int = 300;
		public static const SECOND_SUBSECTION_COLOUMN_WIDTH:int = 125;
		public static const THIRD_COLOUMN_WIDTH:int = 300;
		public static const V_INDENT_TABLE:int = 15;
		
		private var globalY:int;
		private var globalX:int;
		private var gr:GroupOperator;
		private var _onShowTbl:Boolean = true;
		private var _vheight:int;
		private var _maxHeight:int;
		private var _minHeight:int;

		private var _opts:Vector.<OptVEvents>;
		
		public function get onShowTbl():Boolean
		{
			return _onShowTbl;
		}

		public function get vheight():int
		{
			return _vheight;
		}
		
		public function SubsetVrgEvents( jdata:Object )
		{
			super();
			
			
			gr = new GroupOperator;
			
			globalY = 0;
			globalX = 0;
			
			
			
			
			const textButton:TextButton = new TextButton;
			textButton.setUp( jdata.MessagesGroup, onClickButton );
			textButton.x = globalX;
			textButton.y = globalY;
			globalY += textButton.height;
			addChild( textButton );
			
			
			_vheight = _minHeight = textButton.height;
			
			createHeader();
			_maxHeight = globalY;
			
			_opts = new Vector.<OptVEvents>();
			var len:int = jdata.Messages.length;
			for (var i:int=0; i<len; i++) 
				_opts[ i ] = new OptVEvents ( jdata.Messages[ i ] );
			
			
			onClickButton();
			
		}
		
		public function put( jdata:Object ):void
		{
			
			var len:int = jdata.Messages.length;
			for (var i:int=0; i<len; i++) {
				
				_opts[ i ].jmess = jdata.Messages[ i ];
				
				if( _onShowTbl ) _opts[ i ].putRawData( _opts[ i ].jmess.settings[ 0 ] as Array );
				
				
			}
			
			
			
		}
		
		private function onClickButton():void
		{
			_onShowTbl = !_onShowTbl;
			
			if( _onShowTbl )
			{
				
				
				var len:int = _opts.length;
				for (var i:int=0; i<len; i++) {
					if( _opts[ i ].open() )
					{
						globalY += V_INDENT_TABLE;
						_opts[ i ].y = globalY - 1;
						_opts[ i ].x = -.5;
						this.addChild( _opts[ i ] );
						gr.add( "table", _opts[ i ] );
						globalY += _opts[ i ].height - 10;
						_maxHeight = globalY;
					}
					else
						break;
					
				}
				
			}
			
			
			
			
			_vheight = _onShowTbl?_maxHeight:_minHeight;
			
			gr.visible( "table", _onShowTbl );
			
			
			this.dispatchEvent( new Event( Event.RESIZE ) );
			
		}
		
		private function createHeader():void
		{
			const onBorder:Boolean = false;
			
			const imgTable:Sprite = drawTable();
			imgTable.y = globalY;
			imgTable.x = globalX;
			this.addChild( imgTable );
			gr.add( "table", imgTable );
			
			var txt:SimpleTextField = new SimpleTextField( "\r" + loc( "his_event" ) + "\r" );
			txt.setTextFormat( new TextFormat( null, null, null, true, null, null, null, null, TextFormatAlign.CENTER ) ); 
			txt.wordWrap = false;
			txt.autoSize = TextFieldAutoSize.NONE;
			txt.width = PREV_COLOUMN_WIDTH;
			txt.height = 50;
			txt.border = onBorder;
			addChild( txt );
			gr.add( "table", txt );
			txt.y = globalY;
			//globalY += txt.height;
			
			globalX = txt.x + txt.width;
			
			/// two coloumn
			txt = new SimpleTextField(  loc( "in_protect_mode" ) );
			txt.setTextFormat( new TextFormat( null, null, null, true, null, null, null, null, TextFormatAlign.CENTER, null, null, null ) ); 
			txt.wordWrap = false;
			txt.autoSize = TextFieldAutoSize.NONE;
			txt.width = SECOND_COLOUMN_WIDTH;
			txt.height = 25;
			txt.border = onBorder;
			addChild( txt );
			gr.add( "table", txt );
			txt.x = globalX;
			txt.y = globalY + 3;
			
			
			
			txt = new SimpleTextField(  loc( "type" ) );
			txt.setTextFormat( new TextFormat( null, null, null, true, null, null, null, null, TextFormatAlign.CENTER, null, null, null  ) ); 
			txt.wordWrap = false;
			txt.autoSize = TextFieldAutoSize.NONE;
			txt.width = SECOND_SUBSECTION_COLOUMN_WIDTH;
			txt.height = 25;
			txt.border = onBorder;
			txt.x = globalX;
			txt.y = this.getChildAt( this.numChildren - 1 ).y + this.getChildAt( this.numChildren - 1 ).height - .5;
			gr.add( "table", txt );
			addChild( txt );
			
			
			
			txt = new SimpleTextField(  loc( "method_of_send" ) );
			txt.setTextFormat( new TextFormat( null, null, null, true, null, null, null, null, TextFormatAlign.CENTER, null, null, null ) ); 
			txt.wordWrap = false;
			txt.autoSize = TextFieldAutoSize.NONE;
			txt.width = SECOND_COLOUMN_WIDTH - SECOND_SUBSECTION_COLOUMN_WIDTH;
			txt.height = 25;
			txt.border = onBorder;
			txt.x = this.getChildAt( this.numChildren - 1 ).x + this.getChildAt( this.numChildren - 1 ).width;
			txt.y = this.getChildAt( this.numChildren - 1 ).y;
			addChild( txt );
			gr.add( "table", txt );
			globalX = txt.x + txt.width;
			//txt.y = globalY;
			/// third coloumn
			
			txt = new SimpleTextField(  loc( "out_protect_mode" ) );
			txt.setTextFormat( new TextFormat( null, null, null, true, null, null, null, null, TextFormatAlign.CENTER, null, null, null, 40 ) ); 
			txt.wordWrap = false;
			txt.autoSize = TextFieldAutoSize.NONE;
			txt.width = SECOND_COLOUMN_WIDTH;
			txt.height = 25;
			txt.border = onBorder;
			addChild( txt );
			gr.add( "table", txt );
			txt.x = globalX;
			txt.y = globalY + 3;
			
			
			
			txt = new SimpleTextField(  loc( "type" ) );
			txt.setTextFormat( new TextFormat( null, null, null, true, null, null, null, null, TextFormatAlign.CENTER, null, null, null, 40 ) ); 
			txt.wordWrap = false;
			txt.autoSize = TextFieldAutoSize.NONE;
			txt.width = SECOND_SUBSECTION_COLOUMN_WIDTH;
			txt.height = 25;
			txt.border = onBorder;
			txt.x = globalX;
			txt.y = this.getChildAt( this.numChildren - 1 ).y + this.getChildAt( this.numChildren - 1 ).height + 1;
			gr.add( "table", txt );
			addChild( txt );
			
			
			
			txt = new SimpleTextField(  loc( "method_of_send" ) );
			txt.setTextFormat( new TextFormat( null, null, null, true, null, null, null, null, TextFormatAlign.CENTER, null, null, null, 40 ) ); 
			txt.wordWrap = false;
			txt.autoSize = TextFieldAutoSize.NONE;
			txt.width = SECOND_COLOUMN_WIDTH - SECOND_SUBSECTION_COLOUMN_WIDTH;;
			txt.height = 25;
			txt.border = onBorder;
			txt.x = this.getChildAt( this.numChildren - 1 ).x + this.getChildAt( this.numChildren - 1 ).width;
			txt.y = this.getChildAt( this.numChildren - 1 ).y;
			addChild( txt );
			gr.add( "table", txt );
			
			globalY = imgTable.y + imgTable.height;
			
		}
		
		private function drawTable():Sprite
		{
			const ww:int = PREV_COLOUMN_WIDTH + SECOND_COLOUMN_WIDTH * 2;
			const heighTable:int = 50;
			const spr:Sprite = new Sprite;
			spr.graphics.lineStyle( 1 );
			spr.graphics.lineTo( ww, 0 );
			spr.graphics.lineTo( ww, heighTable );
			spr.graphics.lineTo( 0, heighTable );
			spr.graphics.lineTo( 0, 0 );
			// верт перемычки
			spr.graphics.moveTo( PREV_COLOUMN_WIDTH, 0 );
			spr.graphics.lineTo( PREV_COLOUMN_WIDTH, heighTable );
			spr.graphics.moveTo( PREV_COLOUMN_WIDTH + SECOND_COLOUMN_WIDTH, 0 );
			spr.graphics.lineTo( PREV_COLOUMN_WIDTH + SECOND_COLOUMN_WIDTH, heighTable );
			// продольный разрез
			spr.graphics.moveTo( PREV_COLOUMN_WIDTH , heighTable / 2 );
			spr.graphics.lineTo( ww, heighTable / 2 );
			
			// подраздельные верт. перемычки
			
			spr.graphics.moveTo( PREV_COLOUMN_WIDTH + SECOND_SUBSECTION_COLOUMN_WIDTH , heighTable / 2 );
			spr.graphics.lineTo( PREV_COLOUMN_WIDTH + SECOND_SUBSECTION_COLOUMN_WIDTH , heighTable );
			
			spr.graphics.moveTo( PREV_COLOUMN_WIDTH + SECOND_COLOUMN_WIDTH + SECOND_SUBSECTION_COLOUMN_WIDTH , heighTable / 2 );
			spr.graphics.lineTo( PREV_COLOUMN_WIDTH + SECOND_COLOUMN_WIDTH + SECOND_SUBSECTION_COLOUMN_WIDTH , heighTable );
			
			return spr;
		}
	}
}