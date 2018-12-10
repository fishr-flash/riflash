package components.abstract.sysservants
{
	import flash.events.Event;
	
	import components.protocol.statics.OPERATOR;
	import components.system.SysManager;

	public class Smoothloader
	{
		public var VISUAL_LOADED:Number;
		public var TOTAL:int;
		public var LOADED:int;
		
		private var onProgress:Function;
		private var sliced:Object;
		private var CLOSING:Boolean=false;
		
		public function Smoothloader(fOnProgress:Function)
		{
			onProgress = fOnProgress;
		}
		public function start():void
		{
			if (TOTAL<=LOADED) {
				TOTAL = 0;
				LOADED = 0;
				VISUAL_LOADED = 0;
				SysManager.getStage().addEventListener(Event.ENTER_FRAME, onFrame);
				sliced = new Object;
			}
		}
		public function close():void
		{
			CLOSING = true;
		}
		public function abort():void
		{
			terminate();			
		}
		public function put(cmd:int):void
		{
			TOTAL += OPERATOR.getSchema(cmd).GetReadCommandSize(true);
		}
		public function update(cmd:int, wholecmd:Boolean, s:int):void
		{
			if (wholecmd && sliced[cmd] != null)
				return;
			
			var add:int;
			if (wholecmd && sliced[cmd] == null ) {
				 add = OPERATOR.getSchema(cmd).GetReadCommandSize(true);
				// dtrace(OPERATOR.getSchema(cmd).Name + " " + add)
				 LOADED += add;
			} else {
				add = OPERATOR.getSchema(cmd).GetReadStructSize(true);
			//	dtrace(OPERATOR.getSchema(cmd).Name + " " + add)
				LOADED += add;
				sliced[cmd] = true;
			}
		//	dtrace(LOADED+"/"+TOTAL);
		}
		private function terminate():void
		{
			LOADED = TOTAL;
			VISUAL_LOADED = TOTAL;
			SysManager.getStage().removeEventListener(Event.ENTER_FRAME, onFrame);
		}
		private function onFrame(e:Event):void
		{
			// считается прогрессивная скорость движения ползунка
			var shift:Number = (LOADED - VISUAL_LOADED)*(LOADED - VISUAL_LOADED)/TOTAL/3;
			if (shift < TOTAL*0.02)
				shift = TOTAL*0.02;
			
			if (VISUAL_LOADED != LOADED ) {
				if (VISUAL_LOADED > LOADED || VISUAL_LOADED + shift > LOADED)
					VISUAL_LOADED = LOADED;
				else
					VISUAL_LOADED += shift;
			}
			onProgress();
			if (CLOSING && VISUAL_LOADED == TOTAL) {
				terminate();
			}
		}
	}
}