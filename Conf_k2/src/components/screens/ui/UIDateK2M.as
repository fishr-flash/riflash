package components.screens.ui
{
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import components.abstract.ClientArrays;
	import components.abstract.LOC;
	import components.abstract.RegExpCollection;
	import components.basement.UI_BaseComponent;
	import components.gui.fields.FSComboBox;
	import components.gui.fields.FSRadioGroup;
	import components.gui.fields.FSSimple;
	import components.gui.triggers.TextButton;
	import components.gui.visual.Separator;
	import components.interfaces.IFormString;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.protocol.statics.CLIENT;
	import components.static.CMD;
	import components.static.PAGE;
	import components.system.SavePerformer;
	import components.system.UTIL;
	
	/** Различия между К16RT в надписи GPRS и LAN	*/
	
	public class UIDateK2M extends UI_BaseComponent
	{
		private var DO_STOP:int = 0x00;
		private var DO_SET_DATE_TO_BUFER_ONCE:int = 0x01;
		private var DO_GET_DATE_FROM_BUFER:int = 0x02;
		private var DO_UPDATE_BUFFER:int = 0x03;
		
		private var fsDeviceTime:FSSimple;
		private var fsLocalTime:FSSimple;
		private var bSyncro:TextButton;
		private var fsNTP:FSSimple;
		private var cbTimeZone:FSComboBox;
		
		private var PREPARE_TO_SYNCHONIZE:Boolean;
		
		private var rgSynchro:FSRadioGroup;
		
		private var sep:Separator;
		private var sep2:Separator;
		
		public function UIDateK2M()
		{
			super();
			
			fsDeviceTime = new FSSimple;
			addChild( fsDeviceTime );
			fsDeviceTime.x = globalX;
			fsDeviceTime.y = PAGE.CONTENT_TOP_SHIFT + 5;
			fsDeviceTime.attune( FSSimple.F_CELL_NOTSELECTABLE | FSSimple.F_MULTYLINE );
			fsDeviceTime.setName( LOC.loc("ui_date_indevice") );
			fsDeviceTime.setWidth( 130 );
			fsDeviceTime.setCellWidth( 165 );
			
			fsLocalTime = new FSSimple;
			addChild( fsLocalTime );
			fsLocalTime.x = globalX;
			fsLocalTime.y = fsDeviceTime.getHeight() + 15;
			fsLocalTime.attune( FSSimple.F_CELL_NOTSELECTABLE| FSSimple.F_MULTYLINE );
			fsLocalTime.setName( LOC.loc("ui_date_inlocal") );
			fsLocalTime.setCellWidth( 165 );
			fsLocalTime.setWidth( 130 );
			
			bSyncro = new TextButton;
			addChild( bSyncro );
			bSyncro.setUp( LOC.loc("ui_date_synchro"), synchronize );
			bSyncro.setFormat( true, 12, "center" );
			bSyncro.x = 348;
			bSyncro.y = 25;
			bSyncro.focusgroup = 0;
			
			sep = new Separator( 535 );
			sep.x = PAGE.SEPARATOR_SHIFT;
			sep.y = fsLocalTime.getHeight() + fsLocalTime.y;
			addChild( sep );
			
			/**	Параметр 1 - Время синхронизации: 
			 * 		0x00 - Запретить синхронизацию даты и времени, 
			 * 		0x01 - Синхронизация при автотесте, 
			 * 		0x02 - Синхронизация один раз в неделю, 
			 * 		0x03 - Синхронизация один раз в месяц;
				Параметр 2 - Вид синхронизации: 
				 * 0x01 - Синхронизировать дату и время с сервером приема тревожных событий, 
				 * 0x02 - Синхронизировать дату и время с сервером точного времени NTP. */

			globalY = sep.y + 20;
			createUIElement( new FSComboBox, CMD.TIME_SYNCH, LOC.loc("ui_date_syncho_with_server"),
				callSych,1, [{label:LOC.loc("g_never"),data:0},{label:LOC.loc("ui_date_onautotest"),data:1},{label:LOC.loc("ui_date_once_week"),data:2},{label:LOC.loc("ui_date_once_month"),data:3}] );
			attuneElement( 355, 140, FSComboBox.F_COMBOBOX_NOTEDITABLE );
			
			rgSynchro = new FSRadioGroup( [ {label:LOC.loc("ui_date_get_fromalarmserver"), selected:false, id:0x01 },
											{label:LOC.loc("ui_date_get_fromntp"), selected:true, id:0x02 }], 1 );
			addChild( rgSynchro );
			rgSynchro.x = globalX;
			rgSynchro.y = sep.y + 60;
			rgSynchro.width = 395 + PAGE.FS_RGBUTTON_SHIFT;;
			
			sep2 = new Separator( 535 );
			sep2.x = PAGE.SEPARATOR_SHIFT;
			sep2.y = rgSynchro.y + rgSynchro.height;
			addChild( sep2 );
			
			addUIElement( rgSynchro, CMD.TIME_SYNCH,2, onAction);
			
			fsNTP = createUIElement( new FSSimple, CMD.SERVER_NTP, LOC.loc("ui_date_server_ntp"),null,1,null,"",30, new RegExp( "^"+RegExpCollection.RE_DOMEN + "$")) as FSSimple;
			attuneElement(274,220);
			fsNTP.x = globalX;
			fsNTP.y = sep2.y + 10;
			
			cbTimeZone = createUIElement( new FSComboBox, CMD.TIME_ZONE, LOC.loc("g_timezone"),null,1,ClientArrays.aTimeZones) as FSComboBox;
			attuneElement(274,220,FSComboBox.F_COMBOBOX_NOTEDITABLE );
			cbTimeZone.x = globalX;
			cbTimeZone.y = fsNTP.getHeight() + fsNTP.y + 10;
			
			width = 560;
			height = 315;
		}
		override public function open():void
		{
			super.open();
			
			RequestAssembler.getInstance().fireEvent( new Request( CMD.DATE_TIME_FUNCT, put, 1,[DO_UPDATE_BUFFER]));
			
			rgSynchro.disabled = true;
			fsNTP.disabled = true;
			cbTimeZone.disabled = true;
			
			rgSynchro.visible = true;
			fsNTP.visible = true;
			sep2.visible = true;
			
			cbTimeZone.y = fsNTP.getHeight() + fsNTP.y + 10;

			RequestAssembler.getInstance().fireEvent( new Request( CMD.TIME_ZONE, processDate ));
			RequestAssembler.getInstance().fireEvent( new Request( CMD.SERVER_NTP, processDate ));
			RequestAssembler.getInstance().fireEvent( new Request( CMD.TIME_SYNCH, processDate ));
		}
		override public function close():void
		{
			if(!this.visible) return;
			super.close();
			RequestAssembler.getInstance().fireEvent( new Request( CMD.DATE_TIME_FUNCT, null, 1,[DO_STOP]));
			PREPARE_TO_SYNCHONIZE = false;
		}
		override public function put(p:Package):void
		{
			if ( p.success) {
				RequestAssembler.getInstance().fireEvent( new Request( CMD.DATE_TIME_STATE, processState ));
				
				if (!stateRequestTimer)
					stateRequestTimer = new Timer( CLIENT.TIMER_EVENT_DATE_SPAM, 1);
				stateRequestTimer.addEventListener( TimerEvent.TIMER_COMPLETE, timerComplete );
				stateRequestTimer.reset();
				stateRequestTimer.start();
			} else {
				RequestAssembler.getInstance().fireEvent( new Request( CMD.DATE_TIME_FUNCT, put, 1,[DO_UPDATE_BUFFER]));
			}
		}
		override protected function processState(p:Package):void
		{
			super.processState(p);
			var date:Date;
			switch( p.cmd ) {
				case CMD.DATE_TIME:
					date = new Date;
					var formattedDate:String  = UTIL.formateZerosInFront( String(date.getDate()),2 )+"."
						+UTIL.formateZerosInFront( String(int(date.getMonth()+1)),2 )+"."
						+date.getFullYear()+"      "
						+UTIL.formateZerosInFront( String(date.getHours()),2)+":"
						+UTIL.formateZerosInFront( String(date.getMinutes()),2)+":"
						+UTIL.formateZerosInFront( String(date.getSeconds()),2);
					fsLocalTime.setCellInfo( formattedDate );
					
					fsDeviceTime.setCellInfo( UTIL.formateZerosInFront( String(p.getStructure()[0]),2 )
						+"."+UTIL.formateZerosInFront( String(p.getStructure()[1]),2)
						+".20"+UTIL.formateZerosInFront( String(p.getStructure()[2]),2 )+ "      "
						+UTIL.formateZerosInFront( String(p.getStructure()[3]),2)+":"
						+UTIL.formateZerosInFront( String(p.getStructure()[4]),2)+":"
						+UTIL.formateZerosInFront( String(p.getStructure()[5]),2) );
					break;
				case CMD.DATE_TIME_STATE:
					switch( p.getStructure()[0] ) {
						case DO_STOP:
							if ( PREPARE_TO_SYNCHONIZE ) {
								date = new Date;
								var day:int = date.day;
								if ( day == 0 )
									day = 7;
								var year:String = String(date.getFullYear()).slice(2);
								
								var aDate:Array = [ date.getDate(), date.getMonth()+1, int(year), date.getHours(), date.getMinutes(), date.getSeconds(), date.day ];
								RequestAssembler.getInstance().fireEvent( new Request( CMD.DATE_TIME, null, 1,aDate));
								RequestAssembler.getInstance().fireEvent( new Request( CMD.DATE_TIME_FUNCT, put, 1,[DO_GET_DATE_FROM_BUFER]));
							}
							break;
						case DO_GET_DATE_FROM_BUFER:
							RequestAssembler.getInstance().fireEvent( new Request( CMD.DATE_TIME_FUNCT, put, 1,[DO_UPDATE_BUFFER]));
							break;
						case DO_UPDATE_BUFFER:
							RequestAssembler.getInstance().fireEvent( new Request( CMD.DATE_TIME, processState ));
							break;
					}
					break;
			}
		}
		private function onAction(t:IFormString=null):void
		{
			var b:Boolean = Boolean(int(rgSynchro.getCellInfo()) != 2);
			fsNTP.disabled = b;
			cbTimeZone.disabled = b;
			if (t)
				SavePerformer.remember(getStructure(), t);
		}
		private function processDate( p:Package):void
		{
			switch( p.cmd ) {
				case CMD.TIME_ZONE:
					cbTimeZone.setCellInfo( p.getStructure()[0] );
					break;
				case CMD.SERVER_NTP:
					if (p.data.length > 0)
						fsNTP.setCellInfo( p.getStructure()[0] );
					break;
				case CMD.TIME_SYNCH:
					distribute( p.getStructure(), p.cmd );
					doBlock(Boolean(p.getStructure()[0] == 0 ));
					loadComplete();
					break;
			}
		}
		private function callSych(t:IFormString):void
		{
			doBlock(Boolean(int(t.getCellInfo()) == 0 ));
			SavePerformer.remember(1,t);
		}
		private function doBlock(b:Boolean):void
		{
			var ntpblocked:Boolean = Boolean(int(rgSynchro.getCellInfo()) != 2);
			var s:Boolean = fsNTP.disabled;
			rgSynchro.disabled = b;
			fsNTP.disabled = b || ntpblocked;
			cbTimeZone.disabled = b || ntpblocked;
		}
		private function synchronize():void 
		{
			PREPARE_TO_SYNCHONIZE = true;
			RequestAssembler.getInstance().fireEvent( new Request( CMD.DATE_TIME_FUNCT, null, 1,[DO_STOP]));
		}
		override protected function timerComplete( ev:TimerEvent ):void 
		{
			if (this.visible) {
				RequestAssembler.getInstance().fireEvent( new Request( CMD.DATE_TIME_STATE, processState ));
				
				stateRequestTimer.reset();
				stateRequestTimer.start();
			}
		}
	}
}
//290