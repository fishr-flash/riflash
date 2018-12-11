package components.screens.ui
{
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import components.abstract.Dragable3Limits;
	import components.abstract.functions.loc;
	import components.abstract.servants.TaskManager;
	import components.abstract.servants.adapter.VoltageAdapter;
	import components.basement.UI_BaseComponent;
	import components.gui.fields.FSShadow;
	import components.gui.fields.FSSimple;
	import components.gui.limits.VectorScreenAdv;
	import components.gui.visual.charsGraphic.ChartOfIndications;
	import components.gui.visual.charsGraphic.components.HLine;
	import components.interfaces.IFormString;
	import components.interfaces.ITask;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.static.CMD;
	import components.static.COLOR;
	import components.system.SavePerformer;
	
	public class UIDevicePowerK14 extends UI_BaseComponent
	{
		private var vscreen:VectorScreenAdv;
		private var dlimits:Dragable3Limits;
		private var dlimitsGuided:Dragable3Limits;
		private var task:ITask;
		private var p:Point;
		private var adapter:InputVoltageAdapter;
		
		

		private var _chart:ChartOfIndications;
		
		public function UIDevicePowerK14()
		{
			super();
			
			init();
		}
		
		override public function open():void
		{
			super.open();
			
			/// пример использования триггера
			SavePerformer.trigger( { "cmd": refine } ); 
		}
		
		private function init():void
		{
			var shift:int = 450+90;
			
			addui( new FSShadow, CMD.BATTERY_LEVEL, "", null, 1 );
			
			
			
			
			addui( new FSSimple, CMD.BATTERY_LEVEL, loc("power_instant_u"), null, 2 );
			attuneElement( shift, 60, FSSimple.F_CELL_NOTEDITABLE_NOTEDITBOX | FSSimple.F_CELL_ALIGN_CENTER );
			//getLastElement().setAdapter( new VoltageAdapter );
			
			addui( new FSShadow, CMD.VOLTAGE_LIMITS, "", null, 1 );
			adapter = new InputVoltageAdapter;
			//getLastElement().setAdapter( adapter );
			
			
			addui( new FSShadow, CMD.VOLTAGE_LIMITS, "", null, 2 );
			adapter = new InputVoltageAdapter;
			//getLastElement().setAdapter( adapter );
			
			
			addui( new FSSimple, CMD.VOLTAGE_LIMITS, loc("voltage_for_recov_acu"), doChangeVoltage, 5 );
			adapter = new InputVoltageAdapter;
			//getLastElement().setAdapter( adapter );
			attuneElement( shift, 60, FSSimple.F_CELL_ALIGN_CENTER  );
			
			addui( new FSSimple, CMD.VOLTAGE_LIMITS, loc("power_on_when_voltage_reach"), doChangeVoltage, 4 );
			adapter = new InputVoltageAdapter;
			//getLastElement().setAdapter( adapter );
			attuneElement( shift, 60, FSSimple.F_CELL_ALIGN_CENTER  );
			
			addui( new FSSimple, CMD.VOLTAGE_LIMITS, loc("voltage_for_fail_acu"), doChangeVoltage, 3 );
			adapter = new InputVoltageAdapter;
			//getLastElement().setAdapter( adapter );
			attuneElement( shift, 60, FSSimple.F_CELL_ALIGN_CENTER  );
			
			
			
			drawSeparator(800-59);
			
			
			
			starterCMD = [ CMD.BATTERY_LEVEL, CMD.VOLTAGE_LIMITS ]
			
		}
		
		override public function put(p:Package):void
		{
			switch( p.cmd ) 
			{
				case CMD.BATTERY_LEVEL:
					pdistribute( p );
					
					if (!task)
						task = TaskManager.callLater( onRequestVoltage, TaskManager.DELAY_5SEC );
					else
						task.repeat();
					break;
				
				
				case CMD.VOLTAGE_LIMITS:
					
					
					
					getField( p.cmd, 1 ).setCellInfo( Number( Number( p.data[ 0 ][ 0 ] ) / Lp.MULT ).toFixed( 2 ) ); 
					getField( p.cmd, 2 ).setCellInfo( Number( Number( p.data[ 0 ][ 1 ] ) / Lp.MULT ).toFixed( 2 ) ); 
					getField( p.cmd, 3 ).setCellInfo( Number( Number( p.data[ 0 ][ 2 ] ) / Lp.MULT ).toFixed( 2 ) ); 
					getField( p.cmd, 4 ).setCellInfo( Number( Number( p.data[ 0 ][ 3 ] ) / Lp.MULT ).toFixed( 2 ) ); 
					getField( p.cmd, 5 ).setCellInfo( Number( Number( p.data[ 0 ][ 4 ] ) / Lp.MULT ).toFixed( 2 ) ); 
					
					
					
					createChart( p );
					loadComplete();
					
					
					
					
					
					
					break;
				
				default:
					pdistribute( p );		
					break;
			}
		}
		
		private function refine(value:Object):int
		{
			////////////////////TRACE//////////////////////////////
			///TODO: trace
			if( true )
			{
				import components.abstract.functions.dtrace;
				import su.fishr.utils.Dumper;
				import flash.utils.getTimer;
				const log_I:String = String
					(
						"" +   getTimer()  + "  \t " +
						"I project:  ConfLib"
						+ "file:  UIDevicePowerK14.as"
						+ ". funcname : " + ""
						//+ "\r  dump(  ): " + Dumper.dump( true )
						+ "\r  value: " + value
						+ "\r  : " + true
					);
				
				dtrace( log_I );
			}
			////////////////////////////////////////////////////////
			
			if(value is int) {
				switch(value) {
					case CMD.VOLTAGE_LIMITS:
						return SavePerformer.CMD_TRIGGER_TRUE;
						
				}
			} else {
				
				////////////////////TRACE//////////////////////////////
				///TODO: trace
				if( true )
				{
					import components.abstract.functions.dtrace;
					import su.fishr.utils.Dumper;
					import flash.utils.getTimer;
					const log_II:String = String
						(
							"" +   getTimer()  + "  \t " +
							"II project:  ConfLib"
							+ "file:  UIDevicePowerK14.as"
							+ ". funcname : " + ""
							+ "\r  dump( value ): " + Dumper.dump( value )
							//+ "\r  dump(  ): " + Dumper.dump( true )
							+ "\r  : " + true
						);
					
					dtrace( log_II );
				}
				////////////////////////////////////////////////////////
				
				/*var cmd:int = value.cmd;
				value.array[ 0 ] = 1;*/
				//return SavePerformer.CMD_TRIGGER_BREAK;
				//return SavePerformer.CMD_TRIGGER_CONTINUE;
			}
			return SavePerformer.CMD_TRIGGER_FALSE;
		}
		
		private function onChangeVoltage(t:IFormString):void
		{	
			
			
			// получение информации от getField(CMD.VOLTAGE_LIMITS,4)
			
			var res:String = String(t.getCellInfo());
			var r:Number = Number(t.getCellInfo())/Lp.MULT;
			
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
		{
			
			const rel:Number = Number( t.getCellInfo() );
			_chart.setLinePos( t.param + ""
								, rel
								, rel  + loc( "measure_volt_1l" )
								, ""
								);
			
			remember( t );
				 
		}
		private function onRequestVoltage():void
		{
			if (this.visible) { 
				RequestAssembler.getInstance().fireEvent( new Request(CMD.BATTERY_LEVEL, put));
				//RequestAssembler.getInstance().fireEvent( new Request(CMD.CPW_SENSOR, put));
			}
		}
		
		
		private function createChart( p:Package ):void
		{
			
			if( !_chart )
			{
				const maxV:Number = ( Number( p.data[ 0 ][ 0 ] ) / Lp.MULT ) + .1;
				const minV:Number = ( Number( p.data[ 0 ][ 1 ] ) / Lp.MULT ) - .1;
				
				
				// entry point
				var legend:Array = [];
				
				const len:int = 10;
				var vl:String;
				for( var i:int = 0; i < len; i++ )
				{
					vl = Number( minV + ( ( maxV - minV ) / len ) * i ).toFixed( 2 );
					
					legend.push( { label: vl +  loc( "measure_volt_1l" ) , data: Number( vl ) } );
					
					
				}
				
				
				
				_chart = new ChartOfIndications;
				_chart.x = globalX + 20; 
				_chart.y = globalY + 30;
				this.addChild( _chart );
				
				
				_chart.initField( minV, maxV, legend, new Rectangle( 0, 0, 700, 400 ), updateLimits );
				const lineV1:Number = Number( p.data[ 0 ][ 0 ] ) / Lp.MULT;
				const lineV2:Number = Number( p.data[ 0 ][ 1 ] ) / Lp.MULT;
				const lineV3:Number = Number( p.data[ 0 ][ 2 ] ) / Lp.MULT;
				const lineV4:Number = Number( p.data[ 0 ][ 3 ] ) / Lp.MULT;
				const lineV5:Number = Number( p.data[ 0 ][ 4 ] ) / Lp.MULT;
				
				Lp.MX_PWR = lineV1;
				Lp.MN_DSCH = Lp.MN_PWR =  lineV2;
				Lp.MX_DSCH = lineV5 - Lp.GAP;
				
				_chart.createHLine("1"
					, lineV1 
					, COLOR.RED
					, false
					, " " + lineV1.toFixed( 2 ) + loc( "measure_volt_1l" )
					, loc("power_upper_voltage_limit") + " =" + lineV1.toFixed( 2 )
					, HLine.VALIGN_BOTTOM
					
				);
				_chart.createHLine("2"
					, lineV2 
					, COLOR.GREY_ARSENIC
					, false
					, " " + lineV2.toFixed( 2 ) + loc( "measure_volt_1l" )
					, loc("power_lower_voltage_limit") + " =" + lineV2.toFixed( 2 )
					, HLine.VALIGN_TOP
				);
				_chart.createHLine("3"
					,lineV3
					, 0xba7000
					, true
					, " " + lineV3.toFixed( 2 ) + loc( "measure_volt_1l" )
					, loc("voltage_for_fail_acu") + " =" + lineV3.toFixed( 2 )
					, HLine.VALIGN_TOP
				);
				_chart.createHLine("4"
					, lineV4 
					, COLOR.GREEN
					, true
					, " " + lineV4.toFixed( 2 ) + loc( "measure_volt_1l" )
					, loc("power_on_when_voltage_reach") + " =" + lineV4.toFixed( 2 )
					, HLine.VALIGN_TOP
				);
				_chart.createHLine("5"
					,lineV5
					, COLOR.VIOLET
					, true
					, " " + lineV5.toFixed( 2 ) + loc( "measure_volt_1l" )
					, loc("voltage_for_recov_acu") + " =" + lineV5.toFixed( 2 )
					, HLine.VALIGN_TOP
				);
			}
			else
			{
				const lineV11:Number = Number( p.data[ 0 ][ 0 ] ) / Lp.MULT;
				const lineV12:Number = Number( p.data[ 0 ][ 1 ] ) / Lp.MULT;
				const lineV13:Number = Number( p.data[ 0 ][ 2 ] ) / Lp.MULT;
				const lineV14:Number = Number( p.data[ 0 ][ 3 ] ) / Lp.MULT;
				const lineV15:Number = Number( p.data[ 0 ][ 4 ] ) / Lp.MULT;
				
				Lp.MX_PWR = lineV11;
				Lp.MN_DSCH = Lp.MN_PWR =  lineV12;
				Lp.MX_DSCH = lineV15;
				
				_chart.setLinePos( "1"
									, lineV11
									, lineV11.toFixed( 2 ) + loc( "measure_volt_1l" )
									, loc("power_upper_voltage_limit") + " =" + lineV11.toFixed( 2 )
									);
				_chart.setLinePos( "2"
									, lineV12
									, lineV12.toFixed( 2 ) + loc( "measure_volt_1l" )
									, loc("power_lower_voltage_limit") + " =" + lineV12.toFixed( 2 )
									);
				_chart.setLinePos( "3"
									, lineV13
									, lineV13.toFixed( 2 ) + loc( "measure_volt_1l" )
									, loc("voltage_for_fail_acu") + " =" + lineV13.toFixed( 2 )
									);
				_chart.setLinePos( "4"
									, lineV14
									, lineV14.toFixed( 2 ) + loc( "measure_volt_1l" )
									, loc("power_on_when_voltage_reach") + " =" + lineV14.toFixed( 2 )
									);
				_chart.setLinePos( "5"
									, lineV15
									, lineV15.toFixed( 2 ) + loc( "measure_volt_1l" )
									, loc("voltage_for_recov_acu") + " =" + lineV15.toFixed( 2 )
									);
									
			}
			
		}
		
		private function updateLimits( name:String, rel:Number ):void
		{
			var res:Number = rel;
			
			switch( name ) {
				case "3":
					
					
						if( rel > Lp.MX_DSCH )
							res = Lp.MX_DSCH;
						else if ( rel < Lp.MN_DSCH )
							res = Lp.MN_DSCH;
						else
							res = rel;
						
					
						
						
					break;
				
				case "4":
					
						
					break;
				
				case "5":
					
						
						
					break;
				
				default:
					break;
					
					
			}
			
			if( res != Lp.MN_DSCH && res != Lp.MX_DSCH )
			{
				_chart.setLineInfo( name
					, " " + res.toFixed( 2 ) + loc( "measure_volt_1l" )
					, loc("voltage_for_fail_acu") + " =" + res.toFixed( 2 )
				);
			}
			else
			{
				_chart.setLinePos( name
									, res
									, " " + res.toFixed( 2 ) + loc( "measure_volt_1l" )
									, loc("voltage_for_fail_acu") + " =" + res.toFixed( 2 )
				);
			}
			
			
			getField( CMD.VOLTAGE_LIMITS, int( name ) ).setCellInfo( res.toFixed( 2 ) );
			remember( getField( CMD.VOLTAGE_LIMITS, int( name ) ) );
			
		
		}
	}
}
import components.interfaces.IDataAdapter;
import components.interfaces.IFormString;

class InputVoltageAdapter implements IDataAdapter
{
	
	
	public function adapt(value:Object):Object
	{
		
		return ( Number( value ) / Lp.MULT ).toFixed( 2 );
	}
	public function change(value:Object):Object
	{
		
		return value;
	}
	public function perform(field:IFormString):void
	{
		
		
	}
	public function recover(value:Object):Object
	{	
		return Number( value ) * Lp.MULT;
		
		
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
	{	// из за двойного прогона, сначала передается число 10, потом умноженное на LimitsPower.MULTIPLIER
		var r:Number;
		if (int(value)<100)
			r = Number(value)*Lp.MULT;
		else
			r = Number(value);
		
		
		return r;
	}
}


class Lp
{
	// Верхний предел напряжение питания ( парам 1 ком 906 )
	public static var MX_PWR:Number = 4.1;
	// Нижний предел напряжение питания ( парам 2 ком 906 )
	public static var MN_PWR:Number = 2.1;
	public static var MAX_RECOVERY:Number = 4.4;
	public static var MIN_RECOVERY:Number = 3.6;
	public static var MIN_ONDEVICE:Number = 4;
	/// мин уровень установки уровня разряда АКБ
	public static var MN_DSCH:Number = 2;
	/// максимальный уровень установки уровня разряда АКБ
	/// устанавливается в зависимости от уровня Восст. разряда
	public static var MX_DSCH:Number = 2;
	/// минимально допустимое расстояние между значениями восстановления и разряда АКБ
	public static var GAP:Number = .01;
	/// Множитель корректирующий значения прилетающие с прибора
	public static var MULT:Number = 1000;
	
 
	
	
	
}