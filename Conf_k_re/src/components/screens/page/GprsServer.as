package components.screens.page
{
	import components.abstract.RegExpCollection;
	import components.abstract.functions.loc;
	import components.basement.UI_BaseComponent;
	import components.events.GUIEventDispatcher;
	import components.events.GUIEvents;
	import components.gui.fields.FSBitBox;
	import components.gui.fields.FSCheckBox;
	import components.gui.fields.FSComboBox;
	import components.gui.fields.FSShadow;
	import components.interfaces.IFormString;
	import components.protocol.Package;
	import components.static.CMD;
	import components.static.DS;
	import components.system.UTIL;
	
	public class GprsServer extends UI_BaseComponent
	{
		public var opts:Vector.<OptGRPSOnline>;
		
		public function GprsServer()
		{
			super();
			
			globalX = 0;
			globalY = 0;
			
			var l:Array = UTIL.getComboBoxList([[0x0100,"1"],[0x0200,"2"],[0x0300,"3"],[0x0400,"4"],[0x0500,"5"],
				[0x0600,"6"],[0x0700,"7"],[0x0800,"8"],[0x0900,"9"],[0x0A00,"10"]]);
			addui( new FSComboBox, CMD.K5_G_TRY_TIME, loc("ui_gprs_pause_between_reconnect"), 
				null, 1, l, "0-9", 2, new RegExp(RegExpCollection.REF_1to10));
			attuneElement( 250+30, 61, FSComboBox.F_MULTYLINE | FSComboBox.F_COMBOBOX_NOTEDITABLE );
			
		
			switch(DS.alias) {
				case DS.isfam( DS.K5 ):
					addui( new FSBitBox, CMD.K5_BIT_SWITCHES, loc("ui_gprs_compr_mode"), null, 1,[2] );
					attuneElement( 250+78 );
					addui( new FSShadow, CMD.K5_BIT_SWITCHES, "", null, 2 );
					addui( new FSShadow, CMD.K5_BIT_SWITCHES, "", null, 3 );
					addui( new FSCheckBox, CMD.K5RT_GPRS_ADD, loc( "sim_address" ), delegateDispatcher, 2 );
					attuneElement( 250+78 );
					addui( new FSCheckBox, CMD.K5RT_GPRS_ADD, loc( "sim_roaming" ), null, 1 );
					attuneElement( 250+78 );
					break;
				case DS.K1:
				case DS.K1M:
				case DS.K9:
				case DS.K9A:
				case DS.K9M:
				case DS.K9K:
					addui( new FSBitBox, CMD.K9_BIT_SWITCHES, loc("ui_gprs_compr_mode"), null, 1,[6] );
					attuneElement( 250+78 );
					addui( new FSShadow, CMD.K9_BIT_SWITCHES, "", null, 2 );
					break;
			}
			
			globalY += 5;
			var coory:Array;
			opts = new Vector.<OptGRPSOnline>;
			for (var i:int=0; i<2; i++) {
				opts.push( new OptGRPSOnline(i+1) );
				addChild( opts[i] );
				if (!coory)
					coory = [ globalY + opts[i].getHeight(), globalY  ];
				opts[i].x = globalX;
				opts[i].y = coory[i];//globalY;
				globalY += opts[i].getHeight();
			
			}
		}
		
		
		override public function put(p:Package):void
		{
			switch(p.cmd) {
				case CMD.K5_BIT_SWITCHES:
				case CMD.K9_BIT_SWITCHES:
					refreshCells(p.cmd);
				case CMD.K5_G_TRY_TIME:
					distribute(p.getStructure(),p.cmd);
					break;
				case CMD.K5RT_GPRS_ADD:
					distribute(p.getStructure(),p.cmd);
					
					
				case CMD.K5_G_SRV_PASS:
				case CMD.K5_G_SRV_IP:
				case CMD.K5_G_SRV_PORT:
					for (var i:int=0; i<2; i++) {
						opts[i].putData(p);
					}
					break;
			}
		}
		
		private function delegateDispatcher( ifrm:IFormString ):void
		{
			for (var i:int=0; i<2; i++) {
				opts[i].switchGPRSAdd( ifrm.getCellInfo() == "1" );
			}
			remember( ifrm );
			
		}
	}
}
import components.abstract.RegExpCollection;
import components.abstract.adapters.StringCutterAdapter;
import components.abstract.functions.loc;
import components.basement.OptionsBlock;
import components.events.GUIEventDispatcher;
import components.events.GUIEvents;
import components.gui.fields.FSShadow;
import components.gui.fields.FSSimple;
import components.gui.fields.FormString;
import components.interfaces.IFormString;
import components.protocol.Package;
import components.static.CMD;
import components.static.DS;

class OptGRPSOnline extends OptionsBlock
{

	private var defaultWrd:String;

	private var title:IFormString;
	public function OptGRPSOnline(s:int)
	{
		super();
		
		structureID = s;
		
		var srv:String = s == 2 ? loc("ui_gprs_main")+" ":loc("ui_gprs_reserve")+" ";
		var srvnum:String = s == 2 ? "1":"2";
		defaultWrd = srv + loc("ui_gprs_ip_port_pass");
		title = addui( new FormString, 0, defaultWrd, null, 1 );
		attuneElement( 350, NaN, FormString.F_TEXT_BOLD );
		globalY -= 20;
		
		drawSeparator(361);
		
		addui( new FSShadow, CMD.K5_G_SRV_IP, "", null, 1 );
		
		var len:int;	// в команде разная длина
		switch(DS.alias) {
			case DS.isfam( DS.K5 ):
				len = 15;
				break;
			case DS.K1:
			case DS.K1M:
			case DS.K9:
			case DS.K9A:
			case DS.K9M:
			case DS.K9K:
				len = 63;
				break;
		}
		
		addui( new FSSimple, CMD.K5_G_SRV_IP, loc("ui_gprs_ip_domen")+" "+srvnum, null, 2, null, "", len, new RegExp("^" + RegExpCollection.RE_IP_ADDRESS + "|" + RegExpCollection.RE_DOMEN + "$") );
		getLastElement().setAdapter( new StringCutterAdapter(getField(CMD.K5_G_SRV_IP,1) ));
		attuneElement( 210, 130, FSSimple.F_MULTYLINE  );
		addui( new FSShadow, CMD.K5_G_SRV_PORT, "", null, 1 );
		addui( new FSSimple, CMD.K5_G_SRV_PORT, loc("ui_gprs_port")+" "+srvnum, null, 2, null, "0-9", 5, new RegExp(RegExpCollection.REF_PORT) );
		getLastElement().setAdapter( new StringCutterAdapter(getField(CMD.K5_G_SRV_PORT,1) ));
		attuneElement( 280, 60 );
		addui( new FSShadow, CMD.K5_G_SRV_PASS, "", null, 1 );
		addui( new FSSimple, CMD.K5_G_SRV_PASS, loc("ui_gprs_pass_gprs")+" "+srvnum, null, 2, null, "A-z0-9", 8, new RegExp(RegExpCollection.COMPLETE_ATLEST8SYMBOL) );
		getLastElement().setAdapter( new StringCutterAdapter(getField(CMD.K5_G_SRV_PASS,1) ));
		attuneElement( 210, 130, FSSimple.F_MULTYLINE );
		
		
		complexHeight = globalY + 20;
	}
	override public function putData(p:Package):void
	{
		switch( p.cmd ) {
			case CMD.K5RT_GPRS_ADD:
				switchGPRSAdd( p.data[ 0 ][ 1 ] == 1 );
				break;
			default:
				distribute(p.getStructure(structureID),p.cmd);
				break;
		}
		
		
		
	}
	
	public function switchGPRSAdd( added:Boolean ):void
	{
		
		const nm:int = structureID>1?1:2;
		
		if( added ) 
			title.setName( loc( "sim_ipport_for_sim" ) + nm + "" );
		else 
			title.setName( defaultWrd );

		
		
	}
}