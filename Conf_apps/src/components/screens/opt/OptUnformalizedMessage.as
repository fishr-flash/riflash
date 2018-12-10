package components.screens.opt
{
	import components.abstract.RegExpCollection;
	import components.basement.OptionsBlock;
	import components.gui.fields.FSCheckBox;
	import components.gui.fields.FormString;
	import components.gui.triggers.TextButton;
	import components.interfaces.IFormString;
	
	import flash.events.Event;
	
	public class OptUnformalizedMessage extends OptionsBlock
	{
		private var bSend:TextButton;
		private var bClear:TextButton;
		private var f1:IFormString;
		private var f2:IFormString;
		private var f3:IFormString;
		private var f4:IFormString;
		
		public static const EVENT_SEND:String = "EVENT_SEND";
	
		public function OptUnformalizedMessage(num:int)
		{
			super();
			
			structureID = num;
			
			FLAG_SAVABLE = false;
			
			FLAG_VERTICAL_PLACEMENT = false;
			
			createUIElement( new FormString, 0, num.toString(), null, 1 );
			attuneElement( 30, NaN, FormString.F_NOTSELECTABLE );
			
			var shift:int = 35;
			
			createUIElement( new FormString, 0, "", null, 2, null, " A-zА-я0-9!\"№;%:?*()[],./?\\-=+*", 20 ).x = shift;
			attuneElement( 250, NaN, FormString.F_EDITABLE );
			f1 = getLastElement();
			
			shift += 280;
			
			createUIElement( new FSCheckBox, 0, "", null, 3 ).x = shift;
			attuneElement( 0 );
			f3 = getLastElement();
			shift += 50;
			createUIElement( new FSCheckBox, 0, "", null, 4 ).x = shift;
			attuneElement( 0 );
			f4 = getLastElement();
			shift += 50;
			
			createUIElement( new FormString, 0, "", null, 5, null, "0-9", 3, new RegExp( RegExpCollection.REF_1to255_OR_NOTHING) ).x = shift;
			attuneElement( 50, NaN, FormString.F_EDITABLE );
			shift += 65+40;
			f2 = getLastElement();
			
			bSend = new TextButton;
			addChild( bSend );
			bSend.setUp( "Отправить", onSend );
			bSend.x = shift;
			shift += 120;
			
			bClear = new TextButton;
			addChild( bClear );
			bClear.setUp( "Очистить", clear );
			bClear.x = shift;
			
		}
		private function onSend():void
		{
			this.dispatchEvent( new Event( EVENT_SEND ));
		}
		public function getMsg():Array
		{
			var invert:int = int(f4.getCellInfo());
			if (invert == 0)
				invert = 1;
			else
				invert = 0;
			var a:Array = [f1.getCellInfo(),int(f2.getCellInfo()),f3.getCellInfo(),invert];
			return a;
		}
		public function clear():void
		{
			f1.setCellInfo("");
			f2.setCellInfo("");
			f3.setCellInfo(0);
			f4.setCellInfo(0);
		}
	}
}