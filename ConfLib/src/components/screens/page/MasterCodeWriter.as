package components.screens.page
{
	import components.abstract.functions.loc;
	import components.basement.UI_BaseComponent;
	import components.gui.fields.FSSimple;
	import components.gui.visual.Separator;
	import components.interfaces.IServiceFrame;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.screens.ui.UIServiceLocal;
	import components.static.CMD;
	import components.static.DS;
	
	public class MasterCodeWriter extends UI_BaseComponent implements IServiceFrame
	{
		private var field:FSSimple;
		private var sep:Separator;
		private var cmd:int;
		
		public function MasterCodeWriter()
		{
			super();
			
			globalY = 0;
			globalX = 0;
			
			cmd = CMD.VR_MASTER_KEY;
			if ( DS.isRFM )
				cmd = CMD.CTRL_MASTER_CODE;
			
			field = addui( new FSSimple, cmd, loc("g_mastercode"),null,1,null,"",4, new RegExp("^((\\w|\\d){4,4})$")) as FSSimple;
			
			sep = new Separator(UIServiceLocal.SEPARATOR_WIDTH);
			addChild( sep );
			sep.x = -20;
			sep.y = 38;
		}
		private function onChange():void
		{
		}
		public function block(b:Boolean):void
		{
			field.disabled = b;
		}
		override public function get height():Number
		{
			return 50;
		}
		public function getLoadSequence():Array
		{
			return null;
		}
		public function init():void	
		{
			RequestAssembler.getInstance().fireEvent( new Request(cmd, put));
		}
		override public function put(p:Package):void
		{
			distribute(p.getStructure(),p.cmd);
		}
		public function isLast():void
		{
			sep.visible = false;
		}
	}
}