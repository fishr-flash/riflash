package components.screens.ui
{
	import flash.geom.Point;
	
	import components.abstract.Dragable3Limits;
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
	import components.static.CMD;
	import components.static.COLOR;
	import components.static.DS;
	import components.system.UTIL;
	
	public class UIDevicePower extends UI_BaseComponent
	{
		
		
		
		private var vscreen:VectorScreenAdv;
		private var dlimits:Dragable3Limits;
		private var dlimitsGuided:Dragable3Limits;
		private var task:ITask;
		private var p:Point;
		private var adapter:InputVoltageAdapter;
		private var _group14_of4:Array = [ DS.K14W, DS.K14K ];
		
		
		public function UIDevicePower()
		{
			super();
			
			var shift:int = 450+90;
			
			if( !( DS.isDevice( DS.K5 ) && ( int( DS.app ) == 5 || int( DS.app ) == 6 ) ) )
			{
				addui( new FSSimple, CMD.VOLTAGE_SENSOR, loc("power_instant_u"), null, 1 );
				attuneElement( shift, 60, FSSimple.F_CELL_NOTSELECTABLE | FSSimple.F_CELL_ALIGN_CENTER );
				getLastElement().setAdapter( new VoltageAdapter );
			}
			
			
			addui( new FSShadow, CMD.VOLTAGE_LIMITS, "", null, 1 );
			addui( new FSShadow, CMD.VOLTAGE_LIMITS, "", null, 2 );
			
			addui( new FSShadow, CMD.VOLTAGE_LIMITS, "", null, 3 );
			attuneElement(NaN,NaN,FSShadow.F_SHOULD_EVOKE_CHANGE);
			getLastElement().setUp( onChangeVoltage );
			getLastElement().setAdapter( new SmartVoltageAdapter );
			
			addui( new FSShadow, CMD.VOLTAGE_LIMITS, "", null, 4 );
			attuneElement(NaN,NaN,FSShadow.F_SHOULD_EVOKE_CHANGE);
			getLastElement().setUp( onChangeVoltage );
			getLastElement().setAdapter( new SmartVoltageAdapter );
			
			addui( new FSShadow, CMD.VOLTAGE_LIMITS, "", null, 5 );
			attuneElement(NaN,NaN,FSShadow.F_SHOULD_EVOKE_CHANGE);
			getLastElement().setUp( onChangeVoltage );
			getLastElement().setAdapter( new SmartVoltageAdapter );
			
			
			addui( new FSSimple, 0, loc("power_on_when_voltage_reach"), doChangeVoltage, 1 );
			adapter = new InputVoltageAdapter;
			getLastElement().setAdapter( adapter );
			attuneElement( shift, 60 );
			
			addui( new FSSimple, 0, loc("voltage_for_recov_acu"), null, 2 );
			adapter = new InputVoltageAdapter;
			getLastElement().setAdapter( adapter );
			attuneElement( shift, 60, FSSimple.F_CELL_NOTEDITABLE_NOTEDITBOX );
			
			addui( new FSSimple, 0, loc("voltage_for_fail_acu"), null, 3 );
			adapter = new InputVoltageAdapter;
			getLastElement().setAdapter( adapter );
			attuneElement( shift, 60, FSSimple.F_CELL_NOTEDITABLE_NOTEDITBOX );
			
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
			
			var f_toy:Function = function(n:Number, revert:Boolean = false):Number
			{
				
				
				if( revert )
					return Math.round(  ( 200 - ( ( ( n / 100 ) - 10 ) / .025 ) ) + p.y );
				else
					return Math.round(( UTIL.mod(200-(n - p.y))*0.025+10)*100);
			}
				
			
			
//			
			
				
			const stong_orange:int = 0xba7000;
			dlimits = new Dragable3Limits(this, [getField(CMD.VOLTAGE_LIMITS,2)
													,getField(CMD.VOLTAGE_LIMITS,1)]
											, p,f_toy,f_fromy, loc("measure_volt_1l"),false );
			dlimitsGuided = new Dragable3Limits(this, [
															getField(CMD.VOLTAGE_LIMITS,3)
															,getField(CMD.VOLTAGE_LIMITS,4)
															,getField(CMD.VOLTAGE_LIMITS,5)
														], p,f_toy,f_fromy, loc("measure_volt_1l") );
			dlimitsGuided.useCustomColors( [ stong_orange, COLOR.GREEN, COLOR.VIOLET] );

			var a:Array = [ {title:loc("power_lower_voltage_limit"),width:Dragable3Limits.WIDHT_LIMITS_LINES, align:"center", color:COLOR.BLUE},
				{title:loc("power_upper_voltage_limit"), align:"center", width:Dragable3Limits.WIDHT_LIMITS_LINES, top:true, color:COLOR.RED}	
			]
			dlimits.sign(a);
			a = [ 
					{title:loc("voltage_for_fail_acu"),width:Dragable3Limits.WIDHT_LIMITS_LINES, align:"center", color: stong_orange} 
					,{title:loc("power_device_inclusion"),width:Dragable3Limits.WIDHT_LIMITS_LINES, align:"center", color:COLOR.GREEN} 
					,{title:loc("voltage_for_recov_acu"),width:Dragable3Limits.WIDHT_LIMITS_LINES, align:"center", color:COLOR.VIOLET}
				];
			dlimitsGuided.sign( a );
			
			 
			
			dlimits.visible = false;
			dlimitsGuided.visible = false;
			
			
			
			
			starterCMD = [CMD.VOLTAGE_LIMITS,  CMD.CPW_SENSOR ];
			
			if( !( DS.isDevice( DS.K5 ) && ( int( DS.app ) == 5 || int( DS.app ) == 6 ) ) )
																starterRefine( CMD.VOLTAGE_SENSOR, true );
			if ( _group14_of4.indexOf( DS.deviceAlias ) == -1  && !DS.isDevice( DS.A_BRD )  )
																starterRefine( CMD.CPW_LIMITS, true );
			
			
		}
		private function f_fromy(n:Number):Number
		{
			
			
			return Number( ( p.y + (n)/0.025 ).toFixed( 1 ) );// p.y + UTIL.mod(((n/1000)-ypos)/0.525 );
		}
		
		override public function put(p:Package):void
		{
			switch(p.cmd) {
				case CMD.VOLTAGE_LIMITS:
					dlimits.init([
							getValue(p.getParam(2)),
							getValue(p.getParam(1))	]);
					
					adapter.setup( Number(p.getParam(1))/1000, Number(p.getParam(2))/1000);
					
					
					/// настройка диапазона движения линии включения прибора
					dlimitsGuided.changeRectangle( f_fromy(getValue(Dragable3Limits.MAX_LEVEL_ON_DEVICE)),f_fromy(getValue(p.getParam(2))) );
					/// настройка линий разряда и восстановления
					
					dlimitsGuided.changeRectangleSeconds( f_fromy(getValue( p.getParam(1) )),f_fromy(getValue(p.getParam(2)))  );
					//dlimitsGuided.init( [ getValue(p.getParam(4)), getValue(p.getParam(3)), getValue(p.getParam(5)) ] );
					dlimitsGuided.init( [  getValue(p.getParam(3)), getValue(p.getParam(4)), getValue(p.getParam(5)) ] );
					getField(CMD.CPW_LIMITS,1).setName( loc("power_on_when_cpw1")+" ["+ (Number(p.getParam(4))/1000).toFixed(1)+loc("measure_volt_1l")+"] "+loc("power_on_when_cpw2") );
					
					
					dlimits.visible = true;
					dlimitsGuided.visible = true;
					
					break;
				case CMD.CPW_LIMITS:
					pdistribute(p);
					
					break;
				case CMD.CPW_SENSOR:
					pdistribute(p);
					loadComplete();
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
				///FIXME: Debug value! Remove it now!
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
		{	
			
			
			// получение информации от getField(CMD.VOLTAGE_LIMITS,4)
			
			var res:String = String(t.getCellInfo());
			var r:Number = Number(t.getCellInfo())/1000;
			
			switch( t.param ) {
				case 4:
					getField(0,1).setCellInfo( r.toFixed(1) );
					getField(CMD.CPW_LIMITS,1).setName( loc("power_on_when_cpw1")+" ["+ r.toFixed(1)+loc("measure_volt_1l")+"] "+loc("power_on_when_cpw2") );
					const ss:Array = loc("power_device_inclusion").split( ", " );
					dlimitsGuided.getSign(1).text = ss[ 0 ] + ", " + r.toFixed(1) + ss[ 1 ]; 
					break;
				
				case 3:
					
					getField(0,3).setCellInfo( r.toFixed(1) );
					const s:Array = loc("voltage_for_fail_acu").split( ", " );
					dlimitsGuided.getSign(0).text = s[ 0 ] + ", " + r.toFixed(1) + s[ 1 ];
					
					break;
				
				case 5:
					
					getField(0,2).setCellInfo( r.toFixed(1) );
					const sr:Array = loc("voltage_for_recov_acu").split( ", " );
					dlimitsGuided.getSign(2).text = sr[ 0 ] + ", " + r.toFixed(1) + sr[ 1 ];
					
					break;
				
				default:
					break;
			}
			
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
import components.abstract.Dragable3Limits;
import components.interfaces.IDataAdapter;
import components.interfaces.IFormString;


class InputVoltageAdapter implements IDataAdapter
{
	private var hi:Number = NaN;
	private var low:Number = NaN;
	
	public function setup(valuehi:Number, valuelow:Number):void
	{
		hi = Number( valuehi.toFixed( 1 ) );
		low = Number( valuelow.toFixed( 1 ) );
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
		
		
		if (n > Dragable3Limits.MAX_LEVEL_ON_DEVICE )
				n = Dragable3Limits.MAX_LEVEL_ON_DEVICE ;
		
		if ( !isNaN(low) ) {
			
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