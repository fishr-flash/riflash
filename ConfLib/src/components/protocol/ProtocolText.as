package components.protocol
{
	import components.basement.SourceProtocol;
	import components.events.GUIEventDispatcher;
	import components.events.SystemEvents;
	import components.interfaces.IRequestAssembler;
	import components.protocol.models.CommandSchemaModel;
	import components.protocol.models.ParameterSchemaModel;
	import components.protocol.statics.OPERATOR;
	import components.protocol.statics.SERVER;
	
	import flash.utils.ByteArray;
	
	public class ProtocolText extends SourceProtocol
	{
		private var cmd:CommandSchemaModel;
		private var request:Request;
		private var assembler:IRequestAssembler;
		
		public function ProtocolText(_requeue:Function, _complete:Function, ira:IRequestAssembler)
		{
			super();
			fRequeue = _requeue;
			fComplete = _complete;
			assembler = ira;
		}
		public function processRequset( re:ProtocolRequest ):void
		{
			if ( !assembler.online() )
				return;
			
			request = re.shift();
			
			cmd = OPERATOR.getSchema( request.cmd );
			var cmdRequest:String = "+" + cmd.Name + "=";
			if ( request && request.structure > 0 ) {
				cmdRequest += request.structure + ",";
			}
			
			switch( re.func ) {
				case SERVER.REQUEST_READ:
					cmdRequest += "?";
					break;
				case SERVER.REQUEST_WRITE:
					var len:int = request.data.length;
					for( var i:int; i<len; ++i ) {
						if ( i!=0 ) cmdRequest += ",";
						
						if ( (cmd.Parameters[i] as ParameterSchemaModel).ReadOnly == false ) {
							
							switch ( (cmd.Parameters[i] as ParameterSchemaModel).Type ) {
								case "String":
									cmdRequest += "\"" + request.data[i] + "\"";
									break;
								case "Decimal":
									cmdRequest += request.data[i];
									break;
							}
						}
					}
					
					break;
			}

			var ba:ByteArray = new ByteArray;
			ba.writeMultiByte( cmdRequest +"\r","windows-1251" );
			RequestAssembler.getInstance().initSocket( ba );
		}
		public function processResponse( _response:Array ):void
		{
			var funct:uint = _response[10];
			var p:Package = new Package;
			p.cmd = cmd.Id;
			p.structure = request.structure;
			var v:Vector.<Package> = new Vector.<Package>;
			if ( _response[0] == "OK\r") {
				p.success = true;
				v.push(p);
				fComplete(v);
			} else {
				var response:String = (_response[0] as String).slice( 0, (_response[0] as String).search( "\rOK" ));
				var aStructures:Array = response.split( "\r" );
				var len:int = aStructures.length;
				var aReadyData:Array = new Array;
				
				for( var i:int; i < len; ++i ) {
					aReadyData.push( (aStructures[i] as String).split( "," ) );
				}
				
				if ( aReadyData.every( isResponseValid ) ) {
					p.data = aReadyData;
					v.push(p);
					fComplete(v);
				} else
					GUIEventDispatcher.getInstance().fireSystemEvent( SystemEvents.pageLoadLComplete );
			}
		}
		private function isResponseValid( element:Array , index:int, arr:Array ):Boolean
		{
			if (element.length == 1 && element[0] == "") {
				arr.splice( index, 1 );
				return true;
			}
				
			if ( element.length != cmd.Parameters.length ) // Ошибка в текстовом протоколе: количество стуктур не совпадает обработанными данными
				return false;
			var len:int = element.length;
			for( var i:int; i < len; ++i ) {
				if ( (cmd.Parameters[i] as ParameterSchemaModel).Type == "String" ) {
					element[i] = (element[i] as String).slice( 1, (element[i] as String).length-1 );
				} else if ( (cmd.Parameters[i] as ParameterSchemaModel).Type == "Decimal" ) {
					element[i] = int(element[i]);
				}
			}
			return true;
		}
	}
}