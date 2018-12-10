package components.abstract.servants
{
	import components.interfaces.ITask;
	import components.interfaces.IWidget;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.protocol.TunnelOperator;
	import components.static.CMD;
	import components.static.DS;
	import components.system.UTIL;

	public class WiFiMapServant implements IWidget
	{
		public var mac:String;
		public var ssid:String;
		
		private var nets:Array;
		private var task:ITask;
		private var delegate:Function;
		
		public function WiFiMapServant()
		{
		}
		public function get active():Boolean
		{
			if (DS.isVgr && DS.app == "008") {
				return true;
			}
			return false;
		}
		public function requestCoords(f:Function):void
		{
			
			killtask();
			delegate = f;
			nets = [];
			WidgetMaster.access().registerWidget( CMD.ESP_NET_LIST, this );
			RequestAssembler.getInstance().fireEvent(new Request(CMD.ESP_GET_NET_LIST, null, 1, [1], 0, Request.PARAM_MUST_BE_LAST));
		}
		public function put(p:Package):void
		{
			nets.push( {mac:p.getParam(3),signal:UTIL.toSigned(int(p.getParam(6)),1),ssid:p.getParam(4) } );
			if (!task)
				task = TaskManager.callLater(unregister, TaskManager.DELAY_3SEC);
			else
				task.repeat();
		}
		private function unregister():void
		{
			if (nets && nets.length > 0) {
				nets.sortOn("signal", Array.NUMERIC );
				nets = nets.reverse();
				mac = nets[0].mac;
				ssid = nets[0].ssid;
				var yamac:String = (nets[0].mac as String).replace(/:/g,"");
				var signal:String = nets[0].signal;
				///ntes.
				var request:String = JSON.stringify({request:"decodewifi",lbs:yamac +":"+signal})
				TunnelOperator.access().request( request, delegate, {followdata:"wifi"} )
			}
			WidgetMaster.access().unregisterWidget( CMD.ESP_NET_LIST );
			killtask();
		}
	/*	private function onCoords(s:String, data:Object):void
		{
			var re:RegExp = new RegExp("( latitude=\"-?\\d{1,2}\.\\d*\")|( longitude=\"-?\\d{1,3}\\.\\d*\")", "g" );
			var ren:RegExp = new RegExp("( nlatitude=\"-?\\d{1,2}\.\\d*\")|( nlongitude=\"-?\\d{1,3}\\.\\d*\")", "g" );
			
			var a:Array = s.match( re );
			var t:String = String(a[0]);
			
			var a1:Array = s.match( ren );
			var t1:String = String(a[0]);
			
			trace("WiFiServant got wifi from yandex");

			delegate(s,data);
		}*/
		private function killtask():void
		{
			if (task)
				task.kill();
			task = null;
		}
	}
}