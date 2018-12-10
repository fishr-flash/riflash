package components.gui.fields
{
	import components.interfaces.IFormString;
	import components.system.UTIL;

	/** 
	 * Модификация предка. Создан в связи с тем, что в команде K9_BIT_SWITCHES 3603,
	 * нужно менять два бита при включении опции
	 * 
	 * 
	 */
	
	
	public class FSBitBoxK9BitSw extends FSBitBox
	{

		private var _bits:Array;

		private var _combo:IFormString;
		
		public function FSBitBoxK9BitSw()
		{
			//TODO: implement function
			super();
		}
		
		public function setComboTime( comboTime:IFormString ):void
		{
			_combo = comboTime;
		}
		override public function setList(_arr:Array, _selectedIndex:int=-1):void
		{
			_bits = _arr;
			super.setList( _arr, _selectedIndex );
			
		}
		
		override public function getCellInfo():Object
		{
			
			const superInfo:Object = super.getCellInfo();
			
			var b:Boolean = int( superInfo )%2 === 0;
			bitfield = UTIL.changeBit( bitfield, 1, !b );
			
			
			_combo.disabled = b;
			
			
			
			return super.getCellInfo();
		}
	}
}