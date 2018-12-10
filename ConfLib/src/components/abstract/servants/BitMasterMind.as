package components.abstract.servants
{
	import components.interfaces.IFormString;
	import components.protocol.Package;
	import components.system.SavePerformer;
	import components.system.UTIL;

	public class BitMasterMind
	{
		private var fields:Vector.<Object>;
		private var container:Vector.<IFormString>;
		private var cmd:int;
		private var struct:int;
		
		/**	Сначала надо добавить контейнеры addContainer, это Fsshadow, которые содержат информацию о битовой маске и выывают сохранения
		 * 	Потом контроллеры addController это поля управляющие частями битовой маски. Формат:
		 * 					- поле, 
		 * 					- номер параметра в каком хранится их маска (или массив номеров, если параметр располагается больше чем в одном битве), 
		 * 					- номер бита в этой маске)
		 * 					- (опционально) callback(i:IformString)
		 * 
		 * 	Потом вставить put package битовой маски
		 *	Все поля должны быть подключены к SavePerformer	*/

		public function BitMasterMind(str:int=1)
		{
			struct = str;
		}
		
		public function put(p:Package):void
		{
			
			cmd = p.cmd;
			var len:int = container.length;
			for (var i:int=0; i<len; i++) {
				container[i].setCellInfo( p.getParam(i+1) );
			}
			len = fields.length;
			for ( i=0; i<len; i++) {
				if (fields[i].bit is int)
				{
					(fields[i].f as IFormString).setCellInfo( UTIL.isBit( fields[i].bit, int(p.getParam( fields[i].p )) ) );
				}
				else {
					var a:Array = fields[i].bit; 
					var alen:int = a.length;
					var bf:int;
					for (var j:int=0; j<alen; j++) {
						bf = UTIL.changeBit(bf, a[j], true);
					}
					var result:int = (int(p.getParam( fields[i].p )) & bf) >> a[0];
					(fields[i].f as IFormString).setCellInfo( result );
				}
				if (fields[i].cb is Function)
					fields[i].cb(fields[i].f);
			}
		}
		public function putArray(source:Array, _cmd:int):void
		{
			cmd = _cmd;
			var len:int = container.length;
			for (var i:int=0; i<len; i++) {
				//container[i].setCellInfo( source[i] );
				container[i].setCellInfo( source[ container[i].param-1 ] );
			}
			len = fields.length;
			for ( i=0; i<len; i++) {
				if (fields[i].bit is int)
					(fields[i].f as IFormString).setCellInfo( UTIL.isBit( fields[i].bit, int( source[fields[i].p-1]) ) );
				else {
					var a:Array = fields[i].bit; 
					var alen:int = a.length;
					var bf:int;
					for (var j:int=0; j<alen; j++) {
						bf = UTIL.changeBit(bf, a[j], true);
					}
					var result:int = (int( source[fields[i].p-1] ) & bf) >> a[0];
					(fields[i].f as IFormString).setCellInfo( result );
				}
				if (fields[i].cb is Function)
					fields[i].cb(fields[i].f);
			}
		}
		public function addContainer(i:IFormString):void
		{
			if (!container)
				container = new Vector.<IFormString>;
			container.push( i );
		}
		public function addController(i:IFormString, param:int, bitnum:Object, callback:Function=null):void
		{
			if (!fields)
				fields = new Vector.<Object>;
			fields.push( {f:i, p:param, bit:bitnum, cb:callback} );
			i.setUp( changed );
		}
		public function change(param:int, bit:int, value:Boolean, save:Boolean=true, f:Function=null):void
		{
			var n:int = int(getField(param).getCellInfo());
			var res:int = UTIL.changeBit( int(getField(param).getCellInfo()),bit, value );
			getField(param).setCellInfo(res);
			if (save)
				SavePerformer.remember(struct,getField(param));
			if (f is Function)
				SavePerformer.saveForce(f);
		}
		public function getBit(param:int, bitnum:int):Boolean
		{
			return UTIL.isBit( bitnum, int(getField(param).getCellInfo()) );
		}
		private function changed(i:IFormString):void
		{
			var info:Object = getInfo(i);
			var f:IFormString = getField(info.p);
			var b:Boolean = int(i.getCellInfo()) == 1;
			
			var bitfield:int = int(f.getCellInfo());
			
			var result:int;
			if (info.bit is int)
				result = UTIL.changeBit( int(f.getCellInfo()), info.bit, b );
			else {
				var a:Array = info.bit;
				result = int(f.getCellInfo());
				var len:int = a.length;
				for (var j:int=0; j<len; j++) {
					result = UTIL.changeBit( result, a[j], false );
				}
				result |= (int(i.getCellInfo()) << a[0])
			}
			f.setCellInfo( result );
			if (info.cb is Function)
				info.cb(i);
			SavePerformer.remember( struct, f );
		}
		private function getInfo(i:IFormString):Object
		{
			var len:int = fields.length;
			for (var j:int=0; j<len; j++) {
				if( fields[j].f == i )
					return fields[j];
			}
			return null;
		}
		private function getField(param:int):IFormString
		{
			var len:int = container.length;
			for (var i:int=0; i<len; i++) {
				if ( container[i].param == param )
					return container[i];
			}
			return null;
			//return container[param-1];
		}
	}
}