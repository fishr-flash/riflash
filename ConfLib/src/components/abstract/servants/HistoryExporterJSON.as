package components.abstract.servants
{
	import flash.utils.ByteArray;
	
	import components.protocol.statics.OPERATOR;
	import components.static.CMD;
	import components.static.DS;
	import components.system.UTIL;

	public class HistoryExporterJSON
	{
		private var mindate:Number;
		private var maxdate:Number;
		
		private var mindatet:String;
		private var maxdatet:String;
		
		public function compile(header:Array, book:Object):ByteArray
		{
			mindate = Number.MAX_VALUE;
			maxdate = 0;
			var a:Array = OPERATOR.dataModel.getData(CMD.VER_INFO1);
			var obj:Object = {};
			
			obj["IMEI"] = a is Array ? a[0][3] : "#error.cmd.not.requested";
			obj["History"] = DS.alias;
			
			var recs:Array = [];
			var totalrec:int;
			for( var key:String in book) {
				recs.push( formRec(header, book[key] ) );
				totalrec++;
			}
			obj["RecordCount"] = totalrec;
			obj["DateTimeStart"] = mindatet;
			obj["DateTimeEnd"] = maxdatet;
			obj["Records"] = recs;
			
			var s:String = CuteJSON.stringify(obj);
			
			var b:ByteArray = new ByteArray;
//			b.writeUTFBytes(formatJson(JSON.stringify(obj)));
			b.writeUTFBytes(s);
			b.position = 0
			return b;
		}
		private function formatJson(s:String):String
		{
			var len:int = s.length;
			var res:String = "";
			var level:String = "";
			var lastsymbol:String = "";
			for (var i:int=0; i<len; i++) {
				if( s.charAt(i) == "{" || s.charAt(i) == "[" ) {
					level += "\t";
					res += s.charAt(i) + "\r" + level;
					
				} else if( s.charAt(i) == "}" || s.charAt(i) == "]" ) {
					level = level.slice( 0, level.length-1 );
					res += "\r" + level+ s.charAt(i);
					
				} else if( s.charAt(i) == "," ) {
					
					if ( (s.charAt(i-1) == "}" && s.charAt(i+1) == "{") || (s.charAt(i-1) == "]" && s.charAt(i+1) == "[") )
						res += s.charAt(i);
					else
						res += s.charAt(i) + "\r" + level;
				} else
					res += s.charAt(i);
			}
			return res;
		}
		
		private function formRec(h:Array, rec:Array):Array
		{
			var a:Array = [];
			var date:Object = {};
			
			var len:int = h.length;
			for (var i:int=0; i<len; i++) {
				a.push( {name:h[i],data:rec[i] } );
				if (h[i] == "Date")
					date.Date = UTIL.fz(int(rec[i]).toString(16),6);
				if (h[i] == "Time")
					date.Time = UTIL.fz(int(rec[i]).toString(16),6);
			}
			var s:String = date.Date+" "+date.Time;
			var d:Date = parseUTCDate(s);
			if (d.time < mindate) {
				mindate = d.time;
				mindatet = parseReadableDate(s);
			}
			if (d.time > maxdate) {
				maxdate = d.time;
				maxdatet = parseReadableDate(s);
			}
			return a;
		}
		/*private function formRec(h:Array, rec:Array):Object
		{
			var o:Object = {};
			var date:Object = {};
			
			var len:int = h.length;
			for (var i:int=0; i<len; i++) {
				o[h[i]] = rec[i];
				if (h[i] == "Date")
					date.Date = h[i];
				if (h[i] == "Time")
					date.Time = h[i];
			}
			var s:String = date.Date+" "+date.Time;
			var d:Date = parseUTCDate(s);
			if (d.time < mindate) {
				mindate = d.time;
				mindatet = s;
			}
			if (d.time > maxdate) {
				maxdate = d.time;
				maxdatet = s;
			}
			return o;
		}*/
		private function parseReadableDate(str:String):String
		{
			var matches:Array = str.match(/(\d\d)/g);
			return matches[2]+"."+matches[1]+"."+matches[0]+" "+ matches[3]+":"+matches[4]+":"+matches[5];
		}
		private function parseUTCDate( str:String ):Date
		{
			var matches:Array = str.match(/(\d\d)/g);
			
			var d:Date = new Date();
			
			d.setUTCFullYear(int("20"+matches[2]), int(matches[1]) - 1, int(matches[0]));
			d.setUTCHours(int(matches[3]), int(matches[4]), int(matches[5]));
			
			return d;
		}
	}
}
class CuteJSON
{
	private static var ident:String;
	private static var result:String;
	
	public static function stringify(o:Object):String
	{
		result = "{\r";
		ident = "\t";
		stringifyParam("IMEI", o);
		stringifyParam("History", o);
		stringifyParam("RecordCount", o);
		stringifyParam("DateTimeStart", o);
		stringifyParam("DateTimeEnd", o);
		stringifyArray("Records", o.Records);
		result += "}";
		return result;
	}
	private static function stringifyParam(key:String, o:Object):void
	{
		if(o[key] is String)
			result += ident + "\"" + key + "\":\"" +o[key]+ "\",\r";
		else
			result += ident + "\"" + key + "\":" +o[key]+ ",\r";
	}
	private static function stringifyArray(key:String, a:Array):void
	{
		result += ident + "\"" + key + "\":\[\r";
		increaseIdent();
		var len:int = a.length;
		for (var i:int=0; i<len; i++) {
			if (i>0) {
				result = result.slice(0,result.length-2);
				result += ",{\r";
			} else
				result += ident + "{\r";
			increaseIdent();
			var lenj:int = a[i].length;
			for (var j:int=0; j<lenj; j++) {
				if( a[i][j].data is String )
					result += ident + "\"" + a[i][j].name + "\":\"" +a[i][j].data+"\"";
				else
					result += ident + "\"" + a[i][j].name + "\":" +a[i][j].data;
				if (j+1 == lenj)
					result += "\r";
				else
					result += ",\r";
			}
			decreaseIdent();
			result += ident + "}\r";
			
		}
		decreaseIdent();
		result += ident + "]\r";
	}
	private static function increaseIdent():void
	{
		ident += "\t";
	}
	private static function decreaseIdent():void
	{
		ident = ident.slice(0, ident.length-1);
	}
}