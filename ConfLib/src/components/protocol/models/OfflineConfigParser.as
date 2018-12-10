package components.protocol.models
{
	import com.mapquest.tilemap.controls.oceanbreeze.OBDisplayObject;
	
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.statics.OPERATOR;
	import components.static.CMD;
	import components.static.DS;
	import components.static.MISC;
	import components.system.UTIL;

	public class OfflineConfigParser
	{
		public var dm:DataModel;	// local
		//	public var dmo:DataModel;	// online
		private var loadedDM:DataModel;
		
		public function OfflineConfigParser()
		{
			dm = new DataModel;
		}
		public function mergeData(a:Array):void
		{
			var menu:Array = MISC.COPY_MENU;
			var p:Package;
			var len:int = a.length;
			var cmdset:Array;
			for (var i:int=0; i<len; ++i) {
				cmdset = getCMDset( int(a[i]) );//menu[int(a[i])].cmds;
				if (cmdset) {
					var lenj:int = cmdset.length;
					for (var j:int=0; j<lenj; ++j) {
						p = Package.create( loadedDM.getData(cmdset[j]), 0 );
						p.cmd = cmdset[j];
						dm.update( p );
					}
				}
			}
			
			function getCMDset(n:int):Array
			{
				var lenk:int = menu.length;
				for (var k:int=0; k<lenk; ++k) {
					if( menu[k].data == n )
						return menu[k].cmds; 
				}
				return null;
			}
		}
		public function assembleRequests(xml:XML):Array
		{
			var commands:XMLList = xml.descendants("CommandDataModel");
			var cmd:int;
			var r:Request;
			var structs:Array;
			var len:int;
			var i:int;
			var requests:Array = [];
			for each (var command:XML in commands) {
				 
				
				
				cmd = int(command.Id.toString());
				
				if( DS.isfam( DS.K5 ) && cmd === CMD.MASTER_CODE ) continue;
				
				
				structs = getArrayByCmd( cmd, xml );
				len = structs.length;
				for (i=0; i<len; i++) {
					requests.push( new Request(cmd, null, i+1, structs[i] ) );
				}
			}
			return requests;
		}
		public function assembleMenuStructure(xml:XML):Array
		{
			var commands:XMLList = xml.descendants("CommandDataModel");
			var available:Object = {};
			var p:Package;
			loadedDM = new DataModel;
			
			for each (var command:XML in commands) {
				available[ command.Id.toString() ] = true;
				
				var currentId:int = int(command.Id.toString());
				p = Package.create( getArrayByCmd( currentId, xml ), 0 );
				p.cmd = currentId;
				loadedDM.update( p );
			}
			
			var menu:Array = MISC.COPY_MENU;
			var assemblege:Array = [];
			var cmds:Array;
			var current:Object;
			var len:int = menu.length;
			for (var i:int=0; i<len; ++i) {
				current = UTIL.cloneObject( menu[i] );
				current.disabled = true;
				if (menu[i].cmds) {
					cmds = menu[i].cmds;
					var complete:Boolean = true;
					var atleastOne:Boolean = false;
					var lenj:int = cmds.length;
					for (var j:int=0; j<lenj; ++j) {
						if( !available[String(cmds[j])] ) {	// если команды в списке нет совсем
							complete = false;
							//break;
						} else {
							// если команда есть, но количество структур не совпадает
							if ( OPERATOR.getSchema(cmds[j]).StructCount != loadedDM.getData( cmds[j] ).length )
								complete = false;
							atleastOne = true;
						}
					}
					if (complete || atleastOne) {
						delete current.disabled;
						if (!complete)
							current.incomplete = true;
					}
				}
				assemblege.push( current );
			}
			return assemblege;
		}
		private function getArrayByCmd(cmd:int, xml:XML):Array
		{
			var c:Array = new Array;
			
			var schema:CommandSchemaModel = OPERATOR.getSchema(cmd);
			var commands:XMLList = xml.descendants("CommandDataModel");
			if (!schema)
				return null;
			
			for each (var command:XML in commands) {
				var currentId:int = int(command.Id.toString());
				if (cmd == currentId) {
					var structures:XMLList = command.descendants("StructureDataModel");
					var strNum:int;
					
					for each (var str:XML in structures) {
						
						strNum = int(str.Number.toString()); 
						var a:Array = new Array;
						var params:XMLList = str.descendants("ParameterDataModel");
						var num:int;
						for each (var p:XML in params) {
							num = int(p.Order.toString());
							if( (schema.Parameters[num-1] as ParameterSchemaModel).Type == "Decimal" ) {
								a[num-1] = int(p.Value.toString());
							} else {
								var txt:String = p.Value.toString();
								a[num-1] = txt.slice(1,txt.length-1);
							}
						}
						c[strNum-1] = a;
					}
					break;
				}
			}
			return c;
		}
	}
}