package components.screens.ui
{
	import flash.utils.getTimer;
	
	import mx.core.Container;
	import mx.core.ScrollPolicy;
	import mx.core.UIComponent;
	
	import components.abstract.functions.dtrace;
	import components.abstract.functions.loc;
	import components.abstract.servants.C2000EventsServant;
	import components.basement.UI_BaseComponent;
	import components.events.GUIEventDispatcher;
	import components.events.GUIEvents;
	import components.gui.Header;
	import components.gui.OptList;
	import components.gui.fields.FSCheckBox;
	import components.gui.fields.FSRadioGroup;
	import components.gui.fields.FormString;
	import components.interfaces.IFormString;
	import components.protocol.Package;
	import components.protocol.statics.OPERATOR;
	import components.screens.opt.OptC2000Row;
	import components.static.CMD;
	import components.static.DS;
	import components.system.SavePerformer;
	
	public class UIC2000Events extends UI_BaseComponent
	{
		private var _opts:Vector.<OptC2000Row>;
		private var optList:OptList;
		private var _optContainer:Container;
		private var dataEvents:Array;
		private var shadOpts:Array/*OptShudow*/;

		private var lastStates:Array = new Array();

		private var _rg:FSRadioGroup;

		private var _chkAll:FSCheckBox;
		
		
		public function get optContainer():Container
		{
			return _optContainer;
		}

		public function get opts():Vector.<OptC2000Row>
		{
			return _opts;
		}
		
		public function get rg():FSRadioGroup
		{
			return _rg;
		}
		
		
		
		public function UIC2000Events()
		{
			
			super();
			
			init();
		}
		
		

		private function init():void
		{
			
			
			addui( new FSCheckBox(), CMD.K5RT_BOLID_PROTOCOL_TYPE, loc("received_cid_from_the_bolid"), delegateProtocolType, 1 );
			getLastElement().setAdapter( new AdaptProtocolType( this ) );
			attuneElement( 400 );
		
			_rg = new FSRadioGroup
			(
				[
					{ label:loc( "take_all_messages" ), selected:false, id:0x00 },
					{ label:loc( "take_messages_of_c2000" ), selected:false, id:0x01 },
					{ label:loc( "take_custom_messages" ), selected:false, id:0x02 }
				],
				1,
				25
			);
			
			_rg.x = globalX;
			_rg.y = globalY + 10;
			_rg.width = 400;
			globalY += _rg.height + 5;
			this.addChild( _rg );
			
			
			addUIElement( _rg, CMD.K5RT_BOLID_FLTR_TYPE,1, callLogic);
			
			
			drawSeparator( 450 );
			
			
			
			const header:Header = new Header
				(
					[
						{ label:loc( "wifi_ap_num" ), xpos: 0, width:20  },
						{ label:loc( "  " ), xpos:40, width:20 },
						{ label:loc( "navi_c2000_events" ), xpos:105, width:200 },
						{ label:loc( "events_of_main_device" ), xpos:350, width:350 }
						
					]
				);
			header.y = globalY;
			header.x = globalX;
			
			this.addChild( header );
			
		
			FLAG_SAVABLE = false;
			
			
			_chkAll = new FSCheckBox;
			_chkAll.setUp( dlgCheckAll );
			_chkAll.x = -122;
			_chkAll.y = header.y;
			this.addChild( _chkAll );
			
			FLAG_SAVABLE = true;
			
			globalY += header.height + 30;
			
			
			
			var heightCont:int = 400;
			
			_optContainer = new Container();
			_optContainer.x = globalX;
			_optContainer.y = globalY;
			_optContainer.width = 750;
			_optContainer.height = heightCont;
			var scrollBg:UIComponent = new UIComponent;
			_optContainer.addChild( scrollBg );
			this.addChild( _optContainer );
			
			_optContainer.verticalScrollPolicy = ScrollPolicy.AUTO;
			_optContainer.horizontalScrollPolicy = ScrollPolicy.OFF;
			
			
			dataEvents = C2000EventsServant.getSetMessages(); 
			
			var len:int = dataEvents.length;
			_opts = new Vector.<OptC2000Row>( len );
			var yy:int = 0;
			for (var i:int=0; i<len; i++) {
				_opts[ i ] = new OptC2000Row( i )
				optContainer.addChild( _opts[ i ] );
				_opts[ i ].x = 0;
				_opts[ i ].y = yy;
				yy += _opts[ i ].height;
				 
			}
			
			
			var len2:int = OPERATOR.getSchema( CMD.K5RT_BOLID_EVENT_MASK ).StructCount;
			shadOpts = new Array( len2 );
			for (var j:int=0; j<len2; j++)
				shadOpts[ j ] = new OptShadow( j + 1 );
				
			
			
			
			globalY += heightCont;
		
			GUIEventDispatcher.getInstance().addEventListener( GUIEvents.EVOKE_CHANGE, onChangeBox );
		
			drawSeparator( 450 );
			
			addui( new FSCheckBox(), CMD.K5RT_BOLID_OBJECT, loc( "write_address_to_part" ), null, 1 );
			attuneElement( 400, NaN );
			getLastElement().setAdapter( new AdaptChBox() );
			
			
			
		
			
		
		
			FLAG_SAVABLE = false;
			
			const fString:FormString = new FormString();
			fString.alpha = .9;
			fString.setWidth( 500 );
			fString.attune( FormString.F_TEXT_MINI );
			fString.setName( loc( "write_address_to_part_comment" ) );
			fString.x = globalX;
			fString.y = globalY - 5;
			
			this.addChild( fString );
			
			
			globalY += fString.height;
			
			FLAG_SAVABLE = true;
			
			if( DS.alias != DS.K5RT3L )
			{
				addui( new FSCheckBox(), CMD.K5RT_BOLID_LINK, loc( "control_connection_of_device" ), null, 1 );
				attuneElement( 400, NaN );
				getLastElement().setAdapter( new AdaptChBox() )
			}
			
			
			starterCMD = [ CMD.K5RT_BOLID_FLTR_TYPE, CMD.K5RT_BOLID_EVENT_MASK, CMD.K5RT_BOLID_OBJECT, CMD.K5RT_BOLID_PROTOCOL_TYPE ];
			
			if( DS.alias != DS.K5RT3L )starterCMD.push( CMD.K5RT_BOLID_LINK );
			
			
			
		}
		
			
			
		
		
		
		
		override public function put(p:Package):void
		{
			switch( p.cmd ) {
				case CMD.K5RT_BOLID_FLTR_TYPE:
					pdistribute( p );
					
					_chkAll.disabled = p.data[ 0 ][ 0 ] != 2 + "";
					break;
				
				case CMD.K5RT_BOLID_EVENT_MASK:
					//optList.putData( configurePackages( p ).data, OptC2000Row );
					dataConfig( p );
					const freeze:Boolean = getField( CMD.K5RT_BOLID_FLTR_TYPE, 1 ).getCellInfo() < 2 ;
					
					
					var len:int = _opts.length;
					for (var i:int=0; i<len; i++) {
						_opts[ i ].putCustomData( dataEvents[ i ] );
						_opts[ i ].freeze = freeze;
					}
					
					
					
					len = shadOpts.length;
					for (var j:int=0; j<len; j++) {
						shadOpts[ j ].putData( p );
					}
					
					analisecheckAll();
					
					break;
				
				case CMD.K5RT_BOLID_LINK:
					pdistribute( p );
					
					break;
				
				case CMD.K5RT_BOLID_OBJECT:
					pdistribute( p );
					
					break;
				
				case CMD.K5RT_BOLID_PROTOCOL_TYPE:
					
					pdistribute( p );
					loadComplete();
					break;
				
				default:
					break;
			}
		}
		
		
		/// реорганизуем
		private function dataConfig(p:Package):void
		{
			var bMask:uint = 1;
			var bData:uint;
			var enable:int = 0;
			var idx:int = 0;
			const len:int = OPERATOR.getSchema( CMD.K5RT_BOLID_EVENT_MASK ).StructCount;
			
			pack: for(var key:int = 0; key < len; key++ ) 
			{
				for (var i:int=0; i<8; i++) 
				{
					///TODO: Закоменчено из за изменения требований по интерпретации масок
					///https://megaplan.ritm.ru/task/1042237/card/#c291406
					//idx = ( key * 8 ) + i - 1;
					idx = ( key * 8 ) + i;
					/// первый бит последовательности не привязан к полю
					//if( key == 0 && i == 0 ) continue;
					if( !dataEvents[ idx ] ) break pack;
					
					bData = uint( p.data[ key ] );
					dataEvents[ idx ].enable = ( bData & ( bMask << i ) ) > 0;
					
					
					
				}
				
				
			}
			
			
		}
		
		protected function onChangeBox(evt:GUIEvents ):void
		{
			
			
			const ind:int = ( int( evt.serviceObject.id ) - 1 );
			const byteIndex:int = ind / 8 ;
			///TODO: изменено по требованию в задаче https://megaplan.ritm.ru/task/1042237/card/#c291406
			//const bmask:uint = 1 <<  int( evt.serviceObject.id ) % 8;
			const bmask:uint = 1 << ind % 8;
			const value:int = evt.serviceObject.state;
			shadOpts[ byteIndex ].putRawData( [ bmask, value ] );
			
			
			//if( !value ) _chkAll.setCellInfo( 0 );
			analisecheckAll();
			
		}
		
		
		
		private function callLogic(t:IFormString):void
		{
			
			var masks:Array;
			
			
			switch( ( t.getCellInfo().toString() )) {
				case "0": /// выбрать все
					masks =
					[
						255,	
						255,	
						255,	
						255,	
						255,	
						255,	
						255,	
						255,	
						255,	
						255,	
						255,	
						255,	
						255,	
						255,	
						255,	
						255,	
						255,	
						255,	
						255,	
						255	
					];
					selectTypeSetEvents( masks, true );
					_chkAll.disabled = true;
					break;
				case "1": /// по стандарту С2000-ИТ
					masks = [ 127,0,3,124,6,6,0,0,64,130,1,0,0,0,0,0,0,0,0];
					selectTypeSetEvents( masks, true );
					_chkAll.disabled = true;
					break;
				case "2": /// произвольный выбор
					selectTypeSetEvents( null, false );
					_chkAll.disabled = false;
					break;
				
				
				
				
			}
			
			SavePerformer.remember( structureID, t );
		}
		
		
		private function selectTypeSetEvents( masks:Array = null, dsbl:Boolean = true ):void
		{
			
			
			for (var i3:int=0; i3<shadOpts.length; i3++) 
				shadOpts[ i3 ].getField( CMD.K5RT_BOLID_EVENT_MASK, 1 ).setCellInfo( 0 );
			
					
			const len:int = _opts.length;
			
			
			
			if( dsbl && !_opts[ 0 ].freeze  )
			{
				lastStates = new Array();
				
				for (var i:int=0; i<len; i++) 
				{
					
					lastStates.push( _opts[ i ].getField( 0, 2 ).getCellInfo() );	
					_opts[ i ].freeze = dsbl;
				}
				
			}
			else if( !dsbl && lastStates.length )
			{
				for (var j:int=0; j<len; j++) 
				{
					_opts[ j ].freeze = dsbl;
					_opts[ j ].switchState(  lastStates[ j ] );	
					
					
				}
			}
			else
			{
				
				/// сбрасываем все байты в ноль
				for (var k:int=0; k<len; k++) 
					_opts[ k ].switchState( 0 );
				
				for (var i2:int=0; i2<len; i2++)
				{
					_opts[ i2 ].freeze = dsbl;
				}
			}
			
			
			
			if( masks )
			{
				/// сбрасываем все байты в ноль
				for (var k1:int=0; k1<len; k1++) 
					_opts[ k1 ].switchState( 0 );
				
				for ( var k2:int =0; k2<len; k2++) 
				{
					
					const byte:int = k2 / 8;
					
					_opts[ k2 ].switchState( masks[ byte ] & 1 << k2%8?1:0 );
				}
				
			}
		}
		
		///// Обслуживание поведения флажка "выбрать все"////////////////////////////////
		private function dlgCheckAll(  ):void
		{
			var len:int = _opts.length;
			const on_enable:int = _chkAll.getCellInfo()?1:0;
			for (var i:int=0; i<len; i++) {
				_opts[ i ].switchState( on_enable );
				
			}
			
		}		
		
		private function analisecheckAll():void
		{
			var onSelect:int = 1;
			var len:int = _opts.length;
			for (var i:int=0; i<len; i++) {
				if( _opts[ i ].getSelect() as int ) continue;
				onSelect= 0;
				break;
			}
			
			_chkAll.setCellInfo( onSelect );
		}
		
		private function delegateProtocolType( ifr:IFormString ):void
		{
			
			_chkAll.disabled = ifr.getCellInfo() != 0xFF + "";
			
			remember( ifr );
			
		}	
		
			
		
		
	}
}
import components.basement.OptionsBlock;
import components.gui.Balloon;
import components.gui.fields.FSShadow;
import components.interfaces.IDataAdapter;
import components.interfaces.IFormString;
import components.protocol.Package;
import components.screens.ui.UIC2000Events;
import components.static.CMD;
import components.system.SavePerformer;
import components.system.UTIL;

class OptShadow extends OptionsBlock
{
	public function OptShadow( structId:int )
	{
		super();
		
		structureID = structId;
		
		init();
	}
	
	private function init():void
	{
		addui( new FSShadow(), CMD.K5RT_BOLID_EVENT_MASK, "", null, 1 );
		
	}
	
	override public function putRawData(a:Array):void 
	{
		
		const field:IFormString = getField( CMD.K5RT_BOLID_EVENT_MASK, 1 );
		
		var stored:uint = int( field.getCellInfo() );
		const shift:uint = Number( a[ 0 ] ).toString( 2 ).length - 1;
		
		if( UTIL.isBit( shift, stored )  )
		{
				if( !a[ 1 ] )stored -= a[ 0 ];
		}
		else if( a[ 1 ] )
		{
			stored += a[ 0 ];
		}
		
		
		field.setCellInfo( stored );
		
		SavePerformer.remember( structureID, field, true );//remember( field ); 
	}
	
	override public function putData(p:Package):void
	{
		pdistribute( p );
	}
}

class AdaptChBox implements IDataAdapter
{
	public function change(value:Object):Object
	{
		 	// меняет вбитое значение до валидации
		
		
		return value;
	}
	
	public function adapt(value:Object):Object
	{
		return value > 0?0:1;
	}
	
	public function recover(value:Object):Object
	{
		
		return value?0:0xFF;
	}
	
	public function perform(field:IFormString):void
	{
		
	}
}

class AdaptProtocolType implements IDataAdapter
{

	private var _owner:UIC2000Events;
	
	public function AdaptProtocolType( owner:UIC2000Events ):void
	{
		_owner = owner;
	}
	
	public function change(value:Object):Object
	{
		// меняет вбитое значение до валидации
		
		
		return value;
	}
	
	public function adapt(value:Object):Object
	{
		const dsbl:Boolean = value == 0xFF?false:true;
		
		_owner.rg.disabled = dsbl;
		_owner.optContainer.enabled = !dsbl;
		
		return dsbl
	}
	
	public function recover(value:Object):Object
	{
		const dsbl:Boolean = !( value == 0 );
		_owner.optContainer.enabled = !dsbl;
		_owner.rg.disabled = dsbl;
		
		
		Balloon.access().show( "sys_attention","misc_need_restart_to_apply" );
		
		return value?0xFE:0xFF;
		
		
	}
	
	public function perform(field:IFormString):void
	{
		
	}
}