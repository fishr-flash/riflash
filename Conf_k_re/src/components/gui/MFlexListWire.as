package components.gui
{
	import flash.display.DisplayObject;
	import flash.events.IEventDispatcher;
	
	import components.protocol.Package;
	import components.static.DS;

	public class MFlexListWire extends MFlexList
	{
		public function MFlexListWire(c:Class)
		{
			super(c);
			
			
		}
		
		private function shadowK5A():void
		{
			//if ( !DS.isDevice(DS.K5A) && !DS.isDevice(DS.K5GL))return;
			if (  DS.isfam( DS.K5, DS.K5A,  DS.K5GL  ) || DS.isfam( DS.K9 ) )return;
				
			if (list) {
				var len:int = list.length;
				var i:int;
				
				var start:int = 8;
				
				for (i=start; i<len; i++) {
					
					(list[i] as DisplayObject).y = (list[ start ] as DisplayObject).y;
					if( (list[i] as DisplayObject).parent )
						(list[i] as DisplayObject).parent.removeChild( list[ i ] as DisplayObject );
					
				}
				
				this.height = (list[ start ] as DisplayObject).y;
				
			}
		}
		
		override public function put(p:Package, clear:Boolean=true, evokeSave:Boolean=false):void
		{
			super.put( p, clear, evokeSave );
			
			
				shadowK5A();
		}
		
		override public function putPack(a:Array):void
		{
			super.putPack( a );
			
			
				shadowK5A();
		}
		
		override public function add(p:Package, forceStructureNumeration:Boolean=false):IEventDispatcher
		{
			const ieDispatcher:IEventDispatcher = super.add( p, forceStructureNumeration );
			
			
				shadowK5A();
			
			return ieDispatcher;
		}
			
		public function compact(b:Boolean):void
		{
			
			
			if (list) {
				
				var len:int = list.length;
				var i:int;
				
				var start:int;
				if (DS.isfam( DS.K9 ) )
				{
					start = 3;
				}
				else if ( DS.isfam( DS.K5, DS.K5A, DS.K5GL )  )
				{
					start = 8;	
					
				}
				else
				{
					start = 4;
					len = 8;
				}
				
				
				if (b) {
					
					for (i=start; i<len; i++) {
						(list[i] as DisplayObject).visible = false;
					}
				} else {
					for (i=start; i<len; i++) {
						(list[i] as DisplayObject).visible = true;
					}
				}
			}
		}
	}
}