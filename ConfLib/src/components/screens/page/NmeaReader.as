package components.screens.page
{
	import flash.events.Event;
	
	import mx.controls.TextArea;
	import mx.core.UIComponent;
	
	import components.abstract.functions.loc;
	import components.gui.fields.FSCheckBox;
	import components.gui.triggers.TextButton;
	import components.gui.visual.Separator;
	import components.interfaces.IServiceFrame;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.screens.ui.UIServiceLocal;
	import components.static.CMD;
	import components.static.DS;
	import components.system.UTIL;
	
	public class NmeaReader extends UIComponent implements IServiceFrame
	{
		private var button:TextButton;
		private var output:TextArea;
		private var log:String = "";
		private var sep:Separator;

		private var _btnNMEAUSB:TextButton;
		
		public function NmeaReader()
		{
			super();
			
			button = new TextButton;
			addChild(button);
			button.setUp( loc("gps_get_data"), onClick );
			button.x = 0;
			button.y = 0;
			
			if( DS.isDevice( DS.V_ASN ) )
			{
				_btnNMEAUSB = new TextButton;
				addChild(_btnNMEAUSB);
				_btnNMEAUSB.setUp( loc("on_translation_nmea_in_usb"), onTranslation );
				_btnNMEAUSB.x = button.x + button.width + 50;
				_btnNMEAUSB.y = button.y;
			}
			
			
			
			output = new TextArea;
			addChild( output );
			output.tabFocusEnabled = false;
			output.tabEnabled = false;
			output.y = 30;
			output.selectable = true;
			output.editable = false;
			output.wordWrap = true;
			output.height = 75;
			output.width = 500;
			output.addEventListener( "htmlTextChanged", onScroll );
			//output.addEventListener(TextEvent.LINK, linkHandler);
			addChild(output);
			
			sep = new Separator(UIServiceLocal.SEPARATOR_WIDTH);
			addChild( sep );
			sep.x = -20;
			sep.y = 129;
		}
		
		
		
		public function close():void		{		}
		public function init():void		{		}
		public function block(b:Boolean):void		
		{
			button.disabled = b;
		}
		public function put(p:Package):void		{		}
		
		public function getLoadSequence():Array
		{
			return null;
		}
		
		public function isLast():void
		{
			sep.visible = false;
		}
		
		override public function get height():Number
		{
			return 149;
		}
		
		private function onClick():void
		{
			add( loc("gps_get_coord")+"\r", log.length == 0 ? false:true );
			RequestAssembler.getInstance().fireEvent( new Request(CMD.GET_NMEA_RMC, onResponse));
		}
		private function add(msg:String, p:Boolean = false):void
		{
			log += (p ? "\r":"") + UTIL.getHMSTimeStampString(":") + "> " + msg;
			output.text = log;
		}
		private function onScroll(ev:Event):void
		{
			output.verticalScrollPosition= output.maxVerticalScrollPosition;
		}
		private function onResponse(p:Package):void
		{
			add( loc("gps_response_from_gps")+":\r" + p.getStructure()[0]+p.getStructure()[1]  );
		}
		
		private function onTranslation():void
		{
			
			if( _btnNMEAUSB.getName() == loc( "on_translation_nmea_in_usb" ))
			{
				_btnNMEAUSB.setName( loc( "off_translation_nmea_in_usb" ) );
				RequestAssembler.getInstance().fireEvent( new Request(CMD.VR_NMEA_ROUTING,null, 1,[ 0xFE ] ));
			}
			else
			{
				_btnNMEAUSB.setName( loc( "on_translation_nmea_in_usb" ) );
				RequestAssembler.getInstance().fireEvent( new Request(CMD.VR_NMEA_ROUTING,null, 1,[ 0 ] ));
			}
			
			
			
		}
	}
}