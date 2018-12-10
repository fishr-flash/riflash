package components.screens.ui
{
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import components.abstract.ClientArrays;
	import components.abstract.LOC;
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
	import components.resources.Resources;
	import components.static.CMD;
	import components.static.DS;
	import components.static.PAGE;
	import components.system.UTIL;
	
	import su.fishr.utils.Dumper;
	
	/** Различия между К16RT в надписи GPRS и LAN	*/
	
	public class UIDate extends UI_BaseComponent
	{
		private var DO_STOP:int = 0x00;
		private var DO_SET_DATE_TO_BUFER_ONCE:int = 0x01;
		private var DO_GET_DATE_FROM_BUFER:int = 0x02;
		private var DO_UPDATE_BUFFER:int = 0x03;
		
		private var fsDeviceTime:FSSimple;
		private var fsLocalTime:FSSimple;
		private var bSyncro:TextButton;
		
		private var PREPARE_TO_SYNCHONIZE:Boolean;
		
		private var sep:Separator;

		

		
		
		public function UIDate()
		{
			super();
			
			fsDeviceTime = new FSSimple;
			addChild( fsDeviceTime );
			fsDeviceTime.x = globalX;
			fsDeviceTime.y = PAGE.CONTENT_TOP_SHIFT + 5;
			fsDeviceTime.attune( FSSimple.F_CELL_NOTSELECTABLE | FSSimple.F_MULTYLINE );
			fsDeviceTime.setName( loc("ui_date_indevice") );
			fsDeviceTime.setWidth( 130 );
			fsDeviceTime.setCellWidth( 165 );
			
			fsLocalTime = new FSSimple;
			addChild( fsLocalTime );
			fsLocalTime.x = globalX;
			fsLocalTime.y = fsDeviceTime.getHeight() + 15;
			fsLocalTime.attune( FSSimple.F_CELL_NOTSELECTABLE| FSSimple.F_MULTYLINE );
			fsLocalTime.setName( loc("ui_date_inlocal") );
			fsLocalTime.setCellWidth( 165 );
			fsLocalTime.setWidth( 130 );
			
			bSyncro = new TextButton;
			addChild( bSyncro );
			bSyncro.setUp( loc("ui_date_synchro"), synchronize );
			bSyncro.setFormat( true, 12, "center" );
			bSyncro.x = 348;
			bSyncro.y = 25;
			
			sep = new Separator( 750 );
			sep.x = PAGE.SEPARATOR_SHIFT;
			sep.y = fsLocalTime.getHeight() + fsLocalTime.y;
			addChild( sep );
			
			/*if( DEVICES.alias == DEVICES.VL2 || 
				DEVICES.alias == DEVICES.V2 || 
				DEVICES.alias == DEVICES.VL3 || 
				DEVICES.alias == DEVICES.V3 || 
				DEVICES.alias == DEVICES.V4 ||
				DEVICES.alias == DEVICES.V6 &&
				DEVICES.release >= 46 )*/
			
			
			
			
			
			
			width = 560;
			height = 315;
			
			
		}
		override public function open():void
		{
			super.open();
			loadComplete();
			
			RequestAssembler.getInstance().fireEvent( new Request( CMD.DATE_TIME_FUNCT, put, 1,[DO_UPDATE_BUFFER]));
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
			var year:String;
			super.processState(p);
			if (this.visible) {
				var date:Date;
				switch( p.cmd ) {
					case CMD.DATE_TIME:
						date = new Date;
						var gmtshift:int = UTIL.mod(date.getTimezoneOffset()/60);
						year = p.getStructure()[2] >= 70 ? ".19":".20";
						
						var formattedDate:String  = UTIL.formateZerosInFront( String(date.getDate()),2 )+"."
							+UTIL.formateZerosInFront( String(int(date.getMonth()+1)),2 )+"."
							+date.getFullYear()+"      "
							+UTIL.formateZerosInFront( String(date.getHours()),2)+":"
							+UTIL.formateZerosInFront( String(date.getMinutes()),2)+":"
							+UTIL.formateZerosInFront( String(date.getSeconds()),2);
						fsLocalTime.setCellInfo( formattedDate );
						
						var devicedate:Date = new Date;
						devicedate.setUTCFullYear( p.getStructure()[2], p.getStructure()[1]-1, p.getStructure()[0] );
						devicedate.setUTCHours( p.getStructure()[3], p.getStructure()[4], p.getStructure()[5] );
						
						fsDeviceTime.setCellInfo( 
							UTIL.formateZerosInFront( String( devicedate.getDate() ),2 )
							+"."+UTIL.formateZerosInFront( String( devicedate.getMonth()+1),2)
							+year+UTIL.formateZerosInFront( String( devicedate.getFullYear() ),2 )+ "      "
							+UTIL.formateZerosInFront( String(devicedate.getHours() ),2)+":"
							+UTIL.formateZerosInFront( String(devicedate.getMinutes() ),2)+":"
							+UTIL.formateZerosInFront( String(devicedate.getSeconds() ),2) )
						
						break;
					case CMD.DATE_TIME_STATE:
						switch( p.getStructure()[0] ) {
							case DO_STOP:
								if ( PREPARE_TO_SYNCHONIZE ) {
									date = new Date;
									var day:int = date.getUTCDay();
									if ( day == 0 )
										day = 7;
									year = String(date.getUTCFullYear()).slice(2);
									
									var aDate:Array = [ date.getUTCDate(), date.getUTCMonth()+1, int(year), date.getUTCHours(), date.getUTCMinutes(), date.getUTCSeconds(), date.day ];
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