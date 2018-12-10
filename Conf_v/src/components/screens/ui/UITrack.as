package components.screens.ui
{
	import components.abstract.RegExpCollection;
	import components.abstract.functions.loc;
	import components.basement.UI_BaseComponent;
	import components.gui.fields.FSCheckBox;
	import components.gui.fields.FSComboBox;
	import components.gui.fields.FSSimple;
	import components.protocol.Package;
	import components.static.CMD;
	import components.static.DS;
	
	public class UITrack extends UI_BaseComponent
	{
		public function UITrack()
		{
			super();
			
			starterCMD = [ CMD.VR_FILTER_3DFIX, CMD.VR_PACK_SIZE, CMD.VR_FILTER_TRACK];
			
			var margin_right:int = 70;
			
			var list:Array;
			if ( DS.isDevice(DS.V2) 
				|| DS.isDevice(DS.V2_3G) 
				||DS.isDevice(DS.V4) 
				|| DS.isDevice(DS.V2T)
				|| DS.isDevice(DS.VL1)
				|| DS.isDevice(DS.VL1_3G)
				|| DS.isDevice(DS.VL2)
				|| DS.isDevice(DS.VL2_3G)
				|| DS.isDevice(DS.VL3)
				|| DS.isDevice(DS.V_BRPM)
				|| DS.isDevice(DS.V_ASN)
				|| DS.isDevice(DS.V3L_3G)
				||DS.isDevice(DS.VL0) ) {
				list = [
					{data:0,label:loc("track_always")},
					{data:1,label:loc("track_moving")},
					{data:2,label:loc("track_engine_working")},
					{data:3,label:loc("track_moving_or_eng_working")},
					{data:4,label:loc("track_moving_and_eng_working")}
				];
			} else {
				list = [
					{data:0,label:loc("track_always")},
					{data:1,label:loc("track_moving")}
				];
			}
			
			
			
			createUIElement( new FSComboBox, CMD.VR_FILTER_TRACK, loc("track_record_coord"), null, 1, list );
			attuneElement( 300, 320, FSComboBox.F_COMBOBOX_NOTEDITABLE );
			
			if( DS.release < 52 )
			{
				var list2:Array =
					[
						{data:255,label:loc("g_no")}
						
					];
				
				for( var j:int = 1; j < 11; j++ )
				{
					list2.push( {data: j,label:loc(""+ j +"")} );
				}
				
				createUIElement( new FSComboBox, CMD.VR_FILTER_TRACK, loc("track_record_2min"), null, 2, list2 );
				
				attuneElement( 550, margin_right, FSComboBox.F_COMBOBOX_NOTEDITABLE | FSComboBox.F_ALIGN_CENTER  );
			}
			else
			{
				createUIElement( new FSSimple, CMD.VR_FILTER_TRACK, loc("track_record_of_time"), null, 2, null, "0-9" + loc( "g_no" ), 3, new RegExp( RegExpCollection.REF_0to600) );
				attuneElement( 550, margin_right  );
				
			}
			
			
			
			createUIElement( new FSSimple, CMD.VR_FILTER_TRACK, 
				loc("track_record_50m"), null, 3, null,"0-9",3,
				new RegExp( RegExpCollection.REF_1to255));
			attuneElement( 550, margin_right );
			
			createUIElement( new FSSimple, CMD.VR_FILTER_TRACK, 
				loc("track_record_100kmh"), null, 4, null, "0-9",3,
				new RegExp( RegExpCollection.COMPLETE_100to300));
			attuneElement( 550, margin_right );
			
			//if ( CONST.VERSION != DEVICES.V2 ) {
				
			createUIElement( new FSCheckBox, CMD.VR_FILTER_3DFIX, 
				loc("track_record_3d"), null, 1 );
			attuneElement( 550+58 );
			
			if( DS.isDevice( DS.V_ASN ) )
			{
				createUIElement( new FSCheckBox, CMD.VR_NAV_SYSTEM, 
					loc("use_only_glonass"), null, 1 );
				attuneElement( 550+58 ); 
				
				starterRefine( CMD.VR_NAV_SYSTEM, true );
			}
			
			
			drawSeparator(641);
			
			createUIElement( new FSSimple, CMD.VR_PACK_SIZE, loc("track_send_when_exceed"),
				null, 1, null, "0-9", 2, new RegExp( RegExpCollection.COMPLETE_1to30 ));
			attuneElement( 550,margin_right );
			
			
		
			
			
		}
		override public function put(p:Package):void
		{
			distribute( p.getStructure(),p.cmd);
			if (p.cmd == CMD.VR_FILTER_TRACK)
				loadComplete();
		}
	}
}