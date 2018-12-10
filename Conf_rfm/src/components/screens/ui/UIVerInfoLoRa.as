package components.screens.ui
{
	import flash.display.DisplayObject;
	
	import components.abstract.functions.loc;
	import components.abstract.servants.TaskManager;
	import components.abstract.servants.WidgetMaster;
	import components.abstract.servants.adapter.VoltageAdapter;
	import components.gui.Header;
	import components.gui.fields.FSShadow;
	import components.gui.fields.FSSimple;
	import components.interfaces.ITask;
	import components.interfaces.IWidget;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.protocol.statics.OPERATOR;
	import components.static.CMD;
	import components.static.MISC;

	public class UIVerInfoLoRa extends UIVersion implements IWidget
	{

		
		private var task:ITask;

		private var optsOut:Vector.<OptOutDevInfoPage>;
		public function UIVerInfoLoRa()
		{
			
			super(3,0xff);
			
			const lenSep:int = 600;
			
			drawSeparator( lenSep );
			
			
			
			
			
			
			addui( new FSSimple, CMD.CTRL_TEMPERATURE_SENSOR, loc( "vhis_25" ), null, 1 );
			attuneElement( 250, 200, FSSimple.F_CELL_NOTSELECTABLE | FSSimple.F_CELL_ALIGN_LEFT );
			
			
			
			addui( new FSShadow, CMD.CTRL_VOLTAGE_SENSOR, "", null, 1 );
			addui( new FSSimple, CMD.CTRL_VOLTAGE_SENSOR, loc( "vhis_15" ), null, 2 );
			attuneElement( 250, 200, FSSimple.F_CELL_NOTSELECTABLE | FSSimple.F_CELL_ALIGN_LEFT );
			getLastElement().setAdapter( new VoltageAdapter );
			
			drawSeparator( lenSep );
			
			const dO:DisplayObject = this.addChild( new Header( [{label:loc("sensor_output_state"), align:"left",xpos: globalX,width: 250} ] ) );
			dO.y = globalY;
			globalY += 40;
			
			const len:int = OPERATOR.getSchema(  CMD.CTRL_DOUT_SENSOR ).StructCount;
			
			optsOut = new Vector.<OptOutDevInfoPage>( len );
			for (var i:int=0; i<len; i++) 
			{
				optsOut[ i ] = new OptOutDevInfoPage( i + 1 );
				this.addChild( optsOut[ i ] );
				optsOut[ i ].y = globalY;
				optsOut[ i ].x = globalX;
				globalY += optsOut[ i ].height;
			}
			
			drawSeparator( lenSep );
			
			addui( new FSSimple, CMD.CTRL_KEY_SENSOR, loc( "g_button" ), null, 1 );
			attuneElement( 200, 95, FSSimple.F_CELL_NOTEDITABLE_NOTEDITBOX | FSSimple.F_CELL_BOLD | FSSimple.F_CELL_NOTSELECTABLE | FSSimple.F_HTML_TEXT );
			getLastElement().setAdapter( new AdaptKeySensor );
			
			
			starterRefine( CMD.CTRL_DOUT_SENSOR );
			
			
			
		}
		
		
		
		private function getSensor( delay:int ):void
		{
			RequestAssembler.getInstance().fireEvent( new Request( CMD.CTRL_GET_SENSOR, put, 1, [ delay ] ) );
			
			if (!task)
				task = TaskManager.callLater( getSensor, TaskManager.DELAY_30SEC + 10,  [ TaskManager.DELAY_30SEC ]  );
			else
				task.repeat();
			
		}
		override public function open():void
		{
			super.open();
			loadComplete();
			
			MISC.DEBUG_DO_PING = 0;
			
			WidgetMaster.access().registerWidget( CMD.CTRL_TEMPERATURE_SENSOR, this );
			WidgetMaster.access().registerWidget( CMD.CTRL_VOLTAGE_SENSOR, this );
			WidgetMaster.access().registerWidget( CMD.CTRL_KEY_SENSOR, this );
			WidgetMaster.access().registerWidget( CMD.CTRL_DOUT_SENSOR, this );
			
			RequestAssembler.getInstance().doPing( MISC.DEBUG_DO_PING == 1 );
			
			
			
			getSensor( TaskManager.DELAY_30SEC );
			RequestAssembler.getInstance().doPing( false );
			
		}
		
		override public function close():void
		{
			MISC.DEBUG_DO_PING = 1;
			RequestAssembler.getInstance().fireEvent( new Request( CMD.CTRL_GET_SENSOR, put, 1, [ 0 ] ) );
			RequestAssembler.getInstance().doPing( MISC.DEBUG_DO_PING == 1 );
			
			task.stop();
			task.kill();
			task = null;
			
		}
		
		override public function put(p:Package):void
		{
			
			
			switch( p.cmd ) {
				case CMD.CTRL_DOUT_SENSOR:
					
					var len:int = p.data.length;
					for (var i:int=0; i<len; i++) 
					{
						optsOut[ i ].putData( p );
					}
					
					break;
				case CMD.CTRL_KEY_SENSOR:
				case CMD.CTRL_TEMPERATURE_SENSOR:
				case CMD.CTRL_VOLTAGE_SENSOR:
				
					
					pdistribute( p );
					break;
				
				
				
				default:
					super.put( p );
					break;
			}
		}
	}
}


import components.abstract.functions.loc;
import components.basement.OptionsBlock;
import components.gui.fields.FSSimple;
import components.interfaces.IDataAdapter;
import components.interfaces.IFormString;
import components.protocol.Package;
import components.static.CMD;
import components.static.COLOR;


class OptOutDevInfoPage extends OptionsBlock
{
	public function OptOutDevInfoPage( struct:int )
	{
		super();
		
		structureID = struct;
		operatingCMD = CMD.CTRL_DOUT_SENSOR;
		init();
	}
	
	private function init():void
	{
		addui( new FSSimple, operatingCMD, loc( "navi_output" ) +  " " + structureID + "", null, 1 );
		attuneElement( 200, 95, FSSimple.F_CELL_NOTEDITABLE_NOTEDITBOX | FSSimple.F_CELL_BOLD | FSSimple.F_CELL_NOTSELECTABLE | FSSimple.F_HTML_TEXT );
		getLastElement().setAdapter( new AdaptOptOut );
		
	}
	
	override public function putData(p:Package):void
	{
		
		pdistribute( p );
	}
}

class AdaptOptOut implements IDataAdapter
{
	
	
	private const LABELS:Array =
	[
		"",
		"<font color='#"+ COLOR.GREEN_SIGNAL.toString( 16 ) + "' >" + loc( "his_enabled_n" )  + "</font>",
		"<font color='#"+ COLOR.GREEN_SIGNAL.toString( 16 ) + "' >" + loc( "out_impulse_1hz" )  + "</font>",
		"<font color='#"+ COLOR.GREEN_SIGNAL.toString( 16 ) + "' >" + loc( "out_impulse_short" )  + "</font>",
		"<font color='#"+ COLOR.RED_BLOOD.toString( 16 ) + "' >" + loc( "his_disabled_n" )  + "</font>",
		"<font color='#"+ COLOR.GREEN_SIGNAL.toString( 16 ) + "' >" + loc( "out_7hz_pulse" )  + "</font>"
	];
	
	public function change(value:Object):Object{ return value; } 	// меняет вбитое значение до валидации
	/**
	 * Вызывается при первой загрузке входных данных 
	 * @param value собственно данные полученые с прибора
	 * @return данные которые будут сообщены закрепленному компоненту
	 * 
	 */		
	public function adapt(value:Object):Object
	{
		return LABELS[ int( value ) ]; 
	}
	/**
	 * Вызывается при изменении значения эл-та, например
	 * при чеке чекбокса
	 *  
	 * @param value данные полученные компонентом в результате изменения состояния
	 * @return данные которые будут переданны на прибор в результате преобразования
	 * 
	 */		
	public function recover(value:Object):Object{ return value;  }
	/**
	 * Вызывается при первой загрузке входных данных 
	 * @param field элемент за которым закреплен адаптер
	 * @return 
	 * 
	 */	
	public function perform(field:IFormString):void{}
}

class AdaptKeySensor implements IDataAdapter
{
	private const LABELS:Array =
		[
			"<font color='#"+ COLOR.GREEN_SIGNAL.toString( 16 ) + "' >" + loc( "his_not_pressed" )  + "</font>",
			"<font color='#"+ COLOR.RED_BLOOD.toString( 16 ) + "' >" + loc( "his_pressed" )  + "</font>"
		];
	
	public function change(value:Object):Object{ return value; } 	// меняет вбитое значение до валидации
	/**
	 * Вызывается при первой загрузке входных данных 
	 * @param value собственно данные полученые с прибора
	 * @return данные которые будут сообщены закрепленному компоненту
	 * 
	 */		
	public function adapt(value:Object):Object
	{
		
		return LABELS[ int( value ) ]; 
	}
	/**
	 * Вызывается при изменении значения эл-та, например
	 * при чеке чекбокса
	 *  
	 * @param value данные полученные компонентом в результате изменения состояния
	 * @return данные которые будут переданны на прибор в результате преобразования
	 * 
	 */		
	public function recover(value:Object):Object{ return value;  }
	/**
	 * Вызывается при первой загрузке входных данных 
	 * @param field элемент за которым закреплен адаптер
	 * @return 
	 * 
	 */	
	public function perform(field:IFormString):void{}
}