package components.gui.limits
{
	import flash.display.Shape;
	import flash.display.Sprite;
	
	import components.gui.SimpleTextField;
	import components.static.COLOR;

	public class LimitHRuler extends Sprite	// Горизонтальная движущаяся линейка для графика
	{
		private var markers:Vector.<Marker>;
		private var markerDistance:Number;
		private var cmask:Shape;
		private var fRename:Function;
		
		public function LimitHRuler(rename:Function)
		{
			super();
			
			this.fRename = rename;
			
			cmask = new Shape;
			addChild( cmask );
		}
		public function build(a:Array, totalw:int):void
		{
			var len:int, i:int=0;
			if (markers) {
				len = markers.length;
				for ( i=0; i<len; i++) {
					removeChild( markers[i] );
				}
				markers = null;
			}
			markers = new Vector.<Marker>;
			len = a.length-1;
			markerDistance = totalw/len;
			for ( i=0; i<len; i++) {
				markers.push( createText( a[i].title, totalw/len*i+markerDistance/2 ) );
			}
			markers.push( createText( "", totalw/len*i+markerDistance/2 ) );
			
			cmask.graphics.clear();
			cmask.graphics.beginFill( COLOR.BLUE, 0.1 );
			cmask.graphics.drawRect( 0,0, totalw, 50 );
			mask = cmask;
		}
		public function move(shift:Number):void
		{
			var len:int = markers.length;
			for (var i:int=0; i<len; i++) {
				markers[i].x -= shift;
			}
			if (markers[0].x < -25) {
				
				var a:Array = fRename();
				for ( i=0; i<len; i++) {
					markers[i].x += markerDistance;
					markers[i].title = a[i].title;
				}
			}
		}
		private function createText(title:String, xpos:int):Marker
		{
			var m:Marker = new Marker(title);
			addChild(m);
			m.x = xpos;
			return m;
		}
	}
}
import flash.display.Sprite;

import components.gui.SimpleTextField;
import components.static.COLOR;

class Marker extends Sprite
{
	private var text:SimpleTextField;
	
	public function Marker(title:String)
	{
		text = new SimpleTextField(title, 50, COLOR.SATANIC_INVERT_GREY );
		addChild( text );
		text.setSimpleFormat( "center" );
		text.height = 20;
		text.x = -25;
		text.y = 10;
		graphics.lineStyle(2,COLOR.SATANIC_INVERT_GREY);
		graphics.moveTo(0, 10);
		graphics.lineTo(0, 0);
	}
	public function set title(s:String):void
	{
		text.text = s;
	}
}