package components.screens.ui
{
	import com.mapquest.LatLng;
	import com.mapquest.LatLngCollection;
	import com.mapquest.tilemap.IShape;
	import com.mapquest.tilemap.TilemapComponent;
	import com.mapquest.tilemap.controls.inputdevice.MouseWheelZoomControl;
	import com.mapquest.tilemap.controls.shadymeadow.SMLargeZoomControl;
	import com.mapquest.tilemap.controls.shadymeadow.SMViewControl;
	import com.mapquest.tilemap.overlays.CircleOverlay;
	import com.mapquest.tilemap.pois.Poi;
	
	import flash.events.Event;
	import flash.text.TextFormat;
	
	import mx.controls.TextArea;
	
	import components.abstract.functions.dtrace;
	import components.abstract.functions.loc;
	import components.abstract.servants.ResizeWatcher;
	import components.abstract.servants.TaskManager;
	import components.abstract.servants.WiFiMapServant;
	import components.abstract.servants.WidgetMaster;
	import components.basement.UI_BaseComponent;
	import components.gui.Balloon;
	import components.gui.fields.FSCheckBox;
	import components.gui.fields.FSSimple;
	import components.gui.fields.FormString;
	import components.gui.triggers.TextButton;
	import components.gui.visual.Separator;
	import components.interfaces.IResizeDependant;
	import components.interfaces.ITask;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.static.CMD;
	import components.static.COLOR;
	import components.static.DS;
	import components.static.MISC;
	
	import su.fishr.utils.Dumper;
	
	public class UIMap extends UI_BaseComponent implements IResizeDependant
	{
		private var map:TilemapComponent;
		private var bUpdate:TextButton;
		private var fsShowAll:FSCheckBox;
		private var fsAutoUpdate:FSCheckBox;
		private var fsAutoUpdateDelay:FSSimple;
		private var fsSeconds:FormString;
		private var widget:WidgetLbs;
		private var output:TextArea;
		private var poiTf:TextFormat;
		private var poiNmea:Poi;
		private var poiLbsCollection:Vector.<IShape>;
		private var colorCollection:Vector.<int>;
		private var sep:Separator;
		private var task:ITask;
		private var blockTask:ITask;
		private var isFirst:Boolean;	// становится false после получения первой базовой станции, нужно для центровки карты
		private var isNmea:Boolean;		// становится true когда приходят реальные координаты от навигационного приемника
		private var wifiServant:WiFiMapServant;
		
		public function UIMap()
		{
			super();
			
			map = new TilemapComponent;
			map.key = "Fmjtd%7Cluu8216r25%2C7s%3Do5-9422hw";
			map.zoom=8;
			addChild( map );
			map.width = 500;
			
			map.height = 500;
			var myLL:LatLng = new LatLng(59.964909,30.431373);
			map.setCenter(myLL,13);
			
			map.addControl(new SMLargeZoomControl());
			map.addControl(new SMViewControl());
			map.addControl(new MouseWheelZoomControl());
			
			map.y = globalY;
			map.x = globalX;

			sep = drawSeparator();
			
			bUpdate = new TextButton;
			addChild( bUpdate );
			bUpdate.x = globalX;
			bUpdate.setUp( loc("ui_map_refresh"), onUpdate );
			
			FLAG_SAVABLE = false;
			FLAG_VERTICAL_PLACEMENT = false;
			fsShowAll = addui( new FSCheckBox, 0, loc("ui_map_show_all_stations"), onRequestLbs, 1 ) as FSCheckBox;
			attuneElement( 250, 50 );
			fsShowAll.x = globalX;
			
			fsAutoUpdate = addui( new FSCheckBox, 0, "", onAutoUpdate, 2 ) as FSCheckBox;
			attuneElement( 0 );
			fsAutoUpdate.x = 370;
			
			fsAutoUpdateDelay = addui( new FSSimple, 0, loc("ui_map_send_request_every"), onChangeDelay, 3, null, "0-9", 3, new RegExp(/([2-9]\d)|\d{3}/) ) as FSSimple;
			attuneElement( 190, 40 );
			fsAutoUpdateDelay.x = 400;
			fsAutoUpdateDelay.setCellInfo(120);
			
			fsSeconds = addui( new FormString, 0, loc("time_sec_full"), null, 4 ) as FormString;
			fsSeconds.x  = 640;
			
			if (MISC.COPY_DEBUG && MISC.DEBUG_SHOW_LBS_LOG) {
				output = new TextArea;
				addChild( output );
				output.tabFocusEnabled = false;
				output.tabEnabled = false;
				output.x = globalX + map.width + 20;
				output.y = map.y;
				output.selectable = true;
				output.editable = false;
				output.wordWrap = true;
				output.height = 500;
				output.width = 200;
				output.addEventListener( "htmlTextChanged", onScroll );
			}
			
			poiTf = new TextFormat;
			poiTf.font = "Tahoma";
			poiTf.size = 10;
			poiTf.bold = true;
			
			colorCollection = new Vector.<int>;
			colorCollection.push( COLOR.BLUE );
			colorCollection.push( COLOR.BROWN );
			colorCollection.push( COLOR.CIAN );
			colorCollection.push( COLOR.ORANGE );
			colorCollection.push( COLOR.YELLOW_SIGNAL );
			colorCollection.push( COLOR.GREEN );
			colorCollection.push( COLOR.PINK_TRACE );
			colorCollection.push( COLOR.BLACK );
			
			widget = new WidgetLbs(output, onCoords);
		}
		override public function open():void
		{
			super.open();

			blockUpdate();
			
			if (DS.isVoyager() || DS.isfam( DS.K15 ) ) {
				LOADING = true;
				onGetNmea();
			} else
				loadComplete();
			
			WidgetMaster.access().registerWidget( CMD.SEND_LBS, widget );
			
			onRequestLbs();
			
			fsAutoUpdate.setCellInfo(0);
			onAutoUpdate();
			
			//RequestAssembler.getInstance().HTTPSetUp( "http://mobile.maps.yandex.net" );
			
			//RequestAssembler.getInstance().HTTPSetUp( "http://lbs.ritm.ru" );
			RequestAssembler.getInstance().HTTPSetUp( "http://mobile.maps.yandex.net/cellid_location" );
			//RequestAssembler.getInstance().HTTPSetUp( "http://mobile.maps.yandex.net/cellid_location/?clid=1313&lac=235&cellid=1313&operatorid=1&countrycode=250&signalstrength=40&wifinetworks=BSSID:-65&app=ymetro" );
			
			ResizeWatcher.addDependent(this);
		}
		override public function close():void
		{
			super.close();
			if( task )
				task.kill();
			task = null;
			if( blockTask )
				blockTask.kill();
			blockTask = null;
		}
		override public function put(p:Package):void
		{
			if (p.cmd == CMD.GET_NMEA_RMC) {
				
				if (LOADING) {
					loadComplete();
					LOADING = false;
				}
				
				var nmea:String = p.getStructure()[0];
				if (nmea == null || nmea == "" )
					return;
				
				var nmeadata:Array = nmea.split(",");
				
				if (nmeadata[2] == "V" && !LOADING) {
					/*popup = PopUp.getInstance();
					popup.construct( PopUp.wrapHeader(LOC.loc("sys_attention")), PopUp.wrapMessage("Невозможно получить данные от навигационного приемника"), PopUp.BUTTON_OK);
					popup.open();*/
					Balloon.access().show("sys_attention","gps_unavailable");
					isNmea = false;
					return;
				}
				isNmea = true;
				
				var nlat:String = nmeadata[3];
				var latMinutesp:Number = (Number(nlat.slice(2))/60)*100;
				var latMinutes:String = String(latMinutesp).replace(".","");
				if (latMinutesp < 10)
					latMinutes = "0"+ String(latMinutesp).replace(".","");
				
				var nlon:String = nmeadata[5];
				var lonMinutesp:Number = (Number(nlon.slice(3))/60)*100;
				var lonMinutes:String = String(lonMinutesp).replace(".","");
				if (lonMinutesp < 10)
					lonMinutes = "0"+ String(lonMinutesp).replace(".","");
				
				var lat:Number = Number(nlat.slice(0,2) + "." + latMinutes);
				var lon:Number = Number(nlon.slice(0,3) + "." + lonMinutes);
				
				if ( String(nmeadata[4]).toLowerCase() == "s")
					lat *= -1;
				if ( String(nmeadata[6]).toLowerCase() == "w")
					lon *= -1;
				
				var myLL:LatLng = new LatLng(lat,lon);
				map.setCenter(myLL,13);
				initOL();
			}
		}
		public function localResize(w:int, h:int, real:Boolean=false):void
		{
			map.height = h - 100;
			map.width = w - 60;
			
			sep.y = h - 70;
			sep.width = w - (sep.x + 10);

			bUpdate.y = h - 60;
			
			fsShowAll.y = h - 35;
			fsAutoUpdate.y = h - 35;
			fsAutoUpdateDelay.y = h - 35;
			fsSeconds.y = h - 35;
			
			if (output) {
				//map.height = h - 80;
				map.width = w - 260;
				
				output.x = w - 210;
				output.height = map.height;
			}
		}
		private function onScroll(ev:Event):void
		{
			output.verticalScrollPosition= output.maxVerticalScrollPosition;
		}
		private function onAutoUpdate():void
		{
			var d:Boolean = int(fsAutoUpdate.getCellInfo()) == 0;
			fsAutoUpdateDelay.disabled = d; 
			fsSeconds.disabled = d;
			if (!d) {
				var delay:int = int(fsAutoUpdateDelay.getCellInfo());
				if (delay > 19) {
					if(!task)
						task = TaskManager.callLater( onUpdate, delay*1000 );
					else {
						task.delay = delay*1000;
						task.repeat();
					}
				}
			} else {
				if (task)
					task.kill();
				task = null;
			}
		}
		private function onChangeDelay():void
		{
			var delay:int = int(fsAutoUpdateDelay.getCellInfo());
			if (delay > 19) {
				if(!task)
					task = TaskManager.callLater( onUpdate, delay*1000 );
				else {
					task.delay = delay*1000;
					task.repeat();
				}
			}
		}
		private function onUpdate():void
		{
			startBlockTask();
			if (DS.isVoyager() || DS.isfam( DS.K15 ) )
				onGetNmea();
			onRequestLbs();
			if (task)
				task.repeat();
		}
		private function startBlockTask():void
		{
			blockUpdate( true );
			if( !blockTask )
				blockTask = TaskManager.callLater( blockUpdate, TaskManager.DELAY_30SEC );
			else {
				blockTask.delay = TaskManager.DELAY_30SEC;
				blockTask.repeat();
			}
		}
		private function blockUpdate(b:Boolean=false):void
		{
			bUpdate.disabled = b;
			fsShowAll.disabled = b;
		}
		private function onRequestLbs():void
		{
			isFirst = true;
			startBlockTask();
			
			if ( DS.isDevice(DS.V2) && DS.app == "008" && DS.release >= 32 ||
				DS.isfam(DS.K14W) ||
				DS.isDevice(DS.MR1) || DS.isDevice(DS.MT1) || DS.isDevice(DS.MS1)
			) {
				if (!wifiServant)
					wifiServant = new WiFiMapServant;
				wifiServant.requestCoords(onCoords);
			}
			
			TaskManager.callLater( blockUpdate, TaskManager.DELAY_30SEC );
			widget.reset();
			if (poiLbsCollection) {
				var len:int = poiLbsCollection.length;
				for (var i:int=0; i<len; i++) {
					map.removeShape(poiLbsCollection[i]);
				}
				poiLbsCollection = null;
			}
			if ( !(DS.isDevice(DS.MR1) || DS.isDevice(DS.MT1) || DS.isDevice(DS.MS1)) )
				RequestAssembler.getInstance().fireEvent( new Request(CMD.GET_LBS, null, 1, [1], 0, Request.PARAM_MUST_BE_LAST));
		}
		private function onGetNmea():void
		{
			RequestAssembler.getInstance().fireEvent( new Request(CMD.GET_NMEA_RMC, put));
		}
		private function addStation(lat:Number,lon:Number,latn:Number,lonn:Number,data:Object):void 
		{
			if (!poiLbsCollection)
				poiLbsCollection = new Vector.<IShape>;
			
			var latLng1:LatLng = new LatLng(lat,lon);
			
			var info:Object = widget.getLbsInfo(int(data));
			if (info || data == "wifi") {
				var p:Poi = new Poi( latLng1 );
				poiLbsCollection.push(p);
				map.addShape(p);
				
				var color:uint;
				
				if( data=="wifi" ) {
					p.setLabel("WiFi")
					p.rolloverAndInfoTitleText = "lat:"+p.latLng.lat+ " lon:"+p.latLng.lng + "\r"+
						"ssid:"+wifiServant.ssid + "\r" +
						"mac:"+wifiServant.mac;
					color = COLOR.RED;
				} else {
					p.setLabel(loc("cell_station")+ " " + String(int(data)+1),poiTf );
					p.rolloverAndInfoTitleText = "lat:"+p.latLng.lat+ " lon:"+p.latLng.lng + "\r"+
						"cellid: "+info.cellid + "\r" +
						"mcc: "+info.mcc + "\r" +
						"mnc: "+info.mnc + "\r" +
						"lac: "+info.lac;
					color = colorCollection[int(data)];
				}
				
				var latLng2:LatLng = new LatLng(latn,lonn)
				
				var shapePts:LatLngCollection = new LatLngCollection();
				shapePts.add(latLng1);
				shapePts.add(latLng2);
				var dist:Number = shapePts.arcDistance();
	
				var c:CircleOverlay = new CircleOverlay;
				c.radius = dist;
				c.shapePoints = shapePts;
				
				c.borderWidth = 2;
				c.colorAlpha = 1;
				c.fillColorAlpha = 0.2;
				c.color = color;
				c.fillColor = color;
				
				map.addShape(c);
				poiLbsCollection.push(c);
			}
		}
		private function initOL():void 
		{
			if (poiNmea)
				map.removeShape(poiNmea);
			poiNmea = new Poi(map.center);
			poiNmea.setLabel("\r"+loc("gps_coord_from_gps"),poiTf);
			poiNmea.maxInfoWindowWidth = 400;
			poiNmea.rolloverAndInfoTitleText = "lat:"+map.center.lat+ " lon:"+map.center.lng;
			map.addShape(poiNmea);
		}
		private function onCoords(s:String, data:Object):void
		{
			
			if (blockTask && blockTask.running()) {
				blockTask.delay = TaskManager.DELAY_1SEC*5;
				blockTask.repeat();
			}
			
			if (int(data) > 0 && !showAll)
				return;
			
			var re:RegExp = new RegExp("( latitude=\"-?\\d{1,2}\.\\d*\")|( longitude=\"-?\\d{1,3}\\.\\d*\")", "g" );
			var ren:RegExp = new RegExp("( nlatitude=\"-?\\d{1,2}\.\\d*\")|( nlongitude=\"-?\\d{1,3}\\.\\d*\")", "g" );
			var rec:RegExp = new RegExp("-?d{1,2}\.\\d*");
			var a:Array = s.match( re );
			
			var t:String = String(a[0]);
			var lat:Number = Number(t.slice( t.search("\"")+1, t.length-1));
			t = String(a[1]);
			var lon:Number = Number(t.slice( t.search("\"")+1, t.length-1));
			
			a = s.match( ren );
			t = String(a[0]);
			var latn:Number = Number(t.slice( t.search("\"")+1, t.length-1));
			t = String(a[1]);
			var lonn:Number = Number(t.slice( t.search("\"")+1, t.length-1));
			
			if (!isNaN(lat) && !isNaN(lon) ) {
				if (isFirst && !isNmea) {
					var myLL:LatLng = new LatLng(lat,lon);
					map.setCenter(myLL,13);
					isFirst = false;
				}
				addStation(lat,lon,latn,lonn,data)
			} else 
				dtrace("ERROR: координаты не были распарсены. Ответ от сайта:\r"+s);
		}
		private function get showAll():Boolean
		{
			if( !fsShowAll )
				return true;
			return int(fsShowAll.getCellInfo())==1;
		}
	}
}
import mx.controls.TextArea;

import components.interfaces.IWidget;
import components.protocol.Package;
import components.protocol.TunnelOperator;

import su.fishr.utils.Dumper;

class WidgetLbs implements IWidget
{
	private var ta:TextArea;
	private var msg:String = "";
	private var counter:int;
	private var collection:Array;
	private var bstations:Array;
	private var callback:Function;
	
	public function WidgetLbs(t:TextArea, f:Function)
	{
		ta = t;
		callback = f;
	}
	public function reset():void
	{
		collection = [];
		counter = 0;
	}
	public function getLbsInfo(n:int):Object
	{
		return collection[n];
	}
	public function put(p:Package):void
	{
		if (counter == 0) {
			bstations = new Array;
			msg += "----------------\r";
		}
		var len:int = p.data.length;
		var request:String;
		for (var i:int=0; i<len; i++) {
			msg += "station " +(++counter) +"\r" +
				"mcc\t\t"+p.data[i][1] +"\r" +
				"mnc\t\t"+p.data[i][2] +"\r" +
				"cellid\t\t"+p.data[i][3] +"\r" +
				"lac\t\t"+p.data[i][4] +"\r" +
				"rxl\t\t"+p.data[i][5] +"\r";
			
			//cellid=521&operatorid=01&countrycode=250&lac=eb
			collection[i] = {cellid:p.data[i][3], mcc:p.data[i][1], mnc:p.data[i][2], lac:p.data[i][4]};
			request = JSON.stringify({request:"decodelbs",lbs:p.data[i][3]+","+p.data[i][2]+","+p.data[i][1]+","+p.data[i][4]})
				
			
			TunnelOperator.access().request( request, callback, {followdata:i} )
		}
		
		if (ta)
			ta.text = msg;
	}
}
/*
class Marker
{
	private var lat:Number, lon:Number, latn:Number, lonn:Number;
	
	public function Marker(lat:Number,lon:Number,latn:Number,lonn:Number):void
	{
		this.lat = lat;
		this.lon = lon;
		this.latn = latn;
		this.lonn = lonn;
	}
	public function isClone(lat:Number,lon:Number,latn:Number,lonn:Number):Boolean
	{
		return this.lat == lat && this.lon == lon && this.latn == latn && this.lonn == lonn;
	}
}*/