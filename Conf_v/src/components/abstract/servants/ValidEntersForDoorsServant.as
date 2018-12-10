package components.abstract.servants
{
	import components.abstract.functions.loc;
	import components.protocol.Package;
	import components.protocol.statics.OPERATOR;
	import components.static.CMD;
	import components.system.UTIL;

	public class ValidEntersForDoorsServant
	{
		private static var _inst:ValidEntersForDoorsServant;
		private var _enters:Array;
		
		public function ValidEntersForDoorsServant()
		{
		}

		public static function get inst():ValidEntersForDoorsServant
		{
			if( !_inst ) _inst = new ValidEntersForDoorsServant;
			return _inst;
		}
		
		public function getEnters():Array
		{
			if( _enters == null ) 
			{
				_enters = createFullListEnters();	
				
				excludeNonMechanicals();
				excludeExpansion();
				
			}
			
						
			return UTIL.getComboBoxList( _enters.slice() );
		}
		
		public function put( p:Package ):void
		{
			
			
			switch( p.cmd ) {
				
				
				case CMD.VR_INPUT_DIGITAL:
					 excludeNonMechanicals();
					break;
				case CMD.VR_SERIAL_USE:
					
					
					
					break;
				default:
					break;
			}
			
		}
		
		private function createFullListEnters():Array
		{
			const arr:Array = new Array;
			arr.push( [ 0, loc("can_engine_notinuse") ] );  
			for (var i:int=1; i <= 16; i++) 
			{
				if( i > 4 && i < 9 ) continue;
				
				arr.push( [ i, loc("input_title") + " " + i ] )
				
			}
			
			
			return arr;
		}
		
		private function excludeNonMechanicals( ):void
		{
			var pdataType:Array = OPERATOR.getData( CMD.VR_INPUT_TYPE );
			var pdataDig:Array = OPERATOR.getData( CMD.VR_INPUT_DIGITAL );
			
			var len:int = pdataDig.length;
			for (var i:int= 0; i<len; i++) 
				if(pdataType[ i ][ 1 ] != 1 || pdataDig[ i ][ 1 ] ) _enters[ i + 1 ] = null;
			
			for ( i= len; i > 0; i--)
				if( !_enters[ i ] )_enters.splice( i, 1 );
				
			
		}
		
		private function excludeExpansion():void
		{
			var ext:Boolean =  OPERATOR.getData( CMD.VR_SERIAL_USE )[ 0 ][ 0 ] == 4;
			
			if( !ext )
			{
				var len:int = _enters.length - 1;
				for (var i:int=len; i>-1; i--) 
					if( _enters[ i ][ 0 ] > 4 )_enters.splice( i, 1 );	
			}
			
			
			
		}
		
		

		public function clear():void
		{
			_enters = null;
			
		}
	}
}