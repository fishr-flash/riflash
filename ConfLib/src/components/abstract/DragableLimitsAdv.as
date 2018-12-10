package components.abstract
{
	import flash.display.DisplayObject;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import mx.core.UIComponent;
	
	import components.abstract.servants.TabOperator;
	import components.events.AccEvents;
	import components.gui.SimpleTextField;
	import components.gui.limits.LimitGuideLineHU;
	import components.interfaces.IFormString;
	import components.static.COLOR;
	import components.system.SavePerformer;
	
	public final class DragableLimitsAdv
	{
		private var hLimits:Vector.<LimitGuideLineHU>;
		private var dragTarget:LimitGuideLineHU;
		private var lastTarget:LimitGuideLineHU;
		private var dragRectH:Rectangle;
		private var GRAPH_HEIGHT:int = 200;
		
		private var ui:UIComponent;
		private var ty:int;
		private var fields:Vector.<IFormString>;
		private var point:Point;
		private var getTo:Function;
		private var getFrom:Function;
		private var stage:Stage;
		
		private var colors:Array;
		private var _visible:Boolean=true;
		private var tf:Vector.<SimpleTextField>;
		
		public function DragableLimitsAdv(c:UIComponent, flds:Array, p:Point, fto:Function, ffrom:Function, measure:String=null, dragable:Boolean=true)
		{
			ui = c;
			point = p;
			getTo = fto;
			getFrom = ffrom;
			
			fields = new Vector.<IFormString>;
			
			var len:int = flds.length;
			for (var i:int=0; i<len; i++) {
				fields.push( flds[i] );
				(fields[i] as EventDispatcher).addEventListener( Event.CHANGE, onChange );
			}
			var GRAPH_WIDTH:int = 600;
			
			hLimits = new Vector.<LimitGuideLineHU>;
			dragRectH = new Rectangle( point.x,point.y,0,GRAPH_HEIGHT);
			for (i=0; i<len; ++i) {
				hLimits[i] = new LimitGuideLineHU( GRAPH_WIDTH, COLOR.BLACK );
				hLimits[i].rect = dragRectH;
				hLimits[i].getFunction = getTo;
				if (measure is String)
					hLimits[i].customMeasure = measure;
				register( hLimits[i], dragable );
			}
			colors = [COLOR.BLUE,COLOR.RED];
		}
		/** title:string, align:string, color:uint, xpos:int, width:int, top:boolean	*/
		public function sign(a:Array):void
		{
			tf = new Vector.<SimpleTextField>;
			var t:SimpleTextField;
			var len:int = a.length;
			for (var i:int=0; i<len; i++) {
				t = new SimpleTextField(a[i].title);
				if (a[i].align)
					t.setSimpleFormat(a[i].align);
				if (a[i].xpos)
					t.x = a[i].xpos;
				if (a[i].color)
					t.textColor = a[i].color;
				if (a[i].width)
					t.width = a[i].width;
				if (a[i].top)
					t.y = -21;
				tf.push( t );
				hLimits[i].addChild( t );
			}
		}
		public function changeRectangle(top:Number, bottom:Number ):void
		{	// изменяет баундинг бокс для перетаскивания
			hLimits[0].rect = new Rectangle(point.x,top,0,bottom-top);
		}
		public function getSign(n:int):SimpleTextField
		{
			return tf[n];
		}
		public function set visible(b:Boolean):void
		{
			if (_visible != b) {
				var len:int = hLimits.length;
				for (var i:int=0; i<len; i++) {
					hLimits[i].visible = b;	
				}
				_visible = b;
			}
		}
		public function useCustomColors(a:Array):void
		{
			colors = a;
		}
		public function init(a:Array):void
		{
			if (!stage)
				stage = ui.stage;
			stage.addEventListener( MouseEvent.MOUSE_UP, mUp );
			
			moveLimits(a);
		}
		public function moveLimits(a:Array):void
		{
			var len:int = a.length;
			for (var i:int=0; i<len; i++) {
				moveLine( hLimits[i], a[i] );
			}
			colorizeHLimits(false);
		}
		public function close():void
		{
			stage.addEventListener( MouseEvent.MOUSE_UP, mUp );
		}
		private function onChange(e:Event):void
		{
			var len:int = fields.length;
			for (var i:int=0; i<len; i++) {
				moveLine( hLimits[i], int(fields[i].getCellInfo()) );
			}
			colorizeHLimits(false,false);
		}
		private function moveLine(t:LimitGuideLineHU, value:Number):void
		{
			t.y = getFrom(value);
			if (t.y < dragRectH.y)
				t.y = dragRectH.y;
			t.x = point.x;
			if (t.y > dragRectH.y + dragRectH.height)
				t.y = dragRectH.y + dragRectH.height;
			t.updateCoords();
		}
		private function register(d:DisplayObject, dragable:Boolean):void
		{
			if( dragable )
				d.addEventListener( MouseEvent.MOUSE_DOWN, mDown );
			d.addEventListener( Event.SELECT, onSelect );
			ui.addChild( d );
			d.x = 0;
		}
		private function mDown(e:MouseEvent):void
		{
			dragTarget = e.currentTarget as LimitGuideLineHU;
			
			if (dragTarget is LimitGuideLineHU && dragTarget.limit > dragTarget.mouseX) {
				dragTarget = null;
				return;
			}
			TabOperator.getInst().iNeedFocus(dragTarget);
			
			dragTarget.select = true;
			if (lastTarget && dragTarget != lastTarget)
				lastTarget.select = false;
			
			ui.setChildIndex( dragTarget, ui.numChildren-1 );
			dragTarget.dragging = true;
			dragTarget.startDrag(false, dragTarget.rect);
			dragTarget.addEventListener( AccEvents.onSharedGuideLineMove, limitMove );
			lastTarget = null;
		}
		private function mUp(e:MouseEvent):void
		{
			if (dragTarget) {
				dragTarget.dragging = false;
				dragTarget.stopDrag();
				dragTarget.updateCoords();
				colorizeHLimits(true);
				dragTarget.removeEventListener( AccEvents.onSharedGuideLineMove, limitMove );
			} else {
				if (lastTarget)
					lastTarget.select = false;
			}
			lastTarget = dragTarget;
			dragTarget = null;
		}
		private function onSelect(e:Event):void
		{
			var o:Object = e.currentTarget;
			lastTarget = e.currentTarget as LimitGuideLineHU;
			dragTarget = null;
		}
		private function limitMove(ev:Event):void
		{
			if (dragTarget)
				colorizeHLimits(true);
		}
		private function colorizeHLimits(save:Boolean=true, change:Boolean=true):void
		{
			var max:LimitGuideLineHU;
			var min:LimitGuideLineHU;
			var a:Array = [];
			var len:int = hLimits.length;
			for (var i:int=0; i<len; ++i) {
				hLimits[i].color = colors[0];
				if (!max || max.y < hLimits[i].y)
					max = hLimits[i];
				if (!min || min.y > hLimits[i].y)
					min = hLimits[i];
				if (a)
					a.push(hLimits[i].y);
			}
			min.color = colors[1];//COLOR.RED;
			max.color = colors[0];//COLOR.BLUE;
			if (a && change) {
				a = a.sort( Array.NUMERIC );
				for (i=0; i<fields.length; ++i) {
					fields[i].setCellInfo( getTo(a[i])/100 );
					if (save)
						SavePerformer.remember( 1, fields[i] );
				}
			}
		}
	}
}