package components.gui.visual.deviceMap
{
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import mx.core.UIComponent;
	
	import components.abstract.functions.loc;
	
	public class Sensor_help extends UIComponent
	{
		private var trigger:Sensor_root;
		private var triggerDark:Sensor_root;
		private var normal:Sensor_root;
		private var normalDark:Sensor_root;
		private var lost:Sensor_root;
		private var lostDark:Sensor_root;
		
		protected var globalY:int;
		
		private var tTrigger:TextField;
		private var tNormal:TextField;
		private var tLost:TextField;
		
		protected var tf:TextFormat;
		
		public function Sensor_help()
		{
			super();
			
			construct();
		}
		private function construct():void 
		{
			createConveyor( trigger = new Sensor_root );
			trigger.setState( Sensor_root.STATE_TRIGGER );
			
			createConveyor( normal = new Sensor_root );
			normal.setState( Sensor_root.STATE_NORMAL);
			
			createConveyor( lost = new Sensor_root );
			lost.setState( Sensor_root.STATE_LOST);
			
			globalY = 0;
			
			createConveyor( triggerDark = new Sensor_root );
			triggerDark.setDark();
			triggerDark.setState( Sensor_root.STATE_TRIGGER );
			triggerDark.x = trigger.getWidth();
			
			createConveyor( normalDark = new Sensor_root );
			normalDark.setDark();
			normalDark.setState( Sensor_root.STATE_NORMAL);
			normalDark.x = normal.getWidth();
			
			createConveyor( lostDark = new Sensor_root );
			lostDark.setDark();
			lostDark.setState( Sensor_root.STATE_LOST );
			lostDark.x = lost.getWidth();
			
			tf = new TextFormat;
			tf.bold = true;
			tf.font = "Verdana";
			
			tTrigger =  new TextField;
			addChild( tTrigger );
			tTrigger.defaultTextFormat = tf;
			tTrigger.text = "-"+loc("rfd_trigger");
			tTrigger.x = triggerDark.x + triggerDark.getWidth() + 20;
			tTrigger.y = trigger.y;
			tTrigger.width = tTrigger.textWidth + 5;
			
			tNormal = new TextField;
			addChild( tNormal );
			tNormal.defaultTextFormat = tf;
			tNormal.text = "-"+loc("rfd_norm");
			tNormal.x = triggerDark.x + triggerDark.getWidth() + 20;
			tNormal.y = normal.y;
			tNormal.width = tTrigger.textWidth + 5;
			
			tLost = new TextField;
			addChild( tLost );
			tLost.defaultTextFormat = tf;
			tLost.text = "-"+loc("rfd_lost");
			tLost.x = triggerDark.x + triggerDark.getWidth() + 20;
			tLost.y = lost.y;
			tLost.width = tLost.textWidth + 15;
		}
		public function set title(value:String):void
		{
			tLost.text = "-"+value;
			tLost.width = tLost.textWidth + 15;
		}
		protected function createConveyor( _sen:Sensor_root ):void 
		{
			addChild( _sen );
			_sen.y = globalY;
			globalY += _sen.getHeight();
		}
	}
}