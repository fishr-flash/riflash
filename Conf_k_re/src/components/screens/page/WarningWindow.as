package components.screens.page
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	import components.abstract.functions.loc;
	import components.basement.UI_BaseComponent;
	import components.gui.SimpleTextField;
	import components.gui.triggers.TextButton;
	import components.static.COLOR;
	
	public class WarningWindow extends UI_BaseComponent
	{
		private var title:SimpleTextField;
		private var bg:Sprite;
		private var window:Sprite;
		private var xvalue:int = 40;
		private var yvalue:int = 20;
		private var bOk:TextButton;
		private const OK:int = 3;

		private var mess:SimpleTextField;
		
		public function WarningWindow()
		{
			super();
			
			init();
		}
		
		private function init():void
		{
			FLAG_SAVABLE = false;
			
			bg = new Sprite;
			addChild( bg );
			addEventListener( MouseEvent.CLICK, onClose );
			
			window = new Sprite;
			addChild( window );
			window.graphics.beginFill( COLOR.GREY_POPUP_FILL );
			window.graphics.drawRoundRect(xvalue,yvalue,400,190,5,5);
			window.graphics.endFill();
			window.graphics.lineStyle(1, COLOR.GREY_POPUP_OUTLINE );
			window.graphics.drawRoundRect(xvalue,yvalue,400,190,5,5);
			window.graphics.endFill();
			
			globalX = 40;
			globalY += 20;
			
			title = new SimpleTextField("");
			place( title );
			title.setSimpleFormat("center",0,14);
			title.width = 400;
			title.height = 200;
			title.textColor = COLOR.RED;
			globalY += 30;
			
			mess = new SimpleTextField("");
			place( mess );
			mess.setSimpleFormat("left",0,14);
			mess.width = 360;
			mess.height = 200;
			mess.x = globalX + 20;
			globalY += 70;
			mess.textColor = COLOR.RED_DARK;
			
			bOk = new TextButton;
			addChild( bOk );
			bOk.setUp(loc("ui_out_ok"), onClick, OK);
			bOk.x = ( window.width - bOk.width ) / 2;
			bOk.x += 45;
			bOk.y = window.height - bOk.height + 20;
			
			this.visible = false;
		}
		
		private function onClick( n:int ):void
		{
			onClose( null );
		}
		
		public function show( label:String, message:String ):void
		{
			title.text = label;
			
			mess.text = message;
			
			this.visible = true;
			
		}
		
		protected function onClose(event:MouseEvent):void
		{
			// TODO Auto-generated method stub
			
			this.visible = false;
			
		}
		
		private function place(d:DisplayObject):void
		{
			addChild( d );
			d.x = globalX;
			d.y = globalY;
		}
	}
}