package components.screens.ui
{
	import components.abstract.LOC;
	import components.abstract.functions.loc;
	import components.basement.UI_BaseComponent;
	import components.protocol.Package;
	import components.protocol.statics.OPERATOR;
	import components.screens.opt.OptInput;
	import components.static.CMD;
	import components.static.DS;
	import components.static.PAGE;
	
	public class UIInput extends UI_BaseComponent
	{
		private var TOTAL_IN:int;
		
		private var opts:Vector.<OptInput>;
		private var lastVisited:int = -1;

		public function UIInput()
		{
			super();
			
			TOTAL_IN = OPERATOR.getSchema( CMD.VR_INPUT_TYPE ).StructCount;
			
			globalX = PAGE.CONTENT_LEFT_SHIFT;
			
			initNavi();
			
			switch(LOC.language) {
				case LOC.EN:
					navi.setUp( openOut, 30 );
					break;
				default:
					navi.setUp( openOut, 50 );
					break;
			}
			navi.width = PAGE.SECONDMENU_WIDTH;
			navi.height = 200;
			
			for (var i:int=0; i<TOTAL_IN; ++i) {
				navi.addButton( loc("input_title")+" "+(i+1), i+1 );
			}
			
			globalX = PAGE.CONTENT_LEFT_SUBMENU_SHIFT + 10;
			
			opts = new Vector.<OptInput>(TOTAL_IN+1);	// пототму что 0 выхода нет
			
			
			
			switch(DS.alias) {
				case DS.VL0:
					starterCMD = [CMD.VR_INPUT_TYPE, CMD.VR_INPUT_ANALOG, CMD.VR_INPUT_ANALOG_VALUE, CMD.VR_INPUT_DIGITAL];
					break;
				case DS.VL1:
				case DS.VL2:
				case DS.VL3:
				case DS.V15:
				case DS.V15IP:
					starterCMD = [CMD.VR_INPUT_TYPE, CMD.VR_INPUT_DIGITAL];
					break;

				default:
					starterCMD = [CMD.VR_INPUT_TYPE, CMD.VR_INPUT_DIGITAL, CMD.VR_INPUT_ANALOG, CMD.VR_INPUT_FREQ, CMD.VR_INPUT_ANALOG_VALUE, CMD.VR_INPUT_PULSE];
					break;
			}
		}
		override public function close():void
		{
			super.close();
			var len:int = opts.length;
			for (var i:int=0; i<len; i++) {
				if( opts[i] )
					opts[i].close();
			}
		}
		override public function put(p:Package):void
		{
			switch(p.cmd) {
				case CMD.VR_INPUT_DIGITAL:
					if (  
						DS.isDevice(DS.VL1) || 
						DS.isDevice(DS.VL2) || 
						DS.isDevice(DS.VL3) || 
						DS.isDevice(DS.V15) || 
						DS.isDevice(DS.V15IP) || 
						DS.isDevice(DS.VL0) ) { 
						loadComplete();
						openOut(1);
						navi.selection = 1;
					}
					break;
				case CMD.VR_INPUT_PULSE:
					loadComplete();
					if( lastVisited > -1 )
						openOut(lastVisited);
					else
						openOut(1);
					navi.selection = lastVisited;
					break;
			}
		}
		
		
		private function openOut( value:int ):void
		{
			lastVisited = value;
			
			if (!opts[value]) {
				opts[value] = new OptInput(value);
				addChild( opts[value] );
				opts[value].x = globalX;
				opts[value].y = PAGE.CONTENT_TOP_SHIFT;
			}
			if (  
				DS.isDevice(DS.VL1) || 
				DS.isDevice(DS.VL2) || 
				DS.isDevice(DS.VL3) || 
				DS.isDevice(DS.V15) || 
				DS.isDevice(DS.V15IP) || 
				DS.isDevice(DS.VL0) )  {
				opts[value].putRawData( [
					{cmd:CMD.VR_INPUT_TYPE, data:OPERATOR.dataModel.getData(CMD.VR_INPUT_TYPE)[value-1] },
					{cmd:CMD.VR_INPUT_DIGITAL, data:OPERATOR.dataModel.getData(CMD.VR_INPUT_DIGITAL)[value-1] }
				] );
			} else {
				if (DS.isDevice(DS.VL0)) {
					opts[value].putRawData( [
						{cmd:CMD.VR_INPUT_TYPE, data:OPERATOR.dataModel.getData(CMD.VR_INPUT_TYPE)[value-1] },
						{cmd:CMD.VR_INPUT_DIGITAL, data:OPERATOR.dataModel.getData(CMD.VR_INPUT_DIGITAL)[value-1] },
						{cmd:CMD.VR_INPUT_ANALOG, data:OPERATOR.dataModel.getData(CMD.VR_INPUT_ANALOG)[value-1] },
						{cmd:CMD.VR_INPUT_ANALOG_VALUE, data:OPERATOR.dataModel.getData(CMD.VR_INPUT_ANALOG_VALUE)[value-1] }
					] );
				} else {
					opts[value].putRawData( [
						{cmd:CMD.VR_INPUT_TYPE, data:OPERATOR.dataModel.getData(CMD.VR_INPUT_TYPE)[value-1] },
						{cmd:CMD.VR_INPUT_DIGITAL, data:OPERATOR.dataModel.getData(CMD.VR_INPUT_DIGITAL)[value-1] },
						{cmd:CMD.VR_INPUT_ANALOG, data:OPERATOR.dataModel.getData(CMD.VR_INPUT_ANALOG)[value-1] },
						{cmd:CMD.VR_INPUT_FREQ, data:OPERATOR.dataModel.getData(CMD.VR_INPUT_FREQ)[value-1] },
						{cmd:CMD.VR_INPUT_PULSE, data:OPERATOR.dataModel.getData(CMD.VR_INPUT_PULSE)[value-1] },
						{cmd:CMD.VR_INPUT_ANALOG_VALUE, data:OPERATOR.dataModel.getData(CMD.VR_INPUT_ANALOG_VALUE)[value-1] }
					] );
				}
			}
			visibleOnlyOne(value);			
		}
		private function visibleOnlyOne(value:int):void
		{
			var len:int = opts.length;
			for (var i:int=0; i<len; ++i) {
				if (opts[i] )
					opts[i].visible = i == value;
			}
		}
	}
}