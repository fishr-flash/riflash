package components.screens.opt
{
	import components.abstract.RegExpCollection;
	import components.abstract.functions.loc;
	import components.basement.OptionListBlock;
	import components.gui.fields.FSComboBox;
	import components.gui.fields.FormString;
	import components.gui.triggers.TextButton;
	import components.interfaces.IListItem;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.static.CMD;
	import components.static.COLOR;
	import components.static.PART_FUNCT;
	import components.system.UTIL;
	
	public class OptPartition extends OptionListBlock implements IListItem
	{
		private const PARTITION_STATUS_UNKNOWN:int = 0x00;
		private const PARTITION_STATUS_NOTGUARDED:int = 0x01;
		private const PARTITION_STATUS_GUARDED:int = 0x02;
		private const PARTITION_STATUS_ALARM_UNGUARDED:int = 0x03;
		private const PARTITION_STATUS_DELAYCOUNTDOWN:int = 0x04;
		private const PARTITION_STATUS_OFFLINE:int = 0x05;
		private const PARTITION_STATUS_ERROR_NOSECTION:int = 0x06;
		private const PARTITION_STATUS_ERROR_CMDTOPARTITION:int = 0x07;
		private const PARTITION_STATUS_ALARM_GUARDED:int = 0x08;
		private const PARTITION_STATUS_CHECK_SERVER:int = 0x09;
		
		private var bAction:TextButton;
		
		public function OptPartition( _id:int )
		{
			super();
			
			var linewidth:int = 665-11+40-170;
			
			drawSelection(linewidth);
			structureID = _id;
			globalFocusGroup = structureID*10;
			
			FLAG_VERTICAL_PLACEMENT = false;
			
			operatingCMD = CMD.PARTITION;
			
//"^(0?[1-9]|[1-8]\\d|9[1-8])$"
			createUIElement( new FormString, operatingCMD,"",null,1,null,"0-9",2,new RegExp( "^([1-9]|([1-8]\\d)|(9[1-8]))$" ) ).x = -10;
			attuneElement( 50,NaN, FormString.F_ALIGN_CENTER | FormString.F_EDITABLE );
			getLastFocusable().focusorder = 1;
			
			createUIElement( new FormString, CMD.PART_STATE_ALL,"",null,1).x = 50;
			attuneElement( 200,NaN, FormString.F_ALIGN_CENTER );
			
			bAction = new TextButton;
			addChild( bAction );
			bAction.x = 245;
			bAction.setFormat( true, 12 );
			bAction.setUp( loc("ui_part_set_on_guard"), changeAction )
			bAction.data = PART_FUNCT.TAKEONGUARD;
			bAction.focusgroup = globalFocusGroup;
			bAction.focusorder = 2;
			
			createUIElement( new FormString, operatingCMD, "",null,2,null,"B-Fb-f0-9", 4, new RegExp( RegExpCollection.REF_CODE_OBJECT )).x = 410; //"^([\\w|\\d]{4})$"
			attuneElement(50,NaN, FormString.F_EDITABLE | FormString.F_TEXT_RETURNS_HEXDATA );
			getLastFocusable().focusorder = 3;
			
			createUIElement( new FSComboBox, operatingCMD, "",null,3,
				[{label:loc("g_delay"), data:0}, {label:"10", data:10}, {label:"20", data:20}, {label:"30", data:30}, {label:"40", data:40}],
				"0-9",3,new RegExp( "^(([01]?\\d{1,2})|(2[0-4]\\d)|(25[0-5])|"+loc("g_delay")+")$")).x = 502; // 0-255 + текст
			getLastFocusable().focusorder = 4;
			
			complexHeight = 24;
		}
		private function changeAction():void
		{ /** ( 0 - нет команды, 1 - взять на охрану, 2 - снять с охраны, 3 - запросить состояние раздела ) */
			if ( bAction.data == PART_FUNCT.TAKEOFFGUARD)
				RequestAssembler.getInstance().fireEvent( new Request( CMD.PART_FUNCT, null, 1,[ structureID, PART_FUNCT.TAKEOFFGUARD ]));
			else
				RequestAssembler.getInstance().fireEvent( new Request( CMD.PART_FUNCT, null, 1,[ structureID, PART_FUNCT.TAKEONGUARD ]));
		}
		public function putStatus( _status:int ):void 
		{
			bAction.setName( loc("ui_part_set_on_guard") );
			bAction.data = PART_FUNCT.TAKEONGUARD;
			
			var field:FormString = getField( CMD.PART_STATE_ALL,1 ) as FormString;
			switch( _status )
			{
				case PARTITION_STATUS_UNKNOWN:
					field.setName( loc("g_unknown").toLowerCase() );
					field.setTextColor( COLOR.PARTITION_RED);
					break;
				case PARTITION_STATUS_NOTGUARDED:
					field.setName( loc("ui_part_off_guard") );
					field.setTextColor( COLOR.PARTITION_GREEN );
					break;
				case PARTITION_STATUS_GUARDED:
					field.setName( loc("ui_part_on_guard") );
					field.setTextColor( COLOR.PARTITION_ORANGE );
					bAction.setName( loc("ui_part_set_off_guard") );
					bAction.data = PART_FUNCT.TAKEOFFGUARD;
					break;
				case PARTITION_STATUS_ALARM_UNGUARDED:
					field.setName( loc("ui_part_alarm") );
					field.setTextColor( COLOR.PARTITION_RED );
					break;
				case PARTITION_STATUS_DELAYCOUNTDOWN:
					field.setName( loc("ui_part_counting_delay") );
					field.setTextColor( COLOR.PARTITION_RED );
					bAction.setName( loc("ui_part_set_off_guard") );
					bAction.data = PART_FUNCT.TAKEOFFGUARD;
					break;
				case PARTITION_STATUS_OFFLINE:
					field.setName( loc("ui_part_offline") );
					field.setTextColor( COLOR.PARTITION_RED );
					break;
				case PARTITION_STATUS_ERROR_NOSECTION:
					field.setName( loc("ui_part_not_exist") );
					field.setTextColor( COLOR.PARTITION_RED );
					break;
				case PARTITION_STATUS_ERROR_CMDTOPARTITION:
					field.setName( loc("ui_part_cmd_error") );
					field.setTextColor( COLOR.PARTITION_RED );
					break;
				case PARTITION_STATUS_ALARM_GUARDED:
					field.setName( loc("ui_part_alarm") );
					field.setTextColor( COLOR.PARTITION_RED );
					bAction.setName( loc("ui_part_set_off_guard") );
					bAction.data = PART_FUNCT.TAKEOFFGUARD;
					break;
				case PARTITION_STATUS_CHECK_SERVER:
					field.setName( loc("ui_part_chserver").toLowerCase() );
					field.setTextColor( COLOR.YELLOW_SIGNAL_DARK );
					bAction.setName( loc("ui_part_set_off_guard") );
					bAction.data = PART_FUNCT.TAKEOFFGUARD;
					break;
			}
		}
		override public function putRawData(data:Array):void
		{
			var aPartition:Array = data;
			
			getField(operatingCMD,1).setCellInfo( String( aPartition[0] ) );
			getField(operatingCMD,2).setCellInfo( UTIL.formateZerosInFront(  Number( aPartition[1]  ).toString(16) , 4  ) );
			getField(operatingCMD,3).setCellInfo( String( aPartition[2] ) );
		}
	}
}