package components.gui.triggers
{
	import flash.display.Sprite;
	
	/**
	 * Комплекс кнопок для DevConsole, сделан пока
	 * с узкой целью представить кнопки переключения 
	 * языков в качестве одной составной кнопки
	 * 
	 */
	public class CMButton extends Sprite
	{
		public function CMButton( pressCall:Function )
		{
			
			super();
			
			init( pressCall );
		}
		
		private function init(pressCall:Function):void
		{
			this.scaleX = this.scaleY = .6;
			const htmlLblIV:String = "<font color='#0' >" + "Ru" + "</font>";
			const btnLangRu:ClrMButton = new ClrMButton( "Ru", pressCall, 1, 0x9999DD  );
			btnLangRu.setHTMLLabel( htmlLblIV );
			btnLangRu.height = 20;
			
			this.addChild( btnLangRu );
			
			const htmlLblV:String = "<font color='#0' >" + "En" + "</font>";
			const btnLangEn:ClrMButton = new ClrMButton( "En", pressCall, 2, 0xfefe22  );
			btnLangEn.setHTMLLabel( htmlLblV );
			btnLangEn.height = 20;
			btnLangEn.x = -2 + btnLangRu.x + btnLangRu.width;
			this.addChild( btnLangEn );
			
			
			const htmlLblVI:String = "<font color='#0' >" + "Ita" + "</font>";
			const btnLangIt:ClrMButton = new ClrMButton( "Ita", pressCall, 3, 0x99DD99  );
			btnLangIt.setHTMLLabel( htmlLblVI );
			btnLangIt.height = 20;
			btnLangIt.x = -2 + btnLangEn.x + btnLangEn.width;
			this.addChild( btnLangIt );
			
			
			/// пустышка заполнитель места
			/*const btnLang0:ClrMButton = new ClrMButton( "I", null, 0, 0  );
			btnLang0.height = 20;
			btnLang0.x = -2 + btnLangIt.x + btnLangIt.width;
			btnLang0.visible = false;
			this.addChild( btnLang0 );*/
			
			
			
			
		}
	}
}