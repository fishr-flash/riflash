package components.screens.ui
{
	import components.abstract.functions.loc;
	import components.abstract.servants.HistorySaverServant;
	import components.gui.Header;
	import components.gui.visual.HistoryVideoLoader;
	import components.protocol.statics.SERVER;
	import components.screens.opt.OptHistoryLineExt;

	public class UIHistoryExt extends UIHistory
	{
		private const cellnum:int = 20;
		private var hv:HistoryVideoLoader;
		
		public function UIHistoryExt()
		{
			super();
			
			servant = new HistorySaverServant([bXLSpageAll, bTXTpageAll],cellnum,OptHistoryLineExt.getEmulatedvisualizeBitfield,OptHistoryLineExt.calcCIDCRC);
			(servant as HistorySaverServant).historyAdapter = new K7adapter(cellnum);

			if (!SERVER.isGeoritm() ) {
				hv = HistoryVideoLoader.access();
				addChild( hv );
				hv.visible = false;
			}
		}
		override public function close():void
		{
			super.close();
			
			if(hv)
				hv.close();
		}
		override protected function getClass():Class 
		{
			return OptHistoryLineExt;
		}
		override protected function getHeader():Header
		{
			return new Header( [{label:loc("his_index"),align:"center",xpos:8},{label:loc("his_event_time"), xpos:45+48},
				{label:loc("his_object_num"), align:"center", xpos:160+24, width:100}, {label:loc("his_alarm_code"), align:"center", xpos:230+49-9}, {label:loc("his_event"), xpos:350-4},
				{label:loc("his_partition"), xpos:420+173+13+1},{label:loc("his_zone_user"), align:"center", xpos:480+183},{label:loc("his_sent"), xpos:535+205},
				{label:loc("his_cid"), xpos:650+212+2} ], {size:11} );
		}
		override protected function getHistoryExportHeader():Array
		{
			return [loc("his_exp_index"),loc("his_exp_date"),loc("his_exp_object"),loc("his_exp_alarm_code"),
				loc("his_exp_event"), loc("his_exp_part"), loc("his_exp_zone_user"), loc("his_sent"),loc("his_exp_cid")];
		}
	}
}
import components.abstract.functions.loc;
import components.abstract.servants.CIDServant;
import components.abstract.servants.UTCDateAdapter;
import components.interfaces.IAbstractAdapter;
import components.screens.opt.OptHistoryLineExt;
import components.system.UTIL;

class K7adapter implements IAbstractAdapter
{
	private var cellnum:int;
	public function K7adapter(value:int)
	{
		cellnum = value;
	}
	public function adapt(value:Object):Object
	{
		var a:Array = value as Array;
		var adapted:Array = [];
		adapted.push( a[cellnum] );
		
		
	/*	var devicedate:Date = new Date;
		devicedate.setUTCFullYear( p.getStructure()[2], p.getStructure()[1]-1, p.getStructure()[0] );
		devicedate.setUTCHours( p.getStructure()[3], p.getStructure()[4], p.getStructure()[5] );*/
		var d:UTCDateAdapter = new UTCDateAdapter( a[3].toString(16),a[2].toString(16),a[1].toString(16),a[4].toString(16),a[5].toString(16),a[6].toString(16));
		var s:String = d.getFullHistoryDate();
		
	/*	adapted.push( UTIL.formateZerosInFront(a[1].toString(16),2)+"."+ UTIL.formateZerosInFront(a[2].toString(16),2)+ ".20" +UTIL.formateZerosInFront(a[3].toString(16),2)
			+ " " + UTIL.formateZerosInFront(a[4].toString(16),2) + ":"+UTIL.formateZerosInFront(a[5].toString(16),2) + ":"+UTIL.formateZerosInFront(a[6].toString(16),2));*/
		adapted.push( s );
		
		adapted.push( UTIL.formateZerosInFront(a[7].toString(16),4));
		
		var num:int = int( a[9] );
		var result:int = (num & 0x0FFF) << 4 | (num & 0xF000) >> 12;
		
		var label:String="";
		var param:String="";
		var cidEvent:Array = CIDServant.getEvent();
		for( param in cidEvent) {
			if( int( "0x"+cidEvent[param].data ) == result )
				label = cidEvent[param].label;
		}
		/**	Параметр 9 - 0x18h;*/
		/**	Параметр 10 - старшая тетрада -тревога/восстановление, остальное -Код тревоги (BCD);*/
		
		// Номер CID 1301
		adapted.push( label.slice(0,6) );
		// Номер расшифровка CID
		//getField(operatingCMD,5).setCellInfo( UTIL.formateLength(label.slice(6),23));
		adapted.push( label.slice(6) );
		
		/**	Параметр 11 - Номер раздела 1-99 (BCD);*/
		// Раздел
		adapted.push( a[10] );
		
		var zonecrc:String = (a[UTIL.hash_1To0(12)]).toString(16);
		var devicecrc:String = zonecrc.slice(zonecrc.length-1);
		var zone:String = zonecrc.slice(0, zonecrc.length-1 );
		
		/**	Параметр 12 - Номер зоны 1-0x999 (BCD), младшая тетрада Контрольная сумма CID;*/
		// Зона пользователя
		adapted.push( int(zone) );
		
		/**	Параметр 13 - Погашение - 8 каналов связи (8 бит). Бит, установленный в 0 обозначает канал, куда удалось отправить;*/
		/**	Параметр 14 - Глобальный флаг 0x33 - сообщение передано, 0xFF - сообщение не передано;*/
		// Битовое поле каналов связи
		//adapted.push( OptHistoryLineExt.getEmulatedvisualizeBitfield(a[12],a[13]) );
		adapted.push( a[13] == 0x33 ? loc("g_yes"):loc("g_no") );
		/**	Параметр 15 - Номер прибора в сети; //служебная информация*/
		/**	Параметр 16 - Тип датчика / шлейфа / выхода; //служебная информация*/
		/**	Параметр 17 - Номер шлейфа / номер радиодатчика / номер выхода; //служебная информация*/
		/**	Параметры 18,19,20 - резерв */
		
		var crc:String = OptHistoryLineExt.calcCIDCRC( [ UTIL.formateZerosInFront((a[UTIL.hash_1To0(8)]).toString(16),4), 
			(a[UTIL.hash_1To0(9)]).toString(16),
			(a[UTIL.hash_1To0(10)]).toString(16),
			UTIL.formateZerosInFront((a[UTIL.hash_1To0(11)]).toString(16),2), 
			UTIL.formateZerosInFront(zone,3)] );
		
		var color:String;
		if( devicecrc.toLowerCase() != crc.toLowerCase() )
			// Ошибка кода CID
			color = "ED1C24";
		else
			color = "000000";
		
		// CID
		var cid_line:String = UTIL.formateZerosInFront((a[UTIL.hash_1To0(8)]).toString(16),4) +
			(a[UTIL.hash_1To0(9)]).toString(16)+ 
			(a[UTIL.hash_1To0(10)]).toString(16) + 
			UTIL.formateZerosInFront((a[UTIL.hash_1To0(11)]).toString(16),2) + 
			UTIL.formateZerosInFront(zone,3) + 
			devicecrc;
		var CIDlineLength:int = cid_line.length;
		var v:Vector.<String> = new Vector.<String>(CIDlineLength);
		for(var i:int=0;i<CIDlineLength;++i) {
			v[i] = color;
		}
		adapted.push( [cid_line,v] );
		return adapted;
	}
}