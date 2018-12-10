package components.abstract.functions
{
	import components.abstract.LOC;

	public function loc(msg:String, firstCapital:Boolean = false ):String
	{
		var result:String = LOC.loc(msg);
		
		if( firstCapital )
			result = result.charAt().toLocaleUpperCase() + result.substr( 1 );
		
		return result;
	}	
	
	
}