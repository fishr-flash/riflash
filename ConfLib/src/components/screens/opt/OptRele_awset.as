package components.screens.opt
{
	import components.abstract.RegExpCollection;
	import components.abstract.functions.loc;
	import components.abstract.servants.CIDServant;
	import components.abstract.sysservants.PartitionServant;
	import components.basement.OptionsBlock;
	import components.gui.fields.FSComboBox;
	import components.gui.fields.FSShadow;
	import components.gui.fields.FormString;
	import components.protocol.Package;
	import components.static.CMD;
	import components.system.UTIL;
	
	public class OptRele_awset extends OptionsBlock
	{
		public function OptRele_awset()
		{
			super();
			yshift = 15;
			globalX = 10;
			FLAG_SAVABLE = false;
			createUIElement( new FormString, 1, loc("g_zonenum"), null, 1 );
			globalY++;
			createUIElement( new FormString, 1, loc("g_zonetype"), null, 2 );
			globalY++;
			createUIElement( new FormString, 1, loc("rfd_enter_delay"), null, 3 );
			globalY++;
			attuneElement(NaN,NaN, FormString.F_MULTYLINE );
			createUIElement( new FormString, 1, loc("g_partition"), null, 4 );
			globalY++;
			createUIElement( new FormString, 1, loc("rfd_event_on_trigger"), null, 6 );
			attuneElement(NaN,NaN, FormString.F_MULTYLINE );
			FLAG_SAVABLE = true;
			
			operatingCMD = CMD.RFRELAY_AWSET;
			globalX = 200;
			globalY = 0;
			
			createUIElement( new FSComboBox, operatingCMD, "", null, 1, UTIL.comboBoxNumericDataGenerator(1,99) );
			attuneElement( NaN, NaN, FSComboBox.F_COMBOBOX_NOTEDITABLE );
			createUIElement( new FSComboBox, operatingCMD, "", null, 2, CIDServant.getZoneTypeBySensor() );
			attuneElement( NaN, NaN, FSComboBox.F_COMBOBOX_NOTEDITABLE );
			createUIElement( new FormString, operatingCMD, "", null, 3,null,"0-9",3, new RegExp( RegExpCollection.REF_0and5to255_f ) );
			attuneElement( 100, NaN, FormString.F_EDITABLE );
			createUIElement( new FSComboBox, operatingCMD, "", null, 4, PartitionServant.getPartitionList() );
			attuneElement( 100,NaN, FSComboBox.F_COMBOBOX_NOTEDITABLE );
			createUIElement( new FSShadow, operatingCMD, "0", null, 5 );
			createUIElement( new FSComboBox, operatingCMD, "", null, 6, CIDServant.getEvent() );
			attuneElement( 300,NaN, FSComboBox.F_COMBOBOX_NOTEDITABLE | FSComboBox.F_RETURNS_HEXDATA );
		}
		override public function putData(p:Package):void
		{
			structureID = p.structure;
			refreshCells(operatingCMD);
			/** Команда - настройка шлейфа радиореле (16шт. радиореле ):
			 * 	Параметр 1 - Номер зоны (1-999);
			 * 	Параметр 2 - Тип зоны ( 0x00 - нет, 0x01 - проходная, 0x02 - входная, 0x03 - 24 часа, 0x04 - Мгновенная, 0x05 - Ключевая );
			 * 	Параметр 3 - Задержка на вход (0-255);
			 * 	Параметр 4 - Раздел ( Битовое поле, указывающее на на строку в PARTITION. 0x0001 - первая строка, 0x0002 - вторая строка, 0x0004 - третья строка..., 0x8000 - 16 строка). Если Параметр 5 "Мастер раздела" не равен 0, то раздел задается числом 1-99
			 * 	Параметр 5 - Мастер раздела (0-нет, 1-254); ( у Контакта 14 - поле не обрабатывается )
			 * 	Параметр 6 - Событие ContactID при срабатывании шлейфа.	*/
			
			getField( operatingCMD, 1 ).setCellInfo( String( p.getStructure()[0]) );
			getField( operatingCMD, 2 ).setCellInfo( String( p.getStructure()[1]) );
			getField( operatingCMD, 3 ).setCellInfo( String( p.getStructure()[2]) );
			getField( operatingCMD, 4 ).setCellInfo( String( p.getStructure()[3]) );
			getField( operatingCMD, 5 ).setCellInfo( String( p.getStructure()[4]) );
			getField( operatingCMD, 6 ).setCellInfo( int(p.getStructure()[5]).toString(16) );
		}
	}
}