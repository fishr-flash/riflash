package components.abstract.servants
{
	import components.interfaces.IOutServant;

	public final class WireServantK9 implements IOutServant
	{
		public static var MIN_LEVEL_ACP:int = 0;
		public static var MAX_LEVEL_ACP:int = 0;
		public static var MIN_LEVEL_OM:int = 0;
		public static var MAX_LEVEL_OM:int = 0;
		public static var MIN_PREFERRED_LEVEL_OM:int = 0;
		public static var LABEL_LEVEL_SIGN:String = "";	// <, ,> - постановка знака перед лейблом для WireUbitBig 
		
		public static var LAST_PARTITION:int = 0;
		
		public static const MAX_TIMELINE_OM:int = 14820;//10500;
		public static const MIN_TIMELINE_OM:int = 2100;
		public static const MIDDLE_DRY_TIMELINE_OM:int = 6200;
	
		
		private var ACPMax:int;
		private var ACPMin:int;
		
		private const XLength:int = 600;
		
		public function edges(min:int, max:int):void
		{
			ACPMin = min;
			ACPMax = max;
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
			return [ACPMin,470,610,806,ACPMax];//[ACPMax,2000,1000,ACPMin];
		}
		public function calcAPCtoX(acp:int):int
		{
			var i:int = (600/(1023-30))*(acp-30);
			return i;
			var c:Number = (ACPMax-ACPMin)/XLength;
			var r:Number = acp/c;
		//	не сохраняются нормально пороги!
			
			return r < 0 ? 0 : Math.round(r);
		}
		public function calcXtoACP(x:int):int
		{
			return (1023-30)/600*x+30;
			var c:Number = XLength/(ACPMax-ACPMin);
			var r:Number = c*x+ACPMin;
			return r;
		}
		private function calcXtoI(x:int):Number
		{
			return 0;
		}
		public function getLabelXtoI(x:int):String
		{
			var acp:int = 30 + Math.round(x*1.655);
			if ( acp < ACPMin )
				acp = ACPMin;
			var r:Number = 12/(acp*0.0082-0.1)-0.75;
			//var r:Number = ((471*(20-(acp*(3,3/1023)))/(acp*(3,3/1023)))/1000);
			if (Math.round(r) < 10)
				return r.toFixed(2)+" ";
			else if (Math.round(r) < 100)
				return r.toFixed(1)+" ";
			return r.toFixed(0)+" ";
		}
	}
}