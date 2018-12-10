package components.screens.opt
{
	import components.basement.OptionsBlock;
	import components.gui.fields.FSComboBox;
	import components.gui.fields.FSSimple;
	import components.interfaces.IFormString;
	import components.protocol.Package;
	import components.static.CMD;
	import components.system.SavePerformer;
	
	import flash.display.Bitmap;
	
	public final class OptNotify extends OptionsBlock
	{
		private var img:Bitmap;
		
		public function OptNotify(s:int, c:Class)
		{
			super();
			
			structureID = s;
			operatingCMD = CMD.VR_NOTIFICATION;
			
			FLAG_VERTICAL_PLACEMENT = false;
			
			img = new c;
			addChild( img );
			img.y = -9;
			
			var list:Array = [{data:0,label:"отключено"},{data:1,label:"короткое нажатие 300-400мс"},{data:2,label:"длительное нажате 2сек"}]; 
			
			createUIElement( new FSComboBox, operatingCMD, "", callLogic, 1, list );
			attuneElement( NaN, 215, FSComboBox.F_COMBOBOX_NOTEDITABLE );
			getLastElement().x = 50;
			
			list = [{data:1,label:"отправка тревоги на сервер"},{data:2,label:"вызов абонента"},
				{data:3,label:"вызов абонента до снятия трубки"},{data:4,label:"отправка СМС абоненту"},{data:0,label:"отключено"}];
			createUIElement( new FSComboBox, operatingCMD, "", null, 2, list );
			attuneElement( NaN, 250, FSComboBox.F_COMBOBOX_NOTEDITABLE );
			getLastElement().x = 275;
			
			createUIElement( new FSSimple, operatingCMD, "", null, 3, null, "+0-9", 20 ).x = 535;
			attuneElement( 0, 170 );
		}
		override public function putData(p:Package):void
		{
			distribute( p.getStructure(getStructure()), operatingCMD );
			callLogic(null);
		}
		private function callLogic(t:IFormString):void
		{
			var option:int = int( getField(operatingCMD,1).getCellInfo() );
			getField(operatingCMD, 2).disabled = Boolean(option == 0);
			getField(operatingCMD, 3).disabled = Boolean(option == 0);
			if (t)
				SavePerformer.remember(getStructure(),t);
		}
	}
}