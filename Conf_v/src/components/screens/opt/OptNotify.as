package components.screens.opt
{
	import flash.display.Bitmap;
	
	import components.abstract.functions.loc;
	import components.basement.OptionsBlock;
	import components.gui.fields.FSComboBox;
	import components.gui.fields.FSSimple;
	import components.interfaces.IFormString;
	import components.protocol.Package;
	import components.static.CMD;
	import components.system.SavePerformer;
	
	public final class OptNotify extends OptionsBlock
	{
		private var img:Bitmap;
		
		public function OptNotify(s:int, c:Class)
		{
			super();
			
			structureID = s;
			operatingCMD = CMD.VR_NOTIFICATION;
			
			FLAG_VERTICAL_PLACEMENT = false;
			
			img = new c;
			addChild( img );
			img.y = -9;
			
			var list:Array = [{data:0,label:loc("notify_disabled")},{data:1,label:loc("notify_quick_push")},{data:2,label:loc("notify_long_push")}]; 
			
			createUIElement( new FSComboBox, operatingCMD, "", callLogic, 1, list );
			attuneElement( NaN, 215, FSComboBox.F_COMBOBOX_NOTEDITABLE );
			getLastElement().x = 50;
			
			/// вариант с возможностями звонков на телефон
			list = [
					{data:1,label:loc("notify_send_alarm_server")},
					{data:2,label:loc("notify_call_subscriber")},
					{data:3,label:loc("notify_call_subscriber_untill_answer")},
					{data:4,label:loc("notify_send_sms")},
					{data:5,label:loc("notify_call_subscriber_and_send_sms")},
					{data:0,label:loc("notify_disabled")}];
			/*list = [{data:1,label:loc("notify_send_alarm_server")},{data:4,label:loc("notify_send_sms")},{data:0,label:loc("notify_disabled")}];*/
			createUIElement( new FSComboBox, operatingCMD, "", delegateSecondParam, 2, list );
			attuneElement( NaN, 350, FSComboBox.F_COMBOBOX_NOTEDITABLE );
			getLastElement().x = 275;
			
			createUIElement( new FSSimple, operatingCMD, "", null, 3, null, "+0-9", 20 ).x = 635;
			attuneElement( 0, 170 );
			getLastElement().visible = false;
		}
		
		
		override public function putData(p:Package):void
		{
			distribute( p.getStructure(getStructure()), operatingCMD );
			callLogic(null);
			showNbField( getField( operatingCMD, 2 ) );
		}
		private function callLogic(t:IFormString):void
		{
			var option:int = int( getField(operatingCMD,1).getCellInfo() );
			getField(operatingCMD, 2).disabled = Boolean(option == 0);
			getField(operatingCMD, 3).disabled = Boolean(option == 0);
			
			if (t)
				SavePerformer.remember(getStructure(),t);
		}
		
		private function delegateSecondParam( t:IFormString ):void
		{
			showNbField( t );
			remember( t );
		}
		
		private function showNbField(t:IFormString):void
		{
			
			var val:int = int( t.getCellInfo() );
			
			switch( val ) {
				case 2:
				case 3:
					getField( operatingCMD, 3 ).visible = true;
					break;
				default:
					getField( operatingCMD, 3 ).visible = false;	
			}
			
			
			
			
		}
		
		
	}
}