package components.screens.ui
{
	import flash.geom.Point;
	
	import components.abstract.DragableLimitsAdv;
	import components.abstract.functions.loc;
	import components.abstract.servants.TaskManager;
	import components.abstract.servants.adapter.BooleanColorAdapter;
	import components.abstract.servants.adapter.VoltageAdapter;
	import components.basement.UI_BaseComponent;
	import components.gui.fields.FSCheckBox;
	import components.gui.fields.FSShadow;
	import components.gui.fields.FSSimple;
	import components.gui.limits.VectorScreenAdv;
	import components.interfaces.IFormString;
	import components.interfaces.ITask;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.protocol.statics.OPERATOR;
	import components.static.CMD;
	import components.static.COLOR;
	import components.system.UTIL;
	
	public class UIDevicePowerOld extends UI_BaseComponent
	{
		private var vscreen:VectorScreenAdv;
		private var dlimits:DragableLimitsAdv;
		private var dlimitsGuided:DragableLimitsAdv;
		private var task:ITask;
		private var p:Point;
		private var adapter:InputVoltageAdapter;
		
		public function UIDevicePowerOld()
		{
			super();
			
			var shift:int = 450+90;
			
			
			
			
			addui( new FSSimple, CMD.VOLTAGE_SENSOR, loc("power_instant_u"), null, 1 );
			attuneElement( shift, 60, FSSimple.F_CELL_NOTSELECTABLE | FSSimple.F_CELL_ALIGN_RIGHT );
			getLastElement().setAdapter( new VoltageAdapter );
			
			addui( new FSShadow, CMD.VOLTAGE_LIMITS, "", null, 1 );
			addui( new FSShadow, CMD.VOLTAGE_LIMITS, "", null, 2 );
			addui( new FSShadow, CMD.VOLTAGE_LIMITS, "", null, 3 );
			addui( new FSShadow, CMD.VOLTAGE_LIMITS, "", null, 4 );
			attuneElement(NaN,NaN,FSShadow.F_SHOULD_EVOKE_CHANGE);
			getLastElement().setUp( onChangeVoltage );
			getLastElement().setAdapter( new SmartVoltageAdapter );
			
			addui( new FSSimple, 0, loc("power_on_when_voltage_reach"), doChangeVoltage, 1 );
			adapter = new InputVoltageAdapter;
			getLastElement().setAdapter( adapter );
			attuneElement( shift, 60 );
			
			addui( new FSCheckBox, CMD.CPW_LIMITS, loc("power_on_when_cpw1")+" "+loc("power_on_when_cpw2"), null, 1 );
			attuneElement( shift, 60);
			
			drawSeparator(700-59);
			
			addui( new FSSimple, CMD.CPW_SENSOR, loc("power_singnal_cpw"), null, 1 );
			attuneElement( shift, 60, FSSimple.F_CELL_NOTSELECTABLE | FSSimple.F_CELL_ALIGN_RIGHT );
			getLastElement().setAdapter( new BooleanColorAdapter( [loc("g_no"),loc("g_exist")] ) );
			
			var f_input:Function = function(p:Package):Number
			{
				var n:Number = int(p.getParam(1))/1000;
				return n;
			}
			var f_paint:Function = function(n:Number):Number
			{
				return UTIL.mod(n-15)*40;
			}
			var f_xshift:Function = function():Number
			{
				return 1;
			}
			
			vscreen = new VectorScreenAdv("", [], null, false, {input:f_input, paint:f_paint, xshift:f_xshift});
			addChild( vscreen );
			vscreen.open();
			vscreen.y = globalY - 32;
			vscreen.x = globalX-80;
		
			p = new Point(globalX,globalY+43-32);
			var ypos:int = globalY+43-32;
			
			// 10-15
			
			var f_toy:Function = function(n:Number):Number
			{
				var val:int = Math.round(( UTIL.mod(200-(n - p.y))*0.025+10)*100);
				return Math.round(( UTIL.mod(200-(n - p.y))*0.025+10)*100);
			}
//			var f_toy_dragable:Function = function(n:Number):Number
//			{
//				var res:Number = Math.round(( UTIL.mod(200-(n - p.y))*0.025+10)*100);
//				if (res > 1450)
//					res = 1450;
//				return res;
//				return Math.round(( UTIL.mod(200-(n - p.y))*0.025+10)*100);
//			}
				
			dlimits = new DragableLimitsAdv(this, [getField(CMD.VOLTAGE_LIMITS,2),getField(CMD.VOLTAGE_LIMITS,1)], p,f_toy,f_fromy, loc("measure_volt_1l"),false );
			dlimitsGuided = new DragableLimitsAdv(this, [getField(CMD.VOLTAGE_LIMITS,4)], p,f_toy,f_fromy, loc("measure_volt_1l") );
			dlimitsGuided.useCustomColors( [COLOR.GREEN] );

			var a:Array = [ {title:loc("power_lower_voltage_limit"),width:600, align:"center", color:COLOR.BLUE},
				{title:loc("power_upper_voltage_limit"), align:"center", width:600, top:true, color:COLOR.RED}	]
			dlimits.sign(a);
			a = [ {title:loc("power_device_inclusion"),width:300, xpos:30, color:COLOR.GREEN} ];
			dlimitsGuided.sign( a );
			
			dlimits.visible = false;
			dlimitsGuided.visible = false;
			
			starterCMD = [CMD.VOLTAGE_LIMITS, CMD.VOLTAGE_SENSOR, CMD.CPW_SENSOR, CMD.CPW_LIMITS];
		}
		private function f_fromy(n:Number):Number
		{
			return p.y + (n)/0.025;// p.y + UTIL.mod(((n/1000)-ypos)/0.525 );
		}
		
		override public function put(p:Package):void
		{
			switch(p.cmd) {
				case CMD.VOLTAGE_LIMITS:
					dlimits.init([
							getValue(p.getParam(2)),
							getValue(p.getParam(1))	]);
					
					adapter.setup( Number(p.getParam(1))/1000, Number(p.getParam(2))/1000);
					
					dlimitsGuided.changeRectangle( f_fromy(getValue(p.getParam(1))),f_fromy(getValue(p.getParam(2))) );
					dlimitsGuided.init( [ getValue(p.getParam(4)) ] );
					getField(CMD.CPW_LIMITS,1).setName( loc("power_on_when_cpw1")+" ["+ (Number(p.getParam(4))/1000).toFixed(2)+loc("measure_volt_1l")+"] "+loc("power_on_when_cpw2") );
					
					dlimits.visible = true;
					dlimitsGuided.visible = true;
					break;
				case CMD.CPW_LIMITS:
					pdistribute(p);
					loadComplete();
					break;
				case CMD.CPW_SENSOR:
					pdistribute(p);
					break;
				case CMD.VOLTAGE_SENSOR:
					pdistribute(p);
					vscreen.put(p);
					if (!task)
						task = TaskManager.callLater( onRequestVoltage, TaskManager.DELAY_5SEC );
					else
						task.repeat();
					break;
			}
			function getValue(n:int):Number
			{
				return UTIL.mod((n/1000)-15);
			}
		}
		override public function close():void
		{
			super.close();
			if (task)
				task.stop();
			if (dlimits)
				dlimits.close();
			if( dlimitsGuided)
				dlimitsGuided.close();
		}
		private function onChangeVoltage(t:IFormString):void
		{	// получение информации из getField(CMD.VOLTAGE_LIMITS,4)
			var res:String = String(t.getCellInfo());
			var r:Number = Number(t.getCellInfo())/1000;
			getField(0,1).setCellInfo( r.toFixed(2) );
			getField(CMD.CPW_LIMITS,1).setName( loc("power_on_when_cpw1")+" ["+ r.toFixed(2)+loc("measure_volt_1l")+"] "+loc("power_on_when_cpw2") );
			dlimitsGuided.getSign(0).text = loc("power_device_inclusion") + " " + r.toFixed(2);
		}
		private function doChangeVoltage(t:IFormString):void
		{	// внедрение инофрмации в управляющие ползунки
			var res:String = String(t.getCellInfo());
			var r:Number = UTIL.mod(Number(t.getCellInfo())-15);
			dlimitsGuided.moveLimits( [ r ] );
			remember(getField(CMD.VOLTAGE_LIMITS,4));
		}
		private function onRequestVoltage():void
		{
			if (this.visible) { 
				RequestAssembler.getInstance().fireEvent( new Request(CMD.VOLTAGE_SENSOR, put));
				RequestAssembler.getInstance().fireEvent( new Request(CMD.CPW_SENSOR, put));
			}
		}
	}
}
import components.interfaces.IDataAdapter;
import components.interfaces.IFormString;
class InputVoltageAdapter implements IDataAdapter
{
	private var hi:Number = NaN;
	private var low:Number = NaN;
	
	public function setup(valuehi:Number, valuelow:Number):void
	{
		hi = valuehi;
		low = valuelow;
	}
	
	public function adapt(value:Object):Object
	{
//		trace("a " + value);
		return value;
	}
	public function change(value:Object):Object
	{
//		trace("c " +value);
		return value;
	}
	public function perform(field:IFormString):void
	{
	}
	public function recover(value:Object):Object
	{	
		var a:Array = String(value).split(".");
		var res:String = String(a[0]).slice(0,2);
		if (a[1]) {
			var float:String = a[1];
			while (float.length < 2) {
				float += "0";
			}
			res = res + "." + float.slice(0,2);
		}
		var n:Number = Number(res);
		if ( !isNaN(hi) && !isNaN(low) ) {
			if (n > hi)
				n = hi;
			if (n < low)
				n = low;
		}
		return n;
	}
}
class SmartVoltageAdapter implements IDataAdapter
{
	public function adapt(value:Object):Object
	{
		return value;
	}
	public function change(value:Object):Object
	{
		return value;
	}
	public function perform(field:IFormString):void
	{
	}
	public function recover(value:Object):Object
	{	// из за двойного прогона, сначала передается число 10, потом умноженное на 1000
		var r:Number;
		if (int(value)<100)
			r = Number(value)*1000;
		else
			r = Number(value);
		return r;
	}
}