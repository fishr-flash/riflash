package components.abstract.servants
{
	import flash.utils.ByteArray;

	public class HistoryExporterKML
	{
		private const KEY_LON:String = "Долгота";
		private const KEY_LAT:String = "Широта";
		private const KEY_DATE:String = "Дата";
		private const KEY_TIME:String = "Время";
		
		
		public function HistoryExporterKML()
		{
		}
		public function compile(header:Array, book:Array):ByteArray
		{
			var cell_lon:int, cell_lat:int, cell_date:int, cell_time:int, len:int = header.length;
			for (var i:int=0; i<len; ++i) {
				if(header[i] == KEY_LAT)
					cell_lat = i;
				if(header[i] == KEY_LON)
					cell_lon = i;
			}
			
			var result:String = "";
			len = book.length;
			for ( i=0; i<len; ++i) {
				if ( int(book[i][cell_lon]) != 0 || int(book[i][cell_lat]) != 0 ) {
					result += "<when>"+adaptTimestamp( book[i][cell_date] ) + "T"+book[i][cell_time]+".000Z" +"</when>\n"+
						"<gx:coord>"+  book[i][cell_lon] +" "+ book[i][cell_lat] + " 28.20001220703125</gx:coord>\n";
				}
			}
			
			var s:String = buildBody(result,adaptTimestamp(book[0][cell_date]));
			
			var b:ByteArray = new ByteArray;
			b.writeMultiByte(s,"CP1251");
			b.position = 0
			
			return b;
		}
		private function adaptTimestamp(d:String ):String
		{	// 01.01.70
			var res:String = "";
			var y:String = d.substr(7);
			var m:String = d.substr(4,2);
			var d:String = d.substr(0,2);
			return int(y) > 69?"20"+y:"19"+y+"-"+m+"-"+d;
		}
		private function buildBody(track:String, date:String):String
		{
		//date - <name><![CDATA["+18.01.2013 21:55+"]]></name>
			return "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"+
			"<kml xmlns=\"http://www.opengis.net/kml/2.2\" xmlns:gx=\"http://www.google.com/kml/ext/2.2\"" +
			"	xmlns:atom=\"http://www.w3.org/2005/Atom\">"+
				"<Document>"+
					"<open>1</open>"+
					"<visibility>1</visibility>"+
					"<name><![CDATA["+date+"]]></name>"+
					"<Style id=\"track\">"+
						"<LineStyle>"+
							"<color>7f0000ff</color>"+
							"<width>4</width>"+
						"</LineStyle>"+
						"<IconStyle>"+
							"<scale>1.3</scale>"+
							"<Icon>"+
								"<href>http://earth.google.com/images/kml-icons/track-directional/track-0.png"+
								"</href>"+
							"</Icon>"+
						"</IconStyle>"+
					"</Style>"+
					"<Placemark id=\"tour\">"+
						"<name><![CDATA[18.01.2013 21:55]]></name>"+
						"<description><![CDATA[]]>"+
						"</description>"+
						"<styleUrl>#track</styleUrl>"+
						"<gx:MultiTrack>"+
							"<altitudeMode>absolute</altitudeMode>"+
							"<gx:interpolate>1</gx:interpolate>"+
							"<gx:Track>"+track +
//								<when>2013-01-18T17:52:19.000Z</when>
//								<gx:coord>30.408898 59.84873 28.20001220703125</gx:coord>
							"</gx:Track>"+
						"</gx:MultiTrack>"+
					"</Placemark>"+
				"</Document>"+
			"</kml>";
		}
	}
}