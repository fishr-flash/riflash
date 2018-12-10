package components.abstract.servants
{
	import flash.utils.ByteArray;
	
	import components.abstract.TextSnapshoter;
	import components.abstract.servants.primitive.LSDIsoData;

	public class LcdIsoServant
	{
		protected static var _self:LcdIsoServant;

		private var _ents:Vector.<LSDIsoData>;
		
		public function get ents():Vector.<LSDIsoData>
		{
			return _ents;
		}

		public static function get self():LcdIsoServant
		{
			if( !_self ) _self = new LcdIsoServant;
			
			return _self;
		}
		
		
		public function inputRaw( b:ByteArray ):void
		{
			enumerationXMLSubjects( b );
		}
		
		
		private function enumerationXMLSubjects( b:ByteArray ):void
		{
			const xml:XML = XML(  b.toString() );
			
			const command_KBD_PARTITION_NAME:XML = xml.CommandDataModel.( Id == "862" )[ 0 ];
			const command_KBD_ZONES_NAME:XML = xml.CommandDataModel.( Id == "863" )[ 0 ];
			_ents = new Vector.<LSDIsoData>;
			
			if( command_KBD_PARTITION_NAME ) 
				_ents = _ents.concat( parseCommand( command_KBD_PARTITION_NAME ) );
			
			if( command_KBD_ZONES_NAME )
			_ents = _ents.concat( parseCommand( command_KBD_ZONES_NAME ) );
			
			
			
			
			
			
		}
		
		private function parseCommand( cmdsXML:XML ):Vector.<LSDIsoData>
		{
			
			//var ents:Array/*EntitieModelOfLCD*/ = new Array;
			var ents:Vector.<LSDIsoData> = new Vector.<LSDIsoData>();
			const structures:XMLList = cmdsXML.Structures.StructureDataModel;
			const lenStrct:int = structures.length();
			for ( var i:int = 0; i < lenStrct; i++ )
			{
				
				
				const params:XMLList = structures[ i ].Parameters.ParameterDataModel;
				
				const lenParams:int = params.length();
				
				const ent:LSDIsoData = new LSDIsoData;
				ent.command = cmdsXML.Id;
				ent.struct = structures[ i ].Number;
				const param1:String = params[ 0 ].Value.toString().replace( /"/g,"");
				const param2:String = params[ 1 ].Value.toString().replace( /"/g,"");
				
				if( param2.length )
					ent.paramsValue = param1 + "\r" + param2;
				else
					ent.paramsValue = param1;
				 
				
				
				ent.isoData = TextSnapshoter.self.snapshotTextField( ent.paramsValue );
				ents.push( ent );
				
				
			}
			
			return ents;
			
		}
	}
}

