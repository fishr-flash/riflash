package components.gui
{
	import flash.filters.DropShadowFilter;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	import components.gui.fields.lowlevel.interfaces.IComboBoxItem;
	import components.interfaces.IPositioner;
	import components.static.PAGE;
	
	public class SimpleTextField extends TextField implements IPositioner, IComboBoxItem
	{
		private var textf:TextFormat;
		
		public function SimpleTextField( _text:String, _width:int=0, _color:int=0x000000 ):void
		{
			super();
			
			
			
			textf = new TextFormat;
			textf.font = PAGE.MAIN_FONT;
			
			this.defaultTextFormat = textf;
			
			this.autoSize = TextFieldAutoSize.LEFT;
			this.textColor = _color;
			
			
			this.selectable = false;
			
			this.text = _text;
			
			this.width = _width>0? _width:this.textWidth+10;
			this.wordWrap = true;
			
			
		}
		
		
		
		public function setSimpleFormat( _align:String="left", _leading:int=0, _size:int=12, _bold:Boolean=false, _font:String=PAGE.MAIN_FONT ):void {
			textf.align = _align;
			//textf.leading = _leading;
			textf.size = _size;
			textf.bold = _bold;
			textf.font = _font;
			if (this.defaultTextFormat.align != textf.align ||
				//this.defaultTextFormat.leading != textf.leading ||
				this.defaultTextFormat.size != textf.size ||
				this.defaultTextFormat.bold != textf.bold) {
				this.defaultTextFormat = textf;
				this.setTextFormat( textf );
			}
			//this.height = this.textHeight + 15;
		}
		public function addShadow(dist:Number=4,blur:Number=4, str:Number=1, angle:int=45, color:uint=0, _alpha:Number=1 ):void
		{
			var ds:DropShadowFilter = new DropShadowFilter( dist, angle, color, _alpha, blur, blur, str );
			this.filters = [ds];
		}
		public function getWidth():int
		{
			return this.width;
		}
		public function getHeight():int
		{
			return this.height;
		}
		override public function set visible(value:Boolean):void
		{
			super.visible = value;
		}
		
		public function set enabled(b:Boolean):void 	{}
		public function set data(obj:Object):void 	{}
		
		override public function set width(value:Number):void
		{	// как это ни странно, но this.textWidth необходим для адекватного высчитывания numLines 
			super.width = value;
			this.textWidth;
		}
		
		override public function set htmlText(value:String):void
		{
			super.htmlText = value;

			
		}
	}
}