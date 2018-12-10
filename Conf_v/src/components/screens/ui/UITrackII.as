package components.screens.ui
{
	import components.abstract.GroupOperator;
	import components.abstract.RegExpCollection;
	import components.abstract.functions.loc;
	import components.basement.UI_BaseComponent;
	import components.gui.fields.FSCheckBox;
	import components.gui.fields.FSComboBox;
	import components.gui.fields.FSRadioGroup;
	import components.gui.fields.FSSimple;
	import components.gui.fields.FormString;
	import components.interfaces.IFormString;
	import components.protocol.Package;
	import components.static.CMD;
	import components.system.SavePerformer;
	import components.system.UTIL;
	
	public class UITrackII extends UI_BaseComponent
	{

		private var _group:GroupOperator;

		private var _grBottom:String;

		private var _eNbrs:Vector.<OptENumber>;

		private var _grEngins:String;

		private var _pYEngins:int;

		private var _pYBottom:int;
		public function UITrackII()
		{
			super();
			
			init();
		}
		
		private function init():void
		{
			
			var arr:Array = UTIL.getComboBoxList( [ [ 0, loc( "track_always" ) ], [ 1, loc( "track_moving" ) ] ] );
			
						
			addui( new FSComboBox, CMD.VR_FILTER_TRACK, loc("track_record_coord"), null, 1, arr );
			attuneElement( 300, 200, FSComboBox.F_COMBOBOX_NOTEDITABLE );
			
			addui( new FSSimple, CMD.VR_FILTER_TRACK, loc("track_record_of_time"), null, 2, null, "0-9", 2, new RegExp( RegExpCollection.COMPLETE_2to10 )  );
			attuneElement( 300, 200 );
			
			addui( new FSSimple, CMD.VR_FILTER_TRACK, loc("track_record_50m"), null, 3, null, "0-9", 3, new RegExp( RegExpCollection.COMPLETE_50to100 )  );
			attuneElement( 300, 200 );
			
			addui( new FSSimple, CMD.VR_FILTER_TRACK, loc("track_record_100kmh"), null, 4, null, "0-9", 3, new RegExp( RegExpCollection.COMPLETE_100to300 ) );
			attuneElement( 300, 200 );
			
			getLastElement().setAdapter( new AdapterExample( getLastElement() as FSSimple ) );
			

			addui( new FSCheckBox, CMD.VR_FILTER_3DFIX, loc("track_record_3d" ), onClickCHBox, 1);			
			attuneElement( 300, 200 );
			
			
			_group = new GroupOperator();
			
			_grBottom = "bottomGroup";
			
			_grEngins = "engineGroup";
			
			_pYBottom = globalY;
			
			_group.add( _grBottom, drawSeparator(550) );
			 
			_group.add( _grBottom, addui( new FSSimple, CMD.VR_PACK_SIZE, loc("track_send_when_exceed" ), null, 1, null, "0-9", 2, new RegExp( RegExpCollection.COMPLETE_1to30 ) ) );			
			attuneElement( 300, 200 );
			
			_group.add( _grBottom, drawIndent() );
			
			_group.add( _grBottom,  addui( new FormString,0, loc( "ui_cert_structs_amount_for_cert" ), null, 1 ) ); 
			attuneElement( 500, 200, FormString.F_MULTYLINE );
			
			_eNbrs = new Vector.<OptENumber>(  );
		
			_pYEngins = globalY;
			
			var len:int = 3;
			for (var i:int=0; i<len; i++) {
			
				_eNbrs.push( new OptENumber( i + 1 ) );
				addChild( _eNbrs[ i ] );
				_group.add( _grEngins, _eNbrs[ i ] );
				_eNbrs[ i ].x = globalX;
				_eNbrs[ i ].y = globalY;
				
				globalY += _eNbrs[ i ].complexHeight;
				
			}
			
			
			FLAG_SAVABLE = false;
			var fsRgroup:FSRadioGroup = new FSRadioGroup( [ {label:loc("ui_linkch_stay_one_dir"), selected:false, id:1 },
				{label:loc("ui_linkch_go_next_dir"), selected:false, id:2 }], 1, 30 );
			fsRgroup.y = globalY;
			fsRgroup.x = 40;
			fsRgroup.width = 700+157;
			addChild( fsRgroup );
			addUIElement( fsRgroup, CMD.CH_COM_ADD, 2);
			
			
			
			
			starterCMD = [ CMD.VR_FILTER_TRACK, CMD.VR_PACK_SIZE, CMD.VR_FILTER_3DFIX, CMD.ENGIN_NUMB ];
			
			
			
			
			
		}
		
		override public function open():void
		{
			super.open();
			
			/// пример использования триггера
			SavePerformer.trigger( { "cmd": refine } ); 
		}
		
		
		private function refine(value:Object):int
		{
			if(value is int) {
				switch(value) {
					case CMD.VR_FILTER_3DFIX:
						return SavePerformer.CMD_TRIGGER_TRUE;
						
				}
			} else {
				
				
				var cmd:int = value.cmd;
				value.array[ 0 ] = 1;
				//return SavePerformer.CMD_TRIGGER_BREAK;
				//return SavePerformer.CMD_TRIGGER_CONTINUE;
			}
			return SavePerformer.CMD_TRIGGER_FALSE;
		}
		
		private function putEngineNum( p:Package ):void
		{
			// TODO Auto Generated method stub
			var len:int = _eNbrs.length;
			for (var i:int=0; i<len; i++) 
			{
				//_eNbrs[ i ].putRawData( p.data[ i ] );
				_eNbrs[ i ].putData( p );
				
			}
			
			
			
		}
		
		private function onClickCHBox( i:IFormString ):void
		{
			if( int( getField( CMD.VR_FILTER_3DFIX, 1 ).getCellInfo() ) == 1 )
			{
				getField( CMD.VR_FILTER_TRACK, 1 ).disabled = true;
				_group.visible( _grBottom, true );
				_group.movey( _grEngins, _pYEngins );
			}
			else
			{
				getField( CMD.VR_FILTER_TRACK, 1 ).disabled = false;
				_group.visible( _grBottom, false );
				_group.movey( _grEngins, _pYBottom );
			}
			
			
			if( i ) remember( i );
			
		}		
		
		override public function put(p:Package):void
		{
			switch( p.cmd ) 
			{
				case CMD.ENGIN_NUMB:
					putEngineNum( p  );
					
					break;
				
				case CMD.VR_FILTER_3DFIX:
					loadComplete();
					pdistribute( p );
					onClickCHBox( null );
					break;
				
				default:
					pdistribute( p );		
					break;
			}
			//RequestAssembler.getInstance().fireEvent( new Request( CMD.ENGIN_NUMB, putEngineNum ) );
			
			
		
		}
	}
}


import components.abstract.functions.loc;
import components.basement.OptionsBlock;
import components.gui.fields.FSSimple;
import components.interfaces.IDataAdapter;
import components.interfaces.IFormString;
import components.protocol.Package;
import components.static.CMD;
import components.static.COLOR;


class OptENumber extends OptionsBlock
{
	public function OptENumber( structure:int )
	{
		super();
		
		structureID  = structure;
		
		init( );
		
	}
	
	private function init( ):void
	{
		// TODO Auto Generated method stub
		addui( new FSSimple, CMD.ENGIN_NUMB, loc( "rfd_number" ) + " " + structureID, null, 1 );
		attuneElement(140, 400 );
		
		complexHeight = globalY;
		
	}
	
	override public function putRawData(a:Array):void
	{
		getField( CMD.ENGIN_NUMB, 1 ).setCellInfo( a[ 0 ] );
	}
	
	override public function putData(p:Package):void
	{
		pdistribute( p );
	}
	
	
}

class AdapterExample implements IDataAdapter
{

	private var _field:FSSimple;

	public function AdapterExample( field:FSSimple )
	{
		_field = field;
		
	}
	
	public function adapt(value:Object):Object
	{
		var n:int = int( value ) * 2;
		if( n < 200 )
		{
			_field.setTextColor( COLOR.RED_BLOOD );
		}
		else
		{
			_field.setTextColor( COLOR.GREEN_SIGNAL );
		}
		
		
		return n;
	}
	
	public function change(value:Object):Object
	{
		var n:int = int( value );
		if( n < 200 )
		{
			_field.setTextColor( COLOR.RED_BLOOD );
		}
		else
		{
			_field.setTextColor( COLOR.GREEN_SIGNAL );
		}
		

		// TODO Auto Generated method stub
		return value;
	}
	
	public function perform(field:IFormString):void
	{
		// TODO Auto Generated method stub
		
	}
	
	public function recover(value:Object):Object
	{
		// TODO Auto Generated method stub
		return int( value ) / 2;
	}
}

