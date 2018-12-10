package components.protocol.models
{
	import components.protocol.Package;
	import components.protocol.Request;

	public class DataModel
	{
		private var oData:Object;
		public function update(o:Object ):void
		{
			if (o is Package)
				update_package( o as Package );
			else
				update_request( o as Request );
		}
		
		private function update_request(r:Request):void
		{
			if ( !oData )
				oData = new Object;
			if(!oData[r.cmd])
				oData[r.cmd] = new Array;
			oData[r.cmd][r.structure-1] = r.data;
		}
		private function update_package(p:Package):void
		{
			if ( !oData )
				oData = new Object;
			if(!oData[p.cmd])
				oData[p.cmd] = new Array;
			if (p.structure == 0)
				oData[p.cmd] = p.data;
			else
				oData[p.cmd][p.structure-1] = extractData(p.data);
		}
		public function getData(cmd:int):Array
		{
			
			if(!oData || !oData[cmd])
				return null;
			return oData[cmd];
		}
		public function clearData(cmd:int):void
		{
			if(oData || oData[cmd])
				delete oData[cmd];
		}
		public function getRoot():Object
		{
			return oData;
		}
		private function extractData(a:Array):Object
		{
			for( var key:String in a) {
				if (a[key] != null )
					return a[key];
			}
			return null;
		}
	}
}