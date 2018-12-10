package components.gui.fields
{
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import components.abstract.functions.loc;
	import components.interfaces.IFormString;
	import components.static.COLOR;

	public class FSBitwise extends FormEmpty implements IFormString
	{
		private const MIN_SIZE:int = 23;
		
		private var tName:TextField;
		private var cell:TextField;
		private var textFormat:TextFormat;
		private var condition:Array;
		
		public static const F_HTML_TEXT:int = 0x01;
		public static const F_MULTYLINE:int = 0x02;
		public static const F_CELL_ALIGN_LEFT:int = 0x04;
		public static const F_CELL_ALIGN_RIGHT:int = 0x08;
		
		private var IS_HTML_TEXT:Boolean = false;
		
		public function FSBitwise()
		{
			super();
			construct();
		}
		private function construct():void {
			tName = new TextField;
			addChild( tName );
			tName.border = false;
			tName.selectable = false;
			tName.height = 20;
			tName.width = 195;
			//	tName.border  =true;
			tName.backgroundColor = 0xffcccc;
			textFormat = new TextFormat;
			textFormat.font = "Verdana";
			
			tName.defaultTextFormat = textFormat;
			
			cell = new TextField;
			addChild( cell );
			cell.x = 200;
			cell.selectable = false;
			cell.height = 20;
			cell.maxChars = 20;
			
			var cellTextFormat:TextFormat = new TextFormat;
			cellTextFormat.font = "Verdana";
			cellTextFormat.align = "center"
			
			cell.defaultTextFormat = cellTextFormat;
		}
		override public function setList(_arr:Array, _selectedIndex:int=-1):void
		{
			condition = _arr;
		}
		override public function setName( _name:String ):void 
		{
			if (IS_HTML_TEXT)
				tName.htmlText = _name;	
			else
				tName.text = _name;
			
			if ( tName.multiline ) {
				tName.height = tName.textHeight + 10;
				if (tName.height < MIN_SIZE)
					tName.height = MIN_SIZE;
				tName.y = -int((tName.height - 22)/2);
			}
		}
		override public function getName():String 
		{
			return tName.text;
		}
		override public function setCellInfo( value:Object ):void 
		{
			switch (value) {
				case 0:
					if (condition[0]) {
						cell.text = condition[0].label;
						if ( condition[0].color is int )
							cell.textColor = condition[0].color;
						else
							cell.textColor = COLOR.RED;
					}
					break;
				case 1:
					if (condition[1]) {
						cell.text = condition[1].label;
						if ( condition[1].color is int )
							cell.textColor = condition[1].color;
						else
							cell.textColor = COLOR.GREEN;
					}
					break;
				default:
					if ( condition[2] && condition[2].label is String )
						cell.text = condition[2].label;
					else
						cell.text = loc("g_incorrect_value");
					
					if ( condition[2] && condition[2].color is int )
						cell.textColor = condition[0].color;
					else
						cell.textColor = COLOR.BLACK;
					break;					
			}
		}
		override public function getWidth():int 
		{
			return cell.x + cell.width;
		}
		override public function setWidth( _num:int ):void 
		{
			tName.width = _num;
		}
		override public function get width():Number
		{
			return cell.x + cell.width;
		}
		public function setHeight( _num:int ):void 
		{
			tName.height = _num;
		}
		override public function getHeight():int 
		{
			if (tName.height < MIN_SIZE)
				return MIN_SIZE;
			return tName.height;
		}
		override protected function applyParam(param:int):void
		{
			var cellTextFormat:TextFormat;
			switch( param ) {
				case F_HTML_TEXT:
					IS_HTML_TEXT = true;
					break;
				case F_MULTYLINE:
					tName.multiline = true;
					tName.setTextFormat( textFormat );
					tName.defaultTextFormat = textFormat;
					tName.height = tName.textHeight+5;
					tName.y = -int((tName.height - 22)/2);
					break;
				case F_CELL_ALIGN_LEFT:
					cellTextFormat = new TextFormat;
					cellTextFormat.font = "Verdana";
					cellTextFormat.align = "left"
					
					cell.setTextFormat( cellTextFormat );
					cell.defaultTextFormat = cellTextFormat;
					break;
				case F_CELL_ALIGN_RIGHT:
					cellTextFormat = new TextFormat;
					cellTextFormat.font = "Verdana";
					cellTextFormat.align = "right"
					
					cell.setTextFormat( cellTextFormat );
					cell.defaultTextFormat = cellTextFormat;
					break;
			}
		}
	}
}