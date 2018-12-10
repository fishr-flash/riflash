package components.screens.ui
{
	import components.abstract.functions.loc;
	import components.basement.UI_BaseComponent;
	import components.gui.fields.FSComboBox;
	import components.gui.fields.FSShadow;
	import components.gui.triggers.TextButton;
	import components.protocol.Package;
	import components.static.CMD;
	import components.system.SavePerformer;
	import components.system.UTIL;
	
	public class UIRFSysLoRa extends UI_BaseComponent
	{

		private var bCreateSystem:TextButton;
		public function UIRFSysLoRa()
		{
			super();
			
			init();
		}
		
		private function init():void
		{
			//addui(
			var arr:Array = UTIL.getComboBoxList( [ [ 1, loc( "1" ) ], [ 2, loc( "2" ) ] ] );
			
			addui( new FSShadow, CMD.LR_RF_SYSTEM, "", null, 1 );
			
			addui( new FSComboBox, CMD.LR_RF_SYSTEM, loc("rfd_num_rf_channel"), null, 2, arr );
			attuneElement( 300, 80, FSComboBox.F_COMBOBOX_NOTEDITABLE );
			
			addui( new FSShadow, CMD.LR_RF_SYSTEM, "", null, 3 );
			
			drawSeparator();
			
			bCreateSystem = new TextButton;
			addChild( bCreateSystem );
			bCreateSystem.x = globalX;
			bCreateSystem.y = globalY;
			bCreateSystem.setUp(loc("rf_system_new"), onCreate );
			
			starterCMD = [ CMD.LR_RF_SYSTEM ];
			
		}
		
		private function onCreate():void
		{
			getField( CMD.LR_RF_SYSTEM, 2 ).disabled = false;
			bCreateSystem.disabled = true;
			
			
		}
		
		override public function put(p:Package):void
		{
			pdistribute( p );
			getField( CMD.LR_RF_SYSTEM, 2 ).disabled = true;
			bCreateSystem.disabled = false;
			loadComplete();
		}
		
		override public function open():void
		{
			super.open();
			SavePerformer.trigger( { "after": after } ); 
		}
		
		private function after():void
		{
			getField( CMD.LR_RF_SYSTEM, 2 ).disabled = true;
			bCreateSystem.disabled = false;
		}
	}
}