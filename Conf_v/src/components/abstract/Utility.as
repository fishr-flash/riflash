package components.abstract
{
	import components.abstract.functions.loc;
	import components.protocol.Package;
	import components.system.CONST;

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
					return _num + " "+loc("time_min0_full");
				case "1":
					return _num + " "+loc("time_min1_full");
				case "2":
				case "3":
				case "4":
					return _num + " "+loc("time_min2_full");
				case "5":
				case "6":
				case "7":
				case "8":
				case "9":
					return _num + " "+loc("time_mins_full");
			}
			return str;
		}
		public static function addSeconds( _num:int ):String
		{
			var str:String = _num.toString();
			str = str.charAt( str.length - 1);
			
			switch( str ) {
				case "0": 
					return _num + " "+loc("time_sec0_full");
				case "1":
					return _num + " "+loc("time_sec1_full");
				case "2":
				case "3":
				case "4":
					return _num + " "+loc("time_sec2_full");
				case "5":
				case "6":
				case "7":
				case "8":
				case "9":
					return _num + " "+loc("time_secs_full");
			}
			return str;
		}
		public static function formateNumbersToLetters( _number:int):String {
			
			var stringNumber:String = String(_number);
			
			if ( stringNumber.length > 5 )
				return stringNumber.substring( 0, stringNumber.length-5 ) + " "+loc("measure_amount_mega");
			else if ( stringNumber.length > 3 ) {
				if ( stringNumber.length == 4 )
					return stringNumber.charAt(0)+","+stringNumber.charAt(1) + " "+loc("measure_amount_kilo");
				else
					return stringNumber.substring( 0, stringNumber.length-3 ) + " "+loc("measure_amount_kilo");
				
			}
			return stringNumber + " ";
		}
		public static function formateApmers(_num:Number):String
		{
			return _num.toFixed(2)+" "loc("measure_amount_mega");
		}
		public static function formateOm(_num:Number):String
		{
			return formateNumbersToLetters( int(_num) );
		}
		public static function formateLength( _value:Object, _len:int ):String
		{
			var value:String = String(_value);
			if(value.length>_len)
				return value.slice(0,_len) + "...";
			return value;
		}
		public static function comboBoxNumericDataGenerator( _minValue:int, _maxValue:int ):Array 
		{
			var arr:Array = new Array;
			for( var i:int=_minValue; i<=_maxValue; i++ ) {
				arr.push( {label:String(i), data:i } );
			}
			return arr;
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
		public static function hash_0To1(num:Object):int
		{
			return int(num)+1;
		}
		public static function hash_1To0(num:Object):int
		{
			return int(num)-1;
		}
		public static function mod(n:int):int
		{
			if (n<0)
				return n*-1;
			return n;
		}
/** PARTITION **********************************************/		
		public static function turnToPartitionBitfield( arr:Array ):int
		{
			var aBitfield:Array = new Array;
			var len:int = arr.length;
			var i:int;
			for( i=0; i<len; ++i ) {
				var bf:int = getPartitionBySection( arr[i] );
				if ( bf > 0 )
					aBitfield.push( bf );
			}
			len = aBitfield.length;
			var num:int = 0;
			
			for(i = 0 ;i < len; ++i) {
				num |= 1 << (int(aBitfield[i]) - 1);
			}
			return num;
		}
		public static function getPartitionBySection( _section:int):int
		{
			var a:Object = CONST.PARTITION
			for( var key:String in CONST.PARTITION ) {
				if ( _section == CONST.PARTITION[key].section )
					return int(key)
			}
			return 0;
		}
	}
}