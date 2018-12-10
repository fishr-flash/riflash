package components.gui.fields
{
	import flash.events.MouseEvent;
	
	import components.gui.fields.lowlevel.MRadio;
	
	public class FSTextRadio extends FormString
	{
		//private var cell:RadioButton;
		private var cell:MRadio;
		
		public function FSTextRadio()
		{
			super();
			construct();
		}
		private function construct():void 
		{
			cell = new MRadio;
			addChild( cell );
			cell.selected = true;
			cell.x = 200;
			cell.y = 9;
			
			cell.addEventListener( MouseEvent.CLICK, boxClick );
			
			valid = true;
		}
		private function boxClick( ev:MouseEvent ):void
		{
			send();
		}
		override public function setName( _name:String ):void 
		{
			tName.text = _name;
			
			tName.multiline = true;
			//textFormat.leading = -7;
			tName.setTextFormat( textFormat ); 
			tName.height = tName.textHeight+17;
			tName.y = -int((tName.height - 22)/2);
		}
		override public function setCellInfo( value:Object ):void
		{
			var _name:String = String(value);
			if ( _name == "1" || _name == "true" )
				cell.selected = true;
			else
				cell.selected = false;
		}
		override public function getCellInfo():Object
		{
			if ( cell.selected )
				return "1";
			return"0";
		}
		public function switchCheck():void
		{
			cell.selected = !cell.selected;
		}
		override public function setWidth(_num:int):void
		{
			super.setWidth(_num);
			cell.x = tName.width;
		}
		override public function getWidth():int
		{
			return cell.x + 13;
		}
		public function set selected( value:Boolean):void
		{
			cell.selected = value;
		}
		public function get selected():Boolean
		{
			return cell.selected;
		}
		override public function set disabled(value:Boolean):void
		{
			cell.enabled = !value;
			if (value) {
				tName.textColor = 0x999999;
				if (cell.hasEventListener(MouseEvent.CLICK) )
					cell.removeEventListener( MouseEvent.CLICK, boxClick );	
			} else {
				tName.textColor = 0x000000;
				cell.addEventListener( MouseEvent.CLICK, boxClick );
			}
		}
		override public function get disabled():Boolean
		{
			return !cell.enabled;
		}
	}
}