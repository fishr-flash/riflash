package components.screens.opt
{
	import components.abstract.RegExpCollection;
	import components.abstract.functions.loc;
	import components.basement.OptionListBlock;
	import components.gui.fields.FSComboBox;
	import components.gui.fields.FSShadow;
	import components.gui.fields.FormString;
	import components.static.CMD;
	import components.system.UTIL;
	
	public class OptKey extends OptionListBlock
	{
		public function OptKey(s:int)
		{
			super();

			SELECTION_Y_SHIFT -= 1;
			
			operatingCMD = CMD.TM_KEY2;
			structureID = s;
			
			FLAG_VERTICAL_PLACEMENT = false;
			
			FLAG_SAVABLE = false;
			createUIElement( new FormString, 0, s.toString(), null, 1 ).x = globalX;
			attuneElement( 30 );
			FLAG_SAVABLE = true;
			
			createUIElement( new FSShadow, operatingCMD, "1", null, 1 );
			createUIElement( new FormString, operatingCMD, "", null, 2, null, "", 30 ).x = globalX+35;
			attuneElement( 250, NaN, FormString.F_EDITABLE );
			
			var menu:Array = [{data:0,label:loc("tmkey_disabled")},{data:1,label:loc("tmkey_arm")},{data:2,label:loc("tmkey_disarm")},{data:3,label:loc("tmkey_arm_disarm")}];
			createUIElement( new FSComboBox, operatingCMD, "", null, 3, menu ).x = globalX+290;
			attuneElement( 150,NaN, FSComboBox.F_COMBOBOX_NOTEDITABLE );
			
			createUIElement( new FSShadow, operatingCMD, "", null, 4 );
			createUIElement( new FSShadow, operatingCMD, "", null, 5 );
			createUIElement( new FSShadow, operatingCMD, "", null, 6 );
			createUIElement( new FSShadow, operatingCMD, "", null, 7 );
			createUIElement( new FSShadow, operatingCMD, "", null, 8 );
			createUIElement( new FSShadow, operatingCMD, "", null, 9 );
			createUIElement( new FSShadow, operatingCMD, "", null, 10 );
			createUIElement( new FSShadow, operatingCMD, "", null, 11 );
			
			/**Параметры 4,5,6,7,8,9,10,11 - Код ключа, Параметр 4 - младший байт (код семейства), параметры 5-10 (48бит код ключа), параметр 11 - контрольная сумма (CRC8).*/
			FLAG_SAVABLE = false;
			createUIElement( new FormString, 0, "", callLogic, 2, null, "0-9A-Fa-f", 16, new RegExp( RegExpCollection.COMPLETE_TM_KEY )).x = 445;
			attuneElement( 140, NaN, FormString.F_EDITABLE );
			
			drawSelection(600);
			drawLoading(600, loc("tmkey_adding") );
		}
		override public function putRawData(data:Array):void
		{
			distribute( data, operatingCMD );
			
			var key:String="";
			for(var i:int=3; i<11; ++i) {
				key += String( UTIL.formateZerosInFront(int(data[i]).toString(16),2) );
			}
			getField( 0, 2 ).setCellInfo( key.toUpperCase() );
			loadingVisible(false);
		}
		private function callLogic():void
		{
			var txt:String = String(getField( 0, 2 ).getCellInfo());
			var bytecounter:int=0;
			for(var i:int=0; i<8; ++i) {
				getField( operatingCMD, i+4 ).setCellInfo( int("0x"+txt.slice(bytecounter,bytecounter+2)) );
				bytecounter+=2;
			}
			remember( getField( operatingCMD, 4 ) );
		}
		override public function call(value:Object, param:int):Boolean
		{
			if (param == structureID)
				loadingVisible(true);
			return true;
		}
		override public function setUnique(b:Boolean):void
		{
			(getField(operatingCMD,4) as FSShadow).valid = b;
		}
		override public function getUnique():String
		{
			if (!getField(0,2).isValid())
				return null;
			var key:String="";
			for(var i:int=4; i<12; ++i) {
				key += getField(operatingCMD,i).getCellInfo().toString();
			}
			return key;//getField( 0, 2 ).getCellInfo() as String;
		}
	}
}