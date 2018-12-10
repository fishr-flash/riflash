package components.abstract
{
	import flash.display.DisplayObject;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	public class WeakTimer extends EventDispatcher
	{
		public function WeakTimer( weakOwner:DisplayObject, target:IEventDispatcher=null)
		{
			//implement function
			super(target);
		}
	}
}