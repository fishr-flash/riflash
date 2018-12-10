package components.abstract.offline
{
	import components.interfaces.IDataEngine;
	import components.protocol.models.CommandSchemaModel;
	import components.protocol.models.ParameterSchemaModel;
	import components.protocol.statics.OPERATOR;
	import components.static.DS;
	import components.static.MISC;
	import components.system.UTIL;

	/**
	 *  Формирует хмл структуры из полученных в "сыром" виде данных
	 * настроек прибора для записи в файл
	 */
	public class DataEngine implements IDataEngine
	{
		public function save(navi:Array):String
		{
			var lenj:int = navi.length;
			var xml:String = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\r\n<ArrayOfCommandDataModel release=\""+DS.release+"\">\r\n";
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
			return xml + "</ArrayOfCommandDataModel>";
		}
		public function saveraw(cmds:Array):String
		{
			var xml:String = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\r\n<ArrayOfCommandDataModel>\r\n";
			var len:int = cmds.length;
			for (var i:int=0; i<len; ++i) {
				xml += compile( cmds[i] );
			}
			
			
			return xml + "</ArrayOfCommandDataModel>"
		}
		public function getExtension():String
		{
			return DS.deviceAlias+"_"+UTIL.getDataStringWod()+".rcf";
		}
		private function compile(cmd:int):String
		{
			var schema:CommandSchemaModel = OPERATOR.getSchema(cmd);
			var s:String = "  <CommandDataModel>\r\n" +
				"    <Id>"+schema.Id+"</Id>\r\n"+
				"    <Name>"+schema.Name+"</Name>\r\n"+
				"    <Structures>\r\n";
			
			var len:int = schema.StructCount;
			
			var st:String = "";
			var blk:String;
			for (var i:int=0; i<len; ++i) {
				blk = getParams();
				
				st += "      <StructureDataModel>\r\n"+
					"        <Number>"+(i+1)+"</Number>\r\n"
					 + blk +
					"      </StructureDataModel>\r\n";
			}
			s += st + "    </Structures>\r\n"+
				"  </CommandDataModel>\r\n";
			
			return s;
			
			function getParams():String 
			{
				var ps:String = "        <Parameters>\r\n";
				var lena:int = schema.Parameters.length;
				var p:ParameterSchemaModel;
				var arr:Array;
				
				for (var a:int=0; a<lena; ++a) {
					p = (schema.Parameters[a] as ParameterSchemaModel);
					ps += "          <ParameterDataModel>\r\n"+
						"            <Order>"+p.Order+"</Order>\r\n";
					
					arr = OPERATOR.currentDataModel.getData( schema.Id ); 
					
					if( arr ) {
						if ( p.Type == "Decimal" )
							ps+= "            <Value>"+int(arr[i][ p.Order-1 ])+"</Value>\r\n";
						else {
							var symboltest:String = arr[i][ p.Order-1 ];
							
							if( symboltest.search(/(?!\&amp;)\&/g) > -1 )
								symboltest = symboltest.replace(/(?!\&amp;|&lt;|&gt;)\&/g,"&amp;");
							if( symboltest.search(/(?!\&lt;)\</g) > -1 )
								symboltest = symboltest.replace(/(?!\&lt;)\</g,"&lt;");
							if( symboltest.search(/(?!\&gt;)\&/g) > -1 )
								symboltest = symboltest.replace(/(?!\&gt;)\>/g,"&gt;");
							
							symboltest.search(/<>&/g);
							ps+= "            <Value>\""+symboltest+"\"</Value>\r\n";
						}
					} else
						ps+= "            <Value>undefined</Value>\r\n";
					ps += "          </ParameterDataModel>\r\n";
				}
				ps += "        </Parameters>\r\n";
				
				
				
				return ps;
			}
		}
	}
}