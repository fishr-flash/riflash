package components.screens.opt
{
	import flash.display.Bitmap;
	
	import components.abstract.GroupOperator;
	import components.abstract.RegExpCollection;
	import components.abstract.functions.loc;
	import components.abstract.servants.BitMasterMind;
	import components.basement.OptionsBlock;
	import components.gui.Header;
	import components.gui.fields.FSCheckBox;
	import components.gui.fields.FSComboBox;
	import components.gui.fields.FSComboCheckBox;
	import components.gui.fields.FSShadow;
	import components.interfaces.IFormString;
	import components.protocol.statics.OPERATOR;
	import components.static.CMD;
	import components.system.Library;
	import components.system.UTIL;
	
	public class OptOutPatternRdk extends OptionsBlock
	{
		private var go:GroupOperator;
		
		private var T_TRINKET:int=6;
		private var T_SENSOR:int=7;
		private var T_REPEATER:int=8;
		
		private var bitmaps:Vector.<Bitmap>;
		private var bitmmSen:BitMasterMind;
		private var bitmmRep:BitMasterMind;
		
		public function OptOutPatternRdk(str:int)
		{
			super();
			
			go = new GroupOperator;
			
			structureID = str;
			
			var sh:int = 250;
			var w:int = 250;
			
			/*** TRINKET	******************************/
			/** Команда CTRL_TEMPLATE_RCTRL - шаблон для выходов, кнопки от брелока

				Параметр 1 - Брелоки для управления. битовое поле, биты 0..31 - брелоки с номерами 1..32 соответственно. бит=0-брелок не используется в шаблоне, бит=1-брелок используется в шаблоне.
				Параметр 2 - Действие с выходом при нажатии кнопки ""Замок закрыт"":
				....0 - Выключить
				....1 - Включить
				....2 - Включить на время
				....3 - Включить с частотой 1Гц
				....4 - Включить на время с частотой 1Гц
				Параметры 3,4 - время включения (ММ:СС), параметр 3 - минуты (00-99), параметр 4 - секунды (00-59)
				Параметр 5 - Действие с выходом при нажатии кнопки ""Замок открыт"".
				....0 - Выключить
				....1 - Включить
				....2 - Включить на время
				....3 - Включить с частотой 1Гц
				....4 - Включить на время с частотой 1Гц
				Параметры 6,7 - время включения (ММ:СС), параметр 6 - минуты (00-99), параметр 7 - секунды (00-59)
				Параметр 8 - Действие с выходом при нажатии кнопки ""Замок открыт"".
				....0 - Выключить
				....1 - Включить
				....2 - Включить на время
				....3 - Включить с частотой 1Гц
				....4 - Включить на время с частотой 1Гц
				Параметры 9,10 - время включения (ММ:СС), параметр 6 - минуты (00-99), параметр 7 - секунды (00-59)	*/
			
			var shittime:int = 50;
			var wtime:int = 70;
			
			var h:Header = new Header( [{label:loc("ui_part_action"),xpos:0, width:200},{label:loc("alarm_run_command"), xpos:sh, width:200}], {size:12, border:false, align:"left"} );
			addChild( h );
			go.add(T_TRINKET.toString(), h );
			globalY += 30;
			
			addui( new FSComboCheckBox, CMD.CTRL_TEMPLATE_RCTRL, loc("out_trinket_ctrl"), null, 1 );
			attuneElement(sh,w);
			(getLastElement() as FSComboCheckBox).turnToBitfield = turnToBitfield;
			go.add(T_TRINKET.toString(), getLastElement() );
			
			var l:Array = UTIL.getComboBoxList([[0, loc("g_switchoff")],[1,loc("g_switchon")],[2,loc("g_switchon_time")],[3, loc("out_switchon_1hz")],[4,loc("g_switchon_1hz")]]);
			var ltime:Array = UTIL.getComboBoxList([["01:00","01:00"],["05:00","05:00"],["10:00","10:00"],["30:00","30:00"]]);
			
			go.add(T_TRINKET.toString(), addBitmap(Library.cLock, sh - 30) );
			addui( new FSComboBox, CMD.CTRL_TEMPLATE_RCTRL, loc("out_onclick_action"), onClick, 2, l );
			attuneElement(sh,w, FSComboBox.F_COMBOBOX_NOTEDITABLE);
			go.add(T_TRINKET.toString(), getLastElement() );
			addui( new FSComboBox, CMD.CTRL_TEMPLATE_RCTRL, loc("out_switchon_time"), null, 3, ltime, "0-9", 5, new RegExp(RegExpCollection.REF_0002to9959) ).x = shittime;
			go.add(T_TRINKET.toString(), getLastElement() );
			attuneElement(sh + (w-(wtime+shittime)),wtime, FSComboBox.F_COMBOBOX_TIME );
			
			go.add(T_TRINKET.toString(), addBitmap(Library.cUnlock, sh - 30) );
			addui( new FSComboBox, CMD.CTRL_TEMPLATE_RCTRL, loc("out_onclick_action"), onClick, 5, l );
			attuneElement(sh,w, FSComboBox.F_COMBOBOX_NOTEDITABLE);
			go.add(T_TRINKET.toString(), getLastElement() );
			addui( new FSComboBox, CMD.CTRL_TEMPLATE_RCTRL, loc("out_switchon_time"), null, 6, ltime, "0-9", 5, new RegExp(RegExpCollection.REF_0002to9959) ).x = shittime;
			go.add(T_TRINKET.toString(), getLastElement() );
			attuneElement(sh + (w-(wtime+shittime)),wtime, FSComboBox.F_COMBOBOX_TIME );
			
			go.add(T_TRINKET.toString(), addBitmap(Library.cStar, sh - 30) );
			addui( new FSComboBox, CMD.CTRL_TEMPLATE_RCTRL, loc("out_onclick_action"), onClick, 8, l );
			attuneElement(sh,w, FSComboBox.F_COMBOBOX_NOTEDITABLE);
			go.add(T_TRINKET.toString(), getLastElement() );
			addui( new FSComboBox, CMD.CTRL_TEMPLATE_RCTRL, loc("out_switchon_time"), null, 9, ltime, "0-9", 5, new RegExp(RegExpCollection.REF_0002to9959) ).x = shittime;
			go.add(T_TRINKET.toString(), getLastElement() );
			attuneElement(sh + (w-(wtime+shittime)),wtime, FSComboBox.F_COMBOBOX_TIME );
			
			/*** SENSOR	**********************************/
			
			globalY = 0;
			
			addui( new FSComboCheckBox, CMD.CTRL_TEMPLATE_RFSENSALARM, loc("rfd_sensors"), null, 1 );
			attuneElement(sh,w);
			(getLastElement() as FSComboCheckBox).turnToBitfield = turnToBitfield;
			go.add(T_SENSOR.toString(), getLastElement() );
			
			/**	Команда CTRL_TEMPLATE_RFSENSALARM - шаблон ""Тревоги от радиодатчиков""
				Параметр 1 - Радиодатчики, по которым срабатывает шаблон, битовое поле, биты 0..31 - радиодатчики с номерами 1..32 соответственно, 0-радиодатчик не использвется в шаблоне, 1-радиодатчик используется в шаблоне.
				Параметр 2 - Тревоги, на которые реагирует выход, битовое поле, бит 0 - Основная зона, бит 1 - дополнительный шлейф, бит 2 - тамперный контакт, бит 3 - Разряд батареи, бит 4 - автотест не прошел.
				Параметры 3,4 - время включения (ММ:СС), параметр 3 - минуты (00-99), параметр 4 - секунды (00-59)*/

			bitmmSen = new BitMasterMind(structureID);
			
			addui( new FSShadow, CMD.CTRL_TEMPLATE_RFSENSALARM, "", null, 2 );
			bitmmSen.addContainer( getLastElement() );
			
			addui( new FSCheckBox, 0, loc("out_sensor_main_zone"), null, 1 );
			attuneElement(sh+w-13);
			bitmmSen.addController( getLastElement(), 2, 0 );
			go.add(T_SENSOR.toString(), getLastElement() );
			addui( new FSCheckBox, 0, loc("out_sensor_additional_wire"), null, 2 );
			attuneElement(sh+w-13);
			go.add(T_SENSOR.toString(), getLastElement() );
			bitmmSen.addController( getLastElement(), 2, 1 );
			addui( new FSCheckBox, 0, loc("out_sensor_tamper"), null, 3 );
			attuneElement(sh+w-13);
			go.add(T_SENSOR.toString(), getLastElement() );
			bitmmSen.addController( getLastElement(), 2, 2 );
			addui( new FSCheckBox, 0, loc("out_sensor_battery"), null, 4 );
			attuneElement(sh+w-13);
			go.add(T_SENSOR.toString(), getLastElement() );
			bitmmSen.addController( getLastElement(), 2, 3 );
			addui( new FSCheckBox, 0, loc("out_sensor_autotest_fail"), null, 5 );
			attuneElement(sh+w-13);
			go.add(T_SENSOR.toString(), getLastElement() );
			bitmmSen.addController( getLastElement(), 2, 4 );
			
			addui( new FSComboBox, CMD.CTRL_TEMPLATE_RFSENSALARM, loc("out_switchon_time"), null, 3,  ltime, "0-9", 5, new RegExp(RegExpCollection.REF_0002to9959) );
			attuneElement(sh + (w-(wtime)),wtime, FSComboBox.F_COMBOBOX_TIME );
			go.add(T_SENSOR.toString(), getLastElement() );
			
			/*** REPEATER	******************************/

			globalY = 0;
			
			addui( new FSComboCheckBox, CMD.CTRL_TEMPLATE_RFSENSSTATE, loc("rfd_sensors"), null, 1 );
			attuneElement(sh,w);
			(getLastElement() as FSComboCheckBox).turnToBitfield = turnToBitfield;
			go.add(T_REPEATER.toString(), getLastElement() );
			
			/**	Команда CTRL_TEMPLATE_RFSENSSTATE - шаблон ""Повторитель состояния радиодатчиков""

				Параметр 1 - Радиодатчики, по которым срабатывает шаблон, битовое поле, биты 0..31 - радиодатчики с номерами 1..32 соответственно, 0-радиодатчик не использвется в шаблоне, 1-радиодатчик используется в шаблоне.
				Параметр 2 - Тревоги, на которые реагирует выход, битовое поле, бит 0 - Основная зона, бит 1 - дополнительный шлейф, бит 2 - тамперный контакт, бит 3 - Разряд батареи, бит 4 - автотест не прошел. */
			
			bitmmRep = new BitMasterMind(structureID);
			
			addui( new FSShadow, CMD.CTRL_TEMPLATE_RFSENSSTATE, "", null, 2 );
			bitmmRep.addContainer( getLastElement() );
			
			addui( new FSCheckBox, 0, loc("out_sensor_main_zone"), null, 1 );
			attuneElement(sh+w-13);
			bitmmRep.addController( getLastElement(), 2, 0 );
			go.add(T_REPEATER.toString(), getLastElement() );
			addui( new FSCheckBox, 0, loc("out_sensor_additional_wire"), null, 2 );
			attuneElement(sh+w-13);
			go.add(T_REPEATER.toString(), getLastElement() );
			bitmmRep.addController( getLastElement(), 2, 1 );
			addui( new FSCheckBox, 0, loc("out_sensor_tamper"), null, 3 );
			attuneElement(sh+w-13);
			go.add(T_REPEATER.toString(), getLastElement() );
			bitmmRep.addController( getLastElement(), 2, 2 );
			addui( new FSCheckBox, 0, loc("out_sensor_battery"), null, 4 );
			attuneElement(sh+w-13);
			go.add(T_REPEATER.toString(), getLastElement() );
			bitmmRep.addController( getLastElement(), 2, 3 );
			addui( new FSCheckBox, 0, loc("out_sensor_autotest_fail"), null, 5 );
			attuneElement(sh+w-13);
			go.add(T_REPEATER.toString(), getLastElement() );
			bitmmRep.addController( getLastElement(), 2, 4 );
			
		}
		public function open(n:int):void
		{
			//go.show(n.toString());
			go.activate(n.toString());
			
			switch(n) {
				case T_TRINKET:
					(getField(CMD.CTRL_TEMPLATE_RCTRL,1) as FSComboCheckBox).setList( 
						getCCBlist( OPERATOR.getData(CMD.CTRL_TEMPLATE_RCTRL)[structureID-1][0], loc("g_trinket") ));
					getField(CMD.CTRL_TEMPLATE_RCTRL,2).setCellInfo( OPERATOR.getData(CMD.CTRL_TEMPLATE_RCTRL)[structureID-1][1] );
					getField(CMD.CTRL_TEMPLATE_RCTRL,3).setCellInfo( mergeIntoTime( OPERATOR.getData(CMD.CTRL_TEMPLATE_RCTRL)[structureID-1][2],
						OPERATOR.getData(CMD.CTRL_TEMPLATE_RCTRL)[structureID-1][3] ));
					getField(CMD.CTRL_TEMPLATE_RCTRL,5).setCellInfo( OPERATOR.getData(CMD.CTRL_TEMPLATE_RCTRL)[structureID-1][4] );
					getField(CMD.CTRL_TEMPLATE_RCTRL,6).setCellInfo( mergeIntoTime( OPERATOR.getData(CMD.CTRL_TEMPLATE_RCTRL)[structureID-1][5],
						OPERATOR.getData(CMD.CTRL_TEMPLATE_RCTRL)[structureID-1][6] ));
					getField(CMD.CTRL_TEMPLATE_RCTRL,8).setCellInfo( OPERATOR.getData(CMD.CTRL_TEMPLATE_RCTRL)[structureID-1][7] );
					getField(CMD.CTRL_TEMPLATE_RCTRL,9).setCellInfo( mergeIntoTime( OPERATOR.getData(CMD.CTRL_TEMPLATE_RCTRL)[structureID-1][8],
						OPERATOR.getData(CMD.CTRL_TEMPLATE_RCTRL)[structureID-1][9] ));
					
					onClick(null);
					
					break;
				case T_SENSOR:
					(getField(CMD.CTRL_TEMPLATE_RFSENSALARM,1) as FSComboCheckBox).setList( 
						getCCBlist( OPERATOR.getData(CMD.CTRL_TEMPLATE_RFSENSALARM)[structureID-1][0], loc("rfd_sensor") ));
					bitmmSen.putArray( OPERATOR.getData(CMD.CTRL_TEMPLATE_RFSENSALARM)[structureID-1], CMD.CTRL_TEMPLATE_RFSENSALARM);
					getField(CMD.CTRL_TEMPLATE_RFSENSALARM,3).setCellInfo( mergeIntoTime( OPERATOR.getData(CMD.CTRL_TEMPLATE_RFSENSALARM)[structureID-1][2],
						OPERATOR.getData(CMD.CTRL_TEMPLATE_RFSENSALARM)[structureID-1][3] ));
					break;
				case T_REPEATER:
					
					(getField(CMD.CTRL_TEMPLATE_RFSENSSTATE,1) as FSComboCheckBox).setList( 
						getCCBlist( OPERATOR.getData(CMD.CTRL_TEMPLATE_RFSENSSTATE)[structureID-1][0], loc("rfd_sensor") ));
					bitmmRep.putArray( OPERATOR.getData(CMD.CTRL_TEMPLATE_RFSENSSTATE)[structureID-1], CMD.CTRL_TEMPLATE_RFSENSSTATE);
					break;
			}
			
		}
		private function getCCBlist(bf:int, itemttl:String):Array
		{
			var list:Array = new Array;
			var code_all:int = 0xFFFFFFFF;
			list.push( {"label":loc("g_all"), "data":0, "trigger": FSComboCheckBox.TRIGGER_SELECT_ALL, "senddata":code_all } );
			
			var select_all:Boolean = false;
			var select:int;
			for (var i:int=0; i<32; i++) {
				select = UTIL.isBit(i,bf) ?1:0;
				
				list.push( {"labeldata":(i+1), 
					"label":itemttl+ " " + (i+1), 
					"data":select } );
			}
			return list;
		}
		private function turnToBitfield( arr:Array ):int
		{
			var num:int = 0;
			var len:int = arr.length;
			for (var i:int=0; i<len; i++) {
				num |= (1<< int(arr[i]-1));
			}
			return num;
		}
		
		/*** TRINKET	******************************/
		
		private function onClick(t:IFormString):void
		{
			getField(CMD.CTRL_TEMPLATE_RCTRL,3).disabled = int(getField(CMD.CTRL_TEMPLATE_RCTRL,2).getCellInfo())!=4 && int(getField(CMD.CTRL_TEMPLATE_RCTRL,2).getCellInfo())!=2;
			getField(CMD.CTRL_TEMPLATE_RCTRL,6).disabled = int(getField(CMD.CTRL_TEMPLATE_RCTRL,5).getCellInfo())!=4 && int(getField(CMD.CTRL_TEMPLATE_RCTRL,5).getCellInfo())!=2;
			getField(CMD.CTRL_TEMPLATE_RCTRL,9).disabled = int(getField(CMD.CTRL_TEMPLATE_RCTRL,8).getCellInfo())!=4 && int(getField(CMD.CTRL_TEMPLATE_RCTRL,8).getCellInfo())!=2;
			if (t)
				remember(t);
		}
		private function addBitmap(cls:Class, xpos:int):Bitmap
		{
			if (!bitmaps)
				bitmaps = new Vector.<Bitmap>(3);
			bitmaps.push(new cls);
			var index:int = bitmaps.length-1;
			addChild( bitmaps[index] );
			bitmaps[index].x = xpos;
			bitmaps[index].y = globalY;
			return bitmaps[index];
		}
		
		/*** SENSOR	**********************************/
		/*** REPEATER	******************************/
	}
}