package components.screens.opt
{
	import flash.display.Loader;
	import flash.events.Event;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	import components.abstract.functions.dtrace;
	import components.abstract.functions.loc;
	import components.basement.OptionsBlock;
	import components.events.GUIEventDispatcher;
	import components.events.GUIEvents;
	import components.gui.triggers.TextButton;
	import components.protocol.Package;
	import components.static.CMD;
	
	public class OptTakePhotoIpCam extends OptionsBlock
	{
		private var sizeba:int;
		private var barrSShot:ByteArray;

		private var loader:Loader;
		
		
		
		public function OptTakePhotoIpCam( strc:int )
		{
			super();
			
			init( strc );
		}
		
		private function init(strc:int):void
		{
			structureID = strc;
			operatingCMD = CMD.SEND_PHOTO_SHOT;  
			
			var txtButton:TextButton = new TextButton();
			txtButton.y = globalY;
			txtButton.x = globalX;
			this.addChild( txtButton );
			txtButton.setUp( loc( "get_photo_with_cam" ) + " " + structureID, onClick );
			
			globalY = txtButton.y + txtButton.height + 10;
			
		}
		
		override public function putData(p:Package):void 
		{
			if( !barrSShot )
			{
				const baSize:ByteArray = new ByteArray;
				baSize.writeByte( p.data.splice( 1, 1 ) );
				baSize.writeByte( p.data.splice( 0, 1 ) );
				baSize.position = 0;
				
				
				
				sizeba = baSize.readUnsignedShort();
				barrSShot = new ByteArray;
			}
			
			var len:int = p.data.length;
			for (var i:int=0; i<len; i++) 
			{
				barrSShot.writeByte( p.data[ i ][ 0 ] );	
			}
			
			
			if( barrSShot.length == sizeba )
			{
				
				generatePhoto();		
				
				
			}
			
			
		}
		
		private function generatePhoto():void
		{
			if( loader )
			{
				loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onLoadComplete );
				if( loader.parent ) loader.parent.removeChild( loader);
				loader = null;
			}
			
			barrSShot.position = 0;
			loader = new Loader;
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoadComplete );
			
			loader.loadBytes( barrSShot );
			this.addChild( loader );
			loader.x = globalX;
			loader.y = globalY;
			
		}
		
		private function onLoadComplete(event:Event):void
		{
			loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onLoadComplete );
			barrSShot.clear();
			barrSShot = null;
			manualResize();
			GUIEventDispatcher.getInstance().fireEvent(  GUIEvents, GUIEvents.RECEPTION_PHOTO_COMPLETE );
			
		}
		
		private function onClick(  ):void
		{
			GUIEventDispatcher.getInstance().dispatchEvent( new GUIEvents( GUIEvents.CLICK_GET_PHOTO_SHOT, { id:structureID } ) );
			
		}
	}
}