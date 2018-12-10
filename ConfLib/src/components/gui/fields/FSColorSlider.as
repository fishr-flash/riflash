package components.gui.fields
{
	import components.abstract.functions.loc;
	import components.gui.fields.lowlevel.MColorSlider;
	import components.interfaces.IFocusable;

	public class FSColorSlider extends FSSlider implements IFocusable
	{
		public static const F_SLIDER_NOTEDITABLE:int = 0x01;
		public static const F_SLIDER_NONOTATION:int = 0x02;
		public static const F_SLIDER_ACCURATE:int = 0x04;
		public static const F_HIDE_VALUE:int = 0x08;
		public static const F_HIDE_MINMAX:int = 0x10;
		
		public static function generateMinMax(min:int, max:int):Array
		{
			return [{data:min, label:loc("g_min")},{data:max, label:loc("g_max")}];
		}
		
		public function FSColorSlider()
		{
			super();
		}
		override protected function createSlider():void
		{
			cell = new MColorSlider;
			
			tmin.y = 0;
			tmax.y = 0;
		}
		public function update(o:Object):void
		{
			cell.update(o);
		}
		override protected function applyParam(param:int):void
		{
			switch( param ) {
				case F_SLIDER_NOTEDITABLE:
					cell.control(false);
					break;
				case F_SLIDER_NONOTATION:
					tmin.visible = false;
					tmax.visible = false;
					tvalue.visible = false;
					break;
				case F_HIDE_MINMAX:
					tmin.visible = false;
					tmax.visible = false;
					break;
				case F_HIDE_VALUE:
					tvalue.visible = false;
					break;
				case F_SLIDER_ACCURATE:
					ACCURATE = true;
					break;
			}
		}
	}
}