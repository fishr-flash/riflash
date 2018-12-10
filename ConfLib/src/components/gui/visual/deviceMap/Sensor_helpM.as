package components.gui.visual.deviceMap
{
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import mx.core.UIComponent;
	
	import components.abstract.functions.loc;
	
	public class Sensor_helpM extends UIComponent
	{
		private var exit_on:Sensor_root_module;
		private var exit_off:Sensor_root_module;
		
		private var triggerDark:Sensor_root_module;
		private var normal:Sensor_root_module;
		private var normalDark:Sensor_root_module;
		private var lost:Sensor_root_module;
		private var lostDark:Sensor_root_module;
		
		protected var globalY:int;
		
		private var tTrigger:TextField;
		private var tNormal:TextField;
		private var tLost:TextField;
		
		protected var tf:TextFormat;
		private var battery_on:Sensor_root_module;
		private var battery_low:Sensor_root_module;
		private var battery_missing:Sensor_root_module;
		private var power_on:Sensor_root_module;
		private var power_off:Sensor_root_module;
		private var exit_on_dark:Sensor_root_module;
		private var exit_off_dark:Sensor_root_module;
		private var battery_on_dark:Sensor_root_module;
		private var battery_low_dark:Sensor_root_module;
		private var battery_missing_dark:Sensor_root_module;
		private var power_on_dark:Sensor_root_module;
		private var power_off_dark:Sensor_root_module;
		private var lost_dark:Sensor_root_module;
		private var found_dark:Sensor_root_module;
		private var tf_exit_on:TextField;
		private var tf_exit_off:TextField;
		private var tf_battery_on:TextField;
		
		
		public function Sensor_helpM()
		{
			super();
			
			construct();
		}
		private function construct():void 
		{
			
			var entities:Array =
			[
				createLegend( Sensor_root.STATE_NORMAL, loc("rfd_output")+ " " + loc( "g_disabled_m" ).toLocaleLowerCase() ),
				createLegend( Sensor_root.STATE_TRIGGER, loc("rfd_output")+ " " + loc( "g_enabled_m" ).toLocaleLowerCase() ),
				createLegend( Sensor_root.STATE_NORMAL,  loc("rfd_tamper")+ " " + loc( "his_closed" ).toLocaleLowerCase()  ),
				createLegend( Sensor_root.STATE_TRIGGER, loc("rfd_tamper")+ " " + loc( "his_opened" ).toLocaleLowerCase()  ),
				createLegend( Sensor_root.STATE_NORMAL, loc("sensor_battery")+ " " + loc( "sensor_norm" ).toLocaleLowerCase()  ),
				createLegend( Sensor_root.STATE_TRIGGER, loc("sensor_battery")+ " " + loc( "deep_discharge" ).toLocaleLowerCase()  ),
				createLegend( Sensor_root.STATE_NOTEXIST, loc("sensor_battery")+ " " + loc( "is_out" ).toLocaleLowerCase()    ),
				createLegend( Sensor_root.STATE_NORMAL, loc("out_ext_power_ok")  ),
				createLegend( Sensor_root.STATE_TRIGGER, loc("out_ext_power_off") ),
				createLegend( Sensor_root.STATE_LOST, loc("rfd_module_lost", true) ),
				createLegend( Sensor_root.STATE_FOUND, loc("ui_rfmodule_padejr", true)+ " " +  loc("ui_rfmodule_found").toLocaleLowerCase() )
			];
			
		
			
			
		}
		
		private function createLegend( state:int, title:String):Object
		{
			var cell:Sensor_root_module;
			createConveyor( cell =  new Sensor_root_module );
			cell.setState( state );
			cell.setDark();
			
			var cellDark:Sensor_root_module
			createConveyor( cellDark =  new Sensor_root_module );
			cellDark.setState( state );
			//cellDark.setDark();
			cellDark.y = cell.y;
			cellDark.x = cell.getWidth();
			
			globalY += cell.getHeight() + 1;
			
			var tf:TextField =  new TextField;
			addChild( tf );
			tf.defaultTextFormat = new TextFormat( "Verdana", null, null, true );
			tf.text = "- "+ title;
			tf.x = cellDark.x + cellDark.getWidth() + 20;
			tf.y = cell.y;
			tf.width = tf.textWidth + 5;
		
			return { cell:cell, cellDark:cellDark, title:tf };
			
		}
		
		public function set title(value:String):void
		{
			/*tLost.text = "-"+value;
			tLost.width = tLost.textWidth + 15;*/
		}
		protected function createConveyor( _sen:Sensor_root_module ):void 
		{
			addChild( _sen );
			_sen.y = globalY;
			
		}
	}
}