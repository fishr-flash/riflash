package components.screens.opt
{
	import flash.utils.getTimer;
	
	import components.abstract.GroupOperator;
	import components.abstract.functions.dtrace;
	import components.abstract.functions.loc;
	import components.basement.OptionsBlock;
	import components.gui.SubsetVrgEvents;
	import components.gui.fields.FSComboBox;
	import components.gui.fields.FSShadow;
	import components.gui.fields.FormString;
	import components.static.CMD;
	import components.system.UTIL;
	
	public class OptVEvents extends OptionsBlock
	{
		private const GROUP_OCCURENCE:String = "groupOccurence";
		private const GROUP_RECOVERY:String = "groupRecovery";
		private var _jmess:Object;
		private var _gr:GroupOperator;
		private var _zerroCommand:int;
		
		public function set jmess(value:Object):void
		{
			_jmess = value;
		}
		public function get jmess():Object
		{
		 	return _jmess;
		}
		
		public function OptVEvents( jmess:Object)
		{
			super();
		
			FLAG_VERTICAL_PLACEMENT = false;
			_jmess = jmess;
			operatingCMD = CMD.VR_MSG_SETTINGS;
			structureID = int( _jmess.MSG_ID );
			_zerroCommand = -structureID;
			
			 
			_gr = new GroupOperator;
			
			
		}
		
		

		public function open():Boolean
		{
			if( this.numChildren ) return false;
			
			FLAG_SAVABLE = false;
			
			// событие
			_gr.add( GROUP_OCCURENCE, addui( new FormString,_zerroCommand, _jmess.Occurrence, dgtBit, 1 ) );
			attuneElement( SubsetVrgEvents.PREV_COLOUMN_WIDTH, NaN, FormString.F_NOT_EDITABLE_WITH_BORDER );
			globalX += SubsetVrgEvents.PREV_COLOUMN_WIDTH;
			
			const list:Array = UTIL.getComboBoxList( [ [ 0, loc("information") ], [ 4, loc("k5_wire_alarm") ] ] );
			
			_gr.add( GROUP_OCCURENCE, addui( new FSComboBox,_zerroCommand, loc( "" ), dgtBit, 2, list) );
			attuneElement( 0, SubsetVrgEvents.SECOND_SUBSECTION_COLOUMN_WIDTH + 1, FSComboBox.F_COMBOBOX_NOTEDITABLE );
			globalX += SubsetVrgEvents.SECOND_SUBSECTION_COLOUMN_WIDTH;
			
			const list_II:Array =  UTIL.getComboBoxList
				( 
					[
						[ 0, loc("no_transmit" ) ],
						[ 1, loc("g_immediately") ],
						[ 2, loc( "transfer_when_connecting" ) ],
						[ 3, loc( "permament_transmission" ) ]
					]
				);
			
			_gr.add( GROUP_OCCURENCE, addui( new FSComboBox,_zerroCommand, loc( "" ), dgtBit, 3, list_II ) );
			attuneElement( 0, ( SubsetVrgEvents.SECOND_COLOUMN_WIDTH - SubsetVrgEvents.SECOND_SUBSECTION_COLOUMN_WIDTH ) + 1, FSComboBox.F_COMBOBOX_NOTEDITABLE );
			globalX += SubsetVrgEvents.SECOND_COLOUMN_WIDTH - SubsetVrgEvents.SECOND_SUBSECTION_COLOUMN_WIDTH;
			
			_gr.add( GROUP_OCCURENCE, addui( new FSComboBox,_zerroCommand, loc( "" ), dgtBit, 4, list ) );
			attuneElement( 0, SubsetVrgEvents.SECOND_SUBSECTION_COLOUMN_WIDTH + 1, FSComboBox.F_COMBOBOX_NOTEDITABLE );
			globalX += SubsetVrgEvents.SECOND_SUBSECTION_COLOUMN_WIDTH;
			
			_gr.add( GROUP_OCCURENCE, addui( new FSComboBox,_zerroCommand, loc( "" ), dgtBit, 5, list_II ) );
			attuneElement( 0, ( SubsetVrgEvents.SECOND_COLOUMN_WIDTH - SubsetVrgEvents.SECOND_SUBSECTION_COLOUMN_WIDTH ) + 1, FSComboBox.F_COMBOBOX_NOTEDITABLE );
			globalX += SubsetVrgEvents.SECOND_COLOUMN_WIDTH - SubsetVrgEvents.SECOND_SUBSECTION_COLOUMN_WIDTH;
			
			globalX = 0;
			globalY += getLastElement().height;
			
			
			/// действия по завершению события
			_gr.add( GROUP_RECOVERY, addui( new FormString,_zerroCommand, _jmess.Recovery, dgtBit, 6 ) );
			attuneElement( SubsetVrgEvents.PREV_COLOUMN_WIDTH, NaN, FormString.F_NOT_EDITABLE_WITH_BORDER );
			globalX += SubsetVrgEvents.PREV_COLOUMN_WIDTH;
			
			
			_gr.add( GROUP_RECOVERY, addui( new FSComboBox,_zerroCommand, loc( "" ), dgtBit, 7, list) );
			attuneElement( 0, SubsetVrgEvents.SECOND_SUBSECTION_COLOUMN_WIDTH + 1, FSComboBox.F_COMBOBOX_NOTEDITABLE );
			
			
			globalX += SubsetVrgEvents.SECOND_SUBSECTION_COLOUMN_WIDTH;
			
			
			_gr.add( GROUP_RECOVERY, addui( new FSComboBox,_zerroCommand, loc( "" ), dgtBit, 8, list_II ) );
			attuneElement( 0, ( SubsetVrgEvents.SECOND_COLOUMN_WIDTH - SubsetVrgEvents.SECOND_SUBSECTION_COLOUMN_WIDTH ) + 1, FSComboBox.F_COMBOBOX_NOTEDITABLE );
			globalX += SubsetVrgEvents.SECOND_COLOUMN_WIDTH - SubsetVrgEvents.SECOND_SUBSECTION_COLOUMN_WIDTH;
			
			_gr.add( GROUP_RECOVERY, addui( new FSComboBox,_zerroCommand, loc( "" ), dgtBit, 9, list ) );
			attuneElement( 0, SubsetVrgEvents.SECOND_SUBSECTION_COLOUMN_WIDTH + 1, FSComboBox.F_COMBOBOX_NOTEDITABLE );
			globalX += SubsetVrgEvents.SECOND_SUBSECTION_COLOUMN_WIDTH;
			
			_gr.add( GROUP_RECOVERY, addui( new FSComboBox,_zerroCommand, loc( "" ), dgtBit, 10, list_II ) );
			attuneElement( 0, ( SubsetVrgEvents.SECOND_COLOUMN_WIDTH - SubsetVrgEvents.SECOND_SUBSECTION_COLOUMN_WIDTH ) + 1, FSComboBox.F_COMBOBOX_NOTEDITABLE );
			globalX += SubsetVrgEvents.SECOND_COLOUMN_WIDTH - SubsetVrgEvents.SECOND_SUBSECTION_COLOUMN_WIDTH;
			
			if( _jmess.Recovery == "" ) _gr.removeFromTheScene( GROUP_RECOVERY );
			
			updateHeight();
			
			manualResize();
			
			FLAG_SAVABLE = true;
			
			addui( new FSShadow, operatingCMD, "", null, 1 );
			addui( new FSShadow, operatingCMD, "", null, 2 );
			addui( new FSShadow, operatingCMD, "", null, 3 );
			addui( new FSShadow, operatingCMD, "", null, 4 );
			
			
			
			putRawData( _jmess.settings[ 0 ] as Array );
			
			return true;
		}
		override public function putRawData(a:Array):void
		{
			
			getField( operatingCMD, 1 ).setCellInfo( a[ 0 ] );
			getField( operatingCMD, 2 ).setCellInfo( a[ 1 ] );
			getField( operatingCMD, 3 ).setCellInfo( a[ 2 ] );
			getField( operatingCMD, 4 ).setCellInfo( a[ 3 ] );
			
			getField( _zerroCommand, 2 ).setCellInfo( a[ 0 ] & 0x4?4:0 );
			getField( _zerroCommand, 4 ).setCellInfo( a[ 1 ] & 0x4?4:0 );
			getField( _zerroCommand, 7 ).setCellInfo( a[ 2 ] & 0x4?4:0 );
			getField( _zerroCommand, 9 ).setCellInfo( a[ 3 ] & 0x4?4:0 );
			
			getField( _zerroCommand, 3 ).setCellInfo( a[ 0 ] & 0x3 );
			getField( _zerroCommand, 5 ).setCellInfo( a[ 1 ] & 0x3 );
			getField( _zerroCommand, 8 ).setCellInfo( a[ 2 ] & 0x3 );
			getField( _zerroCommand, 10 ).setCellInfo( a[ 3 ] & 0x3 );
			
			
		}
		
		private function dgtBit():void
		{
			getField( operatingCMD, 1 ).setCellInfo( int( getField( _zerroCommand, 2 ).getCellInfo() ) + int( getField( _zerroCommand, 3 ).getCellInfo() ) );
			getField( operatingCMD, 2 ).setCellInfo( int( getField( _zerroCommand, 4 ).getCellInfo() ) + int( getField( _zerroCommand, 5 ).getCellInfo() ) );
			getField( operatingCMD, 3 ).setCellInfo( int( getField( _zerroCommand, 7 ).getCellInfo() ) + int( getField( _zerroCommand, 8 ).getCellInfo() ) );
			getField( operatingCMD, 4 ).setCellInfo( int( getField( _zerroCommand, 9 ).getCellInfo() ) + int( getField( _zerroCommand, 10 ).getCellInfo() ) );
			
			remember( getField( operatingCMD, 1 ) );
			remember( getField( operatingCMD, 2 ) );
			remember( getField( operatingCMD, 3 ) );
			remember( getField( operatingCMD, 4 ) );
		}
		
		private function updateHeight():void
		{
			var len:int = this.numChildren;
			var newH:int = 0;
			var maxHeight:int = newH;
			for (var i:int=0; i<len; i++) {
				newH = this.getChildAt( i ).y + this.getChildAt( i ).height; 
				if( newH > maxHeight ) 
					maxHeight = newH;
			}
			this.height = maxHeight + SubsetVrgEvents.V_INDENT_TABLE;
			
		}
	}
}