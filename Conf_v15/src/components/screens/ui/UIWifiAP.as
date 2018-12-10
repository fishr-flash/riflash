package components.screens.ui
{
	import components.abstract.RegExpCollection;
	import components.abstract.functions.loc;
	import components.abstract.servants.ResizeWatcher;
	import components.basement.UI_BaseComponent;
	import components.gui.MFlexTable;
	import components.gui.fields.FSCheckBox;
	import components.gui.fields.FSComboBox;
	import components.gui.fields.FSShadow;
	import components.gui.fields.FSSimple;
	import components.interfaces.IFormString;
	import components.interfaces.IResizeDependant;
	import components.protocol.Package;
	import components.protocol.RequestAssembler;
	import components.static.CMD;
	import components.static.DS;
	import components.system.UTIL;
	
	public class UIWifiAP extends UI_BaseComponent implements IResizeDependant
	{
		private var firsttime:Boolean = true;
		private var anchor:int;
		private var ftable:MFlexTable;
		private var cbShowPass:IFormString;
		
		public function UIWifiAP()
		{
			super();
			
			/**
			 * Команда WIFI_POINT_SETTINGS - настройка точки доступа сети WIFI, которую создает прибор.

				Параметр 1 - Режим точки доступа Wi-Fi, 0-точка доступа выключена, 1-точка доступа включена;
				Параметр 2 - SSID точки доступа;
				Параметр 3 - Скрыть SSID точки доступа из эфира, 0-SSID видно, 1-SSID не видно;
				Параметр 4 - Безопасность (0 - открытая сеть, 1 - WEP, 2 - WPA2-PSK AES );
				Параметр 5 - Пароль для доступа;
				Параметр 6 - Радиоканал, 1-13.
 			* */
			const shift:int = 250;
			const padding_horis:int = 150; 
			
			addui( new FSCheckBox, CMD.WIFI_POINT_SETTINGS, loc("wifi_ap_mode"), null, 1 );
			attuneElement( shift, 246 );
			FLAG_VERTICAL_PLACEMENT = false;
			const lbl:String = loc("ui_wifi_ssid") + "                                        " + DS.alias + "  ";
			addui( new FSSimple, CMD.WIFI_POINT_SETTINGS, lbl, null, 2, null, "0-9,A-z", 28 );
			getLastElement().setAdapter( new AdaptSSID() );
			attuneElement( shift , 246,  FSSimple.F_CELL_ALIGN_LEFT );
			FLAG_VERTICAL_PLACEMENT = true;
			addui( new FSCheckBox, CMD.WIFI_POINT_SETTINGS, loc("g_hide"), null, 3 ).x = getLastElement().width + 340;
			attuneElement( padding_horis, 10 );
			addui( new FSComboBox, CMD.WIFI_POINT_SETTINGS, loc("ui_wifi_security"), null, 4, UTIL.getComboBoxList( UIWifi.WIFI_SECURITY_CB ) );
			attuneElement( shift + 147, 100, FSComboBox.F_COMBOBOX_NOTEDITABLE );
			
			FLAG_VERTICAL_PLACEMENT = false;
			FLAG_SAVABLE = false;
			addui( new FSCheckBox, 0, loc("g_show_pass"), onShowPass, 3 ).x = getLastElement().width + 340;
			cbShowPass = getLastElement();
			attuneElement( padding_horis, 10 );
			FLAG_VERTICAL_PLACEMENT = true;
			FLAG_SAVABLE = true;
			
			addui( new FSSimple, CMD.WIFI_POINT_SETTINGS, loc("g_pass"), null, 5 );
			attuneElement( shift, 247, FSSimple.F_CELL_ALIGN_CENTER);
			addui( new FSComboBox, CMD.WIFI_POINT_SETTINGS, loc("wifi_radioch"), null, 6, UTIL.comboBoxNumericDataGenerator(1,13), 
				"0-9", 2, new RegExp(RegExpCollection.COMPLETE_1to16) );
			attuneElement( shift + 147, 100 );
			addui( new FSShadow, CMD.WIFI_POINT_SETTINGS, "", null, 7 );
			
			drawSeparator();
			
			FLAG_SAVABLE = false;
			addui( new FSSimple, 0, loc("wifi_connected_it"), null, 1 );
			attuneElement(shift + 84, NaN, FSSimple.F_CELL_NOTSELECTABLE | FSSimple.F_CELL_ALIGN_RIGHT);
			addui( new FSSimple, 0, loc("wifi_can_connect"), null, 2 );
			attuneElement(shift + 84, NaN, FSSimple.F_CELL_NOTSELECTABLE | FSSimple.F_MULTYLINE | FSSimple.F_CELL_ALIGN_RIGHT);
			
			globalY += 10;
			
			ftable = new MFlexTable(new TableAdapter);
			addChild( ftable );
			ftable.width = 500;
			ftable.height = 500;
			ftable.y = globalY;
			ftable.x = globalX;
			ftable.headers = [[loc("wifi_ap_num"),25], loc("wifi_ap_client_name"), loc("lan_mac_adress"), loc("lan_ipadr"), [loc("lan_online"),100]];
			globalY += 25;
			
			width = 600;
			height = 380;

			starterCMD = CMD.WIFI_POINT_SETTINGS;
		}
		
		
		override public function open():void
		{
			super.open();
			ResizeWatcher.addDependent(this);
			cbShowPass.setCellInfo(0);
			onShowPass();
		}
		override public function put(p:Package):void
		{
			switch(p.cmd) {
				case CMD.WIFI_POINT_SETTINGS:
					distribute( p.getStructure(), p.cmd );
					if (p.getStructure()[6] > 0)
						RequestAssembler.getInstance().fireReadSequence( CMD.WIFI_POINT_CLIENT_LIST, put, p.getStructure()[6] );
					else {
						writeTotalConnections(0);
						ftable.visible = false;
						loadComplete();
					}
					break;
				case CMD.WIFI_POINT_CLIENT_LIST:
					ftable.put(p);
					ftable.visible = true;					
					writeTotalConnections(p.length);
					
					firsttime = false;
					loadComplete();
					
					ResizeWatcher.doResizeMe(this);
					break;
			}
		}
		public function localResize(w:int, h:int, real:Boolean=false):void
		{
			ftable.height = h - globalY;
			var ch:int = ftable.height + 20;
			var cw:int = w - 141;
			
			ftable.width = cw < 900 ? cw : 900;
			ftable.resize();
		}
		private function writeTotalConnections(n:int):void
		{
			getField(0,1).setCellInfo( n + " "+loc("g_loaded_from_bytes")+" 50" );
			getField(0,2).setCellInfo( 50-n );
		}
		private function tableAdapter(a:Array):Array
		{
			return [a[0],a[1],a[2],a[3]]
		}
		private function onShowPass():void
		{
			(getField(CMD.WIFI_POINT_SETTINGS,5) as FSSimple).displayAsPassword( cbShowPass.getCellInfo() == 0 );
		}
		
		private function delegateSsid( value:* ):void
		{
		
			
			
		}
	}
}
import mx.controls.dataGridClasses.DataGridColumn;

import components.abstract.functions.loc;
import components.interfaces.IDataAdapter;
import components.interfaces.IFormString;
import components.interfaces.IMTableAdapter;

class TableAdapter implements IMTableAdapter
{
	public function adapt(a:Array, n:int):Array
	{
		return [n,a[0],a[1],a[2],a[3] == 1 ?loc("lan_connected"):loc("lan_disconnected")];
	}
	public function getRowColor(rowIndex:int, sourceColor:uint):uint
	{
		return 0;
	}
	public function get isAdapt():Boolean
	{
		return true;
	}
	public function get isRowColor():Boolean
	{
		return false;
	}
	public function assignCellRenderer(c:DataGridColumn):void
	{
	}
	public function get isCellRenderer():Boolean
	{
		return false;
	}
}

import components.interfaces.IDataAdapter;

class AdaptSSID implements IDataAdapter
{
	private const NAME_PREF:String = "V15-";
	
	public function change(value:Object):Object
	{
		
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
		var str:String = String( value );
		
		return str.substr( 4 );
		
		
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
		
		return NAME_PREF + ( value as String );
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