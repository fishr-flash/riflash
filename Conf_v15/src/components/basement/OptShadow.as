package components.basement
{
	import components.gui.fields.FSShadow;

	public class OptShadow extends ComponentRoot
	{
		private var cmds:Array;
		
		public function OptShadow(str:int)
		{
			super();
			structureID = str;
			cmds = [];
		}
		public function add(cmd:int, params:int):void
		{
			cmds.push( cmd );
			for (var i:int=0; i<params; ++i) {
				createUIElement( new FSShadow, cmd, "", null, i+1 );
			}
		}
		public function rememberCmd(cmd:int=0):void
		{
			if (cmd > 0) {
				remember( getField(cmd,1) );
			} else {
				var len:int = cmds.length;
				for (var i:int=0; i<len; ++i) {
					remember( cmds[i] );
				}
			}
		}
		public function fill(cmd:int, a:Array):void
		{
			var len:int = (a as Array).length;
			for (var i:int=0; i<len; ++i) {
				getField( cmd, i+1 ).setCellInfo( a[i] );
			}
		}
	}
}