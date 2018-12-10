package components.abstract.functions
{
	/**
	 *  Приходящие байты-числа всегда интерпетируются как тип uint.
	 * Фунция пересчитывает это число в формат int, чтобы преобразовать
	 * его в отрицательное значение если оно передано таковым.
	 * Дополняет неполные байты до полной длины кратной 8.
	 * 
	 * @param dg  число полученое в результате интерпретации полученых байтов
	 * 
	 * @return int	интерпретированное число со знаком  
	 * 
	 */
	public function byteInterpreter( dg:int ):int
	{
		var str:String = Number( dg ).toString( 2 );
		while ( str.length % 8 ) str = "0" + str;
		const len:int = str.length - 1;
		var base:int = 1;
		var res:int = 0;
		for ( var i:int = len; i >= 0 ; i-- )
		{
			if( str.charAt( i ) == "1" )res += base;
			base += base;
		}
		
		if ( str.charAt( 0 ) == "1" ) res = res - Math.pow( 2, len + 1 );
		
		return res;
		
	}
}

