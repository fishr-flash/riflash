package components.screens.ui
{
	import flash.events.Event;
	import flash.utils.ByteArray;
	
	import mx.controls.ProgressBar;
	import mx.events.ListEvent;
	
	import components.abstract.GroupOperator;
	import components.abstract.functions.loc;
	import components.abstract.servants.AutoUpdateNinja;
	import components.abstract.servants.FirmwareServant;
	import components.abstract.servants.FirmwareServant_specialForV2n055;
	import components.abstract.servants.ResizeWatcher;
	import components.basement.UI_BaseComponent;
	import components.events.GUIEventDispatcher;
	import components.events.GUIEvents;
	import components.events.SystemEvents;
	import components.gui.Balloon;
	import components.gui.MFlexTable;
	import components.gui.PopUp;
	import components.gui.fields.FSSimple;
	import components.gui.fields.FormString;
	import components.gui.triggers.TextButton;
	import components.gui.visual.Separator;
	import components.interfaces.IResizeDependant;
	import components.protocol.statics.CLIENT;
	import components.static.DS;
	import components.static.NAVI;
	import components.static.PAGE;
	
	public class UIUpdate extends UI_BaseComponent implements IResizeDependant
	{
		private var ftable:MFlexTable;
		
		protected var bReconnect:TextButton;
		protected var bUpload:TextButton;
		protected var go:GroupOperator;
		protected var ninja:AutoUpdateNinja;
		protected var fwservant:FirmwareServant;
		private var pbar:ProgressBar;
		
		private var rtmpath:String;
		
		public function UIUpdate()
		{
			super();
			
			var sepw:int = 800;
			
			go = new GroupOperator;
			
			FLAG_SAVABLE = false;
			
			bReconnect = new TextButton;
			addChild( bReconnect );
			
			bReconnect.setUp( loc("fw_second_connect"), reConnect );
			bReconnect.y = globalY;
			bReconnect.x = globalX  + 700 - bReconnect.getWidth() + 18+60;
		//	go.add("fw", bReconnect );
			
			addui( new FormString, 0, loc("fw_no_update_for_device"), null, 4 );
			attuneElement( 500 );
			go.add("nofw", getLastElement() );

			globalY = PAGE.CONTENT_TOP_SHIFT;
			
			//addui( new FSSimple, 0, loc("sys_device_ver")+":", null, 1 );
			//attuneElement( 225+75+60, 400, FSSimple.F_CELL_ALIGN_RIGHT | FSSimple.F_CELL_NOTEDITABLE_NOTEDITBOX );
			addui( new FormString, 0, "", null, 1 );
			attuneElement( 500 );
			go.add("fw", getLastElement() );
			
			bUpload = new TextButton;
			addChild( bUpload );
			
			bUpload.setUp( loc("fw_start_update"), askRtm );
			bUpload.y = globalY;
			bUpload.x = globalX  + 700 - bUpload.getWidth() + 18+60;
			go.add("fw", bUpload );
			
			//addui( new FSSimple, 0, loc("fw_selected_update")+": ", null, 3 );
			//attuneElement( 245, 200, FSSimple.F_CELL_ALIGN_LEFT | FSSimple.F_CELL_NOTSELECTABLE );
			addui( new FormString, 0, loc("fw_selected_update")+": ", null, 3 );
			attuneElement( 500, FSSimple.F_CELL_ALIGN_LEFT | FSSimple.F_CELL_NOTSELECTABLE );
			go.add("fw", getLastElement() );
			
			var sep:Separator = drawSeparator(sepw); 
			go.add("fw", sep );
			
			ftable = new MFlexTable;
			addChild( ftable );
			go.add("fw", ftable );
			ftable.headers = [[loc("g_ver"),80],loc("g_desc")];
			ftable.y = globalY;
			ftable.x = globalX;
			ftable.width = 820;
			ftable.addEventListener( Event.CHANGE, onChange );
			ftable.variableRowHeight = true;
			
			pbar = new ProgressBar;
			addChild( pbar );
			pbar.y = globalY;
			pbar.x = globalX;
			pbar.width = 760;
			pbar.height = 40;
			pbar.label= "";
			pbar.mode = "manual";
			pbar.maximum = 100;
			pbar.minimum = 0;
			go.add("fwload", pbar );
			
			if( !ninja ) ninja = AutoUpdateNinja.access();
		}
		
		
		
		override public function open():void
		{
			super.open();
			
			ResizeWatcher.addDependent(this);
			
			
			
			
			if( CLIENT.AUTOPAGE_WHILE_WRITING == 0 ) {
			
				bReconnect.visible = false;
				go.show("nofw");
				if (int(DS.getBootloader()) == 0)
					getField(0,1).setCellInfo( loc("sys_device_ver")+": "+ DS.getFullVersion() );
				else
					getField(0,1).setCellInfo( loc("sys_device_ver")+": "+DS.getFullVersion() + "." + DS.getBootloader() );
				bUpload.disabled = false;
				ninja.askTableList(onGetList);
				loadComplete();
			} else {
				GUIEventDispatcher.getInstance().fireEvent( GUIEvents, GUIEvents.onNeedScreenBlock,
					null );
			}
		}
		public function localResize(w:int, h:int, real:Boolean=false):void
		{
			ftable.height = h - 170;
		}
		protected function onGetList(a:Array):void
		{
			
			
			if (a) {
				if (a.length == 0)
					
					getField(0,4).setName( loc("fw_no_update_for_device") );
				else {
					ftable.put(a);
					getField(0,3).setCellInfo( loc("fw_selected_update")+": "+a[a.length-1][2] );
					rtmpath = a[a.length-1][3];
					ResizeWatcher.doResizeMe(this);
					go.show("fw");
					ftable.resize();
				}
			} else {
				getField(0,4).setName( loc("fw_unable_connect_update_srv") );
				bReconnect.visible = true;
			}
		}
		private function onChange(e:Event):void
		{
			if (e is ListEvent) {
				rtmpath = (e as ListEvent).itemRenderer.data[1];
				getField(0,3).setCellInfo( loc("fw_selected_update")+": "+(e as ListEvent).itemRenderer.data[0] );
			}
		}
		private function askRtm():void
		{
			ninja.getRtm( rtmpath, onGetRtm );
			bUpload.disabled = true;
			ftable.visible = false;
			pbar.visible = true;
		}
		private function onGetRtm(b:ByteArray):void
		{
			if (b || true) {
				if (!fwservant) {
					createFirmwareServant();
					fwservant.addEventListener( GUIEvents.EVOKE_ERROR, onError );
					fwservant.addEventListener( GUIEvents.EVOKE_BLOCK, onFwStart );
					fwservant.addEventListener( Event.CHANGE, onFwProgress );
				}
				fwservant.put(b);
				fwservant.write();
			} else {
				getField(0,4).setName( loc("fw_file_not_found") );
				go.show("nofw");
				bReconnect.visible = true;
			}
		}
		private function onError(e:Event):void
		{
			Balloon.access().show(loc("sys_error"),loc("fw_wrong_file"));
			bUpload.disabled = false;
			ftable.visible = true;
			pbar.visible = false;
		}
		protected function createFirmwareServant():void
		{
			
			
			if( DS.isfam( DS.V2 ) && DS.release == 55 )
				fwservant = new FirmwareServant_specialForV2n055 as FirmwareServant;
			else 
				fwservant = new FirmwareServant; 
		}
		protected function onFwStart(e:Event):void
		{
			GUIEventDispatcher.getInstance().fireSystemEvent( SystemEvents.onBlockNavigation, {"isBlock":true} );
			pbar.setProgress( 0, 100 );
			pbar.visible = true;
			pbar.label= loc("fw_load_to_device");
			//firmwareInProgress = true;
			sertAutopage();
		}
		protected function sertAutopage():void
		{
			CLIENT.AUTOPAGE_WHILE_WRITING = NAVI.UPDATE;
		}
		protected function onFwProgress(e:Event):void
		{
			if (fwservant.percload == 100) {
				pbar.label= loc("fw_firmware_loaded");
				//firmwareInProgress = false;
				CLIENT.AUTOPAGE_WHILE_WRITING = 0;
					PopUp.getInstance().composeOfflineMessage(PopUp.wrapHeader(loc("sys_attention")), 
						PopUp.wrapMessage(loc("fw_device_updating")	+" "+ DS.getDeviceFirmwareTime() + loc("fw_not_disable_power") )
					);
			} else
				pbar.label= loc("fw_load_to_device")+", "+loc("fw_left")+" "+(100-fwservant.percload)+"%";
			pbar.setProgress( fwservant.percload, 100 );
		}
		private function reConnect():void
		{
			ninja.getList();
			ninja.askTableList(onGetList);
			bUpload.disabled = false;
			bReconnect.visible = false;
		}
	}
}