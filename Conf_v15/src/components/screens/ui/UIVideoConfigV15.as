package components.screens.ui
{
	import components.abstract.GroupOperator;
	import components.abstract.functions.loc;
	import components.basement.UI_BaseComponent;
	import components.gui.fields.FSCheckBox;
	import components.gui.fields.FSShadow;
	import components.gui.fields.FormString;
	import components.interfaces.IFormString;
	import components.protocol.Package;
	import components.screens.opt.OptCamera;
	import components.static.CMD;
	import components.static.COLOR;
	import components.static.DS;
	import components.system.SavePerformer;
	
	public class UIVideoConfigV15 extends UI_BaseComponent
	{
		private var LOCAL_WIDTH:int = 550;
		private var warn:FormString;
		private var cameras:Vector.<OptCamera>;
		
		
		public function UIVideoConfigV15()
		{
			super();
			
			
			FLAG_SAVABLE = false;
			createUIElement( new FormString, 0, 
				loc("cam_config_bias"), null, 1 );
			attuneElement( 500, NaN, FormString.F_NOTSELECTABLE | FormString.F_MULTYLINE );
			
			drawSeparator(LOCAL_WIDTH+1);
			
			FLAG_SAVABLE = true;
			
			/// Текущий источник видеосигнала, значение 0 - КМОП камера
			addui( new FSCheckBox, CMD.VIDEO_CAM_SOURCE, loc("cam_cmop"), onCamMode, 2 );
			attuneElement( 496 );
			getLastElement().setAdapter(new CMOPAdapter);
			
			/// Маска доступных типов камер, первый бит указывает на доступность КМОП-камеры
			addui( new FSShadow, CMD.VIDEO_CAM_SOURCE, "", null, 1 );
			
			FLAG_SAVABLE = false;
			drawSeparator(LOCAL_WIDTH+1);
			
			createUIElement( new FormString, 0, loc("cam_attaching"), null, 1 );
			attuneElement( 500, NaN, FormString.F_NOTSELECTABLE );
			
			FLAG_SAVABLE = true;
			
			
			
			
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
			
			if (!DS.isDevice(DS.R15)  && !DS.isDevice(DS.R15IP)) {
				createUIElement( new FSCheckBox, CMD.VIDEO_TVIN_POWER, loc("cam_power_analog"),	null, 1 );
				attuneElement( 496 );
			}
			
			
			
			FLAG_SAVABLE = false;
			
			warn = createUIElement( new FormString, 0, loc( "cam_apply_in_minute" ), null, 1 ) as FormString;
			attuneElement(500,NaN, FormString.F_NOTSELECTABLE );
			warn.y = 500; warn.x = 200;
			
			warn.setTextColor( COLOR.RED );
			
			starterCMD = [CMD.VIDEO_CAMS, CMD.VIDEO_CAM_SOURCE ];
			
			if (!DS.isDevice(DS.R15)  && !DS.isDevice(DS.R15IP))
				starterRefine(CMD.VIDEO_TVIN_POWER,true);
			
			
		}
		override public function open():void
		{
			warn.visible = false;
			super.open();
			
			SavePerformer.trigger( { "after": afterSave } );
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
					getField( CMD.VIDEO_CAM_SOURCE, 2).disabled = p1 == 0;
					if (p1 != 0) {
						onCamMode();
					}
					loadComplete();
					break;
				case CMD.VIDEO_TVIN_POWER:
					pdistribute( p );
				
			}
		}
		private function onChange(t:IFormString):void
		{
			warn.visible = true;
			remember(t);
		}
		private function onCamMode(t:IFormString=null):void
		{
			var bit:int = int(getField( CMD.VIDEO_CAM_SOURCE,2).getCellInfo());
			getField(CMD.VIDEO_CAM_SOURCE,2).setCellInfo( bit );
			
			var len:int = cameras.length;
			for (var i:int=0; i<len; i++) {
				cameras[i].disabled = bit == 0;
			}
			if (t)
				remember(getField(CMD.VIDEO_CAM_SOURCE,2));
		}
		
		private function afterSave( ):Object
		{
			
			warn.visible = true;
			return null;
		}
	}
}

import components.interfaces.IDataAdapter;
import components.interfaces.IFormString;

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
