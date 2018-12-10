package components.gui
{
	import mx.controls.dataGridClasses.DataGridColumn;
	import mx.core.ClassFactory;
	
	import components.abstract.servants.VoyagerHistoryServant;
	import components.interfaces.IMTableAdapter;
	
	public class MHistoryTable extends MFlexTable
	{
		private var CAN_OPENED_ONCE:Boolean=false;
		
		public function MHistoryTable(ad:IMTableAdapter=null)
		{
			super(ad);
		}
		override protected function assignHeaderRenderer(c:DataGridColumn, o:Object):void
		{
			if( VoyagerHistoryServant.isCanParam(o[0]) ) {
				if( !Balloon.access().visible && !CAN_OPENED_ONCE ) {
					Balloon.access().showplain("his_can_params","his_selected_blue");
					CAN_OPENED_ONCE = true;
				}
				c.headerRenderer = new ClassFactory(CANHeader);
			} else
				c.headerRenderer = new ClassFactory(WhiteHeader);
		}
		override protected function assignItemRenderer(c:DataGridColumn):void
		{
		/*	c.itemRenderer
				= new ClassFactory(MCell);*/
		}
	}
}
import mx.controls.dataGridClasses.DataGridItemRenderer;

import components.static.COLOR;

class WhiteHeader extends DataGridItemRenderer
{
	public function WhiteHeader():void
	{
		super();
		
		setStyle('fontWeight', 'bold');
		setStyle('textAlign', 'center');
		
		background = true;
		backgroundColor = COLOR.WHITE;
		
		border = true;
		borderColor = COLOR.SIXNINE_GREY;
	}
	override public function set height(value:Number):void
	{
		super.height = value + 3;
	}
	override public function set y(value:Number):void
	{
		super.y = 0;
	}
}
class CANHeader extends DataGridItemRenderer
{
	public function CANHeader():void
	{
		super();
		
		setStyle('fontWeight', 'bold');
		setStyle('textAlign', 'center');
		
		background = true;
		backgroundColor = COLOR.NAVI_MENU_LIGHT_BLUE_BG;
		
		border = true;
		borderColor = COLOR.SIXNINE_GREY;
	}
	override public function set height(value:Number):void
	{
		super.height = value + 3;
	}
	override public function set y(value:Number):void
	{
		super.y = 0;
	}
}