package components.gui
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import components.abstract.functions.dtrace;

	public class FileBrowser
	{
		private static var inst:FileBrowser;
		public static function getInstance():FileBrowser
		{
			if (!inst)
				inst = new FileBrowser;
			return inst;
		}
		private var fr:FileReference;
		private var delegate:Function;
		private var cancel:Function;
		
		/** "Binary File", "*.*;" */
		public static function type(name:String, extension:String):Array
		{
			return [new FileFilter(name, extension)];
		}
		public function save(data:*, filename:String=null):void
		{
			fr = new FileReference();
			fr.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
			try {
				fr.save( data, filename );
			} catch(error:Error) {
				trace(error.message);
			}
		}
		
		/** f returns (byteArray, FileReference)	*/
		public function open(f:Function, types:Array=null, cancel:Function=null):void
		{
			delegate = f;
			this.cancel = cancel;
			fr = new FileReference();
			fr.addEventListener(Event.SELECT, onFileSelect);
			fr.addEventListener(Event.CANCEL,onCancel);
			if (types)
				fr.browse(types);
			else
				fr.browse();
		}
		/** f returns (object), loads only files in the same dir as swf */
		public function loadLocal(filename:String, f:Function):void
		{
			delegate = f;
			
			var loader:URLLoader = new URLLoader;
			loader.load(new URLRequest(filename));
			loader.addEventListener(IOErrorEvent.IO_ERROR, loaderComplete);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, loaderComplete);
			loader.addEventListener(Event.COMPLETE, loaderComplete);
		}
		private function loaderComplete(e:Event):void
		{
			delegate(e.currentTarget.data);
			// The output of the text file is available via the data property
			// of URLLoader.
			//	trace(loader.data);
			//var s:String = e.t
		}
		private function onFileSelect(e:Event):void
		{
			fr.removeEventListener(Event.SELECT, onFileSelect);
			fr.removeEventListener(Event.CANCEL,onCancel);
			fr.addEventListener(Event.COMPLETE, onLoadComplete);
			fr.addEventListener(IOErrorEvent.IO_ERROR, onLoadError);
			fr.load();
		}
		private function onCancel(e:Event):void
		{
			trace("File Browse Canceled");
			fr.removeEventListener(Event.SELECT, onFileSelect);
			fr.removeEventListener(Event.CANCEL,onCancel);
			fr = null;
			if (cancel is Function) {
				cancel();
				cancel = null;
			}
		}
		/************ Select Event Handlers **************/
		private function onLoadComplete(e:Event):void
		{
			delegate(fr.data, e.currentTarget as FileReference);
		/*	try {
				delegate(fr.data, e.currentTarget as FileReference);
			} catch(error:Error) {	
				try {
					delegate(fr.data);
				} catch(error:Error) {
					trace( "FileBrowser.onLoadComplete.try: "+error.message )	
				}
			}*/
			
			fr.removeEventListener(Event.COMPLETE, onLoadComplete);
			fr.removeEventListener(IOErrorEvent.IO_ERROR, onLoadError);
			fr = null;
		}
		private function onLoadError(e:IOErrorEvent):void
		{
			dtrace("Error loading file : " + e.text);
		}
		private function onSaveError(e:IOErrorEvent):void
		{
			dtrace(e.text);
			PopUp.getInstance().construct( PopUp.wrapHeader("sys_error"), PopUp.wrapMessage("misc_file_save_impossible"), PopUp.BUTTON_OK );
			PopUp.getInstance().open();
		}
	}
}