package components.screens.ui
{
	import flash.geom.Point;
	
	import components.abstract.DragableLimits;
	import components.abstract.functions.loc;
	import components.abstract.servants.TaskManager;
	import components.basement.UI_BaseComponent;
	import components.gui.fields.FSSimple;
	import components.gui.fields.FormString;
	import components.interfaces.ITask;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.static.CMD;
	import components.static.COLOR;
	import components.static.DS;
	import components.system.UTIL;
	
	public class UISensorTemperatureK14 extends UI_BaseComponent
	{
		private var task:ITask;
		private var speedTask:ITask;
		private var fsCpu:FSSimple;
		private var fsOuter:FSSimple;
		
		private var slowScreen:VectorScreen;
		private var fastScreen:VectorScreen;
		
		// ACC2 guide lines
		private var dlimits:DragableLimits;
		
		public function UISensorTemperatureK14(group:int=0)
		{
			super();
			
			toplevel = false;
			globalY += 10;
			globalFocusGroup = group;
			
			FLAG_SAVABLE = false;
			FLAG_VERTICAL_PLACEMENT = false;
			fsCpu = addui( new FSSimple, 0, loc("ui_temp_cpu"), null, 1 ) as FSSimple;
			attuneElement( 530, 80, FSSimple.F_CELL_NOTSELECTABLE );
			fsCpu.setColoredBorder( COLOR.GREEN );
			
			FLAG_VERTICAL_PLACEMENT = true;
			addui( new FormString, 0, loc("measure_degree_m"), null, 3 ).x = 616+30;

			if (DS.isDevice(DS.V2) ) {
				FLAG_VERTICAL_PLACEMENT = false;
				fsOuter = addui( new FSSimple, 0, loc("ui_temp_ext_sensor"), null, 2 ) as FSSimple;
				attuneElement( 530, 80, FSSimple.F_CELL_NOTSELECTABLE );
				fsOuter.setColoredBorder( COLOR.RED );
				
				FLAG_VERTICAL_PLACEMENT = true;
				addui( new FormString, 0, loc("measure_degree_m"), null, 4 ).x = 616+30;
			}
			
			drawSeparator( 661+30 );
			globalY += 10;
			
			if (DS.isDevice(DS.ACC2)) {
				FLAG_SAVABLE = true;
				addui( new FSSimple, CMD.LIMITS_TEMP, loc("ui_acc_temp_top_limit"), null, 2 );
				attuneElement( 430 );
				(getLastElement() as FSSimple).setColoredBorder( COLOR.RED);
				addui( new FSSimple, CMD.LIMITS_TEMP, loc("ui_acc_temp_bottom_limit"), null, 1 );
				attuneElement( 430 );
				(getLastElement() as FSSimple).setColoredBorder( COLOR.BLUE );

				var p:Point = new Point(80,290-88);
				var f_toy:Function = function(n:Number):Number
				{
					return Math.round(((105-(n - p.y)*0.525)-30))*100;
				}
				var f_fromy:Function = function(n:Number):Number
				{
					return p.y + UTIL.mod(((n+30)-105)/0.525 );	
				}
				
				dlimits = new DragableLimits(this, [getField(CMD.LIMITS_TEMP,2),getField(CMD.LIMITS_TEMP,1)], p,f_toy,f_fromy, "C°" );
				FLAG_SAVABLE = false;
			}
			
			fastScreen = new VectorScreen(loc("ui_temp_update_5sec"), false);
			addChild( fastScreen );
			fastScreen.y = globalY;
			
			globalY += fastScreen.height;
			
			slowScreen = new VectorScreen(loc("ui_temp_update_2min"));
			addChild( slowScreen );
			slowScreen.y = globalY;
			
			width = 740;
			height = 670;
			
			starterCMD = [CMD.GET_TEMPERATURE];
			if (DS.isDevice(DS.ACC2))
				(starterCMD as Array).splice( 0,0, CMD.LIMITS_TEMP );
		}
		override public function open():void
		{
			super.open();
			loadComplete();
			task = TaskManager.callLater( onTick, TaskManager.DELAY_2MIN );
			speedTask = TaskManager.callLater( onSpeedTick, TaskManager.DELAY_1SEC*5 );
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
		}
		override public function close():void
		{
			super.close();
			if (task)
				task.stop();
			if (dlimits)
				dlimits.close();
		}
		override public function put(p:Package):void
		{
			switch(p.cmd) {
				case CMD.GET_TEMPERATURE:
					var res:Number = comb(int(VectorScreen.toSignedLitleEndian(p.getStructure(1))));
					
					if ( !isNaN(res) ) {
						fsCpu.setCellInfo(res);
					} else {
						fsCpu.setCellInfo(loc("g_nodata"));
					}
					if (fsOuter) {
						res = comb(int(VectorScreen.toSignedLitleEndian(p.getStructure(2))));
						if ( !isNaN(res) ) {
							fsOuter.setCellInfo(res);
						} else {
							fsOuter.setCellInfo(loc("g_nodata"));
						}
					}
					fastScreen.put(p);
					break;
				case CMD.LIMITS_TEMP:
					distribute( p.getStructure(), p.cmd );
					dlimits.init([UTIL.toSigned(int(p.getParam(1)),1),UTIL.toSigned(int(p.getParam(2)),1)]);
					break;
			}
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
				RequestAssembler.getInstance().fireEvent( new Request(CMD.GET_TEMPERATURE, slowPut));
			}
		}
		private function onSpeedTick():void
		{
			if (this.visible) {
				speedTask.repeat();
				RequestAssembler.getInstance().fireEvent( new Request(CMD.GET_TEMPERATURE, put));
			}
		}
	}
}
import components.abstract.functions.loc;
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
	private const LIMIT_MAX:int = 105;
	private const LIMIT_MIN:int = 0;
	
	private var graphStep:Number;
	
	public function VectorScreen(title:String, timeline:Boolean=true)
	{
		addui( new FormString, 0, title, null, 4 ).x = globalX + 60;
		attuneElement( 600 );
		
		var container:LimitVContainer = new LimitVContainer([{title:"-30"},{title:"-15"},{title:"0"},{title:"15"},{title:"30"},{title:"45"},{title:"60"},{title:"75"}].reverse(),GRAPH_WIDTH, GRAPH_HEIGHT);
		addChild( container );
		container.y = globalY;
		container.x = globalX + 50;
		container.alpha = 0.5;
		
		tTemperature = new SimpleTextField(loc("ui_temp_degree"),0,COLOR.SATANIC_INVERT_GREY);
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