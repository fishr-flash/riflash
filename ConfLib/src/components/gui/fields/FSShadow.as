package components.gui.fields
{
	/**
	 * Информационный контейнер, не имеет визуального выражения.
	 * Для чтения/записи информации дополняющей информационный блок 
	 * формируемый визуальными эл-тами
	 *  
	 * @param _name Object сохраняемая структурная информация
	 * 
	 */	
	public class FSShadow extends FormEmpty
	{
		public static const F_SHOULD_EVOKE_CHANGE:int = 0x01;
		
		private var shouldEvokeChange:Boolean = false;
		
			
		/**
		 * Информационный контейнер, не имеет визуального выражения.
		 * Для чтения/записи информации дополняющей информационный блок 
		 * формируемый визуальными эл-тами
		 *  
		 * @param _name Object сохраняемая структурная информация
		 * 
		 */	
		public function FSShadow(_name:Object=null)
		{
			if ( _name != null)
				setCellInfo( String(_name) );
		}
		override public function setCellInfo( value:Object ):void
		{
			var n:String = String(value); 
			if (adapter)
				n = String( adapter.adapt(value) );
			cellInfo = n;
			if ( shouldEvokeChange && fSend is Function )
				fSend( this );
		}
		override public function getCellInfo():Object 
		{
			if (adapter)
				cellInfo = String( adapter.recover(cellInfo) );
			return cellInfo;
		}
		override public function setName( _name:String ):void
		{
			setCellInfo(_name);
		}
		public function get debugName():String
		{
			return cellInfo;
		}
		
		override protected function validate(str:String, ignorSave:Boolean=false):Boolean
		{
			return true;
		}
		override public function isValid(_str:String=null):Boolean
		{
			return true;
		}
		
		override public function get valid():Boolean
		{
			return true;
		}
		override public function set cmd(value:int):void
		{
			super.cmd = value;
		}
		override protected function applyParam(param:int):void
		{
			switch(param) {
				case F_SHOULD_EVOKE_CHANGE:
					shouldEvokeChange = true
					break;
			}
		}
	}
}