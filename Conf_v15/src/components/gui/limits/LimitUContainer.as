package components.gui.limits
{
	import components.abstract.functions.loc;
	import components.static.COLOR;

	public final class LimitUContainer extends LimitConainer
	{
		public function LimitUContainer(_w:int, _h:int, p:int)
		{
			super(_w, _h, p);
			
			label = loc("g_minutes_3l");
			
			timeFrom.setSimpleFormat( "left");
			timeFrom.x = 0; 
			timeTo.setSimpleFormat("right");
			
			timeFrom.text = "";//"0"+label;
			timeTo.text = "";//period+label;
		}
		override public function setup(value:Object, modul:Boolean=false):void
		{
			var a:Array = value as Array;
			
			maxValue.text = a[4];
			hiValue.text = a[3];
			zeroValue.text = a[2];
			lowValue.text = a[1];
			minValue.text = a[0];
		}
		override protected function distribute():void
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
			
			timeTo.x = w - timeTo.width;
		}
	}
}