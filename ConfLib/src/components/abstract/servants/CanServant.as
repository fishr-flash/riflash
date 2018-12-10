package components.abstract.servants
{
	import components.abstract.functions.loc;
	import components.gui.PopUp;
	import components.static.DS;
	import components.static.MISC;

	public class CanServant
	{
		public function CanServant()
		{
		}
		private var cars:Array;
		private var models:Object;
		public var years:Object;
		
		public function getY(key:String):Array
		{
			return years[key];
		}
		
		private var rs485user:String;
		public function isRF485(s:String):Boolean
		{
			return rs485user == s; 
		}
		
		public function put(obj:Object):void
		{
			if (obj) {
				var s:String = String(obj);
				var a:Array = s.split("\r\n");
				var len:int = a.length;
				var _carsunique:Object = {};
				cars = [{label:loc("ui_can_not_selected"),data:loc("ui_can_not_selected")}];
				years = {};
				years[loc("ui_can_not_selected")+", "+loc("g_no")] = [{label:"-", data:0}];
				models = {};
				models[loc("ui_can_not_selected")] = [{label:"-", data:loc("g_no")}];
				var modelunique:Object = {};
				
				var item:Array;
				for (var i:int=0; i<len; i++) {
					item = (a[i] as String).split("\t");
					
					if (!item || item.length < 4 || item.length > 5 ) {
						if (MISC.COPY_DEBUG && !(item && item[0] is String && (item[0] as String).slice(0,2) == "//") ) {
							PopUp.getInstance().construct( 
								PopUp.wrapHeader("g_parse_error"), PopUp.wrapMessage( loc("ui_can_file_contains_error")+" "+(i+1) ), 
								PopUp.BUTTON_OK );  
							PopUp.getInstance().open();
						}
						continue;
					}
					if (!passRules(item[4]))
						continue;
					if (int(item[0]) == 66)	// запоминаем название 66 параметра, он использует rs485 и требует доп логики
						rs485user = item[1];
					if( !_carsunique[item[1]] )
						_carsunique[item[1]] = {};
					if( !models[item[1]] )
						models[item[1]] = [];
					if (!modelunique[item[2]] || item[2] == "-") {
						modelunique[item[2]] = true;
						(models[item[1]] as Array).push( {label:item[2],data:item[2]} );
					}
					if (!years[item[1]+", "+item[2]])
						years[item[1]+", "+item[2]] = [];
					(years[item[1]+", "+item[2]] as Array).push( {label:item[3],data:int(item[0]),sort:getYear(item[3])} );
				}
				for( var key:String in _carsunique) {
					cars.push( {label:key, data:key} );
				}
				cars.sortOn( "data" );
				
				for( key in models) {
					if( (models[key] as Array).length > 1 )
						(models[key] as Array).sortOn( "data" );
				}
				for( key in years) {
					if( (years[key] as Array).length > 1 )
						(years[key] as Array).sortOn( "sort" );
				}
			}
		}
		public function getCarsMenu():Array
		{
			return cars;
		}
		public function getModelsMenu(value:String):Array
		{
			return models[value];
		}
		public function getYearsMenu(value:String):Array
		{
			return years[value];
		}
		private function getYear(s:String):String
		{
			var years:Array = s.match( /([1-2][9,0]\d\d)/g );
			if (years.length > 0)
				return years[0];
			return "0";
		}
		private function passRules(r:String):Boolean
		{
			if (!r)
				return true;
			
			var a:Array = r.split(";");
			var passRelease:Boolean = false;
			var passDevice:Boolean = false;
			if (!a[0] || a[0] == "" || DS.release >= int(a[0]) )
				passRelease = true;
			if (!a[1] || a[1] == "" )
				passDevice = true;
			else {
				var d:Array =  String(a[1]).split(",");
				var len:int = d.length;
				for (var i:int=0; i<len; i++) {
					if (DS.alias == d[i] ) {
						passDevice = true;
						break;
					}
				}
			}
			return passRelease && passDevice;
		}
	}
}