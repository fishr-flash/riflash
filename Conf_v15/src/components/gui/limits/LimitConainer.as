package components.gui.limits
{
	import flash.display.Shape;
	import flash.display.Sprite;
	
	import components.abstract.functions.loc;
	import components.gui.SimpleTextField;
	import components.static.COLOR;
	
	public class LimitConainer extends Sprite
	{
		protected var sepHi:Shape;
		protected var sepCenter:Shape;
		protected var sepLo:Shape;
		
		protected var maxValue:SimpleTextField;
		protected var hiValue:SimpleTextField;
		protected var zeroValue:SimpleTextField;
		protected var lowValue:SimpleTextField;
		protected var minValue:SimpleTextField;
		
		protected var timeFrom:SimpleTextField;
		protected var timeTo:SimpleTextField;
		
		protected var period:int;
		private var currentTime:int;
		protected var w:int;
		protected var h:int;
		protected var label:String=loc("time_sec_3l");
		
		public function LimitConainer(_w:int, _h:int, p:int)
		{
			super();
			
			w = _w;
			h = _h;
			period = p;
			
			sepHi = new Shape;
			addChild( sepHi );
			
			sepCenter = new Shape;
			addChild( sepCenter );
			
			sepLo = new Shape;
			addChild( sepLo );
			
			maxValue = createText(0);
			hiValue = createText(Math.round(h*0.25));
			zeroValue = createText(Math.round(h*0.5));
			zeroValue.text = "0";
			lowValue = createText(Math.round(h*0.75));
			minValue = createText(h);
			
			timeFrom = createTimeText( h + 20,"right" );
			timeFrom.text = "0"+label;
			
			timeTo = createTimeText( h + 20 );
			
			distribute();
			
			timeTo.text = period+label;
		}
		public function setup(value:Object, modul:Boolean=false):void
		{
			var v:Number = Number(value);
			if (modul) {
				maxValue.text = v.toFixed(1) + "g";
				hiValue.text = (v*0.75).toFixed(1) + "g";
				zeroValue.text = (v*0.5).toFixed(1)+ "g";
				lowValue.text = (v*0.25).toFixed(1) + "g";
				minValue.text = "0";
				
			} else {
				maxValue.text = "+"+v + "g";
				hiValue.text = "+"+int(v*0.5) + "g";
				zeroValue.text = "0";
				lowValue.text = "-"+int(v*0.5) + "g";
				minValue.text = "-"+v + "g";
			}
		}
		public function updateTime(t:int):void
		{
			timeFrom.text = t+label;
			timeTo.text = (t + period)+label;
		}
		public function resize(_w:int, _h:int):void
		{
			w = _w;
			h = _h;
			maxValue.y = 0;
			hiValue.y = Math.round(h*0.25);
			zeroValue.y = Math.round(h*0.5);
			lowValue.y = Math.round(h*0.75);
			minValue.y = h;
			timeFrom.y = h + 20;
			timeTo.y = h + 20;
			distribute();
		}
		private function createText(ypos:int):SimpleTextField
		{
			var s:SimpleTextField = new SimpleTextField("", 40, COLOR.SATANIC_INVERT_GREY );
			addChild( s );
			s.setSimpleFormat( "right" );
			s.height = 20;
			s.y = ypos-10;
			s.x = -40;
			return s;
		}
		private function createTimeText(ypos:int, a:String = "left"):SimpleTextField
		{
			var s:SimpleTextField = new SimpleTextField("", 70, COLOR.SATANIC_INVERT_GREY );
			addChild( s );
			s.setSimpleFormat( a );
			s.height = 20;
			s.y = ypos-15;
			s.x = -(s.width+10);
			return s;
		}
		protected function distribute():void
		{
			this.graphics.clear();
			this.graphics.lineStyle(2,COLOR.SATANIC_INVERT_GREY,1,true);
			this.graphics.drawRoundRect(0,0,w, h, 5,5);
			
			sepHi.graphics.clear();
			sepHi.graphics.lineStyle( 2, COLOR.SATANIC_INVERT_GREY );
			sepHi.graphics.lineTo(w,0);
			sepHi.y = Math.round(h*0.25);
			
			sepCenter.graphics.clear();
			sepCenter.graphics.lineStyle( 2, COLOR.SATANIC_INVERT_GREY );
			sepCenter.graphics.lineTo(w,0);
			sepCenter.y = Math.round(h*0.5);
			
			sepLo.graphics.clear();
			sepLo.graphics.lineStyle( 2, COLOR.SATANIC_INVERT_GREY );
			sepLo.graphics.lineTo(w,0);
			sepLo.y = Math.round(h*0.75);
			
			timeTo.x = w + 10;
		}
	}
}