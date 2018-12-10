package components.screens.opt
{
	import components.abstract.functions.loc;
	import components.basement.OptionsBlock;
	import components.gui.fields.FSShadow;
	import components.gui.fields.FSSimple;
	import components.gui.visual.SIMSignal;
	import components.protocol.Package;
	import components.static.CMD;
	import components.static.COLOR;
	import components.static.MISC;
	import components.system.UTIL;
	
	public class OptWiFi extends OptionsBlock
	{
		private var signal:SIMSignal;
		
		public function OptWiFi(s:int, sh:int=250):void
		{
			var c:int = CMD.ESP_INFO;
			var shift:int = sh;
			structureID = s;
			
			globalXSep = -20;
			var sepw:int = 420;
			
			switch(s) {
				case 1:
					addui( new FSSimple, c, loc("wifi_sdk_ver"), null, 1 );
					attuneElement(shift,200, FSSimple.F_CELL_NOTSELECTABLE | FSSimple.F_CELL_ALIGN_LEFT );
					(getLastElement() as FSSimple).setTextColor( COLOR.GREEN_DARK );
					
					addui( new FSSimple, c, loc("ui_verinfo_fw_ver"), null, 2 );
					attuneElement(shift,200, FSSimple.F_CELL_NOTSELECTABLE | FSSimple.F_CELL_ALIGN_LEFT );
					(getLastElement() as FSSimple).setTextColor( COLOR.GREEN_DARK );
					
					addui( new FSShadow, c, "", null, 3 );
					
					globalY -= 10;
					drawSeparator(sepw);
					break;
				case 2:
					addui( new FSSimple, 0, loc("ui_wifi_ap"), null, 1 );
					attuneElement(shift,200, FSSimple.F_CELL_NOTSELECTABLE | FSSimple.F_CELL_ALIGN_LEFT );
					(getLastElement() as FSSimple).setTextColor( COLOR.GREEN_DARK );
					
					addui( new FSSimple, c, loc("lan_mac_adress"), null, 1 );
					attuneElement(shift,200, FSSimple.F_CELL_NOTSELECTABLE | FSSimple.F_CELL_ALIGN_LEFT );
					(getLastElement() as FSSimple).setTextColor( COLOR.GREEN_DARK );
					
					addui( new FSSimple, c, loc("lan_ipadr"), null, 2 );
					attuneElement(shift,200, FSSimple.F_CELL_NOTSELECTABLE | FSSimple.F_CELL_ALIGN_LEFT );
					(getLastElement() as FSSimple).setTextColor( COLOR.GREEN_DARK );
					
					addui( new FSSimple, c, loc("g_mode"), null, 3 );
					attuneElement(shift,200, FSSimple.F_CELL_NOTSELECTABLE | FSSimple.F_CELL_ALIGN_LEFT );
					(getLastElement() as FSSimple).setTextColor( COLOR.GREEN_DARK );
					getLastElement().setAdapter( new WorkingAdapter );
					
					globalY -= 10;
					drawSeparator(sepw);
					break;
				case 3:
					addui( new FSSimple, 0, loc("wifi_client"), null, 1 );
					attuneElement(shift,200, FSSimple.F_CELL_NOTSELECTABLE | FSSimple.F_CELL_ALIGN_LEFT );
					(getLastElement() as FSSimple).setTextColor( COLOR.GREEN_DARK );
					
					addui( new FSSimple, c, loc("lan_mac_adress"), null, 1 );
					attuneElement(shift,200, FSSimple.F_CELL_NOTSELECTABLE | FSSimple.F_CELL_ALIGN_LEFT );
					(getLastElement() as FSSimple).setTextColor( COLOR.GREEN_DARK );
					//getLastElement().setAdapter(new MACAdapter);
					
					addui( new FSSimple, c, loc("lan_ipadr"), null, 2 );
					attuneElement(shift,200, FSSimple.F_CELL_NOTSELECTABLE | FSSimple.F_CELL_ALIGN_LEFT );
					(getLastElement() as FSSimple).setTextColor( COLOR.GREEN_DARK );
					
					addui( new FSShadow, c, "", null, 3 );
					
					signal = new SIMSignal;
					addChild( signal );
					signal.x = shift;
					signal.y = globalY;
					signal.title = loc("wifi_nosignal");
					signal.notdefined = loc("lan_no_connection").toLowerCase();
					addui( new FSSimple, 0, loc("ui_wifi_connect_net"), null, 1 );
					attuneElement(shift,200, FSSimple.F_CELL_NOTSELECTABLE | FSSimple.F_CELL_ALIGN_LEFT );
					(getLastElement() as FSSimple).setTextColor( COLOR.GREEN_DARK );
					
					break;
			}
			complexHeight = globalY;
		}
		override public function putData(p:Package):void
		{
			distribute(p.getStructure(structureID),p.cmd);
			if (structureID==3) {
				var sig:int = p.getStructure(structureID)[2];
				if (MISC.COPY_DEBUG)
					signal.attach = "% ("+UTIL.toSigned(sig,1)+" "+loc("measure_power")+")";
				if (sig == 0x80)
					signal.put( 99 );
				else
					signal.putStraight( UTIL.getDbm2Perc(sig) );
			}
		}
	}
}
import components.abstract.functions.loc;
import components.interfaces.IDataAdapter;
import components.interfaces.IFormString;

class WorkingAdapter implements IDataAdapter
{
	public function adapt(value:Object):Object
	{
		if (value == 0)
			return loc("g_notworking");
		return loc("g_working");
	}
	public function change(value:Object):Object	{		return null;	}
	public function perform(field:IFormString):void	{	}
	public function recover(value:Object):Object	{		return null;	}
}
/*class MACAdapter implements IDataAdapter
{
	public function adapt(value:Object):Object
	{
		if (value == 0)
			return loc("g_notworking");
		return loc("g_working");
	}
	public function change(value:Object):Object	{		return null;	}
	public function perform(field:IFormString):void	{	}
	public function recover(value:Object):Object	{		return null;	}
}*/