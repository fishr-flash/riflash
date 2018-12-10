package components.screens.ui
{
	import flash.display.MovieClip;
	import flash.events.Event;
	
	import components.abstract.functions.loc;
	import components.abstract.servants.CIDServant;
	import components.basement.UI_BaseComponent;
	import components.gui.OptNavigation;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.screens.opt.OptWire;
	import components.static.CMD;
	import components.static.PAGE;
	import components.system.Library;
	import components.system.SavePerformer;
	
	public class UIWire extends UI_BaseComponent
	{
		private var opt:OptWire;
		private var lastOpened:int;
		private var klemm:MovieClip;

		public function UIWire()
		{
			super();
			
			globalX = PAGE.CONTENT_LEFT_SUBMENU_SHIFT + PAGE.CONTENT_LEFT_SHIFT;
			globalY = PAGE.CONTENT_TOP_SHIFT;
			
			opt = new OptWire;
			addChild( opt );
			opt.visible = false;
			opt.addEventListener( "ChangeState", callStateChanger );
			opt.y = globalY;
			opt.x = globalX;
			
			klemm = new Library.wire;
			addChild( klemm );
			klemm.visible = false;
			klemm.y = 420 + globalY;
			klemm.x = globalX;
			
			width = 660;
			height = 785;
			
			starterCMD = CMD.K7_ALARM_WIRE_SET;
		}
		override public function close():void
		{
			if ( !this.visible ) return;
			super.close();
			
			opt.visible = false;
			if (navi)
				navi.selection = 0;
		}
		override public function put( p:Package ):void
		{
			if ( !navi ) {
				initNavi();
				navi.setUp( openWire, 50 );
			
				var len:int = p.length;
				for(var i:int=0; i<len; ++i ) {
					navi.addButton( loc("rfd_wire")+" "+ (i+1), i+1, i*1000 );
				}
			}
			if (lastOpened == 0) 
				lastOpened = 1;
			var fake:Package = new Package;
			fake.structure = lastOpened;
			fake.data = [p.getStructure(lastOpened)];
			openWireData(fake);
			navi.selection = lastOpened;
			
			loadComplete();
		}
		private function openWire( struct:int ):void
		{
			SavePerformer.closePage();
			opt.freeze = true;
			lastOpened = struct;
			RequestAssembler.getInstance().fireEvent( new Request( CMD.K7_ALARM_WIRE_SET, openWireData, struct ));
			callLater( navi.disable, [true]);
		}
		private function openWireData(p:Package):void
		{
			klemm.visible = true;
			klemm.gotoAndStop(p.structure);
			(klemm.sensor as MovieClip).gotoAndStop( p.getStructure()[1]+1 );
			navi.disable(false);
			changeSecondLabel( loc("wire_config")+" "+ p.structure );
			opt.visible = true;
			opt.putData(p);
			opt.freeze = false;
			initSpamTimer( CMD.K7_ALARM_WIRE_GET, p.structure);
			RequestAssembler.getInstance().fireEvent( new Request( CMD.K7_ALARM_WIRE_GET, processState,p.structure));
		}
		private function callStateChanger(ev:Event):void
		{
			(klemm.sensor as MovieClip).gotoAndStop( opt.state+1 );
		}
		override protected function processState(p:Package):void 
		{
			super.processState(p);
			opt.putState(p.getStructure());
			(klemm.alarm as MovieClip).visible = Boolean( opt.state != p.getStructure()[0] );
		}
/********************************************************************
 * 		STATIC VARS & METHODS
 * ******************************************************************/
	
		public static var ZONE_TYPE_NAMES:Array = [ {label:loc("g_no").toLowerCase(), data:0}, {label:loc("zone_passing_by"), data:1},{label:loc("zone_entrance"), data:2}, 
			{label:loc("zone_24"), data:3}, {label:loc("zone_instant"), data:4} ];
	}
}