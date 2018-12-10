package components.gui.camera
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.NetStatusEvent;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.net.NetStreamAppendBytesAction;
	import flash.utils.ByteArray;
	
	import mx.core.UIComponent;
	
	import components.abstract.video.FPSCounter;
	import components.interfaces.IVideoEngine;
	
	public final class VideoH264 extends UIComponent implements IVideoEngine
	{
		private const FLVTAG_AUDIO:uint = 0x08;
		private const FLVTAG_VIDEO:uint = 0x09;
		private const FLVTAG_META:uint = 0x12;
		private const FLV_HEADER:Vector.<int> = new <int>[
			0x46, 0x4C, 0x56, 0x01, 0x01, 0x00, 0x00, 0x00, 0x09, 0x00, 0x00, 0x00, 0x79, 0x09, 0x00, 0x00, 
			0x6E, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x17, 0x00, 0x00, 0x00, 0x00, 0x01, 0x64, 0x00, 
			0x1E, 0xFF, 0xE1, 0x00, 0x5A, 0x67, 0x64, 0x00, 0x1E, 0xAD, 0x84, 0x05, 0x45, 0x62, 0xB8, 0xAC, 
			0x54, 0x74, 0x20, 0x2A, 0x2B, 0x15, 0xC5, 0x62, 0xA3, 0xA1, 0x01, 0x51, 0x58, 0xAE, 0x2B, 0x15, 
			0x1D, 0x08, 0x0A, 0x8A, 0xC5, 0x71, 0x58, 0xA8, 0xE8, 0x40, 0x54, 0x56, 0x2B, 0x8A, 0xC5, 0x47, 
			0x42, 0x02, 0xA2, 0xB1, 0x5C, 0x56, 0x2A, 0x3A, 0x10, 0x24, 0x85, 0x21, 0x39, 0x3C, 0x9F, 0x27, 
			0xE4, 0xFE, 0x4F, 0xC9, 0xF2, 0x79, 0xB9, 0xB3, 0x4D, 0x08, 0x12, 0x42, 0x90, 0x9C, 0x9E, 0x4F, 
			0x93, 0xF2, 0x7F, 0x27, 0xE4, 0xF9, 0x3C, 0xDC, 0xD9, 0xA6, 0xB4, 0x05, 0x80, 0x93, 0x20, 0x01, 
			0x00, 0x04, 0x68, 0xEE, 0x3C, 0xB0, 0x00, 0x00, 0x00, 0x79 ];
		
		private const AVC_HEADER:Vector.<int> = new <int>[1,0,0,0];
		
		private var BUFFERING:Boolean = false;
		
		private var sended:Boolean = false;
		private var currentUnit:Vector.<int>;
		
		private var TIMESTAMP:int = 0;
		private var PREV_TAG_SIZE:int = 0;
		private var CURRENT_TAG_SIZE:int = 0;
		private var INTERFRAME:Boolean = false;
		private var TIME:Date;
		private var CURRENTTIME:Date;
		
		private var ByteStream:Vector.<int> = new Vector.<int>;
		private var Frames:Vector.<Vector.<int>> = new Vector.<Vector.<int>>;
		private var WrappedFrames:Vector.<Vector.<int>> = new Vector.<Vector.<int>>;

		private var video:Video;
		private var video_ns:NetStream;
		private var video_ns_fake:NetStream;
		private var video_nc:NetConnection;
		
		private var bitmap:Bitmap;
		
		public function VideoH264(w:int, h:int)
		{
			super();
			
			video = new Video(w, h);
			addChild( video );
			video_nc = new NetConnection();
			video_nc.connect(null);
			video.visible = false;
			
			var customClient:Object = new Object();
			customClient.onMetaData = onMetaData;
			video_ns = new NetStream(video_nc);
			video_ns.client = customClient;
			video_ns.play(null);
			video_ns.appendBytesAction(NetStreamAppendBytesAction.RESET_BEGIN);
			video_ns.bufferTime = 0.5;
			video_ns.bufferTimeMax = 1;
			
			video_ns_fake = new NetStream(video_nc);
			video_ns_fake.client = customClient;
			video_ns_fake.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
			try {
				video_ns_fake.play("");				
			} catch(error:Error) {
				trace("Инициализация обманного NetStream");
			}
			
			video.attachNetStream(video_ns);
			//video.smoothing = true;
			
			this.width = w;
			this.height = h;
			video.width = w;
			video.height = h;
			
	//		frameTimer = new Timer(40);
	//		frameTimer.addEventListener( TimerEvent.TIMER, onTimer );
			this.addEventListener( Event.ENTER_FRAME, processFrame );
		}
		
		public function read(b:ByteArray):Boolean
		{
			if (b.length > 4) {
				var i:int
				var len:int = b.length;
				var shift:int;
				var total:int;
				b.position = 0;
				
				for( i=0; i<len; ++i) {
					ByteStream.push( b[i] );
				}
				b.length = 0;
				var anchor:int;
				
				while(true) {
					shift = -1;
					total = 0;
					len = ByteStream.length;
					for( i=0; i<len-4; ++i) {
						
						if ( shift < 0 ) {
							if( ByteStream[i] == 0x00 && ByteStream[i+1] == 0x00 && ByteStream[i+2] == 0x00 && ByteStream[i+3] == 0x01 ) {
								shift = i;
								continue;
							}
						} else {
							if( ByteStream[i] == 0x00 && ByteStream[i+1] == 0x00 && ByteStream[i+2] == 0x00 && ByteStream[i+3] == 0x01 ) {
								total = i-shift;
								break;
							}
						}
					}
					if (total > 0) {
						Frames.push( ByteStream.splice(shift, total) );
					} else
						break;
				}
				wrap();
			}
			image.position = 0;
			return false;
		}
		
		public function resize(w:int, h:int):void
		{
			this.width = w;
			this.height = h;
			video.width = w;
			video.height = h;
		}
		
		public function reset():void
		{
		}
		
		public var image:ByteArray;
		private function wrap():void
		{
			var len:int = Frames.length;
			var nalunit:Vector.<int>;
			//var frame:Array;
			var nalLength:int;
			var byteslen:int;
			for(var i:int=0; i<len; ++i ) {
				nalunit = wrapNALUNIT( Frames[i] );
				INTERFRAME = false;
				
				var sign:int = nalunit[4] << 8 | nalunit[5];
				switch(sign) {
					case 0x6764:	// sps
					case 0x674D:	// sps
						currentUnit = nalunit;
						continue;
						break;
					case 0x68EE:	// pps
						currentUnit = currentUnit.concat( nalunit );
						continue;
					case 0x0605:	// sei
						continue;
					case 0x6588:	// idr
						currentUnit = currentUnit.concat( nalunit );
						break;
					case 0x619A:	// non idr
					case 0x619B:
						INTERFRAME = true;
						currentUnit = nalunit;
						break;
				}
				
				nalLength = currentUnit.length;
				
				CURRENTTIME = new Date;
				if (TIME) {
					var now:Number = CURRENTTIME.time;
					var old:Number = TIME.time;
				//	trace(video_ns.bufferLength + " < "+ video_ns.bufferTime )
					var buffershift:int = video_ns.bufferLength < video_ns.bufferTime ? 15:0;
					TIMESTAMP += CURRENTTIME.time - TIME.time + buffershift; 
				//	trace(result);
				}
				TIME = CURRENTTIME;
				
				currentUnit = wrapAVCVideoPacket( currentUnit );
				currentUnit = wrapVideoData( currentUnit );
				currentUnit = wrapFLVTag( currentUnit );
				
				if(!sended) {
					currentUnit = FLV_HEADER.concat( currentUnit );
					sended = true;
				} else 
					currentUnit = wrapFLVStream( currentUnit );
				
				PREV_TAG_SIZE = CURRENT_TAG_SIZE;
				
				WrappedFrames.push(currentUnit);
				
			//	frameTimer.start();
			//	IFRAMES_READY.push( currentUnit.slice() );
				
				//var f:Vector.<int> = currentUnit.slice();
				var flen:int = currentUnit.length;
				if (!image)
					image = new ByteArray;
				for(var k:int=0; k<flen; ++k ) {
					image.writeByte( currentUnit[k] );
				}
				FPSCounter.update();
				//video_ns.appendBytes( image );
			//	trace( video_ns.bufferLength
			}
			Frames.length = 0;
		}
		private function wrapNALUNIT(v:Vector.<int>):Vector.<int>
		{
			v.splice(0,4);
			return toUI32( v.length ).concat( v );
		}
		private function wrapAVCVideoPacket(v:Vector.<int>):Vector.<int>
		{
			return AVC_HEADER.concat( v );
		}
		private function wrapVideoData(v:Vector.<int>):Vector.<int>
		{
			var frameType:int = INTERFRAME == true ? 2 : 1;
			var codecId:int = 7;
			
			var result:Vector.<int> = new <int>[(frameType << 4) | codecId]; 
			
			return result.concat( v );
		}
		private function wrapFLVStream(v:Vector.<int>):Vector.<int>
		{
			return toUI32(PREV_TAG_SIZE).concat( v );
		}
		private function wrapFLVTag(v:Vector.<int>):Vector.<int>
		{
			var tag:Vector.<int> = new <int>[ FLVTAG_VIDEO ];
			tag = tag.concat( toUI24( v.length ) );
			tag = tag.concat( toUI24(TIMESTAMP) );
			tag = tag.concat( new <int>[0,0,0,0] );
			
			CURRENT_TAG_SIZE = v.length+11;
			//TIMESTAMP += 140;
			
			return tag.concat( v );
		}
		private function toUI24(p:uint):Vector.<int>
		{
			var v:Vector.<int> = new <int>[p >> 16, p >> 8 & 0xff, p & 0xff ];
			return v;
		}
		private function toUI32(p:uint):Vector.<int>
		{
			var v:Vector.<int> = new <int>[p >> 24 & 0xff, p >> 16 & 0xff, p >> 8 & 0xff, p & 0xff ];
			return v;
		}
		private function copy():void
		{
			video.attachNetStream(video_ns_fake);
			
			var bd1:BitmapData=new BitmapData(this.width,this.height,true,0);
			
			if (bitmap)
				removeChild( bitmap );
			bitmap = new Bitmap(bd1);
			addChild( bitmap );
			bd1.draw( video );
			
			video.attachNetStream( video_ns );
		}
		private function processFrame(ev:Event):void
		{
			copy();
		}

/** Needed but useless	*/
		private function onMetaData(p_info:Object):void	{}
		private function onNetStatus(e:NetStatusEvent):void	{}
	}
}