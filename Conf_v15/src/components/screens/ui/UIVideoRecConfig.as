package components.screens.ui
{
	import components.abstract.GroupOperator;
	import components.abstract.RegExpCollection;
	import components.abstract.functions.loc;
	import components.basement.UI_BaseComponent;
	import components.gui.fields.FSCheckBox;
	import components.gui.fields.FSComboBox;
	import components.gui.fields.FSRadioGroup;
	import components.gui.fields.FSShadow;
	import components.gui.fields.FSSimple;
	import components.gui.fields.FormString;
	import components.interfaces.IFormString;
	import components.protocol.Package;
	import components.screens.opt.OptCamera;
	import components.static.CMD;
	
	public class UIVideoRecConfig extends UI_BaseComponent
	{
		private static const CMOP_DEPENDENTS:String = "cmopDependents";
		private static const CAM_NAMES:String = "camNames";
		
		private var LOCAL_WIDTH:int = 600;
		private var cameras:Vector.<OptCamera>;
		private var camNames:Vector.<OptCamName>;;
		private var groups:GroupOperator = new GroupOperator();
	
		
		public function UIVideoRecConfig()
		{
			super();
			
			
			
			FLAG_SAVABLE = false;
			createUIElement( new FormString, 0, 
				loc("cam_config_bias"), null, 1 );
			attuneElement( 500, NaN, FormString.F_NOTSELECTABLE | FormString.F_MULTYLINE );
			
			drawSeparator(LOCAL_WIDTH+1);
			
			
			
			createUIElement( new FormString(), 0, loc("cam_video_record_while_event"), null, 1 );
			

			addui( new FSShadow(), CMD.VIDEO_CAM_SOURCE, "", null, 1 );
			addui( new FSShadow(), CMD.VIDEO_CAM_SOURCE, "", null, 2 );
			
			
			globalX = 70;
			const correctPaddingY:int = 5;
			const widthLabels:int = 400;
			
			FLAG_SAVABLE = true;
			
			addui( new FSShadow(), CMD.K15_VIDEO_SETTINGS, "", null, 4 );
			
			addui( new FSCheckBox(), CMD.K15_VIDEO_SETTINGS, loc("engine_is_running"), null, 7 );
			attuneElement( widthLabels );
			globalY -= correctPaddingY;
			
			
			
			addui( new FSCheckBox(), CMD.K15_VIDEO_SETTINGS, loc("vhis_header_224"), null, 8 );
			attuneElement( widthLabels, NaN );
			globalY -= correctPaddingY;
			
			addui( new FSCheckBox(), CMD.K15_VIDEO_SETTINGS, loc("triggering_the_motion_sensor"), null, 6 );
			attuneElement( widthLabels );
			globalY -= correctPaddingY;
			
			
			drawSeparator(LOCAL_WIDTH+1);
			
			
			addui( new FSComboBox, CMD.K15_VIDEO_SETTINGS, loc("cam_fps"), null, 1,
				[{label:loc("cam_24f"),data:24},{label:loc("cam_12f"),data:12},{label:loc("cam_5f"),data:5},{label:loc("cam_1f"),data:1}]);
			attuneElement( widthLabels, 100, FSComboBox.F_COMBOBOX_NOTEDITABLE );
			
			drawSeparator(LOCAL_WIDTH+1);
			
			const arrRGroup:Array =
			[
				{label:loc("cam_size_d1"), selected:false, id:0 },
				{label:loc("cam_size_qrt"), selected:false, id:2 }
			];
			
			const rGroup:FSRadioGroup = new FSRadioGroup( arrRGroup, getStructure(), 30 );
			rGroup.y = globalY;
			rGroup.x = globalX;
			rGroup.width = widthLabels;
			addChild( rGroup );
			addUIElement( rGroup, CMD.K15_VIDEO_SETTINGS, 2);
			groups.add( CMOP_DEPENDENTS, rGroup );
			
			globalY += rGroup.height + 20;
			
			groups.add( CMOP_DEPENDENTS, addui( new FSCheckBox(), CMD.K15_VIDEO_SETTINGS, loc("cam_support_frame"), null, 5 ) );
			attuneElement( widthLabels );
			
			globalY += 20;
			
			FLAG_SAVABLE = false;
			
			groups.add( CMOP_DEPENDENTS, addui( new FormString(), 0, loc("cam_names"), null, 1, null, "" ) );
			attuneElement( widthLabels );

			FLAG_SAVABLE = true;
			
			const camersCount:int = 4;
			camNames = new Vector.<OptCamName>( camersCount );
			
			for (var i:int=0; i<camersCount; i++) {
				camNames[ i ] = new OptCamName( i + 1 );
				
				addChild( camNames[ i ] );
				camNames[ i ].y = globalY;
				
				
				if( i )
				{
					camNames[ i ].y = camNames[ i - 1 ].y;
					camNames[ i ].x = camNames[ i - 1 ].x + camNames[ i - 1 ].width - 75;
					
				
				}
				else
				{
					camNames[ i ].x = globalX;
				}
				
			}
			
			globalY = camNames[ 0 ].y + 50;
			
			FLAG_SAVABLE = false;
			drawSeparator(LOCAL_WIDTH+1);
			
			FLAG_SAVABLE = true;
			
			addui( new FSSimple(), CMD.K15_VIDEO_SETTINGS, loc("cam_bitrate"), null, 3, null, "0-9", 1, new RegExp( RegExpCollection.REF_1to8 ) );
			attuneElement( widthLabels, 45 );
			
			
			addui( new FSSimple(), CMD.VIDEO_FILE_RECORDING_TIME, loc("cam_rec_duration" ) + " 1-120 " + loc("util_056789min"), null, 1, null, "0-9", 3, new RegExp( RegExpCollection.REF_1to120 ) );
			attuneElement( widthLabels, 45 );
			
			
			
			
			starterCMD = [CMD.K15_VIDEO_SETTINGS, CMD.VIDEO_FILE_RECORDING_TIME, CMD.VIDEO_SIDE_NUMDER_VEHICLE, CMD.VIDEO_CAM_SOURCE];
			
		}
		override public function open():void
		{
			
			super.open();
		}
		override public function put(p:Package):void
		{
			
			var len:int, i:int;
			switch( p.cmd ) {
				
				case CMD.VIDEO_CAM_SOURCE:
					pdistribute( p );
					
					onCamMode();
					loadComplete();
					break;
				case CMD.K15_VIDEO_SETTINGS:
					pdistribute(p);
					
				case CMD.VIDEO_FILE_RECORDING_TIME:
					pdistribute(p);
					break;
				case CMD.VIDEO_SIDE_NUMDER_VEHICLE:
					len = p.data.length;
					for(i=0; i<len; ++i ) {
						camNames[i].putData( p );
					}
					break;
			}
			
			
		}
		private function onChange(t:IFormString):void
		{
			
			remember(t);
		}
		private function onCamMode():void
		{
			var bit:int = int(getField( CMD.VIDEO_CAM_SOURCE,2).getCellInfo());
			
			getField(CMD.VIDEO_CAM_SOURCE,2).setCellInfo( bit );
			
			var len:int = camNames.length;
			for (var i:int=0; i<len; i++) {
				camNames[i].freeze = bit == 0;
			}
			
			groups.disabled( CMOP_DEPENDENTS, bit == 0 );
			
			
		}
	}
}
import components.abstract.functions.loc;
import components.basement.OptionsBlock;
import components.gui.fields.FormString;
import components.protocol.Package;
import components.static.CMD;




class OptCamName extends OptionsBlock
{
	public function OptCamName(str:int)
	{
		super();
		
		structureID = str;
		
		addui(new FormString, 0, loc("cam_cam")+" "+str, null, 1 );
		attuneElement(100,NaN, FormString.F_ALIGN_CENTER);
		//attuneElement( 65, 100, FSSimple.F_COLOUMN_ORIENT );
		addui(new FormString, CMD.VIDEO_SIDE_NUMDER_VEHICLE, "", null, 1, null, "", 32 );
		attuneElement(100,NaN,FormString.F_EDITABLE);
		getLastElement().y -= 10;
		complexHeight = globalY;
	}
	override public function putData(p:Package):void
	{
		pdistribute(p);
	}
}