package components.screens.page
{
	import flash.events.Event;
	
	import components.abstract.functions.dtrace;
	import components.abstract.functions.loc;
	import components.events.GUIEventDispatcher;
	import components.events.GUIEvents;
	import components.events.SystemEvents;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.protocol.statics.CLIENT;
	import components.protocol.statics.CRC32;

	public class FirmwareReader extends FirmWareSimpleLoader
	{
		private var firmwarecopy:Array;
		private var validCRC:Array;
		
		public function FirmwareReader()
		{
			super();
		}
		
		override protected function writeToDevice():void
		{
			this.dispatchEvent( new Event( GUIEvents.EVOKE_BLOCK));
			
			GUIEventDispatcher.getInstance().fireSystemEvent( SystemEvents.onBlockNavigation, {"isBlock":true} );
			CLIENT.IS_WRITING_FIRMWARE = true;
			
			bWriteUpdateToDevice.disabled = true;
			//tFileName.text = "";
			bLoalUpdateFromFile.disabled = true;
			bCancelUpdate.visible = true;
			errorHappens = false;
			
			//	trace( UTIL.showByteArray( firmware ));
			
			firmwarecopy = new Array;
			badstructs = null;
			
			progress = 0;
			var crc32:uint = 0;
			if ( firmware ) {
				var i:int;
				var len:int;
				var structCounter:int=1;
				var byte:int;
				firmware.position = 0;
				var aFullFirmWare:Array = new Array;
				while( firmware.bytesAvailable > 0 ) {
					var arr:Array = new Array;
					arr.push( new Array );
					var sCounter:int=0;
					var sNum:int=0;
					
					for( i=0; i < 128; ++i, ++sCounter ) {
						if ( sCounter == 32 ) {
							sCounter = 0;
							sNum++;
							arr.push( new Array );
						}
						
						if ( firmware.bytesAvailable > 0 ) {
							
							byte = firmware.readUnsignedByte();
							arr[sNum].push( byte );
							aFullFirmWare.push( byte );
						} else {
							arr[sNum].push( 0xFF );
							aFullFirmWare.push( 0xFF );
						}
					}
					if ( errorHappens ) return; 
					
					firmwarecopy[structCounter] = arr;
					//RequestAssembler.getInstance().fireEvent( new Request( CMD_PART, writeToDeviceProgress, structCounter, arr, Request.URGENT, Request.PARAM_SAVE, ADDRESS ));
					RequestAssembler.getInstance().fireEvent( new Request( CMD_PART, writeToDeviceProgress, structCounter, null, Request.URGENT, Request.PARAM_SAVE, ADDRESS ));
					structCounter++;
				}
				crc32 = CRC32.calculate( aFullFirmWare, aFullFirmWare.length );
				
				validCRC = [crc32, aFullFirmWare.length];
				
				RequestAssembler.getInstance().fireEvent( new Request( CMD_CRC, onCrc, 1, null, Request.URGENT, Request.PARAM_SAVE, ADDRESS ));
				RequestAssembler.getInstance().fireEvent( new Request( CMD_WRITE, firmwareSent, 1, null, Request.URGENT, Request.PARAM_SAVE, ADDRESS ));
				
				progressTotal = Math.ceil(aFullFirmWare.length/128);
				
				pBar.setProgress( 0, progressTotal );
				label = loc("fw_loaded")+"0%";
				pBar.visible = true;
				
				GUIEventDispatcher.getInstance().addEventListener( SystemEvents.onChangeOnline, monitorOnlineStatus );
				heightChanged();
			}
		}
		
		private var hcrc:String;
		
		private function onCrc(p:Package):void
		{
			hcrc = "";
			
			if ( p.getStructure()[0] != validCRC[0] )
				hcrc = loc("service_incorect_crc1")+" 0x"+uint(p.getStructure()[0]).toString(16)+loc("service_incorect_crc2")+" 0x"+uint(validCRC[0]).toString(16)+"\t";
			if (p.getStructure()[1] != validCRC[1] )
				hcrc += loc("service_incorrect_fwlength1")+" "+p.getStructure()[1]+loc("service_incorrect_fwlength2")+" "+validCRC[1];
		}
		
		private var badstructs:Object;
		override protected function writeToDeviceProgress( p:Package):void
		{
			if (CLIENT.IS_WRITING_FIRMWARE) {
				var error:Boolean=false;
				var len:int = p.data[0].length;
				for (var i:int=0; i<len; i++) {
					for (var j:int=0; j<32; j++) {
						try {
							if( firmwarecopy[p.structure][i][j] != p.data[0][i][j] ) {
								if( !badstructs )
									badstructs = {};
								badstructs[p.structure] = true;
							}
						} catch(e:Error) {
							error = true;
						}
						if (error)
							break;
					}
				}
				if (error) {
					cancelWrite();
					label = loc("service_loaded_fw_mismatch");
				} else {
					progress++;
					pBar.setProgress( progress, progressTotal );
					label = loc("fw_loaded")+" " +int((progress*100) / progressTotal) + "%";
				}
			}
		}
		override protected function firmwareSent(p:Package):void
		{
			var history:String;
			if (badstructs) {
				history = loc("service_mismatching_structures")+": ";
				for( var key:String in badstructs) {
					history += key + ", "; 
				}
			} else {
				history = loc("service_fw_match")+",";
			}
			label = history+ "\t" +hcrc + "\t" +" bootWrite: 0x" +int(p.getStructure()[0]).toString(16);//getLabel(LABEL_UPDATE_COMPLETE);
			dtrace( history+ "\t" +hcrc + "\t" +" bootWrite: 0x" + int(p.getStructure()[0]).toString(16) );
			
			bCancelUpdate.visible = false;
			heightChanged();
			
			CLIENT.IS_WRITING_FIRMWARE = false;
			GUIEventDispatcher.getInstance().fireSystemEvent( SystemEvents.onBlockNavigation, {"isBlock":false} );
			bWriteUpdateToDevice.disabled = false;
			bLoalUpdateFromFile.disabled = false;
			bCancelUpdate.visible = false;
			this.dispatchEvent( new Event( GUIEvents.EVOKE_FREE));
		}
		override protected function getLabel(key:int):String
		{
			switch(key) {
				case LABEL_LOAD_FROM_FILE:
					return loc("service_load_update_from_file");
				case LABEL_DO_UPDATE:
					return loc("service_read_and_compare_fw");
				case LABEL_UPDATE_COMPLETE:
					return loc("service_read_fw_complete")+", ";
				case LABEL_DO_UPDATE:
					return loc("fw_loaded_wrong");
				case LABEL_CANCEL_UPLOAD:
					return loc("service_cancel_read_update");
			}
			return "-"
		}
	}
}