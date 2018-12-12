package components.gui
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.MouseEvent;
	
	import mx.containers.Canvas;
	import mx.core.UIComponent;
	
	import components.abstract.functions.dtrace;
	import components.interfaces.IFlexListItem;
	import components.protocol.Package;
	
	public class MFlexList extends UIComponent
	{
		public var allowComponentControlItsHeight:Boolean = true;
		
		protected var layer:Canvas;
		protected var list:Vector.<IFlexListItem>;
		protected var cls:Class;
		private var _disabled:Boolean;
		
		public static const EVENT_SELECT:String = "EVENT_SELECT";
		
		/** Dont forget so set height & width	*/
		public function MFlexList(c:Class)
		{
			super();
			
			cls = c;
			layer = new Canvas;
			addChild( layer );
		}

		public function get disabled():Boolean
		{
			return _disabled;
		}

		public function set disabled(value:Boolean):void
		{
			if( value == _disabled  ) return;
			
			_disabled = value;
			
			if( !list || !list.length ) return;
			
			var len:int = list.length;
			for (var i:int=0; i<len; i++) 
			{
				list[ i ].disabled = _disabled;	
			}
			
			
		}

		public function putPack(a:Array):void
		{
			var len:int = list.length;
			for (var i:int=0; i<len; i++) {
				try {
					list[i].putRaw( a[i] );
				} catch(error:Error) {
					dtrace("MFlexList error: putPack() outOfRange");
				}
			}
		}
		public function put(p:Package, clear:Boolean=true, evokeSave:Boolean=false):void
		{
			var len:int = p.length;
			var i:int;
			if (clear || !list) {
				clearlist();
			
				list = new Vector.<IFlexListItem>;
				for (i=0; i<len; i++) {
					list.push( new cls(i+1) as IFlexListItem );
					
					(list[i] as EventDispatcher).addEventListener( MouseEvent.CLICK, onSelect );
					layer.addChild( list[i] as DisplayObject );
					list[i].y = list[i].height*i;
					if (evokeSave)
						list[i].change(p);
					else
						list[i].put(p);
				}
			} else {
				len = list.length; // может быть 1 структура но положена во все строки листа
				for (i=0; i<len; i++) {
					if (evokeSave)
						list[i].change(p);
					else
						list[i].put(p);
				}
			}
		}
		public function add(p:Package, forceStructureNumeration:Boolean=false):IEventDispatcher
		{
			if (!list)
				list = new Vector.<IFlexListItem>;
			var i:IFlexListItem;
			if( forceStructureNumeration )
				i = new cls(p.structure);
			else
				i = new cls(list.length);
			
			
			layer.addChild( i as DisplayObject );
			(i as EventDispatcher).addEventListener( MouseEvent.CLICK, onSelect );
			i.y = i.height*list.length;
			i.put(p);
			list.push(i as IFlexListItem);
			
			if (allowComponentControlItsHeight) {
				height = i.height*list.length;
				allowComponentControlItsHeight = true;
			}
			return i as IEventDispatcher;
		}
		public function removeSelected():int
		{
			var s:int;
			
			for (var i:int=0; i<list.length; i++) {
				if(list[i].isSelected()) {
					s = list[i].getStructure();
					(list[i] as EventDispatcher).removeEventListener( MouseEvent.CLICK, onSelect );
					layer.removeChild( list[i] as DisplayObject );
					list[i].kill();
					list.splice( i--, 1 );
					
				}
			}
			var c:int;
			for (i=0; i<list.length; i++) {
				if(list[i])
					list[i].y = list[i].height*c;
				c++;
			}
			return s;
			
			/*
			var i:IFlexListItem = list.pop();
			(i as EventDispatcher).removeEventListener( MouseEvent.CLICK, onSelect );
			layer.removeChild( i as DisplayObject );
			*/
		}
		public function clearlist():void
		{
			if (list) {
				
				var dob:DisplayObject;
				
				while( list.length )
				{
					
					
					dob = list.shift() as DisplayObject ;
					
					if( dob.parent )dob.parent.removeChild( dob );
					dob.removeEventListener( MouseEvent.CLICK, onSelect );
					( dob as IFlexListItem ).kill();
				}
						
					
				
			}
			list = null;
		}
		override public function set width(value:Number):void
		{
			
			layer.width = value;
			super.width = value;
		}
		override public function set height(value:Number):void
		{
			super.height = value;
			layer.height = value;
			allowComponentControlItsHeight = false;
		}
		public function get length():int
		{
			if (list)
				return list.length;
			return 0;
		}
		public function getActualHeight():int
		{
			if (list && list.length)
				return list[0].height*list.length;
			return 0;
		}
		public function extract():Array
		{
			var a:Array = [];
			if( list )
			{
				var len:int = list.length;
				for (var i:int=0; i<len; i++) {
					if (list[i])
						a.push( list[i].extract() );
				}
			}
			
			return a;
		}
		public function getLine(n:int):IFlexListItem
		{
			if (list && list[n])
				return list[n];
			return null;
		}
		protected function onSelect(e:Event):void
		{
			/*var len:int = list.length;
			for (var i:int=0; i<len; i++) {
				if (list[i])
					list[i].selectLine = e.currentTarget == list[i];
			}*/
		}
		
		public function indexOf( elem:IFlexListItem ):int
		{
			return list.indexOf( elem ); 
		}
	}
}