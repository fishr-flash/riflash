package components.screens.ui
{
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import components.abstract.functions.loc;
	import components.basement.UI_BaseComponent;
	import components.gui.fields.FSComboBox;
	import components.gui.fields.FSSimple;
	import components.gui.triggers.TextButton;
	import components.gui.visual.Separator;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.protocol.statics.CLIENT;
	import components.static.CMD;
	import components.system.UTIL;
	
	/***********************************************
	 * 
	 * Редакция для 16го контакта, без 
	 * автоматической синхронизации с сервером NTP
	 * 
	 ***********************************************/
	
	public class UIDateBottom extends UI_BaseComponent
	{
		private var DO_STOP:int = 0x00;
		private var DO_SET_DATE_TO_BUFER_ONCE:int = 0x01;
		private var DO_GET_DATE_FROM_BUFER:int = 0x02;
		private var DO_UPDATE_BUFFER:int = 0x03;
		
		private var fsDeviceTime:FSSimple;
		private var fsLocalTime:FSSimple;
		private var bSyncro:TextButton;
		private var cbTimeZone:FSComboBox;
		
		private var PREPARE_TO_SYNCHONIZE:Boolean;
		
		private var gx:int = 10;
		
		private var sep:Separator;
		
		public function UIDateBottom()
		{
			super();
			
			globalY=-1;

			fsDeviceTime = new FSSimple;
			addChild( fsDeviceTime );
			fsDeviceTime.x = gx;
			fsDeviceTime.y = gx;
			fsDeviceTime.attune( FSSimple.F_CELL_NOTSELECTABLE | FSSimple.F_MULTYLINE );
			fsDeviceTime.setName( loc("ui_date_indevice") );
			fsDeviceTime.setWidth( 130 );
			fsDeviceTime.setCellWidth( 165 );
			
			fsLocalTime = new FSSimple;
			addChild( fsLocalTime );
			fsLocalTime.x = gx;
			fsLocalTime.y = fsDeviceTime.getHeight() + 10;
			fsLocalTime.attune( FSSimple.F_CELL_NOTSELECTABLE| FSSimple.F_MULTYLINE );
			fsLocalTime.setName( loc("ui_date_inlocal") );
			fsLocalTime.setCellWidth( 165 );
			fsLocalTime.setWidth( 130 );
			
			bSyncro = new TextButton;
			addChild( bSyncro );
			bSyncro.setUp( loc("ui_date_synchro"), synchronize );
			bSyncro.setFormat( true, 12, "center" );
			bSyncro.x = 320;
			bSyncro.y = 20;
			bSyncro.focusgroup = 0;
			
			globalY = fsLocalTime.getHeight() + fsLocalTime.y + 10;
		}
		override public function open():void
		{
			super.open();
			
			RequestAssembler.getInstance().fireEvent( new Request( CMD.DATE_TIME_FUNCT, put, 1,[DO_UPDATE_BUFFER]));
		}
		override public function close():void
		{
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
				
				loadComplete();
			} else {
				RequestAssembler.getInstance().fireEvent( new Request( CMD.DATE_TIME_FUNCT, put, 1,[DO_UPDATE_BUFFER]));
			}
		}
		override protected function processState(p:Package):void
		{
			super.processState(p);
			if (this.visible) {
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