package components.screens.opt
{
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import components.basement.OptionsBlock;
	import components.gui.fields.FSComboBox;
	import components.gui.fields.FSComboBoxExt;
	import components.gui.fields.FSShadow;
	import components.gui.fields.FormEmpty;
	import components.gui.fields.FormString;
	import components.static.PAGE;
	
	public class OptWireBlock extends OptionsBlock
	{
		public static var GUIE_TEXT:int = 0x00;
		public static var GUIE_COMBOBOX:int = 0x01;
		public static var GUIE_SHADOW:int = 0x02;
		public static var GUIE_COMBOBOXEXT:int = 0x03;
		
		private var isDual:Boolean;
		private var counter:int;
		private var fieldWidth:int = 200; 
		
		public var aDual:Array;

		private var _ww:int;
		
		public function OptWireBlock( w:int, dual:Boolean=false )
		{
			super();
			aCells = new Array;
			_ww = w;
			isDual = dual;
			
			if ( isDual )
				aDual = new Array;
		}
		public function put( type:int, name:String, list:Array=null, cellWidth:int=100 ):FormEmpty
		{
			
			
			var element:FormEmpty;
			var element2:FormEmpty;
			
			if ( type == GUIE_SHADOW ) {
				element = new FSShadow;
				aCells.push( element );
				if ( isDual )
					aDual.push( new FSShadow );
				return element;
			}
			
			var tfield:TextField = new TextField;
			addChild( tfield );
			tfield.selectable = false;
			
			var textf:TextFormat = new TextFormat;
			textf.font = PAGE.MAIN_FONT;
			//textf.leading = -7;
			textf.size = 12;
			tfield.defaultTextFormat = textf;
			
			tfield.text = name;
			tfield.y = globalY;
			
			var _h:int = 35;
			
			tfield.width = _ww+170;
			
			if ( tfield.numLines > 3 ) {
				tfield.height = 50;
				_h = 50;
			} else if ( tfield.numLines > 1 )
				tfield.height = 35;
			else {
				tfield.height = 20;
				tfield.y += 7;
			}
			
			if ( !Boolean( counter & 0x01 > 0 ) ) {
				var sp:Sprite = new Sprite;
				addChildAt( sp, 0 );
				sp.graphics.beginFill( 0xeeeeee );
				sp.graphics.drawRoundRect(0,0,_ww+fieldWidth+fieldWidth-10,_h,3,3);
				sp.graphics.endFill();
				sp.y = globalY;
			}
			
			switch( type ){
				case GUIE_TEXT:
					element = new FormString;
					(element as FormString).attune( FormString.F_EDITABLE );
					
					if ( isDual ) {
						element2 = new FormString;
						(element2 as FormString).attune( FormString.F_EDITABLE );
					}
					break;
				case GUIE_COMBOBOX:
				case GUIE_COMBOBOXEXT:
					switch( type ){
						case GUIE_COMBOBOX:
							element = new FSComboBox;
							break;
						case GUIE_COMBOBOXEXT:
							element = new FSComboBoxExt;
							break;
					}
					element.setList( list );
					element.attune( FSComboBox.F_COMBOBOX_NOTEDITABLE );
					
					if ( isDual ) {
						switch( type ){
							case GUIE_COMBOBOX:
								element2 = new FSComboBox;
								break;
							case GUIE_COMBOBOXEXT:
								element2 = new FSComboBoxExt;
								break;
						}
						
						element2.attune( FSComboBox.F_COMBOBOX_NOTEDITABLE );
						(element2 as FSComboBox).setList( list );
					}
					break;
			}
			addChild( element );
			
			element.setWidth( cellWidth );
			element.y = globalY + int((_h-25)/2);
			element.x = _ww;
			
			if ( isDual ) {
				addChild( element2 );
				element2.setWidth( cellWidth );
				element2.y = globalY + int((_h-25)/2);
				element2.x = _ww + fieldWidth;
				
				aDual.push( element2 );
			}
			aCells.push( element );
			
			counter++;
			globalY += _h;
			height = globalY;
			return element;
		}
		public function finish():void
		{
			var sp:Sprite = new Sprite;
			addChildAt( sp, counter );
			sp.graphics.lineStyle( 1, 0xaaaaaa );
			sp.graphics.drawRect( _ww-10,0,fieldWidth,height-1 );
			if ( isDual )
				sp.graphics.drawRect( _ww+_ww-30,0,fieldWidth,height-1 );
		}
		public function getCells():Array
		{
			if ( aDual )
				return aCells.concat(aDual).slice();
			return aCells.slice();
		}
	}
}