package components.screens.page
{
	import flash.events.Event;
	
	import mx.core.UIComponent;
	
	import components.events.GUIEvents;
	import components.gui.visual.Separator;
	import components.interfaces.IServiceFrame;
	import components.protocol.Package;
	import components.screens.ui.UIServiceLocal;
	import components.static.CMD;
	
	public class V15PartitionMagic extends UIComponent implements IServiceFrame
	{
		private var sep:Separator;
		private var flist:MFlexListGummyLineHeight;
		private var localheight:int=0;
		
		public function V15PartitionMagic()
		{
			super();
			
			flist = new MFlexListGummyLineHeight(OptDisc);
			addChild( flist );
			flist.width = 600;
			
			sep = new Separator(UIServiceLocal.SEPARATOR_WIDTH);
			addChild( sep );
			sep.x = -20;
		}
		
	/*	public function localResize(w:int, h:int, real:Boolean=false):void
		{
			if (h < 430)
				flist.height = 430-170;
			else
				flist.height = h-170;
			
			if (flist.height > flist.realheight )
				flist.height = flist.realheight;
			
			sep.y = flist.height + 20;
			
			this.dispatchEvent( new Event(GUIEvents.EVOKE_CHANGE_HEIGHT));
		}*/
		public function block(b:Boolean):void
		{
		}
		public function close():void
		{
		}
		public function getLoadSequence():Array
		{
			return [CMD.V15_LIST_DISK];
		}
		override public function get height():Number
		{
			return localheight;
		}
		public function init():void
		{
		}
		public function isLast():void
		{
			sep.visible = false;
		}
		public function put(p:Package):void
		{
			flist.put(p);
			localheight = flist.realheight + 40;
			flist.height = localheight;
			sep.y = localheight-25;
			this.dispatchEvent( new Event(GUIEvents.EVOKE_CHANGE_HEIGHT));
		}
	}
}
import flash.display.DisplayObject;
import flash.events.EventDispatcher;
import flash.events.MouseEvent;

import mx.core.UIComponent;

import components.abstract.functions.loc;
import components.abstract.servants.TaskManager;
import components.basement.UI_BaseComponent;
import components.gui.MFlexList;
import components.gui.PopUp;
import components.gui.SimpleTextField;
import components.gui.fields.FSSimple;
import components.gui.triggers.TextButton;
import components.interfaces.IFlexListItem;
import components.interfaces.IFormString;
import components.protocol.Package;
import components.protocol.Request;
import components.protocol.RequestAssembler;
import components.protocol.SocketProcessor;
import components.static.CMD;
import components.static.COLOR;

class OptDisc extends UI_BaseComponent implements IFlexListItem
{
	private var tf:SimpleTextField;
	private var realheight:int;
	
	private var _disabled:Boolean;
	
	public function get disabled():Boolean
	{
		return _disabled;
	}
	
	public function set disabled(value:Boolean):void
	{
		_disabled = value;
	}
	
	private const names:Array = ["1. "+loc("service_part_geodata"),
		"2. "+loc("service_part_video"),
		"3. "+loc("service_part_service"),
		"4. "+loc("service_part_service")];
	
	public function OptDisc(s:int)
	{
		structureID = s;
		
		tf = new SimpleTextField("");
		addChild( tf );
		tf.setSimpleFormat();
		tf.height = 30;
		tf.width = 200;
		
		//FLAG_SAVABLE = false;
		//addui( new FSSimple, 0, ""
	}
	public function change(p:Package):void
	{
	}
	public function extract():Array
	{
		return null;
	}
	override public function getStructure():int
	{
		return 0;
	}
	override public function get height():Number
	{
		return realheight;
	}
	public function isSelected():Boolean
	{
		return false;
	}
	public function kill():void
	{
	}
	override public function put(p:Package):void
	{
		/** "Команда V15_LIST_DISK - список доступных дисков на приборах V-15 и K-15

		Номер структуры - идентификатор диска, передача во всех структурах 0 - нет дисков вообще.
		Параметр 1 - идентификатор диска:
		.........0 - нет дисков;
		.........1 - Жесткий диск;
		.........2 - Карта microSD
		.........3 - USB-накопитель
		
		Параметр 2 - статус: 0-не подключен, 1-Подключен и используется, 2-Подключен и не используется, 3-Необходимо форматирование
		Параметр 3 - Количество разделов на диске
		Параметр 4 - Раздел 1 (размер в мегабайтах)
		Параметр 5 - Раздел 2 (размер в мегабайтах)
		Параметр 6 - Раздел 3 (размер в мегабайтах) 
		Параметр 7 - Раздел 4 (размер в мегабайтах) 
		Параметр 8 - Общий объем диска (размер в мегабайтах)	**/
		
		var msg:String;
		var deviceid:int = p.getStructure(structureID)[0];
		switch(deviceid) {
			case 0:
				realheight = 0;
				return;
			case 1:
				msg = loc("service_hdd");
				break;
			case 2:
				msg = loc("service_microsd");
				break;
			case 3:
				msg = loc("service_usbdrive");
				break;
		}
		
		FLAG_SAVABLE = false;
		
		globalY += 30;
		
		var size:Array = [];
		var len:int = p.getStructure(structureID)[2];
		for (var i:int=0; i<len; i++) {
			addf(names[i]).setCellInfo( ft(p.getStructure(structureID)[3+i]) );
			size.push( p.getStructure(structureID)[3+i] );
		}
		
		var dstatus:int = p.getStructure(structureID)[1];
		if( dstatus>0 )
			addf(loc("service_total_space")).setCellInfo( ft(p.getStructure(structureID)[7]) );
		addf(loc("g_status")).setCellInfo( getStatus() );
		
		tf.text = msg;
		realheight = globalY;
		
		var pt:Partition = new Partition(len, size, p.getStructure(structureID)[7] );
		addChild( pt );
		pt.x = 120;
		
		var tb:TextButton = new TextButton;
		addChild( tb );
		tb.setUp(loc("service_do_format"), onFormat, deviceid );
		tb.x = 120+160+20+160;
		tb.disabled = dstatus == 0;
		
		function getStatus():String
		{
			switch(dstatus) {
				case 1:
					return loc("service_plugged_and_using");
				case 2:
					return loc("service_plugged_not_using");
				case 3:
					return loc("service_need_format");
			}
			return loc("service_not_plugged");
		}
	}
	private function ft(num:uint):String
	{
		var str:String="";
		while(num>0){
			var tmp:uint=num%1000;
			str=(num>999?" "+(tmp<100?(tmp<10?"00":"0"):""):"")+tmp+str;
			num=num/1000;
		}
		return str + " "+loc("g_mbytes");
	}	
	
	private var currentdevice:int;
	private function onFormat(deviceid:int):void
	{
		currentdevice = deviceid;
		var p:PopUp = PopUp.getInstance();
		p.construct(PopUp.wrapHeader("sys_attention"), 
			PopUp.wrapMessage("service_dont_turnoff_device_while_formating"), 
			PopUp.BUTTON_OK | PopUp.BUTTON_CANCEL, [doFormat] );
		p.open();
	}
	private function doFormat():void
	{
		loadStart();
		blockNaviSilent = true;
		RequestAssembler.getInstance().fireEvent( new Request(CMD.V15_FORMAT_DISK, onFormatSuccess, 1, [currentdevice]));
	}
	private function onFormatSuccess(p:Package):void
	{
		TaskManager.callLater( doRestart, TaskManager.DELAY_1SEC*5 );
	}
	private function doRestart():void
	{
		SocketProcessor.getInstance().reConnect();
	}
	private function addf(ttl:String):IFormString
	{
		addui( new FSSimple, 0, ttl, null, 1 );
		attuneElement( 250, 300, FSSimple.F_CELL_ALIGN_LEFT | FSSimple.F_CELL_NOTSELECTABLE );
		(getLastElement() as FSSimple).setTextColor( COLOR.GREEN );
		return getLastElement();
	}
	public function putRaw(value:Object):void
	{
	}
	public function set selectLine(b:Boolean):void
	{
	}
}
class Partition extends UIComponent
{
	private const colors:Array = [COLOR.YELLOW_SIGNAL,0x27deff, COLOR.GREEN_LIGHT,COLOR.GREEN_LIGHT];
	
	public function Partition(n:int, size:Array, total:int)
	{
		super();
		
		this.graphics.beginFill( COLOR.NAVI_MENU_LIGHT_BLUE_BG );
		this.graphics.drawRect(0,0,320,20);
		this.graphics.endFill();
		this.graphics.lineStyle(1);
		this.graphics.drawRect(0,0,320,20);
		
		var t:SimpleTextField;
		
		var len:int = size.length;
		var formated:int = 0;
		for (var i:int=0; i<len; i++) {
			formated += size[i];
		}
		
		var isemptyspace:Boolean = total - formated > 10;
		if (isemptyspace)
			size.push(total - formated);
		
		var pcount:int = isemptyspace ? n + 1 : n;
		
		var w:int = Math.ceil(320/pcount);
		
		for (i=0; i<pcount; i++) {
			t = new SimpleTextField((i+1) + ": "+ft(size[i]),w);
			addChild( t );
			t.setSimpleFormat("center");
			t.height = 20;
			t.x = i*w;
			t.border = true;
			t.background = true;
			if (isemptyspace && i == pcount-1) {
				if (total == 0)
					t.text = "";
				else
					t.text = ft(total - formated);
				t.backgroundColor = COLOR.NAVI_MENU_LIGHT_BLUE_BG;
			} else
				t.backgroundColor = colors[i];
		}
	}
	private function ft(size:int):String
	{
		if( size < 9999 )
			return size + " "+loc("g_mbytes");
		else if ( size < 999999 )
			return (size/1000).toFixed(1) + " "+loc("g_gbytes");
		else if ( size < 999999999 )
			return (size/1000000).toFixed(1) + " "+loc("g_tbytes");
		return "1+ "+loc("g_pbytes");
	}
}
class MFlexListGummyLineHeight extends MFlexList
{
	private var rh:int;
	public function MFlexListGummyLineHeight(c:Class)
	{
		super(c);
	}
	override public function put(p:Package, clear:Boolean=true, evokeSave:Boolean=false):void
	{
		var len:int = p.length;
		var i:int;
		if (clear) {
			clearlist();
			rh = 0;
			list = new Vector.<IFlexListItem>(len);
			for (i=0; i<len; i++) {
				list[i] = (new cls(i+1) as IFlexListItem);
				(list[i] as EventDispatcher).addEventListener( MouseEvent.CLICK, onSelect );
				layer.addChild( list[i] as DisplayObject );
				list[i].y = rh;
				
				if (evokeSave)
					list[i].change(p);
				else
					list[i].put(p);
				
				rh += list[i].height;
			}
		} else {
			len = list.length; // может быть 1 структура но положена во все строки листа
			for (i=0; i<len; i++) {
				if (evokeSave)
					list[i].change(p);
				else
					list[i].put(p);
			}
		}
	}
	public function get realheight():int
	{
		return rh;
	}
}