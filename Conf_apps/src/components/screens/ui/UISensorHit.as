package components.screens.ui
{
	import components.abstract.functions.loc;
	import components.abstract.servants.TaskManager;
	import components.basement.UI_BaseComponent;
	import components.gui.fields.FSColorSlider;
	import components.gui.fields.FSShadow;
	import components.gui.triggers.TextButton;
	import components.interfaces.IFormString;
	import components.interfaces.ITask;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.static.CMD;
	
	public class UISensorHit extends UI_BaseComponent
	{
		private const MAX_RANGE:int = 40;
		private const MIN_RANGE:int = 0;
		private const RESET:int = 1;
		private const MAX:int = 2;
		
		private var bReset:TextButton;
		private var bMaxStrike:TextButton;
		private var task:ITask;
		private var spamtask:ITask;
		private var maxACP:int;
		private var maxFloatACP:int;
		private var queue:Vector.<int>;
		
		public function UISensorHit(group:int=0)
		{
			super();
			
			var shift:int = 300;
			
			addui( new FSShadow, CMD.VR_SENSOR_SC, "", null, 1 );
			addui( new FSShadow, CMD.VR_SENSOR_SC, "", null, 2 );
			
			createUIElement( new FSColorSlider, CMD.VR_SENSOR_SC, loc("acc_hit_conditionally"), onAlarmStrike, 3, [{data:MIN_RANGE, label:loc("g_min")},{data:MAX_RANGE, label:loc("g_max")}] );
			attuneElement( shift,NaN,FSColorSlider.F_SLIDER_NONOTATION | FSColorSlider.F_SLIDER_ACCURATE );
			(getLastElement() as FSColorSlider).update( 0 );
			globalY += 10;
			FLAG_VERTICAL_PLACEMENT = false;
			FLAG_SAVABLE = false;
			createUIElement( new FSColorSlider, 0, loc("acc_max_hit_value"), null, 1, [{data:MIN_RANGE, label:loc("g_min")},{data:MAX_RANGE, label:loc("g_max")}] );
			attuneElement( shift,NaN,FSColorSlider.F_SLIDER_NONOTATION | FSColorSlider.F_SLIDER_NOTEDITABLE );
			(getLastElement() as FSColorSlider).update( 0 );
			FLAG_VERTICAL_PLACEMENT = true;
			globalY += 10;
			
			bReset = new TextButton;
			addChild( bReset );
			bReset.setUp(loc("g_reset"), callLogic, RESET );
			bReset.y = globalY-15;
			bReset.x = globalX + shift + 200 + 50;
			bReset.focusgroup = 0;
			
			globalY += 30;
			
			bMaxStrike = new TextButton;
			addChild( bMaxStrike );
			bMaxStrike.setUp(loc("acc_sensor_max"), callLogic, MAX );
			bMaxStrike.y = globalY;
			bMaxStrike.x = globalX;
			bMaxStrike.focusgroup = 0;
			
			starterCMD = CMD.VR_SENSOR_SC;
		}
		override public function put(p:Package):void
		{
			distribute(p.getStructure(), p.cmd);
			task = TaskManager.callLater( requestVector, 250 );
			spamtask = TaskManager.callLater( onTick, 250 );
			queue = new Vector.<int>;
			loadComplete();
		}
		override public function close():void
		{
			super.close();
			if(task)
				task.kill();
			if(spamtask)
				spamtask.kill();
		}
		private function requestVector():void
		{
			if ( task && this.visible)
				RequestAssembler.getInstance().fireEvent( new Request(CMD.VECTOR_ACC, onVector));
		}
		private function onVector(p:Package):void
		{
			var len:int = p.length;
			for (var i:int=0; i<len; i++) {
				queue.push( p.data[i][4] );
				if (p.data[i][4] > maxACP) {
					maxACP = p.data[i][4] < 1 ? 1 : p.data[i][4];
					(getField(0,1) as FSColorSlider).update( ((maxACP/1024)*10)/MAX_RANGE );
					getField(0,1).setCellInfo( maxACP/1024*10 );
				}
			}
			task.repeat();
		}
		private function onTick():void
		{
			
			if (queue.length > 0) {
				if (queue[queue.length-1] > maxFloatACP)
					maxFloatACP = queue.pop();
				else {
					maxFloatACP -= 32;
					queue.pop();
				}
				if (maxFloatACP < 0)
					maxFloatACP = 0;
				(getField(CMD.VR_SENSOR_SC,3) as FSColorSlider).update( ((maxFloatACP)/1024*10)/MAX_RANGE );
			}
			if (queue.length < 5)
				spamtask.delay = 50;
			else
				spamtask.delay = 30;
			spamtask.repeat();
		}
		private function callLogic(n:int):void
		{
			//AccEngine.vectorDistibute(
			switch(n) {
				case RESET:
					maxACP = 0;
					getField(0,1).setCellInfo( MIN_RANGE );
					(getField(0,1) as FSColorSlider).update(0);
					break;
				case MAX:
					getField(CMD.VR_SENSOR_SC,3).setCellInfo( (maxACP/1024)*10 );
					getField(0,1).setCellInfo( maxACP/1024*10 );
					remember( getField(CMD.VR_SENSOR_SC,3) );
					break;
			}
		}
		private function onAlarmStrike(t:IFormString):void
		{
			if(t)
				remember(t);
		}
	}
}