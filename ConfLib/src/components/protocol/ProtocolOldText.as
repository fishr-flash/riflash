package components.protocol
{
	import flash.utils.ByteArray;
	
	import components.basement.SourceProtocol;
	import components.interfaces.IRequestAssembler;
	import components.protocol.models.CommandSchemaModel;
	import components.protocol.statics.OPERATOR;
	import components.protocol.statics.SERVER;
	import components.system.UTIL;
	
	public class ProtocolOldText extends SourceProtocol
	{
		private var assembler:IRequestAssembler;
		private var funct:int;
		private var cmd:CommandSchemaModel;
		private var structureID:int;
		private var changeStructure:Boolean;	// менять структуру можно только если команда мультиструктурная
		
		public function ProtocolOldText(_requeue:Function, _complete:Function, ira:IRequestAssembler)
		{
			super();
			
			fRequeue = _requeue;
			fComplete = _complete;
			assembler = ira;
		}
		public function processRequset( re:ProtocolRequest ):void
		{
			var b:ByteArray = new ByteArray;
			var s:String = "+";
			var r:Request = re.shift();
			cmd = OPERATOR.getSchema( r.cmd );
			
			funct = re.func;
			structureID = r.structure;
			var structAdd:String = r.structure > 0 && cmd.StructCount > 1 ? String(r.structure-1) : "";
			var hs:String;
			
			if(re.func == SERVER.REQUEST_READ) {
				if (cmd.Feature == "hexstructure") {
				//	structAdd = String(r.structure);
					hs = (UTIL.fz( (r.structure ).toString(16),4)).toUpperCase();
					s += cmd.Name + hs + "\r";
				} else if (cmd.Feature == "twodigitstructure") {
					s += cmd.Name + UTIL.fz( r.structure.toString(16).toUpperCase(),2) + "\r";
				} else
					s += cmd.Name + structAdd + "\r";
			} else {
				if (cmd.Feature == "hexstructure") {
					//	structAdd = String(r.structure);
					hs = (UTIL.fz( (r.structure ).toString(16),4)).toUpperCase();
					//s += cmd.Name + hs + "\r";
					switch(cmd.Name) {
						case "W":
							s += cmd.Write + hs + ":" + r.data[0] +"\r";
							break;
						case "EE":
							s += cmd.Write + r.data[0] +"\r";
							break;
						default:
							s += cmd.Write + hs + "=" + r.data[0] +"\r";
							break;
					}
				} else if (cmd.Feature == "twodigitstructure") {
					s += cmd.Write + UTIL.fz(r.structure.toString(16).toUpperCase(),2) + "=" + r.data[0] +"\r";
				} else
					s += cmd.Write + structAdd + "=" + r.data[0] +"\r";
			}
			trace("OUT> "+s.slice(0, s.length-1) );
			
			changeStructure = structAdd != ""
			b.writeMultiByte(s, "windows-1251");
			b.position = 0;
			assembler.initSocket( b );
		}
		public function processResponse( _response:Array ):void
		{
			if (!_response)
				funct = SERVER.BROKEN;
			else {
				if ( _response[0].search( /(ERR\r?)/g ) > -1 || _response[0].search( /(IGN\r?)/g ) > -1) 
					funct = SERVER.ERROR;
			}
			
			var post:Vector.<Package> = new Vector.<Package>;
			var p:Package;
			switch( funct ) {
				case SERVER.REQUEST_READ:
					post.push( disassembleReadPacket( _response[0] ));
					break;
				case SERVER.REQUEST_WRITE:
					p = new Package;
					p.cmd = cmd.Id;
					p.success = true;
					if (cmd && cmd.Name == "W")
						p.data = _response;
					post.push( p );
					break;
				case SERVER.BROKEN:	// когда искуственно посылается сломаный или недошедший пакет, чтобы увеличить его номер при пересылке
					p = new Package;
					p.cmd = cmd.Id;
					p.broken = true;
					post.push( p );
					break;
				case SERVER.ERROR:
					p = new Package;
					p.cmd = cmd.Id;
					p.structure = structureID;
					p.error = true;
					post.push( p );
					break;
			}
			assembler.delegateAssembler( post, 1 );
		}
		private function disassembleReadPacket( str:String ):Package
		{
			var s:String = str.replace( /\r?OK\r/g, "" );
			var a:Array = [];
			if (changeStructure)
				a[structureID-1] = [s];
			else
				a[structureID] = [s];
			
			var p:Package = new Package;
			p.cmd = cmd.Id;
			p.data = a;
			p.structure = structureID;
			return p;
		}
	}
}