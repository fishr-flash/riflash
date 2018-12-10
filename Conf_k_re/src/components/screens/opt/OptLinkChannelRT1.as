package components.screens.opt
{
	import flash.events.Event;
	
	import components.abstract.RegExpCollection;
	import components.abstract.functions.loc;
	import components.basement.OptionsBlock;
	import components.events.GUIEvents;
	import components.gui.fields.FSComboBox;
	import components.gui.fields.FSShadow;
	import components.gui.fields.FormString;
	import components.interfaces.IFormString;
	import components.protocol.Package;
	import components.screens.ui.UILinkChannelsRT1;
	import components.static.CMD;
	import components.static.COLOR;
	import components.static.DS;
	
	public class OptLinkChannelRT1 extends OptionsBlock
	{
		private const colors:Array = [COLOR.WIRE_LIGHT_BROWN, COLOR.CIAN, COLOR.GREEN_EMERALD, COLOR.YELLOW_SIGNAL, COLOR.VIOLET, COLOR.SATANIC_INVERT_GREY, COLOR.GLAMOUR, COLOR.BLUE ];
		
		public var emptyvalue:int;
		
		private var comLink:Array;
		private var comLinkHash:Array;
		private var comGRPS1:Array;
		private var comGRPS2:Array;
		private var channel:FSComboBox;
		private var tel:FormString;
		private var grp:IFormString;
		private var reNeedTel:RegExp;
		private var flagOfBlockForWriting:Boolean;
		
		public function OptLinkChannelRT1(struct:int)
		{
			super();
			
			reNeedTel = new RegExp(RegExpCollection.COMPLETE_ATLEST3SYMBOL);
			
			emptyvalue = 0;
			structureID = struct;
			complexHeight = 25;
			FLAG_VERTICAL_PLACEMENT = false;
			
			FLAG_SAVABLE = false;
			addui( new FormString, 0, loc("g_number")+" " + structureID, null, 1 );
			FLAG_SAVABLE = true;
			
			operatingCMD = CMD.K5RT_DIRECTIONS;
			
			/**"Команда K5RT_DIRECTIONS - каналы связи 
			 Параметр 1 -  номер направления, от 1 до 8
			 Параметр 2 - порядковый номер телефона, от 1 до 8 (соответствует номеру структуры)
			 Параметр 3 - метод передачи, 0 - GSM, 1 - проводной
			 Параметр 4 - номер симкарты, 0 - SIM1, 1 - SIM2
			 Параметр 5 - тип набора по проводной линии, 0 - импульсный, 1 - тоновый 
			 Параметр 6 -тип канала:
			 0 - номер не используется,
			 1 - DTMF,
			 2 - CSD по протоколу v.32
			 3 - GPRS offline по основному IP
			 4 - GPRS offline по резервному IP
			 5 - SMS в IServer
			 6 - Резерв
			 7 - CSD по протоколу v.110
			 Параметр 7 - номер телефона */
			
			grp = addui( new FSShadow, operatingCMD, "", null, 1 ) as IFormString;
			addui( new FSShadow, operatingCMD, "", null, 2 );
			
			addui( new FSShadow, operatingCMD, "", null, 3 );
			addui( new FSShadow, operatingCMD, "", null, 4 );
			addui( new FSShadow, operatingCMD, "", null, 5 );
			addui( new FSShadow, operatingCMD, "", null, 6 );
			
			tel = createUIElement( new FormString, operatingCMD,"",changeTel,7,null,"+0-9, W",32) as FormString;
			attuneElement( 250,NaN, FormString.F_EDITABLE );
			tel.x = 450;
			var first:int = tel.focusorder;
			tel.focusorder++;
			
			/**"Команда K5RT_DIRECTIONS - каналы связи 
			 Параметр 1 -  номер направления, от 1 до 8
			 Параметр 2 - порядковый номер телефона, от 1 до 8 (соответствует номеру структуры)
			 Параметр 3 - метод передачи, 0 - GSM, 1 - проводной
			 Параметр 4 - номер симкарты, 0 - SIM1, 1 - SIM2
			 Параметр 5 - тип набора по проводной линии, 0 - импульсный, 1 - тоновый 
			 Параметр 6 -тип канала:
			 0 - номер не используется,
			 1 - DTMF,
			 2 - CSD по протоколу v.32
			 3 - GPRS offline по основному IP
			 4 - GPRS offline по резервному IP
			 5 - SMS в IServer
			 6 - Резерв
			 7 - CSD по протоколу v.110
			 Параметр 7 - номер телефона */
			
			comLink = [
				{label:loc("ui_linkch_not_in_use"),data:emptyvalue},
				{label:loc("ui_linkch_cid_v32_sim1"),data:1},	// Contact ID через цифровой канал GSM (V.32) - SIM1: 3-0,4-0,5-1,6-2
				{label:loc("ui_linkch_cid_v32_sim2"),data:2},	// Contact ID через цифровой канал GSM (V.32) - SIM2: 3-0,4-1,5-1,6-2
				{label:loc("ui_linkch_cid_v110_sim1"),data:3},	// Contact ID через цифровой канал GSM (V.110) - SIM1: 3-0,4-0,5-1,6-7
				{label:loc("ui_linkch_cid_v110_sim2"),data:4},	// Contact ID через цифровой канал GSM (V.110) - SIM2: 3-0,4-1,5-1,6-7
				/// если это не урезанная версия прибора сюда будут вставлены каналы ниже
				{label:loc("ui_linkch_sms_inetserver_sim1"),data:9},	// SMS InetServer - SIM1: 3-0,4-0,5-0,6-5
				{label:loc("ui_linkch_sms_inetserver_sim2"),data:10},	// SMS InetServer - SIM2: 3-0,4-1,5-0,6-5
			];
			
			
			if( DS.isDevice( DS.K5RT1L ) == false 
				&& DS.isDevice( DS.K5RT13G ) == false 
				&& DS.isDevice( DS.K5RT33G ) == false 
				&& DS.isDevice( DS.K5RT3L ) == false )
					comLink.splice
						( 
							5,
							0,
							{label:loc("ui_linkch_cid_voice_sim1"),data:5},	// Contact ID через голосовой канал GSM - SIM1: 3-0,4-0,5-1,6-1
							{label:loc("ui_linkch_cid_voice_sim2"),data:6},	// Contact ID через голосовой канал GSM - SIM2: 3-0,4-1,5-1,6-1
							{label:loc("ui_linkch_cid_pulse"),data:7},		// Contact ID по проводной линии импульсный набор: 3-1,4-0,5-0,6-1 
							{label:loc("ui_linkch_cid_tone"),data:8}		// Contact ID по проводной линии тональный набор: 3-1,4-0,5-1,6-1
						);
			
			
			if( DS.isDevice( DS.K5RT13G ) && DS.isDevice( DS.K5RT33G ))
					comLink.splice
						( 
							5,
							0,
							{label:loc("ui_linkch_cid_pulse"),data:7},		// Contact ID по проводной линии импульсный набор: 3-1,4-0,5-0,6-1 
							{label:loc("ui_linkch_cid_tone"),data:8}		// Contact ID по проводной линии тональный набор: 3-1,4-0,5-1,6-1
						);
			
			
			
			comLinkHash = [
				[0,0,0,0],				// 0
				[0,0,0,2],[0,1,0,2],	// 1-2
				[0,0,0,7],[0,1,0,7],	// 3-4
				[0,0,0,1],[0,1,0,1],	// 5-6
				[1,0,0,1],[1,0,1,1],	// 7-8
				[0,0,0,5],[0,1,0,5],	// 9-10
				[0,0,0,3],[0,0,0,4],	// 11-12
				[0,1,0,3],[0,1,0,4]		// 13-14
				];
			/*comLinkHash = [
			[0,0,0,0],				// 0
			[0,0,1,2],[0,1,1,2],	// 1-2
			[0,0,1,7],[0,1,1,7],	// 3-4
			[0,0,1,1],[0,1,1,1],	// 5-6
			[1,0,0,1],[1,0,1,1],	// 7-8
			[0,0,0,5],[0,1,0,5],	// 9-10
			[0,0,1,3],[0,0,1,4],	// 11-12
			[0,1,1,3],[0,1,1,4]		// 13-14
			];*/
			comGRPS1 = [
				{label:loc("ui_linkch_gprsoffline_sim1_ip1"),data:11},	// GPRS-offline SIM1 IP1: 3-0,4-0,5-1,6-3
				{label:loc("ui_linkch_gprsoffline_sim1_ip2"),data:12}		// GPRS-offline SIM1 IP2: 3-0,4-0,5-1,6-4
			];
			comGRPS2 = [
				{label:loc("ui_linkch_gprsoffline_sim2_ip1"),data:13},	// GPRS-offline SIM2 IP1: 3-0,4-1,5-1,6-3
				{label:loc("ui_linkch_gprsoffline_sim2_ip2"),data:14}		// GPRS-offline SIM2 IP2: 3-0,4-1,5-1,6-4
			];
			
			channel = createUIElement( new FSComboBox, 0,"",changeChannel,1,comLink) as FSComboBox;
			attuneElement( 370,NaN, FSComboBox.F_COMBOBOX_NOTEDITABLE );
			channel.x = 70;
			channel.focusorder = first;
		}
		override public function putData(p:Package):void
		{
			pdistribute(p);
			getField(p.cmd,2).setCellInfo(getStructure());
			var n:int = getPseudoChannel(p.getStructure(getStructure()));
			channel.setCellInfo(n);
			setColor(colors[p.getParam(1,getStructure())]);
			
			phoneDisable();
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
			
			for (var i:int=0; i<len; i++) {
				if( l[i].data == n ) {
					found = true;
					break;
				}
			}
			if (!found) {
				channel.setCellInfo(emptyvalue);
				callLater(changeChannel,[channel]);
			}
		}
		public function getDir():int
		{
			var l:Array = channel.getList();
			var len:int = l.length;
			var n:int = int(channel.getCellInfo());
			var found:Boolean = false;
			for (var i:int=0; i<len; i++) {
				if( l[i].data == n ) {
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
		public function set active(b:Boolean):void
		{
			if (!b) {
				if ( int(channel.getCellInfo()) != emptyvalue) {
					channel.setCellInfo( emptyvalue );
					distributePseudoChannel(emptyvalue);
					remember(grp);
				}
			}
		}
		public function get active():Boolean
		{
			var o:Object = channel.getCellInfo();
			//return int(channel.getCellInfo()) != emptyvalue; 
			var b:Boolean = int(channel.getCellInfo()) != emptyvalue;
			if (b)
				return true;
			else
				return false;
		}
		public function putDirection(n:int):void
		{
			channel.setCellInfo( n );
			distributePseudoChannel(n);
			phoneDisable();
		}
		public function putPhone(n:String):void
		{
			tel.setCellInfo( n );
		}
		public function getTel():String
		{
			return String(tel.getCellInfo());
		}
		public function rememberchange():void
		{
			remember(grp);
		}
		public function set group(n:int):void
		{
			grp.setCellInfo(n);
			remember(grp);
			setColor(colors[n]);
		}
		private function getPseudoChannel(a:Array):int
		{	// преобразовывает данные с прибора в хэшномер канала
			var s:String;
			
			if (a[2] == 1)
				s = String(a.slice(2,6));
			else
				s = String(a.slice(2,4)+",0,"+a.slice(5,6));
			
			var len:int = comLinkHash.length;
			for (var i:int=0; i<len; i++) {
				if (s == String(comLinkHash[i]))
					return i;
			}
			return 0;
		}
		private function changeTel(t:IFormString):void
		{
			this.dispatchEvent( new Event( GUIEvents.EVOKE_CHANGE_PARAM ));
			remember(t);
		}
		private function changeChannel(t:IFormString):void
		{
			if (!UILinkChannelsRT1.MASTER) {
				remember(grp);
				distributePseudoChannel(int(t.getCellInfo()));
				this.dispatchEvent( new Event( GUIEvents.EVOKE_CHANGE ));
			}
			phoneDisable();
		}
		private function phoneDisable():void
		{
			var value:int = int(channel.getCellInfo());
			switch(value) {
				case emptyvalue:
				case 11:
				case 12:
				case 13:
				case 14:
					tel.rule = null;
					break;
				default:
					tel.rule = reNeedTel;
					break;
			}
			tel.setCellInfo( tel.getCellInfo() );
		}
		private function distributePseudoChannel(n:int):void
		{
			getField(operatingCMD,3).setCellInfo( comLinkHash[n][0] );
			getField(operatingCMD,4).setCellInfo( comLinkHash[n][1] );
			getField(operatingCMD,5).setCellInfo( comLinkHash[n][2] );
			getField(operatingCMD,6).setCellInfo( comLinkHash[n][3] );
		}
		private function setColor(c:uint):void
		{
			this.graphics.clear();
			this.graphics.beginFill( c, 0.09 );
			this.graphics.drawRoundRect( -8,-5,720, 30,5,5);
			this.graphics.endFill();
		}
		
		public function onDisableOfBlockWriters( flag:Boolean ):void
		{
			flagOfBlockForWriting = flag;
			getField( operatingCMD, 1 ).disabled = flag;
			getField( operatingCMD, 2 ).disabled = flag;
			getField( operatingCMD, 3 ).disabled = flag;
			getField( operatingCMD, 4 ).disabled = flag;
			getField( operatingCMD, 5 ).disabled = flag;
		}
	}
}