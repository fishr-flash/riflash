package components.gui.visual.wire
{
	import components.gui.SimpleTextField;
	import components.system.CONST;
	
	import flash.display.Sprite;
	
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
			
			left = new SimpleTextField("", 300, CONST.COLOR_WHITE );
			addChild( left );
			left.setSimpleFormat( "center" );
			left.height = 35;
			left.y = 20;
			left.background = true;
			left.backgroundColor = CONST.COLOR_WIRE_GREEN;

			right = new SimpleTextField("", 300, CONST.COLOR_WHITE );
			addChild( right );
			right.setSimpleFormat( "center" );
			right.height = 35;
			right.x = 300;
			right.y = 20;
			right.background = true;
			right.backgroundColor = CONST.COLOR_WIRE_LIGHT_BROWN;
			
			unit = new WireUnitBigSimple( CONST.COLOR_WIRE_GREEN );
			addChild( unit );
			open(false);
		}
		public function state(_open:Boolean):void
		{
			if (_open) {
				left.text = "Норма";
				right.text = "Тревога\nЗона " + getZone();
			} else {
				right.text = "Норма";
				left.text = "Тревога\nЗона " + getZone();
			}
			stateOpen = _open;
		}
		public function open(b:Boolean):void
		{
			if (b) {
				unit.x = 450;
				unit.draw( CONST.COLOR_WIRE_LIGHT_BROWN )
			} else {
				unit.x = 150;
				unit.draw( CONST.COLOR_WIRE_GREEN );
			}
		}
		public function set zone(z:int):void
		{
			_zone = z;
			if (stateOpen)
				right.text = "Тревога\nЗона " + _zone;
			else
				left.text = "Тревога\nЗона " + _zone;
		}
		private function getZone():String
		{
			return _zone == 0? "нет":_zone.toString();
		}
	}
}