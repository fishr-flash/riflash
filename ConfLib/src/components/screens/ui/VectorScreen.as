package components.screens.ui
{
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
	
	public class VectorScreen extends UI_BaseComponent
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
}