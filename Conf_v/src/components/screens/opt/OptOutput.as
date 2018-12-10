package components.screens.opt
{
	import flash.events.Event;
	
	import components.abstract.GroupOperator;
	import components.abstract.functions.loc;
	import components.basement.OptionsBlock;
	import components.gui.fields.FSComboBox;
	import components.gui.fields.FSShadow;
	import components.gui.fields.FSSimple;
	import components.gui.fields.FormString;
	import components.gui.triggers.TextButton;
	import components.interfaces.IFormString;
	import components.interfaces.IOutputSpeed;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.protocol.statics.OPERATOR;
	import components.screens.ui.UIOutput;
	import components.static.CMD;
	import components.static.COLOR;
	import components.static.DS;
	import components.system.SavePerformer;
	import components.system.UTIL;
	
	public class OptOutput extends OptionsBlock
	{
		private const fullmenu:Array = [
			{data:0,label:loc("output_manual")},
			{data:1,label:loc("output_speed_exceed_II")},
			{data:2,label:loc("output_idn_left")},
			{data:3,label:loc("output_signal_speed_mode")},
			{data:4,label:loc("output_signal_block")}
		];
		
		private const cmdHash:Object = {0:CMD.VR_OUT, 1:CMD.VR_OUT_MANUAL_CONTROL };
		private const TYPE_MANUAL:int = 0;
		private const TYPE_SPEED_EXCESS:int = 1;
		private const TYPE_IDN_LEFT:int = 2;
		private const TYPE_SIGNAL_SPEED_MODE:int = 3;
		private const TYPE_SIGNAL_BLOCK:int = 4;
		
		public static const OPT_TYPE_NORMAL:int = 1;
		public static const OPT_TYPE_ACC:int = 2;	// дополнительные поля с 34 релиза
		
		private var OUTPUT_ON:Boolean = false;
		private var INVERSE:Boolean=false;
		private var type:int;
		
		private var group:GroupOperator;
		private var cache:Array;
		private var bManualOutSwitch:TextButton;
		private var bExtend:TextButton;
		private var optSpeedExcess:Vector.<IOutputSpeed>;
		
		public function OptOutput(s:int)
		{
			super();
			
			structureID = s;
			
			createUIElement( new FSShadow, CMD.VR_OUT, "", null, 1 );
			if ( DS.release < 60 && ( DS.isfam( DS.F_VL ) || DS.isfam( DS.F_VL_3G ) ) )
				createUIElement( new FSShadow, CMD.VR_OUT, "", null, 2 );
			else
			{
				createUIElement( new FSComboBox, CMD.VR_OUT, loc("output_purpose"), load, 2, getMenu(0) );
				attuneElement(150, 350, FSComboBox.F_COMBOBOX_NOTEDITABLE );
				
				drawSeparator();
			}
				
			
			createUIElement( new FSComboBox, CMD.VR_OUT, loc("output_control"), null, 3, UTIL.getComboBoxList([[0,loc("output_stright")],[1,loc("output_inverse")]]) );
			attuneElement(300, 200, FSComboBox.F_COMBOBOX_NOTEDITABLE );
			
			group = new GroupOperator;
		//	group.add( TYPE_MANUAL.toString(), [drawSeparator(), getLastElement()] );
			
			drawSeparator();
			
			var anchor:int = globalY;
			
			/** Ручное управление выходом
			 	Команда VR_OUT_MANUAL_CONTROL - ручное управление выходом
				Параметр 1 - управление выходом, 0-выключить выход, 1-включить выход, 2-вернуть в автоматический режим.		*/
			
			createUIElement( new FSSimple, 1, loc("output_state"), null, 1 );
			attuneElement(300, 200, FSSimple.F_CELL_NOTSELECTABLE);
			getLastElement().setAdapter(new DisplayManualOutAdapter);
			group.add( TYPE_MANUAL.toString(), getLastElement() );
			
			bManualOutSwitch = new TextButton;
			addChild( bManualOutSwitch );
			bManualOutSwitch.x = globalX;
			bManualOutSwitch.y = globalY;
			bManualOutSwitch.setUp( loc("g_switchon"), onSwitch );
			group.add( TYPE_MANUAL.toString(), bManualOutSwitch );
			
			/** Команда VR_SPEED_ALARM - Настройка шаблона "Сигнализатор нарушения скоростного режима".
				Номер структуры - порог "Превышение" (Внимание, здесь таблица настроек развернута по отношению к нарисованному экрану)
				Структура 1 - Превышение 1,
				Структура 2 - Превышение 2,
				Структура 3 - Превышение 3.
				
				Параметр 1 - Скорость свыше, км/ч;
				Параметр 2 - Включать, если длительность превышения скорости более чем, в секундах;
				Параметр 3 - Длительность импульса ""включено"", в секунднах/10;
				Параметр 4 - Длительность импульса ""выключено"", в секундах/10;
				Параметр 5 - Количество импульсов;
				Параметр 6 - Если превышение продолжается, то повторять через, в секундах."	*/
			
			globalY = anchor;
			
			var cmdlen:int = OPERATOR.getSchema( CMD.VR_SPEED_ALARM).StructCount;
			//cmdlen = 3;
			
			optSpeedExcess = new Vector.<IOutputSpeed>(cmdlen);
			var switcher:SpeedExcessTestSwitcher = new SpeedExcessTestSwitcher(optSpeedExcess, structureID);
			var optn:OptOutputSpeedExcess;
			var opta:OptOutputAccExcess;
			
			var xvalue:int = 0;
			var centertitle:int = int(cmdlen/2);	// для выячисления центрального блока, чтобы в нем написать название, чтобы оно было посередине
			
			for (var i:int=0; i<cmdlen; i++) {
				optn = new OptOutputSpeedExcess(i+1,centertitle == i);
				addChild( optn );
				group.add( String(TYPE_SPEED_EXCESS), optn );
				optn.x = 340 + (85*i);
				optn.y = globalY;
				optn.extend = false;
				optn.enableZoomer = false;
				optn.addEventListener( UIOutput.EVENT_SPEED_EXCESS_TEST, switcher.onSwitch );
				optSpeedExcess[i] = optn;
				
				xvalue = optn.x + 85;
			}
			
			xvalue += 5;
			
			if (DS.release >= 34 && !( DS.isfam( DS.F_VL_3G ) || DS.isfam( DS.F_VL )  )) {
				for (i=0; i<2; i++) {
					opta = new OptOutputAccExcess(i+1);
					addChild( opta );
					group.add( String(TYPE_SPEED_EXCESS), opta );
					opta.x = xvalue + (115*i);
					opta.y = globalY;
					opta.extend = false;
					opta.enableZoomer = false;
					opta.addEventListener( UIOutput.EVENT_SPEED_EXCESS_TEST, switcher.onSwitch );
					optSpeedExcess.push( opta );
				}
			}
			globalY += 33;
			
			group.add( String(TYPE_SPEED_EXCESS), 
				addui( new FormString, TYPE_SPEED_EXCESS, loc("output_speed_higher"), null, 1 ) );
			
			bExtend = new TextButton;
			addChild( bExtend );
			bExtend.x = globalX;
			bExtend.y = globalY;
			bExtend.setUp(loc("output_add_options"), onClick);
			group.add( String(TYPE_SPEED_EXCESS), bExtend );
			
			var fieldwidth:int = 350;
			
			group.add( String(TYPE_SPEED_EXCESS), 
				addui( new FormString, 0, loc("output_configure"), null, 10 ) );
			attuneElement( fieldwidth, NaN, FormString.F_TEXT_BOLD );
			group.add( TYPE_SPEED_EXCESS + "add", getLastElement() );
			group.add( String(TYPE_SPEED_EXCESS), 
				addui( new FormString, TYPE_SPEED_EXCESS, loc("output_time_on_pulse"), null, 2 ) );
			attuneElement( fieldwidth );
			group.add( TYPE_SPEED_EXCESS + "add", getLastElement() );
			group.add( String(TYPE_SPEED_EXCESS), 
				addui( new FormString, TYPE_SPEED_EXCESS, loc("output_time_off_pulse"), null, 3 ) );
			attuneElement( fieldwidth );
			group.add( TYPE_SPEED_EXCESS + "add", getLastElement() );
			group.add( String(TYPE_SPEED_EXCESS), 
				addui( new FormString, TYPE_SPEED_EXCESS, loc("output_pulse_amount"), null, 4 ) );
			attuneElement( fieldwidth );
			group.add( TYPE_SPEED_EXCESS + "add", getLastElement() );
			group.add( String(TYPE_SPEED_EXCESS), addui( new FormString, TYPE_SPEED_EXCESS, 
				loc("output_speed_exceed_longer"), null, 5 ) );
			attuneElement( fieldwidth, NaN, FormString.F_MULTYLINE );
			group.add( TYPE_SPEED_EXCESS + "add", getLastElement() );
			group.add( String(TYPE_SPEED_EXCESS), addui( new FormString, TYPE_SPEED_EXCESS, 
				loc("output_speed_exceed_repeat"), null, 6 ) );
			attuneElement( fieldwidth, NaN, FormString.F_MULTYLINE );
			group.add( TYPE_SPEED_EXCESS + "add", getLastElement() );
			group.visible( TYPE_SPEED_EXCESS + "add", false );
			
		}
		override public function putRawData(a:Array):void
		{
			cache = a;
			var data:Array = getData(CMD.VR_OUT);
			var bit:int = data[0];
			//type = data[1];
			INVERSE = data[2] == 1;
			var f:IFormString = getField(CMD.VR_OUT,2);
			if((f as FSComboBox) )(f as FSComboBox).setList( getMenu(bit) );		
			//f.setCellInfo( type );
			distribute( data, CMD.VR_OUT );
			load(f,false);
		}
		override public function putState(re:Array):void
		{
			
			OUTPUT_ON = re[0]==1;
			getField(1,1).setCellInfo( re[0] );
			(getField(1,1) as FormString).setTextColor( getColor(re[0]) );
			bManualOutSwitch.setName( getName(re[0]) );
			function getName(value:int):String
			{
				if (value == 1)
					return loc("g_switchoff");
				return loc("g_switchon");
			}
			function getColor(value:int):int
			{
				if (value == 0)
					return COLOR.RED;
				return COLOR.GREEN_SIGNAL;
			}
		}
		public function updateOutType():void
		{
			INVERSE = int(getField(CMD.VR_OUT, 3).getCellInfo()) == 1;
		}
		public function get needState():Boolean
		{
			return type == TYPE_MANUAL || type == TYPE_IDN_LEFT || type == TYPE_SIGNAL_BLOCK;
				
		}
		private function load(t:IFormString, save:Boolean=true):void
		{
			type = int(t.getCellInfo());
			
			group.visible( String(TYPE_MANUAL), type==TYPE_MANUAL || type == TYPE_SIGNAL_BLOCK);
			group.visible( String(TYPE_SPEED_EXCESS), type==TYPE_SPEED_EXCESS || type == TYPE_SIGNAL_SPEED_MODE);
			
			switch(type) {
				
				case TYPE_SIGNAL_BLOCK:
					bManualOutSwitch.visible = false;
				case TYPE_MANUAL:
					width = 550;
					height = 200;
					
					break;
				case TYPE_IDN_LEFT:
					width = 550;
					height = 200;
					
					break;
				case TYPE_SPEED_EXCESS:
				case TYPE_SIGNAL_SPEED_MODE:
					speedExcessExtend(false);
					//group.visible( TYPE_SPEED_EXCESS + "add", false );
					var len:int = optSpeedExcess.length;
					for (var i:int=0; i<len; i++) {
						if (optSpeedExcess[i].type == OPT_TYPE_NORMAL) {
							optSpeedExcess[i].putRawData( OPERATOR.dataModel.getData(CMD.VR_SPEED_ALARM)[i] );
							optSpeedExcess[i].enableZoomer = false;
						}
					}
					
					if (DS.release >= 34 && !( DS.isfam( DS.F_VL_3G ) || DS.isfam( DS.F_VL )  ) ) {
						for (i=0; i<len; i++) {
							if (optSpeedExcess[i].type == OPT_TYPE_ACC) {
								
								optSpeedExcess[i].putRawData( OPERATOR.dataModel.getData(CMD.VR_ACC_ALARM)[optSpeedExcess[i].getStructure()-1] );
								optSpeedExcess[i].enableZoomer = false;
							}
						}
						if( DS.release == 34 )
							width = 860;
						else
							width = 1030;
					} else
						width = 670;
					height = 440;
					break;
			}
			
			/*if (type>0)
				distribute( getData(cmdHash[type]), cmdHash[type] );*/
			
			this.dispatchEvent( new Event(UIOutput.EVENT_ASK_STATE) );
			
			if (save)
				SavePerformer.remember(getStructure(),t);
			else
				SavePerformer.closePage(false);
		}
		private function getData(cmd:int):Array
		{
			var len:int = cache.length;
			for (var i:int=0; i<len; ++i) {
				if( cache[i].cmd == cmd )
					return cache[i].data;
			}
			return null;
		}
		
		private function getMenu(bit:int):Array
		{
			/** бит0=1 - Управляемый дистанционно выход */
			if( bit & ( 1 << 2 )) bit |= ( 1 << 4 );
			
			
			var a:Array = [];
			var len:int = fullmenu.length;
			for (var i:int=0; i<len; ++i) {
				
				
				if( (bit & (1<<i)) > 0 ) {
					a.push( fullmenu[i] );
				}
			}
			return a;
		}
		private function onSwitch():void
		{
			var off:int = 0;
			var on:int = 1;
			if (INVERSE) {
				off = 1;
				on = 0;
			}
			RequestAssembler.getInstance().fireEvent( new Request( CMD.VR_OUT_MANUAL_CONTROL, null, getStructure(), [OUTPUT_ON==true?off:on]));
		}
		private function onClick():void
		{
			speedExcessExtend(true);
			RequestAssembler.getInstance().fireEvent(new Request(CMD.VR_OUT_MANUAL_CONTROL, null, getStructure(), [0]));
		}
		private function speedExcessExtend(b:Boolean):void
		{
			bExtend.visible = !b;
			group.visible( TYPE_SPEED_EXCESS + "add", b );
			var len:int = optSpeedExcess.length;
			for (var i:int=0; i<len; i++) {
				optSpeedExcess[i].extend = b;
			}
		}
	}
}
import flash.events.Event;

import components.abstract.functions.loc;
import components.interfaces.IDataAdapter;
import components.interfaces.IFormString;
import components.interfaces.IOutputSpeed;
import components.protocol.Request;
import components.protocol.RequestAssembler;
import components.static.CMD;

class DisplayManualOutAdapter implements IDataAdapter
{
	// Состояние выхода, 0-выход разомкнут, 1-выход зам
	private var hash:Array = [loc("g_wire_open").toLowerCase(),loc("g_wire_closed").toLowerCase()];
	
	public function adapt(value:Object):Object
	{
		if (int(value) < hash.length)
			return hash[int(value)];
		return loc("g_incorrect_value").toLowerCase();
	}
	public function change(value:Object):Object
	{
		return value;
	}
	public function perform(field:IFormString):void	{	}
	public function recover(value:Object):Object
	{
		var res:int = Math.round(Number(value)*10);
		return res;
	}
}
class SpeedExcessTestSwitcher
{
	private var opts:Vector.<IOutputSpeed>;
	private var structure:int;
	
	public function SpeedExcessTestSwitcher(v:Vector.<IOutputSpeed>, str:int):void
	{
		opts = v;
		structure = str;
	}
	public function onSwitch(e:Event):void
	{
		//var opt:OptOutputSpeedExcess = (e.currentTarget as OptOutputSpeedExcess);
		var opt:IOutputSpeed = (e.currentTarget as IOutputSpeed);
		var len:int = opts.length;
		for (var i:int=0; i<len; i++) {
			if( opts[i] != opt ) {
				opts[i].enableZoomer = false;
			} else
				RequestAssembler.getInstance().fireEvent( new Request( CMD.VR_OUT_MANUAL_CONTROL, null, structure, [opt.enableZoomer ? i+1 : 0] ));
		}
		
	}
}