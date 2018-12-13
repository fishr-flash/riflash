package components.screens.ui
{
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import components.abstract.Dragable3Limits;
	import components.abstract.functions.loc;
	import components.abstract.servants.TaskManager;
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
			
			
			addui( new FSShadow, CMD.VOLTAGE_LIMITS, "", null, 1 );
			
			
			
			addui( new FSShadow, CMD.VOLTAGE_LIMITS, "", null, 2 );
			
			
			
			addui( new FSSimple, CMD.VOLTAGE_LIMITS, loc("voltage_for_recov_acu"), doChangeVoltage, 5 );
			attuneElement( shift, 60, FSSimple.F_CELL_ALIGN_CENTER |FSSimple.F_CELL_NOTEDITABLE_EDITBOX  );
			FSSimple( getLastElement() ).fcellBorderColor = COLOR.VIOLET;
			
			addui( new FSSimple, CMD.VOLTAGE_LIMITS, loc("power_on_when_voltage_reach"), doChangeVoltage, 4 );
			attuneElement( shift, 60, FSSimple.F_CELL_ALIGN_CENTER |FSSimple.F_CELL_NOTEDITABLE_EDITBOX );
			FSSimple( getLastElement() ).fcellBorderColor = COLOR.GREEN;
			
			
			addui( new FSSimple, CMD.VOLTAGE_LIMITS, loc("voltage_for_fail_acu"), doChangeVoltage, 3 );
			attuneElement( shift, 60, FSSimple.F_CELL_ALIGN_CENTER |FSSimple.F_CELL_NOTEDITABLE_EDITBOX );
			FSSimple( getLastElement() ).fcellBorderColor = 0xba7000;
			
			
			
			drawSeparator(800-59);
			
			
			
			starterCMD = [ CMD.BATTERY_LEVEL, CMD.VOLTAGE_LIMITS ]
			
		}
		
		override public function put(p:Package):void
		{
			var rel:Number = 0;
			switch( p.cmd ) 
			{
				case CMD.BATTERY_LEVEL:
					if( p.getParam( 1 ) > 0 )
					{
						getField( p.cmd, 2 ).disabled = false;
						rel = Number( p.data[ 0 ][ 1 ] ) / 1000;
						getField( p.cmd, 2 ).setCellInfo( rel.toFixed( 2 ) );
						
						
						if( _chart && _chart.lastBarY != rel )_chart.setBar( "BL2", rel, rel.toFixed( 2 ) + loc( "measure_volt_1l" ) );
						
					}
					else
					{
						if( _chart ) _chart.removeHBarLine( "BL2" );
						getField( p.cmd, 2 ).setCellInfo( loc( "can_not_available" ) );
						getField( p.cmd, 2 ).disabled = true;
					}
					
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
					
					_chart.setBar( "BL2"
									, Number( getField( CMD.BATTERY_LEVEL, 2 ).getCellInfo() )
									,  getField( CMD.BATTERY_LEVEL, 2 ).getCellInfo() + loc( "measure_volt_1l" ) );
					loadComplete();
					
					
					
					
					
					
					break;
				
				default:
					pdistribute( p );		
					break;
			}
		}
		
		private function refine(value:Object):int
		{
			
			if(value is int) {
				switch(value) {
					case CMD.VOLTAGE_LIMITS:
						return SavePerformer.CMD_TRIGGER_TRUE;
						
				}
			} else {
				
				
				
				/*var cmd:int = value.cmd;
				value.array[ 0 ] = 1;*/
				//return SavePerformer.CMD_TRIGGER_BREAK;
				//return SavePerformer.CMD_TRIGGER_CONTINUE;
				
				const len:int =value.array.length;
				for (var i:int=0; i<len; i++) {
					value.array[ i ]  = Number( getField( value.cmd, i + 1 ).getCellInfo() ) *  Lp.MULT;
					
				}
				
			}
			return SavePerformer.CMD_TRIGGER_FALSE;
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
				
			}
		}
		
		
		private function createChart( p:Package ):void
		{
			
			if( !_chart )
			{
				/*const maxV:Number = ( Number( p.data[ 0 ][ 0 ] ) / Lp.MULT ) + .02;
				const minV:Number = ( Number( p.data[ 0 ][ 1 ] ) / Lp.MULT ) - .02;*/
				/// отрицательные значения добавляют высоту графика, положительные сужают
				const clearanceMax:Number = -.01;
				const clearanceMin:Number = -.01;
				const maxV:Number = ( Number( p.data[ 0 ][ 0 ] ) / Lp.MULT ) - clearanceMax;
				const minV:Number = ( Number( p.data[ 0 ][ 1 ] ) / Lp.MULT ) + clearanceMin;
				
				
				// entry point
				var legend:Array = [];
				
				const len:int = 12;
				var vl:String;
				for( var i:int = 0; i < len; i++ )
				{
					vl = Number( minV + ( ( maxV - minV ) / len ) * i ).toFixed( 2 );
					
					legend.push( { label: vl +  loc( "measure_volt_1l" ) , data: Number( vl ) } );
					
					
				}
				
				
				
				
				_chart = new ChartOfIndications;
				_chart.x = globalX + 30; 
				_chart.y = globalY + 10;
				this.addChild( _chart );
				
				
				_chart.initField( minV, maxV, legend, new Rectangle( 0, 0, 710, 400 ), updateLimits );
				const lineV1:Number = Number( p.data[ 0 ][ 0 ] ) / Lp.MULT;
				const lineV2:Number = Number( p.data[ 0 ][ 1 ] ) / Lp.MULT;
				const lineV3:Number = Number( p.data[ 0 ][ 2 ] ) / Lp.MULT;
				const lineV4:Number = Number( p.data[ 0 ][ 3 ] ) / Lp.MULT;
				const lineV5:Number = Number( p.data[ 0 ][ 4 ] ) / Lp.MULT;
				
				Lp.MX_PWR = lineV1;
				Lp.MN_DSCH = Lp.MN_PWR =  lineV2;
				Lp.MX_DSCH = lineV5 - Lp.GAP;
				Lp.MN_RCVR = lineV3 + Lp.GAP;
				
				_chart.createHLine("1"
					, lineV1 
					, COLOR.RED
					, false
					, " " + lineV1.toFixed( 2 ) + loc( "measure_volt_1l" )
					, loc("power_upper_voltage_limit") + Lp.SIMB + lineV1.toFixed( 2 )
					, HLine.VALIGN_BOTTOM
					
				);
				_chart.createHLine("2"
					, lineV2 
					, COLOR.GREY_ARSENIC
					, false
					, " " + lineV2.toFixed( 2 ) + loc( "measure_volt_1l" )
					, loc("power_lower_voltage_limit") + Lp.SIMB + lineV2.toFixed( 2 )
					, HLine.VALIGN_TOP
				);
				_chart.createHLine("3"
					,lineV3
					, 0xba7000
					, true
					, " " + lineV3.toFixed( 2 ) + loc( "measure_volt_1l" )
					, loc("voltage_for_fail_acu") + Lp.SIMB + lineV3.toFixed( 2 )
					, HLine.VALIGN_TOP
				);
				_chart.createHLine("4"
					, lineV4 
					, COLOR.GREEN
					, true
					, " " + lineV4.toFixed( 2 ) + loc( "measure_volt_1l" )
					, loc("power_on_when_voltage_reach") + Lp.SIMB + lineV4.toFixed( 2 )
					, HLine.VALIGN_TOP
				);
				_chart.createHLine("5"
					,lineV5
					, COLOR.VIOLET
					, true
					, " " + lineV5.toFixed( 2 ) + loc( "measure_volt_1l" )
					, loc("voltage_for_recov_acu") + Lp.SIMB + lineV5.toFixed( 2 )
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
				Lp.MN_RCVR = lineV13 + Lp.GAP;
				
				_chart.setLinePos( "1"
									, lineV11
									, lineV11.toFixed( 2 ) + loc( "measure_volt_1l" )
									, loc("power_upper_voltage_limit") + Lp.SIMB + lineV11.toFixed( 2 )
									);
				_chart.setLinePos( "2"
									, lineV12
									, lineV12.toFixed( 2 ) + loc( "measure_volt_1l" )
									, loc("power_lower_voltage_limit") + Lp.SIMB + lineV12.toFixed( 2 )
									);
				_chart.setLinePos( "3"
									, lineV13
									, lineV13.toFixed( 2 ) + loc( "measure_volt_1l" )
									, loc("voltage_for_fail_acu") + Lp.SIMB + lineV13.toFixed( 2 )
									);
				_chart.setLinePos( "4"
									, lineV14
									, lineV14.toFixed( 2 ) + loc( "measure_volt_1l" )
									, loc("power_on_when_voltage_reach") + Lp.SIMB + lineV14.toFixed( 2 )
									);
				_chart.setLinePos( "5"
									, lineV15
									, lineV15.toFixed( 2 ) + loc( "measure_volt_1l" )
									, loc("voltage_for_recov_acu") + Lp.SIMB + lineV15.toFixed( 2 )
									);
									
			}
			
		}
		
		private function updateLimits( name:String, rel:Number ):void
		{
			var res:Number = rel;
			var legend:String = "";
			/// надо ли передвигать ползунок, или достаточно сменить текст надписи
			var setp:Boolean = false;
			/// если порог определяется несколькими данными
			/// сюда записывается актуальный по результатам сравнения
			var actual:Number = 0;
			switch( name ) {
				case "3":
					
						Lp.MX_DSCH = Number( getField( CMD.VOLTAGE_LIMITS, 5 ).getCellInfo() ) - Lp.GAP;
						actual = Number( getField( CMD.VOLTAGE_LIMITS, 4 ).getCellInfo() ) - Lp.GAP;
						
						if( actual < Lp.MX_DSCH )
							Lp.MX_DSCH = actual;
						
						legend = loc("voltage_for_fail_acu");
						if( rel >= Lp.MX_DSCH )
						{
							res = Lp.MX_DSCH;
							setp = true;
						}
						
						if ( rel <= Lp.MN_DSCH + Lp.GAP )
						{
							res = Lp.MN_DSCH + Lp.GAP;
							setp = true;
						}
						
						
						
						
					break;
				
				case "4":
					legend = loc("power_on_when_voltage_reach");
					
					Lp.MN_OND  = Number( getField( CMD.VOLTAGE_LIMITS, 3 ).getCellInfo() ) + Lp.GAP;
					
					actual = Number( getField( CMD.VOLTAGE_LIMITS, 2 ).getCellInfo() ) + Lp.GAP;
					
					if( actual > Lp.MN_OND )
							Lp.MN_OND = actual;
					
					if( rel <= Lp.MN_OND )
					{
						res = Lp.MN_OND;
						setp = true;
					}
					
					if( rel >= Lp.MX_OND )
					{
						res = Lp.MX_OND;
						setp = true;
					}
						
					break;
				
				case "5":
					Lp.MN_RCVR = Number( getField( CMD.VOLTAGE_LIMITS, 3 ).getCellInfo() ) + Lp.GAP;
					
					if( rel >= Lp.MX_RCVR )
					{
						res = Lp.MX_RCVR;
						setp = true;
					}
					
					if ( rel <= Lp.MN_RCVR )
					{
						res = Lp.MN_RCVR + Lp.GAP;
						setp = true;
					}
					
					legend = loc("voltage_for_recov_acu");
					break;
				
				default:
					break;
					
					
			}
			
			
			
			if( setp )
			{
				
				_chart.setLinePos( name
					, res
					, " " + res.toFixed( 2 ) + loc( "measure_volt_1l" )
					, legend + Lp.SIMB + res.toFixed( 2 )
				);
				
			}
			else
			{
				
				_chart.setLineInfo( name
					, " " + res.toFixed( 2 ) + loc( "measure_volt_1l" )
					, legend + Lp.SIMB + res.toFixed( 2 )
				);	
			}
			
			
			getField( CMD.VOLTAGE_LIMITS, int( name ) ).setCellInfo( res.toFixed( 2 ) );
			remember( getField( CMD.VOLTAGE_LIMITS, int( name ) ) );
			
		
		}
	}
}



class Lp
{
	/**
	 * Верхний предел напряжение питания ( парам 1 ком 906 )
	 */
	public static var MX_PWR:Number = 4.1;
	/**
	 * Нижний предел напряжение питания ( парам 2 ком 906 )
	 */
	public static var MN_PWR:Number = 2.1;
	
	/**
	 *  Максимальное значение уровня восстановления разряда
	 */
	public static var MX_RCVR:Number = 4.1;
	
	/**
	 * мин уровень установки уровня восстановления разряда АКБ
	 * устанавливается в зависимости от уровня разряда
	 */
	public static var MN_RCVR:Number = 2;
	
	/**
	 * мин уровень установки уровня разряда АКБ
	 */
	public static var MN_DSCH:Number = 2;
	/**
	 * максимальный уровень установки уровня разряда АКБ
	 * устанавливается в зависимости от уровня Восст. разряда
	 */
	public static var MX_DSCH:Number = 2;
	
	/**
	 *  Макс. уровень включения прибора
	 */
	public static var MX_OND:Number = 4;
	
	/**
	 *  Мин. уровень включения прибора
	 */
	public static var MN_OND:Number = 0;
	
	/**
	 * минимально допустимое расстояние между значениями восстановления и разряда АКБ
	 */
	public static var GAP:Number = .01;
	/**
	 * Множитель корректирующий значения прилетающие с прибора
	 */
	public static var MULT:Number = 1000;
	/**
	 * подставляемый знак между текстом и значением (-/=/~ )
	 */
	public static var SIMB:String = " ~";

	
	
	
 
	
	
	
}