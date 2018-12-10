package components.gui.fields
{
	import components.gui.triggers.TextButton;
	import components.interfaces.IFormString;

	public class FSButton extends FormString implements IFormString
	{
		private var cell:TextButton;
		
		public function FSButton()
		{
			super();
			construct();
		}
		private function construct():void 
		{
			cell = new TextButton;
			addChild( cell );
			cell.x = 200;
		}
		override public function setCellInfo( value:Object ):void
		{
			cell.setName(String(value));
		}
		override public function getCellInfo():Object
		{
			return cell.getName();
		}
		override public function setWidth(_num:int):void
		{
			tName.width = _num;
			cell.x = tName.width;
		}
		override public function setCellWidth(_num:int):void
		{
		}
		override public function setUp( _fsend:Function, _id:int=-1 ):void 
		{
			cell.setId(_id);
			cell.setFunction(_fsend);
		}
	}
}