package components.screens.ui
{
	import components.abstract.functions.loc;
	import components.basement.UI_BaseComponent;
	import components.gui.PopUp;
	import components.gui.fields.FSComboBox;
	import components.gui.fields.FormString;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.static.CMD;
	import components.static.COLOR;
	import components.static.DS;
	
	public class UICanIrma extends UI_BaseComponent
	{
		private static const PAGE_EMPTY:int = 0;
		private static const PAGE_CAR:int = 1;
		private static const PAGE_MATRIX:int = 2;
		
		private var ui:UI_BaseComponent;
		private var _oldValue:int;

		private var preload:Boolean;

		
		
		public function UICanIrma()
		{
			super();
			
			init();
		}
		
		private function init():void
		{
			const widthCell:int = 200;
			const widthField:int = 350;
			
			popup = PopUp.getInstance();
			
			const list:Array =
			[
				{ label:loc( "notify_disabled" ), data: 0 },
				{ label:loc( "slave_car" ), data: 1 }
				
			];
			
			if( DS.release != 55 && DS.release != 56 )list.push( { label:loc( "sensore_matrix" ), data: 2 } ); 
			
			FLAG_SAVABLE = false;
			
			addui(  new FSComboBox, CMD.CAN_FUNCT_SELECT, loc( "output_purpose" ), onChangeOpt, 1, list );
			attuneElement( widthCell, widthField, FSComboBox.F_COMBOBOX_NOTEDITABLE );
			
			
			addui( new FormString, 0, loc("select_cantype_warn" ), null, 1 );
			( getLastElement() as FormString ).setTextColor( COLOR.RED_DARK );
			( getLastElement() as FormString ).setRangeBold( 0, 10 );
			
			attuneElement( 700 );
			
			FLAG_SAVABLE = true;
			starterCMD = [ CMD.CAN_FUNCT_SELECT ];
			
			
		}
		
		private function onChangeOpt():void
		{
			popup.construct( PopUp.wrapHeader("select_cantype_warn_popup"), PopUp.wrapMessage("select_cantype_warn_popup_nota"), PopUp.BUTTON_YES | PopUp.BUTTON_NO, [doChange,doCancel] );
			popup.open();
			
		}
		
		override public function put( p:Package ):void
		{
			pdistribute( p );
			
			
			
			changeScreen( p );
			
			preload = false;
		}
		
		override public function open():void
		{
			super.open();
			preload = true;
		}
		
		override public function close():void
		{
			super.close();
			if( ui )ui.close();
		}
		
		private function changeScreen(  p:Package ):void
		{
			_oldValue = int( p.data[ 0 ][ 0 ] );
			
			loadStart();
			if( ui )
			{
				ui.parent.removeChild( ui );
				ui.close();
				ui = null;
			}
			switch( int( p.data[ 0 ][ 0 ] ) ) {
				case PAGE_EMPTY:
					loadComplete();
					break;
				case PAGE_CAR:
					ui = new UICanR42;
					break;
				case PAGE_MATRIX:
					ui = new UICanMatrix;
					break;
				default:
					break;
			}
			
			if( ui )
			{
				ui.y = globalY;
				this.addChild( ui );
				ui.open();
			}
			
			
		}
		
		private function doChange():void
		{
			_oldValue = int( getField(CMD.CAN_FUNCT_SELECT, 1 ).getCellInfo() );
			loadStart();
			RequestAssembler.getInstance().fireEvent( new Request( CMD.CAN_FUNCT_SELECT, null, 1, [ _oldValue ] ) );
			RequestAssembler.getInstance().fireEvent( new Request( CMD.CAN_FUNCT_SELECT, changeScreen ) );
		}
		
		private function doCancel():void
		{
			getField(CMD.CAN_FUNCT_SELECT, 1 ).setCellInfo( _oldValue );
			
		}
	}
}