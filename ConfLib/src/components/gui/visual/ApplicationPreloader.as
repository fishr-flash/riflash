package components.gui.visual
{
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	
	import mx.core.Application;
	import mx.core.FlexGlobals;
	import mx.events.FlexEvent;
	import mx.preloaders.IPreloaderDisplay;
	
	import components.abstract.servants.TaskManager;
	import components.gui.SimpleTextField;
	import components.interfaces.IFounder;
	import components.static.COLOR;
	
	public class ApplicationPreloader extends Sprite implements IPreloaderDisplay
	{
		private const ttlWidth:int= 300;
		private const ttlHeight:int = 50;
		private const totalLoadWidth:int = 292;
		
		private var bg:Shape;
		private var pbar:Shape;
		private var maskshape:Shape;
		private var tbytes:SimpleTextField;
		private var tBlue:SimpleTextField;
		private var tGrey:SimpleTextField;
		private var _preloader:Sprite;
		private var preloaderbg:Shape;
		private var w:Number = 0;
		private var h:Number = 0;
		
		private var appInitComplete:Boolean;
		private var appPreloadComplete:Boolean;
		
		public function ApplicationPreloader()
		{
			super();
			
			preloaderbg = new Shape;
			addChild( preloaderbg );
			
			bg = new Shape;
			addChild( bg );
			bg.graphics.beginFill( COLOR.MENU_ITEM_BLUE );
			bg.graphics.drawRect(0,0,300,30);
			bg.graphics.endFill();
			bg.graphics.beginFill( COLOR.NAVI_MENU_LIGHT_BLUE_BG );
			bg.graphics.drawRect(2,2,296,26);
			bg.graphics.endFill();
			
			pbar = new Shape;
			addChild( pbar );
			
			maskshape = new Shape;
			addChild( maskshape );

			tBlue = new SimpleTextField("", 300, COLOR.MENU_ITEM_BLUE);
			tBlue.setSimpleFormat("center",0,16,true);
			tBlue.height = 20;
			tBlue.y = 4;
			addChild( tBlue );

			tGrey = new SimpleTextField("", 300, COLOR.NAVI_MENU_LIGHT_BLUE_BG);
			tGrey.setSimpleFormat("center",0,16,true);
			tGrey.height = 20;
			tGrey.y = 4;
			addChild( tGrey );
			
			tGrey.mask = maskshape;
			
			tbytes = new SimpleTextField("", 300, COLOR.MENU_ITEM_BLUE);
			tbytes.setSimpleFormat("right");
			tbytes.height = 20;
			tbytes.y = 30; 
			addChild( tbytes );
			
			appInitComplete = false;
			appPreloadComplete = false;
			
		//	(FlexGlobals.topLevelApplication as Application).addEventListener(FlexEvent.
			
		}
		public function get backgroundAlpha():Number
		{
			return 0;
		}
		public function set backgroundAlpha(value:Number):void
		{
		}
		public function get backgroundColor():uint
		{
			return COLOR.CIAN;
		}
		public function set backgroundColor(value:uint):void
		{
		}
		public function get backgroundImage():Object
		{
			return null;
		}
		public function set backgroundImage(value:Object):void
		{
		}
		public function get backgroundSize():String
		{
			return null;
		}
		public function set backgroundSize(value:String):void
		{
		}
		public function initialize():void
		{
			trace("ApplicationPreloader.initialize()");
			
		}
		public function set preloader(p:Sprite):void
		{
			_preloader = p;
			
			_preloader.addEventListener(ProgressEvent.PROGRESS, handleProgress); 
			_preloader.addEventListener(Event.COMPLETE, handleComplete);
			
			_preloader.addEventListener(FlexEvent.INIT_PROGRESS, handleInitProgress);
			_preloader.addEventListener(FlexEvent.INIT_COMPLETE, handleInitComplete);
		}
		public function get stageHeight():Number
		{
			return h;
		}
		
		public function set stageHeight(value:Number):void
		{
			h = value;
			resize();
		}
		public function get stageWidth():Number
		{
			return w;
		}
		
		public function set stageWidth(value:Number):void
		{
			w = value;
			resize();
			
		}
		private function resize():void
		{
			if (w > 0 && h > 0) { 
				this.x = int(w/2 - ttlWidth/2);
				this.y = int(h/2 - ttlHeight);
				
				preloaderbg.graphics.clear();
				preloaderbg.graphics.beginFill( COLOR.NAVI_MENU_LIGHT_BLUE_BG );
				preloaderbg.graphics.drawRect(-int(w/2 - ttlWidth/2),-int(h/2 - ttlHeight),w,h);
				preloaderbg.graphics.endFill();
			}
		}
		private function handleProgress(e:ProgressEvent):void
		{
			if (stage) {
				w = stage.stageWidth;
				h = stage.stageHeight;
				resize();
			}
			
			if (e.bytesTotal == 0 ) {
				
				tBlue.text = "?";
				tGrey.text = "?";
				
				pbar.graphics.clear();
				pbar.graphics.beginFill( COLOR.MENU_ITEM_BLUE);
				pbar.graphics.drawRect(4,4,totalLoadWidth,22);
				
				maskshape.graphics.clear();
				maskshape.graphics.beginFill( COLOR.MENU_ITEM_BLUE);
				maskshape.graphics.drawRect(4,4,totalLoadWidth,22);
				
				tbytes.text = (e.bytesLoaded/1024).toFixed() + " KB";
				
			} else {
				var prog:String = Math.ceil((e.bytesLoaded/e.bytesTotal)*100) + "%";
				
				tBlue.text = prog;
				tGrey.text = prog;
				
				pbar.graphics.clear();
				pbar.graphics.beginFill( COLOR.MENU_ITEM_BLUE);
				pbar.graphics.drawRect(4,4,Math.ceil(totalLoadWidth*(e.bytesLoaded/e.bytesTotal)),22);
				
				maskshape.graphics.clear();
				maskshape.graphics.beginFill( COLOR.MENU_ITEM_BLUE);
				maskshape.graphics.drawRect(4,4,Math.ceil(totalLoadWidth*(e.bytesLoaded/e.bytesTotal)),22);
				
				tbytes.text = (e.bytesLoaded/1024).toFixed() +" / "+ (e.bytesTotal/1024).toFixed() + " KB";
			}
		}
		private function handleComplete(e:Event):void
		{
			_preloader.removeEventListener(ProgressEvent.PROGRESS, handleProgress); 
			_preloader.removeEventListener(Event.COMPLETE, handleComplete);
			_preloader.removeEventListener(FlexEvent.INIT_PROGRESS, handleInitProgress);
			
			appPreloadComplete = true;
			complete();
		}
		private function complete():void
		{
			if (appInitComplete && appPreloadComplete)
				dispatchEvent(new Event(Event.COMPLETE));
		}
	
		private function handleInitProgress(e:Event):void
		{
		}
		private function handleInitComplete(e:Event):void
		{
			_preloader.removeEventListener(FlexEvent.INIT_COMPLETE, handleInitComplete);
			appInitComplete = true;
			complete();
		}
	}
}