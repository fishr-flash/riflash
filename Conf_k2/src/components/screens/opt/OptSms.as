package components.screens.opt
{
	import flash.events.Event;
	import flash.events.FocusEvent;
	
	import components.abstract.ClientArrays;
	import components.abstract.SmsServant;
	import components.abstract.functions.loc;
	import components.basement.OptionListBlock;
	import components.gui.fields.FSSimple;
	import components.screens.ui.UISms;
	import components.static.CMD;
	import components.system.SavePerformer;
	import components.system.UTIL;
	
	public class OptSms extends OptionListBlock
	{
		public function OptSms(s:int)
		{
			super();
			
			structureID = s;
			operatingCMD = CMD.SMS_TEXT_K2;
			createUIElement( new FSSimple, operatingCMD, "", null, 1, null,"",50);
			attuneElement( 350,450, FSSimple.F_CELL_ALIGN_LEFT );
			getLastElement().addEventListener( FocusEvent.FOCUS_OUT, focusOut );
		}
		override public function call(value:Object, param:int):Boolean
		{
			var f:FSSimple = getField( operatingCMD, 1 ) as FSSimple;
			var compare:String;
			switch( param ) {
				case UISms.UPDATE_NAME:
					f.setName( String(value) );
					if ( String(value) == loc("sms_autotest")) {
						f.attune( FSSimple.F_CELL_ALIGN_LEFT | FSSimple.F_CELL_NOTEDITABLE_EDITBOX );
						f.removeEventListener( FocusEvent.FOCUS_OUT, focusOut );
					}
					break;
				case UISms.UPDATE_DATA:
					compare = value.toString();
					if (String(value) == loc("sms_autotest"))
						compare = loc("g_test");
					if (f.getCellInfo() != compare ) {
						f.setCellInfo( compare );
						remember( f );
					}
					break;
				case UISms.TRIM_SPACES:
					if ( UTIL.isTrimSpace( f.getCellInfo() )) {
						f.setCellInfo( UTIL.doTrimSpace( f.getCellInfo() ) );
						SavePerformer.remember( getId(), f );
					}
					break;
				case UISms.TEST:
					if (String(value) == loc("sms_autotest"))
						return f.getCellInfo() == loc("g_test");
					return f.getCellInfo() == String(value);
				case UISms.UPDATE_CID:
					const expression:String = SmsServant.CODE_OBJECT + "18" + value.toString(); 
					compare = expression  + SmsServant.crc( expression );
					
					if (f.getCellInfo().toString().toUpperCase() != compare.toUpperCase() ) {
						f.setCellInfo( compare.toUpperCase() );
						remember( f );
					}
					break;
				case UISms.UPDATE_CID_IMEI:
					const expression1:String = SmsServant.CODE_OBJECT + "18" + value.toString(); 
					compare = expression1  + SmsServant.crc( expression1 );
					const composite:String = SmsServant.IMEI + compare;
					if (f.getCellInfo().toString().toLowerCase() != composite.toLowerCase() ) {
						f.setCellInfo( composite.toLowerCase() );
						remember( f );
					}
					break;
			}
			return true;
		}
		override public function putRawData(data:Array):void
		{
			getField( operatingCMD,1).setCellInfo( data[0] );
		}
		private function focusOut(ev:Event):void
		{
			var f:FSSimple = getField( operatingCMD, 1 ) as FSSimple;
			if ( (f.getCellInfo() as String).length == 0 ) {
				if ( ClientArrays.sms_text[getId()-1] == loc("sms_autotest"))
					f.setCellInfo( loc("g_test") );
				else
					f.setCellInfo( ClientArrays.sms_text[getId()-1] );
				SavePerformer.remember(getId(),f);
			} else {
				if ( UTIL.isTrimSpace( f.getCellInfo() )) {
					f.setCellInfo( UTIL.doTrimSpace( f.getCellInfo() ) );
					SavePerformer.remember( getId(), f );
				}
			}
		}
		override public function set disabled(value:Boolean):void
		{
			(getField( operatingCMD, 1 ) as FSSimple).focusable = !value;
			
			
		}
	}
}