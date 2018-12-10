package components.interfaces
{
	import flash.display.BitmapData;

	public interface IStreamer
	{
		function gotPicture(b:BitmapData):void;
		function getStreamId():int;
	}
}