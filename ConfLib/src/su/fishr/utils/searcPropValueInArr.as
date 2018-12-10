package su.fishr.utils 
{
	/**
	 * Ищет значение произвольно указанного свойства в массиве, используя 
	 * нестрогое соответствие и возвращает его индекс.
	 * Если значение не найдено возвращает -1
	 * 
	 * @author  
	 */
	public function searcPropValueInArr( propName:String, searchValue:*, arr:Array ):int
	{
		
		var len:int = arr.length;
		for ( var i:int = 0; i < len; i++ )
		{
			
			if ( arr[ i ][ propName ] == searchValue ) return i;
		}
		
		return -1;
	}

}