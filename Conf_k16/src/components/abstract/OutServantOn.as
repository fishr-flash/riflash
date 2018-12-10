package components.abstract
{
	import components.abstract.functions.loc;
	import components.interfaces.IOutServant;

	public class OutServantOn implements IOutServant
	{
		private var ACPMax:int;
		private var ACPMin:int;
		
		private var IMax:Number = 12;
		private var IMin:Number = 1.4996;
		
		private const XLength:int = 600;
		
		public function edges(min:int, max:int):void
		{
			ACPMin = min;
			ACPMax = max;
			
			IMax = 0.1336*max+4;
			IMin = 0.1336*min+4;
		}
		public function getMaxACP():int
		{
			return ACPMax;
		}
		public function getMinACP():int
		{
			return ACPMin;
		}
		public function getXlength():int
		{
			return XLength;
		}
		public function getDefaults():Array
		{
			return [ACPMax,2000,1000,ACPMin];
		}
		public function calcAPCtoX(acp:int):int
		{
			var c:Number = (ACPMax-ACPMin)/XLength;
			var r:Number = (acp-ACPMin)/c;
			return r < 0 ? 0 : Math.round(r);
		}
		public function calcXtoACP(x:int):int
		{
			var c:Number = (ACPMax-ACPMin)/XLength;
			var r:Number = c*x+ACPMin;
			return r;
		}
		private function calcXtoI(x:int):Number
		{
			var cx:int = calcXtoACP(x);
			var f2:Number = cx*0.132+0.3168;
			return f2;//r;
		}
		public function getLabelXtoI(x:int):String
		{
			if (x > XLength)
				return ">"+format( calcXtoI(XLength) );
			else if (x < 0)
				return "<"+format( calcXtoI(0) );
			return format( calcXtoI(x) );
			
			function format(_num:Number):String
			{
				return _num.toFixed(0)+" "+loc("measure_amount_mega");
			}
		}
	}
}