package components.screens.opt
{
	import flash.utils.getTimer;
	
	import components.abstract.functions.dtrace;
	import components.abstract.functions.loc;
	import components.basement.OptionListBlock;
	import components.events.GUIEventDispatcher;
	import components.events.GUIEvents;
	import components.gui.fields.FSCheckBox;
	import components.gui.fields.FormString;
	import components.interfaces.IFormString;
	import components.interfaces.IListItem;
	
	
	public class OptC2000Row extends OptionListBlock implements IListItem
	{
		private var field1:FormString;
		private var field2:FormString;
		private var field3:FSCheckBox;
		
		
		
		public function OptC2000Row(_struct:int)
		{
			super();
			
			structureID = _struct;
			FLAG_VERTICAL_PLACEMENT = false;
			operatingCMD = 0;// CMD.K5RT_BOLID_EVENT_MASK;
			
			globalFocusGroup = 3050;
			
			
			
			var id:String = "";
			var active:int = 1;
			var event2000:String = "";
			var evetnCIDCode:String = "";
			var eventCID:String = "";
			
			
			
			
			addui( new FormString(), operatingCMD, id, null, 1 );
			attuneElement( 35, NaN );
			getLastElement().x = 0;
			
			addui( new FSCheckBox(), operatingCMD, "", onClickChBx, 2 );
			attuneElement( 20, NaN );
			getLastElement().x += 28;
			
			addui( new FormString(), operatingCMD, event2000, null, 3 );
			attuneElement( 200, NaN );
			getLastElement().x += 120;
			
			addui( new FormString(), operatingCMD, eventCID, null, 4 );
			attuneElement( 350, NaN );
			getLastElement().x += 360;
			
			this.width = 700;
			
				
			
		}
		
		public function switchState( state:int ):void
		{
			
			getField( operatingCMD, 2 ).setCellInfo( state );
			
			GUIEventDispatcher.getInstance().fireEvent( GUIEvents, GUIEvents.EVOKE_CHANGE, { id:getField( operatingCMD, 1 ).getCellInfo() , state: state } );
		}
		
		private function onClickChBx( i:IFormString ):void
		{
			GUIEventDispatcher.getInstance().fireEvent( GUIEvents, GUIEvents.EVOKE_CHANGE, { id:getField( operatingCMD, 1 ).getCellInfo() , state: getField( operatingCMD, 2 ).getCellInfo() } );
		}
		
		
		public function putCustomData( obj:Object ):void
		{
			getField( operatingCMD, 1 ).setCellInfo( obj[ "id" ] );
			getField( operatingCMD, 2 ).setCellInfo( obj[ "enable" ] );
			getField( operatingCMD, 3 ).setCellInfo( obj[ "label"] );
			getField( operatingCMD, 4 ).setCellInfo( obj[ "cid" ] );
		}
		
		
		
		public function getSelect(  ):Object
		{
			return getField( operatingCMD, 2 ).getCellInfo();
		}
		
		private function setFill():void
		{
			
			var txt:String = String( field1.getCellInfo() );
			
			if(!field2.getCellInfo() || field2.getCellInfo() == loc( "g_no" ) )
			{
				field2.setCellInfo( txt );//.fillBlank(txt);
				remember( field2 );
			}
		}
		private function change(target:IFormString):void
		{
			setFill();
			remember( field1 );
		}
		override public function call(value:Object, param:int):Boolean
		{
			if (!value)
				return false;
			if (int(value) < 0) {
				
				if ( field1.getCellInfo() != "0" &&
					field2.getCellInfo() != ""	) {
					remember( field2 );
				}
				
				field2.setCellInfo( "" );
				return true;
			}
			
			if( int(value) != int(field1.getCellInfo()) )
				field1.setCellInfo( value.toString(16) );
			
			
			var txt:String = String( field1.getCellInfo() );
			var fill:String;
			
			if (txt != loc("g_no"))
				fill = txt.slice(6,56); 
			else
				fill = txt;
			
			if( field2.getCellInfo().toString() != fill ) {
				field2.setCellInfo( fill );
				remember( field2 );
			}
			
			setFill();
			
			return true;
		}
	}
}