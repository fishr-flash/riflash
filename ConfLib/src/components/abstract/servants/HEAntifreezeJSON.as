package components.abstract.servants
{
	import flash.utils.ByteArray;
	
	import components.protocol.statics.OPERATOR;
	import components.static.CMD;
	import components.static.DS;

	public final class HEAntifreezeJSON
	{
		private var mindate:Number;
		private var maxdate:Number;
		
		private var mindatet:String;
		private var maxdatet:String;
		
		private var body:String;
		private var qtjson:QTJSON;
		private var header:Array;
		private var totalrec:int;
		
		public function HEAntifreezeJSON()		{		}
		
		public function init(h:Array):void
		{
			mindate = Number.MAX_VALUE;
			maxdate = 0;
			
			header = h;
			
			var a:Array = OPERATOR.dataModel.getData(CMD.VER_INFO1);
			var obj:Object = {};
			
			obj["IMEI"] = a is Array ? a[0][3] : "#error.cmd.not.requested";
			obj["History"] = DS.alias;
			
			var recs:Array = [];
			obj["RecordCount"] = "#recct";
			obj["DateTimeStart"] = "#datetimestart_12";
			obj["DateTimeEnd"] = "#datetimeend_1234";
			
			qtjson = new QTJSON;
			
			qtjson.stringify(obj);
		}
		public function add(a:Array):void
		{
			var len:int = a.length;
			for (var i:int=0; i<len; i++) {
				a[i] = formRec(a[i]);
			}
			totalrec += len;
			qtjson.add(a);
		}
		public function getGasps():Array
		{
			return qtjson.getGasps();
		}
		public function getBytes():ByteArray
		{
			qtjson.replace( "#recct", totalrec );
			qtjson.replace( "#datetimestart_12", mindatet );
			qtjson.replace( "#datetimeend_1234", maxdatet );
			return qtjson.getFile();
		}
		public function getRecIndex(a:Array):Array
		{
			return formRec(a);
		}
		private function formRec(rec:Array):Array
		{
			var a:Array = [];
			var date:Object = {};
			
			var len:int = header.length;
			for (var i:int=0; i<len; i++) {
				a.push( {name:header[i],data:rec[i] } );
				if (header[i] == "Date")
					date.Date = rec[i];
				if (header[i] == "Time")
					date.Time = rec[i];
			}
			var s:String = date.Date+" "+date.Time;
			var d:Date = parseUTCDate(s);
			if (d && d.time < mindate) {
				mindate = d.time;
				mindatet = parseReadableDate(s);
				if (mindatet == "undefined.undefined.00 undefined:undefined:undefined")
					trace();
			}
			if (d && d.time > maxdate) {
				maxdate = d.time;
				maxdatet = parseReadableDate(s);
			}
			return a;
		}
		private function parseReadableDate(str:String):String
		{
			var matches:Array = str.match(/(\d\d)/g);
			return matches[2]+"."+matches[1]+"."+matches[0]+" "+ matches[3]+":"+matches[4]+":"+matches[5];
		}
		private function parseUTCDate( str:String ):Date
		{
			if( str.search("NaN") > -1 )
				return null;
			
			var matches:Array = str.match(/(\d\d)/g);
			
			var d:Date = new Date();
			
			if (int(matches[2]) > 69)
				d.setUTCFullYear(int("19"+matches[2]), int(matches[1]) - 1, int(matches[0]));
			else
				d.setUTCFullYear(int("20"+matches[2]), int(matches[1]) - 1, int(matches[0]));
			d.setUTCHours(int(matches[3]), int(matches[4]), int(matches[5]));
			
			return d;
		}
	}
}
import flash.utils.ByteArray;

import components.abstract.functions.dtrace;
import components.abstract.functions.loc;
import components.system.UTIL;

class QTJSON
{
	private var ident:String;
	private var result:String;
	private var storage:Vector.<String>;
	private var bytes:ByteArray;
	private var index:uint;
	private var currentindex:uint;
	private var gasps:Array;	// массив содержит индексы истории которые были пропущены вовремя вычитывания
	private var headerplaced:Boolean= false;
	
	public function stringify(o:Object):void
	{
		result = "{\r";
		ident = "\t";
		stringifyParam("IMEI", o);
		stringifyParam("History", o);
		stringifyParam("RecordCount", o);
		stringifyParam("DateTimeStart", o);
		stringifyParam("DateTimeEnd", o);
		
		index=0;
		gasps = null;
		
		bytes = new ByteArray;
		bytes.writeUTFBytes( result );
		headerplaced = false;
		
		storage = new Vector.<String>;
	}
	public function add(a:Array):void
	{
		var res:String = "";
		var crcfail:Boolean;
		if(!headerplaced) {
			headerplaced = true;
			bytes.writeUTFBytes( ident + "\"Records\":\[\r" );
			increaseIdent();
		}
		var len:int = a.length;
		for (var i:int=0; i<len; i++) {
			crcfail=false;
			
			if (i>0) {
				res = res.slice(0,res.length-2);
				res += ",{\r";
			} else {
				if ( bytes[bytes.length-3] == 0x7d && bytes[bytes.length-2] == 0xd && bytes[bytes.length-1] == 0xa ) {
					// ,0xd0xa
					bytes.position = bytes.length-2;
					// надо сдвинуть байтмассив, чтобы стереть лишнее
					res += ",{\r";
				} else
					res += ident + "{\r";
			}
			increaseIdent();
			var lenj:int = a[i].length;
			for (var j:int=0; j<lenj; j++) {

				if (a[i][j].name == "CRC" && a[i][j].data == loc("g_yes") ) {
					// это значит ошибка в подсчете crc
					crcfail=true;
					break;
				}
				
				if( a[i][j].data is String )
					res += ident + "\"" + a[i][j].name + "\":\"" +a[i][j].data+"\"";
				else
					res += ident + "\"" + a[i][j].name + "\":" +a[i][j].data;
				if (j+1 == lenj)
					res += "\r";
				else
					res += ",\r";
				
				if (a[i][j].name == "Index") {
					currentindex = int(a[i][j].data);
				}
			}
			decreaseIdent();
			
			if( !crcfail ) {
				if (index>0) {
					if (index + 1 != currentindex) {
						if( !gasps )
							gasps = [];//["874256-874260"];
						gasps.push(index + "-" + currentindex)
					}
				}
				index = currentindex;
				res += ident + "}\r";
			} else {
				// если crc не правильное, не надо сохранять запись
				res = "";
			}
		}
		bytes.writeUTFBytes( res );
	}
	public function replace(tag:String, value:Object):void
	{
		if (value is int)
			result = result.replace( tag, UTIL.fz(value,tag.length) );
		else
			result = result.replace( tag, String(value) );
	}
	public function getGasps():Array
	{
		return gasps;
	}
	public function getFile():ByteArray
	{
		decreaseIdent();
		bytes.writeUTFBytes( ident + "]\r}" );
		bytes.position = 0;
		bytes.writeUTFBytes( result );
		if (gasps && gasps.length) {
			dtrace( "Разрывы в истории: " +gasps.toString() );
		}
		return bytes;
	}
	private function stringifyParam(key:String, o:Object):void
	{
		if(o[key] is String)
			result += ident + "\"" + key + "\":\"" +o[key]+ "\",\r";
		else
			result += ident + "\"" + key + "\":" +o[key]+ ",\r";
	}
	private function stringifyArray(a:Array):void
	{
		
	}
	private function increaseIdent():void
	{
		ident += "\t";
	}
	private function decreaseIdent():void
	{
		ident = ident.slice(0, ident.length-1);
	}
}