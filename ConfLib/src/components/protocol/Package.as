package components.protocol
{
	import components.abstract.functions.dtrace;
	import components.protocol.statics.OPERATOR;
	import components.system.UTIL;

	public class Package
	{
		public var error:Boolean;		// когда случается ошибка в протоколе
		public var _broken:Boolean;		// помечается недошедший от прибора пакет
		public function set broken(value:Boolean):void
		{
			_broken = value;
		}
		public function get broken():Boolean 
		{
			return _broken;
		}
		public var success:Boolean;		// когда приходит удачный ответ на запись 
		public var cmd:int;
		public var data:Array;
		public var structure:int;
		public var request:Request;
		public var bin2response:Boolean=true;
		public var compressed:Boolean=false;
		
		public var id:Number;
		
		public function Package()
		{
			id = UTIL.generateUId();
		}

		public function getValidStructure():Array
		{
			for( var key:String in data) {
				if (data[key] is Array)
					return data[key]; 
			}
			return null;
		}
		public function getStructure(num:int=1):Array
		{
			if (data && data[num-1])
				return data[num-1];
			return new Array;
		}
		public function getParam(num:int, str:int=1):Object
		{
			if (data && data[str-1] && data[str-1][num-1] != null)
				return data[str-1][num-1];
			
			dtrace( "error@package.getParam, cmd:"+ OPERATOR.getSchema(cmd).Name );
			
			return null;
		}
		public function getParamInt(num:int, str:int=1):int
		{
			return int(getParam(num,str));
		}
		public function getParamString(num:int, str:int=1):String
		{
			return String(getParam(num,str));
		}
		public function get length():int
		{
			return data?data.length:0;
		}
		public function launch():void
		{
			if(request && request.delegate is Function) {
				if (request.smoothloader)
					request.smoothloader.update(request.cmd, structure==0, structure);
				request.delegate(this);
			}
		}
		public function attach(p:Package):void
		{
			if (cmd == p.cmd)
				data = data.concat( p.data );
		}
		
		/**
		 *
		 * Выделяет из общего пакета данных, данные относящиеся
		 * к конкретной команде и возвращает их в виде отдельного 
		 * пакета
		 *  
		 * @param s package
		 * @return package
		 * 
		 */		
		public function detach(s:int):Package
		{
			var p:Package = new Package;
			p.cmd = cmd;
			p.structure = s;
			p.data = new Array;
			p.data[s-1] = getStructure(s);
			return p;
		}
		public function get serverAdr():int
		{
			if (request)
				return request.serverAdr;
			return 0;
		}
		public static function create(a:Array, struct:int=1):Package
		{
			var p:Package = new Package;
			p.data = a;
			p.structure = struct;
			return p;
		}
	}
}