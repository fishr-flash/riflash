package components.screens.ui
{
	import components.abstract.GroupOperator;
	import components.abstract.RegExpCollection;
	import components.abstract.SecondCalculateAdapter;
	import components.abstract.TimeValidationBot;
	import components.abstract.functions.loc;
	import components.abstract.servants.ValidEntersForDoorsServant;
	import components.basement.UI_BaseComponent;
	import components.gui.fields.FSComboBox;
	import components.interfaces.IFormString;
	import components.protocol.Package;
	import components.static.CMD;
	import components.system.UTIL;
	
	public class UICanMatrix extends UI_BaseComponent
	{
		public static const MAX_COUNT_DOORS:int = 10;

		private var gr:GroupOperator;

		private var doors:Vector.<OptDoorProp>;
		
		public function UICanMatrix()
		{
			super();
			
			init();
			
		}
		
		private function init():void
		{
			const widthCell:int = 200;
			const widthField:int = 150;
			const wSep:int = 700;
			
			const list:Array = new Array( MAX_COUNT_DOORS );
			for (var i:int=0; i< MAX_COUNT_DOORS; i++) 
						list[ i ] = { label: i + 1, data:i + 1 };	
			
			addui( new FSComboBox, CMD.VR_IRMA_DOOR_NUM, loc("count_doors"), selectCountDoor, 1, list );
			attuneElement( widthCell, widthField, FSComboBox.F_COMBOBOX_NOTEDITABLE );
			
			drawSeparator( wSep );
			
			globalY += 20;
			globalX += 60;
			
			
			
			
			doors = new Vector.<OptDoorProp>();
			const marginLeft:int = 150;
			globalX += marginLeft;
			for ( i=0; i< UICanMatrix.MAX_COUNT_DOORS; i++)
			{
				doors.push( addopt( new OptDoorProp( i + 1 ) ) as OptDoorProp );
				doors[ i ].y = globalY;
				doors[ i ].visible = false;
				globalY += doors[ i ].height;
			}
			globalX -= marginLeft;
			
			gr = new GroupOperator;
			
			gr.add( "bottom", drawSeparator( wSep ) );

			globalX = 20;
			gr.add( "bottom", addui( new FSComboBox, CMD.VR_IRMA_DOOR_DELAY, loc("delay_for_close"), null, 1, createTimerList(), "0-9.", 4, new RegExp( RegExpCollection.REF_0to25_none_and_dot )  ) );
			attuneElement( widthCell + 200, 70 );
			getLastElement().setAdapter( new SecondCalculateAdapter );
			
			
			/// первые две команды заполняют сервант данными о допустимых входах
			starterCMD = [ CMD.VR_INPUT_TYPE, CMD.VR_INPUT_DIGITAL, CMD.VR_SERIAL_USE, CMD.VR_IRMA_DOOR_NUM, CMD.VR_IRMA_DOOR_INPUT , CMD.VR_IRMA_DOOR_DELAY];
		}
		
		override public function open():void
		{
			super.open();
			
		}
		
		override public function close():void
		{
			super.close();
			ValidEntersForDoorsServant.inst.clear();
		}
		
		override public function put( p:Package ):void
		{
			switch( p.cmd ) {
				
				
				
				
				case CMD.VR_IRMA_DOOR_NUM:
					pdistribute( p );
					selectCountDoor();
					break;
				case CMD.VR_IRMA_DOOR_INPUT:
					var len:int = doors.length;
					for (var i:int=0; i<len; i++) 
						doors[ i ].putData( p );
					
					loadComplete();
					break;
				case CMD.VR_IRMA_DOOR_DELAY:
					pdistribute( p );
					
					break;
				
				default:
					break;
			}
			
		}
		
		private function selectCountDoor( ifrm:IFormString = null ):void
		{
			var isCount:int = int( getField( CMD.VR_IRMA_DOOR_NUM, 1 ).getCellInfo() );
			
			
			
			for (var i:int= doors.length - 1 ; i > -1; i--) 
			{
				
				if( i >= isCount )
					doors[ i ].visible = false;
				else
					doors[ i ].visible = true;
				
				
				
			}
			
			const nowY:int = doors[ 0 ].y + doors[ 0 ].height + ( doors[ 0 ].height * isCount );
			gr.movey( "bottom", nowY );
			
			if( ifrm ) remember( ifrm );
			
		}
		
		private function createTimerList():Array
		{
			var arr:Array = new Array;
			var len:int = 10;
			var multiply:Number = .5;
			var value:Number = multiply;
			for (var i:int=1; i<len; i++) 
			{
				value = i * multiply;
				arr.push( [ value, value ] ); 
			}
			
			return UTIL.getComboBoxList( arr );
		}
	}
}
import components.abstract.functions.loc;
import components.abstract.servants.ValidEntersForDoorsServant;
import components.basement.OptionsBlock;
import components.gui.fields.FSComboBox;
import components.protocol.Package;
import components.static.CMD;
import components.system.UTIL;

class OptDoorProp extends OptionsBlock
{
	public function OptDoorProp( str:int )
	{
		structureID = str;
		
		init();
	}
	
	private function init():void
	{
		const widthCell:int = 80;
		
		addui( new FSComboBox, CMD.VR_IRMA_DOOR_INPUT, loc( "nm_door" ) + " " + structureID, null,  1 );
		attuneElement( widthCell, widthCell * 2, FSComboBox.F_COMBOBOX_NOTEDITABLE );
		
		
	}
	
	override public function putData(p:Package):void
	{
		var box:FSComboBox = getField( CMD.VR_IRMA_DOOR_INPUT, 1 ) as FSComboBox;
		box.setList( ValidEntersForDoorsServant.inst.getEnters() );
		box.setCellInfo( p.getParam( 1, structureID )  );
		if( !box.valid && !this.visible )box.setCellInfo( 0 );
		
		
		
	}
}

