package components.abstract
{
	import components.abstract.functions.loc;
	import components.interfaces.IOutServant;

	public class OutServantOff implements IOutServant
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
			
			IMax = 0.0037*max+0.027;
			IMin = 0.0037*min+0.027;
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
			var c:Number = (IMax-IMin)/XLength;
			var r:Number = c*x+IMin;
			return r;
		}
		public function getLabelXtoI(x:int):String
		{
			//return calcXtoACP(x) + " " + format( calcXtoI(x) );
			if (x > XLength)
				return ">"+format( calcXtoI(XLength) );
			else if (x < 0)
				return "<"+format( calcXtoI(0) );
			return format( calcXtoI(x) );
			
			function format(_num:Number):String
			{
				return _num.toFixed(1)+" "+loc("measure_amount_mega");
			}
		}
	}
}