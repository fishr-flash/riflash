package components.screens.opt
{
	import components.basement.OptionsBlock;
	import components.protocol.Package;
	
	public class OptSensorRoot extends OptionsBlock
	{
		public static const TYPE_A:int=0;
		public static const TYPE_B:int=1;
		public static const TYPE_C:int=2;
		public static const TYPE_D:int=3;
		public static const TYPE_E:int=4;
		public static const TYPE_F:int=5;
		public static const TYPE_G:int=6;
		public static const TYPE_H:int=7;
		public static const TYPE_I:int=8;
		
		protected var type:int;
		protected var title:String="";
		
		protected const pos1:int = 270;
		protected const pos2:int = 470;
		
		public function OptSensorRoot(str:int, type:int, cmd:int)
		{
			super();
			
			operatingCMD = cmd;
			structureID = str;
			this.type = type;
			
			build();
		}
		protected function build():void
		{
			
		}
		override public function putData(p:Package):void
		{
			if (p.cmd == operatingCMD)
				pdistribute(p);
		}
	}
}