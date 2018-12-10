package components.screens.ui
{
	import components.basement.UI_BaseComponent;
	import components.protocol.Package;
	import components.static.CMD;
	
	public class UIServers extends UI_BaseComponent
	{
		private var opts:Vector.<OptServers>;
		
		public function UIServers()
		{
			super();
			
			opts = new Vector.<OptServers>;
			for (var i:int=0; i<2; i++) {
				opts.push( new OptServers(i+1) );
				addChild( opts[i] );
				opts[i].y = globalY;
				opts[i].x = globalX;
				globalY += opts[i].complexHeight;
			}
			
			starterCMD = CMD.SET_SERVER;
		}
		override public function put(p:Package):void
		{
			opts[0].putData(p);
			opts[1].putData(p);
			loadComplete();
		}
	}
}
import components.abstract.RegExpCollection;
import components.abstract.functions.loc;
import components.basement.OptionsBlock;
import components.gui.fields.FSCheckBox;
import components.gui.fields.FSSimple;
import components.protocol.Package;
import components.static.CMD;

class OptServers extends OptionsBlock
{
	private const namesp1:Array = [loc("srv_ch_gprs"), 
		loc("srv_ch_lan_wifi_modem")];
	private const namesp2:Array = [loc("srv_ip_ch_gprs"), 
		loc("srv_ip_ch_lan_wifi_modem")];
	private const namesp3:Array = [loc("srv_port_gprs"), 
		loc("srv_port_ch_lan_wifi_modem")];
	
	public function OptServers(s:int)
	{
		super();
		
		structureID = s;
		operatingCMD = CMD.SET_SERVER;
		var sh:int = 470;
		
		addui( new FSCheckBox, operatingCMD, namesp1[s-1], null, 1 );
		attuneElement( sh+88, NaN, s == 1 ? 0 : FSCheckBox.F_MULTYLINE );
		
		//globalY += s == 1 ? 0 : 10;
		globalY += 10;
		
		addui( new FSSimple, operatingCMD, namesp2[s-1] , null, 2, null, "", 63, new RegExp("^" + RegExpCollection.RE_IP_ADDRESS + "|" + RegExpCollection.RE_DOMEN + "$") );
		attuneElement( sh-100, 200, FSSimple.F_MULTYLINE );
		
		//globalY += s == 1 ? 0 : 10;
		globalY += 10;
		
		addui( new FSSimple, operatingCMD, namesp3[s-1], null, 3,null, "0-9", 5, new RegExp(RegExpCollection.REF_PORT) );
		attuneElement( sh+40, 60, s == 1 ? 0 : FSSimple.F_MULTYLINE );
		
		if (s==1) {
			globalXSep -= 20;
			drawSeparator(500+111);
		}
		
		complexHeight = globalY;
	}
	override public function putData(p:Package):void
	{
		distribute(p.getStructure(structureID),p.cmd);
	}
}