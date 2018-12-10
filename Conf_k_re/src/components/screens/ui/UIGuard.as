package components.screens.ui
{
	import components.abstract.adapters.HexAdapter;
	import components.abstract.functions.loc;
	import components.abstract.servants.TaskManager;
	import components.basement.OptionsBlock;
	import components.basement.UI_BaseComponent;
	import components.gui.Header;
	import components.gui.fields.FSComboBox;
	import components.gui.fields.FSSimple;
	import components.gui.fields.FormString;
	import components.gui.triggers.TextButton;
	import components.interfaces.ITask;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.static.CMD;
	import components.static.COLOR;
	import components.system.UTIL;
	
	public class UIGuard extends UI_BaseComponent
	{
		private var opts:Vector.<OptionsBlock>;
		private var bGuard:TextButton;
		private var task:ITask;
		private var fstate:FormString;
		private var onguard:Boolean = false;
		
		private const REF_17to98:String = "^((1[7-9]|[2-8]\\d|9[0-8]))$";;
		private const STATE:Array = [loc("guard_unkwn"),loc("guard_off"),loc("guard_on"),loc("guard_alarm_24"),loc("guard_delay"),loc("guard_offline"),
			loc("guard_err_nopart"),loc("guard_err_cmd"),loc("guard_alarm")];
		
		public function UIGuard()
		{
			super();
			
			var sh:int = 220;
			var w:int = 200;
			
			fstate = addui( new FSSimple, 0, loc("guard_status"), null, 1 ) as FormString;
			attuneElement( sh-20, w+50, FSSimple.F_CELL_NOTSELECTABLE | FSSimple.F_CELL_ALIGN_LEFT );
			
			bGuard = new TextButton;
			addChild( bGuard );
			bGuard.x = globalX + sh-20;
			bGuard.y = globalY;
			bGuard.setUp( "", onGuard );
			
			addui( new FormString, 0, loc("guard_control"), null, 2 );
			attuneElement( sh, w, FormString.F_NOTSELECTABLE );
			
			drawSeparator();
			
			addui( new FSSimple, CMD.OBJECT, loc("options_objnum"), null, 1, null, "A-Fa-f0-9", 4 );
			getLastElement().setAdapter( new HexAdapter );
			attuneElement( sh+30, 60);
			var l:Array = UTIL.comboBoxNumericDataGenerator(17,98);
			addui( new FSComboBox, CMD.LAN_PART, loc("guard_partnum"), null, 1, l, "0-9", 2, new RegExp(REF_17to98) );
			attuneElement( sh+30, 61, FSComboBox.F_ALIGN_CENTER )
			
			var h:Header = new Header( [{label:loc("guard_zonenum"),xpos:80,width:150},{label:loc("guard_norm"), xpos:211-25,width:200}], {size:11, align:"center"} );
			addChild( h );
			h.y = globalY;
			globalY+= 30;
			
			opts = new Vector.<OptionsBlock>;
			
			var opt:OptLocalWire;
			
			for (var i:int=0; i<2; i++) {
				opt = new OptLocalWire(i+1);
				addChild( opt );
				opt.x = globalX;
				opt.y = globalY;
				globalY += 30;
				opts.push(opt);
			}
			
			starterCMD = [CMD.LAN_PART, CMD.OBJECT, CMD.LAN_ZONE];
		}
		override public function close():void
		{
			super.close();
			if (task)
				task.stop();
		}
		override public function put(p:Package):void
		{
			switch(p.cmd) {
				case CMD.OBJECT:
				case CMD.LAN_PART:
					pdistribute(p);
					break;
				case CMD.LAN_ZONE:
					opts[0].putData(p);
					opts[1].putData(p);
					bGuard.disabled = true;
					loadComplete();
					
					/** Команда PART_FUNCT
						Команда для работы с разделом
						Параметр 1 - номер строки  (индекс раздела), соответствующий PARTITION, в которой хранится(хранился) раздел Контакт-LAN(только 17)
						Параметр 2 - команда разделу ( 0 - нет команды, 1 - взять на охрану, 2 - снять с охраны, 3 - запросить состояние раздела ( меняет PART_STATE ), 4-прибору перечитать информацию по разделу (меняет PART_STATE_ALL)*/					
					if (!task)
						task = TaskManager.callLater( request, TaskManager.DELAY_2SEC ); 
					else
						task.repeat();
					RequestAssembler.getInstance().fireEvent( new Request(CMD.PART_FUNCT, null, 1, [17,4]));
					
					break;
				case CMD.PART_STATE_ALL:
					
					bGuard.disabled = false;
					
					/** Команда PART_STATE_ALL - состояние всех разделов ( 16 структур для К16 и K5, 8 структур для К14 )
						Прибор меняет значения принудительно по запросу и самостоятельно при изменениях в разделах.

						Параметр 1 - текущее состояние раздела. Индекс раздела соответствует разделу из PARTITION. состояние раздела ( 
						 * 0x00 - неизвестное состояние, 
						 * 0x01 - снят с охраны, 
						 * 0x02 - под охраной, 
						 * 0x03 - тревога (охранная и пожарная) в разделе не под охраной (24 часа), 
						 * 0x04 - отсчет задержки, 0x05 - нет связи (для сетевых разделов), 
						 * 0x06 - ошибка, нет раздела; 
						 * 0x07 - ошибка команды разделу; 
						 * 0x08 - тревога (охранная и пожарная) под охраной);"	*/
					
					var st:int = p.getValidStructure()[0];
					var c:int;
					
					onguard = st == 2;
					if (onguard)
						bGuard.setName(loc("ui_part_off_guard"));
					else
						bGuard.setName(loc("ui_part_on_guard"));
					
					switch(st) {
						case 0:
						case 1:
						case 4:
							c = COLOR.YELLOW_SIGNAL;
							break;
						case 2:
							c = COLOR.GREEN;
							break;
						case 3:
						case 6:
						case 7:
						case 8:
							c = COLOR.RED;
							break;
						default:
							c = COLOR.YELLOW_SIGNAL;
							st = 0;
							break;
					}
					
					fstate.setTextColor( c );
					fstate.setCellInfo( STATE[st] );
					
					if (visible) {
						RequestAssembler.getInstance().fireEvent( new Request(CMD.PART_FUNCT, null, 1, [17,4]));
						task.repeat();
					}
					break;
			}
		}
		public function request():void
		{
			RequestAssembler.getInstance().fireEvent( new Request(CMD.PART_STATE_ALL, put, 17 ));
		}
		private function onGuard():void
		{
			if( onguard ) {
				RequestAssembler.getInstance().fireEvent( new Request(CMD.PART_FUNCT, null, 1, [17,2]));
			} else
				RequestAssembler.getInstance().fireEvent( new Request(CMD.PART_FUNCT, null, 1, [17,1]));
			bGuard.disabled = true;
		}
	}
}
import components.abstract.RegExpCollection;
import components.abstract.functions.loc;
import components.basement.OptionsBlock;
import components.gui.fields.FSComboBox;
import components.gui.fields.FSSimple;
import components.protocol.Package;
import components.static.CMD;
import components.system.UTIL;

class OptLocalWire extends OptionsBlock
{
	public function OptLocalWire(s:int)
	{
		super();
		
		structureID = s;
		
		FLAG_VERTICAL_PLACEMENT = false;
		
		addui( new FSSimple, CMD.LAN_ZONE, loc("rfd_wire")+" "+s, null, 1, null, "0-9",3, new RegExp(RegExpCollection.REF_0to255) );
		attuneElement( 100, 50 );
			
		var l:Array = UTIL.getComboBoxList([[0,loc("guard_wire_opened")],[1,loc("guard_wire_closed")]]);
		addui( new FSComboBox, CMD.LAN_ZONE, "", null, 2, l ).x = 150+51;
		attuneElement( 0, 110, FSComboBox.F_COMBOBOX_NOTEDITABLE );
	}
	override public function putData(p:Package):void
	{
		pdistribute(p);
	}
}