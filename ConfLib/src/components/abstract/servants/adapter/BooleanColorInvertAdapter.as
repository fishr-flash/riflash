package components.abstract.servants.adapter
{
	import components.abstract.functions.loc;
	import components.gui.fields.FSSimple;
	import components.interfaces.IDataAdapter;
	import components.interfaces.IFormString;
	import components.static.COLOR;

	public class BooleanColorInvertAdapter implements IDataAdapter
	{
		private var color:uint;
		private var label:Array;
		/** Array.strings [ good, bad, unknown (optional)]	*/
		public function BooleanColorInvertAdapter(a:Array)
		{
			label = a;
		}
		public function adapt(value:Object):Object
		{
			var n:int = int(value);
			switch(n) {
				case 0:
					color = COLOR.GREEN;
					return label[0];
				case 1:
					color = COLOR.RED;
					return label[1];
			}
			color = COLOR.BLACK;
			if (label[2])
				return label[2];
			return loc("g_unknown");
		}
		public function change(value:Object):Object
		{
			return null;
		}
		public function perform(field:IFormString):void
		{
			(field as FSSimple).setTextColor( color );
		}
		public function recover(value:Object):Object
		{
			return null;
		}
	}
}