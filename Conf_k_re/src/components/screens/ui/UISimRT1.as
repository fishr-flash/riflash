package components.screens.ui
{
	import flash.display.Sprite;
	import flash.text.TextFormatAlign;
	
	import components.abstract.RegExpCollection;
	import components.abstract.functions.loc;
	import components.basement.UI_BaseComponent;
	import components.gui.SimpleTextField;
	import components.gui.fields.FSCheckBox;
	import components.gui.fields.FSComboBox;
	import components.gui.fields.FSRadioGroup;
	import components.gui.fields.FSShadow;
	import components.gui.fields.FSSimple;
	import components.gui.fields.FormString;
	import components.gui.visual.Indent;
	import components.interfaces.IFormString;
	import components.protocol.Package;
	import components.screens.opt.OptSim;
	import components.static.CMD;
	import components.static.DS;
	import components.system.CONST;
	import components.system.UTIL;
	
	public class UISimRT1 extends UI_BaseComponent
	{
		private var simcards:Vector.<OptSim>;
		private var comlink:Vector.<OptComLink>;
		private var _firewall:Sprite;
		
		public function UISimRT1()
		{
			super();
			
			simcards = new Vector.<OptSim>;
			
			for( var i:int=0; i<2; ++i ) {
				if (i>0)
					drawSeparator(421);
				simcards.push( new OptSim(i+1,false,false) );
				addChild( simcards[i] );
				simcards[i].x = globalX;
				simcards[i].y = globalY;
				globalY += simcards[i].height;
			}
			
			globalY = 10;
			
			globalX = simcards[ 0 ].x + simcards[ 0 ].width + 40;
			globalXSep = globalX;
			
			var l:Array = UTIL.getComboBoxList([[1,"1"],[2,"2"],[3,"3"],[4,"4"],[5,"5"],
				[6,"6"],[7,"7"],[8,"8"],[9,"9"],[10,"10"]]);
			addui( new FSComboBox, CMD.K5_G_TRY_TIME, loc("ui_gprs_pause_between_reconnect"), 
				null, 1, l, "0-9", 2, new RegExp(RegExpCollection.REF_1to10));
			attuneElement( 250+70, 61, FSComboBox.F_MULTYLINE | FSComboBox.F_COMBOBOX_NOTEDITABLE );
			getLastElement().setAdapter(new IrrationalTimeAdapter);
			
			if( !DS.isfam( DS.K5RT3 ) )
			{
				addui( new FSCheckBox, CMD.K5RT_GPRS_ADD, loc("sim_roaming"), null, 1 );
				attuneElement( 368 );
			}
			else
			{
				addui( new FSShadow(), CMD.K5RT_GPRS_ADD, loc("sim_roaming"), null, 1 );
			}
			
			
			addui( new FSCheckBox, CMD.K5RT_GPRS_ADD, loc("sim_address"), onlink, 2 );
			attuneElement( 368 );
			
			drawSeparator(500-79);
			
			comlink = new Vector.<OptComLink>;
			
			for( i=0; i<2; ++i ) {
				if (i>0)
					drawSeparator(500-79);
				comlink.push( new OptComLink(i+1) );
				addChild( comlink[i] );
				comlink[i].x = globalX;
				comlink[i].y = globalY;
				globalY += comlink[i].complexHeight;
			}
			
			//height = 840;
			const indent:Indent = drawIndent( 430 );
			indent.x = simcards[ 0 ].x + simcards[ 0 ].width + 20;
			indent.y = 10;
			
			if( DS.isDevice( DS.K5RT13G ) || DS.isDevice( DS.K5RT33G) || DS.isDevice( DS.K53G ) )
			{
				FLAG_VERTICAL_PLACEMENT = true;
				
				globalY += 10;
				globalX = 10;
				
				
				drawSeparator( this.width ).x = globalX;
				
				
				addui( new FormString, 0, loc( "mode_work_modem" ), null, 1 ); 
				attuneElement( NaN, NaN, FormString.F_TEXT_BOLD );
				
				globalY += 10;
				
				
				const arr:Array = 
				[
					{ label:loc( "Auto" ), selected:true, id:0 },
					{ label:loc( "GSM 2G" ), selected:false, id:1 },
					{ label:loc( "WCDMA 3G" ), selected: false, id:2 }
				]
				
				const fsRGroup:FSRadioGroup = new FSRadioGroup( arr, 1, 24 );
				
				
				fsRGroup.x = 10;
				fsRGroup.y = globalY;
				fsRGroup.width = 400;
				this.addChild( fsRGroup );
				globalY += fsRGroup.height;
				
				addUIElement( fsRGroup, CMD.MODEM_NETWORK_CTRL, 1);
				
				starterCMD = [ CMD.MODEM_NETWORK_CTRL ];
				
			}
			
			if( starterCMD ) starterCMD = starterCMD.concat( [CMD.K5_G_TRY_TIME, CMD.K5RT_GPRS_ADD, CMD.CH_COM_LINK_GPRS, CMD.GPRS_SIM, CMD.CH_COM_LINK_LOCK] );
			else starterCMD = [CMD.K5_G_TRY_TIME, CMD.K5RT_GPRS_ADD, CMD.CH_COM_LINK_GPRS, CMD.GPRS_SIM, CMD.CH_COM_LINK_LOCK];
			
		}
		
		override public function close():void
		{
			if( _firewall && _firewall.parent )
				_firewall.parent.removeChild( _firewall );
		}
		
		override public function put(p:Package):void
		{
			switch(p.cmd) {
				case CMD.CH_COM_LINK_LOCK:
					
					if( CONST.DEBUG )
						break;
					
					var obj:Object;
					
					
					if( p.data[ 0 ] == 0x00 )
						createFirewall();
					else if( _firewall && _firewall.parent )
						_firewall.parent.removeChild( _firewall );
					
					
					break;
				
				case CMD.GPRS_SIM:
					simcards[0].putData(p.detach(1));
					simcards[1].putData(p.detach(2));
					
					onlink(null);
					loadComplete();
					break;
				case CMD.CH_COM_LINK_GPRS:
					comlink[0].putData(p.detach(1));
					comlink[1].putData(p.detach(2));
					break;
				default:
					pdistribute(p);
					break;
			}
		}
		private function onlink(t:IFormString):void
		{
			var f:IFormString = getField(CMD.K5RT_GPRS_ADD,2);
			if( int(f.getCellInfo()) == 0 ) {
				comlink[0].renameTitle(loc("gprs_main_ip"));
				comlink[1].renameTitle(loc("gprs_backup_ip"));
			} else {
				comlink[0].renameTitle(loc("sim_ipport_for_sim")+"1");
				comlink[1].renameTitle(loc("sim_ipport_for_sim")+"2");
			}
				
			if (t)
				remember(t);
		}
		private function createFirewall():Sprite
		{
			_firewall = new Sprite();
			_firewall.graphics.beginFill( 0xFFFFFF, .75 );
			_firewall.graphics.drawRect(0, 0, this.width, this.height );
			
			
			this.addChild( _firewall );
			
			const label:SimpleTextField = new SimpleTextField( loc("warning_settings_blocked"), 650, 0xBB0000 );
			label.setSimpleFormat( TextFormatAlign.CENTER, 0, 20, true );
			_firewall.addChild( label );
			label.x = 150;
			label.y = 200;
			
			
			return _firewall;
		}
	}
}
import components.abstract.RegExpCollection;
import components.abstract.functions.loc;
import components.basement.OptionsBlock;
import components.gui.fields.FSSimple;
import components.gui.fields.FormString;
import components.interfaces.IDataAdapter;
import components.interfaces.IFormString;
import components.protocol.Package;
import components.static.CMD;
import components.system.UTIL;

class OptComLink extends OptionsBlock
{
	public function OptComLink(str:int):void
	{
		super();
		
		structureID = str;
		
		/**"Команда CH_COM_LINK_GPRS - используется для простых каналов связи с жесткой логикой.
		 
		 Параметр 1 - IP адрес или доменное имя;
		 Параметр 2 - порт;
		 Параметр 3 - пароль для соединения с сервером;"													*/
		
		var w:int = 180;
		var cw:int = 200;
		
		if (str==1)
			addui( new FormString, 0, loc("gprs_main_ip"), null, 1 );
		else
			addui( new FormString, 0, loc("gprs_backup_ip"), null, 1 );
		attuneElement( w + cw, NaN, FormString.F_TEXT_BOLD );
		
		addui( new FSSimple, CMD.CH_COM_LINK_GPRS, loc("ui_wifi_ip"), null, 1, null, "", 63 );
		attuneElement( w, cw );
		addui( new FSSimple, CMD.CH_COM_LINK_GPRS, loc("g_port"), null, 2, null, "0-9", 5, new RegExp(RegExpCollection.REF_PORT) );
		attuneElement( w + cw - 60, 60 );
		addui( new FSSimple, CMD.CH_COM_LINK_GPRS, loc("sim_connect_pass"), null, 3, null, "A-z0-9", 20 );
		attuneElement( w, cw );
		
		complexHeight = globalY;
	}
	override public function putData(p:Package):void
	{
		pdistribute(p);
	}
	public function renameTitle(ttl:String):void
	{
		getField(0,1).setName( ttl );
	}
}
class IrrationalTimeAdapter implements IDataAdapter
{
	public function adapt(value:Object):Object
	{
		var s:String = UTIL.fz(int(value).toString(16),4);
		return int(s.slice(0,2));
	}
	public function change(value:Object):Object
	{
		return value;
	}
	public function perform(field:IFormString):void
	{
	}
	public function recover(value:Object):Object
	{
		return int("0x"+UTIL.fz(int(value),2) + "00");
	}
}