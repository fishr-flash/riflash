package components.gui.fields.lowlevel
{
	import components.static.GuiLib;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	public class MRadio extends MCheckBox
	{
		public function MRadio()
		{
			super();
		}
		override protected function construct():void
		{
			layer = new GuiLib.m_radio;
			addChild( layer );
			layer.gotoAndStop(1);
			layer.check.visible = _selected;
			
			enabled =_enabled;
		}
		override protected function mClick(ev:MouseEvent):void
		{
			selected = true;
		}
	}
}