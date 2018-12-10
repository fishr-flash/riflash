package components.abstract
{
	import components.protocol.Package;
	import components.protocol.statics.SERVER;
	import components.screens.ui.UIWire;
	import components.system.CONST;
	import components.system.UTIL;

	public class Utility
	{
		/**************** CONST 16/C16 *************************/
		
		private static const discret_116:Number = 3.42/4095;
		private static var cortextMagicNumber:Number = 11225189;
		
		public static var GUARD_RESIST_ALL:int=0;
		public static var GUARD_RESIST_FIRST:int=0;
		public static var GUARD_RESIST_SECOND:int=0;
		
		public static var GUARD_DRY_OPEN:Boolean=false;

		public static function mathOMtoACP(om:int):int
		{
			return cortextMagicNumber/(om + 770);
		}
		public static function mathACPtoOM( acp:int ):int
		{
			return cortextMagicNumber/acp - 770;
		}
		/**************** END 16/C16 *************************/
		
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
		public static function hash_0To1(num:Object):int
		{
			return int(num)+1;
		}
		public static function hash_1To0(num:Object):int
		{
			return int(num)-1;
		}
	}
}