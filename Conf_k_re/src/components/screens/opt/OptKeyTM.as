package components.screens.opt
{
	import components.abstract.functions.loc;
	import components.basement.OptionListBlock;
	import components.gui.fields.FormString;
	import components.interfaces.IFlexListItem;
	import components.protocol.Package;
	import components.system.UTIL;
	
	public class OptKeyTM extends OptionListBlock implements IFlexListItem
	{
		private var bf:int;
		private var force:int;
		private var gbr:int;
		
		public function OptKeyTM(n:int)
		{
			super();
			
			structureID = n;
			
			/** "Команда K5_TM_KEY - для чтения и записи ключей ТМ
				Параметры 1-8 - код ключа ТМ
				Параметр 9 - битовая маска разделов, которые ставятся/снимаются этим ключом
				Параметр 10 - флаг того, что этот ключ используется для снятия ""под принуждением"" (0 - обычный, 1 - под принуждением)
				Параметр 11 - битовая маска:
				0 -бит - флаг того, что этот ключ используется для отметки группы быстрого реагирования  (0 - не ставим отметку в истории, 1 - ставим отметку CID 750.1 (используем для теста ) - прибытие группы)
				1-7биты - резерв.
				!NB: При записи ключей программа настройки должна сама отслеживать повторение кодов ключей." ( не относится к К-5 приборам )	*/
			
			FLAG_VERTICAL_PLACEMENT = false;
			
			addui( new FormString, 0, (n+300).toString(), null, 1 );
			attuneElement( 40 );
			globalX += 45;
			
			addui( new FormString, 0, "", null, 2 );
			attuneElement( 140 );
			globalX += 160;
			
			addui( new FormString, 0, "", null, 3 );
			attuneElement( 250 );
			globalX += 280;
			
			addui( new FormString, 0, "", null, 4 );
			attuneElement( 40 );
			globalX += 64+16+26;
			
			addui( new FormString, 0, "", null, 5 );
			attuneElement( 40 );
			
			drawSelection(647);
			
			
			
			width=647;
		}
		public function put(p:Package):void
		{
			var a:Array = p.getStructure(structureID);
			var s:String = "";
			for (var i:int=0; i<8; i++) {
				s += UTIL.fz(int(a[i]).toString(16),2).toUpperCase(); 
			}
			getField(0,2).setCellInfo( s );
			
			
			bf = a[8];
			s = "";
			for (i=0; i<16; i++) {
				if( (bf & (1 << i)) > 0 ) {
					if (s.length > 0)
						s += " ";
					s += i+1;
				}
			}
			getField(0,3).setCellInfo(s);
			force = a[9];
			getField(0,4).setCellInfo( (a[10] & 1) == 0 ? loc("g_yes"):loc("g_no"));
			gbr = a[10];
			getField(0,5).setCellInfo( a[9] == 1 ? loc("g_yes"):loc("g_no"));
		}
		public function change(p:Package):void
		{
		}
		public function extract():Array
		{
			return [getField(0,2).getCellInfo(),bf,force,gbr];
		}
		public function isSelected():Boolean
		{
			return selection.visible;
		}
		public function kill():void
		{
		}
		public function putRaw(value:Object):void
		{
		}
		public function set selectLine(b:Boolean):void
		{
			select( b );
		}
	}
}