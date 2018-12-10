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
	import components.static.COLOR;
	import components.static.DS;
	
	import su.fishr.utils.Dumper;
	
	public class UIVideoConfigV15Old extends UI_BaseComponent
	{
		private var LOCAL_WIDTH:int = 550;
		private var rg1:FSRadioGroup;
		private var rg2:FSRadioGroup;
		private var rg3:FSRadioGroup;
		private var warn:FormString;
		private var cameras:Vector.<OptCamera>;
		private var camNames:Vector.<OptCamName>;;

		private var go:GroupOperator;
		
		public function UIVideoConfigV15Old()
		{
			super();
			
			go = new GroupOperator;
			
			FLAG_SAVABLE = false;
			createUIElement( new FormString, 0, 
				loc("cam_config_bias"), null, 1 );
			attuneElement( 500, NaN, FormString.F_NOTSELECTABLE | FormString.F_MULTYLINE );
			FLAG_SAVABLE = true;
			drawSeparator(LOCAL_WIDTH+1);
			
			addui( new FSCheckBox, CMD.K15_VIDEO_SETTINGS, loc("cam_video_record_while_move"), null, 6 );
			attuneElement( 496 );
			drawSeparator(LOCAL_WIDTH+1);
			
			addui( new FSCheckBox, 1, loc("cam_cmop"), onCamMode, 1 );
			attuneElement( 496 );
			getLastElement().setAdapter(new CMOPAdapter);
			
			FLAG_SAVABLE = false;
			drawSeparator(LOCAL_WIDTH+1);
			
			createUIElement( new FormString, 0, loc("cam_attaching"), null, 1 );
			attuneElement( 500, NaN, FormString.F_NOTSELECTABLE );
			FLAG_SAVABLE = true;
			
			addui( new FSShadow, CMD.VIDEO_CAM_SOURCE, "", null, 1 );
			addui( new FSShadow, CMD.VIDEO_CAM_SOURCE, "", null, 2 );
			
			var opt:OptCamera;
			cameras = new Vector.<OptCamera>;
			for( var i:int=0; i<4; ++i ) {
				opt = new OptCamera(i+1);
				addChild( opt );
				if (i==3)
					opt.x = globalX + i*138;
				else
					opt.x = globalX + i*139;
				opt.y = globalY;
				cameras.push( opt );
			}
			
			globalY += 30;
			drawSeparator(LOCAL_WIDTH+1);
			
			createUIElement( new FSComboBox, CMD.K15_VIDEO_SETTINGS, loc("cam_fps"), onChange, 1,
				[{label:loc("cam_24f"),data:24},{label:loc("cam_12f"),data:12},{label:loc("cam_5f"),data:5},{label:loc("cam_1f"),data:1}]);
			attuneElement( 409, 100, FSComboBox.F_COMBOBOX_NOTEDITABLE );
			go.add( "1", getLastElement() );
			
			drawSeparator(LOCAL_WIDTH+1);
			
			rg2 = new FSRadioGroup( [ {label:loc("cam_size_d1"), selected:false, id:0x00 },
				{label:loc("cam_size_qrt"), selected:false, id:0x02 }], 1, 30 );
			addChild( rg2 );
			go.add( "1", rg2 );
			rg2.x = globalX;
			rg2.y = globalY;
			rg2.width = LOCAL_WIDTH - 54;
			
			addUIElement( rg2, CMD.K15_VIDEO_SETTINGS,2,onChange);
			globalY += rg2.height + 5;
			
			drawSeparator(LOCAL_WIDTH+1);
			
			createUIElement( new FSShadow, CMD.K15_VIDEO_SETTINGS,"",null,4 );
			createUIElement( new FSCheckBox, CMD.K15_VIDEO_SETTINGS, loc("cam_support_frame"),
				onChange, 5 );
			attuneElement( 496 );
			
			if (!DS.isDevice(DS.R15)  && !DS.isDevice(DS.R15IP)) {
				createUIElement( new FSCheckBox, CMD.VIDEO_TVIN_POWER, loc("cam_power_analog"),	null, 1 );
				attuneElement( 496 );
			}
			
			drawSeparator(LOCAL_WIDTH+1);
			
			createUIElement( new FSSimple, CMD.K15_VIDEO_SETTINGS, loc("cam_bitrate"),	null, 3, null, "1-8", 1);
			attuneElement( 469, 40 );
			
			FLAG_SAVABLE = false;
			warn = createUIElement( new FormString, 0, "", null, 1 ) as FormString;
			attuneElement(500,NaN, FormString.F_NOTSELECTABLE );
			warn.setTextColor( COLOR.RED );
			
			addui( new FSShadow(), CMD.K15_VIDEO_SETTINGS, "", null, 7 );
			addui( new FSShadow(), CMD.K15_VIDEO_SETTINGS, "", null, 8 );
			
			starterCMD = [CMD.VIDEO_CAMS, CMD.VIDEO_CAM_SOURCE, CMD.K15_VIDEO_SETTINGS];
			if (!DS.isDevice(DS.R15)  && !DS.isDevice(DS.R15IP) )
				starterRefine(CMD.VIDEO_TVIN_POWER,true);
			
			if ( ( DS.isDevice(DS.V15)|| DS.isDevice(DS.V15IP) ) && DS.release >= 5) {
				
				FLAG_SAVABLE = true;
				
				drawSeparator(LOCAL_WIDTH+1);
				
				camNames = new Vector.<OptCamName>;
				
				var optn:OptCamName;
				for( i=0; i<4; ++i ) {
					optn = new OptCamName(i+1);
					addChild( optn );
					if (i==3)
						optn.x = globalX + i*138;
					else
						optn.x = globalX + i*139;
					optn.y = globalY;
					camNames.push( optn );
				}
				
				globalY += camNames[0].complexHeight;
				
				drawSeparator(LOCAL_WIDTH+1);
				
				createUIElement( new FSSimple, CMD.VIDEO_FILE_RECORDING_TIME, loc("cam_rec_duration" ) + " 1-120 " + loc("util_056789min"),	null, 1, null, "1-9", 3, new RegExp(RegExpCollection.REF_1to120));
				attuneElement( 469-20, 60 );
				
				starterRefine(CMD.VIDEO_FILE_RECORDING_TIME,true);
				starterRefine(CMD.VIDEO_SIDE_NUMDER_VEHICLE,true);
			}
		}
		override public function open():void
		{
			warn.visible = false;
			super.open();
		}
		override public function put(p:Package):void
		{
			var len:int, i:int;
			switch( p.cmd ) {
				case CMD.VIDEO_CAMS:
					len = p.data.length;
					for(i=0; i<len; ++i ) {
						cameras[i].putRawData( p.getStructure(i+1) );
					}
					break;
				case CMD.VIDEO_CAM_SOURCE:
					distribute( p.getStructure(), p.cmd );
					var p1:int = p.getStructure()[0] & 1;
					getField(1,1).disabled = p1 == 0;
					if (p1 > 0) {
						getField(1,1).setCellInfo( p.getStructure()[1] );
						onCamMode();
					}
					break;
				case CMD.K15_VIDEO_SETTINGS:
					loadComplete();
				case CMD.VIDEO_TVIN_POWER:
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
			warn.visible = true;
			remember(t);
		}
		private function onCamMode(t:IFormString=null):void
		{
			var bit:int = int(getField(1,1).getCellInfo());
			//camBitField = bit;
			getField(CMD.VIDEO_CAM_SOURCE,2).setCellInfo( bit );
			
			var len:int = cameras.length;
			for (var i:int=0; i<len; i++) {
				cameras[i].disabled = bit == 0;
			}
			go.disabled("1", bit == 0 );
			
			if (t)
				remember(getField(CMD.VIDEO_CAM_SOURCE,2));
		}
	}
}
import components.abstract.functions.loc;
import components.basement.OptionsBlock;
import components.gui.fields.FormString;
import components.interfaces.IDataAdapter;
import components.interfaces.IFormString;
import components.protocol.Package;
import components.static.CMD;

class CMOPAdapter implements IDataAdapter
{
	
	public function adapt(value:Object):Object
	{
		if (value == 0)
			return 1;
		return 0;
	}
	public function change(value:Object):Object
	{
		return value;
	}
	public function perform(field:IFormString):void
	{
		
	}
	public function recover(value:Object):Object
	{
		if (value == true)
			return 0;
		return 1;
	}
}
class OptCamName extends OptionsBlock
{
	public function OptCamName(str:int)
	{
		super();
		
		structureID = str;
		
		addui(new FormString, 0, loc("cam_cam")+" "+str, null, 1 );
		attuneElement(100,NaN, FormString.F_ALIGN_CENTER);
		
		addui(new FormString, CMD.VIDEO_SIDE_NUMDER_VEHICLE, "", null, 1, null, "", 32 );
		attuneElement(100,NaN,FormString.F_EDITABLE);
		
		complexHeight = globalY;
	}
	override public function putData(p:Package):void
	{
		pdistribute(p);
	}
}