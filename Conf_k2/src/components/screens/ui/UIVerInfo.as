package components.screens.ui
{
	import flash.events.TimerEvent;
	
	import components.abstract.LOC;
	import components.abstract.functions.loc;
	import components.abstract.servants.TaskManager;
	import components.basement.UI_BaseComponent;
	import components.gui.fields.FSShadow;
	import components.gui.fields.FormString;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.screens.opt.OptVerInfo;
	import components.static.CMD;
	import components.static.COLOR;
	import components.static.DS;
	import components.static.PAGE;
	
	public class UIVerInfo extends UI_BaseComponent
	{
		private var FLAG_ASK_BALANCE:Boolean = false;
		private var FLAG_SIMCARD_INITIALISED:Boolean = false;

		private var opt:OptVerInfo;
		public function UIVerInfo()
		{
			super();
			
			globalY = PAGE.CONTENT_TOP_SHIFT;
			//yshift = 0;
			FLAG_SAVABLE = false;
			createUIElement( new FormString, 0, loc("ui_verinfo_device_name"),null,1);
			attuneElement(250);
			createUIElement( new FormString, 0, loc("ui_verinfo_fw_ver"),null,1);
			attuneElement(250);
			createUIElement( new FormString, 0, loc( "ui_verinfo_memory_type" ) ,null,1);
			
			createUIElement( new FormString, 1, loc("ui_verinfo_conn_type"),null,1);
			attuneElement(250);
			createUIElement( new FormString, 1, loc("ui_verinfo_modem"),null,2);
			attuneElement(250);
			createUIElement( new FormString, 1, loc("ui_verinfo_modem_fw_ver"),null,3);
			attuneElement(250);
			createUIElement( new FormString, 1, loc("ui_verinfo_imei"),null,4);
			attuneElement(250);
			
			/**Команда VER_INFO
			 * Параметр 1 - Название прибора;
			 * Параметр 2 - Версия прошивки;
			 * Параметр 3 - Тип памяти;
			 * 
			 * Команда VER_INFO1 ( для приборов с двумя симкартами - две структуры )
			 * Параметр 1 - Тип соединения;
			 * Параметр 2 - Тип GSM модема;
			 * Параметр 3 - Версия прошивки модема;
			 * Параметр 4 - IMEI код;
			 * Параметр 5 - ID SIM карты;
			 * Параметр 6 - Сотовый оператор;*/
			
			globalY = PAGE.CONTENT_TOP_SHIFT;
			globalX = 280;
			var clr:uint = COLOR.GREEN_DARK;
			createUIElement( new FormString, CMD.VER_INFO, "",null,1);
			(getLastElement() as FormString).setTextColor( clr );
			createUIElement( new FormString, CMD.VER_INFO, "",null,2);
			(getLastElement() as FormString).setTextColor( clr );
			//createUIElement( new FSShadow, CMD.VER_INFO, "", null, 3 );
			createUIElement( new FormString, CMD.VER_INFO, "",null,3);
			(getLastElement() as FormString).setTextColor( clr );
			
			createUIElement( new FormString, CMD.VER_INFO1, "",null,1);
			(getLastElement() as FormString).setTextColor( clr );
			createUIElement( new FormString, CMD.VER_INFO1, "",null,2);
			(getLastElement() as FormString).setTextColor( clr );
			createUIElement( new FormString, CMD.VER_INFO1, "",null,3);
			(getLastElement() as FormString).setTextColor( clr );
			createUIElement( new FormString, CMD.VER_INFO1, "",null,4);
			attuneElement(200);
			(getLastElement() as FormString).setTextColor( clr );
			
			opt = new OptVerInfo(1);
			addChild( opt );
			opt.y = globalY;
			opt.x = PAGE.CONTENT_LEFT_SHIFT;
			
			width = 465;
			height = 285;
		}
		override public function open():void
		{
			super.open();
			
			RequestAssembler.getInstance().fireEvent( new Request(CMD.VER_INFO,process ));
			RequestAssembler.getInstance().fireEvent( new Request(CMD.VER_INFO1,process ));
			RequestAssembler.getInstance().fireEvent( new Request(CMD.BATTERY_LEVEL,process ));
			
			opt.reset();
		}
		private function process(p:Package):void
		{
			switch(p.cmd) {
				case CMD.VER_INFO:
					var vinfo:Array = p.data[0].slice();
					getField( CMD.VER_INFO,1 ).setCellInfo( DS.name );
					getField( CMD.VER_INFO,2 ).setCellInfo( vinfo[1] );
					getField( CMD.VER_INFO,3 ).setCellInfo( vinfo[2] );
					break;
				case CMD.VER_INFO1:
					var vinfo1:Array = p.data[0].slice();
					
					FLAG_SIMCARD_INITIALISED = Boolean((vinfo1[4] != loc("verinfo_no_sim") && vinfo1[5] != loc("verinfo_no_sim") ));
					
					getField( p.cmd,1 ).setCellInfo( vinfo1[0] );
					getField( p.cmd,2 ).setCellInfo( vinfo1[1] );
					getField( p.cmd,3 ).setCellInfo( vinfo1[2] );
					getField( p.cmd,4 ).setCellInfo( vinfo1[3] );
					if(  p.getParamString(5).toLowerCase() != "Нет SIM-карты".toLowerCase() ) {
						opt.reset();
						initSpamTimer( CMD.GSM_SIG_LEV,1,true,null,5000 );
						if (DS.alias != DS.K2M && LOC.language == LOC.RU)
							RequestAssembler.getInstance().fireEvent( new Request(CMD.USSD_BALANS,balans ));
					} else
						TaskManager.callLater( callVerInfoRequest, TaskManager.DELAY_5SEC );
					
					opt.putData( p );
					break;
				case CMD.BATTERY_LEVEL:
					
					loadComplete();
					break;
			}
		}
		private function balans(p:Package):void
		{
			switch( p.cmd ) {
				case CMD.USSD_BALANS:
					//	запрос баланса 0 - нет номера, 1 - авто, 2 - пользовательски
					if ( (p.getStructure()[0] == 1 || p.getStructure()[0] == 2) && LOC.language == LOC.RU )
						RequestAssembler.getInstance().fireEvent( new Request(CMD.USSD_FUNCT,balans,1,[1,1] ));
					break;
				case CMD.USSD_FUNCT:
					if (p.success)
						FLAG_ASK_BALANCE = true;
					else {
						if (p.data) {
							switch( p.getStructure()[0] ) {
								case 2:
									FLAG_ASK_BALANCE = true;
									break;
								case 3:
									RequestAssembler.getInstance().fireEvent( new Request(CMD.USSD_STRING,balans ));
								case 4:
									FLAG_ASK_BALANCE = false;
									opt.putData(p);
									break;
							}
						}
					}
					break;
				case CMD.USSD_STRING:
					opt.putData(p);
					break;
			}
		}
		private function callVerInfoRequest():void
		{
			RequestAssembler.getInstance().fireEvent( new Request(CMD.VER_INFO1,process ));
		}
		override protected function timerComplete( ev:TimerEvent ):void 
		{
			if (this.visible) {
				if (FLAG_SIMCARD_INITIALISED) {
					RequestAssembler.getInstance().fireEvent( new Request(CMD.GSM_SIG_LEV,processState ));
					if(FLAG_ASK_BALANCE)
						RequestAssembler.getInstance().fireEvent( new Request(CMD.USSD_FUNCT,balans ));
				} else
					callVerInfoRequest();
				
				RequestAssembler.getInstance().fireEvent( new Request(CMD.BATTERY_LEVEL,processState ));
			
				stateRequestTimer.reset();
				stateRequestTimer.start();
			}
		}
		override protected function processState(p:Package):void 
		{
			switch(p.cmd) {
				case CMD.GSM_SIG_LEV:
					opt.putState( p.getStructure(1) );
					break;
				case CMD.BATTERY_LEVEL:
					opt.putBattery( p.getStructure(1) );
					break;
			} 
		}
	}
}