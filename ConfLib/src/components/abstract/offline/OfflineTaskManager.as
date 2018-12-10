package components.abstract.offline
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.ProgressEvent;
	import flash.utils.ByteArray;
	
	import components.abstract.WriterIsoLCD3Bot;
	import components.abstract.functions.dtrace;
	import components.abstract.functions.loc;
	import components.abstract.servants.K14ConfigLoaderBot;
	import components.abstract.servants.K16ConfigLoaderBot;
	import components.abstract.servants.K2ConfigLoaderBot;
	import components.abstract.servants.KLANConfigLoaderBot;
	import components.abstract.servants.VConfigLoaderBot;
	import components.abstract.sysservants.Smoothloader;
	import components.gui.Balloon;
	import components.interfaces.ICommandOperator;
	import components.interfaces.IConfigLoaderBot;
	import components.interfaces.IDataEngine;
	import components.interfaces.IFormString;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.protocol.SocketProcessor;
	import components.protocol.models.CommandSchemaModel;
	import components.protocol.models.ParameterSchemaModel;
	import components.protocol.statics.OPERATOR;
	import components.static.DS;
	import components.static.MISC;
	import components.system.UTIL;

	public class OfflineTaskManager extends EventDispatcher
	{
		public var ABORTED:Boolean;	// сообщает о том что загорузка была прервана, чтобы пришедшее событие не активировало полосу загрузки
		
		private var engine:IDataEngine;
		public static var sl:Smoothloader;
		public function OfflineTaskManager( o:ICommandOperator, e:IDataEngine )
		{
			cmdBot = o;
			engine = e;
			
			
			// выбор загрузчика и обработчика команд
			switch(DS.deviceAlias) {
			/*	case DEVICES.K5:
					configLoader = new K5ConfigLoaderBot(totalIncrease);
					break;*/
				case DS.KLAN:
				case DS.A_ETH:
					configLoader = new KLANConfigLoaderBot(totalIncrease);
					break
				case DS.K14K:
				case DS.K14W:
				case DS.K14AW:
				case DS.K14A:
				case DS.K14L:
				case DS.K14KW:
				case DS.K14:
					configLoader = new K14ConfigLoaderBot(totalIncrease);
					break;
				case DS.K16:
				case DS.K16_3G:
					configLoader = new K16ConfigLoaderBot(totalIncrease);
					break;
				case DS.K2:
					configLoader = new K2ConfigLoaderBot(totalIncrease);
					break;
				/// все вояджеры кроме 15
				case DS.isfam( DS.F_V ):
				case DS.V15:
				case DS.V15IP:
					configLoader  = new VConfigLoaderBot;
					break;
				default:
					configLoader = new DefaultConfigBot;
					break;
			}
			OfflineProcessor.init();
			sl = new Smoothloader(onProgress);
		}
		public function getExtension():String
		{
			return engine.getExtension();
		}
		public function needRestart():Boolean
		{
			return configLoader.needRestart();
		}
/*** SAVE CHANGES	******************/
		public function getSaveList():Array
		{
			var a:Array = new Array;
			var len:int = MISC.COPY_MENU.length;
			for (var i:int=0; i<len; ++i) {
				a.push( UTIL.cloneObject( MISC.COPY_MENU[i] ) );
			}
			
			if (SocketProcessor.getInstance().connected)
				return OfflineProcessor.getSaveListOnline(a);
			return OfflineProcessor.getSaveList(a);
		}
/*** SAVE OFFLINE	******************/
		public function saveListToFile(list:Array):String
		{
			var len:int = list.length;
			for (var i:int=0; i<len; ++i) {
				list[i] = int(list[i]);
			}
			
			
			return engine.save(list);
		}
/*** SAVE ONLINE	******************/
		private var storage:Object;
		private var saveList:Array;
		public function newSession():void
		{
			OfflineProcessor.clearOnlineDataModel();
			sl.abort();
			Assembler.abort();
		}
		public function abort():void
		{
			RequestAssembler.getInstance().clearStackLater();
			Assembler.abort();
			ABORTED = true;
			sl.abort();
		}
		// необходим для прерывания все механизмов запущенных в ConfigLoader'e при загрузке
		public function interrupt():void
		{
			configLoader.interrupt();
			RequestAssembler.getInstance().clearStackLater();
			if( cmdBot as WriterIsoLCD3Bot ) ( cmdBot as WriterIsoLCD3Bot ).interrupt();
		}
		public function doListIntegration(list:Array, selected:Array, f:IFormString):void
		{
			configLoader.doListIntegration( list, selected, f );
		}
		public function saveOnlineListToFile(list:Array):void
		{
			sl.start();
			ABORTED = false;
			if (!storage)
				storage = {};
			var len:int = list.length;
			
			var a:CMDArray;
			configLoader.doBeforeRead(list);
			
			for (var i:int=0; i<len; ++i) {
				trace( "page "+list[i] + " isPageExist " + OfflineProcessor.isPageExist( int(list[i]) )  + " isLoading "+Assembler.isLoading(int(list[i])) );
				if( !OfflineProcessor.isPageExist( int(list[i]) ) && !Assembler.isLoading(int(list[i])) ) {
					a = OfflineProcessor.getCMDsetByPage( int(list[i]) );
					storage[int(list)] = new Assembler( int(list[i]), a, onReady, configLoader );
				}
			}
			saveList = list;
			integrality();
		}
		private function onReady(navi:int):void
		{
			delete storage[navi];
			integrality();
		}
		private function onProgress():void
		{
			this.dispatchEvent( new Event( ProgressEvent.PROGRESS));
		}
		private function integrality():void
		{
			var len:int = saveList.length;
			for (var i:int=0; i<len; ++i) {
				if( !OfflineProcessor.isPageExist( int(saveList[i]) ) ) {
					this.dispatchEvent( new Event( ProgressEvent.PROGRESS));
					return;
				}
			}
			sl.close();
			Assembler.abort();
			this.dispatchEvent( new Event( Event.COMPLETE ));
		}
/*** LOAD OFFLINE	******************/
		public function mergeSelected(list:Array):void
		{
			OfflineProcessor.mergeSelectedPages(list);
		}
		public function getLoadList(b:ByteArray):Array
		{
			try {
				var xml:XML = new XML(b.readUTFBytes(b.length));				
			} catch(error:Error) {
				dtrace(error.message);
				return [];
			}
			
			
			switch(DS.alias) {
				case DS.VL1:
				case DS.VL2:
				case DS.V2T:
				case DS.V2:
				case DS.V3:
				case DS.V3L:
				case DS.V4:
				case DS.V5:
				case DS.V6:
					var release:int = int((xml.@release as XMLList).toString());
					
					if (release == 0 || release > DS.release) {
						Balloon.access().show(loc("sys_attention"), loc("sys_conf_file_too_new")); 
						return [];
					}
					break;
			}
			
			//var xml:XML = new XML(b.readUTFBytes(b.length));
			return OfflineProcessor.getLoadedPages(xml);
		}
/*** LOAD ONLINE	******************/
		private var total:int;
		private var progress:int;
		private var cmdBot:ICommandOperator;
		private var configLoader:IConfigLoaderBot;
		
		private var u:Vector.<Updater>;
		public var fUpdate:Function;
		public function needSpecialActions(a:Array, f:Function, fcancel:Function):Boolean
		{
			return configLoader.doActions(a, f, fcancel);
		}
		
		public function uploadSelected(list:Array, f:Function):void
		{
			
			OfflineProcessor.mergeSelectedPages(list);
			
			total = 0;
			progress = 0;
			fUpdate = f;
			u = new Vector.<Updater>;
			
			var len:int = list.length;
			var cmds:Array = [];
			var a:Array;
			for (var i:int=0; i<len; ++i) {
				if( !configLoader.checkImportant(int(list[i])) )			
					cmds = cmds.concat( OfflineProcessor.getCMDsetByPage( int(list[i]) ) );
			}
			cmds = configLoader.addImportant(cmds);
			
			len = cmds.length;
			for (i=0; i<len; ++i) {
				checkClone( i, cmds );
			}
			// повторное переопределение длины необходимо. После проверки клонов она могла измениться
			len = cmds.length;
			for (i=0; i<len; ++i) {
				a = OfflineProcessor.getData( cmds[i] );
				// если по какой то причине команд в загрузочном файле меньше, чем предполагается в данной версии клиента, а может быть null
				if (a) {
					var lenj:int = a.length;
					for (var j:int=0; j<lenj; ++j) {
						
						if ( isReadOnly(cmds[i]) )
							continue;
						
						total++;
						u.push( new Updater( cmds[i], j+1 ));
						
						configLoader.doRefine( cmds[i], a[j], j+1 );
						
						
						var adr:int = OfflineProcessor.getAddress(cmds[i]);
						
						//RequestAssembler.getInstance().fireEvent( new Request(cmds[i],onComplete,j+1,a[j],Request.NORMAL, Request.PARAM_SAVE, OfflineProcessor.getAddress(cmds[i]) ));
						configLoader.fire( new Request(cmds[i],onComplete,j+1,a[j],Request.NORMAL, Request.PARAM_SAVE, OfflineProcessor.getAddress(cmds[i]) ) );
					}
					
					// если бот существует посылаем ему триггер функцию, предоставляем ему выполнить какие-то действия
					if (cmdBot ) {
						if( cmdBot as WriterIsoLCD3Bot )( cmdBot as WriterIsoLCD3Bot ).fUpdate = fUpdate;
						var o:Object = cmdBot.after(cmds[i], onComplete);
						if (o is Object ) {
							total++;
							u.push( new Updater( o.cmd, o.structure) );
						}
						
					}
				}
			}
			configLoader.doImportant(onComplete);
		}
		private function totalIncrease():void
		{
			total++;
		}
		private function checkClone(n:int, a:Array):void
		{
			var len:int = a.length;
			var original:int =  a[n];
			for (var i:int=n+1; i<len; ++i) {
				if( original == a[i] )
					a.splice( i,1 );
			}
		}
		private function isReadOnly(cmd:int):Boolean
		{
			var c:CommandSchemaModel = OPERATOR.getSchema( cmd );
			var len:int = c.Parameters.length;
			for (var i:int=0; i<len; ++i) {
				if( !(c.Parameters.getItemAt(i) as ParameterSchemaModel).ReadOnly )
					return false;
			}
			return true;
		}
		private function onComplete(p:Package=null):void
		{
			fUpdate(++progress, total);
			var len:int = u.length;
			for (var i:int=0; i<len; ++i) {
				if (u[i] is Updater) {
					if (u[i].cmd == p.cmd && u[i].struc == p.structure) {
						u[i] = null;
						break;
					}
				}
			}
		}
/******** 	GET/SET				**************/		
		
		public function get VISUAL_LOAD_PROGRESS():Number
		{
			return sl.VISUAL_LOADED;
		}
		public function get LOAD_PROGRESS():int
		{
			return sl.LOADED;
		}
		public function get LOAD_TOTAL():int
		{
			return sl.TOTAL;
		}
	}
}

class Updater
{
	public var cmd:int;
	public var struc:int;
	
	public function Updater(_cmd:int, _structure:int)
	{
		cmd = _cmd;
		struc = _structure;
	}
}

import components.abstract.offline.CMDArray;
import components.abstract.offline.OfflineProcessor;
import components.abstract.offline.OfflineTaskManager;
import components.abstract.sysservants.Smoothloader;
import components.interfaces.IConfigLoaderBot;
import components.interfaces.IFormString;
import components.protocol.Package;
import components.protocol.Request;
import components.protocol.RequestAssembler;

class Assembler
{
	private var navi:int;
	
	private var cmds:CMDArray;
	private var ready:Function;
	
	private static var loading:Object;	// складываются номера навигации которые в данный момент грузятся
	
	public static function isLoading(value:int):Boolean
	{
		if ( loading && loading[value] )
			return true;
		return false;
	}
	public static function abort():void
	{
		loading = null;
	}
	
	public function Assembler(_navi:int, _cmds:CMDArray, fReady:Function, bot:IConfigLoaderBot)
	{
		var sl:Smoothloader = OfflineTaskManager.sl;
		if (!loading)
			loading = new Object;
		loading[_navi] = true;
		
		cmds = _cmds;
		ready = fReady;
		navi = _navi;
		bot.doSaveRefine(_navi);
		var len:int = cmds.length;
		var r:Request;
		
		
		for (var i:int=0; i<len; ++i) {
			r = new Request(cmds[i], onPackage, 0, null, Request.NORMAL, 0, cmds.address );
			r.smoothloader = sl;
			sl.put(cmds[i]);
			RequestAssembler.getInstance().fireEvent( r );
			
			
		}
		
		
		
		
	}
	private function onPackage(p:Package):void
	{
		OfflineProcessor.updateOnlineData(p);
		
		var len:int = cmds.length;
		for (var i:int=0; i<len; ++i) {
			if (cmds[i] == p.cmd) {
				
				cmds.splice(i,1);
				break;
			}
		}
		if (cmds.length == 0) {
			if (loading)
				loading[navi] = false;
			ready(navi);
		}
	}
}
class DefaultConfigBot implements IConfigLoaderBot
{
	public function checkImportant(n:int):Boolean
	{
		
		return false;
	}
	public function addImportant(a:Array):Array
	{
		return a;
	}
	public function doImportant(f:Function):void {};
	public function doBeforeRead(a:Array):void	{};
	public function doActions(a:Array,f:Function, fcancel:Function):Boolean
	{
		return false;
	}
	public function doRefine(cmd:int, a:Array, str:int):void	{};
	public function doSaveRefine(cmd:int):void {};
	public function doListIntegration(l:Array, selected:Array, f:IFormString):void {}
	public function needRestart():Boolean
	{	// если по каким то причинам необходимо рестартнуть клиент после загрузки информации, функция возвращает true;
		return false;
	}
	public function fire(r:Request):void
	{
		RequestAssembler.getInstance().fireEvent(r);
	}
	public function interrupt():void {	}
}

