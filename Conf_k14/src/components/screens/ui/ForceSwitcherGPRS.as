package components.screens.ui
{
	import flash.display.DisplayObject;
	
	import components.abstract.functions.loc;
	import components.basement.UI_BaseComponent;
	import components.gui.fields.FormString;
	import components.gui.triggers.TextButton;
	import components.gui.visual.Separator;
	import components.interfaces.IServiceFrame;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.static.CMD;
	
	public class ForceSwitcherGPRS extends UI_BaseComponent implements IServiceFrame
	{

		private var widthWith:int;

		private var sep:Separator;
		public function ForceSwitcherGPRS( widthScreen:int = 700 )
		{
			super();
		
			widthWith = widthScreen;
			
			addui( new FormString, 0, loc( "forcibly_switches_gprs" ) + ' \r "' +  loc( "ui_linkch_gprs_sim2_offline_contactId") + '" ', null, 1 );
			attuneElement( widthWith );
			const btn:TextButton = new TextButton();
			btn.setUp( loc( "g_runcmd" ), onClick, 1 );
			btn.y = ( getField( 0, 1 ) as DisplayObject ).y;
			btn.x = 600;
			this.addChild( btn );
			
		}
		
		public function init():void
		{
		
			
			
		}
		
		private function onClick( idNum:int ):void
		{
			RequestAssembler.getInstance().fireEvent( new Request( CMD.CH_COM_GOTO_GPRS_OFFLINE_WHILE, put, 1, [ 15 ] ) );
		}		
		
		public function block(b:Boolean):void {}
		public function getLoadSequence( ):Array { return null; }
		public function isLast():void { if( sep ) sep.visible = false; }
	}
}