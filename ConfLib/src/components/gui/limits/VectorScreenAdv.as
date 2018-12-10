package components.gui.limits
{
	import components.basement.UI_BaseComponent;
	import components.gui.SimpleTextField;
	import components.gui.fields.FormString;
	import components.protocol.Package;
	import components.static.COLOR;
	import components.system.UTIL;
	
	public class VectorScreenAdv extends UI_BaseComponent
	{
		public var currentHour:int;
		public var currentMinute:String;
		
		private var tTemperature:SimpleTextField;
		private var vScreen:VectorDrawScreenU;
		private var graphxshift:Number;
		private var hruler:LimitHRuler;
		private var fInputFormatter:Function;
		
		private const GRAPH_WIDTH:int = 600;
		private const GRAPH_HEIGHT:int = 200;
		private const LIMIT_MAX:int = 105;
		private const LIMIT_MIN:int = 0;
		
		private var graphStep:Number;
		
		public function VectorScreenAdv(title:String, limits:Array, lefttitle:String, timeline:Boolean=true, functs:Object=null)
		{
			addui( new FormString, 0, title, null, 4 ).x = globalX + 60;
			attuneElement( 600 );
			
			if (functs && functs.input is Function)
				fInputFormatter = functs.input; 
			
			var container:LimitVContainer = new LimitVContainer(limits.reverse(),GRAPH_WIDTH, GRAPH_HEIGHT);
			addChild( container );
			container.y = globalY;
			container.x = globalX + 50;
			container.alpha = 0.5;
			
			if (lefttitle is String) {
				tTemperature = new SimpleTextField(lefttitle,0,COLOR.SATANIC_INVERT_GREY);
				tTemperature.height = 30;
				addChild( tTemperature );
				tTemperature.y = globalY + 164;
				tTemperature.x = 10;
				tTemperature.rotationZ = -90;
			}
			
			var gear:Object = {w:GRAPH_WIDTH, h:GRAPH_HEIGHT, max_period:300, signal_resolution:1};
			graphStep = GRAPH_WIDTH/gear.max_period;
			
			vScreen = new VectorDrawScreenU(COLOR.GREEN,gear);
			addChild( vScreen );
			vScreen.setup( graphStep );
			if (functs && functs.paint is Function)
				vScreen.getFunction = functs.paint;
			else
				vScreen.getFunction = getYByAcpForPaint;
			/*if (functs && functs.xshift is Function)
				vScreen.fGetGlobalXShift = functs.xshift;
			else
				vScreen.fGetGlobalXShift = getXShift;*/
			vScreen.fGetGlobalXShift = getXShift;
			vScreen.x = globalX + 50;
			vScreen.y = globalY;
			
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
			vScreen.clear();
		}
		override public function put(p:Package):void
		{
			var res:Number;
			if (fInputFormatter is Function)
				res = fInputFormatter(p);
			else
				res = comb(int(toSignedLitleEndian(p.getStructure(1))));
			
			if ( !isNaN(res) )
				vScreen.paint( res );
			else
				vScreen.endFill();
			if (vScreen.isFull())
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
			var acp:int = rawacp;
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