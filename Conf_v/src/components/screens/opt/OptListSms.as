package components.screens.opt
{
	import flash.events.Event;
	
	import components.abstract.servants.SmsVjsServant;
	import components.events.GUIEventDispatcher;
	import components.events.GUIEvents;
	import components.gui.OptList;
	import components.gui.fields.FSComboBox;
	import components.protocol.Package;
	
	public class OptListSms extends OptList
	{
		public function OptListSms()
		{
			super();
			
			
		}
		
		
		
		public function revertDefault():void
		{
			var len:int = cont.numChildren;
			var optSms:OptSms_text_v;
			for (var i:int=0; i<len; i++) 
			{
				optSms = cont.getChildAt( i ) as OptSms_text_v;
				if( optSms )optSms.recovery();
				
				optSms = null;
				
				
				
			}
			
		}
		
		public function putLocsEnb(p:Package):void
		{
			
			var len:int = cont.numChildren;
			var optSms:OptSms_text_v;
			for (var i:int=0; i<len; i++) 
			{
				optSms = cont.getChildAt( i ) as OptSms_text_v;
				if( optSms )optSms.putLocEnb( p )
				
				optSms = null;
				
				
				
			}
		}
		
		override public function put( p:Package, cls:Class ):void
		{
			
			
			super.put( p, cls );
			
			fetchIdleMess();
			
			GUIEventDispatcher.getInstance().addEventListener( GUIEvents.CHANGE_SMS_TYPE, onChangeSMSType );
			
		}
		
		protected function onChangeSMSType(event:Event):void
		{
			
			fetchIdleMess();
		}
		
		/**
		 *  Вычисляем невыбранные доступные сообщения и формируем список опций
		 * для комбобоксов
		 */
		public function fetchIdleMess():void
		{
			var len:int = cont.numChildren;
			var sett:Vector.<FSComboBox> = new Vector.<FSComboBox>();
			
			/// обнуляем и пересобираем здесь массив занятых ид сообщений, т.к. хранитель незнает 
			/// о моменте когда это можно сделать
			SmsVjsServant.busyIdsSmss = new Array();
			
			for (var i:int=1; i<len; i++) 
			{
					sett.push( ( cont.getChildAt( i  ) as OptSms_text_v ).getField( 0, 1 ) as FSComboBox );
					SmsVjsServant.registerBusySMS( sett[ i - 1 ].getCellInfo() );
					
			}
			
			
			var options:Array = [ "" ];
			len = sett.length;
			for (var j:int=0; j<len; j++) 
			{
				options = SmsVjsServant.getFreeSMS( sett[ j ].getCellInfo(), options.slice( 1 ) );
				sett[ j ].setList( options.slice() );
			}
			
			
			
			
		}
		
		override public function close():void
		{
			super.close();
			
			GUIEventDispatcher.getInstance().removeEventListener( GUIEvents.CHANGE_SMS_TYPE, onChangeSMSType );
			
		}
		
	}
}