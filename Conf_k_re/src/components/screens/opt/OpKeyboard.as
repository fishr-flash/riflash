package components.screens.opt
{
	import components.basement.OptionListBlock;
	import components.gui.fields.FormString;
	import components.interfaces.IFlexListItem;
	import components.interfaces.IFormString;
	import components.protocol.Package;
	import components.screens.ui.UIKeyboardK5;
	import components.static.CMD;
	
	public class OpKeyboard extends OptionListBlock implements IFlexListItem
	{
		private var validator:IFormString;
		
		public function OpKeyboard(s:int)
		{
			super();
			
			SELECTION_Y_SHIFT = -1;
			
			drawSelection(300);
			
			structureID = s;
			
			FLAG_VERTICAL_PLACEMENT = false;
			globalX = 0;
			
			FLAG_SAVABLE = false;
			addui( new FormString, 0, String(structureID), null, 1 );
			attuneElement( 40 ); 
			FLAG_SAVABLE = true;
			
			globalX += 53;
			
			validator = addui( new FormString, CMD.K5_KBD_INDEX, "", null, 1);
			attuneElement( 60, NaN, FormString.F_EDITABLE );
			UIKeyboardK5.getValidator().register(validator);
			
			globalX += 120;
			
			addui( new FormString, CMD.K5_KBD_NUMOBJ, "", null, 1, null, "0-9A-Fa-f", 4 );
			attuneElement( 60, NaN, FormString.F_EDITABLE | FormString.F_UPPERCASE );
			getLastElement().setAdapter( new KeyAdapter );
		}
		public function set selectLine(b:Boolean):void	
		{
			select( b );
		}
		override public function get height():Number
		{
			return 30;
		}
		public function kill():void
		{
			UIKeyboardK5.getValidator().unregister(validator);
		}
		public function change(p:Package):void		{		}
		public function extract():Array		{	return null	}
		public function put(p:Package):void
		{
			distribute( p.getStructure(structureID),p.cmd);
		}
		public function putRaw(value:Object):void
		{
			
		}
		public function isSelected():Boolean
		{
			return selection.visible;
		}
	}
}
import components.abstract.adapters.HexAdapter;

class KeyAdapter extends HexAdapter
{
	override public function adapt(value:Object):Object
	{
		return String(super.adapt(value)).toUpperCase();
	}
	override public function change(value:Object):Object
	{
		return String(super.change(value)).toUpperCase();
	}
}