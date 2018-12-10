package components.screens.opt
{
	import components.abstract.functions.loc;
	import components.basement.OptionsBlock;
	import components.gui.Header;
	import components.gui.SimpleTextField;
	import components.gui.fields.FSComboBox;
	import components.gui.fields.FSShadow;
	import components.gui.fields.FormString;
	import components.gui.triggers.TextButton;
	import components.gui.visual.Separator;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.static.CMD;
	import components.static.COLOR;
	
	public class OptRele extends OptionsBlock
	{
		private var buttons:Vector.<TextButton>;
		private var tAnnotation:SimpleTextField;
		
		private const picXpos:int = 10;
		private const picYpos:int = 290;
		
		private var bitfield_start:int;
		private var bitfield_action:int;
		private const total_out:int = 5; 
		
		public function OptRele()
		{
			super();
			structureID = 1;
			
			var header:Header = new Header( [{label:loc("g_element"),xpos:15},{label:loc("rf_relay_element_state"), xpos:110},
				{label:loc("rf_relay_change_state"),  xpos:230} ],
				{size:11, leading:0} );
			
			addChild( header );
			header.y = 10;
			
			var i:int;
			yshift = 1;
			FLAG_SAVABLE = false;
			
			/** Колонка 1 */
			globalY = 50;
			globalX = 20;
			for( i=0; i<total_out; ++i ) {
				createUIElement( new FormString, 1, loc("rfd_output")+(i+1),null,i+2);				
			}
			var sep:Separator = new Separator(320);
			addChild( sep );
			sep.y = globalY+15;
			sep.x = globalX-20;
			
			/** Колонка 2 */
			globalY = 50;
			globalX = 110;
			for( i=0; i<total_out; ++i ) {
				createUIElement( new FormString, 2, loc("g_unknown").toLowerCase(),null,i+2);				
			}
			/** Колонка 3 */
			buttons = new Vector.<TextButton>;
			globalY = 50;
			globalX = 230;
			var but:TextButton;
			for( i=0; i<total_out; ++i ) {
				but = new TextButton;
				addChild( but );
				but.setUp( loc("g_switchon"), switchState, i );
				but.x = globalX;
				but.y = globalY;
				but.data = 0;
				globalY += 23;
				buttons.push( but );
			}
			
			FLAG_SAVABLE = true;
			createUIElement( new FSShadow, operatingCMD, "", null, 1 );
		}
		private function state_start(num:int):void
		{
			var field:FSComboBox = getField( 4, num+1 ) as FSComboBox;
			var param:FSShadow = getField(operatingCMD,1) as FSShadow;
			if( field.getCellInfo() == "1" ) {
				bitfield_start |= (1<<num);					
			} else {
				bitfield_start &= ~(1<<num);
			}
			param.setCellInfo( bitfield_start.toString() );
			remember( param );
		}
		override public function putState(re:Array):void
		{
			/**	Команда RELAY_STATE - состояние выходов
			 * Параметр 1 - битовое поле, бит 0 - выход 1 ( 0 - выключен, 1 - включен ), 
			 * 		бит 1 - выход 2 ( 0 - выключен, 1 - включен ), 
			 * 		бит 2 - выход 3 ( 0 - выключен, 1 - включен ), 
			 * 		бит 3 - выход 4 ( 0 - выключен, 1 - включен ), 
			 * 		бит 4 - выход 5 ( 0 - выключен, 1 - включен ) */
			
			var bitfield:int = re[0];
			var i:int;
			var field:FormString;
			
			for(i=0;i<total_out;++i) {
				field = getField(2,i+2) as FormString;
				if( (bitfield & (1 << i)) > 0 ) {
					field.setCellInfo(loc("g_enabled_m").toLowerCase());
					field.setTextColor( COLOR.GREEN );
					(buttons[i] as TextButton).setName( loc("g_switchoff") );
					(buttons[i] as TextButton).data = 1;
				} else {
					field.setCellInfo(loc("g_disabled_m").toLowerCase());
					field.setTextColor( COLOR.RED );
					(buttons[i] as TextButton).setName( loc("g_switchon") );
					(buttons[i] as TextButton).data = 0;
				}
			}
		}
		private function switchState(num:int):void
		{
			/** Команда RELAY_FUNCT - команда выходу включить/выключить и запросить состояние;
			 * 	Параметр 1 - Запросить состояние выходов ( 0- нет, 1-запросить - ответ в OUT_STATE и OUT_CTRL_STATE);
			 * 	Параметр 2 - Включить выходы бит 0 - выход 1, бит 1 - выход 2, бит 2 - выход 3, бит 3 - выход 4, бит 4 - выход 5 (для включения устанавливаем бит в 1);
			 * 	Параметр 3 - Выключить выходы бит 0 - выход 1, бит 1 - выход 2, бит 2 - выход 3, бит 3 - выход 4, бит 4 - выход 5 (для включения устанавливаем бит в 1);
			 * 	Параметр 4 - Изменить состояние выхода на противоположное бит 0 - выход 1, бит 1 - выход 2, бит 2 - выход 3, бит 3 - выход 4, бит 4 - выход 5 (для переключения устанавливаем бит в 1); */
			
			var bit:int;
			var a:Array;
			bit |= (1 << num);
			if( (buttons[num] as TextButton).data == 0 )
				a = [0,bit,0,0];
			else
				a = [0,0,bit,0];
			
			RequestAssembler.getInstance().fireEvent( new Request( CMD.RELAY_FUNCT, null, 1, a ));
		}
	}
}