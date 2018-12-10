package components.abstract
{
	import components.system.CONST;
	import components.system.UTIL;

	public class Utility
	{
		private static var discret:Number = 3.18/4095;
		
		public static function mathOMtoACP(om:int):int
		{
			return ((19.7*470)/(om+770))/discret;
		}
		public static function mathACPtoOM( acp:int ):int
		{
			return int((19.7*470)/(acp*discret) - 770);
		}
		
		public static function addMinutes( _num:int ):String
		{
			var str:String = _num.toString();
			str = str.charAt( str.length - 1 );
			
			switch( str ) {
				case "0": 
					return _num + " минут";
				case "1":
					return _num + " минута";
				case "2":
				case "3":
				case "4":
					return _num + " минуты";
				case "5":
				case "6":
				case "7":
				case "8":
				case "9":
					return _num + " минут";
			}
			return str;
		}
		public static function addSeconds( _num:int ):String
		{
			var str:String = _num.toString();
			str = str.charAt( str.length - 1);
			
			switch( str ) {
				case "0": 
					return _num + " секунд";
				case "1":
					return _num + " секунда";
				case "2":
				case "3":
				case "4":
					return _num + "секунды";
				case "5":
				case "6":
				case "7":
				case "8":
				case "9":
					return _num + " секунд";
			}
			return str;
		}
		public static function formateApmers(_num:Number):String
		{
			return _num.toFixed(2)+" м";
		}
		public static function formateOm(_num:Number):String
		{
			return UTIL.formateNumbersToLetters( int(_num) );
		}
		public static function formateLength( _value:Object, _len:int ):String
		{
			var value:String = String(_value);
			if(value.length>_len)
				return value.slice(0,_len) + "...";
			return value;
		}
		public static function getDecimalStringLength( _len:int ):int
		{
			var compile:String="0x";
			for(var i:int; i<_len; ++i) {
				compile += "FF";
			}
			return int(compile).toString().length + 1;// +1 для возможонго знака минус
		}
		public static function isDuplicateInside( _source:Object, _obj:* ):Boolean
		{
			for( var key:String in _source) {
				if ( _source[key] == _obj ) {
					return true;
				}
			}
			return false;
		}
		public static function calcCreateBitfield(value:Array):int 
		{
			var bit:int=0;
			for( var i:int; i<value.length; ++i) {
				if ( value[i] > 0 ) {
					bit |= 1<<i;
				}
			}
			return bit;
		}
		public static function getRealArrayLength( arr:Array ):uint
		{
			var counter:int;
			for( var key:String in arr ) {
				if ( arr[key] != null )
					counter++;
			}
			return counter;
		}
		public static function testIsGarbage(pattern:Object, target:Object):Boolean
		{
			for( var key:String in target) {
				if ( target[key] != pattern )
					return false;
			}
			return true;
		}
		public static function createPassword(length:int,numeric:Boolean=false):String
		{
			var chars:String;
			if( numeric )
				chars="0123456789";
			else
				chars="abchefghjkmnpqrstuvwxyzQWERTYUIOPLKJHGFDSAZXCVBNM0123456789";
			
			var pass:String="";
			var nLenght:Number=chars.length;
			for(var i:int; i<length; ++i)
			{
				var num:int=Math.random()*nLenght;
				pass+=chars.charAt(num);
			}
			return pass;
		}
		public static function mod(n:int):int
		{
			if (n<0)
				return n*-1;
			return n;
		}
	}
}