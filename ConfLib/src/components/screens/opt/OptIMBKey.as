package components.screens.opt
{
	import flash.events.Event;
	
	import components.abstract.RegExpCollection;
	import components.abstract.functions.loc;
	import components.abstract.sysservants.PartitionServant;
	import components.basement.OptionsBlock;
	import components.basement.UIRadioDeviceRoot;
	import components.gui.fields.FSComboCheckBox;
	import components.gui.fields.FSShadow;
	import components.gui.fields.FSSimple;
	import components.interfaces.IFocusable;
	import components.interfaces.IFormString;
	import components.protocol.Package;
	import components.screens.ui.UIKeys;
	import components.static.CMD;
	import components.system.UTIL;

	public class OptIMBKey extends OptionsBlock
	{
		public function OptIMBKey()
		{
			
			FLAG_SAVABLE = false;
			
			operatingCMD = CMD.VR_TM_KEY;
			//structureID = s;
			var anchor:int = 0;
			globalX = 10;
			globalY = 10;
			
			FLAG_SAVABLE = false;
			createUIElement( new FSSimple, 0, loc("rfd_tmkey_code"), callLogic, 1,null, "0-9A-Fa-f", 16 )
			attuneElement( 200, 200 );
			FLAG_SAVABLE = true;
			
			createUIElement( new FSShadow, operatingCMD, "1", null, 1 );
			
			createUIElement( new FSShadow, operatingCMD, "", null, 2 );
			createUIElement( new FSShadow, operatingCMD, "", null, 3 );
			createUIElement( new FSShadow, operatingCMD, "", null, 4 );
			createUIElement( new FSShadow, operatingCMD, "", null, 5 );
			createUIElement( new FSShadow, operatingCMD, "", null, 6 );
			createUIElement( new FSShadow, operatingCMD, "", null, 7 );
			createUIElement( new FSShadow, operatingCMD, "", null, 8 );
			createUIElement( new FSShadow, operatingCMD, "", null, 9 );
			
			createUIElement( new FSComboCheckBox, operatingCMD, loc("rfd_part_for_key_control"), callPartitionMemorizer, 10 );
			var ccb:FSComboCheckBox = getLastElement() as FSComboCheckBox;
			//ccb.x = ;
			ccb.turnToBitfield = PartitionServant.turnToPartitionBitfield;
			attuneElement( NaN, 200, FSComboCheckBox.F_MULTYLINE );
			
			createUIElement( new FSSimple, operatingCMD, loc("g_user_code"), null, 11, null, "0-9", 3, new RegExp( RegExpCollection.REF_0to255 ));
			attuneElement( 200, 50 );//, NaN, [FormString.F_SELECTABLE] );
		}
		override public function putData(p:Package):void
		{
			old = Boolean( p.data[0]==2 );
			structureID = p.structure;
			globalFocusGroup = 200*(structureID-1)+50;
			(getField(0,1) as IFocusable).focusgroup = globalFocusGroup; 
			refreshCells(operatingCMD);
			
			var a:Array = PartitionServant.getPartitionCCBList( p.data[9] );
			
			(getField( operatingCMD, 10 ) as FSComboCheckBox).setList( PartitionServant.getPartitionCCBList( p.data[9] ));
			distribute( p.data, operatingCMD );
			
			var key:String="";
			for(var i:int=1; i<9; ++i) {
				key += String( UTIL.formateZerosInFront(int(p.data[i]).toString(16),2) );
			}
			getField( 0, 1 ).setCellInfo( key.toUpperCase() );
			
			this.dispatchEvent( new Event( UIRadioDeviceRoot.EVENT_LOADED ));
		}
		private function callLogic():void
		{
			var txt:String = String(getField( 0, 1 ).getCellInfo());
			var bytecounter:int=0;
			for(var i:int=0; i<8; ++i) {
				getField( operatingCMD, i+2 ).setCellInfo( int("0x"+txt.slice(bytecounter,bytecounter+2)).toString() );
				bytecounter+=2;
			}
			remember( getField( operatingCMD, 2 ) );
		}
		private function callPartitionMemorizer(target:IFormString):void
		{
			UIKeys.LAST_PARTITION = int( target.getCellInfo() );
			remember( target );
		}
	}
}