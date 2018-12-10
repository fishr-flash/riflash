package components.screens.opt
{
	import flash.utils.getTimer;
	
	import components.abstract.functions.dtrace;
	import components.abstract.functions.loc;
	import components.abstract.servants.SmsVjsServant;
	import components.basement.OptionListBlock;
	import components.events.GUIEventDispatcher;
	import components.events.GUIEvents;
	import components.gui.fields.FSCheckBoxSimple;
	import components.gui.fields.FSComboBox;
	import components.gui.fields.FSShadow;
	import components.gui.fields.FormString;
	import components.interfaces.IFormString;
	import components.interfaces.IListItem;
	import components.protocol.Package;
	import components.protocol.statics.OPERATOR;
	import components.static.CMD;
	
	import su.fishr.utils.Dumper;
	import su.fishr.utils.searcPropValueInArr;
	
	/**
	 * Клон OptSms_text, ориентированный для 
	 * серии вояджеров 2,3 L... и тд 
	 * @author r.kasymov
	 * 
	 */	
	public class OptSms_text_v extends OptionListBlock implements IListItem
	{
		
		private var field1:FSComboBox;
		private var field2:FormString;
		private var field3:FSCheckBoxSimple;

		
		public function OptSms_text_v(_struct:int)
		{
			super();
			
			structureID = _struct;
			FLAG_VERTICAL_PLACEMENT = false;
			operatingCMD = CMD.VR_SMS_NOTIF;
			
			globalFocusGroup = 3050;
			
			var block:Object = SmsVjsServant.getSetMessages()[ structureID ]; 
			var lbl:String = "";
			var id:String = "";
			if( block ) 
			{
				lbl = block.label;
				id = block.data + "";
			}
			
			addui( new FSShadow(), operatingCMD, id, null, 1 );
			
			/// наименование события соотв. его  идентификатору по VR_SMS_NOTIF_LIST
			/*field1 = createUIElement( new FormString, 0, lbl, change, 1, null,"",25) as FormString;
			attuneElement(300,NaN, FormString.F_NOT_EDITABLE_WITH_BORDER );*/
			
			field1 = createUIElement( new FSComboBox, 0, "", change, 1, block as Array,"",25) as FSComboBox;
			attuneElement(NaN, 300);
			
			if( !lbl )this.visible = true;
			//field1.disabled = true;
			
			/// пользовательское наименование события
			field2 = createUIElement( new FormString,operatingCMD, lbl,null,2,null,"",25) as FormString;
			attuneElement(300,NaN, FormString.F_EDITABLE );
			
			field2.x = 305;
			field2.fillBlank(loc("g_no"));
			
			
			
			addui( new FSShadow, CMD.VR_SMS_LOCATION_ENABLE, "", null, 1 );
			attuneElement( NaN, NaN, FSShadow.F_SHOULD_EVOKE_CHANGE );
			
			
			
			
			
			
			field3 = createUIElement( new FSCheckBoxSimple, operatingCMD, "", null, 3 ) as FSCheckBoxSimple;
			attuneElement( NaN, NaN );
			field3.x = 725;
			
			addui( new FSCheckBoxSimple, CMD.VR_SMS_LOCATION_ENABLE, "", null, 2 );
			attuneElement( NaN, NaN );
			getLastElement().x = 880;
			
			
			
			
			
		}
		override public function putRawData(a:Array):void
		{
				
			
			
			const inx:int = searcPropValueInArr( "data", a[ 0 ],  SmsVjsServant.getSetMessages() );
				
			
			
			getField( operatingCMD, 1 ).setCellInfo( a[ 0 ] );
			
			const data:Object = SmsVjsServant.getSetMessages()[ inx ];

			field1.setList( [ data ], 0  );

			
			
			field1.setCellInfo( SmsVjsServant.getSetMessages()[ inx ].data );
			
			field2.setCellInfo( (a[1]).toString() );
			field3.setCellInfo( (a[2]) );
			
			setFill();
			
			/// если данные изменены в UIVSms после получения и нуждаются в записи
			if( a[ 3 ] )
			{
				
				remember( field2 );
				remember( field3 );
			}
				
			
			/// этот элемент создан чтобы затереть отключенные смски
			//this.visible = a[ 0 ] != 0;
			
				if( a[ 0 ] == 0 && this.parent ) this.parent.removeChild( this );	
			
			
				
		}
		
		
		
		override public function getFieldsData():Array 
		{
			const arr:Array = [ getField( operatingCMD, 1 ).getCellInfo(),  field2.getCellInfo(), field3.getCellInfo(), field1.getCellInfo()  ]; 
			
			return arr;
		}
		
		public function recovery():void
		{
			field2.setCellInfo( getLabel() );
			remember( field2 );
		}
		
		private function setFill():void
		{
			if(field1.getCellInfo() != 0 && ( !field2.getCellInfo() || field2.getCellInfo() == loc( "g_no" ) ) )
			{
				field2.setCellInfo( getLabel() );//.fillBlank(txt);
				remember( field2 );
			}
		}
		private function change(target:IFormString):void
		{
			
			
			const inx:int = searcPropValueInArr( "data", target.getCellInfo(),  SmsVjsServant.getSetMessages() );
			
			const type:IFormString = getField( operatingCMD, 1 );
			type.setCellInfo( field1.getCellInfo() );
			remember( type );
			
			field2.setCellInfo(  SmsVjsServant.getSetMessages()[ inx ].label );//.fillBlank(txt);
			remember( field2 );
			
			field3.setCellInfo( true );
			//( getField( CMD.VR_SMS_LOCATION_ENABLE, 2 ) as FSCheckBoxSimple ).setCellInfo(  getField( CMD.VR_SMS_LOCATION_ENABLE, 2 ).getCellInfo() );
			( getField( CMD.VR_SMS_LOCATION_ENABLE, 2 ) as FSCheckBoxSimple ).setCellInfo( 0 );
			getField( CMD.VR_SMS_LOCATION_ENABLE, 1 ).setCellInfo( type.getCellInfo()  );
			
			
			remember( getField( CMD.VR_SMS_LOCATION_ENABLE, 1 ) );
			remember( getField( CMD.VR_SMS_LOCATION_ENABLE, 2 ) );
			remember( field2 );
			remember( field3 );
			
			GUIEventDispatcher.getInstance().fireEvent( GUIEvents, GUIEvents.CHANGE_SMS_TYPE, {"id": structureID});
			
			
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
		
		public function putLocEnb(p:Package):void
		{
			
			
			getField( CMD.VR_SMS_LOCATION_ENABLE, 1 ).setCellInfo( p.data[ structureID - 1 ][ 0 ] );
			getField( CMD.VR_SMS_LOCATION_ENABLE, 2 ).setCellInfo( p.data[ structureID - 1 ][ 1 ] );
			
			/// если данные изменены после получения в UIVSms.as
			if( p.data[ structureID - 1 ][ 2 ] ){
				remember(getField( CMD.VR_SMS_LOCATION_ENABLE, 1 ) )
				remember(getField( CMD.VR_SMS_LOCATION_ENABLE, 2 ) )
			}
				
			
		}
		
		private function getLabel( ):String
		{
			
			
			const inx:int = searcPropValueInArr( "data", field1.getCellInfo(),  SmsVjsServant.getSetMessages() );
			
			
			
			return  String(  SmsVjsServant.getSetMessages()[ inx ].label );
		}
	}
}