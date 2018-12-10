package components.screens.opt
{
	import flash.events.Event;
	
	import components.abstract.RegExpCollection;
	import components.abstract.functions.loc;
	import components.abstract.servants.TabOperator;
	import components.abstract.servants.TaskManager;
	import components.basement.OptionsBlock;
	import components.basement.UIRadioDeviceRoot;
	import components.gui.fields.FSComboBox;
	import components.gui.fields.FSShadow;
	import components.gui.fields.FSSimple;
	import components.gui.fields.FSTextPic;
	import components.gui.fields.FormEmpty;
	import components.gui.fields.FormString;
	import components.gui.visual.Separator;
	import components.interfaces.IFormString;
	import components.interfaces.ITask;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.protocol.statics.OPERATOR;
	import components.screens.ui.UITrmSens;
	import components.static.CMD;
	import components.static.COLOR;
	import components.static.PAGE;
	import components.system.UTIL;
	
	public class OptRctrlTermoSens extends OptionsBlock
	{
		
		private var section:FormString;
		private var fsLock:FSTextPic;
		private var fsUnlock:FSTextPic;
		private var fsStar:FSTextPic;

		private var speedTask:ITask;
		
		public static const INNER_LENGTH_STEP_WRITE:int = 5;
		public static const INNER_TOP_LEVEL:int = 3;
		public static const INNER_DOWN_LEVEL:int = 4;
		
		public static const OUTER_LENGTH_STEP_WRITE:int = 8;
		public static const OUTER_TOP_LEVEL:int = 6;
		public static const OUTER_DOWN_LEVEL:int = 7;
		
		public function OptRctrlTermoSens()
		{
			super();
			
			globalX = PAGE.CONTENT_LEFT_SHIFT;
			globalY = 15;
			
			operatingCMD = CMD.RF_CTRL_TEMP;
			
			const oneColWidth:int = 650;
			const secColWidth:int = 80;
			
			//addui( new FSShadow, operatingCMD, "", null, 1
			
			const fsOuter:FSSimple = addui( new FSSimple, CMD.GET_TEMPERATURE, loc("ui_temp_int_sensor"), null, 1  ) as FSSimple;
			attuneElement( oneColWidth, secColWidth, FSSimple.F_CELL_NOTSELECTABLE );
			fsOuter.setColoredBorder( COLOR.RED );
			addMeasure( getLastElement() as IFormString );
			
			globalY += 15;
			
			
			addui( new FSShadow, operatingCMD, "", null, 1 );
			addui( new FSShadow, operatingCMD, "", null, 2 );
			
			var list:Array = UTIL.comboBoxNumericDataGenerator( 0, 32 );
			
			addui( new FSComboBox, operatingCMD, loc( "save_changes_temperature_more" ),  dlgtUpIdRecord, INNER_LENGTH_STEP_WRITE, list.slice(), "0-9", 2, new RegExp( RegExpCollection.REF_0to32_none ) );
			attuneElement( oneColWidth, secColWidth );
			addMeasure( getLastElement() as IFormString );
			
			//gener_event_change_tempr
			/// реализовать проверку введенных значений для порогов, корректировать диапазон значений таким образом, чтобы нижний порог не мог быть "горячее" верхнего
			
			list = UTIL.comboBoxNumericDataGenerator( -40, 63 ).reverse();
			addui( new FSComboBox,  operatingCMD, loc("gener_event_change_tempr"), delegateTermoLevel, INNER_TOP_LEVEL, list.slice() , "-0-9",3, new RegExp( RegExpCollection.REF_minus_63to63 )  );
			
			attuneElement( oneColWidth, secColWidth);
			
			addMeasure( getLastElement() as IFormString );
			
			list = UTIL.comboBoxNumericDataGenerator( -40, 63 ).reverse();
			addui( new FSComboBox,  operatingCMD, loc("gener_event_change_tempr_down"), delegateTermoLevel, INNER_DOWN_LEVEL, list.slice() , "-0-9",4, new RegExp( RegExpCollection.REF_minus_63to63 )  );
			attuneElement( oneColWidth, secColWidth );
			//fsOuter_II.setColoredBorder( COLOR.BLUE );
			addMeasure( getLastElement() as IFormString );
			
			globalY += 15;
			var sep:Separator = new Separator( oneColWidth + secColWidth + 90);
			addChild( sep );
			sep.y = globalY;
			sep.x = 10;
			
			globalY += 25;
			
			/****************************************** second half the screen ****************************************/
			
			const fsOuter_I:FSSimple = addui( new FSSimple, CMD.GET_TEMPERATURE, loc("ui_temp_ext_sensor"), null, 2  ) as FSSimple;
			attuneElement( oneColWidth, secColWidth, FSSimple.F_CELL_NOTSELECTABLE );
			fsOuter_I.setColoredBorder( COLOR.PINK_TRACE );
			addMeasure( getLastElement() as IFormString );
			
			globalY += 15;
			
			
			
			list = UTIL.comboBoxNumericDataGenerator( 0, 32 );
			
			addui( new FSComboBox, operatingCMD, loc( "save_changes_temperature_more" ), dlgtUpIdRecord, OUTER_LENGTH_STEP_WRITE, list.slice(), "0-9", 2, new RegExp( RegExpCollection.REF_0to32_none ) );
			attuneElement( oneColWidth, secColWidth );
			addMeasure( getLastElement() as IFormString );
			
			//gener_event_change_tempr
			/// реализовать проверку введенных значений для порогов, корректировать диапазон значений таким образом, чтобы нижний порог не мог быть "горячее" верхнего
			
			list = UTIL.comboBoxNumericDataGenerator( -55, 125 ).reverse();
			addui( new FSComboBox,  operatingCMD, loc("gener_event_change_tempr"), delegateTermoLevel, OUTER_TOP_LEVEL, list.slice() , "-0-9",4, new RegExp( RegExpCollection.REF_minus_127to127 )  );
			
			attuneElement( oneColWidth, secColWidth);
			//fsOuter_I.setColoredBorder( COLOR.ORANGE );
			addMeasure( getLastElement() as IFormString );
			
			list = UTIL.comboBoxNumericDataGenerator( -55, 125 ).reverse();
			addui( new FSComboBox,  operatingCMD, loc("gener_event_change_tempr_down"), delegateTermoLevel, OUTER_DOWN_LEVEL, list.slice() , "-0-9",4, new RegExp( RegExpCollection.REF_minus_127to127 )  );
			attuneElement( oneColWidth, secColWidth );
			//fsOuter_II.setColoredBorder( COLOR.BLUE );
			addMeasure( getLastElement() as IFormString );
			
			/**
			 * "Команда RF_CTRL_TEMP - настройка беспроводных датчиков температуры.

				Параметр 1 - наличие, 0-нет, 1-да;
				Параметр 2 - резерв (0xFF) (например, под тип датчика)
				Параметр 3 - верхний порог внутреннего датчика,  -63...63;
				Параметр 4 - нижний порог внутреннего датчика,  -63...63;
				Параметр 5 - событие об изменении температуры внутреннего датчика на указанное количество градусов, 0-нет, 1...32;
				Параметр 6 - верхний порог внешнего датчика,  -127...127;
				Параметр 7 - нижний порог внешнего датчика,  -127...127;
				Параметр 8 - событие об изменении температуры внутреннего датчика на указанное количество градусов, 0-нет, 1...32;
				"													
			 */
			
			
		}
		
			
		
		
		
		override public function putData(p:Package):void
		{
			
			structureID = p.structure
			globalFocusGroup = 200*(structureID-1)+50;
			refreshCells( CMD.GET_TEMPERATURE );
			refreshCells( operatingCMD );
			
			RequestAssembler.getInstance().fireEvent( new Request( CMD.GET_TEMPERATURE, loadHandler ) );
			RequestAssembler.getInstance().fireEvent( new Request( operatingCMD, loadHandler, structureID ) );
			if( !speedTask )speedTask = TaskManager.callLater( onSpeedTick, TaskManager.DELAY_1SEC*5 );
			
			
		}
		
		
		
		
		
		private function loadHandler( p:Package ):void
		{
			
			
			switch( p.cmd ) {
				case CMD.GET_TEMPERATURE:
					
					
					
					const in_term:String = UTIL.toSigned( p.getParamInt( 1,  ( structureID  * 2 ) ), 1 ) + ""; 
					getField( CMD.GET_TEMPERATURE, 1 ).setCellInfo( ( int( in_term ) == 128 || int( in_term ) == -128 )?loc("his_not_available"):in_term );
					
					const out_term:String = UTIL.toSigned( p.getParamInt( 1,  ( structureID  * 2 ) + 1 ), 1 ) + ""; 
					getField( CMD.GET_TEMPERATURE, 2 ).setCellInfo( ( int( out_term ) == 128 || int( out_term ) == -128)?loc("his_not_available"):out_term );
					
					
					break;
				
				case operatingCMD:
					
					
					const spStr:int = structureID - 1;
					
					getField( operatingCMD, 1 ).setCellInfo( p.getParam( 1, 1 ) );
					getField( operatingCMD, 2 ).setCellInfo( p.getParam( 2, 1 ) );
					/// если байт является отрицательным числом...
					getField( operatingCMD, 3 ).setCellInfo( UTIL.toSigned( p.getParamInt( 3, 1 ), 1 ) );
					getField( operatingCMD, 4 ).setCellInfo( UTIL.toSigned( p.getParamInt( 4, 1 ), 1 ) );
					getField( operatingCMD, 5 ).setCellInfo( p.getParam( 5, 1 ) );
					if( UITrmSens.ID_REC_SENS && UITrmSens.ID_REC_SENS != 5 + ( UITrmSens.CPRM_908 * spStr ) )
					{
						getField( operatingCMD, 5 ).setCellInfo( 0 );
						getField( operatingCMD, 5 ).disabled = true;
					}
					else if( !UITrmSens.ID_REC_SENS && int( p.getParam( 5, 1 ) ) > 0 )
					{
						UITrmSens.ID_REC_SENS = 5 + ( UITrmSens.CPRM_908 * spStr );
						getField( operatingCMD, 5 ).disabled = false;
						getField( operatingCMD, 5 ).setCellInfo( p.getParam( 5, 1 ) );
					}
					else
					{
						getField( operatingCMD, 5 ).setCellInfo( p.getParam( 5, 1 ) );
						getField( operatingCMD, 5 ).disabled = false;
					}
					getField( operatingCMD, 6 ).setCellInfo( UTIL.toSigned( p.getParamInt( 6, 1 ), 1 ) );
					getField( operatingCMD, 7 ).setCellInfo( UTIL.toSigned( p.getParamInt( 7, 1 ), 1 ) );
					//getField( operatingCMD, 8 ).setCellInfo( p.getParam( 8, 1 ) );
					
					if( UITrmSens.ID_REC_SENS && UITrmSens.ID_REC_SENS != 8 + ( UITrmSens.CPRM_908 * spStr ) )
					{
						
						
						getField( operatingCMD, 8 ).setCellInfo( 0 );
						getField( operatingCMD, 8 ).disabled = true;
					}
					else if( !UITrmSens.ID_REC_SENS && int( p.getParam( 8, 1 ) ) > 0 )
					{
						UITrmSens.ID_REC_SENS = 8 + ( UITrmSens.CPRM_908 * spStr );
						getField( operatingCMD, 8 ).disabled = false;
						getField( operatingCMD, 8 ).setCellInfo( p.getParam( 8, 1 ) );
					}
					else
					{
						
						getField( operatingCMD, 8 ).setCellInfo( p.getParam( 8, 1 ) );
						getField( operatingCMD, 8 ).disabled = false;
					}

					this.dispatchEvent( new Event( UIRadioDeviceRoot.EVENT_LOADED ));
					break;
				
				default:
					break;
			}
			
		}
		
		private function onSpeedTick():void
		{
			
			speedTask.repeat();
			if( this.visible ) RequestAssembler.getInstance().fireEvent( new Request(CMD.GET_TEMPERATURE, loadHandler) );
			
			
		}
		
		public function close():void
		{
			if( speedTask )speedTask.kill();
			speedTask = null;
		}
		
		private function addMeasure( elt:IFormString ):void
		{
			const yy:int = globalY;
			const xx:int = globalX;
			const space:int = 10;
			
			const measure:IFormString = addui( new FormString, 0, loc( "measure_degree_m" ), null, 1 );
			measure.y = elt.y;
			measure.x = elt.x + elt.width + space;
			
			globalY = yy;
			globalX = xx;
			
			
		}
		
		private function delegateTermoLevel( t:IFormString ):void
		{
			var opponent:FormEmpty;
			
			
			
			
			( t as FormEmpty ).forceValid = 0;
			
			
			switch( t.param ) {
				case INNER_TOP_LEVEL:
					opponent = getField( operatingCMD, INNER_DOWN_LEVEL ) as FormEmpty;
					if( int( t.getCellInfo() ) <= int( opponent.getCellInfo() ) )
						opponent.forceValid = 2;
					else
						opponent.forceValid = 0;
						break;
				case INNER_DOWN_LEVEL:
					opponent = getField( operatingCMD, INNER_TOP_LEVEL ) as FormEmpty;
					if( int( t.getCellInfo() ) >= int( opponent.getCellInfo() ) )
						opponent.forceValid = 2;
					else
						opponent.forceValid = 0;
					break;
						break;
				case OUTER_TOP_LEVEL:
					opponent = getField( operatingCMD, OUTER_DOWN_LEVEL ) as FormEmpty;
					if( int( t.getCellInfo() ) <= int( opponent.getCellInfo() ) )
						opponent.forceValid = 2;
					else
						opponent.forceValid = 0;
					break;
				

				
				case OUTER_DOWN_LEVEL:
					opponent = getField( operatingCMD, OUTER_TOP_LEVEL ) as FormEmpty;
					if( int( t.getCellInfo() ) >= int( opponent.getCellInfo() ) )
						opponent.forceValid = 2;
					else
						opponent.forceValid = 0;
					break;
						
					
				default:
					break;
			}
			
			
			remember( t );
			
		
			
			
		}
		
		/**
		 * Разыскивает поле модуля значение которого пишется
		 * в историю.
		 * 
		 */
		private function dlgtUpIdRecord( t:IFormString ):void
		{
			
			const idOpponent:IFormString = getField( operatingCMD, 5 ).param == t.param?getField( operatingCMD, 8 ):getField( operatingCMD, 5 );

			
			if( idOpponent.param != t.param && int( t.getCellInfo() ) > 0)
			{
				
				UITrmSens.ID_REC_SENS =  ( ( structureID - 1 ) * UITrmSens.CPRM_908 ) + t.param;
				idOpponent.setCellInfo( 0 );
				idOpponent.disabled = true; 
			}
			else if( int( t.getCellInfo() ) == 0 )
			{
				idOpponent.disabled = false; 
				UITrmSens.ID_REC_SENS =  0;
			}
			
			
			remember( t );	
		}	
		
	}
}