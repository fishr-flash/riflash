package components.gui.limits
{
	import flash.display.Sprite;
	
	import components.static.COLOR;
	
	public class LimitVContainer extends Sprite // Более продвинутая версия LimitUContainer
	{
		private var markers:Vector.<Marker>;
		
		public function LimitVContainer(a:Array, w:int, h:int)
		{
			super();
			
			markers = new Vector.<Marker>;
			var len:int = a.length;
			for (var i:int=0; i<len; i++) {
				markers.push( createText( a[i].title, h/(len-1)*i, w ) );
			}
			
			build(w,h);
		}
		private function createText(title:String, ypos:int, w:int):Marker
		{
			var m:Marker = new Marker(title, w);
			addChild(m);
			m.y = ypos;
			return m;
		}
		private function build(w:int,h:int):void
		{
			this.graphics.clear();
			this.graphics.lineStyle(2,COLOR.SATANIC_INVERT_GREY,1,true);
			this.graphics.drawRect(0,0,w, h);
		}
	}
}
import flash.display.Sprite;

import components.gui.SimpleTextField;
import components.static.COLOR;

class Marker extends Sprite
{
	private var s:SimpleTextField;
	
	public function Marker(title:String, w:int)
	{
		var s:SimpleTextField = new SimpleTextField(title, 50, COLOR.SATANIC_INVERT_GREY );
		addChild( s );
		s.setSimpleFormat( "right" );
		s.height = 20;
		s.x = -60;
		s.y = -10;
		graphics.lineStyle(2,COLOR.SATANIC_INVERT_GREY);
		graphics.moveTo(0, 0);
		graphics.lineTo(w, 0);
	}
}