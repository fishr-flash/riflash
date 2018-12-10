package components.screens.ui
{
	import components.abstract.functions.loc;
	import components.abstract.servants.TaskManager;
	import components.abstract.servants.WidgetMaster;
	import components.basement.UI_BaseComponent;
	import components.gui.Header;
	import components.interfaces.IWidget;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.protocol.statics.OPERATOR;
	import components.screens.opt.OptSensorButton;
	import components.screens.opt.OptSensorOutput;
	import components.screens.opt.OptSensorRoot;
	import components.screens.opt.OptSensorTamper;
	import components.screens.opt.OptSensorTemp;
	import components.screens.opt.OptSensorVoltage;
	import components.static.CMD;
	import components.system.UTIL;

	public class UISensors extends UI_BaseComponent implements IWidget
	{
		private var opts:Vector.<OptSensorRoot>;
		private var ready:Boolean = false;
		
		public function UISensors()
		{
			super();
		}
		override public function open():void
		{
			super.open();
			
			cached(CMD.CTRL_SENSOR_AVAILABLE,put);
			
			WidgetMaster.access().registerWidget( CMD.CTRL_VOLTAGE_SENSOR, this );
			WidgetMaster.access().registerWidget( CMD.CTRL_TAMPER_SENSOR, this );
			WidgetMaster.access().registerWidget( CMD.CTRL_TEMPERATURE_SENSOR, this );
			WidgetMaster.access().registerWidget( CMD.CTRL_KEY_SENSOR, this );
			WidgetMaster.access().registerWidget( CMD.CTRL_DOUT_SENSOR, this );
			
			request();
		}
		override public function close():void
		{
			super.close();
			
			WidgetMaster.access().unregisterWidget( CMD.CTRL_VOLTAGE_SENSOR );
			WidgetMaster.access().unregisterWidget( CMD.CTRL_TAMPER_SENSOR );
			WidgetMaster.access().unregisterWidget( CMD.CTRL_TEMPERATURE_SENSOR );
			WidgetMaster.access().unregisterWidget( CMD.CTRL_KEY_SENSOR );
			WidgetMaster.access().unregisterWidget( CMD.CTRL_DOUT_SENSOR );
			
			RequestAssembler.getInstance().fireEvent( new Request(CMD.CTRL_GET_SENSOR,put,1,[0]));
		}
		override public function put(p:Package):void
		{
			var len:int, i:int;
			switch(p.cmd) {
				case CMD.CTRL_SENSOR_AVAILABLE:
					if (!ready)
						init();
					break;
				case CMD.CTRL_GET_SENSOR:
					if (visible) {
						loadComplete();
						runTask(request,TaskManager.DELAY_2SEC*10);
					}
					break;
				case CMD.CTRL_VOLTAGE_SENSOR:
				case CMD.CTRL_TAMPER_SENSOR:
				case CMD.CTRL_TEMPERATURE_SENSOR:
				case CMD.CTRL_KEY_SENSOR:
				case CMD.CTRL_DOUT_SENSOR:
					if (opts) {
						len = opts.length;
						for (i=0; i<len; i++) {
							opts[i].putData(p);
						}
					}
				break;
			}
		}
		private function request():void
		{
			RequestAssembler.getInstance().fireEvent( new Request(CMD.CTRL_GET_SENSOR,put,1,[30]));	// 30 - требование по ТЗ
		}
		private function build(cls:Class, bit:int):void
		{
			var str:int;
			var opt:OptSensorRoot;
			for (var i:int=0; i<8; i++) {
				if( UTIL.isBit(i,bit) ) {
					opt = new cls(str+1,i);
					opts.push( opt );
					addChild( opt );
					opt.x = globalX;
					opt.y = globalY;
					globalY += 30;
					str++;
				}
			}
			globalY += 10;
		}
		private function init():void
		{
			ready = true;
			
			var sen:Array = OPERATOR.dataModel.getData(CMD.CTRL_SENSOR_AVAILABLE);
			
			opts = new Vector.<OptSensorRoot>;
			
			var len:int = sen.length;
			
			if (sen[0] && sen[0][0] > 0) {
				// Voltage
				var h:Header = new Header( [{label:loc("sensor_power_source"),xpos:globalX, width:200},
					{label:loc("sensor_state"), xpos:300, width:100},
					{label:loc("sensor_u"), xpos:500, width:150}
				], {size:11, border:false, align:"left"} );
				addChild( h );
				h.y = globalY;
				globalY += 30;
				
				build(OptSensorVoltage,sen[0][0]);
			}
			
			if (sen[1] && sen[1][0] > 0) {
				// Tamper
				h = new Header( [{label:loc("sensor_tamper_contact"),xpos:globalX, width:200},
					{label:loc("sensor_state"), xpos:300, width:100}
				], {size:11, border:false, align:"left"} );
				addChild( h );
				h.y = globalY;
				globalY += 30;
				
				build(OptSensorTamper,sen[1][0]);
			}
			
			if (sen[2] && sen[2][0] > 0) {
				// Temp
				h = new Header( [{label:loc("sensor_temp"),xpos:globalX, width:200},
					{label:loc("ui_temp_degree"), xpos:500, width:200}
				], {size:11, border:false, align:"left"} );
				addChild( h );
				h.y = globalY;
				globalY += 30;
				
				build(OptSensorTemp,sen[2][0]);
			}
			
			if (sen[3] && sen[3][0] > 0) {
				// Button
				h = new Header( [{label:loc("sensor_buttons"),xpos:globalX, width:200},
					{label:loc("sensor_state"), xpos:300, width:100}
				], {size:11, border:false, align:"left"} );
				addChild( h );
				h.y = globalY;
				globalY += 30;
				
				build(OptSensorButton,sen[3][0]);
			}
			
			if (sen[4] && sen[4][0] > 0) {
				// Relay
				h = new Header( [{label:loc("sensor_output_state"),xpos:globalX, width:200},
				], {size:11, border:false, align:"left"} );
				addChild( h );
				h.y = globalY;
				globalY += 30;
				
				build(OptSensorOutput,sen[4][0]);
			}
		}
	}
}