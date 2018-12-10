package components.screens.ui
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	
	import components.abstract.CmdBot;
	import components.abstract.WriterIsoLCD3Bot;
	import components.abstract.offline.DataEngine;
	import components.abstract.servants.FirmwareServant_specialForV2n055;
	import components.basement.UI_BaseComponent;
	import components.events.GUIEvents;
	import components.interfaces.IServiceFrame;
	import components.protocol.Package;
	import components.protocol.RequestAssembler;
	import components.protocol.SocketProcessor;
	import components.protocol.statics.CLIENT;
	import components.screens.page.ConfigLoaderK1;
	import components.screens.page.DeviceRestarter;
	import components.screens.page.FirmWareAdvLoader;
	import components.screens.page.FirmWareAdvLoaderK5;
	import components.screens.page.FirmWareAdvLoader_specialForV2n055;
	import components.screens.page.FirmWareK1Loader;
	import components.screens.page.FirmWareSimpleLoader;
	import components.screens.page.FirmwareReader;
	import components.screens.page.HistoryRetranslator;
	import components.screens.page.K5DisabledTime;
	import components.screens.page.MasterCodeWriter;
	import components.screens.page.NmeaReader;
	import components.screens.page.OfflineDataLoader;
	import components.screens.page.PhoneRequester;
	import components.screens.page.SimpleConfigLoader;
	import components.screens.page.V15PartitionMagic;
	import components.static.DS;
	import components.static.MISC;
	import components.static.PAGE;
	
	public class UIServiceAdv extends UI_BaseComponent
	{
		protected var frames:Vector.<IServiceFrame>;
		private var cmdOperator:CMDOperator;
		private var saveStarter:Object;
		private var firmware:FirmWareSimpleLoader;
		
		public function UIServiceAdv()
		{
			super();
			starterCMD = create(getModuls());
		}
		protected function getModuls():Array
		{
			return [addFirmware,addConfig,addRestarter];
		}
		protected function create(moduls:Array):Array
		{
			
			// возвращает список команд, которые требуются для загрузки выбранных модулей
			cmdOperator = new CMDOperator;
			frames = new Vector.<IServiceFrame>;
			
			var len:int = moduls.length;
			for (var i:int=0; i<len; ++i) {
				frames.push( moduls[i]() ); 
			}
			frames[i-1].isLast();	// чтобы скрыть последний сепаратор
			var h:int = 0, w:int = 0;
			len = frames.length;
			var sequence:Array;
			for ( i=0; i<len; ++i) {
				h += frames[i].height;
				if (w < frames[i].width)
					w = frames[i].width;
				cmdOperator.register( frames[i].getLoadSequence(), frames[i].put );
			}
			height = h;
			width = w;
			return cmdOperator.sequence;
		}
		protected function addFirmwareSimple():IServiceFrame
		{
			var target:FirmWareSimpleLoader = new FirmWareSimpleLoader;
			addChild( target );
			target.x = globalX;
			return target;
		}
		protected function addFirmwareReader():IServiceFrame
		{
			var target:FirmwareReader= new FirmwareReader;
			addChild( target );
			target.x = globalX;
			return target;
		}
		
		protected function addFirmware():IServiceFrame
		{
			
			
			var target:FirmWareAdvLoader;
			
			
			//var target:FirmWareAdvLoader = new FirmWareAdvLoader;
			if( DS.isfam( DS.V2 ) && DS.release == 55 )
				target = new FirmWareAdvLoader_specialForV2n055 as FirmWareAdvLoader;
			else
				target = new FirmWareAdvLoader;
			
			register(target);
			return target;
		}
		protected function addFirmwareK5():IServiceFrame
		{
			var target:FirmWareAdvLoaderK5 = new FirmWareAdvLoaderK5;
			register(target);
			return target;
		}
		protected function addConfigSimple():IServiceFrame
		{
			var target:SimpleConfigLoader = new SimpleConfigLoader;
			register(target);
			return target;
		}
		
		
		protected function addConfig():IServiceFrame
		{
			var target:OfflineDataLoader = new OfflineDataLoader(new CmdBot, new DataEngine);
			addChild( target );
			target.addEventListener( GUIEvents.EVOKE_CHANGE_HEIGHT, onChangeHeight );
			target.addEventListener( OfflineDataLoader.LOADER_EVOKE_HIDE, onHide );
			target.addEventListener( OfflineDataLoader.LOADER_EVOKE_SHOW, onShow );
			target.addEventListener( GUIEvents.EVOKE_BLOCK, onBlock );
			target.addEventListener( GUIEvents.EVOKE_FREE, onFree );
			target.x = globalX;
			return target;
		}
		
		protected function addConfigOfLCD3():IServiceFrame
		{
			var target:OfflineDataLoader = new OfflineDataLoader(new WriterIsoLCD3Bot, new DataEngine);
			addChild( target );
			target.addEventListener( GUIEvents.EVOKE_CHANGE_HEIGHT, onChangeHeight );
			target.addEventListener( OfflineDataLoader.LOADER_EVOKE_HIDE, onHide );
			target.addEventListener( OfflineDataLoader.LOADER_EVOKE_SHOW, onShow );
			target.addEventListener( GUIEvents.EVOKE_BLOCK, onBlock );
			target.addEventListener( GUIEvents.EVOKE_FREE, onFree );
			target.x = globalX;
			return target;
		}
		
		protected function addRestarter():IServiceFrame
		{
			var target:DeviceRestarter = new DeviceRestarter;
			addChild( target );
			target.addEventListener( GUIEvents.EVOKE_BLOCK, onBlock );
			target.addEventListener( GUIEvents.EVOKE_FREE, onFree );
			target.x = globalX;
			return target;
		}
		protected function addRestarterFinal():IServiceFrame
		{
			var target:DeviceRestarter = new DeviceRestarter(true);
			addChild( target );
			target.addEventListener( GUIEvents.EVOKE_BLOCK, onBlock );
			target.addEventListener( GUIEvents.EVOKE_FREE, onFree );
			target.x = globalX;
			return target;
		}
		protected function addPhoneRequester():IServiceFrame
		{
			var target:PhoneRequester = new PhoneRequester;
			addChild( target );
			target.addEventListener( GUIEvents.EVOKE_BLOCK, onBlock );
			target.addEventListener( GUIEvents.EVOKE_FREE, onFree );
			target.x = globalX;
			return target;
		}
		protected function addNmeaReader():IServiceFrame
		{
			var target:NmeaReader = new NmeaReader;
			addChild( target );
			target.addEventListener( GUIEvents.EVOKE_BLOCK, onBlock );
			target.addEventListener( GUIEvents.EVOKE_FREE, onFree );
			target.x = globalX;
			return target;
		}
		protected function addHistoryRetranslator():IServiceFrame
		{
			var target:HistoryRetranslator = new HistoryRetranslator;
			addChild( target );
			target.addEventListener( GUIEvents.EVOKE_BLOCK, onBlock );
			target.addEventListener( GUIEvents.EVOKE_FREE, onFree );
			target.x = globalX;
			return target;
		}
		protected function runSpecialOptions(f:IServiceFrame):void
		{
			if (f is OfflineDataLoader)
				(f as OfflineDataLoader).setMenu(MISC.COPY_MENU);
		}
		protected function addV15PartitionMagic():IServiceFrame
		{
			var target:V15PartitionMagic = new V15PartitionMagic;
			register(target);
			return target;
		}
		protected function addMasterCodeWriter():IServiceFrame
		{
			var target:MasterCodeWriter = new MasterCodeWriter;
			register(target);
			return target;
		}
		protected function addConfigK1():IServiceFrame
		{
			var target:ConfigLoaderK1 = new ConfigLoaderK1;
			addChild( target );
			register(target);
			target.x = globalX;
			return target;
		}
		protected function addFirmwareK1():IServiceFrame
		{
			var target:FirmWareK1Loader = new FirmWareK1Loader;
			register(target);
			return target;
		}
		protected function addK5DisabledTime():IServiceFrame
		{
			var target:K5DisabledTime = new K5DisabledTime;
			register(target);
			return target;
		}
		
		
		protected function register(target:DisplayObject):void
		{
			
			addChild( target );
			target.addEventListener( GUIEvents.EVOKE_BLOCK, onBlock );
			target.addEventListener( GUIEvents.EVOKE_FREE, onFree );
			target.addEventListener( GUIEvents.EVOKE_CHANGE_HEIGHT, onChangeHeight );
			target.x = globalX;	
		}
		
		
		/***********************************/
		override public function open():void
		{
			cmdOperator.ready = false;
			if (MISC.VERSION_MISMATCH) {
				saveStarter = starterCMD;
				starterCMD = null;
				
				if(!firmware) {
					firmware = addFirmwareSimple() as FirmWareSimpleLoader;
					firmware.isLast();
					firmware.y = PAGE.CONTENT_TOP_SHIFT;
				}
				if( !this.contains( firmware ) )
					addChild( firmware );
				onHide(null);
				//firmware.dispatchEvent( new Event( OfflineDataLoader.LOADER_EVOKE_HIDE ));
			} else {
				if (!starterCMD && saveStarter)
					starterCMD = saveStarter;
				if( firmware && this.contains( firmware ) )
					removeChild( firmware );
			}
			
			super.open();
			
			CLIENT.AUTOPAGE_WHILE_WRITING = 0;
			
			var online:Boolean = SocketProcessor.getInstance().connected;
			
			var len:int = frames.length;
			for (var i:int=0; i<len; ++i) {
				frames[i].init();
				if ( !(frames[i] is FirmWareAdvLoader) ) {
					frames[i].block( CLIENT.IS_WRITING_FIRMWARE );
					frames[i].visible = !MISC.VERSION_MISMATCH;
				}
				runSpecialOptions( frames[i] );
			}
			
			onChangeHeight();
			
			if (!starterCMD)
				loadComplete();
		}
		override public function put(p:Package):void 
		{
			cmdOperator.distribute(p);
			if (cmdOperator.ready)
				loadComplete();
		}
		override public function close():void
		{
			super.close();
			var len:int = frames.length;
			for (var i:int=0; i<len; ++i) {
				frames[i].close();
			}
			RequestAssembler.getInstance().clearStackLater();
		}
		private function onHide(e:Event):void
		{
			var len:int = frames.length;
			for (var i:int=0; i<len; ++i) {
				if (e)
					frames[i].visible = frames[i] == e.currentTarget;
				else
					frames[i].visible = false;
			}
		}
		protected function onShow(e:Event):void
		{
			var len:int = frames.length;
			for (var i:int=0; i<len; ++i) {
				frames[i].visible = true;
			}
		}
		protected function onChangeHeight(e:Event=null):void
		{
			globalY = PAGE.CONTENT_TOP_SHIFT;
			var len:int = frames.length;
			for (var i:int=0; i<len; ++i) {
				frames[i].y = globalY;
				globalY += frames[i].height;
			}
			height = globalY;
		}
		protected function onBlock(e:Event):void
		{
			var len:int = frames.length;
			for (var i:int=0; i<len; ++i) {
				frames[i].block( e.currentTarget != frames[i] );
				if (e.currentTarget is OfflineDataLoader || e.currentTarget is FirmWareK1Loader || e.currentTarget is ConfigLoaderK1 )
					blockNaviSilent = true;
			}
		}
		protected function onFree(e:Event):void
		{
			var len:int = frames.length;
			for (var i:int=0; i<len; ++i) {
				frames[i].block( false );
				if (e.currentTarget is OfflineDataLoader || e.currentTarget is FirmWareK1Loader || e.currentTarget is ConfigLoaderK1 )
					blockNaviSilent = false;
			}
		}
		
		
	}
}
import flash.events.Event;

import components.abstract.functions.loc;
import components.basement.UI_BaseComponent;
import components.events.GUIEvents;
import components.gui.fields.FSSimple;
import components.interfaces.IServiceFrame;
import components.protocol.Package;
import components.protocol.Request;
import components.protocol.RequestAssembler;
import components.static.CMD;

class CMDOperator
{
	public var ready:Boolean;
	public var sequence:Array;
	
	private var queries:Vector.<CMDQuery>;
	
	public function register(cmds:Array, callback:Function):void
	{
		if (cmds) {
			if (!sequence)
				sequence = new Array;
			sequence = sequence.concat(cmds);
			
			var len:int = sequence.length;
			for (var i:int=0; i<len; ++i) {
				removeClones(sequence[i]);
			}
			
			if (!queries)
				queries = new Vector.<CMDQuery>;
			// комманды, котрые запрашивает модуль. Функция ответа, статус все ли получил закачик 
			queries.push( new CMDQuery(cmds, callback) );
		}
	}
	public function open():void
	{
		if (queries && queries.length > 0)
			ready = false;
	}
	public function distribute(p:Package):void
	{
		var len:int = queries.length;
		for (var i:int=0; i<len; ++i) {
			queries[i].put(p);
		}
		ready = true;
		for (i=0; i<len; ++i) {
			if (!queries[i].ready) {
				ready = false;
				break;
			}
		}
	}
	private function removeClones(cmd:int):void
	{
		var one:Boolean = false;
		var len:int = sequence.length;
		for (var i:int=0; i<len; ++i) {
			if( sequence[i] == cmd) {
				if (one)
					sequence.splice(i,1);
				else
					one = true;
			}
		}
	}
}
class CMDQuery 
{
	public var ready:Boolean = false;
	
	private var queries:Vector.<Object>;
	private var callback:Function;
	
	public function CMDQuery(cmds:Array, f:Function )
	{
		callback = f;
		queries = new Vector.<Object>;
		var len:int = cmds.length;
		for (var i:int=0; i<len; ++i) {
			queries.push( {cmd:cmds[i], ready:false} );
		}
	}
	public function put(p:Package):void
	{	// передаем номер команды, который пришел
		var len:int = queries.length;
		for (var i:int=0; i<len; ++i) {
			if( queries[i].cmd == p.cmd ) {
				queries[i].ready = true;
				callback(p);
				if (len == 1)	// если только онда команда - значит вся посылка готова
					ready = true;
				break;
			}
		}
		if (len > 1) {	// если больше одной - надо проверитьв се ли ячейки получили посылки
			ready = true;
			for ( i=0; i<len; ++i) {
				if( !queries[i] ) {
					ready = false;
					break;
				}
			}
		}
	}
}

