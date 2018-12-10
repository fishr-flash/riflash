package components.gui.visual
{
	import flash.geom.Point;
	
	import mx.core.UIComponent;
	
	import components.gui.triggers.VisualButton;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.protocol.statics.OPERATOR;
	import components.static.CMD;
	import components.static.GuiLib;
	
	// LibMp4V2
	
	public class HistoryVideoLoader extends UIComponent
	{
		private var vblock:Vector.<VideoBlock>
		private static var inst:HistoryVideoLoader;
		public static function access():HistoryVideoLoader
		{
			if(!inst)
				inst = new HistoryVideoLoader;
			return inst;
		}
		
		private var bClose:VisualButton;
		private var gear:GearBox;
		
		public function HistoryVideoLoader()
		{
			super();
			
			gear = new GearBox;
			
			vblock = new Vector.<VideoBlock>(3);
			
			for (var i:int=0; i<3; i++) {
				vblock[i] = new VideoBlock(gear);
				addChild( vblock[i] );
				vblock[i].y = vblock[i].height*i;
			}
			
			bClose = new VisualButton(GuiLib.cxclose_v2);
			bClose.setUp("",close);
			addChild( bClose );
			bClose.x = 582;
			bClose.y = 2;
		}
		public function open(date:Date,p:Point):void
		{
			this.y = p.y-47;
			this.x = 20;
			
			RequestAssembler.getInstance().fireEvent(new Request(CMD.VPN_GET_INFO,put));
			RequestAssembler.getInstance().fireEvent(new Request(CMD.GET_NET,put));
			RequestAssembler.getInstance().fireEvent(new Request(CMD.WIFI_POINT_SETTINGS,put));
			
			gear.reset();
			
			vblock[0].put(getCloneDate(date,-1));
			vblock[1].put(getCloneDate(date,0));
			vblock[2].put(getCloneDate(date,1));
		}
		private function put(p:Package):void
		{
			// Приоритеты WiFi, Vpn, Lan
			switch(p.cmd) {
				case CMD.VPN_GET_INFO:
					if (p.getParamInt(1)==1 )
						gear.add(p.getParamString(2));
					break;
				case CMD.GET_NET:
					
					var a1:Object = OPERATOR.getParamInt(CMD.VPN_GET_INFO,1);
					if (p.getParamInt(1)!=0xff && OPERATOR.getParamInt(CMD.VPN_GET_INFO,1)==0 )
						gear.add(p.getParamString(2));
					break;
				case CMD.WIFI_POINT_SETTINGS:
					if (p.getParamInt(1)==1 )
						gear.add("192.168.41.01");
					
					vblock[0].open();
					vblock[1].open();
					vblock[2].open();
					
					visible = true;
					break;
			}
		}
		private function getCloneDate(date:Date,addminutes:int):Date
		{
			var d:Date = new Date;
			var y:Number = (date.fullYearUTC < 70) ? (2000 + date.fullYearUTC) : (1900 + date.fullYearUTC);
			
			d.setUTCFullYear(y, date.monthUTC,date.dateUTC);
			d.setUTCHours(date.hoursUTC,date.minutesUTC,0);
			d.minutesUTC = d.minutesUTC + addminutes; 
			return d;
			
		}
		public function close():void
		{
			this.visible = false;
			
			vblock[0].close();
			vblock[1].close();
			vblock[2].close();
		}
	}
}
import flash.display.Bitmap;
import flash.events.AsyncErrorEvent;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.NetStatusEvent;
import flash.events.ProgressEvent;
import flash.filters.BitmapFilterQuality;
import flash.filters.DropShadowFilter;
import flash.media.Video;
import flash.net.NetConnection;
import flash.net.NetStream;
import flash.net.URLLoader;
import flash.net.URLLoaderDataFormat;
import flash.net.URLRequest;
import flash.text.TextField;
import flash.utils.ByteArray;

import mx.core.UIComponent;
import mx.utils.URLUtil;

import components.abstract.functions.dtrace;
import components.abstract.functions.loc;
import components.abstract.servants.TaskManager;
import components.gui.FileBrowser;
import components.gui.SimpleTextField;
import components.gui.camera.VideoH264;
import components.gui.triggers.TextButton;
import components.gui.visual.ProgressBarStatic;
import components.interfaces.ITask;
import components.static.COLOR;
import components.system.Library;
import components.system.UTIL;

class VideoBlock extends UIComponent
{
	private var bmpTime:Bitmap;
	private var bmpSize:Bitmap;
	private var bmpFormat:Bitmap;
	private var tTime:SimpleTextField;
	private var tSize:SimpleTextField;
	private var tFormat:SimpleTextField;
	private var tSpeed:SimpleTextField;
	private var bDownload:TextButton;
	//private var pBar:ProgressBar;
	private var bar:ProgressBarStatic;
	
	private var loader:URLLoader;
	private var request:URLRequest;
	private var date:Date;
	private var gear:GearBox;
	private var silent:Boolean=false;	// для вытаскивания размеров файлов, быстрый коннект, который прерывается сразу после получения первого ProgressEvent
	private var speedBox:SpeedBox;
	private var filename:String;		// название для файла
	
	public function VideoBlock(g:GearBox):void
	{
		super();
		
		gear = g;
		
		draw();
		
		tTime = add( "", 10, 10, 100, Library.c_date );
		tSize = add( "-", 110, 10, 150, Library.c_size );
		tFormat = add("mp4", 200, 10, 150, Library.c_videfile );
		tSpeed = add( "-", 380, 18, 200 );
		//tSpeed = add( "speed:33.35KB/s", 380, 18, 200 );
		speedBox = new SpeedBox(tSpeed);
		
		bDownload = new TextButton;
		addChild( bDownload );
		bDownload.setUp( loc("g_download"), onTryDownload );
		bDownload.x = 270;
		bDownload.y = 18;
		
		bar = new ProgressBarStatic(Library.c_pb_bg_left, Library.c_pb_bg, Library.c_pb_bg_right,
			Library.c_pb_fill_left, Library.c_pb_fill, Library.c_pb_fill_right);
		addChild( bar );
		bar.y = 4;
		bar.x = 270;
		bar.width = 300;
	}
	public function close():void
	{
		tSize.text = "-";
		speedBox.stop();
		if (loader)
			loader.close();
		loader = null;
		
		bar.setProgress( 0, 10 );
		bDownload.setName(loc("g_download"));
	}
	public function put(d:Date):void
	{
		close();
		date = d;
		tTime.text = UTIL.fz(date.hours,2)+":"+UTIL.fz(date.minutes,2)+":00";
		filename = UTIL.fz(date.fullYear,4) + "-"+ UTIL.fz(date.month,2) +"-"+ UTIL.fz(date.date,2)+ "--" + UTIL.fz(date.hours,2)+"-"+UTIL.fz(date.minutes,2)+"-00.mp4"
	}
	public function open():void
	{
		silent = true;
		bDownload.disabled = true;
		go(getAdr());
	}
	private function add(ttl:String, xpos:int, ypos:int, w:int, bmpcls:Class=null):SimpleTextField
	{
		if (bmpcls) {
			var bmp:Bitmap = new bmpcls;
			addChild( bmp );
			bmp.x = xpos;
			bmp.y = ypos+2;
		}
		
		var t:SimpleTextField = new SimpleTextField(ttl);
		addChild( t );
		t.x = bmp == null ? xpos : xpos + 18;
		t.y = ypos;
		t.width = w;
		return t;
	}
	private function getAdr():String
	{
		var adr:String = gear.getadr();
		
		var file:String = "hdd/" + date.fullYearUTC +"-"+ 
			UTIL.fz(date.monthUTC+1,2) +"/"+ 
			UTIL.fz(date.dateUTC,2) +"/"+ 
			UTIL.fz(date.hoursUTC,2) +"/"+ 
			UTIL.fz(date.minutesUTC,2) +".mp4";
		
		return adr + file;
	}
	private function onTryDownload():void
	{
		/*
		if (!gotvideo)
			go(getAdr());
		else {
			FileBrowser.getInstance().save(mp4,filename);
		}
		*/
			
		if (!gotvideo)
			FileBrowser.getInstance().open(gotVideo);
		else {
			
			/*
			
			var m:Mp4Player = new Mp4Player(mp4);
			addChild( m );
			*/
			
			FileBrowser.getInstance().save(mp4,"asd.flv");
		}
		
		
	}
	private function onTrySilentDownload():void
	{
		go(getAdr());
	}
	private var gotvideo:Boolean;
	private var mp4:ByteArray;
	private function gotVideo(b:ByteArray,n:Object=null):void
	{
		gotvideo = true;
		bDownload.setName(loc("g_save"));
		
		var v:VideoH264 = new VideoH264(320,240);
		addChild( v );
		v.read(b);
		
		mp4 = v.image;
//		mp4 = b;
		bDownload.disabled = false;
	}
	
	private function go(url:String):void
	{
		request = new URLRequest( url );
		loader = new URLLoader();
		loader.dataFormat = URLLoaderDataFormat.BINARY;
		loader.addEventListener(IOErrorEvent.IO_ERROR, onFail);
		loader.addEventListener(ProgressEvent.PROGRESS, onProgress);
		loader.addEventListener(Event.COMPLETE, onComplete);
		loader.load(request);
	}
	private function onFail(e:Event=null):void
	{
		if (e && e.type != null)
			dtrace("error " + e.type );
		//callback(null);
		gear.invalid(request.url);
		if (gear.getadr() is String)
			go( gear.getadr() );
		else {
			loader = null;
			speedBox.stop();
		}
	}
	
	private function onProgress(e:ProgressEvent):void
	{
		if( tSize.text == "-" ) {
			tSize.text = (e.bytesTotal/1024/1024).toFixed(1) + " " + loc("g_mbytes");
		}
		if (silent) {
			loader.close();
			loader = null;
			bDownload.disabled = false;
			silent = false;
		} else {
			speedBox.update(e.bytesLoaded);
			bDownload.setName(loc("g_do_cancel"));
			bar.setProgress( 0, 10 );
		}
	}
	private function onComplete(e:Event):void
	{
		loader.removeEventListener(IOErrorEvent.IO_ERROR, onFail);
		loader.removeEventListener(Event.COMPLETE, onComplete);
		gotVideo(loader.data as ByteArray);
		speedBox.stop();
		loader = null;
	}
	
	private function draw():void
	{
		this.graphics.clear();
		this.graphics.beginFill( COLOR.ANGELIC_GREY );
		this.graphics.drawRoundRect(0,0,600,40,5,5);
		this.graphics.endFill();
		
		var dropShadow:DropShadowFilter = new DropShadowFilter(); 
		dropShadow.distance = 5; 
		dropShadow.angle = 45; 
		dropShadow.color = COLOR.BLACK; 
		dropShadow.alpha = 0.5; 
		dropShadow.blurX = 5; 
		dropShadow.blurY = 5; 
		dropShadow.strength = 1; 
		dropShadow.quality = BitmapFilterQuality.HIGH; 
		dropShadow.inner = false; 
		dropShadow.knockout = false; 
		dropShadow.hideObject = false; 
		
		this.filters = [dropShadow];
	}
	override public function get height():Number
	{
		return 42;
	}
}
class GearBox
{
	private var address:Array;
	
	public function reset():void
	{
		address = [];
	}
	public function getadr():String
	{
		if (address.length > 0)
			return "http://"+address[0]+":40302/";
		return null;
	}
	public function add(adr:String):void
	{
		address.push(adr);
	}
	public function invalid(url:String):void
	{
		var adr:String = URLUtil.getServerName(url);
		
		if( address ) {
			var len:int = address.length;
			for (var i:int=0; i<len; i++) {
				if (address[i] == adr) {
					address.splice(i,1);
					break;
				}
			}
		}
	}
}
class SpeedBox
{
	private var task:ITask;
	private var field:TextField;
	private var first:Number = 0;
	private var last:Number;
	
	public function SpeedBox(tf:TextField)
	{
		field = tf;
		field.text = "-";
		task = TaskManager.callLater(onTick, TaskManager.DELAY_1SEC );
		task.stop();
	}
	public function update(bytesloaded:Number):void
	{
		if (!task.running())
			task.repeat();
		last = bytesloaded;
		if(first == 0) {
			onTick();
			first = bytesloaded;
		}
	}
	public function stop():void
	{
		field.text = "-";
		task.stop();
	}
	private function onTick():void
	{
		if ( (last - first)/1024 < 1000) 
			field.text = ((last - first)/1024).toFixed(1) + " " + loc("g_kb_sec");
		else
			field.text = ((last - first)/1024/1024).toFixed(1) + " " + loc("g_mb_sec");
		first = last;
		task.repeat();
	}
}
class Mp4Player extends UIComponent
{
	public function Mp4Player(b:ByteArray):void
	{
		super();
		
		var nc:NetConnection = new NetConnection(); 
		nc.connect(null);
		
		var ns:NetStream = new NetStream(nc);
		ns.addEventListener(AsyncErrorEvent.ASYNC_ERROR, asyncErrorHandler); 
		function asyncErrorHandler(event:AsyncErrorEvent):void 
		{ 
			// ignore error 
		}
		
		var customClient:Object = new Object();
		customClient.onMetaData = onMetaData;

		
		ns.client = customClient; 
		
		ns.play(null);
		ns.appendBytes( b );
		
		var vid:Video = new Video(); 
		vid.attachNetStream(ns); 
		addChild(vid);
		
		/*
		var nc:NetConnection = new NetConnection(); 
		nc.connect(null);
		
		var ns:NetStream = new NetStream(nc); 
		ns.addEventListener(AsyncErrorEvent.ASYNC_ERROR, asyncErrorHandler); 
		ns.play("video.mp4"); 
		function asyncErrorHandler(event:AsyncErrorEvent):void 
		{ 
			// ignore error 
		}
		
		var vid:Video = new Video(); 
		vid.attachNetStream(ns); 
		addChild(vid);
		*/
	}
	
	private function onMetaData(p_info:Object):void	{}
	private function onNetStatus(e:NetStatusEvent):void	{}

}