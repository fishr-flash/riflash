package components.screens.ui
{
	import components.abstract.functions.loc;
	import components.abstract.servants.CanServant;
	import components.abstract.servants.ResizeWatcher;
	import components.abstract.widget.CanWidget;
	import components.basement.UI_BaseComponent;
	import components.gui.PopUp;
	import components.gui.SimpleTextField;
	import components.gui.fields.FSBitwise;
	import components.gui.fields.FSComboBox;
	import components.gui.fields.FSShadow;
	import components.gui.fields.FSSimple;
	import components.gui.fields.FormString;
	import components.interfaces.IFormString;
	import components.interfaces.ITask;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.protocol.statics.OPERATOR;
	import components.resources.Resources;
	import components.static.CMD;
	import components.static.COLOR;
	import components.static.DS;
	import components.static.PAGE;
	import components.system.SavePerformer;
	import components.system.UTIL;
	
	public class UICanR42 extends UI_BaseComponent
	{
		private var cbcars:FSComboBox;
		private var cbmodels:FSComboBox;
		private var cbyers:FSComboBox;
		private var servant:CanServant;
		private var widget:CanWidget;
		private var task_engagebin2:ITask;
		private var preloaded:Boolean=false;
		private var carengineList:Array;
		
		public function UICanR42()
		{
			super();
			
			servant = new CanServant;
			
			var adapterFF:CanAdapter = new CanAdapter(128);
			var adapterFFFF:CanAdapter = new CanAdapter(32768);
			var adapterFFFFFFFF:CanAdapter = new CanAdapter(2147483648);

			//var adapterFFSigned:CanAdapter = new CanAdapter(128);
			var adapterFFFFSigned:CanAdapter = new CanAdapter(32768,true);
			//var adapterFFFFFFFF:CanAdapter = new CanAdapter(2147483648);
			
			createUIElement( new FSShadow, CMD.CAN_CAR_ID, "", null, 1 );
			
			FLAG_SAVABLE = false;
			cbcars = createUIElement( new FSComboBox, 0, loc("can_car"), onCarType, 1 ) as FSComboBox;
			attuneElement( NaN, 200, FSComboBox.F_COMBOBOX_NOTEDITABLE );
			cbmodels = createUIElement( new FSComboBox, 0, loc("can_model"), onCarModel, 2 ) as FSComboBox;
			attuneElement( NaN, 200, FSComboBox.F_COMBOBOX_NOTEDITABLE );
			cbyers = createUIElement( new FSComboBox, 0, loc("can_year"), onCarYear, 3 ) as FSComboBox;
			attuneElement( NaN, 200, FSComboBox.F_COMBOBOX_NOTEDITABLE );
			
			FLAG_SAVABLE = true;
			globalY += 15;
			addui( new FSComboBox, CMD.CAN_ENGINE, loc("can_engine_id"), null, 1 );
			attuneElement( 300+143, 300, FSComboBox.F_COMBOBOX_NOTEDITABLE );
			FLAG_SAVABLE = false;
			
			var s:String = loc("can_attention");
			
			var st:SimpleTextField = new SimpleTextField(s, 550 );
			addChild( st );
			st.x = 450;
			st.y = PAGE.CONTENT_TOP_SHIFT;
			st.setSimpleFormat("left", 2, 12);
			st.htmlText = s;
			st.height = 100;
			drawSeparator( 1110 );
		//	var col1:int=400;
		//	var col2:int=800;
			
			useLayout();
			
			addui( new FormString, 1, loc("can_perimeter"), null, 1 );
			attuneElement( 250, NaN, FormString.F_TEXT_BOLD );
			
			var anchor:int = globalY;
			var doors:Array = [{label:loc("can_door_closed"), data:0, color:COLOR.GREEN},{label:loc("can_door_opened"), data:1, color:COLOR.RED},{label:loc("can_not_available"), data:2}];
			var kapot:Array = [{label:loc("can_hood_closed"), data:0, color:COLOR.GREEN},{label:loc("can_hood_opened"), data:1, color:COLOR.RED},{label:loc("can_not_available"), data:2}];
			var alarm:Array = [{label:loc("can_alarm_norm"), data:0, color:COLOR.GREEN},{label:loc("can_alarm_violation"), data:1, color:COLOR.RED},{label:loc("can_not_available"), data:2}];
			var onoff:Array = [{label:loc("can_off"), data:0, color:COLOR.GREEN},{label:loc("can_on"), data:1, color:COLOR.RED},{label:loc("can_not_available"), data:2}];
			var pBreak:Array = [{label:loc("can_break_pedal_released"), data:0, color:COLOR.GREEN},{label:loc("can_break_pedal_pressed"), data:1, color:COLOR.RED},{label:loc("can_not_available"), data:2}];
			var yesno:Array = [{label:loc("g_no"), data:0, color:COLOR.GREEN},{label:loc("g_yes"), data:1, color:COLOR.RED},{label:loc("can_not_available"), data:2}];
			
			createUIElement( new FSBitwise, CMD.CAN_INPUTS, loc("can_door_front_left"), null, 1, doors );
			attuneElement( NaN, NaN, FSBitwise.F_CELL_ALIGN_RIGHT );
			createUIElement( new FSBitwise, CMD.CAN_INPUTS, loc("can_door_front_right"), null, 2, doors );
			attuneElement( NaN, NaN, FSBitwise.F_CELL_ALIGN_RIGHT );
			createUIElement( new FSBitwise, CMD.CAN_INPUTS, loc("can_door_back_right"), null, 3, doors );
			attuneElement( NaN, NaN, FSBitwise.F_CELL_ALIGN_RIGHT );
			createUIElement( new FSBitwise, CMD.CAN_INPUTS, loc("can_door_back_left"), null, 4, doors );
			attuneElement( NaN, NaN, FSBitwise.F_CELL_ALIGN_RIGHT );
			
			createUIElement( new FSBitwise, CMD.CAN_INPUTS, loc("can_hood"), null, 5, kapot );
			attuneElement( NaN, NaN, FSBitwise.F_CELL_ALIGN_RIGHT );
			createUIElement( new FSBitwise, CMD.CAN_INPUTS, loc("can_trunk"), null, 6, kapot );
			attuneElement( NaN, NaN, FSBitwise.F_CELL_ALIGN_RIGHT );
			createUIElement( new FSBitwise, CMD.CAN_INPUTS, loc("can_central_lock"), null, 7, kapot );
			attuneElement( NaN, NaN, FSBitwise.F_CELL_ALIGN_RIGHT );
			createUIElement( new FSBitwise, CMD.CAN_INPUTS, loc("can_onboard_security"), null, 8, alarm );
			attuneElement( NaN, NaN, FSBitwise.F_CELL_ALIGN_RIGHT );
			
		//	globalY += 10;

			newLayoutGroup();
			
			addui( new FormString, 1, loc("can_fuel_level_consumption"), null, 2 );
			attuneElement( 250, NaN, FormString.F_TEXT_BOLD );
			
	//		FLAG_SAVABLE = true;
			
			createUIElement( new FSSimple, CMD.CAN_PARAMS_FUEL, loc("can_fuel_level_l"), null, 1 );		// 32768
			attuneElement( NaN, NaN, FSSimple.F_CELL_NOTSELECTABLE | FSSimple.F_CELL_ALIGN_RIGHT );
			getLastElement().setAdapter( adapterFFFF );
			createUIElement( new FSSimple, CMD.CAN_PARAMS_FUEL, loc("can_fuel_level_perc"), null, 2 );		// 128
			attuneElement( NaN, NaN, FSSimple.F_CELL_NOTSELECTABLE | FSSimple.F_CELL_ALIGN_RIGHT );
			getLastElement().setAdapter( adapterFF );
			createUIElement( new FSSimple, CMD.CAN_PARAMS_FUEL, loc("can_total_fuel_consumption"), null, 3 );	// 2147483648
			attuneElement( NaN, NaN, FSSimple.F_CELL_NOTSELECTABLE | FSSimple.F_CELL_ALIGN_RIGHT );
			getLastElement().setAdapter( adapterFFFFFFFF );
			
			FLAG_SAVABLE = false;
		//	globalX = col1;
		//	globalY = anchor;
			
			newLayoutGroup();
			
			addui( new FormString, 1, loc("can_transmission"), null, 3 );
			attuneElement( 250, NaN, FormString.F_TEXT_BOLD );
			
			createUIElement( new FSBitwise, CMD.CAN_INPUTS, loc("can_akpp_moving"), null, 9, onoff );
			attuneElement( NaN, NaN, FSBitwise.F_CELL_ALIGN_RIGHT );
			createUIElement( new FSBitwise, CMD.CAN_INPUTS, loc("can_akpp_back"), null, 10, onoff );
			attuneElement( NaN, NaN, FSBitwise.F_CELL_ALIGN_RIGHT );
			createUIElement( new FSBitwise, CMD.CAN_INPUTS, loc("can_akpp_neutral"), null, 11, onoff );
			attuneElement( NaN, NaN, FSBitwise.F_CELL_ALIGN_RIGHT );
			createUIElement( new FSBitwise, CMD.CAN_INPUTS, loc("can_akpp_parking"), null, 12, onoff );
			attuneElement( NaN, NaN, FSBitwise.F_CELL_ALIGN_RIGHT );
			
			createUIElement( new FSBitwise, CMD.CAN_INPUTS, loc("can_break_pedal"), null, 13, pBreak );
			attuneElement( NaN, NaN, FSBitwise.F_CELL_ALIGN_RIGHT );
			createUIElement( new FSBitwise, CMD.CAN_INPUTS, loc("can_hard_break"), null, 14, onoff );
			attuneElement( NaN, NaN, FSBitwise.F_CELL_ALIGN_RIGHT );
			createUIElement( new FSBitwise, CMD.CAN_INPUTS, loc("can_car_moving"), null, 15, yesno );
			attuneElement( NaN, NaN, FSBitwise.F_CELL_ALIGN_RIGHT );
			createUIElement( new FSBitwise, CMD.CAN_INPUTS, loc("can_working_mode"), null, 16, onoff );
			attuneElement( NaN, NaN, FSBitwise.F_CELL_ALIGN_RIGHT );
		
		//	FLAG_SAVABLE = false;
		//	globalY += 50;
		//	FLAG_SAVABLE = true;
			
			newLayoutGroup();
			
			addui( new FormString, 1, loc("can_engine_work_options"), null, 4 );
			attuneElement( 250, NaN, FormString.F_TEXT_BOLD );
			
			createUIElement( new FSSimple, CMD.CAN_PARAMS_ENGINE, loc("can_cool_liquid_temp"), null, 1 );	// 32768
			attuneElement( NaN, NaN, FSSimple.F_CELL_NOTSELECTABLE | FSSimple.F_CELL_ALIGN_RIGHT );
			getLastElement().setAdapter( adapterFFFFSigned );
			createUIElement( new FSSimple, CMD.CAN_PARAMS_ENGINE, loc("can_rpm"), null, 2 );		// 32768
			attuneElement( NaN, NaN, FSSimple.F_CELL_NOTSELECTABLE | FSSimple.F_CELL_ALIGN_RIGHT );
			getLastElement().setAdapter( adapterFFFF );
			createUIElement( new FSSimple, CMD.CAN_PARAMS_ENGINE, loc("can_insta_fuel_consuption"), null, 3 );			// 32768
			attuneElement( NaN, NaN, FSSimple.F_CELL_NOTSELECTABLE | FSSimple.F_CELL_ALIGN_RIGHT );
			getLastElement().setAdapter( new FuelAdapter(32768) );
			
		//	FLAG_SAVABLE = false;
		//	globalX = col2;
		//	globalY = anchor;
			
			newLayoutGroup();
			
			addui( new FormString, 1, loc("can_engine_lights"), null, 5 );
			attuneElement( 250, NaN, FormString.F_TEXT_BOLD );
			
			createUIElement( new FSBitwise, CMD.CAN_INPUTS, loc("can_key_in_ignition"), null, 17, yesno );
			attuneElement( NaN, NaN, FSBitwise.F_CELL_ALIGN_RIGHT );
			createUIElement( new FSBitwise, CMD.CAN_INPUTS, loc("can_accessories"), null, 18, onoff );
			attuneElement( NaN, NaN, FSBitwise.F_CELL_ALIGN_RIGHT );
			createUIElement( new FSBitwise, CMD.CAN_INPUTS, loc("can_ignition"), null, 19, onoff );
			attuneElement( NaN, NaN, FSBitwise.F_CELL_ALIGN_RIGHT );
			createUIElement( new FSBitwise, CMD.CAN_INPUTS, loc("can_engine_working"), null, 20, yesno );
			attuneElement( NaN, NaN, FSBitwise.F_CELL_ALIGN_RIGHT );
			
			createUIElement( new FSBitwise, CMD.CAN_INPUTS, loc("can_parking_lights"), null, 21, onoff );
			attuneElement( NaN, NaN, FSBitwise.F_CELL_ALIGN_RIGHT );
			createUIElement( new FSBitwise, CMD.CAN_INPUTS, loc("can_dipped_beam"), null, 22, onoff );
			attuneElement( NaN, NaN, FSBitwise.F_CELL_ALIGN_RIGHT );
			createUIElement( new FSBitwise, CMD.CAN_INPUTS, loc("can_main_beam"), null, 23, onoff );
			attuneElement( NaN, NaN, FSBitwise.F_CELL_ALIGN_RIGHT );
			createUIElement( new FSBitwise, CMD.CAN_INPUTS, loc("can_safety_belt"), null, 24, onoff );
			attuneElement( NaN, NaN, FSBitwise.F_CELL_ALIGN_RIGHT );
			
			createUIElement( new FSBitwise, CMD.CAN_INPUTS, loc("can_wiper"), null, 25, onoff );
			attuneElement( NaN, NaN, FSBitwise.F_CELL_ALIGN_RIGHT );
			createUIElement( new FSBitwise, CMD.CAN_INPUTS, loc("can_direction_indicator_left"), null, 26, onoff );
			attuneElement( NaN, NaN, FSBitwise.F_CELL_ALIGN_RIGHT );
			createUIElement( new FSBitwise, CMD.CAN_INPUTS, loc("can_direction_indicator_right"), null, 27, onoff );
			attuneElement( NaN, NaN, FSBitwise.F_CELL_ALIGN_RIGHT );
			
			createUIElement( new FSShadow, CMD.CAN_INPUTS, "", null, 28 );
			createUIElement( new FSShadow, CMD.CAN_INPUTS, "", null, 29 );
			createUIElement( new FSShadow, CMD.CAN_INPUTS, "", null, 30 );
			createUIElement( new FSShadow, CMD.CAN_INPUTS, "", null, 31 );
			createUIElement( new FSShadow, CMD.CAN_INPUTS, "", null, 32 );
			
			newLayoutGroup();
			
			addui( new FormString, 1, loc("can_operating_params"), null, 6 );
			attuneElement( 250, NaN, FormString.F_TEXT_BOLD );
			
			createUIElement( new FSSimple, CMD.CAN_PARAMS_EXPL, loc("can_motohours"), null, 1 );				// 2147483648
			attuneElement( NaN, NaN, FSSimple.F_CELL_NOTSELECTABLE | FSSimple.F_CELL_ALIGN_RIGHT );
			getLastElement().setAdapter( adapterFFFFFFFF );
			createUIElement( new FSSimple, CMD.CAN_PARAMS_EXPL, loc("can_total_milage"), null, 2 );			// 2147483648
			attuneElement( NaN, NaN, FSSimple.F_CELL_NOTSELECTABLE | FSSimple.F_CELL_ALIGN_RIGHT );
			getLastElement().setAdapter( adapterFFFFFFFF );
			createUIElement( new FSSimple, CMD.CAN_PARAMS_EXPL, loc("can_milage_until_service"), null, 3 );			// 2147483648
			attuneElement( NaN, NaN, FSSimple.F_CELL_NOTSELECTABLE | FSSimple.F_CELL_ALIGN_RIGHT );
			getLastElement().setAdapter( adapterFFFFFFFF );
			
			widget = new CanWidget(put);
			
			/***********************************************************************************************************************
			 * 														ВАЖНО!
			 * 
			 * При добавлении новых полей, не забыть добавить их скрытие и появление в зависимости от скрытия в параметрах истории
			 * фунуция validateVisibility()
			 */
			
			
			starterCMD = [CMD.CAN_ENGINE, CMD.VR_SERIAL_USE,CMD.CAN_CAR_ID, CMD.CAN_INPUTS, CMD.CAN_PARAMS_FUEL, CMD.CAN_PARAMS_ENGINE, CMD.HISTORY_AVAILABLE_PAR, CMD.HISTORY_SELECT_PAR, CMD.CAN_PARAMS_EXPL];
		}
		override public function put(p:Package):void
		{
			
			switch(p.cmd) {
				case CMD.CAN_CAR_ID:
					LOADING = true;
					
					servant.put(Resources.CanCars());
					
					var t:int = p.getStructure()[0];
					var found:Boolean=false;
					cbcars.setList( servant.getCarsMenu() );
					
					for (var key:String in servant.years) {
						var a:Array = servant.getY(key);//servant.years[key];
						var len:int = a.length;
						for (var i:int=0; i<len; ++i) {
							if( a[i].data == t ) {
								var car:String = key.slice(0, key.search(", "));
								var model:String = key.slice(key.search(", ")+2);
								var year:String = a[i].label;
								
								cbcars.setCellInfo(car);
								cbmodels.setList( servant.getModelsMenu(car) );
								cbmodels.setCellInfo(model);
								cbyers.setList( servant.getYearsMenu(key) );
								cbyers.setCellInfo( t );
								
								found = true;
							}
							if(found)
								break;
						}
						if(found)
							break;
					}
					break;
				case CMD.CAN_INPUTS:
					getField( CMD.CAN_INPUTS, 1).setCellInfo( BitAdapter.getParam( 1, p.getStructure()[0],p.getStructure()[4] ));
					getField( CMD.CAN_INPUTS, 2).setCellInfo( BitAdapter.getParam( 2, p.getStructure()[0],p.getStructure()[4] ));
					getField( CMD.CAN_INPUTS, 3).setCellInfo( BitAdapter.getParam( 3, p.getStructure()[0],p.getStructure()[4] ));
					getField( CMD.CAN_INPUTS, 4).setCellInfo( BitAdapter.getParam( 4, p.getStructure()[0],p.getStructure()[4] ));
					
					getField( CMD.CAN_INPUTS, 5).setCellInfo( BitAdapter.getParam( 5, p.getStructure()[0],p.getStructure()[4] ));
					getField( CMD.CAN_INPUTS, 6).setCellInfo( BitAdapter.getParam( 6, p.getStructure()[0],p.getStructure()[4] ));
					getField( CMD.CAN_INPUTS, 7).setCellInfo( BitAdapter.getParam( 7, p.getStructure()[0],p.getStructure()[4] ));
					getField( CMD.CAN_INPUTS, 8).setCellInfo( BitAdapter.getParam( 8, p.getStructure()[0],p.getStructure()[4] ));
					
					getField( CMD.CAN_INPUTS, 9).setCellInfo( BitAdapter.getParam( 1, p.getStructure()[1],p.getStructure()[5] ));
					getField( CMD.CAN_INPUTS, 10).setCellInfo( BitAdapter.getParam( 2, p.getStructure()[1],p.getStructure()[5] ));
					getField( CMD.CAN_INPUTS, 11).setCellInfo( BitAdapter.getParam( 3, p.getStructure()[1],p.getStructure()[5] ));
					getField( CMD.CAN_INPUTS, 12).setCellInfo( BitAdapter.getParam( 4, p.getStructure()[1],p.getStructure()[5] ));
					
					getField( CMD.CAN_INPUTS, 13).setCellInfo( BitAdapter.getParam( 5, p.getStructure()[1],p.getStructure()[5] ));
					getField( CMD.CAN_INPUTS, 14).setCellInfo( BitAdapter.getParam( 6, p.getStructure()[1],p.getStructure()[5] ));
					getField( CMD.CAN_INPUTS, 15).setCellInfo( BitAdapter.getParam( 7, p.getStructure()[1],p.getStructure()[5] ));
					getField( CMD.CAN_INPUTS, 16).setCellInfo( BitAdapter.getParam( 8, p.getStructure()[1],p.getStructure()[5] ));
					
					getField( CMD.CAN_INPUTS, 17).setCellInfo( BitAdapter.getParam( 1, p.getStructure()[2],p.getStructure()[6] ));
					getField( CMD.CAN_INPUTS, 18).setCellInfo( BitAdapter.getParam( 2, p.getStructure()[2],p.getStructure()[6] ));
					getField( CMD.CAN_INPUTS, 19).setCellInfo( BitAdapter.getParam( 3, p.getStructure()[2],p.getStructure()[6] ));
					getField( CMD.CAN_INPUTS, 20).setCellInfo( BitAdapter.getParam( 4, p.getStructure()[2],p.getStructure()[6] ));
					
					getField( CMD.CAN_INPUTS, 21).setCellInfo( BitAdapter.getParam( 5, p.getStructure()[2],p.getStructure()[6] ));
					getField( CMD.CAN_INPUTS, 22).setCellInfo( BitAdapter.getParam( 6, p.getStructure()[2],p.getStructure()[6] ));
					getField( CMD.CAN_INPUTS, 23).setCellInfo( BitAdapter.getParam( 7, p.getStructure()[2],p.getStructure()[6] ));
					getField( CMD.CAN_INPUTS, 24).setCellInfo( BitAdapter.getParam( 8, p.getStructure()[2],p.getStructure()[6] ));
					
					getField( CMD.CAN_INPUTS, 25).setCellInfo( BitAdapter.getParam( 1, p.getStructure()[3],p.getStructure()[7] ));
					getField( CMD.CAN_INPUTS, 26).setCellInfo( BitAdapter.getParam( 2, p.getStructure()[3],p.getStructure()[7] ));
					getField( CMD.CAN_INPUTS, 27).setCellInfo( BitAdapter.getParam( 3, p.getStructure()[3],p.getStructure()[7] ));
					break;
				case CMD.CAN_PARAMS_EXPL:
					if (LOADING) {
						widget.active(true);
						
						if (DS.release >= 36 && DS.isDevice(DS.V2)) {
							if (cached(CMD.VR_SERIAL_USE,put))
								loadComplete();
						} else
							loadComplete();
				//		onChangeAutoUpdate();
						LOADING = false;
						
						validateVisibility();
						
					}
					SavePerformer.trigger({cmd:cmd});
				case CMD.CAN_PARAMS_FUEL:
				case CMD.CAN_PARAMS_ENGINE:
					pdistribute(p);
					break;
				case CMD.VR_SERIAL_USE:
					loadComplete();
					break;
			}
		}
		
		override public function open():void
		{
			super.open();
			
			
		}
		
		override public function close():void
		{
			
			super.close();
			widget.active(false);
			preloaded = false;
			
			RequestAssembler.getInstance().doPing( true );
		}
		private function validateVisibility(p:Package=null):void
		{
			var a:Array = OPERATOR.dataModel.getData(CMD.HISTORY_SELECT_PAR)[0];
			var av:Array = OPERATOR.dataModel.getData(CMD.HISTORY_AVAILABLE_PAR)[0];
			var gr:Array = [];
			var f:IFormString;
			// 18 - заканчивать проверку на 18м байте (по номерам в истории) последние проверяемые параметры 136-143
			for(var i:int=12; i<18; ++i) {
				for(var k:int=0; k<8; ++k) {
					if ( i*8+k < 103)
						continue;
					getFiledAlias(i*8+k).visible  = (a[i] & (1 << k)) > 0;
					gr[i*8+k] = (a[i] & (1 << k)) > 0 ? 1:0;
				}
			}
			
			/* 107 (обороты двигателя) и 130 (зажигание) для CAN_ENGINE
			0 - данные CAN не ипользуются
			1 - на основании данных CAN по оборотам двигателя
			2 - на основании данных CAN по зажиганию
			3 - по "или" на основании данных CAN по оборотам двигателя или зажигания	*/
			
			var list:Array;
			if (gr[107]==1 && gr[130]==1) {
				list = UTIL.getComboBoxList([[0,loc("his_not_available")],[1,loc("can_engine_rpm")],[2,loc("can_engine_ignition")],[3,loc("can_engine_both")]]);
			} else if (gr[107]==1 && gr[130]==0) {
				list = UTIL.getComboBoxList([[0,loc("his_not_available")],[1,loc("can_engine_rpm")]]);
			} else if (gr[107]==0 && gr[130]==1) {
				list = UTIL.getComboBoxList([[0,loc("his_not_available")],[2,loc("can_engine_ignition")]]);
			} else {
				list = UTIL.getComboBoxList([[0,loc("his_not_available")]]);
			}
			(getField(CMD.CAN_ENGINE,1) as FSComboBox).setList( list );
			getField(CMD.CAN_ENGINE,1).setCellInfo(OPERATOR.getParamInt(CMD.CAN_ENGINE,1));
			getField(CMD.CAN_ENGINE,1).disabled = false;
			
			if (gr[103] == 0 &&
				gr[104] == 0 &&
				gr[105] == 0) {
				getField(1,2).visible = false;
			} else
				getField(1,2).visible = true;
			
			if (gr[106] == 0 &&
				gr[107] == 0 &&
				gr[108] == 0) {
				getField(1,4).visible = false;
			} else
				getField(1,4).visible = true;
			
			if (gr[109] == 0 &&
				gr[110] == 0 &&
				gr[111] == 0) {
				getField(1,6).visible = false;
			} else
				getField(1,6).visible = true;
			
			if (gr[112] == 0 &&
				gr[113] == 0 &&
				gr[114] == 0 &&
				gr[115] == 0 &&
				gr[116] == 0 &&
				gr[117] == 0 &&
				gr[118] == 0 &&
				gr[119] == 0) {
				getField(1,1).visible = false;
			} else
				getField(1,1).visible = true;
			
			if (gr[120] == 0 &&
				gr[121] == 0 &&
				gr[122] == 0 &&
				gr[123] == 0 &&
				gr[124] == 0 &&
				gr[125] == 0 &&
				gr[126] == 0 &&
				gr[127] == 0) {
				getField(1,3).visible = false;
			} else
				getField(1,3).visible = true;
			
			if (gr[128] == 0 &&
				gr[129] == 0 &&
				gr[130] == 0 &&
				gr[131] == 0 &&
				gr[132] == 0 &&
				gr[133] == 0 &&
				gr[134] == 0 &&
				gr[135] == 0) {
				getField(1,5).visible = false;
			} else
				getField(1,5).visible = true;
			
		/*	if (gr[128] == 0 &&
				gr[129] == 0 &&
				gr[130] == 0 &&) {*/
			
			ResizeWatcher.doResizeMe(layout);
		}
		private function onCarType():void
		{
			blockCanEngine();
			
			var info:String = cbcars.getCellInfo().toString();
			if (servant.isRF485(info) ) {
				if( OPERATOR.dataModel.getData(CMD.VR_SERIAL_USE)[1][0] != 3 ) {
					PopUp.getInstance().construct( PopUp.wrapHeader("sys_attention"), PopUp.wrapMessage("can_port_warning"), PopUp.BUTTON_OK );
					PopUp.getInstance().open();
					cbcars.setCellInfo( loc("ui_can_not_selected") );
				}
			}
			
			var v:String = cbcars.getCellInfo().toString(); 
			
			var menu:Array = servant.getModelsMenu( cbcars.getCellInfo().toString() );
			cbmodels.setList( menu );
			for (var key:String in menu ) {
				cbmodels.setCellInfo( menu[key].data );
				onCarModel();
				break;
			}
		}
		private function onCarModel():void
		{
			blockCanEngine();
			
			var info:String = cbcars.getCellInfo().toString();
			var info2:String = cbmodels.getCellInfo().toString();
			var menu:Array = servant.getYearsMenu( cbcars.getCellInfo() + ", "+ cbmodels.getCellInfo().toString() );
			cbyers.setList( menu );
			for (var key:String in menu ) {
				cbyers.setCellInfo( menu[key].data );
				onCarYear();
				break;
			}
		}
		
		private function onCarYear():void
		{
			blockCanEngine();
			
			var f:IFormString = getField(CMD.CAN_CAR_ID,1);
			f.setCellInfo( cbyers.getCellInfo() );
			SavePerformer.remember( 1, f);
		}
		
		private var carSaveData:Array;
		private function cmd(value:Object):int
		{
			if (value is int) {
				if (int(value) == CMD.CAN_CAR_ID)
					return SavePerformer.CMD_TRIGGER_TRUE; 
			} else if (value is Object) {
				var p:PopUp = PopUp.getInstance();
				p.construct( PopUp.wrapHeader("sys_attention"), 
					PopUp.wrapMessage(loc("can_important_note")), 
					PopUp.BUTTON_OK | PopUp.BUTTON_CANCEL, [doSave] );
				p.open();
				carSaveData = value.array;
				return SavePerformer.CMD_TRIGGER_CONTINUE;	
			}
			return SavePerformer.CMD_TRIGGER_FALSE;
		}
		private function doSave():void
		{
			RequestAssembler.getInstance().fireEvent(new Request(CMD.CAN_ENGINE, null, 1, [0]));
			
			RequestAssembler.getInstance().fireEvent(new Request(CMD.CAN_CAR_ID, null, 1, carSaveData));
			RequestAssembler.getInstance().fireEvent(new Request(CMD.HISTORY_SELECT_PAR, validateVisibility ));
			widget.active(true);
		}
		private function blockCanEngine():void
		{
			getField(CMD.CAN_ENGINE,1).setCellInfo(0);
			getField(CMD.CAN_ENGINE,1).disabled = true;
		}
		private function getFiledAlias(num:int):IFormString
		{
			if (num < 112) {
				switch(num) {
					case 103:
					case 104:
					case 105:
						return getField(CMD.CAN_PARAMS_FUEL, num - 102);
					case 106:
					case 107:
					case 108:
						return getField(CMD.CAN_PARAMS_ENGINE, num - 105);
					case 109:
					case 110:
					case 111:
						return getField(CMD.CAN_PARAMS_EXPL, num - 108);
				}
			} else
				return getField(CMD.CAN_INPUTS, num - 111);
			return null;
		}
	}
}
import components.abstract.functions.loc;
import components.gui.fields.FSSimple;
import components.interfaces.IDataAdapter;
import components.interfaces.IFormString;
import components.static.COLOR;
import components.system.UTIL;

class BitAdapter 
{
	//	параметр для CAN_INPUTS, параметр - 2 бита
	public static function getParam(param:int, data:int, isactive:int):int
	{
		var p:int = param-1; 
		if ( (1<<p) & isactive ) {
			if( (1<<p) & data )
				return 1;
			return 0;
		}
		return 2;
	}
}
// адаптер меняет цвет и данные
class CanAdapter implements IDataAdapter 
{
	private var target:uint;
	private var color:int;
	private var signed:Boolean;
	
	public function CanAdapter(value:int, isSigned:Boolean=false)
	{
		target = value;
		signed = isSigned;
	}
	public function adapt(value:Object):Object
	{
		if ( uint(value) == target ) {
			color = COLOR.BLACK;
			return loc("can_not_available")
		}
		color = COLOR.GREEN;
		if (signed) {
			var byte:int = 1;
			switch(target) {
				case 32768:
					byte = 2;
					break;
				case 2147483648:
					byte = 4;
					break;
			}
			return UTIL.toSigned(int(value),byte);
		}
		return value;
	}
	public function perform(field:IFormString):void
	{
		(field as FSSimple).setTextColor( color );
	}
	public function recover(value:Object):Object
	{
		return value;
	}
	public function change(value:Object):Object 	{ return value	}
}
// адаптер делит на 10 значение мгновенного расхода топлива
class FuelAdapter implements IDataAdapter 
{
	private var target:uint;
	private var color:int;
	public function FuelAdapter(value:int)
	{
		target = value;
	}
	public function adapt(value:Object):Object
	{
		if ( uint(value) == target ) {
			color = COLOR.BLACK;
			return loc("can_not_available")
		}
		color = COLOR.GREEN;
		return int(value)/100;
	}
	public function perform(field:IFormString):void
	{
		(field as FSSimple).setTextColor( color );
	}
	public function recover(value:Object):Object
	{
		return value;
	}
	public function change(value:Object):Object 	{ return value	}
}