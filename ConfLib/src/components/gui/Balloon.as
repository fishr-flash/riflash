package components.gui
{
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import mx.core.UIComponent;
	
	import components.abstract.LOC;
	import components.abstract.servants.ResizeWatcher;
	import components.abstract.servants.TaskManager;
	import components.interfaces.IResizeDependant;
	import components.interfaces.ITask;
	import components.static.COLOR;
	
	public class Balloon extends UIComponent implements IResizeDependant
	{
		private static var inst:Balloon;
		public static function access():Balloon
		{
			if (!inst) inst = new Balloon;
			return inst;
		}
		
		private var bg:Shape;
		private var mess:TextField;
		private var title:TextField;
		private var baloonAreaHeight:int;
		private var task:ITask;
		private var fade:ITask;
		private var defaulttf:TextFormat;
		
		public function Balloon()
		{
			super();
			
			bg = new Shape;
			addChild( bg );
			
			title = new TextField;
			addChild( title );
			title.x = 5;
			//				title.border = true;
			title.selectable = false;
			
			mess = new TextField;
			addChild( mess );
			mess.x = 5;
			//				mess.border = true;
			mess.selectable = false;
			mess.wordWrap = true;
			
			defaulttf = title.defaultTextFormat;
			
			task = TaskManager.callLater( closeSlowly, TaskManager.DELAY_10SEC );
			task.stop();
			fade = TaskManager.callLater( closeSlowly, 100 );
			fade.stop();
			
			this.visible = false;
			
			this.addEventListener( MouseEvent.CLICK, onClick );
			this.addEventListener( MouseEvent.ROLL_OUT, onOut );
			this.addEventListener( MouseEvent.ROLL_OVER, onOver );
		}
		public function show(ttl:String, msg:String, h:int=60):void
		{
			draw(h);
			
			title.y = -baloonAreaHeight;
			title.width = width-10;
			title.height = 20;
			
			mess.y = -baloonAreaHeight+20;
			mess.width = width-10;
			mess.height = baloonAreaHeight-20;
			
			title.htmlText = "<b><font face='Tahoma' size='12' color='#"+COLOR.RED.toString(16)+"'>" + LOC.loc(ttl) + "</font></b>";;
			mess.htmlText = "<font face='Tahoma' size='11' color='#"+COLOR.SATANIC_GREY.toString(16)+"'>" + LOC.loc(msg) + "</font>";
			ResizeWatcher.addDependent(this);
			this.visible = true;
			task.repeat();
		}
		public function showResizable(ttl:String, msg:String, size:int):void
		{
			width = 300;
			
			mess.width = width-10;
			
			title.htmlText = "<b><font face='Tahoma' size='"+size+"' color='#"+COLOR.RED.toString(16)+"'>" + LOC.loc(ttl) + "</font></b>";;
			mess.htmlText = "<font face='Tahoma' size='"+int(size-size/10)+"' color='#"+COLOR.BLACK.toString(16)+"'>" + LOC.loc(msg) + "</font>";
			
			mess.height = mess.textHeight+10;
			
			draw(mess.height + 20);
			
			title.y = -baloonAreaHeight;
			title.width = width-10;
			title.height = 20;
			var tf:TextFormat = new TextFormat;
			tf.align = "center";
			title.defaultTextFormat = tf;
			title.setTextFormat( tf );
			
			mess.y = -baloonAreaHeight+20;
			
			title.defaultTextFormat = defaulttf;
			
			ResizeWatcher.addDependent(this);
			this.visible = true;
			task.repeat();
		}
		public function showplain(ttl:String, msg:String, h:int=60):void
		{
			draw(h);
			
			title.y = -baloonAreaHeight;
			title.width = width-10;
			title.height = 20;
			
			mess.y = -baloonAreaHeight+20;
			mess.width = width-10;
			mess.height = baloonAreaHeight-20;
			
			title.htmlText = "<b><font face='Tahoma' size='12' color='#"+COLOR.SATANIC_GREY.toString(16)+"'>" + LOC.loc(ttl) + "</font></b>";;
			mess.htmlText = "<font face='Tahoma' size='11' color='#"+COLOR.SATANIC_GREY.toString(16)+"'>" + LOC.loc(msg) + "</font>";
			ResizeWatcher.addDependent(this);
			this.visible = true;
			task.repeat();
		}
		public function shownote(msg:String, h:int=30):void
		{
			draw(h);
			
			title.y = -baloonAreaHeight;
			title.width = 0;
			title.height = 0;
			title.text = "";
			
			mess.y = -baloonAreaHeight + 5;
			mess.width = width-10;
			mess.height = baloonAreaHeight-5;
			mess.htmlText = "<font face='Tahoma' size='11' color='#"+COLOR.SATANIC_GREY.toString(16)+"'>" + LOC.loc(msg) + "</font>";
			
			if( mess.height < mess.textHeight ) {
				shownote( msg, mess.numLines * 14 + 10 );
				return;
			}
			
			ResizeWatcher.addDependent(this);
			this.visible = true;
			task.repeat();
		}
		public function close():void
		{
			this.visible = false;
			ResizeWatcher.removeDependent(this);
			this.alpha = 1;
			task.stop();
			fade.stop();
		}
		public function localResize(w:int, h:int, real:Boolean=false):void
		{
			this.x = w - 80;
			this.y = h + 40;
		}
		private function draw(h:int):void
		{
			var w:int = 300;
			
			var comm:Vector.<int> = new Vector.<int>;
			comm.push( 1 );
			comm.push( 2 );
			comm.push( 2 );
			comm.push( 2 );
			var path:Vector.<Number> = new Vector.<Number>;
			path.push( (w-30)+0 );
			path.push( h+0 );
			path.push( (w-30)+19 );
			path.push( h+17 );
			path.push( (w-30)+19 );
			path.push( h+0 );
			path.push( (w-30)+0 );
			path.push( h+0 );
			
			bg.graphics.clear();
			bg.graphics.beginFill( COLOR.NAVI_MENU_LIGHT_BLUE_BG );
			bg.graphics.drawRoundRect(0,0, w, h, 10,10);
			bg.graphics.drawPath( comm, path );
			bg.filters = [new DropShadowFilter(0,0,COLOR.BLACK,1,2,2,1,1,false)];

			bg.y = -h;
			
			width = w;
			height = h+17;
			baloonAreaHeight = h;
		}
		private function closeSlowly():void
		{
			if (this.alpha >= 0) {
				this.alpha -= 0.05;
				fade.repeat();
			} else
				close();
		}
		private function onClick(e:Event):void
		{
			this.close();
		}
		private function onOver(e:Event):void
		{
			task.stop();
			fade.stop();
			this.alpha = 1;
		}
		private function onOut(e:Event):void
		{
			task.repeat();
			fade.stop();
		}
	}
}