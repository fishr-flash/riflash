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
	import components.gui.fields.FSShadow;
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
	import components.screens.opt.OptBatLevel;
	import components.static.CMD;
	import components.static.DS;
	import components.system.UTIL;
	
	public class UIGeneralOptionsK5 extends UI_BaseComponent
	{
		private var signals:Vector.<SIMSignal>;
		private var fsDeviceTime:FSSimple;
		private var fsLocalTime:FSSimple;
		private var gsmtask:ITask;
		private var clocktask:ITask;
		private var bImei:TextButton;
		private var btns:Vector.<TextButton>;
		private var optBatLevel:OptBatLevel;
		
		public function UIGeneralOptionsK5()
		{
			super();
			
			var w:int = 270;
			
			addui( new FSSimple, CMD.OBJECT, loc("options_objnum"), null, 1, null, "A-Fa-f0-9", 4 );
			attuneElement( w, 60 );
			getLastElement().setAdapter( new ObjectAdapter );
			addui(  new FSSimple, CMD.MASTER_CODE, loc("options_masterkey"),null,1,null,"0-9",4, new RegExp(RegExpCollection.COMPLETE_ATLEST4SYMBOL));
			if( DS.release < 13 && !DS.isfam( DS.K5AA, DS.K5A ) )getLastElement().setAdapter( new HexAdapter4 );
			attuneElement( w, 60 );
			
			drawSeparator();

			createbutton( loc("options_stop_device"), onStopDevice, globalX );
			createbutton( loc("options_restart_device"), onRebootDevice, globalX + 200 );
			globalY += 30;
			
			drawSeparator();
			
			addui( new FSShadow, CMD.K5_BIT_SWITCHES, "", null, 1 );
			addui( new FSShadow, CMD.K5_BIT_SWITCHES, "", null, 2 );
			addui( new FSShadow, CMD.K5_BIT_SWITCHES, "", null, 3 );
			
			signals = new Vector.<SIMSignal>(2);
			
			signals[0] = new SIMSignal;
			addChild( signals[0] );
			signals[0].x = globalX + 200;
			signals[0].y = globalY+2;
			
			createUIElement( new FormString, 0, loc("ui_gprs_signal_level") + " SIM 1",null,3);
			attuneElement( w );
			
			signals[1] = new SIMSignal;
			addChild( signals[1] );
			signals[1].x = globalX + 200;
			signals[1].y = globalY+2;
			
			createUIElement( new FormString, 0, loc("ui_gprs_signal_level") + " SIM 2",null,3);
			attuneElement( w );

			bImei = new TextButton;
			bImei.x = globalX + 200;
			bImei.y = globalY;
			bImei.setUp("", onClick );
			
			createUIElement( new FormString, 0, loc("options_modem_imei"),null,4);
			attuneElement( w );
			
			drawSeparator();
			
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
			
			// чтобы bImei был всегда выше всех
			addChild( bImei );
			
			globalY += 30;
			
			createbutton( loc("options_do_synchnize"), onSynch, globalX);
			
			globalY += 30;
			
			if( DS.isfam( DS.K5AA, DS.K5A ) )
			{
				optBatLevel = new OptBatLevel();
				this.addChild( optBatLevel );
				optBatLevel.x = globalX;
				optBatLevel.y = globalY;
			}
			
			starterCMD = [CMD.OBJECT, CMD.MASTER_CODE, CMD.VER_INFO1, CMD.DATE_TIME, CMD.GSM_SIG_LEV];
			
			if( DS.isfam( DS.K5AA, DS.K5A ) ) 
			{
				starterRefine( CMD.BATTERY_LEVEL, true );
				
			}
			
			manualResize();
		}
		override public function put(p:Package):void
		{
			switch(p.cmd) {
				case CMD.OBJECT:
				case CMD.MASTER_CODE:
					distribute(p.getStructure(), p.cmd);
					break;
				case CMD.VER_INFO1:
					bImei.setName( p.getStructure()[3] );
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
				
				case CMD.BATTERY_LEVEL:
					optBatLevel.putData( p );
					
					break;
			}
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
			if( DS.isfam( DS.K5AA, DS.K5A ) )RequestAssembler.getInstance().fireEvent( new Request(CMD.BATTERY_LEVEL,put));
		}
		private function requestTime():void
		{
			RequestAssembler.getInstance().fireEvent( new Request(CMD.DATE_TIME,put));
		}
		private function onStopDevice():void
		{
			btns[0].disabled = true;
			TaskManager.callLater( function():void {btns[0].disabled = false;}, TaskManager.DELAY_2SEC );
			RequestAssembler.getInstance().fireEvent( new Request(CMD.K5_STOP_PANEL,null,1,[1]));
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
		private function onClick():void
		{
			var a:Object = OPERATOR.dataModel.getData(CMD.VER_INFO1);
			var copy:String = String(OPERATOR.dataModel.getData(CMD.VER_INFO1)[0][3]);
			Clipboard.generalClipboard.clear();
			Clipboard.generalClipboard.setData(ClipboardFormats.TEXT_FORMAT, copy);
			
			Balloon.access().show("options_imei_copied", "\""+copy+"\" " +loc("options_in_buffer") );
		}
	}
	
	
}

import components.abstract.adapters.HexAdapter;
import components.system.UTIL;

class HexAdapter4 extends HexAdapter
{
	override public function adapt(value:Object):Object
	{
		return UTIL.fz( super.adapt(value),4);
	}
}
