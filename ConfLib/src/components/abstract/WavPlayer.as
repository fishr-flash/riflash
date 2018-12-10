package components.abstract
{
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	public class WavPlayer {
		private var _wavFormat:PCMFormat;
		private var sound:Sound;
		private var channel:SoundChannel;
		
		public function play(b:ByteArray):void 
		{
			trace("loading complete… analyzing header…");
			
			var wavHeader:ByteArray = new ByteArray(); wavHeader.endian = Endian.LITTLE_ENDIAN;
			var wavData:ByteArray = new ByteArray(); wavData.endian = Endian.LITTLE_ENDIAN;
			
			b.readBytes(wavHeader, 0, PCMFormat.HEADER_SIZE);
			_wavFormat = new PCMFormat();
			
			try {
				_wavFormat.AnalyzeHeader(wavHeader);
			} catch (e:Error) {
				trace(e);
				return;
			}
			
			var bytesToRead:uint = b.bytesAvailable < _wavFormat._waveDataLength ? b.bytesAvailable : _wavFormat._waveDataLength;
			b.readBytes(wavData, 0, bytesToRead);
			var swf:SWFFormat = new SWFFormat(_wavFormat);
			var compiledSWF:ByteArray = swf.CompileSWF(wavData);
			var compiledSWFLoader:Loader = new Loader();
			compiledSWFLoader.loadBytes(compiledSWF);
			compiledSWFLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, generateCompleteHandler);
		}
		public function stop():void
		{
			if (channel)
				channel.stop();
		}
		private function generateCompleteHandler(e:Event):void
		{
			var soundClass:Class = LoaderInfo(e.target).applicationDomain.getDefinition(SWFFormat.CLASS_NAME) as Class;
			sound = new soundClass() as Sound;
			if (channel)
				channel.stop();
			channel = sound.play(0, 0, null);
		}
	}
}

	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	import components.abstract.LOC;
	import components.gui.Balloon;
	
class PCMFormat {
	/* CLASS PROPERTIES **********************************************************************/
	public static const HEADER_SIZE:uint = 44;
	
	public var _channels:uint;
	public var _sampleRate:uint;
	public var _byteRate:uint;
	public var _blockAlign:uint;
	public var _bitsPerSample:uint;
	public var _waveDataLength:uint;
	public var _fullDataLength:uint;
	
	/* CONSTRUCTOR ***************************************************************************/
	public function PCMFormat() {
		
	}
	
	/* PUBLIC METHODS ************************************************************************/
	public function AnalyzeHeader(byteArray:ByteArray):void
	{
		var typeArray:ByteArray = new ByteArray();
		byteArray.readBytes(typeArray, 0, 4);
		
		if (typeArray.toString() != "RIFF") {
			//throw new Error("Error: incorrect RIFF header");
			Balloon.access().show( LOC.loc("sys_error"), LOC.loc("snd_incorrect_riff_header") );
			return;
		}
		
		_fullDataLength = byteArray.readUnsignedInt()+8;
		byteArray.position = 0x10;
		var chunkSize:Number = byteArray.readUnsignedInt();
		
	/*	if (chunkSize != 0x10) {
			throw new Error("Error: incorrect chunk size");
			return;
		}*/
		
		var isPCM:Boolean = Boolean(byteArray.readShort());
		
		if (!isPCM) {
			//throw new Error("Error: this file is not PCM wave file");
			Balloon.access().show( LOC.loc("sys_error"), "snd_not_pcm_format" ); 
			return;
		}
		
		_channels = byteArray.readShort();
		_sampleRate = byteArray.readUnsignedInt();
		
		switch (_sampleRate) {
			case 44100:
			case 22050:
			case 11025:
			case 5512:
				break;
			default:
				//throw new Error("Decode error: incorrect sample rate");
				Balloon.access().show( LOC.loc("sys_error"), LOC.loc("snd_incorrect_sample_rate") );
				return;
		}
		
		_byteRate = byteArray.readUnsignedInt();
		_blockAlign = byteArray.readShort();
		_bitsPerSample = byteArray.readShort();
		byteArray.position += 0x04;
		_waveDataLength = byteArray.readUnsignedInt();
		
		if (!_blockAlign) {
			_blockAlign = _channels*_bitsPerSample/8;
		}
		
		byteArray.position = 0;
	}
}

	
class SWFFormat {
	/* CLASS PROPERTIES **********************************************************************/
	private static const SWF_PART0:String = "46575309";
	private static const SWF_PART1:String = "7800055F00000FA000000C01004411080000004302FFFFFFBF150B00000001005363656E6520310000BF14C7000000010000000010002E00000000080013574156506C61796572536F756E64436C6173730B666C6173682E6D6564696105536F756E64064F626A6563740C666C6173682E6576656E74730F4576656E744469737061746368657205160116031802160600050701020702040701050704070300000000000000000000000000010102080300010000000102010104010003000101050603D030470000010101060706D030D04900470000020201010517D0306500600330600430600230600258001D1D1D6801470000BF03";
	private static const SWF_PART2:String = "3F131800000001000100574156506C61796572536F756E64436C61737300440B0800000040000000";
	
	public static const CLASS_NAME:String = "WAVPlayerSoundClass";
	
	private var _pcmFormat:PCMFormat;
	
	/* CONSTRUCTOR ***************************************************************************/
	public function SWFFormat(format:PCMFormat)
	{
		_pcmFormat = format;
	}
	
	/* PRIVATE METHODS ***********************************************************************/
	private function WriteBytesFromString(byteArray:ByteArray, bytesHexString:String):void
	{
		var length:uint = bytesHexString.length;
		
		for (var i:uint = 0;i<length;i+=2) {
			var hexByte:String = bytesHexString.substr(i, 2);
			var byte:uint = Number("0x"+hexByte);
			byteArray.writeByte(byte);
		}
	}
	
	private function TraceArray(array:ByteArray):String
	{ // for debug
		var out:String = "";
		var pos:uint = array.position;
		array.position = 0;
		
		while (array.bytesAvailable) {
			var str:String = array.readUnsignedByte().toString(16).toUpperCase();
			str = str.length < 2 ? "0"+str : str;
			out += str+' ';
		}
		
		array.position = pos;
		return out;
	}
	
	private function GetFormatByte():uint
	{
		var byte:uint = (_pcmFormat._bitsPerSample == 0x10) ? 0x32 : 0x00;
		byte += (_pcmFormat._channels-1);
		byte += 4*(Math.floor(_pcmFormat._sampleRate/5512.5).toString(2).length-1); // :-)
		return byte;
	}
	
	/* PUBLIC METHODS ************************************************************************/
	public function CompileSWF(audioData:ByteArray):ByteArray
	{
		var dataLength:uint = audioData.length;
		var swfSize:uint = dataLength+307;
		var totalSamples:uint = dataLength/_pcmFormat._blockAlign;
		var output:ByteArray = new ByteArray();
		output.endian = Endian.LITTLE_ENDIAN;
		WriteBytesFromString(output, SWFFormat.SWF_PART0);
		output.writeUnsignedInt(swfSize);
		WriteBytesFromString(output, SWFFormat.SWF_PART1);
		output.writeUnsignedInt(dataLength+7);
		output.writeByte(1);
		output.writeByte(0);
		output.writeByte(GetFormatByte());
		output.writeUnsignedInt(totalSamples);
		output.writeBytes(audioData);
		WriteBytesFromString(output, SWFFormat.SWF_PART2);
		return output;
	}
}