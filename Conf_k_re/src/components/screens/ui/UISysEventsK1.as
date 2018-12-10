package components.screens.ui
{
	import components.abstract.RegExpCollection;
	import components.abstract.functions.loc;
	import components.basement.UI_BaseComponent;
	import components.gui.fields.FSBitBox;
	import components.gui.fields.FSBitBoxK9BitSw;
	import components.gui.fields.FSCheckBox;
	import components.gui.fields.FSComboBox;
	import components.gui.fields.FSShadow;
	import components.gui.fields.FormEmpty;
	import components.gui.fields.FormString;
	import components.interfaces.IFormString;
	import components.protocol.Package;
	import components.static.CMD;
	import components.static.DS;
	import components.static.PAGE;
	import components.system.UTIL;
	
	public class UISysEventsK1 extends UI_BaseComponent
	{
		private var enableCPWsettings:Boolean;
		private var adv_atest:int;
		private var main_atest:int;
		private var timefields:Vector.<IFormString>;

		private var timeCPW:FormEmpty;

		
		public function UISysEventsK1()
		{
			super();
			var wid:int = 350;
			var cwid:int = 70;
			globalX = 370;
			main_atest = CMD.K9_MAIN_ATEST; 
			
			enableCPWsettings = int( DS.app ) == 4 || int( DS.app ) == 7 ;
			
			
			
			
			var list:Array = UTIL.getComboBoxList( [[0,loc("g_no")],[1,loc("k5_sysev_one")],[2,loc("k5_sysev_two")],[3,loc("k5_sysev_three")]] );
			addui( new FSComboBox, main_atest, loc("k5_sysev_autotests"), onAmount, 1, list );
			attuneElement( 161, cwid, FSComboBox.F_COMBOBOX_NOTEDITABLE );
			
			var reg:RegExp = new RegExp("^("+RegExpCollection.RE_00to2359+")$");
			
			timefields = new Vector.<IFormString>;
			
			var time_list:Array = [ {label:"00:00", data:"00:00"},
				{label:"08:00", data:"08:00"},
				{label:"16:00", data:"16:00"} ];
			
			main_atest = CMD.K9_MAIN_ATEST; 
			
			addui( new FSShadow, main_atest, "", null, 2 );
			addui( new FSShadow, main_atest, "", null, 3 );
			addui( new FSShadow, main_atest, "", null, 4 );
			addui( new FSShadow, main_atest, "", null, 5 );
			addui( new FSShadow, main_atest, "", null, 6 );
			addui( new FSShadow, main_atest, "", null, 7 );
			
			FLAG_SAVABLE = false;
			addui( new FSComboBox, 1, loc("k5_sysev_at")+" 1", onTime,1,time_list,"0-9:",5,
				new RegExp( reg ));
			attuneElement( 161,cwid, FSComboBox.F_COMBOBOX_TIME );
			timefields.push( getLastElement() );
			addui( new FSComboBox, 1, loc("k5_sysev_at")+" 2", onTime,2,time_list,"0-9:",5,
				new RegExp( reg ));
			attuneElement( 161,cwid, FSComboBox.F_COMBOBOX_TIME );
			timefields.push( getLastElement() );
			addui( new FSComboBox, 1, loc("k5_sysev_at")+" 3", onTime,3,time_list,"0-9:",5,
				new RegExp( reg ));
			attuneElement( 161,cwid, FSComboBox.F_COMBOBOX_TIME );
			timefields.push( getLastElement() );
			FLAG_SAVABLE = true;
			
			var anchor:int = globalY;
			globalX = PAGE.CONTENT_LEFT_SHIFT;
			
			addui( new FormString, 0, loc("ui_sysev_gen_autotest"), null, 10 );
			attuneElement( NaN, NaN, FormString.F_MULTYLINE );
			getLastElement().y -= 76;
			globalY = anchor;
			
			drawSeparator(641+109-140);
			
			adv_atest = CMD.K9_ADV_ATEST;
			var time_list1:Array = [ {label:loc("g_off"), data:"0"},
				{label:"1", data:1},
				{label:"6", data:6},
				{label:"12", data:12},
				{label:"24", data:24}	];
			addui( new FSComboBox, adv_atest , loc("k9_sysev_atdop"), null,1,time_list1,"0-9",3,
				new RegExp( RegExpCollection.REF_0to255 ));
			attuneElement( wid+151,cwid );
			
			wid = 500;
			cwid = 70;
			
			drawSeparator(641+109-140);
			
			if( enableCPWsettings === true ){
				addui( new FSBitBoxK9BitSw, CMD.K9_BIT_SWITCHES, loc("ui_sysev_gen_no_220"), null, 2,[0] );
				attuneElement( wid+cwid-13);
				globalY += 15;
				timeCPW = addui( new FSComboBox, CMD.K5_TIME_CPW, loc("ui_sysev_gen_no_220_time"), null,1,time_list,"0-9:",5,
					new RegExp( reg ));
				getLastElement().setAdapter( new AdaptTime() );
				attuneElement( wid,cwid );//, FSComboBox.F_COMBOBOX_TIME );
				globalY += 15;
				
				( getField( CMD.K9_BIT_SWITCHES, 2 ) as FSBitBoxK9BitSw ).setComboTime( timeCPW );
					
			}
			else
			{
				addui( new FSShadow, CMD.K9_BIT_SWITCHES, "", null, 2 );
				addui( new FSShadow, CMD.K5_TIME_CPW, "", null, 1 );
			}
			
			
			
			//FLAG_SAVABLE = false;
			///K9_BAT_EVENTS bit 1
			addui( new FSCheckBox, 0, loc("ui_sysev_gen_acu_low"), onDischargeAkb, 3 );
			attuneElement( wid+cwid-13);
			//FLAG_SAVABLE = true;
			addui( new FSBitBox, CMD.K9_BIT_SWITCHES, loc("ui_sysev_gen_ev_restart"), null, 1,[0] );
			attuneElement( wid+cwid-13);
			addui( new FSShadow, CMD.K9_BAT_EVENTS, "", null, 1 );			
			
			
			if( int( DS.app ) > 6 ) ///K9_BAT_EVENTS bit 0
				addui( new FSCheckBox, 0, loc("ui_sysev_gen_acu_fail"), onDischargeAkb, 1 );
			
			
			attuneElement( wid+cwid-13);
			starterCMD = [CMD.K9_BIT_SWITCHES,CMD.K9_BAT_EVENTS,CMD.K9_ADV_ATEST, CMD.K5_TIME_CPW,CMD.K9_MAIN_ATEST];
			
		}
		
			
		
		override public function put(p:Package):void
		{
			var bf:int;
			switch(p.cmd) {
				case CMD.K9_BAT_EVENTS:
					refreshCells( p.cmd );
					distribute( p.getStructure(), p.cmd );
					bf = p.getStructure()[0];
					
					getField(0,3).setCellInfo(UTIL.isBit( 0, bf ));
					if( getField(0,1) ) getField(0,1).setCellInfo(UTIL.isBit( 1, bf ));
					break;
				case CMD.K9_BIT_SWITCHES:
					
					refreshCells( p.cmd );
					distribute( p.getStructure(), p.cmd );
					
					break;
				case CMD.K9_ADV_ATEST:
					distribute( p.getStructure(), p.cmd );
					break;
				case CMD.K5_TIME_CPW:

					distribute( p.getStructure(), p.cmd );
					
					break;
				case CMD.K9_MAIN_ATEST:
					pdistribute(p);
					getField(1,1).setCellInfo( mergeIntoTime( p.getStructure()[1], p.getStructure()[4] ) );
					getField(1,2).setCellInfo( mergeIntoTime( p.getStructure()[2], p.getStructure()[5] ) );
					getField(1,3).setCellInfo( mergeIntoTime( p.getStructure()[3], p.getStructure()[6] ) );
					onAmount(null);
					loadComplete();
					break;
			}
		}
		
		
		
		private function onAmount(t:IFormString):void
		{
			var f:IFormString = getField( main_atest, 1 );
			var n:int = int(f.getCellInfo());
			
			getField(adv_atest,1).disabled = true;
			
			getField(1,1).disabled = true;
			getField(1,2).disabled = true;
			getField(1,3).disabled = true;
			
			switch(n) {
				case 3:
					getField(1,3).disabled = false;
				case 2:
					getField(1,2).disabled = false;
				case 1:
					getField(1,1).disabled = false;
					getField(adv_atest,1).disabled = false;
					break;
			}
			if (t)
				remember(t);
		}
		private function onDischargeAkb( ifrm:IFormString ):void
		{
			if(  int( DS.app ) > 6  )var discharge:Boolean = int((getField(0,1) as FSCheckBox).getCellInfo()) == 1;
			var low:Boolean = int((getField(0,3) as FSCheckBox).getCellInfo()) == 1;
			var f:IFormString;
			var bf:uint;
			
			f = getField( CMD.K9_BAT_EVENTS, 1 );
			const val:uint = uint(f.getCellInfo());
			if(int( DS.app ) > 6 )
			{
				bf = UTIL.changeBit( val, 1, discharge );
				bf = UTIL.changeBit( bf, 0, low );
			}
			else
			{
				bf = UTIL.changeBit( val, 0, low );
			}
			
			
			
			f.setCellInfo( bf );
			remember( f );
		}
		private function onTime():void
		{
			var f:IFormString = getField( main_atest, 1 );
			var a:Array = [f.getCellInfo()];
			a = a.concat(timefields[0].getCellInfo());
			a = a.concat(timefields[1].getCellInfo());
			a = a.concat(timefields[2].getCellInfo());
			
			distribute( [a[0],a[1],a[3],a[5],a[2],a[4],a[6]], CMD.K9_MAIN_ATEST );
			remember(f);
		}
	}
}
import components.gui.fields.FormEmpty;
import components.interfaces.IDataAdapter;
import components.interfaces.IFormString;


class AdaptTime implements IDataAdapter
{

	
	
	public function AdaptTime(  )
	{
		
	}
	
	public function change(value:Object):Object
	{
		
		// меняет вбитое значение до валидации
		return value;
	}
	/**
	 * Вызывается при первой загрузке входных данных 
	 * @param value собственно данные полученые с прибора
	 * @return данные которые будут сообщены закрепленному компоненту
	 * 
	 */		
	public function adapt(value:Object):Object
	{
		const data:int = int( value );
		const min:int = data / 60;
		const sec:int = data % 60;

		const time:String = ( min < 10? "0" + min:min ) + ":" +( sec < 10? "0" + sec:sec );
		
		
		
		return time;
	}
	/**
	 * Вызывается при изменении значения эл-та, например
	 * при чеке чекбокса
	 *  
	 * @param value данные полученные компонентом в результате изменения состояния
	 * @return данные которые будут переданны на прибор в результате преобразования
	 * 
	 */		
	public function recover(value:Object):Object
	{
		var comb:Array = ( value as String ).split( ":" );
		
		
		const res:int = int( comb[ 0 ] ) * 60 + int( comb[ 1 ] );
		return res;
	}
	/**
	 * Вызывается при первой загрузке входных данных 
	 * @param field элемент за которым закреплен адаптер
	 * @return 
	 * 
	 */	
	public function perform(field:IFormString):void
	{
		
	}
}