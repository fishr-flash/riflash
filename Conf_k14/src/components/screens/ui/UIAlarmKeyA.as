package components.screens.ui
{
	import components.abstract.functions.loc;
	import components.abstract.servants.CIDServant;
	import components.abstract.sysservants.PartitionServant;
	import components.basement.UI_BaseComponent;
	import components.gui.fields.FSComboBox;
	import components.gui.fields.FSComboBoxExt;
	import components.gui.fields.FSShadow;
	import components.gui.fields.FSSimple;
	import components.interfaces.IFormString;
	import components.protocol.Package;
	import components.static.CMD;
	import components.system.UTIL;
	
	public class UIAlarmKeyA extends UI_BaseComponent
	{
		public function UIAlarmKeyA()
		{
			super();
			
			const mainCMD:int = CMD.ALARM_WIRE_SET;
			
			const wl:int = 500;
			const wc:int = 300;
			
			addui( new FSShadow, mainCMD, "", null, 1 );
			attuneElement( wl );
			addui( new FSComboBox, mainCMD, loc( "guard_zonenum" ), null  , 2,UTIL.comboBoxNumericDataGenerator( 0, 99 ), "0-9", 2 );
			attuneElement( wl );
			const lst:Array = [{data:0x00, label:loc("wire_state_open").toLowerCase()},
				{data:0x01, label:loc("wire_state_closed").toLowerCase()} ];
			addui( new FSComboBox, mainCMD, loc( "guard_norm" ), null  , 3, lst, "0-1", 1 );
			attuneElement( wl );
			addui( new FSComboBox, mainCMD, loc( "g_zonetype" ), delegateTypeZone  , 4, CIDServant.getZoneTypeBySensor(), "0-1", 1 );
			attuneElement( wl );
			addui( new FSSimple, mainCMD, loc( "wire_enter_delay" ), null  , 5, null);
			attuneElement( wl );
			addui( new FSComboBox, mainCMD, loc( "guard_partnum" ), null  , 6, PartitionServant.getPartitionList(), "0-1", 1 );
			attuneElement( wl );
			addui( new FSShadow, mainCMD, "", null, 7 );
			attuneElement( wl );
			
			const events:Array =  CIDServant.getEvent( CIDServant.CID_RFSENSORS );
			events.splice( 0,1 );
			addui( new FSComboBoxExt, mainCMD, loc( "rfd_event_on_trigger" ), null  , 8, events, "0-1", 1 );
			attuneElement( 300, wc );
			(getLastElement() as FSComboBoxExt).attune( FSComboBox.F_RETURNS_HEXDATA );
			
			
			starterCMD = mainCMD;
			
			width = 650;
		}
		
		private function delegateTypeZone( ifr:IFormString ):void
		{
			
			getField( CMD.ALARM_WIRE_SET, 5 ).disabled = ifr.getCellInfo() != 2; // если зона не входная
			
			remember( ifr );
			
		}
		
		override public function put(p:Package):void
		{
			( getField( CMD.ALARM_WIRE_SET, 6 ) as FSComboBox ).setList( PartitionServant.getPartitionList() );
			
			/// переводим значение события в hex-формат для правильного определения события
			p.data[ 0 ][ 7 ] =  int( Number( p.data[ 0 ][ 7 ] ).toString( 16 ) );
			getField( CMD.ALARM_WIRE_SET, 5 ).disabled = p.data[ 0 ][ 3 ] != 2; // если зона не входная
			pdistribute( p );
			loadComplete();
		}
	}
}