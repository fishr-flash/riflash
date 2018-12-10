package components.screens.ui
{
	import components.abstract.functions.loc;
	import components.basement.UI_BaseComponent;
	import components.gui.SimpleTextField;
	import components.gui.fields.FSShadow;
	import components.gui.fields.FSSimple;
	import components.gui.visual.Indent;
	import components.protocol.Package;
	import components.static.CMD;
	import components.static.DS;
	
	public class UICounters extends UI_BaseComponent
	{
		private var tMilage:SimpleTextField;
		private var tHours:SimpleTextField;
		
		public function UICounters()
		{
			super();
			
			addui( new FSSimple, CMD.VR_COUNTER_NAV_MILEAGE, loc("count_milage"),
				null, 1, null, "0-9", 6  );
			attuneElement( 500, 120 );
			getLastElement().setAdapter( new MtoKm );
			addui( new FSShadow, CMD.VR_COUNTER_NAV_MILEAGE, "", null, 2 );
			
			var indent:Indent = new Indent( 30 );
			addChild( indent );
			indent.x = globalX;
			indent.y = globalY;
			var msg:String = loc("count_msg_change_milage")
			
			tMilage = new SimpleTextField(msg, 600 );
			addChild( tMilage );
			tMilage.x = globalX + 20;
			tMilage.y = globalY;
			
			if (DS.isDevice(DS.V2) 
				|| DS.isDevice(DS.V2_3G) 
				|| DS.isDevice(DS.V4) 
				|| DS.isDevice(DS.VL3) 
				|| DS.isDevice(DS.VL3_3G) 
				|| DS.isDevice(DS.VL1) 
				|| DS.isDevice(DS.VL1_3G) 
				|| DS.isDevice(DS.VL2) 
				|| DS.isDevice(DS.VL2_3G) 
				|| DS.isDevice(DS.V_BRPM) 
				|| DS.isDevice(DS.V_ASN) 
			) {
			
				globalY += 40;
				
				drawSeparator( 641 );
				
				msg = loc("count_msg_change_motohours")
	
				addui( new FSSimple, CMD.VR_COUNTER_NAV_HOURS, loc("count_motohours"),
					null, 1, null, "0-9", 6 );
				attuneElement( 500, 120 );
				getLastElement().setAdapter( new SectoHours );
				addui( new FSShadow, CMD.VR_COUNTER_NAV_HOURS, "", null, 2 );
				
				indent = new Indent( 30 );
				addChild( indent );
				indent.x = globalX;
				indent.y = globalY;
				
				tHours = new SimpleTextField(msg, 600 );
				addChild( tHours );
				tHours.x = globalX + 20;
				tHours.y = globalY;
				
				starterCMD = [CMD.VR_COUNTER_NAV_MILEAGE, CMD.VR_COUNTER_NAV_HOURS];
			} else
				starterCMD = CMD.VR_COUNTER_NAV_MILEAGE;
		}
		override public function put(p:Package):void
		{
			distribute( p.getStructure(), p.cmd );
			if (p.getStructure()[0] == uint.MAX_VALUE) {
				getField(p.cmd,1).setCellInfo(loc("g_nodata"));
				getField(p.cmd,1).disabled = true;
			} else
				getField(p.cmd,1).disabled = false;
			loadComplete();
		}
	}
}
import components.abstract.functions.loc;
import components.interfaces.IDataAdapter;
import components.interfaces.IFormString;

class MtoKm implements IDataAdapter
{
	public function adapt(value:Object):Object
	{
		if (value == loc("g_nodata"))
			return value;
		return Number(Number(value)/1000).toFixed();
	}
	public function change(value:Object):Object
	{
		
		return value;
	}
	public function perform(field:IFormString):void	{		}
	public function recover(value:Object):Object
	{
		return Number(value)*1000;
	}
}
class SectoHours implements IDataAdapter
{
	public function adapt(value:Object):Object
	{
		if (value == loc("g_nodata"))
			return value;
		return Number(Number(value)/60/60).toFixed();
	}
	public function change(value:Object):Object
	{
		return value;
	}
	public function perform(field:IFormString):void	{		}
	public function recover(value:Object):Object
	{
		return Number(value)*60*60;
	}
}