package components.protocol.models
{
	import components.abstract.functions.loc;
	import components.static.COLOR;
	import components.system.UTIL;

	public class BinaryModel
	{
		public var uid:int;
		
		public var title:String="";
		public var hex:String="";
		public var dec:String="";
		public var error:String="";
		
		public var func:String;
		private var cmds:String; 
		
		public function BinaryModel(id:int)
		{
			uid = id;
			cmds = "";
		}
		public function addLine(_title:String,_hex:String,_dec:Object, _error:Object=null):void
		{
			title += _title + "\r";
			hex += _hex + "\r";
			dec += _dec.toString() + "\r";
			if (_error) {
				error += _error.toString();
				cmd = UTIL.wrapHtml(loc("sys_error"), COLOR.RED );
			} else
				error += "\r";
			
			var re:RegExp = new RegExp( /\n|\r\n/g);
			while( re.test(_hex) ) {
					title += "\r";
					dec += "\r"
					error += "\r";
			}
		}
		public function set cmd(s:String):void
		{
			if (cmds == "")
				cmds += s;
			else
				cmds += ", "+s;
		}
		public function get cmd():String
		{
			return cmds;
		}
	}
}