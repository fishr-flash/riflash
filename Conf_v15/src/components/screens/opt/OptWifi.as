package components.screens.opt
{
	import flash.events.Event;
	
	import components.abstract.GroupOperator;
	import components.abstract.functions.loc;
	import components.basement.OptionsBlock;
	import components.gui.fields.FSCheckBox;
	import components.gui.fields.FSComboBox;
	import components.gui.fields.FSShadow;
	import components.gui.fields.FSSimple;
	import components.gui.fields.FormEmpty;
	import components.gui.triggers.TextButton;
	import components.interfaces.IFormString;
	import components.screens.ui.UIWifi;
	import components.static.CMD;
	import components.system.SavePerformer;
	import components.system.UTIL;
	
	public class OptWifi extends OptionsBlock
	{
		public static const EVENT_NEED_REFRESH:String="EVENT_NEED_REFRESH";
		public static const EVENT_DATA_READY:String="EVENT_DATA_READY";
		
		private var bStoreNet:TextButton;
		private var data:Array;
		private var g:GroupOperator;
		private var fsallow:FSCheckBox;
		private var fspass:FSSimple;
		private var fsSSID:FSSimple;
		private var fsSecurity:FSComboBox;
		private var fsSecuritySimple:FSSimple;
		private var fIsNetStored:Function;	// return array
		
		public var SSID:String;
		private var cbPass:IFormString;
		
		public function OptWifi(f:Function)
		{
			super();
			
			/**	Параметр 1 0- SSID; ( Сохраненное имя сети или считанное из эфира, если сеть не добавлена в прибор );
				Параметр 2 1- Безопасность (0 - открытая сеть, 1 - WEP, 2 - WPA2-PSK AES ), считанное из эфира, если сеть не добавлена в прибор;
				Параметр 3 2- Состояние, 0-Отключено, 1-Подключено;
				Параметр 4 3- Уровень сигнала сети, 0-Сигнал потерян, 1-Плохой, 2-Слабый, 3-Хороший, 4-Сильный;
				Параметр 5 4- Скорость соединения, строка с обозначением размерности скорости;
				Параметр 6 5- Безопасность сети, считанная из эфира, строка, с безопасностью;
				Параметр 7 6- IP адрес.	*/
			
			operatingCMD = CMD.WIFI_NETS_VISIBLE;
			
			globalX = 0;
			
			fIsNetStored = f;
			
			var shift:int = 250;
			
			g = new GroupOperator;
			
			g.setAnchor( "1", globalY );
			
			fsallow = createUIElement( new FSCheckBox, 0, loc("wifi_allow_conn"), onNetChange, 1 ) as FSCheckBox;
			attuneElement( shift );
			g.add("hide", getLastElement() );
			g.addPattern( "restore", getLastElement(), {y:getLastElement().y, visible:true} );
			
			fsSSID = createUIElement( new FSSimple, operatingCMD, "SSID", onNetChange, 1, null, "_`{}|~A-z0-9 !\"#$%&'()*+,-./:;<=>?@[\\]^", 32 ) as FSSimple;
			attuneElement( shift, 300, FSSimple.F_CELL_ALIGN_LEFT );
			g.add("1", getLastElement() );
			g.addPattern( "restore", getLastElement(), {y:getLastElement().y, visible:true} );

			g.setAnchor( "2", globalY );
			
			FLAG_VERTICAL_PLACEMENT = false;
			var secur:Array = UTIL.getComboBoxList( UIWifi.WIFI_SECURITY_CB );
			fsSecurity = createUIElement( new FSComboBox, operatingCMD, loc("ui_wifi_security"), onNetChange,2,secur) as FSComboBox;
			attuneElement( shift, NaN, FSComboBox.F_COMBOBOX_NOTEDITABLE );
			
			FLAG_VERTICAL_PLACEMENT = true;
			fsSecuritySimple = createUIElement( new FSSimple, 1, loc("ui_wifi_security"), null,1) as FSSimple;
			attuneElement( shift, NaN, FSSimple.F_CELL_NOTSELECTABLE | FSSimple.F_CELL_ALIGN_LEFT);
			fsSecuritySimple.y = fsSecurity.y;
			
			g.add("1", getLastElement() );
			g.addPattern( "restore", getLastElement(), {y:getLastElement().y, visible:true} );
			
			FLAG_SAVABLE = false;
			FLAG_VERTICAL_PLACEMENT = false;
			cbPass = addui( new FSCheckBox, 0, loc("g_show_pass"), onPass, 1 );
			attuneElement( 140 );
			(cbPass as FormEmpty).x = 410;
			g.add("hide", getLastElement() );
			g.addPattern( "restore", getLastElement(), {y:getLastElement().y, visible:true} );
			FLAG_SAVABLE = true;
			FLAG_VERTICAL_PLACEMENT = true;
			
			fspass = createUIElement( new FSSimple, 0, loc("g_pass"), onNetChange, 2, null, "_`{}|~A-z0-9 !\"#$%&'()*+,-./:;<=>?@[\\]^", 32 ) as FSSimple;
			attuneElement( shift );
			g.add("hide", getLastElement() );
			g.addPattern( "restore", getLastElement(), {y:getLastElement().y, visible:true} );
			
			createUIElement( new FSSimple, operatingCMD, loc("wifi_state"), null, 3 );
			attuneElement( shift, 250, FSSimple.F_CELL_NOTSELECTABLE | FSSimple.F_CELL_ALIGN_LEFT );
			getLastElement().setAdapter(new WifiStatusAdaptor);
			g.add("2", getLastElement() );
			g.addPattern( "restore", getLastElement(), {y:getLastElement().y, visible:true} );
			
			createUIElement( new FSSimple, operatingCMD, loc("ui_wifi_signal_level"), null, 4 );
			attuneElement( shift, 250, FSSimple.F_CELL_NOTSELECTABLE | FSSimple.F_CELL_ALIGN_LEFT );
			getLastElement().setAdapter(new SignalAdaptor);
			g.add("2", getLastElement() );
			g.addPattern( "restore", getLastElement(), {y:getLastElement().y, visible:true} );
			
			createUIElement( new FSSimple, operatingCMD, loc("wifi_conn_speed"), null, 5 );
			attuneElement( shift, NaN, FSSimple.F_CELL_NOTSELECTABLE | FSSimple.F_CELL_ALIGN_LEFT );
			g.add("2", getLastElement() );
			g.addPattern( "restore", getLastElement(), {y:getLastElement().y, visible:true} );
			
			createUIElement( new FSSimple, operatingCMD, loc("ui_wifi_security"), null, 6 );
			attuneElement( shift, 400, FSSimple.F_CELL_NOTSELECTABLE | FSSimple.F_CELL_ALIGN_LEFT );
			g.add("2", getLastElement() );
			g.addPattern( "restore", getLastElement(), {y:getLastElement().y, visible:true} );
			
			createUIElement( new FSSimple, operatingCMD, loc("ui_wifi_ip"), null, 7 );
			attuneElement( shift, NaN, FSSimple.F_CELL_NOTSELECTABLE | FSSimple.F_CELL_ALIGN_LEFT );
			g.add("2", getLastElement() );
			g.addPattern( "restore", getLastElement(), {y:getLastElement().y, visible:true} );
			
			bStoreNet = new TextButton;
			addChild( bStoreNet );
			bStoreNet.setUp( loc("wifi_add_to_device"), onStore );
			bStoreNet.y = globalY;
			g.add("2", bStoreNet );
			g.addPattern( "restore", bStoreNet, {y:bStoreNet.y, visible:false} );
			
			addui( new FSShadow, CMD.WIFI_NETS_CHANGE, "", null, 1 );
			addui( new FSShadow, CMD.WIFI_NETS_CHANGE, "", null, 2 );
			addui( new FSShadow, CMD.WIFI_NETS_CHANGE, "", null, 3 );
			addui( new FSShadow, CMD.WIFI_NETS_CHANGE, "", null, 4 );
			addui( new FSShadow, CMD.WIFI_NETS_CHANGE, "", null, 5 );
		}
		public function show(a:Array, str:int):void
		{
			
			/**	Параметр 1 0- SSID; ( Сохраненное имя сети или считанное из эфира, если сеть не добавлена в прибор );
			 Параметр 2 1- Безопасность (0 - открытая сеть, 1 - WEP, 2 - WPA2-PSK AES ), считанное из эфира, если сеть не добавлена в прибор;
			 Параметр 3 2- Состояние, 0-Отключено, 1-Подключено;
			 Параметр 4 3- Уровень сигнала сети, 0-Сигнал потерян, 1-Плохой, 2-Слабый, 3-Хороший, 4-Сильный;
			 Параметр 5 4- Скорость соединения, строка с обозначением размерности скорости;
			 Параметр 6 5- Безопасность сети, считанная из эфира, строка, с безопасностью;
			 Параметр 7 6- IP адрес.	*/
			
			cbPass.setCellInfo(0);
			onPass();
			
			data = null;
			this.visible = true;
			structureID = str;
			refreshCells( operatingCMD );
			var atemp:Array;
			if (a.length<7) {
				atemp = new Array;
				atemp.length = 7;
				atemp[0] = a[1];
				atemp[1] = a[2];
				atemp[2] = 0;
				atemp[3] = 0;
				atemp[4] = "";
				atemp[5] = "";
				atemp[6] = "";
				fsallow.setCellInfo(a[0]);
				fspass.setCellInfo(a[3]);
				
				a = atemp;
			}
			
			distribute( a, operatingCMD );
			
			getField(1,1).setCellInfo( UIWifi.WIFI_SECURITY_SHOW[a[1]][1] );
			getField(operatingCMD,7).visible = a[2] == 1;
			
			// проверка есть ли в списках сохраненная сеть
			var stored:Array = fIsNetStored(a[0]);
			if( stored ) {	// сеть добавлена в прибор
				g.executePattern("restore", ["y","visible"] );
				fsSSID.attune( FSSimple.F_CELL_SELECTABLE);
				//fsSecurity.attune( FSComboBox.F_COMBOBOX_CLICKABLE);
				fsSecurity.visible = true;
				fsSecuritySimple.visible = false;
				refreshCells( CMD.WIFI_NETS_CHANGE,true,1 );
				fsallow.setCellInfo( stored[0] );
				fspass.setCellInfo( stored[3] );
				
				fspass.disabled = int(fsSecurity.getCellInfo()) == 0;
				//cbPass.visible = !fspass.disabled; 
			} else {
				g.visible("hide", false );
				g.movey( "1", g.getAnchor("1") );
				g.movey( "2", g.getAnchor("2") );
				fsSSID.attune( FSSimple.F_CELL_NOTSELECTABLE );
				//fsSecurity.attune( FSComboBox.F_COMBOBOX_NOTCLICKABLE);
				fsSecurity.visible = false;
				fsSecuritySimple.visible = true;
				bStoreNet.visible = true;
			}
			
			
			/*fsallow.visible = a[1] == 1;
			g.movey("1", a[1] != 1? g.getAnchor("1"):g.getAnchor("2") );*/
			SSID = a[0];
		}
		public function getDeleteData():Array
		{
			var a:Array = [0,0,getField(operatingCMD,1).getCellInfo(),0,""];
			return [0,0,getField(operatingCMD,1).getCellInfo(),0,""];
		}
		public function getRestoreData():Array
		{
			return [getField(operatingCMD,1).getCellInfo(), int(getField(operatingCMD,2).getCellInfo()), String(fspass.getCellInfo())];
		}
		public function getAddingData():Array
		{
			if (data) {
				var a:Array = data.slice();
				data = null;
				return a;
			}	
			return null;
		}
		public function getChangeData():Array
		{
			/**	Команда WIFI_NETS_CHANGE - добавить/удалить сеть WIFI
			
			Параметр 1 - Добавление сети в прибор, 0 - удалить сеть из прибора , 1- добавить сеть в прибор ( изменить настройки сети, которая уже есть в приборе )
			Параметр 2 - Разрешено подключаться к сети, 0 - нет, 1 - да;
			Параметр 3 - SSID; ( Имя сети, которую хотим удалить или добавить. );
			Параметр 4 - Безопасность (0 - открытая сеть, 1 - WEP, 2 - WPA2-PSK AES )
			Параметр 5 - Пароль;		*/
			
			return [
				1,
				int(getField(operatingCMD,3).getCellInfo()),
				getField(operatingCMD,4).getCellInfo(),
				int(getField(operatingCMD,5).getCellInfo()),
				getField(operatingCMD,6).getCellInfo(),
				];
		}
		private function onStore():void
		{
			var ssid:String = getField(operatingCMD,1).getCellInfo() as String;
			if (ssid == "")
				ssid = "unnamed";
			data = [ssid, int(getField(operatingCMD,2).getCellInfo())];
			this.dispatchEvent( new Event( EVENT_DATA_READY ));
		//	RequestAssembler.getInstance().fireEvent( new Request(CMD.WIFI_NETS_CHANGE, null, 1, getChangeData() ));
		//	this.dispatchEvent( new Event(EVENT_NEED_REFRESH));
		}
		private function onNetChange(t:IFormString):void
		{
			/**	Команда WIFI_NETS_CHANGE - добавить/удалить сеть.
			 
			 Параметр 1 - Добавление сети в прибор, 0 - удалить сеть из прибора , 1- добавить сеть в прибор ( изменить настройки сети, которая уже есть в приборе )
			 Параметр 2 - Разрешено подключаться к сети, 0 - нет, 1 - да;
			 Параметр 3 - SSID; ( Имя сети, которую хотим удалить или добавить. );
			 Параметр 4 - Безопасность (0 - открытая сеть, 1 - WEP, 2 - WPA2-PSK AES )
			 Параметр 5 - Пароль;	*/	
			
			fspass.disabled = int(fsSecurity.getCellInfo()) == 0;
			
			getField(CMD.WIFI_NETS_CHANGE,1).setCellInfo(1);
			getField(CMD.WIFI_NETS_CHANGE,2).setCellInfo(fsallow.getCellInfo());
			getField(CMD.WIFI_NETS_CHANGE,3).setCellInfo(fsSSID.getCellInfo());
			getField(CMD.WIFI_NETS_CHANGE,4).setCellInfo(fsSecurity.getCellInfo());
			getField(CMD.WIFI_NETS_CHANGE,5).setCellInfo(fspass.getCellInfo());
			
			SavePerformer.remember( 1, getField(CMD.WIFI_NETS_CHANGE,1) );
		}
		private function onPass():void
		{
			(getField( 0, 2) as FSSimple).displayAsPassword( cbPass.getCellInfo() == 0 );
		}
	}
}
import components.abstract.functions.loc;
import components.interfaces.IDataAdapter;
import components.interfaces.IFormString;

class SignalAdaptor implements IDataAdapter
{
	// 0-Сигнал потерян, 1-Плохой, 2-Слабый, 3-Хороший, 4-Сильный;
	public function adapt(value:Object):Object
	{
		switch(value) {
			case 0:
				return loc("wifi_s_lost");
			case 1:
				return loc("wifi_s_poor");
			case 2:
				return loc("wifi_s_low");
			case 3:
				return loc("wifi_s_good");
			case 4:
				return loc("wifi_s_ex");
		}
		return loc("g_invalid_value");
	}
	
	public function perform(field:IFormString):void	{	}
	public function recover(value:Object):Object	{		return null;	}
	public function change(value:Object):Object 	{ return value	}
}
class WifiStatusAdaptor implements IDataAdapter
{
	//0-Отключено, 1-Подключено;
	public function adapt(value:Object):Object
	{
		switch(value) {
			case 0:
				return loc("wifi_disabled_it");
			case 1:
				return loc("wifi_enabled_it");
		}
		return loc("g_invalid_value");
	}
	
	public function perform(field:IFormString):void	{	}
	public function recover(value:Object):Object	{		return null;	}
	public function change(value:Object):Object 	{ return value	}
}
