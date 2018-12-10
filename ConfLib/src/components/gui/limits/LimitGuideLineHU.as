package components.gui.limits
{
	import flash.events.Event;
	
	import components.abstract.functions.loc;
	import components.events.AccEvents;
	import components.interfaces.IFocusable;
	
	public class LimitGuideLineHU extends LimitGuideLineH implements IFocusable
	{
		public var getFunction:Function;
		public var customMeasure:String;
		
		public function LimitGuideLineHU(_w:int, c:int)
		{
			super(_w, c);
			value.width = 80;
		}
		override public function updateCoords(ev:Event=null):void
		{
			var result:Number;
			if (getFunction is Function)
				result = Number( Number( getFunction( this.y )/100 ).toFixed( 1 ) );
			else
				result = this.y;
			
			
			this.text = result +" "+ (customMeasure is String ? customMeasure : loc("measure_volt_1l"));
			this.dispatchEvent( new AccEvents( AccEvents.onSharedGuideLineMove, this.y));
		}
		override public function doAction(key:int,ctrl:Boolean=false, shift:Boolean=false):void		
		{
			this.dispatchEvent( new Event( Event.SELECT));
			trace("LIMIT "+key);
		}
	}
}