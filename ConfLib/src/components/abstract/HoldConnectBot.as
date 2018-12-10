package components.abstract
{
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.utils.getTimer;
	
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.static.CMD;

	public class HoldConnectBot
	{
		private const SIZE_STEP:int = ( ( 1000 * 60 ) * 4 ) + 40000; /// ms * (sec/min) * 4 min + 40 sec
		private var _countStep:int = 0;
		 
		private static var _self:HoldConnectBot;
		private var _dispatcher:DisplayObjectContainer;
		
		
		public function HoldConnectBot()
		{
			
		}

		public static function get self():HoldConnectBot
		{
			if( !_self ) _self = new HoldConnectBot;
			
			return _self;
		}
		
		public function run( place:DisplayObjectContainer ):void
		{
			
			
			
			
			_dispatcher = place;
			
			
			checkTime( null );
			_dispatcher.addEventListener(Event.ENTER_FRAME, checkTime );
			
			
		}
		
		protected function checkTime(event:Event):void
		{
			
			
			
			if( _dispatcher.stage )
			{
				
				
				if( getTimer() / SIZE_STEP > _countStep )
				{
					
					
					_countStep++;
					RequestAssembler.getInstance().fireEvent( new Request( CMD.HOLD_CONNECTION, null, 1, [ 5 ], 0, 1, 0xFF ) )
				}
				
				
			}
			else
			{
				if( _dispatcher ) _dispatcher.removeEventListener(Event.ENTER_FRAME, checkTime );
			}
		}		

	}
}