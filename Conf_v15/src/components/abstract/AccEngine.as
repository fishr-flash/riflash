package components.abstract
{
	import components.protocol.Package;
	import components.system.UTIL;

	public class AccEngine
	{
		public static var RANGE:int;
		public static var LIVE:Boolean = true;	// true управлет просмотром, false управляет пользователь с помощью timelineNavigation
		public static var RECORDING:Boolean = false;
		
		public static const BOX_TIME_PERIOD:int = 20;
		public static var BOX_CURRENT_WIDTH:int;
		public static var BOX_CURRENT_HEIGHT:int;
		public static var EXPAND:Boolean = false; 
		
		public static const DEVICE_FREQUENCY:int = 85;	// с какой частотой обнавляется информация на приборе в мс
		public static const REQUEST_DELAY:int = 250;	// в милисекундах
		public static const MAX_LIMIT:int = 0x1000;
		public static const MAX_PERIOD:int = 20;	// в секундах
		public static const SIGNAL_RESOLUTION:int = 10;	// точек в секунду
		public static const TOTAL_TIME:int = 300;	// в секундах
		
		private static const DEGREES_IN_RADIAN:Number = 57.2958;
		private static const RADIAN_IN_DEGREES:Number = 3.14159265/180;
	
		public static function getYByAcp(acp:Number):Number
		{
			var coef:Number = acp/MAX_LIMIT;
			return BOX_CURRENT_HEIGHT*0.5 - coef*(BOX_CURRENT_HEIGHT*0.5);
		}
		public static function getGbyY(ypos:Number):Number
		{
			var coefy:Number = (ypos-BOX_CURRENT_HEIGHT*0.5)/(BOX_CURRENT_HEIGHT*0.5);
			var coefg:Number = RANGE/MAX_LIMIT;
			var acp:int = -MAX_LIMIT*coefy;
			return acp*coefg;
		}
	/*	public static function getAngle(target:int, v1:int, v2:int):int
		{
			var angle:Number = Math.atan( /( Math.sqrt( v1*v1 + v2*v2) ));
			return Math.round( angle );
		}*/
		
		public static function getAngle(projection:int, signProjection:int, module:int):int
		{
			var p:int = projection;
			if ( UTIL.mod(projection) > module) {
				if (projection < 0)
					p = -module;
				else
					p = module;
			}
			
			var ret:Number = 0;
			ret = Math.acos( p / module) * DEGREES_IN_RADIAN;
			if(ret < 0)
				ret += 360;
			return Math.round(ret);
			/*
			
			var sin:Number;
			var cos:Number;
			if(module != 0)	{
				if(signProjection > 0) {
					sin = Math.asin( p / module);
					ret = Math.asin( p / module) * DEGREES_IN_RADIAN;
				} else {
					cos = Math.acos( p / module);
					ret = 90 - Math.acos( p / module) * DEGREES_IN_RADIAN;
				}
				if(ret < 0)
					ret += 360;
			}
			return Math.round(ret);
			*/
		}
		public static function getVector(angle:int):int
		{
			var sin:Number = Math.cos(angle * RADIAN_IN_DEGREES );
			return getModul() * sin;
		}
		public static function getModul():int
		{
			var modulacp:int;
			switch(RANGE) {
				case 2:
					modulacp = 2048;
					break;
				case 4:
					modulacp = 1024;
					break;
				case 8:
					modulacp = 512;
					break;
			}
			return modulacp;
		}
		public static function getGbyAcp(acp:Number):Number
		{
			var coefg:Number = RANGE/MAX_LIMIT;
			return acp*coefg;
		}
		public static function getAcpByG(g:Number):Number
		{
			var coefg:Number = RANGE/MAX_LIMIT;
			return g/coefg;
		}
/** Queue distribution	*/
		private static var stackCounter:int;
		public static var TOTAL_STRUC:int;
	//	public static var updateStack:Vector.<Array>;
		
		public static var distibutor:TimeAlignDistributor;
		
		public static function prepare(d:Function, delay:int=DEVICE_FREQUENCY, preset:int=0x01 ):void
		{
			if( distibutor )
				distibutor.destroy();
			distibutor = new TimeAlignDistributor( d,delay,preset);
		}
		public static function vectorDistibute(p:Package):void
		{
			const max:int = 0xfe;
			
			var len:int = p.data.length;
			var i:int;
			var target:Array = p.data.slice();
			var foundCycle:Boolean = false;
			var foundZero:Boolean = false;
			var foundZeroAt:int = 0;
			var foundFF:Boolean = false;
			var cycleAnchor:int;
			
			for (i=0; i<len; ++i) {
				if (target[i+1] != null && target[i][0] > target[i+1][0] ) {
					foundCycle = true;
					cycleAnchor = i;
					//break;
				}
				if (target[i][0] == max)
					foundFF = true;
				if (target[i][0] == 0) {
					foundZero = true;
					foundZeroAt = i;
				}
			}
			if (foundZero && foundFF) {
				var c:int = foundZeroAt;
				target = p.data.slice();
				target.sortOn("0", Array.NUMERIC );
				
				for (i=0; i<len; ++i) {
					if (target[i+1] != null && target[i][0] + 1 != target[i+1][0] )
						break;
				}
				target = target.slice(i+1,len).concat( target.slice(0, i+1) );
			} else if (foundZero && !foundFF) {
				target = target.slice(cycleAnchor+1,len);
				len = target.length;
			} else if (foundCycle) {
				target.sortOn("0", Array.NUMERIC );
			}
			
			var found:Boolean = false;
			
			for (i=0; i<len; ++i) {
				if ( stackCounter + 1 == target[i][0] || (target[i][0] == 0 && stackCounter+TOTAL_STRUC > max) ) {
					found = true;
					if (target[i][0] == 0 && stackCounter+TOTAL_STRUC > max) {
						if (stackCounter > 0)
							stackCounter = 0;
						else
							stackCounter++;
						foundZero = true;
					} else
						stackCounter++;
					
					distibutor.add( target[i] );
				} else {
					if (found) {	// уже не равен
						break;
					} else		// еще не равен
						continue;
				}
			}
			if (!found) {
				if (!foundZero && !foundFF) {
					stackCounter = target[0][0];
					for (i=0; i<len; ++i) {
						if (stackCounter > target[i][0])
							stackCounter = target[i][0];
					}
					stackCounter--;
					
					for (i=0; i<len; ++i) {
						if ( stackCounter + 1 == target[i][0] || target[i][0] == 0 ) {
							found = true;
							if (target[i][0] == 0 ) {
								stackCounter = 0;
								foundZero = true;
							}
							distibutor.add( target[i] );
							stackCounter++;
						} else {
							if (found)	// уже не равен
								break;
							else		// еще не равен
								continue;
						}
					}
				}
			}
		}
	}
}