package components.abstract.servants
{
	import flash.events.Event;
	import flash.system.Security;
	import flash.utils.ByteArray;
	
	import mx.utils.URLUtil;
	
	import components.abstract.functions.dtrace;
	import components.events.GUIEventDispatcher;
	import components.events.GUIEvents;
	import components.protocol.ProtocolHttp;
	import components.protocol.statics.SERVER;
	import components.static.DS;
	import components.static.NAVI;

	public class AutoUpdateNinja
	{
		private static var inst:AutoUpdateNinja;
		public static function access():AutoUpdateNinja
		{
			if(!inst)
				inst = new AutoUpdateNinja;
			return inst;
		}

		protected var fb:FirmwareBot;
		protected var fwDelegate:Function;
		protected var adr:String;
		protected var port:int;
		protected var connecterror:Boolean = false;
		private var device:Object;
		private var deviceDelegate:Function;
		private var grabNinja:GrabNinja;
		
		public function getList():void
		{
			fb = null;
			fwDelegate = null;
			
			GUIEventDispatcher.getInstance().dispatchEvent( new GUIEvents( GUIEvents.MAINMENU_APPEARANCE, 
				{getButtonId:getButtonId(), getButtonStatus:0} ));
			
			adr = URLUtil.getServerName(SERVER.UPDATE_SERVER_ADR);
			port = URLUtil.getPort(SERVER.UPDATE_SERVER_ADR);
			if (port == 0)
				port = 80;
			
			connecterror = false;
			
			Security.loadPolicyFile( SERVER.UPDATE_SERVER_ADR+"/crossdomain.xml");
			
			init();
			grabNinja.go(SERVER.UPDATE_SERVER_ADR+"/device.json", onGetJson);
		}
		public function askTableList(f:Function):void
		{
			if (connecterror)
				f(null);
			else if (fb) {
				f(fb.getTableList());
			} else
				fwDelegate = f;
		}
		public function getRtm(path:String, f:Function):void
		{
			grabNinja.go( SERVER.UPDATE_SERVER_ADR + path, onGetRtm );
			fwDelegate = f;
		}
		public function askDevice(f:Function):void
		{
			if (device)
				f(device);
			else
				deviceDelegate = f;
		}
		protected function init():void
		{
			grabNinja = new GrabNinja;
			device = null;
		}
		
		
		
		protected function onGetJson(b:ByteArray):void
		{
			if (isError(b)) {
				connecterror = true;
				if (fwDelegate is Function)
					fwDelegate(null);
				fwDelegate = null;
			}
			var s:String = "";
			if (b)
				s = b.readUTFBytes(b.bytesAvailable);
			
			var d:Object;
			try {
				d = JSON.parse(s);
			} catch(error:Error) {
				if( connecterror )
					dtrace( "AutoUpdateNinja got connect error and has nothing to parse" );
				else
					dtrace( "AutoUpdateNinja got bad JSON and avoided to parse it!" );
			}
			
			if (d) {
				device = d;
				if (deviceDelegate is Function)
					deviceDelegate(device);

				/*var k:String;
				if (int(DEVICES.getBootloader())>0)
					k = DEVICES.getFullVersion()+"."+DEVICES.getBootloader();
				else
					k = DEVICES.getFullVersion();*/
				
				var k:String = DS.getFullVersion()+"."+DS.getBootloader();
				
				createBot( k, DS.app, DS.deviceAlias );
				
				
				var isupdate:Boolean = fb.isUpdate(d);
				
				if (isupdate) {
					GUIEventDispatcher.getInstance().dispatchEvent( new GUIEvents( GUIEvents.MAINMENU_APPEARANCE, 
						{getButtonId:getButtonId(), getButtonStatus:1} ));
				} 
				if (fwDelegate is Function)
					fwDelegate(fb.getTableList());
				fwDelegate = null;
			}
			
			
			
			
		}
		
		private function onGetRtm(b:ByteArray):void
		{
			if (fwDelegate is Function) {
				if (isError(b)) {
					fwDelegate(null);
					connecterror = true;
				} else
					fwDelegate(b);
			}
			fwDelegate = null;
		}
		protected function onHTTPError(e:Event):void
		{
			dtrace("error " + e.type );
		}
		private function onComplete(e:Event):void
		{
		}
		private function isError(b:ByteArray):Boolean
		{
			if (!b)
				return true;
			if ( ( b && b.length == 2 ) && (
				(b[0] << 8 | b[1]) == ProtocolHttp.ERROR_SOCKET_KAPUT ||
				(b[0] << 8 | b[1]) == ProtocolHttp.ERROR_NOT_EXIST ||
				(b[0] << 8 | b[1]) == ProtocolHttp.ERROR_TIMEOUT ) ) {
				GUIEventDispatcher.getInstance().dispatchEvent( new GUIEvents( GUIEvents.MAINMENU_APPEARANCE, 
					{getButtonId:getButtonId(), getButtonStatus:0} ));
				return true;
			}
			return false;
		}
		protected function getButtonId():int
		{
			return NAVI.UPDATE;
		}
		protected function createBot(k:String,ap:String,al:String):void
		{
			fb = new FirmwareBot(k,ap,al);
		}
	}
}
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.net.URLLoader;
import flash.net.URLLoaderDataFormat;
import flash.net.URLRequest;
import flash.utils.ByteArray;

import components.abstract.LOC;
import components.abstract.functions.dtrace;

class FirmwareBot 
{
	private var device:Object;
	private var patch:Array;
	
	private var keyword:String
	private var app:String;
	private var alias:String;
	
	public function FirmwareBot(k:String,ap:String,al:String)
	{
		keyword = k;
		app = ap;
		alias = al;
	}
	
	/**
	 * Здесь изучается device.json и если текущая версия прибора оказывается
	 * в списке VersionOld блока то делается вывод о наличии обнавлений и формируется 
	 * список обновлений.
	 * 
	 */
	public function isUpdate(a:Object):Boolean
	{
		
		var b:Boolean;
		for( var key:String in a) {
			b = isUpdateInside(a[key]);
			if (b)
				return true;
		}
		return b;
	}
	private function isUpdateInside(device:Object):Boolean
	{
		
		if (!device || !device.Firmware)
			return false;
		var len:int = device.Firmware.length;
		patch = [];
		
		for (var i:int=0; i<len; i++) {
			
			
			if( isPartOf( device.Firmware[i].VersionOld, keyword )
			|| isPartOf( device.Firmware[i]["VersionOld#1"], keyword ) ){
				
				if (LOC.language == LOC.RU)
					patch.push( {desc:device.Firmware[i].Description, rtm:device.Firmware[i].Rtm, ver:device.Firmware[i].Version } );
				else
					patch.push( {desc:device.Firmware[i].DescriptionDefault, rtm:device.Firmware[i].Rtm, ver:device.Firmware[i].Version } );
			}
		}
		return patch.length > 0
	}
	private function isPartOf(a:Array, s:String):Boolean
	{
		
		if (a) {
			var len:int = a.length;
			for (var i:int=0; i<len; i++) {
				if( a[i] == s )
					return true;
			}
		}
		return false;
	}
	public function getTableList():Array
	{
		var a:Array = [];
		if (patch) { 
			var len:int = patch.length;
			for (var i:int=0; i<len; i++) {
				a.push( [getVer(patch[i].ver[0]), String(patch[i].desc), getVersionByApp(patch[i].ver), patch[i].rtm] );
			}
		}
		return a;
	}
	private function getVer(v:String):String
	{
		var a:Array = v.split(".");
		if (a && a[2])
			return a[2];
		return "";
	}
	private function getVersionByApp(a:Array):String
	{
		
		
		var len:int = a.length;
		var v:Array;
		for (var i:int=0; i<len; i++) {
			v = String(a[i]).split(".");
			if (v && v[1] && app == v[1] )
				return a[i];
		}
		
		
		
		
		 //// Изменено в результате устного обсуждения с КБ
		return a.length?a[ 0 ]:"";
		//return "$error.getting.app";
	}
	
	
	
	/*
	public function isUpdate(a:Object):Boolean
	{
		device = getDevice(a as Array);
		if (!device || !device.Firmware)
			return false;
		
		var len:int = device.Firmware.length;
		patch = [];
		
		for (var i:int=0; i<len; i++) {
			if( isPartOf( device.Firmware[i].VersionOld, keyword ) )
				if (LOC.language == LOC.RU)
					patch.push( {desc:device.Firmware[i].Description, rtm:device.Firmware[i].Rtm, ver:device.Firmware[i].Version } );
				else
					patch.push( {desc:device.Firmware[i].DescriptionDefault, rtm:device.Firmware[i].Rtm, ver:device.Firmware[i].Version } );
		}
		return patch.length > 0;
	}
	public function getTableList():Array
	{
		var a:Array = [];
		if (patch) { 
			var len:int = patch.length;
			for (var i:int=0; i<len; i++) {
				a.push( [getVer(patch[i].ver[0]), String(patch[i].desc), getVersionByApp(patch[i].ver), patch[i].rtm] );
			}
		}
		return a;
	}
	private function getVer(v:String):String
	{
		var a:Array = v.split(".");
		if (a && a[2])
			return a[2];
		return "";
	}
	private function getVersionByApp(a:Array):String
	{
		var len:int = a.length;
		var v:Array;
		for (var i:int=0; i<len; i++) {
			v = String(a[i]).split(".");
			if (v && v[1] && app == v[1] )
				return a[i];
		}
		return "$error.getting.app";
	}
	public function getDevice(a:Array):Object
	{
		var len:int = a.length;
		for (var i:int=0; i<len; i++) {
			if( a[i].ShortName == alias )
				return a[i];
		}
		return null;
	}
	private function getfw():Array
	{
		return null;
	}
	private function isPartOf(a:Array, s:String):Boolean
	{
		if (a) {
			var len:int = a.length;
			for (var i:int=0; i<len; i++) {
				if( a[i] == s )
					return true;
			}
		}
		return false;
	}*/
}
class GrabNinja
{
	private var callback:Function;
	
	public function go(url:String, f:Function):void
	{
		callback = f;
		
		var request:URLRequest = new URLRequest( url );
		var loader:URLLoader = new URLLoader();
		loader.dataFormat = URLLoaderDataFormat.BINARY;
		loader.addEventListener(IOErrorEvent.IO_ERROR, onFail);
		loader.addEventListener(Event.COMPLETE, onComplete);
		loader.load(request);
	}
	private function onFail(e:Event=null):void
	{
		if (e && e.type != null)
			dtrace("error " + e.type );
		callback(null);
	}
	private function onComplete(e:Event):void
	{
		var loader:URLLoader = e.target as URLLoader;
		loader.removeEventListener(IOErrorEvent.IO_ERROR, onFail);
		loader.removeEventListener(Event.COMPLETE, onComplete);
		callback(loader.data as ByteArray);
		
		loader = null;
	}
}