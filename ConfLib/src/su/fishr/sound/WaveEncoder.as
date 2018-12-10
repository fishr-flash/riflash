///********************************************************************
///* Copyright © 2012 fishr (fishr.flash@gmail.com)  
///********************************************************************


package su.fishr.sound 
{
	
	import flash.display.Shape;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
   

	/**
	 *    Кодирует PCM в формат WAVE ( .wav )
	 * 
	 * @playerversion          Flash 9
	 * @langversion            3.0
	 * @author                 fishr
	 * @created                21.08.2012 2:34
	 * @since                  21.08.2012 2:34
	 */
	public  class WaveEncoder extends EventDispatcher
	{
		
		
		
		[Event (name="progress", type="flash.events.ProgressEvent")];
		[Event (name="complete", type="flash.events.Event")];
		[Event (name="errorEncoder", type="su.fishr.sound.WaveEncoder")];
	/**-------------------------------------------------------------------------------
	* 
	*	   						V A R I A B L E ' S 	
	* 
	* --------------------------------------------------------------------------------
	*/
	//{
		static public const ERROR_ENCODER:String = "errorEncoder";
		static private const AUTHOR:String = "fishr (fishr.flash@gmail.com)";
		
		private static const RIFF:String = "RIFF";	
		private static const WAVE:String = "WAVE";	
		private static const FMT:String = "fmt ";	
		private static const DATA:String = "data";	
		private const _LIMIT_BYTES:int = 441000;
		private const _DISPATCHER_FRAME:Shape = new Shape();
		
		private var _bytes:ByteArray = new ByteArray();
		private var _buffer:ByteArray = new ByteArray();
		private var _volume:Number;
		private var _samples:ByteArray;
		private var _rate:int;
		private var _channels:int;
		private var _bits:int;
		
	//}
	
	/**-------------------------------------------------------------------------------
	* 
	*	 						P R O P E R T I E S 	
	* 
	* --------------------------------------------------------------------------------
	*/
	//{
		public function get wav():ByteArray
		{
			return _bytes;
		}
		
		public function get raw():ByteArray
		{
			return _samples;
		}
		
		public function get rate():int 
		{
			return _rate;
		}
	//}
	/**-------------------------------------------------------------------------------
	* 
	*								P U B L I C 	
	* 
	* --------------------------------------------------------------------------------
	*/
	//{
		public function WaveEncoder( volume:Number = 1, target:IEventDispatcher = null)
		{
			super(target);
			_volume = volume;
			

		}
		
		/**
		 * 
		 * @param samples
		 * @param channels
		 * @param bits
		 * @param rate
		 * @return 
		 * 
		 */		
		public function encode( samples:ByteArray, channels:int=2, bits:int=16, rate:int=44100 ):void
		{
			_samples = samples;
			_rate = rate;
			_channels = channels;
			_bits = bits;
			create();

		}
		
		public function decode( wav:ByteArray = null ):void
		{
			_bytes = wav || _bytes;
			_bytes.endian = Endian.LITTLE_ENDIAN;
			_bytes.position = 24;
			_rate = _bytes.readInt();
			_bytes.position = 44;
			_samples = new ByteArray();

			_DISPATCHER_FRAME.addEventListener(Event.ENTER_FRAME, enterFrameDecode );
			
		}
		
		
		
		
	//}
	
	/**-------------------------------------------------------------------------------
	* 
	*								P R I V A T E 	
	* 
	* --------------------------------------------------------------------------------
	*/	
	//{
		private function create():void
		{
			_buffer.endian = Endian.LITTLE_ENDIAN;
			_buffer.length = 0;
			_samples.position = 0;
			
			_DISPATCHER_FRAME.addEventListener(Event.ENTER_FRAME, enterFrame );
			
			
		}
		
		private function enterFrameDecode(e:Event):void 
		{
			
			if ( !_bytes.bytesAvailable )
			{
				
				_DISPATCHER_FRAME.removeEventListener(Event.ENTER_FRAME, enterFrameDecode );
				_bytes.clear();
				_samples.position = 0;
				this.dispatchEvent( new Event( Event.COMPLETE ) );
				return;
			}
			
			const length:int = _bytes.length - 44;
			this.dispatchEvent( new ProgressEvent
									( ProgressEvent.PROGRESS, false, false, 
										length -_bytes.bytesAvailable, length ) );
			
			writeFloat();
		}
		
		private function writeFloat():void 
		{
			
			try
			{
				_samples.writeFloat( _bytes.readShort() / (0x7fff * _volume) );
				while ( _bytes.position % _LIMIT_BYTES && _bytes.bytesAvailable )
				_samples.writeFloat(  _bytes.readShort() / (0x7fff * _volume) );
			}
			catch ( err:Error )
			{
				////////////////////////// T R A C E ///////////////////////////////
				var d:Date = new Date();
				trace(d.valueOf() + ". WaveEncoder::writeFloat()  : " + err);
				//////////////////////// E N D  T R A C E //////////////////////////
				
				this.dispatchEvent( new Event( ERROR_ENCODER ) );
				
			}
			
		}
		
		private function enterFrame(e:Event):void 
		{
			if ( !_samples.bytesAvailable )
			{
				completeWrite();
				_DISPATCHER_FRAME.removeEventListener(Event.ENTER_FRAME, enterFrame );
				return;
			}
			
			this.dispatchEvent( new ProgressEvent
									( ProgressEvent.PROGRESS, false, false, 
										_samples.length -_samples.bytesAvailable,_samples.length ) );
			
			writeShort();
		}
		
		private function writeShort():void
		{
			try
			{
			    _buffer.writeShort(_samples.readFloat() * (0x7fff * _volume) );
				while ( _samples.position % _LIMIT_BYTES && _samples.bytesAvailable )
				_buffer.writeShort(_samples.readFloat() * (0x7fff * _volume) );
			
				
			}
			catch ( err:Error )
			{
				////////////////////////// T R A C E ///////////////////////////////
				var d:Date = new Date();
				trace(d.valueOf() + ". WaveEncoder::writeShort()  : " + err);
				//////////////////////// E N D  T R A C E //////////////////////////
				
				_samples.position = _samples.length;
				this.dispatchEvent( new Event( ERROR_ENCODER ) );
				
			}
			
		}
		
		private function completeWrite():void 
		{
			_bytes.length = 0;
			_bytes.endian = Endian.LITTLE_ENDIAN;
			
			_bytes.writeUTFBytes( WaveEncoder.RIFF );
			_bytes.writeInt( uint( _buffer.length + 44 ) );
			_bytes.writeUTFBytes( WaveEncoder.WAVE );
			_bytes.writeUTFBytes( WaveEncoder.FMT );
			_bytes.writeInt( uint( 16 ) );
			_bytes.writeShort( uint( 1 ) );
			_bytes.writeShort( _channels );
			/// position 24
			_bytes.writeInt( _rate );
			_bytes.writeInt( uint( _rate * _channels * ( _bits >> 3 ) ) );
			_bytes.writeShort( uint( _channels * ( _bits >> 3 ) ) );
			_bytes.writeShort( _bits );
			_bytes.writeUTFBytes( WaveEncoder.DATA );
			_bytes.writeInt( _buffer.length );
			/// всегда _bytes.position = 44
			
			_bytes.writeBytes( _buffer );
			_bytes.position = 0;
			
			this.dispatchEvent( new Event ( Event.COMPLETE ) );
			
			
		}
	//}
		
		
	}

}