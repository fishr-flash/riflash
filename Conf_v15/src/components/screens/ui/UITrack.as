package components.screens.ui
{
	import components.abstract.RegExpCollection;
	import components.abstract.functions.loc;
	import components.basement.UI_BaseComponent;
	import components.gui.fields.FSComboBox;
	import components.gui.fields.FSSimple;
	import components.protocol.Package;
	import components.static.CMD;

	/** Спецредакция для К15
	 *  спрятан комбобокс "Записывать координаты"	*/
	
	public class UITrack extends UI_BaseComponent
	{
		public function UITrack()
		{
			super();
			
			var list:Array = [
				{data:0,label:loc("track_always")},
				{data:1,label:loc("track_moving")},
				{data:2,label:loc("track_engine_working")},
				{data:3,label:loc("track_moving_or_eng_working")},
				{data:4,label:loc("track_moving_and_eng_working")}
			];
			
			createUIElement( new FSComboBox, CMD.VR_FILTER_TRACK, loc("track_record_coord"), null, 1, list );
			attuneElement( 300, 300, FSComboBox.F_COMBOBOX_NOTEDITABLE );
	//		createUIElement( new FSShadow, CMD.VR_FILTER_TRACK, "", null, 1 );
			
			createUIElement( new FSSimple, CMD.VR_FILTER_TRACK, 
				loc("track_record_of_time"), null, 2,null, "0-9",2,
				new RegExp( RegExpCollection.COMPLETE_2to10) );
			attuneElement( 550, 50 );
			createUIElement( new FSSimple, CMD.VR_FILTER_TRACK, 
				loc("track_record_50m"), null, 3, null,"0-9",3,
				new RegExp( RegExpCollection.COMPLETE_50to100));
			attuneElement( 550, 50 );
			createUIElement( new FSSimple, CMD.VR_FILTER_TRACK, 
				loc("track_record_100kmh"), null, 4, null, "0-9",3,
				new RegExp( RegExpCollection.COMPLETE_100to300));
			attuneElement( 550, 50 );
			
			starterCMD = CMD.VR_FILTER_TRACK;
		}
		override public function put(p:Package):void
		{
			distribute( p.getStructure(),p.cmd);
			loadComplete();
		}
	}
}