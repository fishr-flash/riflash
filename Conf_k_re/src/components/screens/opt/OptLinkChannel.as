package components.screens.opt
{
	import flash.events.Event;
	
	import components.abstract.RegExpCollection;
	import components.abstract.adapters.StringCutterAdapter;
	import components.abstract.functions.loc;
	import components.basement.OptionsBlock;
	import components.events.GUIEvents;
	import components.gui.fields.FSComboBox;
	import components.gui.fields.FSShadow;
	import components.gui.fields.FormString;
	import components.interfaces.IFormString;
	import components.screens.ui.UILinkChannelsK5;
	import components.screens.ui.UILinkChannelsK9;
	import components.static.CMD;
	import components.static.DS;
	
	/** Редакция для 5-9 Контакта */
	
	public class OptLinkChannel extends OptionsBlock
	{
		private var comLink:Array;
		private var comGRPS1:Array;
		private var comGRPS2:Array;
		private var channel:FSComboBox;
		private var tel:FormString;
		private var reNeedTel:RegExp;
		//private var bg:Sprite;
		private var LOADING:Boolean=false;	// если false то будут очищаться поля Телефон/ип адрес при загрузке
		
		public var emptyvalue:int;
		
		public function OptLinkChannel(struct:int)
		{
			super();
			
			switch(DS.alias) {
				case DS.isfam( DS.K5 ):
					emptyvalue = 0;
					break;
				case DS.K9:
				case DS.K9A:
				case DS.K9M:
				case DS.K9K:
				case DS.K1:
				case DS.K1M:
					emptyvalue = 0xff;
					
					reNeedTel =  new RegExp(RegExpCollection.COMPLETE_ATLEST3SYMBOL);
					break;
			}
			
			createChannels();
			
			structureID = struct;
			complexHeight = 25;
			FLAG_VERTICAL_PLACEMENT = false;
			
			FLAG_SAVABLE = false;
			addui( new FormString, 0, loc("g_number")+" " + structureID, null, 1 );
			FLAG_SAVABLE = true;
			
			/**	Параметр 2 - Телефонный номер или IP адрес или доменное имя */
			addui( new FSShadow, CMD.K5_APHONE, "", null, 1 );
			tel = createUIElement( new FormString, CMD.K5_APHONE,"",changeTel,2,null,"+0-9,W",32  ) as FormString;
			getLastElement().setAdapter( new StringCutterAdapter(getField(CMD.K5_APHONE,1)));
			attuneElement( 250,NaN, FormString.F_EDITABLE );
			tel.x = 450;
			//	tel.disabled = true;
			var first:int = tel.focusorder;
			tel.focusorder++;
			
			
			switch(DS.alias) {
				case DS.isfam( DS.K5 ):
					operatingCMD = CMD.K5_DIRECTIONS;
					break;
				case DS.K9:
				case DS.K9A:
				case DS.K9M:
				case DS.K9K:
				case DS.K1:
				case DS.K1M:
					operatingCMD = CMD.K9_DIRECTIONS;
					break;
			}
			
			channel = createUIElement( new FSComboBox, operatingCMD,"",changeChannel,1,comLink) as FSComboBox;
			attuneElement( 370,NaN, FSComboBox.F_COMBOBOX_NOTEDITABLE );
			channel.x = 70;
			channel.focusorder = first;
			switch(DS.alias) {
				case DS.isfam( DS.K5 ):
					channel.setAdapter( new EndianAdapter(structureID) );
					break;
				case DS.K9:
				case DS.K9A:
				case DS.K9M:
				case DS.K9K:
				case DS.K1:
				case DS.K1M:
					channel.setAdapter( new ChannelK9Adapter(structureID) );
					break;
			}
		}
		public function setColor(c:uint):void
		{
			if (getStructure() == 1)
				trace("  ");
			trace(c.toString(16));
			this.graphics.clear();
			this.graphics.beginFill( c, 0.09 );
			this.graphics.drawRoundRect( -8,-5,720, 30,5,5);
			this.graphics.endFill();
		}
		public function setList(sim1:Boolean, sim2:Boolean):void
		{
			var l:Array = comLink.slice();
			if (!sim1)
				l = comLink.concat( comGRPS1 );
			if (!sim2)
				l = l.concat( comGRPS2 );
			
			channel.setList( l );
			
			var len:int = l.length;
			var found:Boolean = false;
			var n:int = int(channel.getCellInfo());
			//var value:int = (n >> 8) & 0xF8  | ((n & 0x00FF) << 8)
			var value:int;
			// для проверки в К5 нужно перевернуть байты LitleEndian в Bigendian и отрезать 0,1,2 биты 
			if (DS.isfam( DS.K5 ))
				value = (n >> 8) & 0xF8  | ((n & 0x00FF) << 8)
			else {	// в К9 нужно отрезать 0,1,2 биты
				if (n == 0xff)
					value = n;
				else
					value = n & 0x07F8;
			}
			
			for (var i:int=0; i<len; i++) {
				if( l[i].data == value ) {
					found = true;
					break;
				}
			}
			if (!found) {
				channel.setCellInfo(emptyvalue);
				callLater(changeChannel,[channel]);
				
			}
		}
		public function putDirection(n:int):void
		{
			switch(DS.alias) {
				case DS.isfam( DS.K5 ):
					channel.setCellInfo( n );
					break;
				case DS.K9:
				case DS.K9A:
				case DS.K9M:
				case DS.K9K:
				case DS.K1:
				case DS.K1M:
					if (n == emptyvalue)
						channel.setCellInfo( n );
					else {
						var b:Boolean = channel._rule.test( String(n & 0xF8) );
						if (b)
							channel.setCellInfo( n );
						else
							channel.setCellInfo( emptyvalue );
					}
					
					phoneDisable();
					break;
			}
		}
		public function putPhone(a:Array):void
		{
			distribute( a, CMD.K5_APHONE );
		}
		public function rememberchange():void
		{
			remember(channel);
			remember(tel);
		}
		private function get master():Boolean
		{
			switch(DS.alias) {
				case DS.isfam( DS.K5 ):
					return UILinkChannelsK5.MASTER
				case DS.K9:
				case DS.K9A:
				case DS.K9M:
				case DS.K9K:
				case DS.K1:
				case DS.K1M:
					return UILinkChannelsK9.MASTER
			}
			return false;
		}
		
		private function changeTel(t:IFormString):void
		{
			this.dispatchEvent( new Event( GUIEvents.EVOKE_CHANGE_PARAM ));
			remember(t);
		}
		private function changeChannel(t:IFormString):void
		{
			if (!master) {
				remember(t);
				this.dispatchEvent( new Event( GUIEvents.EVOKE_CHANGE ));
			}
			
			phoneDisable();
			
		}
		/**
		 * В зависимости от выбранного типа связи проверяет
		 * нужна ли валидация введенных тел.номеров. При типе связи 
		 * через GPRS, номер не нужен, поэтому и валидация ненужна
		 */
		private function phoneDisable():void
		{
			var value:int = int(channel.getCellInfo());
		
			
			if
			(
				 value == emptyvalue ||
				 ( value > 7 && value < 25 ) ||
				 ( value > 71 && value < 88 ) 
			)
			{
				tel.rule = null;
			}
			else
			{
				tel.rule = reNeedTel;
			}
			
			
			tel.setCellInfo( tel.getCellInfo() );
		}
		public function set active(b:Boolean):void
		{
			if (!b) {
				if ( int(channel.getCellInfo()) != emptyvalue) {
					channel.setCellInfo( emptyvalue );
					remember(channel);
				}
			}
		}
		public function get active():Boolean
		{
			var o:Object = channel.getCellInfo();
			return int(channel.getCellInfo()) != emptyvalue; 
		}
		public function getData():Array
		{
			return [structureID,int(channel.getCellInfo()),[getField(CMD.K5_APHONE,1).getCellInfo(),tel.getCellInfo()]];
		}
		public function getDir():int
		{
			var l:Array = channel.getList();
			var len:int = l.length;
			var n:int = int(channel.getCellInfo());
			var found:Boolean = false;
			var value:int;
			if (DS.isfam( DS.K5 ))
				value = (n >> 8) & 0xF8  | ((n & 0x00FF) << 8)
			else
				value = n & 0xF8;
			for (var i:int=0; i<len; i++) {
				if( l[i].data == value ) {
					found = true;
					break;
				}
			}
			if (!found)
				return emptyvalue;
			if (!channel.valid)
				return emptyvalue;
			return int(channel.getCellInfo());
		}
		public function getTel():Array
		{
			return [int(getField(CMD.K5_APHONE,1).getCellInfo()),tel.getCellInfo()];
		}
		private function createChannels():void
		{
			/** K9 Directions	Параметры	Биты												
			 Параметр 1	7												
			 6	Номер симкарты: 1 - SIM1, 0 - SIM2											
			 5	"Тип соединения:
			 6 – цифровое протокол v.110, 
			 4 – СМС на InerServer, 
			 3 – СМС, 
			 2 – GPRS как направление IP2,
			 1 – GPRS как направление IP1, 
			 0 – цифровое протокол v.32"											
			 4												
			 3												
			 2	Индекс номера телефона											
			 1												
			 0												*/
			
			comLink = [ ];
			switch(DS.alias) {
				
				case DS.isfam( DS.K5 ):
					comLink = comLink.concat( [
						{label:loc("ui_linkch_not_in_use"),data:emptyvalue},
						{label:loc("ui_linkch_cid_v32_sim1"),data:1968},
						{label:loc("ui_linkch_cid_v32_sim2"),data:1712},
						{label:loc("ui_linkch_cid_v110_sim1"),data:1928},
						{label:loc("ui_linkch_cid_v110_sim2"),data:1672},
						/// добавляется ниже если прибор не К-53джи
						/*{label:loc("ui_linkch_cid_voice_sim1"),data:1920},
						{label:loc("ui_linkch_cid_voice_sim2"),data:1664},*/// 8й бит симкарты должен быть 0
						//исключено для списка упрощенной версии К-5А
						/*{label:loc("ui_linkch_cid_pulse"),data:1536},
						{label:loc("ui_linkch_cid_tone"),data:1600},*/
						{label:loc("ui_linkch_sms_sim1"),data:1944},
						{label:loc("ui_linkch_sms_sim2"),data:1688},
						{label:loc("ui_linkch_sms_inetserver_sim1"),data:1952},
						{label:loc("ui_linkch_sms_inetserver_sim2"),data:1696},
					] );
					comGRPS1 = [
						{label:loc("ui_linkch_gprsoffline_sim1_ip1"),data:2000},
						{label:loc("ui_linkch_gprsoffline_sim1_ip2"),data:1936}
					];
					comGRPS2 = [
						{label:loc("ui_linkch_gprsoffline_sim2_ip1"),data:1744},
						{label:loc("ui_linkch_gprsoffline_sim2_ip2"),data:1680}
					];
				
				
				 
				 if( DS.isfam( DS.K5, DS.K5, DS.K53G ) ) break;
					 comLink.splice( 5, 0, {label:loc("ui_linkch_cid_pulse"),data:1536}, {label:loc("ui_linkch_cid_tone"),data:1600} );
				 if( DS.alias == DS.K53G || DS.isDevice( DS.A_BRD )) break;
					 comLink.splice( 5, 0, {label:loc("ui_linkch_cid_voice_sim1"),data:1920}, {label:loc("ui_linkch_cid_voice_sim2"),data:1664} );
				  
					break;
				case DS.K9:
				case DS.K9A:
				case DS.K9M:
				case DS.K9K:
				case DS.K1:
				case DS.K1M:
					if (int(DS.app) == 5 || int(DS.app) == 2 ) {
						comLink = comLink.concat( [
							{label:loc("ui_linkch_not_in_use"),data:emptyvalue},
							{label:loc("ui_linkch_cid_v32_sim1"),data:64},
							{label:loc("ui_linkch_cid_v32_sim2"),data:0},
							{label:loc("ui_linkch_cid_v110_sim1"),data:112},
							{label:loc("ui_linkch_cid_v110_sim2"),data:48},
							{label:loc("ui_linkch_sms_sim1"),data:88},
							{label:loc("ui_linkch_sms_sim2"),data:24},
							{label:loc("ui_linkch_sms_inetserver_sim1"),data:96},
							{label:loc("ui_linkch_sms_inetserver_sim2"),data:32}
						] );
						comGRPS2 = [
							{label:loc("ui_linkch_gprsoffline_sim2_ip1"),data:8},
							{label:loc("ui_linkch_gprsoffline_sim2_ip2"),data:16}
						];
					} else {
						comLink = comLink.concat( [
							{label:loc("ui_linkch_not_in_use"),data:emptyvalue},
							{label:loc("ui_linkch_cid_v32_sim1"),data:64},
							{label:loc("ui_linkch_cid_v110_sim1"),data:112},
							{label:loc("ui_linkch_sms_sim1"),data:88},
							{label:loc("ui_linkch_sms_inetserver_sim1"),data:96},
						] );
						comGRPS2 = [];
					}
					comGRPS1 = [
						{label:loc("ui_linkch_gprsoffline_sim1_ip1"),data:72},
						{label:loc("ui_linkch_gprsoffline_sim1_ip2"),data:80}
					];
					
					break;
			}
			
		}
	}
}
import components.interfaces.IDataAdapter;
import components.interfaces.IFormString;
import components.system.UTIL;
class ChannelK9Adapter implements IDataAdapter
{
	private var telindex:int;
	
	public function ChannelK9Adapter(n:int):void
	{
		telindex = n-1;
	}
	public function adapt(value:Object):Object
	{
		
		if ( int(value) == 0xff)	// канал отключен
			return 0xff;
		return int(value) & 0x07F8;
	}
	public function change(value:Object):Object
	{
		return value;
	}
	public function perform(field:IFormString):void
	{
	}
	public function recover(value:Object):Object
	{
		
		if ( int(value) == 0xff)	// канал отключен
			return 0xff;
		
		var n:int = int(value) | telindex;
		return n;
	}
}
class EndianAdapter implements IDataAdapter
{
	private var telindex:int;
	
	public function EndianAdapter(n:int):void
	{
		telindex = n-1;
	}
	public function adapt(value:Object):Object
	{
		var n:int = int(value);
		var res:int = (n >> 8) | ((n & 0x00FF) << 8);
		
		/**
		 если 7 бит — 1, игнорируется 6 бит
		 за исключением если 3-5 бит — 010, тогда 6 бит не игнорируется
		 7 бит — 0, игнорируется 8 бит
		 */
		if (!UTIL.isBit(7,res) ) {
			return res & 0x06F8;		// игнорировать 8 бит (СИМкарты) при проводной линии
		} else if ( ((res & 0x38) >> 3) != 2 )	{// игнорируется 6 бит
			return res & 0x07B8; 
		}
		return res & 0x07F8;
	}
	public function change(value:Object):Object
	{
		return value;
	}
	public function perform(field:IFormString):void	{	}
	public function recover(value:Object):Object
	{
		if (value == 0 || value == 0xff) {
			return 0;
		}
		var n:int = int(value) | telindex;
		var res:int = (n >> 8) | ((n & 0x00FF) << 8);
		return res;
	}
}