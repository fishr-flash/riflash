package components.gui
{
	import components.abstract.servants.ResizeWatcher;
	import components.gui.widget.WidgetDefaultSkin;
	import components.interfaces.IResizeDependant;
	import components.interfaces.IWidget;
	import components.protocol.Package;
	import components.static.COLOR;
	import components.static.GuiLib;
	import components.system.UTIL;
	
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.core.UIComponent;
	
	public class Widget extends UIComponent implements IResizeDependant, IWidget
	{
		private const MIN_WIDTH:int = 50;
		
		private const MIN_HEIGHT:int = 50;
		
		private var skin:WidgetDefaultSkin;
		private var _cmd:int;
		private var title:SimpleTextField;
		private var message:SimpleTextField;
		private var icon:Bitmap;
		
		private var opened:Boolean;
		
		public function Widget(command:int)
		{
			super();
			
			skin = new WidgetDefaultSkin;
			addChild( skin );
			
			title = new SimpleTextField( "", this.width - 20 );
			addChild( title );
			title.y = 10;
			title.x = 10;
			title.setSimpleFormat("center");
			title.htmlText = UTIL.wrapHtml("Date", COLOR.BLACK, 14, true );
			
			message = new SimpleTextField( "", this.width - 20 );
			addChild( message );
			message.x = 10;

			icon = new GuiLib.cWidget_time;
			addChild( icon );
			
			this.addEventListener( Event.ADDED_TO_STAGE, onAdded );
		}
		public function open(b:Boolean, force:Boolean=false):void
		{
			if (opened != b || force) {
				opened = b;
				message.visible = b;
				icon.visible = !b;
				title.visible = b;
				if (b) {
					this.width = 150;
					this.height = 100;
					
					title.width = this.width-20;
					title.height = 30;
					
					message.y = 45;
					message.width = this.width-20;
					message.height = this.height - 55;
				} else {
					this.width = MIN_WIDTH;
					this.height = MIN_HEIGHT;
				}
				placeCorrection();
			}
		}
		public function active(b:Boolean):void
		{
		}
		public function put(p:Package):void
		{
			open(opened);
			if (opened) {
				message.htmlText = UTIL.wrapHtml("12.12.12 14:15:35", COLOR.BLACK );
			}
		}
		override public function set width(value:Number):void
		{
			super.width = value;
			resize();
		}
		override public function set height(value:Number):void
		{
			super.height = value;
			resize();
		}
		private function resize():void
		{
			skin.resize(width,height,opened);
		}
		public function set cmd(value:int):void
		{
			_cmd = value;
		}
		public function get cmd():int
		{
			return _cmd;
		}
/*** FUNCT		***/		
		private function placeCorrection():void
		{
			if (this.x < 0 )
				this.x = 0;
			if (this.y < 0)
				this.y = 0;
			if (this.y + this.height > this.stage.stageHeight )
				this.y = this.stage.stageHeight - (this.height+30);
			if (this.x + this.width > this.stage.stageWidth )
				this.x = this.stage.stageWidth - (this.width+30);
		}
/*** EVENT		***/
		private function onAdded(e:Event):void
		{
			this.removeEventListener( Event.ADDED_TO_STAGE, onAdded );
			
			this.doubleClickEnabled = true;
			this.addEventListener( MouseEvent.MOUSE_DOWN, onMDown );
			this.addEventListener( MouseEvent.DOUBLE_CLICK, onDClick);
			stage.addEventListener( MouseEvent.MOUSE_UP, onMUp );
			ResizeWatcher.addDependent(this);
			
			open(false,true);
		}
		private function onMDown(e:MouseEvent):void
		{
			this.startDrag();
		}
		private function onMUp(e:MouseEvent):void
		{
			this.stopDrag();
			placeCorrection();
		}
		private function onDClick(e:MouseEvent):void
		{
			open(!opened);
		}
		
		public function localResize(w:int, h:int, real:Boolean=false):void
		{
			placeCorrection();
		}
	}
}