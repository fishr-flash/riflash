package components.gui.visual.wire
{
	import flash.display.Sprite;
	
	import components.abstract.functions.loc;
	import components.gui.SimpleTextField;
	import components.static.COLOR;
	
	public class SimpleWireRes extends Sprite
	{
		private var left:SimpleTextField;
		private var right:SimpleTextField;
		private var unit:WireUnitBigSimple;
		private var stateOpen:Boolean = false;
		
		private var _zone:int;
		
		public function SimpleWireRes()
		{
			super();
			
			left = new SimpleTextField("", 300, COLOR.WHITE );
			addChild( left );
			left.setSimpleFormat( "center" );
			left.height = 35;
			left.y = 20;
			left.background = true;
			left.backgroundColor = COLOR.WIRE_GREEN;

			right = new SimpleTextField("", 300, COLOR.WHITE );
			addChild( right );
			right.setSimpleFormat( "center" );
			right.height = 35;
			right.x = 300;
			right.y = 20;
			right.background = true;
			right.backgroundColor = COLOR.WIRE_LIGHT_BROWN;
			
			unit = new WireUnitBigSimple( COLOR.WIRE_GREEN );
			addChild( unit );
			open(false);
		}
		public function state(_open:Boolean):void
		{
			if (_open) {
				left.text = loc("wire_norm");
				right.text = loc("wire_alarm")+ " " + getZone();
				right.backgroundColor = COLOR.WIRE_LIGHT_BROWN;
				left.backgroundColor = COLOR.WIRE_GREEN;
			} else {
				right.text = loc("wire_norm");
				left.text = loc("wire_alarm")+ " " + getZone();
				right.backgroundColor = COLOR.WIRE_GREEN;
				left.backgroundColor = COLOR.WIRE_LIGHT_BROWN;
			}
			if (unit.x > 150 )
				unit.draw( right.backgroundColor )
			else
				unit.draw( left.backgroundColor )
			stateOpen = _open;
		}
		public function open(b:Boolean):void
		{
			if (b) {
				unit.x = 450;
				unit.draw( right.backgroundColor )
			} else {
				unit.x = 150;
				unit.draw( left.backgroundColor );
			}
		}
		public function set zone(z:int):void
		{
			_zone = z;
			if (stateOpen)
				right.text = loc("wire_alarm")+ " " + getZone();
			else
				left.text = loc("wire_alarm")+ " " + getZone();
		}
		private function getZone():String
		{
			return _zone == 0? loc("g_no").toLowerCase() :_zone.toString();
		}
	}
}