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
	import components.gui.limits.LimitGuideLineHU;
	import components.interfaces.IFormString;
	import components.static.COLOR;
	import components.system.SavePerformer;

	public final class DragableLimits
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
		
		public function DragableLimits(c:UIComponent, flds:Array, p:Point, fto:Function, ffrom:Function, measure:String=null, dragable:Boolean=true)
		{
			ui = c;
			point = p;
			getTo = fto;
			getFrom = ffrom;
			
			fields = new Vector.<IFormString>;
			fields.push( flds[0] );
			(fields[0] as EventDispatcher).addEventListener( Event.CHANGE, onChange );
			fields.push( flds[1] );
			(fields[1] as EventDispatcher).addEventListener( Event.CHANGE, onChange );
			
			
			var GRAPH_WIDTH:int = 600;
			
			hLimits = new Vector.<LimitGuideLineHU>;
			dragRectH = new Rectangle( point.x,point.y,0,GRAPH_HEIGHT);
			for (var i:int=0; i<2; ++i) {
				hLimits[i] = new LimitGuideLineHU( GRAPH_WIDTH, COLOR.BLACK );
				hLimits[i].rect = dragRectH;
				hLimits[i].getFunction = getTo;
				if (measure is String)
					hLimits[i].customMeasure = measure;
				register( hLimits[i], dragable );
			}
		}
		public function init(a:Array):void
		{
			if (!stage)
				stage = ui.stage;
			stage.addEventListener( MouseEvent.MOUSE_UP, mUp );
			
			moveLine( hLimits[0], a[0] );
			moveLine( hLimits[1], a[1] );
			
			colorizeHLimits(false);
		}
		public function close():void
		{
			stage.addEventListener( MouseEvent.MOUSE_UP, mUp );
		}
		private function onChange(e:Event):void
		{
			moveLine( hLimits[0], int(fields[0].getCellInfo()) );
			moveLine( hLimits[1], int(fields[1].getCellInfo()) );
			
			colorizeHLimits(false);
		}
		private function moveLine(t:LimitGuideLineHU, value:Number):void
		{
			t.y = getFrom(value);
			t.x = point.x;
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
		private function colorizeHLimits(save:Boolean=true):void
		{
			var max:LimitGuideLineHU;
			var min:LimitGuideLineHU;
			var a:Array = [];
			for (var i:int=0; i<2; ++i) {
				hLimits[i].color = COLOR.BLUE;
				if (!max || max.y < hLimits[i].y)
					max = hLimits[i];
				if (!min || min.y > hLimits[i].y)
					min = hLimits[i];
				if (a)
					a.push(hLimits[i].y);
			}
			min.color = COLOR.RED;
			max.color = COLOR.BLUE;
			if (a) {
				a = a.sort( Array.NUMERIC );
				for (i=0; i<2; ++i) {
					fields[i].setCellInfo( getTo(a[i])/100 );
					if (save)
						SavePerformer.remember( 1, fields[i] );
				}
			}
		}
	}
}