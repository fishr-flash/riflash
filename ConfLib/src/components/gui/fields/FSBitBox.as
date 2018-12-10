package components.gui.fields
{
	import components.interfaces.IFormString;
	import components.system.UTIL;

	public class FSBitBox extends FSCheckBox implements IFormString
	{
		private var bit:int;
		protected var bitfield:int;
		
		
		public function FSBitBox()
		{
			super();
		}
		override public function setList(_arr:Array, _selectedIndex:int=-1):void
		{
			bit = _arr[0];
			
		}
		override public function setCellInfo( value:Object ):void 
		{
			bitfield = int(value);
			
			if ( (bitfield & (1 << bit)) > 0 )
				super.setCellInfo(1);
			else
				super.setCellInfo(0);
		}
		override public function getCellInfo():Object
		{
			var b:Boolean = super.getCellInfo() == 1;
			bitfield = UTIL.changeBit( bitfield, bit, b );
			return bitfield;
		}
	}
}