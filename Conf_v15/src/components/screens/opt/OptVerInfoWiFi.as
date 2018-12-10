package components.screens.opt
{
	import components.abstract.functions.loc;
	import components.basement.OptionsBlock;
	import components.gui.fields.FSShadow;
	import components.gui.fields.FSSimple;
	import components.gui.fields.FormString;
	import components.gui.visual.SIMSignal;
	import components.protocol.Package;
	import components.screens.ui.UIVersion;
	import components.static.CMD;
	import components.static.COLOR;
	
	public class OptVerInfoWiFi extends OptionsBlock
	{
		private var signal:SIMSignal;
		
		public function OptVerInfoWiFi(short:Boolean=false)
		{
			super();
			
			var shift:int = UIVersion.shift;
			yshift = 0;
			addui( new FormString, 0, loc("wifi_current"), null, 2 );
			attuneElement(NaN,NaN,FormString.F_TEXT_BOLD);
			addui( new FSSimple, CMD.WIFI_GET_NET, loc("wifi_name"), null, 1 );
			attuneElement( shift, 300,  FSSimple.F_CELL_ALIGN_LEFT | FSSimple.F_CELL_NOTSELECTABLE );
			(getLastElement() as FSSimple).setTextColor( COLOR.GREEN_DARK );
			
			if (!short) {
				addui( new FSSimple, CMD.WIFI_GET_NET, loc("wifi_conn_status"), null, 2 );
				attuneElement( shift, 300,  FSSimple.F_CELL_ALIGN_LEFT | FSSimple.F_CELL_NOTSELECTABLE );
				(getLastElement() as FSSimple).setTextColor( COLOR.GREEN_DARK );
				getLastElement().setAdapter( new OnOffAdapter );
				addui( new FSSimple, CMD.WIFI_GET_NET, loc("lan_ipadr"), null, 3 );
				attuneElement( shift, 300,  FSSimple.F_CELL_ALIGN_LEFT | FSSimple.F_CELL_NOTSELECTABLE );
				(getLastElement() as FSSimple).setTextColor( COLOR.GREEN_DARK );
				addui( new FSSimple, CMD.WIFI_GET_NET, loc("lan_subnet_mask"), null, 4 );
				attuneElement( shift, 300,  FSSimple.F_CELL_ALIGN_LEFT | FSSimple.F_CELL_NOTSELECTABLE );
				(getLastElement() as FSSimple).setTextColor( COLOR.GREEN_DARK );
				addui( new FSSimple, CMD.WIFI_GET_NET, loc("lan_default_gateway"), null, 5 );
				attuneElement( shift, 300,  FSSimple.F_CELL_ALIGN_LEFT | FSSimple.F_CELL_NOTSELECTABLE );
				(getLastElement() as FSSimple).setTextColor( COLOR.GREEN_DARK );
				addui( new FSSimple, CMD.WIFI_GET_NET, loc("lan_preferred_dns"), null, 6 );
				attuneElement( shift, 300,  FSSimple.F_CELL_ALIGN_LEFT | FSSimple.F_CELL_NOTSELECTABLE );
				(getLastElement() as FSSimple).setTextColor( COLOR.GREEN_DARK );
				addui( new FSSimple, CMD.WIFI_GET_NET, loc("lan_alternate_dns"), null, 7 );
				attuneElement( shift, 300,  FSSimple.F_CELL_ALIGN_LEFT | FSSimple.F_CELL_NOTSELECTABLE );
				(getLastElement() as FSSimple).setTextColor( COLOR.GREEN_DARK );
				addui( new FSShadow, CMD.WIFI_GET_NET, "", null, 8 );
			} else {
				addui( new FSShadow, CMD.WIFI_GET_NET, "", null, 2 );
				addui( new FSShadow, CMD.WIFI_GET_NET, "", null, 3 );
				addui( new FSShadow, CMD.WIFI_GET_NET, "", null, 4 );
				addui( new FSShadow, CMD.WIFI_GET_NET, "", null, 5 );
				addui( new FSShadow, CMD.WIFI_GET_NET, "", null, 6 );
				addui( new FSShadow, CMD.WIFI_GET_NET, "", null, 7 );
				addui( new FSShadow, CMD.WIFI_GET_NET, "", null, 8 );
			}
			signal = new SIMSignal;
			addChild( signal );
			signal.x = shift;
			signal.y = globalY;
			
			addui( new FormString, 0, loc("wifi_signal_level"), null, 1 );
			
			complexHeight = globalY + 10;
		}
		override public function putData(p:Package):void
		{
			pdistribute(p);
			signal.putStraight( int(p.getStructure()[7]), true ); 
		}
	}
}
import components.abstract.functions.loc;
import components.interfaces.IDataAdapter;
import components.interfaces.IFormString;

class OnOffAdapter implements IDataAdapter
{
	public function adapt(value:Object):Object
	{
		if (int(value)==1)
			return loc("wifi_enabled")
		return loc("wifi_disabled");
	}
	public function change(value:Object):Object	{		return null;	}
	public function perform(field:IFormString):void	{	}
	public function recover(value:Object):Object	{		return null;	}
}