package components.abstract.servants
{
	import components.abstract.functions.loc;
	import components.interfaces.IFounder;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.protocol.statics.SERVER;
	import components.static.CMD;
	import components.static.DS;
	import components.static.MISC;
	import components.system.SensorConst;
	
	import foundation.functions.getMenu;

	public class SensorLoader
	{
		private static var inst:SensorLoader;
		public static function access():SensorLoader
		{
			if(!inst)
				inst = new SensorLoader;
			return inst;
		}
		
		private var founder:IFounder;
		private var swtch:int;
		private var ninjaexist:Boolean = false;	// сигнализирует о том, что с сервера получена инфрмация
		
		public function start(p:Package, f:IFounder):void
		{
			founder = f;
			ninjaexist = false;
			
			SERVER.VER = String(p.getStructure(1)[0]).replace(/\n?\r?/g,"");
			SERVER.VER_FULL = String(p.getStructure(1)[0]).replace(/\n?\r?/g,"");
			SERVER.HARDWARE_VER = SERVER.VER_FULL.split(".")[1]; 
			var v:String = SERVER.VER_FULL;
			var alias:String = DS.deviceAlias;
			swtch = 0;
			
			DS.fgetStatus = getStatusVersion;
			
			/*RSD1.005.001
			RIPR1.002.001
			RDD1.001.001
			RGD1.002.001
			RMD1.001.001
			RDD3.003.001*/
			
			/*
			14.002 - RDD1
			14.003 - RMD1
			14.005 - RSD1
			14.008 - RIPR1
			14.009 - RGD1
			14.012 - RDD3
			*/
			
			if (v.toLowerCase().search("bootldr") > -1 ) {
		//		MISC.NEED_UPDATE = true;
				MISC.VINTAGE_BOOTLOADER_ACTIVE = true;
				RequestAssembler.getInstance().fireEvent( new Request(CMD.OP_un_BOOTLOADER_VER, adaptVersion));
				return;
			} else if (v.toLowerCase().search("ver ") > -1 ) {
		//		MISC.NEED_UPDATE = true;
				var s:String = SensorConst.getAlias(p);
				SERVER.VER_FULL = s + ".000.000";
				SERVER.HARDWARE_VER = "000";
			} else {
				if ( alias == "RMD1" || (alias == "RDD1" && int(v.split(".")[2]) > 1 ))
					swtch |= 3;
				if (alias == "RSD1" || alias == "RDD3" || alias == "RGD1" || alias == "RIPR1" || (alias == "RDD1" && int(v.split(".")[2]) < 2 ))
					swtch |= 1;
			}
			
			load();
		}
		private function load():void
		{
			if(!ninjaexist) {
				founder.menu( getMenu(swtch) );
	//			AutoUpdateNinja.access().getList(load);
				ninjaexist = true;
			} else {
				WatchDog.access().start();
				founder.load();
			}
		}
		private function adaptVersion(p:Package):void
		{
			var s:String = SensorConst.getBootLoaderVersion(p);
			if (s == null) {
				RequestAssembler.getInstance().fireEvent( new Request(CMD.OP_un_BOOTLOADER_VER, adaptVersion));
				return;
			}
			SERVER.VER_FULL = s + ".000.000";
			SERVER.HARDWARE_VER = "000";
			load();
		}
		private function getStatusVersion():String
		{
			var v:String = SERVER.VER; 
			var alias:String = DS.deviceAlias;
			
			if (v.toLowerCase().search("bootldr") > -1 ) {
				if (alias.toLowerCase().search("bootldr") > -1)
					return loc("sensor_detecting");
				return alias + " "+ loc("sensor_updating");
			} else if (v.toLowerCase().search("ver ") > -1 )
				return SERVER.VER;
			return SERVER.VER_FULL;
		}
	}
}