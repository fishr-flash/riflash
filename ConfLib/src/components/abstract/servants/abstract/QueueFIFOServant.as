package components.abstract.servants.abstract
{
	public class QueueFIFOServant
	{
		private var queue:Vector.<Object>;
		
		public function QueueFIFOServant()
		{
			queue = new Vector.<Object>;
		}
		public function put(callback:Function, args:Object):void
		{
			queue.push( {callback:callback, args:args} )
		}
		protected function take():Object
		{
			if (queue.length)
				return queue.shift();
			return null;
		}
	}
}
