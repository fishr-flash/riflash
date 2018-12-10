package components.screens.opt
{
	import flash.events.Event;
	
	import components.abstract.LOC;
	import components.abstract.adapters.StringCutterAdapter;
	import components.abstract.functions.loc;
	import components.basement.OptionListBlock;
	import components.gui.fields.FSShadow;
	import components.gui.fields.FormString;
	import components.gui.triggers.TextButton;
	import components.interfaces.IFlexListItem;
	import components.interfaces.IFormString;
	import components.protocol.Package;
	import components.screens.ui.UIRSms;
	import components.static.CMD;
	import components.static.DS;
	
	public class OptRSms extends OptionListBlock implements IFlexListItem
	{
		public static var globalcounter:int = 1;
		
		private var localnumber:int;
		private var bToLat:TextButton;
		private var bToCyr:TextButton;
		private var listeners:Array = [];
		private var fsms:FormString;
		private var fsmslen:IFormString;
		
		private var rule:RegExp = new RegExp("\\r|\\n|\\r\\n|\\n\\r");
		
		public function OptRSms(n:int)
		{
			super();
			
			structureID = n;
			localnumber = globalcounter++;
			
			FLAG_VERTICAL_PLACEMENT = false;
			
			addui( new FormString, 0, localnumber.toString(), null, 1);
			attuneElement( 30 );
			
			addui( new FormString, 0, "name", null, 2 ).x = 40;
			attuneElement( 600 );
			
			fsmslen = addui( new FSShadow, CMD.K5_SMS_TEXT, "", null, 1 );
			fsms = addui( new FormString, CMD.K5_SMS_TEXT, "sms", null, 2, null, "", 45 ) as FormString;
			getLastElement().setAdapter( new StringCutterAdapter(getField(CMD.K5_SMS_TEXT,1)));
			attuneElement( 400, NaN, FormString.F_EDITABLE );
			fsms.x = 640;
			
			if (LOC.language == LOC.RU) {
				bToLat = new TextButton;
				addChild( bToLat );
				bToLat.setUp( loc("sms_translit"), onClick, 1 );
				bToLat.x = 1050;
				
				bToCyr = new TextButton;
				addChild( bToCyr );
				bToCyr.setUp( loc("sms_cyr"), onClick, 2 );
				bToCyr.x = 1120;
			}
		}
		public function set smstext(value:String):void
		{
			if (fsms.getCellInfo() != value) {
				fsmslen.setCellInfo( value.length );
				fsms.setCellInfo( value ); 
				remember( fsms );
			}
		}
		public function get smstext():String
		{
			return String(getField( CMD.K5_SMS_TEXT,2 ).getCellInfo());
		}
		override public function get height():Number
		{
			return 25;
		}
		override public function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void
		{
			super.addEventListener(type, listener, useCapture, priority, useWeakReference);
			listeners.push({type:type, listener:listener});
		}
		public function put(p:Package):void
		{
			var uir:Array = UIRSms.SMS_TEXT;
			
			if (DS.isfam(DS.K1))
				getField(0,2).setCellInfo( UIRSms.SMS_TEXT[getStructure()] );
			else
				getField(0,2).setCellInfo( UIRSms.SMS_TEXT[localnumber-1] );
			fsmslen.setCellInfo( p.getValidStructure()[0] );
			
			var s:String = p.getValidStructure()[1];
			if (s.search(rule) > -1 ) {
				s = s.replace( rule, "" );
				fsmslen.setCellInfo( s.length );
				remember( fsms );
			}
			fsms.setCellInfo( s );
		}
		public function kill():void
		{
			for(var i:Number = 0; i<listeners.length; i++) {
				if( this.hasEventListener(listeners[i].type)) {
					this.removeEventListener(listeners[i].type, listeners[i].listener);
				}
			}
			listeners = null
				
		}
		public function extract():Array		{	return null	}
		public function change(p:Package):void		{		}
		public function putRaw(value:Object):void
		{
			fsmslen.setCellInfo( String(value).length );
			fsms.setCellInfo( String(value) );
			remember(fsms);
		}
		private function onClick(n:int):void
		{
			if (n == 1)
				this.dispatchEvent( new Event(UIRSms.EVENT_LAT));
			else
				this.dispatchEvent( new Event(UIRSms.EVENT_CYR));
		}
		public function set selectLine(b:Boolean):void	{		}
		public function isSelected():Boolean
		{
			return false
		}
	}
}