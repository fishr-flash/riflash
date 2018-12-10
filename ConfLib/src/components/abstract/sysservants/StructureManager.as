package components.abstract.sysservants
{
	public class StructureManager
	{
		// класс должен быть пустым, создается на каждом приборе отдельно
		
		private static var inst:StructureManager;
		public static function access():StructureManager
		{
			if(!inst)
				inst = new StructureManager;
			return inst;
		}
		
		public function StructureManager()
		{
			
		}
		
		public function launch():void
		{
		}
	}
}