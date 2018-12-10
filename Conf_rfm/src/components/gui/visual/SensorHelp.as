package components.gui.visual
{
	import flash.display.Sprite;
	import flash.text.TextField;
	
	import components.abstract.functions.loc;
	import components.gui.SimpleTextField;
	import components.gui.visual.deviceMap.Sensor_help;
	import components.gui.visual.deviceMap.Sensor_root;
	import components.static.DS;

	public class SensorHelp extends Sensor_help
	{
		private var found:Sensor_root;
		private var foundDark:Sensor_root;
		private var tFound:TextField;
		
		public function SensorHelp()
		{
			super();
			
			var anchor:int = globalY;
			createConveyor( found = new Sensor_root );
			found.setState( Sensor_root.STATE_FOUND );
			
			globalY = anchor;
			createConveyor( foundDark = new Sensor_root );
			foundDark.setDark();
			foundDark.setState( Sensor_root.STATE_FOUND );
			foundDark.x = found.getWidth();
			
			tFound = new TextField;
			addChild( tFound );
			tFound.defaultTextFormat = tf;
			tFound.text = "-"+loc("rfd_lost_and_found");
			tFound.x = foundDark.x + foundDark.getWidth() + 20;
			tFound.y = found.y;
			tFound.width = tFound.textWidth + 15;
			
			addInfo();
			
			
		}
		
		private function addInfo():void
		{
			globalY += 20;
			
			var canY:int = 5;
			var canX:int = 10;
			const can:Sprite = new Sprite
			drawBorder( can );
			can.y = globalY;
			this.addChild( can );
			
			const label:String = DS.isDevice( DS.RDK )?loc( "rfd_rd_repeater" ):"*№32 - " + loc( "rfd_rd_repeater" );
			const head:SimpleTextField = new SimpleTextField(  label );
			head.y = canY;
			can.addChild( head );
			
			canY += head.height + 15;
			
			const lbl:String = DS.isDevice( DS.M_RR1 )?"major_zone_wire_II":"major_zone_wire";
			
			const subtitle_i:SimpleTextField = new SimpleTextField( loc( lbl ) );
			subtitle_i.y = canY;
			subtitle_i.x = canX;
			can.addChild( subtitle_i );
			
			canY += subtitle_i.height + 10;
			
			makeState( "wire_disunite", Sensor_root.STATE_TRIGGER, canY, can );
			canY += 20;
			makeState( "wire_closed", Sensor_root.STATE_NORMAL, canY, can );
			
			canY += 50;
			const subtitle_ii:SimpleTextField = new SimpleTextField( loc( "additional_wire" ) );
			subtitle_ii.y = canY;
			subtitle_ii.x = canX;
			can.addChild( subtitle_ii );
			
			canY += subtitle_ii.height + 10;
			
			makeState( "repeater_powered_reseirved", Sensor_root.STATE_TRIGGER, canY, can );
			canY += 20;
			makeState( "source_power_ison", Sensor_root.STATE_NORMAL, canY, can );
			
			
			
		}
		
		private function drawBorder( can:Sprite ):void
		{
			const ww:int = 600;
			const hh:int = 230;
			
			can.graphics.beginFill( 0xFFFFFF );
			can.graphics.lineStyle(1, 0x00 );
			can.graphics.drawRect( 0, 0, ww, hh );
			can.graphics.endFill();
		}
		
		private function makeState( txt:String, state:int, yy:int, can:Sprite ):void
		{
			var sensor:Sensor_root = new Sensor_root
			sensor.setState( state );
			sensor.y = yy;
			sensor.x = 10;
			can.addChild( sensor );
			
			
			var sensorDark:Sensor_root = new Sensor_root
			sensorDark.setDark();
			sensorDark.setState( state );
			sensorDark.x = sensor.getWidth();
			sensorDark.y = yy;
			can.addChild( sensorDark );
			
			tFound = new TextField;
			can.addChild( tFound );
			tFound.defaultTextFormat = tf;
			tFound.text = "-"+loc( txt ).toLocaleLowerCase();
			tFound.x = sensorDark.x + sensorDark.getWidth() + 20;
			tFound.y = yy;
			tFound.width = tFound.textWidth + 15;
		}
	}
}