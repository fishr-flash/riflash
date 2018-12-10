package components.system
{
	import flash.display.DisplayObject;
	import flash.display.Stage;
	import flash.utils.ByteArray;
	import flash.utils.getTimer;
	
	import components.basement.UI_BaseComponent;
	import components.gui.MainNavigation;
	import components.static.MISC;

	public class UTIL
	{
		private var sr:Array = [
			"АБВГДЕЁЖЗИКЛМНОПРСТУФХЧШЩЪЫЬЭЮЯ",
			"ABCDEFGHIJKLMNOPQRSTUVWXYZ",
			("АБВГДЕЁЖЗИКЛМНОПРСТУФХЧШЩЪЫЬЭЮЯ" as String).toLocaleLowerCase(),
			("ABCDEFGHIJKLMNOPQRSTUVWXYZ" as String).toLocaleLowerCase(),
			"123456789!@#$%^&*()!\"№;%:?"
		];
		
		public static function isThroughVisible(d:DisplayObject):Boolean
		{
			if (d is Stage)
				return true;
			if (d.visible && d.parent ) {
				if( (d.parent is UI_BaseComponent && d.parent.visible) || d.parent is MainNavigation || d.parent == MISC.subMenuContainer || d.parent == MISC.subMenu )	// если поиск дошел до этих компонентов, значит объект видим - компоненты базовые
					return true;
				return isThroughVisible(d.parent);
			}
			return false;
		}
		public static function isChildOf(c:DisplayObject, d:DisplayObject):Boolean
		{
			if ( c.parent && c.parent == d )
				return true;
			if (!c.parent)
				return false;
			return isChildOf( c.parent, d );
		}
		
		public static function cloneObject(obj:Object):Object {
			var b:ByteArray=new ByteArray();
			b.writeObject(obj);
			b.position = 0;
			return b.readObject();
		}
		public static function getByteArray(obj:Object):ByteArray
		{
			var b:ByteArray = new ByteArray;
			b.writeObject( obj );
			b.position = 0;
			return b;
		}
		/** array[ array[ data, label ], int, ... ]	*/
		public static function getComboBoxList(a:Array):Array
		{
			var lst:Array = new Array;
			var len:int = a.length;
			for (var i:int=0; i<len; ++i) {
				if (a[i] is Array)
					lst.push( {label:a[i][1], data:a[i][0]} );
				else
					lst.push( {label:a[i].toString(), data:a[i]} );
			}
			return lst;
		}
		public static function getHMSTimeStampString(sep:String="."):String
		{
			var d:Date = new Date;
			return formateZerosInFront(d.hours,2)+sep+formateZerosInFront( int(d.minutes),2)+sep+formateZerosInFront( int(d.seconds),2 );
		}
		public static function getTimeStampString():String
		{
			var d:Date = new Date;
			return formateZerosInFront(d.minutes,2)+"."+formateZerosInFront( int(d.seconds),2)+"."+formateZerosInFront( int(d.milliseconds),4 );
		}
		public static function getDataString(fullyear:Boolean=false):String
		{
			var d:Date = new Date;
			return formateZerosInFront(d.date,2)+"."+formateZerosInFront( int(d.month+1),2)+"."+String(d.fullYear).slice( fullyear ? 0 : 2);
		}
		public static function getDataStringWod():String
		{
			var d:Date = new Date;
			return String(d.fullYear).slice(2)+""+formateZerosInFront( int(d.month+1),2)+""+formateZerosInFront(d.date,2);
		}
		public static function getHistoryDateStamp(date:Date=null):String
		{
			var d:Date;
			if (date)
				d = date;
			else
				d = new Date;
			
			return formateZerosInFront(d.date,2)+"."+formateZerosInFront( int(d.month+1),2)+"."+String(d.fullYear)+" "+
				formateZerosInFront(d.hours,2)+":"+formateZerosInFront(d.minutes,2)+":"+formateZerosInFront(d.seconds,2);
		}
		public static function getUTCDateStamp(date:Date=null):String
		{
			var d:Date;
			if (date)
				d = date;
			else
				d = new Date;
			
			return formateZerosInFront(d.dateUTC,2)+"."+formateZerosInFront( int(d.monthUTC+1),2)+"."+String(d.fullYearUTC)+" "+
				formateZerosInFront(d.hoursUTC,2)+":"+formateZerosInFront(d.minutesUTC,2)+":"+formateZerosInFront(d.secondsUTC,2);
		}
		public static function isEven(n:Object):Boolean
		{
			return !Boolean( (int(n) & 0x01) > 0);
		}
		public static function mod(n:Number):Number
		{
			if (n<0)
				return n*-1;
			return n;
		}
		public static function doTrimSpace(txt:Object):String
		{
			if ( txt == null || !(txt is String) )
				return "";
			return txt.replace(/^\s+|\s+$/g, "");
		}
		public static function isTrimSpace(txt:Object):Boolean
		{
			if ( txt == null || !(txt is String) )
				return false;
			return Boolean( (txt as String).search( /^\s+|\s+$/g ) > -1 );
		}
		
		private static var uids:Vector.<int>;
		public static function generateUId():int
		{
			if (!uids)
				uids = new Vector.<int>;
			var num:int;
			var unique:Boolean;
			var len:int = uids.length;
			for(var b:Boolean=true;b;b) {
				num = Math.random()*1000000;
				unique = true;
				for (var i:int=0; i<len; ++i) {
					if (num == uids[i]) {
						unique = false;
						break;
					}
				}
				if (unique) {
					uids.push( num );
					return num;
				}
			}
			return -1;
		}
		
		private static var suids:Vector.<int>;
		public static function generateSimpleUId():int
		{
			if (!suids)
				suids = new Vector.<int>;
			var num:int;
			var unique:Boolean;
			var len:int = suids.length;
			for(var b:Boolean=true;b;b) {
				unique = true;
				for (var i:int=0; i<len; ++i) {
					if (num == suids[i]) {
						unique = false;
						num++;
						break;
					}
				}
				if (unique) {
					suids.push( num );
					return num;
				}
			}
			return -1;
		}
		
		
		public static function fz( _value:Object, _len:int ):String
		{
			return formateZerosInFront(_value,_len);
		}
		public static function formateZerosInFront( _value:Object, _len:int ):String
		{
			
			
			var value:String = String(_value);
			
			while( value.length < _len ) {
				value = "0" + value;
			}
			
			return value;
		}
		public static function getBCDInteger(value:int):int
		{
			return int(value.toString(16));
		}
	/*	public static function isCSD():Boolean
		{
			return Boolean(SERVER.CONNECTION_TYPE.toLowerCase().search(SERVER.CONNECTION_CSD) > -1);
		}*/
		
		public static function hash_0To1(num:Object):int
		{
			return int(num)+1;
		}
		public static function hash_1To0(num:Object):int
		{
			return int(num)-1;
		}
		/** 1 to 4 bytes **/
		public static function toSigned(value:int, byte:int):int
		{
			var i:int = byte*8-1;
			var mask:int;
			for (var j:int=0; j<byte; j++) {
				mask |= ( 0xff << 8*j );
			}
			if (value >> i > 0 )
				return -((value^mask)+1);
			return value;
			
			/*
			if (value < 0x10000) {
				if (value < 0x100) {
					i = 7;
					mask = 0xff;
				} else {
					i = 15;
					mask = 0xffff;
				}
			} else {
				if (value < 0x1000000) {
					i = 23;
					mask = 0xffffff;
				} else {
					i = 31;
					mask = 0xffffffff;
				}
			}
			
			if (value >> i > 0 )
				return -((value^mask)+1);
			return value;*/
		}
		/** Приведение к signed всегда положительному числу */ 
		public static function toSigned2bytesMod(value:int):int
		{
			if (value >> 15 > 0 )
				return (value^0xffff)+1;
			return value;
		}
		public static function toUnSigned2bytes(value:int):uint
		{
			if (value < 0)
				return ((value^0xffff)*-1)-1;
			return value;
		}
		public static function wrapHtml(txt:String, color:int=0, size:int=12, bold:Boolean=false, font:String="Tahoma"):String
		{
			var s:String = "<font face='"+font+"' size='"+size+"' color='#" + color.toString(16) + "'>";
			if (bold)
				s += "<b>"+txt+"</b>";
			else
				s += txt;
			return s + "</font>";
		}
		public static function generateMAC():Array
		{
			var a:Array = [getRandom() & 0xFE, getRandom(), getRandom(), getRandom(), getRandom(), getRandom()];
			return a;
			function getRandom():int
			{
				return Math.round(Math.random()*253+1);
			}	
		}
		public static function getDbm2Perc(value:int):int
		{
			var sig:int = UTIL.mod( UTIL.toSigned(value,1) );
			
			if (sig < 35)
				return 100;
			else if (sig > 94)
				return 1;
			return Math.round((100/60)*(60-(sig - 35)));
		}
/**************************************************************** BITWISE FUNCTIONS */		
		public static function toLitleEndian(arr:Array ):int
		{
			var value:uint=0;
			var len:int = arr.length;
			for(var k:int=0; k<len; ++k) {
				value |= arr[k] << k*8;
			}
			return value;
		}
		public static function toLitleEndianByteArray(b:ByteArray, index:int, len:int):int
		{
			var value:uint=0;
			for(var k:int=0; k<len; ++k) {
				value |= b[index+k] << k*8;
			}
			return value;
		}
		/** Only 1 byte size, bitnum = 0-7	*/
		public static function changeBit(bitvalue:uint, bitnum:Object, setto:Boolean):uint
		{
			var bf:uint = 0;
			
			var len:int = 8;
			if (bitvalue > 0xff || bitnum > 7)
				len = 16
			
			for (var i:int=0; i<len; i++) {
				if (contains()) {
					if (setto)
						bf |= 1 << i;
					else
						bf |= 0 << i;
				} else {
					if ( mod((bitvalue & 1 << i)) > 0)
						bf |= 1 << i;
					else
						bf |= 0 << i;
				}
			}
			
			return bf;
			
			function contains():Boolean
			{
				if (bitnum is int)
					return bitnum == i;
				else {
					var lenj:int = (bitnum as Array).length;
					for (var j:int=0; j<lenj; j++) {
						if (i == bitnum[j])
							return true;
					}
				}
				return false;
			}
		}
		/**
		 *  Возвращает включен ли бит в байте
		 *  @param num номер бита состояние которого необходимо выяснить 
		 *  @param value байт/число содержащее интересующий бит 
		 * 
		 *  0 - first bit, 7 - last	*/
		public static function isBit(num:int, value:int):Boolean
		{
			return Boolean(mod((value & (1 << num))) > 0);
		}
		
		public static function hexToDec( hx:String ):uint
		{
			return uint( Number( "0x" + hx ).toString( 10 ) );
		}
/**************************************************************** DEBUG FUNCTIONS */
		private static var dStart:Date;
		public static function timerStart():void
		{
			dStart = new Date;
		}
		public static function timerResult():Number
		{
			if (!dStart)
				return 0;
			var dStop:Date = new Date;
			return dStop.time - dStart.time; 
		}
		private static var dStart2:Date;
		public static function timerStart2():void
		{
			dStart2 = new Date;
		}
		public static function timerResult2():Number
		{
			if (!dStart2)
				return 0;
			var dStop:Date = new Date;
			return dStop.time - dStart2.time; 
		}
		
		
		
		
		private static var dGlobal:Date;
		public static function timerGlobalReset():void
		{
			if(!dGlobal)
				dGlobal = new Date;	
		}
		public static function timerResultGlobal(start:Boolean):String
		{
			if(!dGlobal)
				dGlobal = new Date;				
			var dCurrent:Date = new Date;
			var txt:String;
			if (start)
				txt = dCurrent.hours+":"+dCurrent.minutes+":"+dCurrent.seconds+":"+dCurrent.milliseconds; 
			else
				txt = dCurrent.hours+":"+dCurrent.minutes+":"+dCurrent.seconds+":"+dCurrent.milliseconds+ 
					" (разница " +(dCurrent.time - dGlobal.time)+"мс)";
			
			dGlobal = new Date;
			return txt; 
		}
		private static var tStart:Number;
		public static function timerResultGet(sec:Boolean=false):String
		{
			var tNow:Number = getTimer();
			var txt:String;
			if (!sec)
				txt = "(разница " +(tNow - tStart)+"мс)";
			else
				txt = "(разница " +((tNow - tStart)/1000).toFixed(1)+" с)";
			tStart = getTimer();
			return txt; 
		}
		public static function getSpecificByteArray(b:ByteArray, from:int, to:int=0):ByteArray
		{
			b.position = from;
			var n:ByteArray = new ByteArray;
			var l:int = to==0 ? b.bytesAvailable: to
			b.readBytes( n, 0, l );
			return n;
		}
		public static function showTranscodedByteArray(b:ByteArray):String
		{
			var s:String = b.readMultiByte(b.bytesAvailable, "windows-1251" );
			b.position = 0;
			s = s.replace(/\r/g, "\\r");
			return s.replace(/\n/g, "\\n");
		}
		public static function showByteArray(b:ByteArray, linelen:int=32, pos:int=0, total:int=0):String
		{
			if (!b)
				return "byteArray is null";
			var len:int = b.length;
			var s:String = "";
			var totalLength:int = total;
			var counter:int;
			var c:int = 1;
			for (var i:int=pos; i<len; ++i) {
				
				if (total > 0 && counter > total)
					break;
				
				s += formateZerosInFront(int(b[i]).toString(16),2).toUpperCase() + " ";
				if (c==linelen) {
					c = 1;
					s += "\n";
				} else
					c++;
				
				counter++;
			}
			/*trace("Массив длиной "+b.length + "\r"+s);
			trace(s);*/
			return s;
		}
		public static function compareByteArray(b1:ByteArray, b2:ByteArray, depth:int=32):void
		{
			if (b1.length == b2.length) {
				var len:int = b1.length;
				if (len > depth)
					len = depth;
				for (var i:int=0; i<len; ++i) {
					if ( b1[i] != b2[i] ) {
						
						var t1:String = UTIL.showByteArray( b1,32,0,len );
						var t2:String = UTIL.showByteArray( b2,32,0,len );
						trace(t1);
						trace(t2);
						break;
					}
				}
			} else
				trace("length mismatch");
		}
		public static function showArray(b:Array, linelen:int=32):String
		{
			var len:int = b.length;
			var s:String = "";
			var c:int = 0;
			for (var i:int=0; i<len; ++i) {
				
				s += formateZerosInFront(int(b[i]).toString(16),2).toUpperCase() + " ";
				if (c==(linelen-1)) {
					c = 0;
					s += "\n";
				} else
					c++;
			}
			return s;
			/*trace("Начало массива длиной "+b.length);
			trace(s);*/
		}
		public static function testRegExp(a:Array, re:RegExp):void
		{
			var len:int = a.length;
			for (var i:int=0; i<len; ++i) {
				trace( "soure:"+re.source+" target:" + a[i] +" result:"+Boolean( String(a[i]).search(re)==0 ));
			}
			
		}
		public static function comboBoxNumericDataGenerator( _minValue:int, _maxValue:int ):Array 
		{
			var arr:Array = new Array;
			for( var i:int=_minValue; i<=_maxValue; i++ ) {
				arr.push( {label:String(i), data:i } );
			}
			return arr;
		}
		public static function formateNumbersToLetters( _number:int):String {
			
			var stringNumber:String = String(_number);
			
			if ( stringNumber.length > 5 )
				return stringNumber.substring( 0, stringNumber.length-5 ) + " M";
			else if ( stringNumber.length > 3 ) {
				if ( stringNumber.length == 4 )
					return stringNumber.charAt(0)+","+stringNumber.charAt(1) + " K";
				else
					return stringNumber.substring( 0, stringNumber.length-3 )+","+stringNumber.charAt(2) + " K";
				
			}
			return stringNumber + " ";
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
		public static function testIsGarbage(pattern:Object, target:Object):Boolean
		{
			for( var key:String in target) {
				if ( target[key] != pattern )
					return false;
			}
			return true;
		}
		public static function enableCache(s:String):uint
		{
			
			s = "K-14";
			var b:ByteArray = new ByteArray;
			b.writeUTFBytes(s+s);
			b.position = 0;
			
			
			return b.readUnsignedInt();
		}
	}
}