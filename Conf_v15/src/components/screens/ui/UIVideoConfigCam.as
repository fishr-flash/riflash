package components.screens.ui
{
	import components.abstract.functions.loc;
	import components.basement.UI_BaseComponent;
	import components.gui.fields.FSCheckBox;
	import components.gui.fields.FSComboBox;
	import components.gui.fields.FSShadow;
	import components.gui.fields.FSSimple;
	import components.gui.fields.FormString;
	import components.protocol.Package;
	import components.static.CMD;
	import components.system.UTIL;
	
	public class UIVideoConfigCam extends UI_BaseComponent
	{
		public function UIVideoConfigCam()
		{
			super();
			
			var sepw:int = 500-27;
			
			addui( new FormString, 0, loc("cam_config_bias"), null, 1 );
			attuneElement( 500, NaN, FormString.F_MULTYLINE );
			
			drawSeparator(sepw);
			
			var c:int = CMD.K15_VIDEO_SETTINGS;
			
			var l:Array = UTIL.getComboBoxList([[15,"Full HD 1920x1080"],
				[14,"1280x720"],
				[13,"1280x960"],
				[12,"1024x768"],
				[11,"800x600"],
				[10,"640x480"]] );
			
			addui( new FSComboBox, c, loc("cam_video_quality"), null, 2, l );
			attuneElement( 240, 160, FSComboBox.F_COMBOBOX_NOTEDITABLE );
			drawSeparator(sepw);
			addui( new FSCheckBox, c, loc("cam_video_record_while_move"), null, 6 );
			attuneElement( 387 );
			drawSeparator(sepw);
			addui( new FSCheckBox, c, loc("cam_support_frame"), null, 5 );
			attuneElement( 387 );
			drawSeparator(sepw);
			createUIElement( new FSComboBox, c, loc("cam_fps"), null, 1,
				[{label:loc("cam_24f"),data:24},{label:loc("cam_12f"),data:12},{label:loc("cam_5f"),data:5},{label:loc("cam_1f"),data:1}]);
			attuneElement( 300, 100, FSComboBox.F_COMBOBOX_NOTEDITABLE );
			drawSeparator(sepw);			
			createUIElement( new FSSimple, c, loc("cam_bitrate"),	null, 3, null, "1-8", 1, new RegExp("^([1-8])$"));
			attuneElement( 300+59, 40 );
			
			addui( new FSShadow, c, "", null, 4 );
			addui( new FSShadow, c, "", null, 7 );
			addui( new FSShadow, c, "", null, 8 );
			
			starterCMD = c;
		}
		override public function put(p:Package):void
		{
			pdistribute(p);
			loadComplete();
		}
	}
}