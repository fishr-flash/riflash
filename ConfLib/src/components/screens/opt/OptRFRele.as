package components.screens.opt
{
	import flash.display.Bitmap;
	import flash.display.MovieClip;
	import flash.events.Event;
	
	import components.abstract.functions.loc;
	import components.basement.OptionsBlock;
	import components.basement.UIRadioDeviceRoot;
	import components.gui.Header;
	import components.gui.SimpleTextField;
	import components.gui.fields.FSComboBox;
	import components.gui.fields.FSShadow;
	import components.gui.fields.FormString;
	import components.gui.triggers.TextButton;
	import components.gui.visual.Separator;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.static.CMD;
	import components.static.COLOR;
	import components.static.GuiLib;
	import components.system.SavePerformer;
	
	public class OptRFRele extends OptionsBlock
	{
		private var pics:Object = new Object;
		private var pic_rele:Bitmap;
		private var buttons:Vector.<TextButton>;
		private var tAnnotation:SimpleTextField;
		
		private const picXpos:int = 10;
		private const picYpos:int = 290;
		
		private var bitfield_start:int;
		private var bitfield_action:int;
		
		public function OptRFRele()
		{
			super();
			
			var header:Header = new Header( [{label:loc("g_element"),xpos:15},{label:loc("rf_relay_element_state"), xpos:110},
				{label:loc("rf_relay_change_state"),  xpos:230}, {label:loc("rf_relay_default_state"), xpos:372}, 
				{label:loc("rf_relay_action_when_go_offline"), xpos:500}],
				{size:11, leading:0} );
			
			addChild( header );
			header.y = 10;
			
			var i:int;
			yshift = 1;
			FLAG_SAVABLE = false;
			
			/** Колонка 1 */
			globalY = 50;
			globalX = 20;
			createUIElement( new FormString, 1, loc("rfd_wire"),null,1);
			globalY += 15;
			for( i=0; i<6; ++i ) {
				createUIElement( new FormString, 1, loc("rfd_output")+(i+1),null,i+2);				
			}
			var sep:Separator = new Separator(600);
			addChild( sep );
			sep.y = globalY+15;
			sep.x = globalX;
			
			/** Колонка 2 */
			globalY = 50;
			globalX = 110;
			createUIElement( new FormString, 2, loc("g_wire_closed"),null,1);
			globalY += 15;
			for( i=0; i<6; ++i ) {
				createUIElement( new FormString, 2, loc("g_unknown").toLowerCase(),null,i+2);				
			}
			/** Колонка 3 */
			buttons = new Vector.<TextButton>;
			globalY = 50;
			globalX = 230;
			createUIElement( new FormString, 3, loc("g_no_action"),null,1);
			globalY += 15;
			var but:TextButton;
			for( i=0; i<6; ++i ) {
				but = new TextButton;
				addChild( but );
				but.setUp( loc("g_switchon"), switchState, i );
				but.x = globalX;
				but.y = globalY;
				but.data = 0;
				globalY += 23;
				buttons.push( but );
			}
			yshift = 0;
			/** Колонка 4 */
			globalY = 50;
			globalX = 360;
			createUIElement( new FormString, 4, loc("g_wire_closed"),null,0).x = 375;
			globalY += 15;
			var cblist:Array = [{label:loc("g_disabled_m"), data:0},{label:loc("g_enabled_m"), data:1}];
			for( i=0; i<6; ++i ) {
				createUIElement( new FSComboBox, 4, "", state_start, i+1, cblist );
				attuneElement( NaN, NaN, FSComboBox.F_COMBOBOX_NOTEDITABLE );
				getLastElement().setId( i+1 );
			}
			/** Колонка 5 */
			globalY = 50;
			globalX = 500;
			createUIElement( new FormString, 5, loc("g_no_action"),null,0);
			globalY += 15;
			cblist = [{label:loc("g_switchoff"), data:0},{label:loc("g_no_action"), data:1}];
			for( i=0; i<6; ++i ) {
				createUIElement( new FSComboBox, 5, "", state_action, i+1, cblist );
				attuneElement( NaN, NaN, FSComboBox.F_COMBOBOX_NOTEDITABLE );
				getLastElement().setId( i+1 );
			}			

			FLAG_SAVABLE = true;
			
			operatingCMD = CMD.RFRELAY_INIT;
			createUIElement( new FSShadow, operatingCMD, "", null, 1 );
			createUIElement( new FSShadow, operatingCMD, "", null, 2 );
			createUIElement( new FSShadow, operatingCMD, "", null, 3 );
			
			pic_rele = new GuiLib.cRele;
			addChild( pic_rele );
			pic_rele.y = picYpos + 20;
			pic_rele.x = picXpos + 50;
			
			pics["relay1"] = new GuiLib.cRelay;
			addChild( pics["relay1"] );
			pics["relay1"].x = picXpos + 90+45;
			pics["relay1"].y = picYpos + 387-45; 
			(pics["relay1"] as MovieClip).gotoAndStop(2);
			pics["relay1"].title.text = loc("rfd_output")+" 1";
			
			pics["relay2"] = new GuiLib.cRelay;
			addChild( pics["relay2"] );
			pics["relay2"].x = picXpos + 198+38;
			pics["relay2"].y = picYpos + 316; 
			(pics["relay2"] as MovieClip).gotoAndStop(2);
			pics["relay2"].title.text = loc("rfd_output")+" 2";
			
			pics["relay3"] = new GuiLib.cRelay;
			addChild( pics["relay3"] );
			pics["relay3"].x = picXpos + 266+28;
			pics["relay3"].y = picYpos + 316; 
			(pics["relay3"] as MovieClip).gotoAndStop(2);
			pics["relay3"].title.text = loc("rfd_output")+" 3";
			
			pics["relay4"] = new GuiLib.cRelay;
			addChild( pics["relay4"] );
			pics["relay4"].x = picXpos + 343+9;
			pics["relay4"].y = picYpos + 316; 
			(pics["relay4"] as MovieClip).gotoAndStop(2);
			pics["relay4"].title.text = loc("rfd_output")+" 4";
			
			pics["relay5"] = new GuiLib.cRelay;
			addChild( pics["relay5"] );
			pics["relay5"].x = picXpos + 410;
			pics["relay5"].y = picYpos + 316; 
			(pics["relay5"] as MovieClip).gotoAndStop(2);
			pics["relay5"].title.text = loc("rfd_output")+" 5";
			
			pics["relay6"] = new GuiLib.cRelay;
			addChild( pics["relay6"] );
			pics["relay6"].x = picXpos + 490-22;
			pics["relay6"].y = picYpos + 316; 
			(pics["relay6"] as MovieClip).gotoAndStop(2);
			pics["relay6"].title.text = loc("rfd_output")+" 6";
			
			pics["antenna"] = new GuiLib.cAntenna;
			addChild( pics["antenna"] );
			pics["antenna"].x = picXpos + 142;
			pics["antenna"].y = picYpos - 35; 
			
			pics["power"] = new GuiLib.cPower;
			addChild( pics["power"] );
			pics["power"].x = picXpos + 17;
			pics["power"].y = picYpos + 78; 
			
			pics["wire"] = new GuiLib.cWire;
			addChild( pics["wire"] );
			pics["wire"].x = picXpos + 75;
			pics["wire"].y = picYpos + 351; 
			(pics["wire"] as MovieClip).gotoAndStop(1);
			
			var annotation:String = loc("rf_relay_note");
			
			tAnnotation = new SimpleTextField( annotation );
			addChild( tAnnotation );
			tAnnotation.height = 80;
			tAnnotation.x = 20;
			tAnnotation.y = pic_rele.height + pic_rele.y + 70;
			
			pics["a1"] = new GuiLib.cCell;
			addChild( pics["a1"] );
			pics["a1"].x = picXpos + 142+21;
			pics["a1"].y = picYpos - 35+80; 
			pics["a1"].title.text = "1";
			
			pics["a2"] = new GuiLib.cCell;
			addChild( pics["a2"] );
			pics["a2"].x = picXpos + 17+152;
			pics["a2"].y = picYpos + 78 +47; 
			pics["a2"].title.text = "2";
			
			pics["a3"] = new GuiLib.cCell;
			addChild( pics["a3"] );
			pics["a3"].x = picXpos + 75;
			pics["a3"].y = picYpos + 351-42; 
			pics["a3"].title.text = "3";
			
			pics["a4"] = new GuiLib.cCell;
			addChild( pics["a4"] );
			pics["a4"].x = picXpos + 135 ;
			pics["a4"].y = picYpos + 387-45-57; 
			pics["a4"].title.text = "4";
			
			
			pics["a5"] = new GuiLib.cCell;
			addChild( pics["a5"] );
			pics["a5"].x = picXpos + 198+38;
			pics["a5"].y = picYpos + 295; 
			pics["a5"].title.text = "5";
			
			pics["a6"] = new GuiLib.cCell;
			addChild( pics["a6"] );
			pics["a6"].x = picXpos + 266+28;
			pics["a6"].y = picYpos + 295; 
			pics["a6"].title.text = "6";
			
			pics["a7"] = new GuiLib.cCell;
			addChild( pics["a7"] );
			pics["a7"].x = picXpos + 343+9;
			pics["a7"].y = picYpos + 295; 
			pics["a7"].title.text = "7";
			
			pics["a8"] = new GuiLib.cCell;
			addChild( pics["a8"] );
			pics["a8"].x = picXpos + 410;
			pics["a8"].y = picYpos + 295; 
			pics["a8"].title.text = "8";
			
			pics["a9"] = new GuiLib.cCell;
			addChild( pics["a9"] );
			pics["a9"].x = picXpos + 490-22;
			pics["a9"].y = picYpos + 295; 
			pics["a9"].title.text = "9";
			
			pics["a10"] = new GuiLib.cCell;
			addChild( pics["a10"] );
			pics["a10"].x = picXpos + 400 + 26;
			pics["a10"].y = picYpos + 20 + 38; 
			pics["a10"].title.text = "10";
		}
		private function state_start(num:int):void
		{
			var field:FSComboBox = getField( 4, num ) as FSComboBox;
			var param:FSShadow = getField(operatingCMD,2) as FSShadow;
			if( field.getCellInfo() == "1" ) {
				bitfield_start |= (1<<num);					
			} else {
				bitfield_start &= ~(1<<num);
			}
			param.setCellInfo( bitfield_start.toString() );
			SavePerformer.remember( getStructure(),param );
		}
		private function state_action(num:int):void
		{
			var field:FSComboBox = getField( 5, num ) as FSComboBox;
			var param:FSShadow = getField(operatingCMD,3) as FSShadow;
			if( field.getCellInfo() == "1" ) {
				bitfield_action |= (1<<num);					
			} else {
				bitfield_action &= ~(1<<num);
			}
			param.setCellInfo( bitfield_action.toString() );
			SavePerformer.remember( getStructure(),param );
		}
		override public function putData(p:Package):void
		{
			if(p.error)
				return;
			structureID = p.structure;//re[0]+1;
			globalFocusGroup = 200*(structureID-1)+50;
			old = Boolean( p.data[0]==2 );
			refreshCells(operatingCMD);
			/** Команда RFRELAY_INIT - начальное состояние выходов и действие при потере связи радиореле: 
				Параметр 1 - Наличие радиореле в приборе (0x00 - нет радиореле, 0x01 - есть радиореле; 0x02 - радиоустройство потеряно из-за новой радиостемы ); */
			
			getField( operatingCMD, 1).setCellInfo( p.data[0].toString() );
			
			/**	Параметр 2 - битовое поле, начальное состояние выходов, бит0 - резерв , 
			 * бит 1 - выход 1 ( 0 - выключен, 1 - включен ), 
			 * бит 2 - выход 2 ( 0 - выключен, 1 - включен ), 
			 * бит 3 - выход 3 ( 0 - выключен, 1 - включен ), 
			 * бит 4 - выход 4 ( 0 - выключен, 1 - включен ), 
			 * бит 5 - выход 5 ( 0 - выключен, 1 - включен ), 
			 * бит 6 - выход 6 ( 0 - выключен, 1 - включен ); */
			
			getField( operatingCMD, 2).setCellInfo( p.data[1].toString() );
			bitfield_start = p.data[1];
			var bitfield:int = p.data[1];
			var i:int;
			for(i=1;i<7;++i) {
				if( (bitfield & (1 << i)) > 0 )
					getField(4,i).setCellInfo("1");
				else
					getField(4,i).setCellInfo("0");
			}
			
			/**	Параметр 3 - битовое поле, действие при потере радиосвязи, бит0 - резерв, 
			 * бит 1 - выход 1 ( 0 - выключить, 1 - нет действия ),
			 * бит 2 - выход 2 ( 0 - выключить, 1 - нет действия ), 
			 * бит 3 - выход 3 ( 0 - выключить, 1 - нет действия ), 
			 * бит 4 - выход 4 ( 0 - выключить, 1 - нет действия ), 
			 * бит 5 - выход 5 ( 0 - выключить, 1 - нет действия ), 
			 * бит 6 - выход 6 ( 0 - выключить, 1 - нет действия ); */
			getField( operatingCMD, 3).setCellInfo( p.data[2].toString() );
			bitfield_action = p.data[2];
			bitfield = p.data[2];
			for(i=1;i<7;++i) {
				if( (bitfield & (1 << i)) > 0 )
					getField(5,i).setCellInfo("1");
				else
					getField(5,i).setCellInfo("0");
			}
			this.dispatchEvent( new Event( UIRadioDeviceRoot.EVENT_LOADED ));
		}
		override public function putState(re:Array):void
		{
			/**	Команда RFRELAY_STATE - состояние шлейфа и выходов радиореле (16 шт радиореле ):
			 * Параметр 1 - Состояние радиореле, битовое поле, бит1 - сработал дополнительный шлейф, бит2 - сработал тампер, бит3 - CPW, бит7 - радиореле потеряно;
			 * Параметр 2 - Состояние выходов радиореле, битовое поле, бит1 - Выход 1....бит6 - Выход 6, бит установлен - выход включен, бит сброшен - выход выключен; */
			
			var bitfield:int = re[1];
			var i:int;
			var field:FormString;
			
			for(i=0;i<6;++i) {
				field = getField(2,i+2) as FormString;
				if( (bitfield & (1 << (i+1))) > 0 ) {
					field.setCellInfo(loc("g_enabled_m").toLowerCase());
					field.setTextColor( COLOR.GREEN );
					(pics["relay"+(i+1)] as MovieClip).gotoAndStop(1);
					(buttons[i] as TextButton).setName( loc("g_switchoff") );
					(buttons[i] as TextButton).data = 1;
				} else {
					field.setCellInfo(loc("g_disabled_m").toLowerCase());
					field.setTextColor( COLOR.RED );
					(pics["relay"+(i+1)] as MovieClip).gotoAndStop(2);
					(buttons[i] as TextButton).setName( loc("g_switchon") );
					(buttons[i] as TextButton).data = 0;
				}
			}
			
			bitfield = re[0];
			field = getField(2,1) as FormString;
			if( (bitfield & (1 << 1)) > 0 ) {
				field.setCellInfo(loc("g_wire_open").toLowerCase());
				field.setTextColor( COLOR.RED );
				(pics["wire"] as MovieClip).gotoAndStop(2);
			} else {
				field.setCellInfo(loc("g_wire_closed").toLowerCase());
				field.setTextColor( COLOR.GREEN );
				(pics["wire"] as MovieClip).gotoAndStop(1);
			}
		}
		private function switchState(num:int):void
		{
			/** Команда RFRELAY_FUNCT - команда выходу включить/выключить и запросить состояние;
			 * 	Параметр 1 - Номер радиореле (1-16);
			 * 	Параметр 2 - Запросить состояние всех радиореле ( 0- нет, 1-запросить)
			 * 	Параметр 3 - Включить выходы радиореле бит0 - резерв, бит 1 - выход 1, бит 2 - выход 2,..., бит 6 - выход 6;
			 * 	Параметр 4 - Выключить выходы радиореле бит0 - резерв,  бит 1 - выход 1, бит 2 - выход 2,..., бит 6 - выход 6;
			 *	Параметр 5 - Изменить состояние выхода радиореле бит0 - резерв,  бит 1 - выход 1, бит 2 - выход 2,..., бит 6 - выход 6; */
			
			var bit:int;
			var a:Array;
			bit |= (1 << (num+1));
			if( (buttons[num] as TextButton).data == 0 )
				a = [getStructure(),0,bit,0,0];
			else
				a = [getStructure(),0,0,bit,0];
			
			RequestAssembler.getInstance().fireEvent( new Request( CMD.RFRELAY_FUNCT, null, 1, a ));
		}
	}
}