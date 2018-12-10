package components.screens.opt
{
	import flash.events.MouseEvent;
	
	import components.abstract.GroupOperator;
	import components.abstract.LR_AL_KEY_STATES;
	import components.abstract.functions.loc;
	import components.abstract.servants.TabOperator;
	import components.basement.OptionListBlock;
	import components.gui.MFlexListAlKey;
	import components.gui.fields.FormString;
	import components.gui.triggers.TextButton;
	import components.interfaces.IFlexListItem;
	import components.interfaces.IFocusable;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.screens.ui.UIAlarmKeys;
	import components.static.CMD;
	
	
	
	
	public class OptAlKey extends OptionListBlock implements IFlexListItem
	{
		
		
		private static const DIFF_WIDTH:int = 40;
		
		
		private var selected:Boolean;
		private var gr:GroupOperator;

		private var _state:int;

		private var flds:Flds;
		
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
		public function OptAlKey( struct:int, idx:int )
		{
			super();
			
			structureID  = struct;
			this.id = ( idx + 1 ) +  "";
			
			
			
			init( );
			
		}
		
		private function init( ):void
		{
			
			
			operatingCMD = CMD.LR_DEVICE_LIST_RF_SYSTEM;
			FLAG_VERTICAL_PLACEMENT = false;
			
			flds = new Flds;
			
			gr = new GroupOperator;
			
			flds.NN = addui( new FormString, 0, "", null, 3  );
			flds.NN.setCellInfo( this.id )
			attuneElement( 80, NaN );
			getLastElement().x = UIAlarmKeys.COLOUMN_POSITIONS[ 0 ];
			
			
			flds.ADDRESS = addui( new FormString, 0, "", null, 2, null );
			attuneElement( 100, NaN, FormString.F_ALIGN_CENTER );
			getLastElement().x = UIAlarmKeys.COLOUMN_POSITIONS[ 1 ];
			gr.add( "data_device", getLastElement() );
			
			
			flds.STATE = addui( new FormString, 0, "", null, 1, null ) as FormString;
			attuneElement( 200, NaN, FormString.F_MULTYLINE );
			getLastElement().x = UIAlarmKeys.COLOUMN_POSITIONS[ 2 ];
			flds.STATE.visible = false;
			
			
			flds.TYPE = addui( new FormString, operatingCMD, "",  null, 2, null ) as FormString;
			attuneElement( 200, NaN, FormString.F_ALIGN_CENTER );
			gr.add( "data_device", getLastElement() );
			
			flds.TYPE.setAdapter( new TypeFieldAdapter );
			flds.TYPE.x = UIAlarmKeys.COLOUMN_POSITIONS[ 3 ];
			
			
			
			
			flds.BTN_RESTORE = new TextButton();
			addChild( flds.BTN_RESTORE );
			flds.BTN_RESTORE.x = UIAlarmKeys.COLOUMN_POSITIONS[ 4 ];
			flds.BTN_RESTORE.setUp(loc("g_restore"),  onRestore );
			flds.BTN_RESTORE.visible = false;
			
			
			flds.BTN_CANCEL = new TextButton();
			addChild( flds.BTN_CANCEL );
			flds.BTN_CANCEL.x = UIAlarmKeys.COLOUMN_POSITIONS[ 4 ];
			flds.BTN_CANCEL.setUp(loc("g_cancel_add"),  onCancelAdd );
			flds.BTN_CANCEL.visible = false;
			
			
			drawSelection( MFlexListAlKey.WIDTH_FIELD );
			
			changeState( LR_AL_KEY_STATES.ADDING )
			
			
		}
		
		public function upDate( struct:int, idx:int ):void
		{
			structureID  = struct;
			this.id = ( idx + 1 ) +  "";
			
			flds.NN.setCellInfo( this.id );
			flds.ADDRESS.setCellInfo( structureID );	
			changeState( LR_AL_KEY_STATES.ADDING );
			
		}
		private function changeState( nstate:int, clean:Boolean = true ):void
		{
			
			
			
			
			if( clean ) clear();
			switch( nstate) 
			{
				case LR_AL_KEY_STATES.CREATE_AT_BUTTON:
				case LR_AL_KEY_STATES.ADDING:
					
					this.disabled = false;
					flds.STATE.visible = true;
					//if( _state == LR_AL_KEY_STATES.OPERATION_BREAK ) break;
					flds.BTN_CANCEL.visible = true;
					flds.BTN_CANCEL.disabled = false;
					
					break;
				
				/// после сообщения об удачном добавлении пойдет запрос листинга, так что ничего не делаем особого
				case LR_AL_KEY_STATES.ADDED_SUCCESS:
					
					if( !flds.STATE.visible ) flds.STATE.visible = true;
					
					
					break;
				
				case LR_AL_KEY_STATES.DELETE_SUCCESS:
					
					if( !flds.STATE.visible ) flds.STATE.visible = true;
					flds.BTN_RESTORE.visible = true;
					flds.BTN_RESTORE.disabled = false;
					
					break;
				case LR_AL_KEY_STATES.RESTORE_SUCCESS:
					
					flds.ADDRESS.visible = true;
					flds.TYPE.visible = true;
					this.disabled = false;
					
					break;
				case LR_AL_KEY_STATES.CREATE_AT_BUTTON:
					if( !flds.STATE.visible ) flds.STATE.visible = true;
					flds.BTN_CANCEL.visible = false;
					flds.BTN_CANCEL.disabled = true;
					break;
				
					
				case LR_AL_KEY_STATES.OPERATION_BREAK:
				case LR_AL_KEY_STATES.ADD_FAIL:
				case LR_AL_KEY_STATES.ADDRESS_BUSY:
				case LR_AL_KEY_STATES.RESTORE_FAIL:
					if( !flds.STATE.visible ) flds.STATE.visible = true;
					this.disabled = true;
					break;
				
				default:
					
					
					if( flds.STATE.visible ) flds.STATE.visible = false;
					flds.ADDRESS.visible = true;
					flds.TYPE.visible = true;
					this.disabled = false;
					
					break;
			}
			
			
			
			flds.STATE.setCellInfo( LR_AL_KEY_STATES.getLoc( nstate ) );
			flds.STATE.setTextColor( LR_AL_KEY_STATES.getColor( nstate ) );
			
			_state = nstate;
		}
		
		public function updateIndex( inx:int ):void
		{
			
			this.id = inx + "";
			flds.NN.setCellInfo( this.id );
		}
		
		private function clear():void
		{
			flds.ADDRESS.visible = false;
			flds.STATE.visible = false;
			flds.TYPE.visible = false;
			
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
			
			flds.ADDRESS.setCellInfo( structureID );
			flds.TYPE.setCellInfo( p.getParamInt( 2, structureID ) );
			
			
		}
		
		public function put(p:Package):void 
		{
			
			
			
			
			
			
			switch(p.cmd) {
				case CMD.LR_RF_STATE:
					
					if( p.getParamInt( 1 ) != structureID ) break;
					
					
					changeState(  p.getParamInt( 2 ) , true );
					
					break;
				
				case CMD.LR_DEVICE_LIST_RF_SYSTEM:
					
					switch( p.getParamInt( 1, structureID ) ) {
						case 2:
							changeState( LR_AL_KEY_STATES.DELETE_SUCCESS );
								
							break;
						case 0:
							break;
						default:
							
							changeState( LR_AL_KEY_STATES.IDLE );
							break;
					}
					putData( p );
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
			
			//this.dispatchEvent( new MouseEvent( MouseEvent.CLICK ) );
			changeState( LR_AL_KEY_STATES.OPERATION_BREAK );
			RequestAssembler.getInstance().fireEvent( new Request( CMD.LR_DEVICE_BREAK, null, 1, [ 1 ], Request.SYSTEM ) );
		}
		
		
		
	}
}
import components.abstract.servants.DevicesServant;
import components.gui.fields.FormString;
import components.gui.triggers.TextButton;
import components.interfaces.IDataAdapter;
import components.interfaces.IFormString;

class TypeFieldAdapter implements IDataAdapter
{
	public function change(value:Object):Object { return value; }	// меняет вбитое значение до валидации
	/**
	 * Вызывается при первой загрузке входных данных 
	 * @param value собственно данные полученые с прибора
	 * @return данные которые будут сообщены закрепленному компоненту
	 * 
	 */		
	public function adapt(value:Object):Object
	{
		
		
		return DevicesServant.instance.getLabel( value as int ); 
	}
	/**
	 * Вызывается при изменении значения эл-та, например
	 * при чеке чекбокса
	 *  
	 * @param value данные полученные компонентом в результате изменения состояния
	 * @return данные которые будут переданны на прибор в результате преобразования
	 * 
	 */		
	public function recover(value:Object):Object 
	{
		
		return DevicesServant.instance.getId( value as String ); 
	}
	/**
	 * Вызывается при первой загрузке входных данных 
	 * @param field элемент за которым закреплен адаптер
	 * @return 
	 * 
	 */	
	public function perform(field:IFormString):void {}
}

class Flds
{
	public var NN:IFormString;
	public var ADDRESS:IFormString;
	public var STATE:FormString;
	public var TYPE:IFormString;
	public var BTN_RESTORE:TextButton;
	public var BTN_CANCEL:TextButton;
}