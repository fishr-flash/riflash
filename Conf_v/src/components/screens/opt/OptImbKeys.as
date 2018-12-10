package components.screens.opt
{
	import flash.events.MouseEvent;
	
	import components.abstract.GroupOperator;
	import components.abstract.IMB_KEY_STATES;
	import components.abstract.functions.loc;
	import components.abstract.servants.TabOperator;
	import components.basement.OptionListBlock;
	import components.events.GUIEventDispatcher;
	import components.events.SystemEvents;
	import components.gui.MFlexListImbKey;
	import components.gui.fields.FSShadow;
	import components.gui.fields.FormString;
	import components.gui.triggers.TextButton;
	import components.interfaces.IFlexListItem;
	import components.interfaces.IFocusable;
	import components.interfaces.IFormString;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.protocol.statics.OPERATOR;
	import components.screens.ui.UIImbKeys;
	import components.static.CMD;
	import components.system.UTIL;
	
	
	
	
	public class OptImbKeys extends OptionListBlock implements IFlexListItem
	{
		
		
		private static const DIFF_WIDTH:int = 40;
		
		
		private var selected:Boolean;
		private var gr:GroupOperator;

		private var _state:int;

		private var flds:Flds;

		private var some:String = "";
		
		public function get state():int
		{
			return _state;
		}
		
		public function get structure():int
		{
			return structureID;
		}

		override public function set disabled(value:Boolean):void
		{
			
			_disabled = value;
			
			var len:int = this.numChildren;
			for (var i:int=0; i<len; i++) 
			{
				
				
				if( ( this.getChildAt( i )  as Object ).hasOwnProperty( "mouseEnabled" ) )
					( this.getChildAt( i )  as Object ).mouseEnabled = !_disabled;
				
				if( ( this.getChildAt( i )  as Object ).hasOwnProperty( "mouseChildren" ) )
					( this.getChildAt( i )  as Object ).mouseChildren = !_disabled;
				
				
			}
			
			this.mouseChildren = !_disabled;
			this.mouseEnabled = !_disabled;
			
			if( selection )selection.alpha = _disabled?.4:1;
			
		}
		public function OptImbKeys( struct:int )
		{
			super();
			
			structureID  = struct;
			this.id = structureID +  "";
			
			
			
			init( );
			
		}
		
		private function init( ):void
		{
			
			
			operatingCMD = CMD.VR_TM_KEY;
			FLAG_VERTICAL_PLACEMENT = false;
			
			flds = new Flds;
			
			gr = new GroupOperator;
			
			flds.NN = addui( new FormString, 0, "", null, 3  );
			flds.NN.setCellInfo( this.id )
			attuneElement( UIImbKeys.COLOUMN_POSITIONS[ 1 ] - UIImbKeys.COLOUMN_POSITIONS[ 0 ], NaN );
			getLastElement().x = UIImbKeys.COLOUMN_POSITIONS[ 0 ];
			
			
			flds.IDENTIFICATOR = addui( new FormString, 0, "", identDelegate, 2, null );
			attuneElement( UIImbKeys.COLOUMN_POSITIONS[ 2 ] - UIImbKeys.COLOUMN_POSITIONS[ 1 ], NaN );
			getLastElement().x = UIImbKeys.COLOUMN_POSITIONS[ 1 ];
			gr.add( "data_device", getLastElement() );
			
			
			
			var len:int = OPERATOR.getSchema( operatingCMD ).Parameters.length;
			for (var i:int=0; i<len; i++) 
			{
				addui( new FSShadow, operatingCMD, "", null, i + 1 );
			}
			
			
			
			
			flds.STATE = addui( new FormString, 0, "", null, 1, null ) as FormString;
			attuneElement( 200, NaN, FormString.F_ALIGN_CENTER );
			getLastElement().x = UIImbKeys.COLOUMN_POSITIONS[ 2 ];
			flds.STATE.visible = false;
			
			
			
			
			
			
			flds.BTN_RESTORE = new TextButton();
			addChild( flds.BTN_RESTORE );
			flds.BTN_RESTORE.x = UIImbKeys.COLOUMN_POSITIONS[ 4 ];
			flds.BTN_RESTORE.setUp(loc("g_restore"),  onRestore );
			flds.BTN_RESTORE.visible = false;
			
			
			flds.BTN_CANCEL = new TextButton();
			addChild( flds.BTN_CANCEL );
			flds.BTN_CANCEL.x = UIImbKeys.COLOUMN_POSITIONS[ 4 ];
			flds.BTN_CANCEL.setUp(loc("g_cancel_add"),  onCancelAdd );
			flds.BTN_CANCEL.visible = false;
			
			
			drawSelection( MFlexListImbKey.WIDTH_FIELD );
			
			
		}
		
		
		
		public function upDate( struct:int, idx:int ):void
		{
			structureID  = struct;
			this.id = ( idx + 1 ) +  "";
			
			flds.NN.setCellInfo( this.id );
			flds.IDENTIFICATOR.setCellInfo( structureID );	
			changeState( IMB_KEY_STATES.SEARCH_UP );
			
		}
		
		public function updateIndex( inx:int ):void
		{
			
			this.id = inx + "";
			flds.NN.setCellInfo( this.id );
		}
		
		private function clear():void
		{
			flds.IDENTIFICATOR.visible = false;
			flds.STATE.visible = false;
			//flds.TYPE.visible = false;
			
			flds.BTN_RESTORE.visible = false;
			flds.BTN_RESTORE.disabled = true;
			flds.BTN_CANCEL.visible = false;
			flds.BTN_CANCEL.disabled = true;
		}
		
		
		
		
		
		override public function putRawData(a:Array):void
		{
			
		}
		
		override public function putData(p:Package):void
		{
			
			const bytes:Array = ( p.data[ structureID - 1 ] as Array ).slice();
			var value:String = "";
			/// два последних параметра не код ключа, они зарезервированны
			var len:int = bytes.length - 2;
			for (var i:int=0; i<len; i++) 
			{
				/// данные восьми первых параметров переводим в хекс, дополняем впереди нулем, если цифра одна, и переводим в верх. регистр
				value += UTIL.fz(  ( bytes[ i ] as Number ).toString( 16 ) , 2 ).toUpperCase();
				
				getField( operatingCMD, i + 1 ).setCellInfo( bytes[ i ] );
			}
			
			flds.IDENTIFICATOR.setCellInfo( value );
			
			changeState( IMB_KEY_STATES.KEY_FOUND );
			
		}
		
		public function put(p:Package):void 
		{
			
			
			
			
			switch(p.cmd) {
				case CMD.VR_TM_KEY:
					
					//if( p.getParamInt( 1 ) != structureID ) break;
					
					
					//changeState(  p.getParamInt( 2 ) , true );
					putData( p );
					break;
				
				case CMD.VR_TM_SEARCH:
					
					switch( p.getParamInt( 1, 1 ) ) {
						case IMB_KEY_STATES.DOUBLE_DETECTED:
							
								some = "" + p.getParamInt( 2, 1 );
								changeState(  int( p.getParam( 1, 1 ) ) );
							break;
						/*case 0:
							break;*/
						default:
							
							changeState(  int( p.getParam( 1, 1 ) ) );
							break;
					}
					
					break;
				default:
					
				
			}
			
		}	// loads data
		
		
		public function change(p:Package):void {}	// loads data and evoke save
		public function putRaw(value:Object):void{}
		public function kill():void
		{
			var len:int = this.numChildren;
			for (var i:int=0; i<len; i++)
			{
				if(  this.getChildAt( i ) is IFocusable )TabOperator.getInst().remove( this.getChildAt( i ) as IFocusable );
			
				
			}
			
		}
		public function extract():Array { return null; }			// get data from target
		public function set selectLine(b:Boolean):void 
		{
			super.select( b );
		}
		
		public function isSelected():Boolean { return selected };
		
		
		private function onRestore( ):void
		{
			flds.BTN_RESTORE.visible = false;
			
			this.dispatchEvent( new MouseEvent( MouseEvent.CLICK ) );
			
			RequestAssembler.getInstance().fireEvent( new Request( CMD.LR_DEVICE_RES_FROM_RF_SYSTEM, null, 1, [ structureID ], Request.SYSTEM ) );
		}
		private function onCancelAdd( ):void
		{
			flds.BTN_CANCEL.visible = false;
			changeState( IMB_KEY_STATES.ALL_CANCEL );
			GUIEventDispatcher.getInstance().fireSystemEvent( SystemEvents.onBlockNavigation, {"isBlock":false} );
			//this.dispatchEvent( new MouseEvent( MouseEvent.CLICK ) );
			
			RequestAssembler.getInstance().fireEvent( new Request( CMD.VR_TM_SEARCH, put, 1, [ IMB_KEY_STATES.ALL_CANCEL, 0  ], Request.SYSTEM ) );
			
		}
		
		private function identDelegate( ifrm:IFormString ):void
		{
			
			
		}
		
		private function changeState( nstate:int, clean:Boolean = true ):void
		{
			
			if( clean ) clear();
			switch( nstate) 
			{
				case IMB_KEY_STATES.ON_SEARCH:
					
					
				
					this.disabled = false;
					flds.STATE.visible = true;
					//if( _state == LR_AL_KEY_STATES.OPERATION_BREAK ) break;
					flds.BTN_CANCEL.visible = true;
					flds.BTN_CANCEL.disabled = false;
					this.mouseChildren = true;
						break;
				
				case IMB_KEY_STATES.DOUBLE_DETECTED:
				case IMB_KEY_STATES.ALL_CANCEL:
				case IMB_KEY_STATES.TIME_OUT:
					
					
					this.disabled = true;
					flds.STATE.visible = true;
					flds.BTN_CANCEL.visible = false;
					flds.BTN_CANCEL.disabled = true;
					
						break;
				
				case IMB_KEY_STATES.KEY_FOUND:
					
					
				
					this.disabled = false;
					flds.IDENTIFICATOR.visible = true;
					//flds.STATE.visible = false;
					//if( _state == LR_AL_KEY_STATES.OPERATION_BREAK ) break;
					flds.BTN_CANCEL.visible = false;
					flds.BTN_CANCEL.disabled = true;
					
						break;
				
				
				
				default:
					
					
					//if( flds.STATE.visible ) flds.STATE.visible = false;
					flds.IDENTIFICATOR.visible = true;
					//flds.TYPE.visible = true;
					this.disabled = false;
					
					break;
			}
			
			
			
			flds.STATE.setCellInfo( IMB_KEY_STATES.getLoc( nstate, some ) );
			flds.STATE.setTextColor( IMB_KEY_STATES.getColor( nstate ) );
			some = "";
			_state = nstate;
		}
		
		
	}
}
import components.gui.fields.FormString;
import components.gui.triggers.TextButton;
import components.interfaces.IFormString;



class Flds
{
	public var NN:IFormString;
	public var IDENTIFICATOR:IFormString;
	public var STATE:FormString;
	public var TYPE:IFormString;
	public var BTN_RESTORE:TextButton;
	public var BTN_CANCEL:TextButton;
}