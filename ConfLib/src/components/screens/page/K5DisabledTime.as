package components.screens.page
{
	import mx.core.UIComponent;
	
	import components.abstract.RegExpCollection;
	import components.abstract.functions.loc;
	import components.gui.fields.FormString;
	import components.gui.triggers.TextButton;
	import components.gui.visual.Separator;
	import components.interfaces.IServiceFrame;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.screens.ui.UIServiceLocal;
	import components.static.CMD;
	
	public class K5DisabledTime extends UIComponent implements IServiceFrame
	{
		private var b:TextButton;
		private var f:FormString;
		private var sep:Separator;
		
		public function K5DisabledTime()
		{
			super();

			var fs:FormString = new FormString;
			addChild( fs );
			fs.attune( FormString.F_MULTYLINE );
			fs.setName( loc("service_klan_disable_time") );
			fs.setWidth( 400 );
			fs.y = 22;
			
			f = new FormString;
			addChild( f );
			f.setWidth( 71 );
			f.restrict( "0-9",3 );
			f.rule = new RegExp( RegExpCollection.REF_1to255);
			f.attune( FormString.F_EDITABLE | FormString.F_ALIGN_CENTER );
			f.x = 420;

			b = new TextButton;
			addChild( b );
			b.setUp(loc("g_disable"), onClick );
			b.x = 418;
			b.y = 30;
			
			sep = new Separator(UIServiceLocal.SEPARATOR_WIDTH);
			addChild( sep );
			sep.x = -20;
			sep.y = 80;
		}
		
		public function init():void
		{
			f.setCellInfo( 15 );
		}
		
		public function block(b:Boolean):void
		{
		}
		
		public function getLoadSequence():Array
		{
			return null;
		}
		
		public function isLast():void
		{
			sep.visible = false;
		}
		private function onClick():void
		{
			if (f.valid)
				RequestAssembler.getInstance().fireEvent( new Request(CMD.LAN_SERVDIS_TIME, null, 1, [int(f.getCellInfo())]) );
		}
		
		public function close():void
		{
			 
		}
		
		override public function get height():Number
		{
			return sep.y+26;
		}
		public function put(p:Package):void
		{
		}
	}
}