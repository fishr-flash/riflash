package components.abstract
{
	import components.abstract.offline.OfflineProcessor;
	import components.interfaces.IDataEngine;
	import components.protocol.models.CommandSchemaModel;
	import components.protocol.models.ParameterSchemaModel;
	import components.protocol.statics.OPERATOR;
	import components.static.DS;
	import components.static.MISC;
	import components.system.UTIL;
	
	public class StandDataEngine implements IDataEngine
	{
		public function StandDataEngine()
		{
		}
		
		public function save(navi:Array):String
		{
			var lenj:int = navi.length;
			var xml:String = "";
			for (var j:int=0; j<lenj; ++j) {
				var cmds:Array;
				var len:int = MISC.COPY_MENU.length;
				
				for (var i:int=0; i<len; ++i) {
					if ( MISC.COPY_MENU[i].data == navi[j] ) {
						var asa:Object =  MISC.COPY_MENU[i];
						cmds = MISC.COPY_MENU[i].cmds;
						break;
					}
				}
				if (cmds) {
					len = cmds.length;
					for (i=0; i<len; ++i) {
						xml += compile( cmds[i] );
					}
				}
			}
			return xml;
		}
		public function getExtension():String
		{
			return DS.deviceAlias+"_"+UTIL.getDataString()+".txt";
		}
		private function compile(cmd:int):String
		{
			var schema:CommandSchemaModel = OPERATOR.getSchema(cmd);
			var s:String = "";
			var len:int = schema.StructCount;
			var st:String = schema.Name.toLocaleUpperCase()+"=";
			for (var i:int=0; i<len; ++i) {
				s += st + (i+1)+getParams() + "\r";
			}
			return s;
			
			function getParams():String 
			{
				var ps:String = "";
				var lena:int = schema.Parameters.length;
				var p:ParameterSchemaModel;
				
				for (var a:int=0; a<lena; ++a) {
					p = (schema.Parameters[a] as ParameterSchemaModel);
					var tr:Object = OfflineProcessor.getData( schema.Id );
					if( OfflineProcessor.getData( schema.Id ) ) {
						if (!p.ReadOnly) {
							if ( p.Type == "Decimal" )
								ps+= ","+OfflineProcessor.getData( schema.Id )[i][ p.Order-1 ];
							else
								ps+= ",\""+OfflineProcessor.getData( schema.Id )[i][ p.Order-1 ]+"\"";
						} else
							ps =",";
					} else
						ps+= ",undefined";
				}
				return ps;
			}
		}
	}
}