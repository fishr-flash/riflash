package components.screens.ui
{
	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	
	import components.abstract.RegExpCollection;
	import components.abstract.adapters.HexAdapter;
	import components.abstract.adapters.ObjectAdapter;
	import components.abstract.functions.loc;
	import components.abstract.servants.TaskManager;
	import components.basement.UI_BaseComponent;
	import components.gui.Balloon;
	import components.gui.PopUp;
	import components.gui.fields.FSButton;
	import components.gui.fields.FSComboBox;
	import components.gui.fields.FSRadioGroup;
	import components.gui.fields.FSSimple;
	import components.gui.fields.FormString;
	import components.gui.triggers.TextButton;
	import components.gui.visual.SIMSignal;
	import components.interfaces.ITask;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.protocol.SocketProcessor;
	import components.protocol.statics.OPERATOR;
	import components.static.CMD;
	import components.static.DS;
	import components.system.UTIL;
	
	public class UIGeneralOptionsRT1 extends UI_BaseComponent
	{
		private var btns:Vector.<TextButton>;
		private var signals:Vector.<SIMSignal>;
		
		private var fsDeviceTime:FSSimple;
		private var fsLocalTime:FSSimple;
		private var gsmtask:ITask;
		private var clocktask:ITask;
		
		public function UIGeneralOptionsRT1()
		{
			super();
			
			
			var cmds:Array = new Array();
			
			var w:int = 450;
			var sepw:int = 550;
			const cellw:int = 70;
			addui( new FSSimple, CMD.OBJECT, loc("options_objnum"), null, 1, null, "A-Fa-f0-9", 4, new RegExp(RegExpCollection.COMPLETE_ATLEST1SYMBOL) );
			attuneElement( w, cellw );
			getLastElement().setAdapter( new ObjectAdapter );
			
			cmds.push( CMD.OBJECT );
			
			addui(  new FSSimple, CMD.MASTER_CODE, loc("g_mastercode_ext"),null,1,null,"0-9",4, new RegExp(RegExpCollection.COMPLETE_ATLEST4SYMBOL));
			attuneElement( w, cellw );
			getLastElement().setAdapter( new HexAdapterNZerro);
			
			cmds.push( CMD.MASTER_CODE );
			
			
			
			globalY -= 1;
			createbutton( loc("options_restart_device"), onRebootDevice, globalX );
			globalY += 33;
			
			drawSeparator(sepw);
			
			if( DS.alias == DS.K5RT1 || DS.isDevice(DS.K5RT13G) || DS.isDevice(DS.K5RT33G) || DS.alias == DS.K5RT1L )
			{
				addui( new FormString, 0, loc("tel_emulator_handshake"), null, 1 );
				attuneElement( w );
				
				var l:Array = UTIL.getComboBoxList([[50,"50"], [100,"100"], [150,"150"], [200,"200"], [250,"250"]]);
				
				addui( new FSComboBox, CMD.K5RT_EMULATOR_HS, loc("tel_emulator_handshake_1400"), null, 2, l, "0-9", 3, new RegExp(RegExpCollection.REF_50to250) );
				attuneElement( w, cellw );
				addui( new FSComboBox, CMD.K5RT_EMULATOR_HS, loc("tel_emulator_handshake_pause"), null, 3, l, "0-9", 3, new RegExp(RegExpCollection.REF_50to250) );
				attuneElement( w, cellw );
				addui( new FSComboBox, CMD.K5RT_EMULATOR_HS, loc("tel_emulator_handshake_2300"), null, 4, l, "0-9", 3, new RegExp(RegExpCollection.REF_50to250) );
				attuneElement( w, cellw );
				l = UTIL.comboBoxNumericDataGenerator(3,10);
				addui( new FSComboBox, CMD.K5RT_EMULATOR_HS, loc("tel_emulator_handshake_pause_sec"), null, 1, l, "0-9", 2, new RegExp(RegExpCollection.REF_3to10) );
				attuneElement( w, cellw, FSComboBox.F_COMBOBOX_NOTEDITABLE );
				
				drawSeparator(sepw);
				
				cmds.push( CMD.K5RT_EMULATOR_HS );
			}
			
			
			const locTextI:String =  ( DS.isDevice( DS.K5RT3L ) == false )?"tel_voice_cid_standart":"tel_voice_cid_standart_lite";
			const locTextII:String =  ( DS.isDevice( DS.K5RT3L ) == false )?"tel_voice_cid_slowed":"tel_voice_cid_slowed_lite";
			
			if( !DS.isDevice( DS.K5RT13G ) && !DS.isDevice( DS.K5RT1L ))
			{
				FLAG_SAVABLE = false;
				
				const head:FormString = addui( new FormString, 0, loc( "tel_voice_cid" ), null, 0 ) as FormString;
				head.setWidth( 400 );
				
				globalY+=3+10;
				
				FLAG_SAVABLE = true;
				
				var fsRgroup:FSRadioGroup = new FSRadioGroup( [ {label:loc(locTextI), selected:false, id:0 },
					{label:loc(locTextII), selected:false, id:1 }], 1, 40 );
				fsRgroup.y = globalY;
				fsRgroup.x = globalX;
				fsRgroup.width = 700-203;
				addChild( fsRgroup );
				addUIElement( fsRgroup, CMD.K5RT_SLOW_DTMF, 1);
				
				globalY += fsRgroup.getHeight();
				cmds.push( CMD.K5RT_SLOW_DTMF );
				
				drawSeparator(sepw);
				
			}
			
			
			
			
			
			
			signals = new Vector.<SIMSignal>(2);
			
			signals[0] = new SIMSignal;
			addChild( signals[0] );
			signals[0].x = globalX + 350;
			signals[0].y = globalY+2;
			
			createUIElement( new FormString, 0, loc("ui_gprs_signal_level") + " SIM 1",null,2);
			attuneElement( w );
			
			signals[1] = new SIMSignal;
			addChild( signals[1] );
			signals[1].x = globalX + 350;
			signals[1].y = globalY+2;
			
			createUIElement( new FormString, 0, loc("ui_gprs_signal_level") + " SIM 2",null,3);
			attuneElement( w );
			
			drawSeparator(sepw);
			
			addui( new FSButton, 0, loc("options_modem_imei"), onClick, 4 );
			attuneElement( w );
			
			drawSeparator(sepw);
			
			fsDeviceTime = new FSSimple;
			addChild( fsDeviceTime );
			fsDeviceTime.x = globalX;
			fsDeviceTime.y = globalY;
			fsDeviceTime.attune( FSSimple.F_CELL_NOTSELECTABLE | FSSimple.F_MULTYLINE );
			fsDeviceTime.setName( loc("ui_date_indevice") );
			fsDeviceTime.setWidth( 130 );
			fsDeviceTime.setCellWidth( 165 );
			
			globalY += 30;
			
			fsLocalTime = new FSSimple;
			addChild( fsLocalTime );
			fsLocalTime.x = globalX;
			fsLocalTime.y = globalY;
			fsLocalTime.attune( FSSimple.F_CELL_NOTSELECTABLE| FSSimple.F_MULTYLINE );
			fsLocalTime.setName( loc("ui_date_inlocal") );
			fsLocalTime.setCellWidth( 165 );
			fsLocalTime.setWidth( 130 );
			
			globalY += 30;
			
			cmds.push( CMD.DATE_TIME );
			
			createbutton( loc("options_do_synchnize"), onSynch, globalX);
			
			globalY += 30;
			
			if( DS.alias != DS.K5RT3L && DS.alias != DS.K5RT1L )
			{
				drawSeparator(sepw);
				
				addui( new FormString, 0, loc("output_test_both"), null, 1 );
				
				createbutton( loc("output_switch_on_both"), onSwitchOn, globalX);
				globalY += 30;
				createbutton( loc("output_switch_off_both"), onSwitchOff, globalX);
			}
			
			
			height = 670;
			
			//if( CONST.DEBUG ) createbutton( loc("options_stop_device"), onStopDevice, globalX + 200 );
			
			cmds.push( CMD.VER_INFO1 );
			if( !DS.isDevice( DS.K5RT3L ) && !DS.isDevice( DS.K5RT1L ) ) cmds.push( CMD.K5_OUT_DRIVE );
			
			cmds.push( CMD.GSM_SIG_LEV );
			//cmds.push( CMD.K5_STOP_PANEL );
			
			starterCMD = cmds;
			
			manualResize();
		}
		override public function put(p:Package):void
		{
			switch(p.cmd) {
				case CMD.OBJECT:
				case CMD.MASTER_CODE:
				case CMD.K5RT_EMULATOR_HS:
				case CMD.K5RT_SLOW_DTMF:
					//distribute(p.getStructure(), p.cmd);
					pdistribute(p);
					break;
				case CMD.K5_OUT_DRIVE:
					
					if( DS.isfam( DS.K5RT3, DS.K5RT3L ) || DS.isfam( DS.K5RT1, DS.K5RT1L ))
					{
						btns[2].disabled = p.getParamInt(1) == 1;
						btns[3].disabled = p.getParamInt(1) == 0;
					}
					
					break;
				case CMD.VER_INFO1:
					getField(0,4).setCellInfo(p.getStructure()[3] );
					loadComplete();
					break;
				case CMD.DATE_TIME:
					if (p.success) {
						RequestAssembler.getInstance().fireEvent( new Request(CMD.DATE_TIME,put));
					} else {
						var date:Date = new Date;
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
						
						onClock();
					}
					break;
				case CMD.GSM_SIG_LEV:
					signals[0].put( int(p.getParam(1,1)));
					signals[1].put( int(p.getParam(1,2)));
					if (this.visible) {
						if (!gsmtask)
							gsmtask = TaskManager.callLater(requestSignal,TaskManager.DELAY_2SEC*2);
						else
							gsmtask.repeat();
					}
					break;
			}
		}
		private function createbutton(name:String, delegate:Function, xpos:int):void
		{
			if (!btns)
				btns = new Vector.<TextButton>;
			var b:TextButton = new TextButton;
			addChild( b );
			b.y = globalY;
			b.x = xpos;
			b.setUp( name, delegate );
			btns.push( b );
		}
		private function onRebootDevice():void
		{
			RequestAssembler.getInstance().fireEvent( new Request(CMD.REBOOT,onReboot,1,[1]));
			loadStart();
			blockNaviSilent = true;
		}
		private function onReboot(p:Package):void
		{
			popup = PopUp.getInstance();
			popup.composeOfflineMessage( PopUp.wrapHeader("sys_attention"),	PopUp.wrapMessage("sys_k5_final_disconnect") );
			SocketProcessor.getInstance().disconnectFinal();
		}
		private function onClick():void
		{
			var a:Object = OPERATOR.dataModel.getData(CMD.VER_INFO1);
			var copy:String = String(OPERATOR.dataModel.getData(CMD.VER_INFO1)[0][3]);
			Clipboard.generalClipboard.clear();
			Clipboard.generalClipboard.setData(ClipboardFormats.TEXT_FORMAT, copy);
			
			Balloon.access().show("options_imei_copied", "\""+copy+"\" " +loc("options_in_buffer") );
		}
		
		/// для остановки мусора с девайса
		private function onStopDevice():void
		{
			btns[0].disabled = true;
			TaskManager.callLater( function():void {btns[0].disabled = false;}, TaskManager.DELAY_2SEC );
			RequestAssembler.getInstance().fireEvent( new Request(CMD.K5_STOP_PANEL,null,1,[1]));
		}
		
		private function onSynch():void
		{
			var d:Date = new Date;
			RequestAssembler.getInstance().fireEvent( new Request(CMD.DATE_TIME,put,1,[d.date, d.month+1, int(String(d.getFullYear()).slice(2)), d.hours, d.minutes, d.seconds, getDay() ]));
			function getDay():int
			{
				if( d.day == 7 )
					return 1;
				return d.day + 1;
			}
		}
		private function requestSignal():void
		{
			RequestAssembler.getInstance().fireEvent( new Request(CMD.GSM_SIG_LEV,put));
		}
		private function requestTime():void
		{
			RequestAssembler.getInstance().fireEvent( new Request(CMD.DATE_TIME,put));
		}
		private function onClock():void
		{
			if (!clocktask)
				TaskManager.callLater( onClock, TaskManager.DELAY_1SEC );
			else
				clocktask.repeat();
			
			var date:Date = new Date;
			var formattedDate:String  = UTIL.formateZerosInFront( String(date.getDate()),2 )+"."
				+UTIL.formateZerosInFront( String(int(date.getMonth()+1)),2 )+"."
				+date.getFullYear()+"      "
				+UTIL.formateZerosInFront( String(date.getHours()),2)+":"
				+UTIL.formateZerosInFront( String(date.getMinutes()),2)+":"
				+UTIL.formateZerosInFront( String(date.getSeconds()),2);
			fsLocalTime.setCellInfo( formattedDate );
		}
		private function onSwitchOn():void
		{
			RequestAssembler.getInstance().fireEvent( new Request( CMD.K5_OUT_DRIVE, null, 1, [1] ));
			RequestAssembler.getInstance().fireEvent( new Request( CMD.K5_OUT_DRIVE, null, 2, [1] ));
			
			RequestAssembler.getInstance().fireEvent( new Request( CMD.K5_OUT_DRIVE, put ));
		}
		private function onSwitchOff():void
		{
			RequestAssembler.getInstance().fireEvent( new Request( CMD.K5_OUT_DRIVE, null, 1, [0] ));
			RequestAssembler.getInstance().fireEvent( new Request( CMD.K5_OUT_DRIVE, null, 2, [0] ));
			
			RequestAssembler.getInstance().fireEvent( new Request( CMD.K5_OUT_DRIVE, put ));
		}
		override public function close():void
		{
			super.close();
			btns[0].disabled = false;
			if (gsmtask)
				gsmtask.kill();
			gsmtask = null;
			if (clocktask)
				clocktask.kill();
			clocktask = null;
		}
	}
}


import components.interfaces.IDataAdapter;
import components.interfaces.IFormString;
import components.system.UTIL;

class HexAdapterNZerro implements IDataAdapter
{
	public function change(value:Object):Object
	{
		return value;
	}
	
	public function adapt(value:Object):Object
	{
		const dec:String = int(value).toString(16).toUpperCase(); 
		return UTIL.formateZerosInFront( dec, 4 );
	}
	
	public function recover(value:Object):Object
	{
		return int("0x"+value);
	}
	
	public function perform(field:IFormString):void
	{
	}
}