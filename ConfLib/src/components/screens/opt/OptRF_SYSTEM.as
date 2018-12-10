package components.screens.opt
{
	import flash.events.Event;
	
	import components.abstract.RegExpCollection;
	import components.abstract.functions.loc;
	import components.abstract.servants.TabOperator;
	import components.abstract.servants.adapter.AdapterGMT;
	import components.basement.OptionsBlock;
	import components.gui.SimpleTextField;
	import components.gui.fields.FSCheckBox;
	import components.gui.fields.FSComboBox;
	import components.gui.fields.FSShadow;
	import components.gui.fields.FSSimple;
	import components.gui.fields.FormEmpty;
	import components.gui.visual.Separator;
	import components.interfaces.IFormString;
	import components.protocol.Package;
	import components.screens.ui.UIRadioSystem;
	import components.static.CMD;
	import components.static.COLOR;
	import components.static.DS;
	import components.system.SavePerformer;
	import components.system.SysManager;
	import components.system.UTIL;
	
	public class OptRF_SYSTEM extends OptionsBlock
	{
		private const varA:String = loc("rfd_for_correct_work_should_be_version")+" A";
		private const varB:String = loc("rfd_for_correct_work_should_be_version")+" B";
		
		private var aDefault:Array = [1,1,4,1,60,4,0,12,0,7];
		
		private var aPeriodBattary:Array = [ {label:loc("g_immediately"), data:"255:255"}, {label:"04:00", data:"04:00" }, {label:"08:00", data:"08:00" }, {label:"12:00", data:"12:00" }, {label:"18:00", data:"18:00" }, {label:"22:00", data:"22:00" }]; 
		private var aPeriodAlarm:Array = [ {label:"04:00", data:"04:00" }, {label:"08:00", data:"08:00" }, {label:"12:00", data:"12:00" }, {label:"18:00", data:"18:00" }, {label:"22:00", data:"22:00" }, {label:loc("g_no"), data:"00:00"}];
		private var st1:SimpleTextField;
		private var st2:SimpleTextField;
		private var hider:SimpleTextField;
		private var warn:SimpleTextField;
		private var _blocked:Boolean; // запоминает, была ли блокировка радиосистемы
		public var valid:Boolean;
		
		public function OptRF_SYSTEM()
		{
			super();
			construct();
		}
		private function construct():void
		{
			aCells = new Array;
			
			operatingCMD = CMD.RF_SYSTEM;
			
			globalX = 10;
			/** Параметр 1 - Наличие настроенной радиосистемы ( 0x00 - нет радиосистемы, 0x01 -  есть радиосистема ) */
			createUIElement( new FSShadow,operatingCMD , "", null, 1 ).setCellInfo("1");
			/**	Параметр 2 - Номер канала радиопередачи; */
			createUIElement( new FSComboBox, operatingCMD, loc("rfd_num_rf_channel"), change, 2, UTIL.comboBoxNumericDataGenerator(1, 7),"1-7",1, new RegExp("^([1-7])$") );
			attuneElement( 300 );
			
			st1 = new SimpleTextField(loc("g_minutes_3l"),50);
			addChild( st1 );
			st1.x = 350;
			
			/**	Параметр 3 - Период автотестов в радиосистеме (в минутах); */
			st1.y = createUIElement( new FSSimple, operatingCMD, loc("rf_system_autotest_period"),change,3,null,"0-9", 2, 
				new RegExp("^([1-9]|[1-5][0-9])$") ).y;
			attuneElement( 300, 35 );
			
			/**	Параметр 4 - Индикация датчиков при тревоге ( 0x00 - нет индикации, 0x01 - есть индикация ); */
			createUIElement( new FSComboBox, operatingCMD, loc("rfd_sensor_ind_while_alarm"),change,4);
			attuneElement(300,NaN, FSComboBox.F_COMBOBOX_BOOLEAN | FSComboBox.F_COMBOBOX_NOTEDITABLE );
			
			st2 = new SimpleTextField(loc("time_sec_3l"),50);
			addChild( st2 );
			st2.x = 350;
			
			/**	Параметр 5 - Период передачи тревожных сообщений от датчиков ( секунды ); */
			st2.y = createUIElement( new FSSimple, operatingCMD, loc("rfd_transfer_period_from_sensor"),change,5,null,"0-9", 3,
				new RegExp( RegExpCollection.REF_2to255 )).y;
			attuneElement( 300, 35 );
			
			/**	Параметр 6,7 - Период формирования повторной тревоги "Автотест не прошел" (ЧЧ:ММ), параметр 6 - час	59, значения параметров 6 и 7 равные 0x00, 0x00 -  Нет */
			createUIElement( new FSComboBox, operatingCMD,loc("rfd_second_alarm_period_autotest_fail"),change,6,
				aPeriodAlarm,"",0,new RegExp( "^((([01]?\\d|2[0-3]):([0]?\\d|[0-5]\\d))|"+loc("g_no")+")$" ) );
			attuneElement( 300,NaN, FSComboBox.F_MULTYLINE | FSComboBox.F_COMBOBOX_TIME);
			globalY += 10;
			
			/**	Параметр 8,9 - Сообщать в указанное время (ЧЧ:ММ) о разряде батареи датчика, параметр 8 - часы 00-23 значение параметров 8 и 9 равное 0xFF,0xFF - "Всегда"; */
			createUIElement( new FSComboBox, operatingCMD,loc("rfd_notify_battery_low"),change,8,
				aPeriodBattary,"",0,new RegExp( "^((([01]?\\d|1\\d|2[0-3]):(\\d|[0-5]\\d))|255:255|"+loc("g_always")+")$" ) );
			attuneElement( 300,NaN, FSComboBox.F_MULTYLINE | FSComboBox.F_COMBOBOX_TIME );
			if ( DS.isDevice(DS.K7)) {
				getLastElement().setAdapter( new AdapterGMT );
			}
			globalY += 10;
			/**	Параметр 10 - Период повторного формирования сообщения "Разряд батареи радиодатчика" (дней) 1-14. */
			
			createUIElement( new FSComboBox, operatingCMD,loc("rfd_second_alarm_period_battery_low"),change,10,
				UTIL.getComboBoxList([1,7,14]),"",0,new RegExp( "^([1-9]|1[0-4])$" ) );
			attuneElement( 300,NaN, FSComboBox.F_MULTYLINE );
			globalY += 10;
			for( var fields:String in aCells ) {
				(aCells[fields] as FormEmpty).addEventListener( Event.CHANGE, evChanged );
			}
			
			addui( new FSCheckBox, CMD.RF_MESSAGE_TAMPER, loc("rfd_elements_dispatch_tamper_contact"), null, 1 );
			attuneElement( 300 + 87, NaN, FSCheckBox.F_MULTYLINE );
			getLastElement().setAdapter( new CheckBoxAdapter );
			
			addui( new FSCheckBox, CMD.RF_SENSOR_TIME, loc("rfd_use_sensor_typeb"), onSensorTime, 1 );
			attuneElement( 300 + 87 );
			getLastElement().setAdapter(new SensorTimeAdapter );
			
			warn = new SimpleTextField("", 500, COLOR.RED);
			warn.x = globalX;
			warn.y = globalY - 5;
			addChild( warn );
			
			hider = new SimpleTextField(loc("g_not_exist"), 100);
			hider.background = true;
			hider.backgroundColor = COLOR.WHITE;
			hider.height = 30;
			hider.x = st2.x - 40;
			hider.y = st2.y;
			addChild( hider );

			globalY += 50;
			
			var sep:Separator = new Separator( 400 );
			addChild( sep );
			sep.y = globalY-10;
			sep.x = globalX;
			
			complexHeight = globalY;
			valid = true;
		}
		private function evChanged(ev:Event ):void
		{
			change(aCells[0])
		}
		
		private var LOADING:Boolean = false;
		private function change(target:IFormString):void
		{
			if (!LOADING) {
				valid = true;
				for( var fields:String in aCells ) {
					if ( !(aCells[fields] as FormEmpty).valid ) {
						valid = false;
						break;
					}
				}
				//dispatchEvent( new Event("edited") );
				SavePerformer.remember( getStructure(), target );
			}
		}
		override public function putData(p:Package):void
		{
			if ( !p.error ) {
				switch(p.cmd) {
					case CMD.RF_SENSOR_TIME:
						distribute(p.getStructure(),p.cmd);
						visualize(p.getStructure()[0] == UIRadioSystem.sensortime_active);
						break;
					case CMD.RF_MESSAGE_TAMPER:
						distribute(p.getStructure(),p.cmd);
						break;
					default:
						if( !TabOperator.getInst().isCurrentFocusOnMenu() )
							SysManager.clearFocus(stage);
						LOADING = true;
						p.getStructure().forEach( parseResponse );
						LOADING = false;
						break;
				}
			}
		}
		private function visualize(on:Boolean):void
		{
			hider.visible = on;
		//	getField(operatingCMD,5).disabled = on ? true : _blocked;
			warn.text = on ? varB : varA;
			(getField(operatingCMD,5) as FSSimple).tabIgnore = on;
		}
		private function onSensorTime(t:IFormString):void
		{
			visualize( int(t.getCellInfo()) == UIRadioSystem.sensortime_active );
			remember(t);
		}
		private function parseResponse( element:int , index:int, arr:Array ):void 
		{
			var value:String;
			switch( index )	{
				case 6:
				case 8:
					break;
				case 5:
				case 7:
					if ( element == 0xFF && arr[index+1] == 0xFF )
						value = "255:255";
					else {
						if ( DS.isDevice(DS.K7) && index == 7) {
							value = UTIL.fz(element,2)+":"+ UTIL.fz( arr[index+1].toString(), 2 );
						} else
							value = UTIL.fz( element.toString(), 2)+":"+ UTIL.fz( arr[index+1].toString(), 2 );
					}
					break;
				default:
					value = element.toString();
					break;
			}
			if ( !(value == null) )
				getField(operatingCMD,index+1).setCellInfo(value);
		}
		public function setDefault():void 
		{
			aDefault[1] = int( Math.random()*7)+1;
			aDefault[7] = 12;
			if ( DS.isDevice(DS.K7) ) {
				var d:Date = new Date;
				d.setHours(aDefault[7]);
				aDefault[7] = d.getUTCHours();
			}
			aDefault.forEach( parseResponse );
			SavePerformer.remember(1,getField(operatingCMD,10));
			valid = true;
		}
		public function getDefault():Array
		{
			aDefault[1] = int( Math.random()*7)+1;
			return aDefault;
		}
		public function block(b:Boolean):void
		{
			_blocked = b;
			for( var fields:String in aCells ) {
			//	if ((aCells[fields] as FormEmpty).cmd == operatingCMD && (aCells[fields] as FormEmpty).param < 6)
				if ((aCells[fields] as FormEmpty).cmd == operatingCMD)
					(aCells[fields] as FormEmpty).disabled = b;
			}
			
			if (b) {
				st1.textColor = COLOR.SATANIC_INVERT_GREY;
				st2.textColor = COLOR.SATANIC_INVERT_GREY;
				if (hider)
					hider.textColor = COLOR.SATANIC_INVERT_GREY;
			} else {
				st1.textColor = COLOR.BLACK;
				st2.textColor = COLOR.BLACK;
				if (hider)
					hider.textColor = COLOR.BLACK;
			}
		}
	}
}
import components.interfaces.IDataAdapter;
import components.interfaces.IFormString;
import components.screens.ui.UIRadioSystem;

class SensorTimeAdapter implements IDataAdapter
{
	public function adapt(value:Object):Object
	{
		if (value == UIRadioSystem.sensortime_active)
			return 1;
		return 0;
	}
	public function change(value:Object):Object
	{
		return value;
	}
	public function perform(field:IFormString):void	{	}
	public function recover(value:Object):Object
	{
		if (value == true)
			return UIRadioSystem.sensortime_active;
		return 0;
	}
}
class CheckBoxAdapter implements IDataAdapter
{
	public function adapt(value:Object):Object
	{
		if (int(value) > 0)  
			return 1;
		return 0;
	}
	public function change(value:Object):Object
	{
		return value;
	}
	public function perform(field:IFormString):void	{	}
	public function recover(value:Object):Object
	{
		if (value == true)
			return 1
		return 0;
	}
}