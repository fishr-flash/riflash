package components.screens.ui
{
	import components.abstract.functions.dtrace;
	import components.abstract.servants.TaskManager;
	import components.basement.UI_BaseComponent;
	import components.gui.fields.FSSimple;
	import components.gui.fields.FormString;
	import components.gui.limits.LimitHRuler;
	import components.interfaces.ITask;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.static.CMD;
	import components.static.COLOR;
	import components.static.DS;
	import components.system.UTIL;
	
	public class UISensorTemperature extends UI_BaseComponent
	{
//		private const GRAPH_WIDTH:int = 600;
//		private const GRAPH_HEIGHT:int = 200;
//		private const LIMIT_MAX:int = 90;
//		private const LIMIT_MIN:int = 0;
		
//		private var vScreenCpu:VectorDrawScreenU;
//		private var vScreenOuter:VectorDrawScreenU;
//		private var hruler:LimitHRuler;
		private var task:ITask;
		private var speedTask:ITask;
		private var fsCpu:FSSimple;
		private var fsOuter:FSSimple;
//		private var graphxshift:Number;
//		private var graphStep:Number;
//		private var currentHour:int;
//		private var currentMinute:String;
//		private var tTemperature:SimpleTextField;
		
		private var slowScreen:VectorScreen;
		private var fastScreen:VectorScreen;
		
		public function UISensorTemperature(group:int=0)
		{
			super();
			
			toplevel = false;
			globalY += 10;
			globalFocusGroup = group;
			
			FLAG_SAVABLE = false;
			FLAG_VERTICAL_PLACEMENT = false;
			fsCpu = addui( new FSSimple, 0, "Температура процессора, текущая", null, 1 ) as FSSimple;
			attuneElement( 530, 80, FSSimple.F_CELL_NOTSELECTABLE );
			fsCpu.setColoredBorder( COLOR.GREEN );
			
			FLAG_VERTICAL_PLACEMENT = true;
			addui( new FormString, 0, "град.", null, 3 ).x = 616+30;

			if (DS.isDevice(DS.V2) ) {
				FLAG_VERTICAL_PLACEMENT = false;
				fsOuter = addui( new FSSimple, 0, "Температура внешнего датчика, текущая", null, 2 ) as FSSimple;
				attuneElement( 530, 80, FSSimple.F_CELL_NOTSELECTABLE );
				fsOuter.setColoredBorder( COLOR.RED );
				
				FLAG_VERTICAL_PLACEMENT = true;
				addui( new FormString, 0, "град.", null, 4 ).x = 616+30;
			}
			
			drawSeparator( 661+30 );
			globalY += 10;
			
			fastScreen = new VectorScreen("Внимание! Обновление графика температуры производится раз в 5 секунд", false);
			addChild( fastScreen );
			fastScreen.y = globalY;
			
			globalY += fastScreen.height;
			
			slowScreen = new VectorScreen("Внимание! Обновление графика температуры производится раз в 2 минуты");
			addChild( slowScreen );
			slowScreen.y = globalY;
			
//			addui( new FormString, 0, "Внимание! Обновление графика температуры производится раз в 2 минуты", null, 4 ).x = globalX + 60;
//			attuneElement( 600 );
//			
//			var container:LimitVContainer = new LimitVContainer([{title:"-30"},{title:"-15"},{title:"0"},{title:"15"},{title:"30"},{title:"45"},{title:"60"}].reverse(),GRAPH_WIDTH, GRAPH_HEIGHT);
//			addChild( container );
//			container.y = globalY;
//			container.x = globalX + 50;
//			container.alpha = 0.5;
//			
//			tTemperature = new SimpleTextField("Температура, град",0,COLOR.SATANIC_INVERT_GREY);
//			tTemperature.height = 30;
//			addChild( tTemperature );
//			tTemperature.y = globalY + 164;
//			tTemperature.x = 10;
//			tTemperature.rotationZ = -90;
//			
//			var gear:Object = {w:GRAPH_WIDTH, h:GRAPH_HEIGHT, max_period:300, signal_resolution:1};
//			graphStep = GRAPH_WIDTH/gear.max_period;
//			
//			vScreenCpu = new VectorDrawScreenU(COLOR.GREEN,gear);
//			addChild( vScreenCpu );
//			vScreenCpu.setup( graphStep );
//			vScreenCpu.getFunction = getYByAcpForPaint;
//			vScreenCpu.fGetGlobalXShift = getXShift;
//			vScreenCpu.x = globalX + 50;
//			vScreenCpu.y = globalY;
//			
//			if (DEVICES.getCurrentDevice() == DEVICES.V2 ) {
//				vScreenOuter = new VectorDrawScreenU(COLOR.RED,gear);
//				addChild( vScreenOuter );
//				vScreenOuter.setup( graphStep );
//				vScreenOuter.getFunction = getYByAcpForPaint;
//				vScreenOuter.fGetGlobalXShift = getXShift;
//				vScreenOuter.x = globalX + 50;
//				vScreenOuter.y = globalY;
//			}
//			
//			
//			
//			
//			
//			
//			
//			globalY += GRAPH_HEIGHT + 1;
			
//			hruler = new LimitHRuler(rename);
//			addChild( hruler );
//			hruler.y = globalY;
//			hruler.x = globalX + 50;
//			hruler.alpha = 0.5;
			
			width = 740;
			height = 670;
			
			starterCMD = CMD.GET_TEMPERATURE;
		}
		override public function open():void
		{
			super.open();
			loadComplete();
//dtrace( UTIL.getHMSTimeStampString()+ " > launch");
			task = TaskManager.callLater( onTick, TaskManager.DELAY_2MIN );
			speedTask = TaskManager.callLater( onSpeedTick, TaskManager.DELAY_1SEC*5 );
//			graphxshift = 0;
			var d:Date = new Date;
			
			fastScreen.currentHour = d.hours + 1;
			if (fastScreen.currentHour > 23)
				fastScreen.currentHour -= 24;
			fastScreen.currentMinute = UTIL.fz(d.minutesUTC,2);
			fastScreen.open();
			
			slowScreen.currentHour = d.hours + 1;
			if (slowScreen.currentHour > 23)
				slowScreen.currentHour -= 24;
			slowScreen.currentMinute = UTIL.fz(d.minutesUTC,2);
			slowScreen.open();
//			hruler.build(rename(false),GRAPH_WIDTH);
//			if (vScreenOuter)
//				vScreenOuter.clear();
//			vScreenCpu.clear();
		}
		override public function close():void
		{
			super.close();
			if (task)
				task.stop();
		}
//		override public function put(p:Package):void
//		{
//			var res:Number = comb(int(toSignedLitleEndian(p.getStructure(1))));
//			
//			if ( !isNaN(res) ) {
//				vScreenCpu.paint( res );
//				fsCpu.setCellInfo(res);
//			} else {
//				fsCpu.setCellInfo("нет данных");
//				vScreenCpu.endFill();
//			}
//			if (vScreenOuter) {
//				res = comb(int(toSignedLitleEndian(p.getStructure(2))));
//				if ( !isNaN(res) ) {
//					vScreenOuter.paint( res );
//					fsOuter.setCellInfo(res);
//				} else {
//					fsOuter.setCellInfo("нет данных");
//					vScreenOuter.endFill();
//				}
//			}
//			if (vScreenCpu.isFull())
//				hruler.move( graphStep );
//			graphxshift += graphStep;
//			
//			function comb(value:int):Number
//			{
//				if (UTIL.mod(value) == 128)
//					return NaN;
//				if(value > 90)
//					return 90;
//				if (value < -30)
//					return -30;
//				return value;
//			}
//		}
		override public function put(p:Package):void
		{
			var res:Number = comb(int(VectorScreen.toSignedLitleEndian(p.getStructure(1))));
			
			if ( !isNaN(res) ) {
				fsCpu.setCellInfo(res);
			} else {
				fsCpu.setCellInfo("нет данных");
			}
			if (fsOuter) {
				res = comb(int(VectorScreen.toSignedLitleEndian(p.getStructure(2))));
				if ( !isNaN(res) ) {
					fsOuter.setCellInfo(res);
				} else {
					fsOuter.setCellInfo("нет данных");
				}
			}
			fastScreen.put(p);
			
			function comb(value:int):Number
			{
				if (UTIL.mod(value) == 128)
					return NaN;
				if(value > 90)
					return 90;
				if (value < -30)
					return -30;
				return value;
			}
		}
		private function slowPut(p:Package):void
		{
			slowScreen.put(p);
		}
		
		private function onTick():void
		{
			if (this.visible) {
				task.repeat();
//dtrace( UTIL.getHMSTimeStampString()+ " > repeat");
				RequestAssembler.getInstance().fireEvent( new Request(CMD.GET_TEMPERATURE, slowPut));
			}
		}
		private function onSpeedTick():void
		{
			if (this.visible) {
				speedTask.repeat();
//dtrace( UTIL.getHMSTimeStampString()+ " > repeat");
				RequestAssembler.getInstance().fireEvent( new Request(CMD.GET_TEMPERATURE, put));
			}
		}
//		private function getYByAcpForPaint(rawacp:Number):Number
//		{
//			var acp:int = rawacp + 30;
//			var coef:Number = GRAPH_HEIGHT/(LIMIT_MAX-LIMIT_MIN);
//			var num:Number = GRAPH_HEIGHT - ( acp-LIMIT_MIN )*coef;
//			if (num < 0 )
//				num = 0;
//			if (num > GRAPH_HEIGHT )
//				num = GRAPH_HEIGHT;
//			return num;
//		}
//		private function getXShift():Number
//		{
//			return graphxshift;
//		}
	}
}
import components.basement.UI_BaseComponent;
import components.gui.SimpleTextField;
import components.gui.fields.FormString;
import components.gui.limits.LimitHRuler;
import components.gui.limits.LimitVContainer;
import components.gui.limits.VectorDrawScreenU;
import components.protocol.Package;
import components.static.COLOR;
import components.static.DS;
import components.system.UTIL;

class VectorScreen extends UI_BaseComponent
{
	public var currentHour:int;
	public var currentMinute:String;
	
	private var tTemperature:SimpleTextField;
	private var vScreenCpu:VectorDrawScreenU;
	private var vScreenOuter:VectorDrawScreenU;
	private var graphxshift:Number;
	private var hruler:LimitHRuler;
	
	private const GRAPH_WIDTH:int = 600;
	private const GRAPH_HEIGHT:int = 200;
	private const LIMIT_MAX:int = 90;
	private const LIMIT_MIN:int = 0;
	
	private var graphStep:Number;
	
	public function VectorScreen(title:String, timeline:Boolean=true)
	{
		addui( new FormString, 0, title, null, 4 ).x = globalX + 60;
		attuneElement( 600 );
		
		var container:LimitVContainer = new LimitVContainer([{title:"-30"},{title:"-15"},{title:"0"},{title:"15"},{title:"30"},{title:"45"},{title:"60"}].reverse(),GRAPH_WIDTH, GRAPH_HEIGHT);
		addChild( container );
		container.y = globalY;
		container.x = globalX + 50;
		container.alpha = 0.5;
		
		tTemperature = new SimpleTextField("Температура, град",0,COLOR.SATANIC_INVERT_GREY);
		tTemperature.height = 30;
		addChild( tTemperature );
		tTemperature.y = globalY + 164;
		tTemperature.x = 10;
		tTemperature.rotationZ = -90;
		
		var gear:Object = {w:GRAPH_WIDTH, h:GRAPH_HEIGHT, max_period:300, signal_resolution:1};
		graphStep = GRAPH_WIDTH/gear.max_period;
		
		vScreenCpu = new VectorDrawScreenU(COLOR.GREEN,gear);
		addChild( vScreenCpu );
		vScreenCpu.setup( graphStep );
		vScreenCpu.getFunction = getYByAcpForPaint;
		vScreenCpu.fGetGlobalXShift = getXShift;
		vScreenCpu.x = globalX + 50;
		vScreenCpu.y = globalY;
		
		if (DS.isDevice(DS.V2) ) {
			vScreenOuter = new VectorDrawScreenU(COLOR.RED,gear);
			addChild( vScreenOuter );
			vScreenOuter.setup( graphStep );
			vScreenOuter.getFunction = getYByAcpForPaint;
			vScreenOuter.fGetGlobalXShift = getXShift;
			vScreenOuter.x = globalX + 50;
			vScreenOuter.y = globalY;
		}
		
		globalY += GRAPH_HEIGHT + 1;
		
		hruler = new LimitHRuler(rename);
		addChild( hruler );
		hruler.y = globalY;
		hruler.x = globalX + 50;
		hruler.alpha = 0.5;
		hruler.visible = timeline;
		if (timeline)
			height = globalY + 50;
		else
			height = globalY;
	}
	override public function open():void
	{
		super.open();
		graphxshift = 0;
		
		hruler.build(rename(false),GRAPH_WIDTH);
		if (vScreenOuter)
			vScreenOuter.clear();
		vScreenCpu.clear();
	}
	override public function put(p:Package):void
	{
		var res:Number = comb(int(toSignedLitleEndian(p.getStructure(1))));
		
		if ( !isNaN(res) )
			vScreenCpu.paint( res );
		else
			vScreenCpu.endFill();
		if (vScreenOuter) {
			res = comb(int(toSignedLitleEndian(p.getStructure(2))));
			if ( !isNaN(res) )
				vScreenOuter.paint( res );
			else
				vScreenOuter.endFill();
		}
		if (vScreenCpu.isFull())
			hruler.move( graphStep );
		graphxshift += graphStep;
		
		function comb(value:int):Number
		{
			if (UTIL.mod(value) == 128)
				return NaN;
			if(value > 90)
				return 90;
			if (value < -30)
				return -30;
			return value;
		}
	}
	private function getYByAcpForPaint(rawacp:Number):Number
	{
		var acp:int = rawacp + 30;
		var coef:Number = GRAPH_HEIGHT/(LIMIT_MAX-LIMIT_MIN);
		var num:Number = GRAPH_HEIGHT - ( acp-LIMIT_MIN )*coef;
		if (num < 0 )
			num = 0;
		if (num > GRAPH_HEIGHT )
			num = GRAPH_HEIGHT;
		return num;
	}
	private function getXShift():Number
	{
		return graphxshift;
	}
	private function rename(increase:Boolean=true):Array
	{
		if (increase)
			currentHour = eva(currentHour);
		
		var a:Array = new Array;
		var h:int = currentHour;
		for (var i:int=0; i<6; i++) {
			a.push( {title:UTIL.fz(h,2) + ":"+currentMinute} );
			h = eva(h);
		}
		return a;
		function eva(value:int):int
		{
			var v:int = value + 2;
			if (v > 23)
				v -= 24;
			return v;
		}
	}
	public static function toSignedLitleEndian(arr:Array ):String
	{
		var need_invert:Boolean = false;
		if( (arr[ arr.length-1 ] & (0xf << 7)) > 0 )
			need_invert = true;
		
		var value:int=0;
		var len:int = arr.length;
		for(var k:int=0; k<len; ++k) {
			value |= arr[k] << k*8;
		}
		
		if (need_invert) {
			var mask:int;
			for(k=0; k<len; ++k) {
				mask |= 0xFF << 8*k
			}
			return "-"+((value ^ mask)+1);
		}
		return value.toString();
	}
}