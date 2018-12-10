package components.screens.ui
{
	import flash.events.Event;
	
	import components.abstract.LOC;
	import components.abstract.RegExpCollection;
	import components.abstract.TimeZoneAdapter;
	import components.abstract.VoyagerBot;
	import components.abstract.functions.byteInterpreter;
	import components.abstract.functions.loc;
	import components.abstract.servants.SmsVjsServant;
	import components.basement.UI_BaseComponent;
	import components.gui.Header;
	import components.gui.OptList;
	import components.gui.fields.FSCheckBox;
	import components.gui.fields.FSComboBox;
	import components.gui.fields.FSSimple;
	import components.gui.fields.FormEmpty;
	import components.gui.fields.FormString;
	import components.gui.triggers.TextButton;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.protocol.statics.OPERATOR;
	import components.resources.Resources;
	import components.screens.opt.OptListSms;
	import components.screens.opt.OptSMSSchedule;
	import components.screens.opt.OptSms_text_v;
	import components.static.CMD;
	import components.system.SavePerformer;
	
	import su.fishr.utils.searcPropValueInArr;
	
	public class UIVSms extends UI_BaseComponent
	{
		private static var sheds:Vector.<OptSMSSchedule>;
		private static var lenSheds:int = 4;

		private var smsOpts:OptListSms;
		private var cbTimeZone:FSComboBox;
		
		public function UIVSms()
		{
			super();
			
			init();
		}
		
		private function init():void
		{
			var firstWidth:int = 400;
			var secondWidth:int = 150;
			
			
			addui( new FSSimple, CMD.VR_SMS_SETTINGS, loc( "ui_verinfo_device_name" ) + "(Eng.)", null, 1, null, "A-Z, a-z, 0-9, \\-,  _", 10 );
			attuneElement( firstWidth, secondWidth );
			
			
			addui( new FSSimple, CMD.VR_SMS_SETTINGS, loc( "notify_phone" ) + " 1", null, 2, null, "0-9+", 20, new RegExp( RegExpCollection.RE_TEL_NOREQUIRED )  );
			attuneElement( firstWidth, secondWidth );
			
			
			addui( new FSSimple, CMD.VR_SMS_SETTINGS, loc( "notify_phone" ) + " 2", null, 3 , null, "0-9+", 20, new RegExp( RegExpCollection.RE_TEL_NOREQUIRED )  );
			attuneElement( firstWidth, secondWidth );
			
			addui( new FSCheckBox(), CMD.VR_SMS_SETTINGS, loc("on_sms_to_roaming"), null, 4 );
			attuneElement( firstWidth, secondWidth );
			
			var list:Array =
			[
				{ data:0, label:loc("g_text" ) },
				{ data:1, label:loc("navi_map" ) + " " + loc( "g_yandex" ) },
				{ data:2, label:loc("navi_map" ) + " " + loc( "g_google" ) },
				{ data:3, label:loc("navi_map" ) + " " + "OSM" }
			];
			
			createUIElement( new FSComboBox, CMD.VR_SMS_SETTINGS, loc("send_coords_in_format"), null, 5, list );
			attuneElement(  firstWidth - 30, secondWidth + 30, FSComboBox.F_COMBOBOX_NOTEDITABLE );
			
			
			var shedsX:int = getLastElement().x;
			
			cbTimeZone = addui( new FSComboBox, CMD.TIME_ZONE, loc("g_timezone"),null,1, Resources.getUTCTimes( LOC.language ) ) as FSComboBox;
			attuneElement(200,350,FSComboBox.F_COMBOBOX_NOTEDITABLE );
			cbTimeZone.setUp( onTimeZone );
			cbTimeZone.x = globalX;
			
			FLAG_SAVABLE = false;
			
			drawSeparator( firstWidth + secondWidth + 30 );
			
			globalY -= 10;
			
			addui( new FormString(), 0, loc( "send_coords_shedule" ) + ":", null, 1 );
			attuneElement( firstWidth, NaN,  FormString.F_TEXT_BOLD | FormString.F_NOTSELECTABLE );
			
			
			
			FLAG_SAVABLE = true;
			
			
			sheds = new Vector.<OptSMSSchedule>();
			var timeZoneAdapter:TimeZoneAdapter = new TimeZoneAdapter();
			var shedsHgh:int = 33;
			var xplace:int = 400;
			for( var i:int = 1; i <= lenSheds; i++ )
			{
				sheds.push( new OptSMSSchedule( loc( "vem_schedule" ) + " " + i, i , 180,  400, timeZoneAdapter ) );
				addChild( sheds[ i - 1 ] );
				sheds[ i - 1 ].y = globalY;
				sheds[ i - 1 ].x = shedsX;
				sheds[ i - 1 ].addEventListener( Event.CHANGE, onChangeShedule );
				globalY += shedsHgh;
				
			}
			
			FLAG_SAVABLE = false;
			
			drawSeparator( firstWidth + secondWidth + 30 );
			
			
			
			
			
			
			
			addui( new FormString(), 0, loc( "send_sms_to_events" ), null, 1 );
			attuneElement( firstWidth, NaN,  FormString.F_TEXT_BOLD | FormString.F_NOTSELECTABLE );
			
			var revDefaults:TextButton = new TextButton;
			addChild( revDefaults );
			revDefaults.x = globalX;
			revDefaults.y = globalY;
			revDefaults.setUp( loc("g_revert_defaults"), revertDefaults );
			
			globalY += revDefaults.height;
			
			const header:Header = new Header
			(
				[
					{ label:loc( "his_event" ) + "\r", xpos:100, width:100 },  
					{ label:loc( "text_message" )+ "\r", xpos:370, width:150 },  
					{ label:loc( "sms_send_message" ), xpos:670, width:100 },
					{ label:loc( "send_location" ), xpos:750, width:250 }
				],
				{ "align":"center" }
			);
			
			header.y = globalY + 20;
			header.x = getLastElement().x;
			
			this.addChild( header );
			
			globalY += header.height + 30 + 30;
			
			FLAG_SAVABLE = true;
			
			
			smsOpts = new OptListSms();
			this.addChild( smsOpts );
			smsOpts.attune( CMD.VR_SMS_NOTIF, 0, OptList.PARAM_NO_BLOCK_SAVE | OptList.PARAM_V_SCROLLING_WHEN_NEEEDED );
			smsOpts.y = globalY;
			smsOpts.width = 1050;
			smsOpts.height = 400;
			
			manualResize();
			
			//send_geoloc
			//addui( new FSCheckBoxSimple, 0, loc( "send_geoloc" ), null, 1 );
			
			
			starterCMD = [ CMD.TIME_ZONE,  CMD.VR_SMS_SETTINGS, CMD.VR_SMS_SCHEDULE, CMD.VR_SMS_LOCATION_ENABLE, CMD.VR_SMS_NOTIF_LIST ];
		}
		
		private function onChangeShedule( evt:Event ):void
		{
			for( var i:int = 0; i < lenSheds; i++ )
				sheds[ i ].dispatchChange();
		
		}
		
		override public function open():void
		{
			super.open();
			
			

			VoyagerBot.TIME_ZONE = (new Date).timezoneOffset/60*-1;
			SavePerformer.trigger( {"cmd":refine } ) ;
			cbTimeZone.setCellInfo(VoyagerBot.TIME_ZONE);
		 
		}
		
		
		
		override public function put(p:Package):void
		{
			
			switch( p.cmd ) 
			{
				
				case CMD.VR_SMS_SETTINGS:
					
					pdistribute( p );
					
					break;
				
				case CMD.VR_SMS_SCHEDULE:
					
					
					for( var i:int = 0; i < lenSheds; i++ )
						sheds[ i ].putRawData( p.data[ i ] );
					
					
					
					break;
				
				
				case CMD.VR_SMS_NOTIF:
					
					
					smsOpts.put(  preparePackage( p ) , OptSms_text_v );
					
					smsOpts.putLocsEnb( editSmsLocation( p.data ) ); 
					
					
					loadComplete();
					
					break;
				
				case CMD.VR_SMS_NOTIF_LIST:
					
					SmsVjsServant.listIdsSmss = new Array();
					
					
					for ( var key:String in p.data )
					{
						
						excludeIds( int( key ), p.data[ key ] );
					}
					
					
					
						RequestAssembler.getInstance().fireEvent( new Request( CMD.VR_SMS_NOTIF, put, 0, null, 0 )  );	
					
					
					break;
				
				case CMD.TIME_ZONE:
				
					
					cbTimeZone.setCellInfo( byteInterpreter( p.getStructure()[0] ) );
					
					VoyagerBot.TIME_ZONE = int( getField( CMD.TIME_ZONE, 1 ).getCellInfo() );
					
					break;
				
				
				
			}
			
			
			
			
		}
		
		private function onTimeZone( formEmpty:FormEmpty ):void
		{
			VoyagerBot.changeTimeZone( int(cbTimeZone.getCellInfo()) );
			onChange();
			
			SavePerformer.remember( 1, cbTimeZone );
		}
		
		private function refine( value:Object ):Object
		{
			if(value is int) {
				if( value  == CMD.VR_SMS_SCHEDULE )
					return SavePerformer.CMD_TRIGGER_TRUE;
			} else {
				
				
				sheds[ value.struct - 1  ].adaptTimeZone( value );
				
				return SavePerformer.CMD_TRIGGER_CONTINUE;
			}
			return SavePerformer.CMD_TRIGGER_FALSE;
		}
		
		
		/// Извлекаем ид смс данных поддерживаемых прибором
		private function excludeIds( startIndex:int, bitMask:String ):void
		{
			
			
			const bdata:int = int( bitMask );
			var bmask:uint = 1;
			var id:int = 0;
			
			for (var j:int=0; j< 8; j++) 
			{
				id = bdata & ( bmask << j );
				
				
				
				
				if( id )
				{
					
					
					SmsVjsServant.listIdsSmss.push( j   +  ( startIndex * 8 ) );
					
					
					
				}
				
				
			}
			
			
			
			
			
		}
		
		private function preparePackage( p:Package ):Package
		{
			/// список настроек событий в приборе ( в нем могут быть укзаны настройки дл
			/// для событий которые этот прибор уже или еще не поддерживает
			var arrData:Array = p.data as Array ; 
			var oldData:Array = arrData.slice();
			
			//копия списка ид допустимых в приборе событий
			var tempArr:Array  = SmsVjsServant.listIdsSmss.slice();
			const maxLen:int = tempArr.length;
			
			
			
			/// просеиваем полученные записанные данные
			/// чтобы отделить ид уже использованные от тех
			/// которые можно использовать, но которые не записаны
			for (var j:int=0; j<arrData.length; j++) 
			{
				const inOf:int = tempArr.indexOf(  arrData[ j ][ 0 ] );
				
				
				if( inOf > -1 ) tempArr.splice( inOf, 1 );
				
				
				
				if( inOf == -1 && arrData[ j ][ 0 ] > 0)  {
					arrData.splice( j, 1 );
					--j;
				}
				
				
				
			}
			
			
			
			for (var i:int=0; i< oldData.length; i++) {

				if( !arrData[ i ] ) arrData[ i ] = [ 0, "", 0 ];
				
				if(  !arrData[ i ][ 0 ] )
				{
					
					if( tempArr.length ) arrData[ i ][ 0 ] = tempArr.shift();
					else
					{
						arrData[ i ] = [ 0, "", 0 ];
						
					}
					
				}
				
				if(  arrData[ i ] )arrData[ i ][ 3 ] =  arrData[ i ][ 0 ] != oldData[ i ][ 0 ];
				//else arrData[ i ] = [ 0, "", 0, true ];
			}
			
			
			
			return p;
		}
		
		private function editSmsLocation(arrData:Array):Package
		{
			var smsLocation:Array = OPERATOR.getData( CMD.VR_SMS_LOCATION_ENABLE );
			var newSmsLocation:Array = [];
			
			var len:int = arrData.length;
			var key:int = -1;
			for (var i:int=0; i<len; i++) {
				
				key = searcPropValueInArr( "0", arrData[ i ][ 0 ], smsLocation );
				
				if( key > -1 )
					newSmsLocation.push( [ arrData[ i ][ 0 ], smsLocation[ key ][ 1 ] ] );
				else
					newSmsLocation.push( [ arrData[ i ][ 0 ], 0 ] );
				
			}
			
			/// элементы измененные помечаем на необходимость сохранения
			len = newSmsLocation.length;
			var needRemember:Boolean = false;
			for (var j:int=0; j<len; j++) {
				
				needRemember = newSmsLocation[ j ][ 0 ] === smsLocation[ j ][ 0 ] && newSmsLocation[ j ][ 1 ] === smsLocation[ j ][ 1 ] ;
				
				
				newSmsLocation[ j ].push( !needRemember );
					
				
			}
			
			const p:Package = new Package();
			p.cmd = CMD.VR_SMS_LOCATION_ENABLE;
			p.data = newSmsLocation; 
			return p;	
		}
		
		private function onChange(e:Event=null):void
		{	
			// заставляет все поля расписания маркировать себя как измененные для сохранения
			for (var i:int=0; i<lenSheds; i++) 
			{
				sheds[ i ].dispatchChange();
			}
			
		}
		
		private function revertDefaults():void
		{
			smsOpts.revertDefault();
			
			
			
		}
	}
}