package components.screens.ui
{
	import flash.events.Event;
	import flash.utils.ByteArray;
	
	import components.abstract.servants.FirmwareEngine;
	import components.events.GUIEvents;
	import components.protocol.TunnelOperator;
	import components.static.DS;
	import components.static.PAGE;
	
	public class UIVUpdate extends UIUpdate
	{
		public function UIVUpdate()
		{
			super();
			
			FLAG_SAVABLE = false;
			
			globalY = PAGE.CONTENT_TOP_SHIFT;
		}
		override protected function initServant():void
		{
			fwservant = new FirmwareEngine;
			fwservant.addEventListener( GUIEvents.EVOKE_BLOCK, onFwStart );
			fwservant.addEventListener( Event.CHANGE, onFwProgress );
		}
		override protected function showVersion():void
		{
			getField(0,2).setCellInfo( DS.getStatusVersion() );
		}
		override protected function onUpload(b:ByteArray=null):void
		{
			bUpload.disabled = true;
			
			if ( b ) {
				fwservant.put( b );
				fwservant.write();
			} else {
		/*		if (ninja.fwname) {
					var str:String = JSON.stringify( {request:"firmwarefile", device:DEVICES.getDeviceAlias(), file:ninja.fwname } );
					TunnelOperator.access().request(str, onUpload, {binary:true} );
				}*/
			}
		}
	}
}