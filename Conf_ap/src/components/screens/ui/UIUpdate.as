package components.screens.ui
{
	import flash.events.Event;
	import flash.utils.ByteArray;
	
	import mx.controls.ProgressBar;
	
	import components.abstract.GroupOperator;
	import components.abstract.functions.loc;
	import components.abstract.servants.AutoUpdateNinja;
	import components.abstract.servants.FirmwareServant;
	import components.basement.UI_BaseComponent;
	import components.events.GUIEventDispatcher;
	import components.events.GUIEvents;
	import components.events.SystemEvents;
	import components.gui.PopUp;
	import components.gui.SimpleTextField;
	import components.gui.fields.FSSimple;
	import components.gui.fields.FormString;
	import components.gui.triggers.TextButton;
	import components.gui.visual.Separator;
	import components.interfaces.IFirmwareEngine;
	import components.protocol.statics.CLIENT;
	import components.static.COLOR;
	import components.static.DS;
	import components.static.NAVI;
	import components.static.PAGE;
	
	public class UIUpdate extends UI_BaseComponent
	{
		public var firmwareInProgress:Boolean = false;
		
		protected var go:GroupOperator;
		protected var bUpload:TextButton;
		protected var ninja:AutoUpdateNinja;
		protected var fwservant:IFirmwareEngine;
		
		private var patchnotes:SimpleTextField;
		private var movedownAnchor:int;
		private var pbar:ProgressBar;
		private var ninjaAsked:Boolean=false;	// перед входом, если нинзя работает, надо подождать 500 милисекнд, а потом коннектиться в любом случае
		
		protected var tunnelOnline:String = loc("fw_no_update_for_device");
		private var tunnelOffline:String = loc("fw_unable_connect_update_srv");
		
		public function UIUpdate()
		{
			super();
			
			go = new GroupOperator;
			
			var sepw:int = 740;
			
			FLAG_SAVABLE = false;
			addui( new FormString, 0, "", null, 1 );
			attuneElement( 500 );
			go.add("nofw", getLastElement() );
			
			globalY = PAGE.CONTENT_TOP_SHIFT;
			
			addui( new FSSimple, 0, loc("service_current_device_ver")+":", null, 2 );
			attuneElement( 225, 400, FSSimple.F_CELL_NOTEDITABLE_NOTEDITBOX );
			go.add("fw", getLastElement() );
			
			go.add("fw", drawSeparator(sepw) );
			
			patchnotes = new SimpleTextField("", 400 );
			addChild( patchnotes );
			patchnotes.x = globalX + 300;
			patchnotes.y = globalY;
			patchnotes.setSimpleFormat("left");
			patchnotes.height = 60;
			//patchnotes.border = true;
			patchnotes.text = "";
			go.add("fw", patchnotes );
			
			addui( new FSSimple, 0, "Всего обновлений для прибора:", null, 5 );
			attuneElement( 225, NaN, FSSimple.F_CELL_NOTEDITABLE_NOTEDITBOX | FSSimple.F_CELL_ALIGN_LEFT);
			go.add("fw", getLastElement() );
			
			addui( new FormString, 0, "Доступна версия для обновления:", null, 3 );
			attuneElement( 300 );
			go.add("fw", getLastElement() );
			
			addui( new FormString, 0, "", null, 4 );
			(getLastElement() as FormString).setTextColor( COLOR.MENU_ITEM_BLUE );
			go.add("fw", getLastElement() );
			
			movedownAnchor = globalY;
			
			var sep:Separator = drawSeparator(sepw); 
			
			go.add("fw", sep );
			go.add("movedown", sep );
			
			bUpload = new TextButton;
			addChild( bUpload );
			bUpload.x = globalX;
			bUpload.y = globalY;
			globalY += 30;
			bUpload.setUp( "Загрузить в прибор", onUpload );
			go.add("fw", bUpload );
			go.add("movedown", bUpload );
			
			pbar = new ProgressBar;
			addChild( pbar );
			pbar.y = globalY - 40;
			pbar.x = 200;
			pbar.width = 300;
			pbar.height = 40;
			pbar.label= "";
			pbar.mode = "manual";
			pbar.maximum = 100;
			pbar.minimum = 0;
			go.add("movedown",pbar);
			
			globalY += 30;
			
			initServant();
			
			setNinja();
		}
		override public function open():void
		{
			loadComplete();
		}
		protected function setNinja():void
		{
			ninja = AutoUpdateNinja.access();
		}
		protected function initServant():void
		{
			fwservant = new FirmwareServant;
			fwservant.addEventListener( GUIEvents.EVOKE_BLOCK, onFwStart );
			fwservant.addEventListener( Event.CHANGE, onFwProgress );
		}
		protected function showVersion():void
		{
			getField(0,2).setCellInfo( DS.getFullVersion()+" "+DS.getCommit() );
		}
		protected function onUpload(b:ByteArray=null):void
		{
		}
		protected function onFwStart(e:Event):void
		{
			GUIEventDispatcher.getInstance().fireSystemEvent( SystemEvents.onBlockNavigation, {"isBlock":true} );
			pbar.setProgress( 0, 100 );
			pbar.visible = true;
			
			pbar.label= loc("fw_load_to_device");
			firmwareInProgress = true;
			CLIENT.AUTOPAGE_WHILE_WRITING = NAVI.UPDATE;
		}
		protected function onFwProgress(e:Event):void
		{
			if (fwservant.percload == 100) {
				pbar.label= loc("fw_firmware_loaded");
				firmwareInProgress = false;
				CLIENT.AUTOPAGE_WHILE_WRITING = 0;
				PopUp.getInstance().composeOfflineMessage(PopUp.wrapHeader(loc("sys_attention")), 
					PopUp.wrapMessage(loc("fw_device_updating")	+ DS.getDeviceFirmwareTime() + loc("fw_not_disable_power") ));
			} else
				pbar.label= loc("fw_load_to_device")+", "+loc("fw_left")+" "+(100-fwservant.percload)+"%";
			pbar.setProgress( fwservant.percload, 100 );
		}
	}
}