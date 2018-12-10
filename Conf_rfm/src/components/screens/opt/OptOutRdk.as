package components.screens.opt
{
	import components.abstract.adapters.SwitchAdapter;
	import components.abstract.functions.loc;
	import components.abstract.servants.TaskManager;
	import components.abstract.servants.adapter.FFAdapter;
	import components.basement.OptionsBlock;
	import components.gui.fields.FSCheckBox;
	import components.gui.fields.FSComboBox;
	import components.gui.fields.FSShadow;
	import components.gui.fields.FSSimple;
	import components.gui.triggers.TextButton;
	import components.interfaces.IBaseComponent;
	import components.interfaces.IFormString;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.protocol.statics.OPERATOR;
	import components.static.CMD;
	import components.static.MISC;
	import components.static.PAGE;
	import components.system.SavePerformer;
	import components.system.UTIL;
	
	public class OptOutRdk extends OptionsBlock implements IBaseComponent
	{
		private var bTest:TextButton;
		private var opt:OptOutPatternRdk;
		
		public function OptOutRdk(n:int)
		{
			super();
			
			globalX += PAGE.CONTENT_LEFT_SHIFT;
			globalY += PAGE.CONTENT_TOP_SHIFT;
			
			structureID = n;
			
			globalXSep = PAGE.SEPARATOR_SHIFT;
			
			var sh:int = 250;
			var w:int = 250;
			var sw:int = 540;
			
			addui( new FSSimple, CMD.CTRL_NAME_OUT, loc("out_title"), null, 1, null, "", 15 );
			attuneElement( sh, w );
			
			drawSeparator(sw);

			bTest = new TextButton;
			addChild( bTest );
			bTest.x = 430;
			bTest.y = globalY;
			bTest.setFormat(true,12,"right");
			bTest.setUp(loc("g_test"),onTest);
			bTest.setWidth( 100 );
			
			addui( new FSSimple, CMD.CTRL_DOUT_SENSOR, loc("out_current_state"), null, 1 );
			attuneElement(sh,w -50,FSSimple.F_CELL_NOTSELECTABLE | FSSimple.F_CELL_ALIGN_LEFT );
			getLastElement().setAdapter(new SwitchAdapter);
			
			drawSeparator(sw);
			
			/*var l:Array = UTIL.getComboBoxList( [[1,loc("g_enabled")],[2,loc("out_switchon_1hz")],[3,loc("out_short_impulse_6sec")],[4,loc("g_disabled")]] );
			addui( new FSComboBox, CMD.CTRL_INIT_OUT, loc("out_start_state"), null, 1, l );
			attuneElement( sh, w, FSComboBox.F_COMBOBOX_NOTEDITABLE );*/
			//addui( new FSShadow, CMD.CTRL_INIT_OUT, loc("out_start_state"), null, 1 );
			addui( new FSSimple, CMD.CTRL_INIT_OUT, loc("out_start_state"), null, 1 );
			attuneElement(sh,w,FSSimple.F_CELL_NOTEDITABLE_NOTEDITBOX | FSSimple.F_CELL_ALIGN_RIGHT );
			getLastElement().setCellInfo( loc("g_disabled") );
			getLastElement().setAdapter( new OutputAdapter );
			
			addui( new FSShadow, CMD.CTRL_INIT_OUT, "", null, 2 );
			
			addui( new FSCheckBox, CMD.CTRL_INIT_OUT, loc("out_inverse"), null, 3 );
			attuneElement( sh + w-13 );
			getLastElement().setAdapter( new FFAdapter );
			
			drawSeparator(sw);
			
			var l:Array = UTIL.getComboBoxList( [[0,loc("out_no_action")],[6,loc("out_trinket_buttons")],
				[7,loc("out_sensor_alarms")],[8,loc("out_sensor_state_doppler")]] );
			addui( new FSComboBox, CMD.CTRL_TEMPLATE_OUT, loc("ui_pattern_output_control"), onPattern, 1, l );
			attuneElement( sh, w, FSComboBox.F_COMBOBOX_NOTEDITABLE );
			
			drawSeparator(sw);
			
			opt = new OptOutPatternRdk(structureID);
			addChild( opt );
			opt.x = globalX;
			opt.y = globalY;
			
			manualResize();
		}
		public function open():void
		{
			SavePerformer.LOADING = true;
			distribute( OPERATOR.getData(CMD.CTRL_NAME_OUT)[structureID-1], CMD.CTRL_NAME_OUT );
			distribute( OPERATOR.getData(CMD.CTRL_INIT_OUT)[structureID-1], CMD.CTRL_INIT_OUT );
			distribute( OPERATOR.getData(CMD.CTRL_TEMPLATE_OUT)[structureID-1], CMD.CTRL_TEMPLATE_OUT );
			onPattern();
			SavePerformer.LOADING = false;
			
			bTest.disabled = false;
		}
		private function onPattern(t:IFormString=null):void
		{
			var choise:int = int(getField(CMD.CTRL_TEMPLATE_OUT,1).getCellInfo());
			opt.open(choise);
			
			if (t)
				remember(t);
			
			manualResize();
		}
		public function close():void
		{
			if (MISC.COPY_DEBUG && MISC.SPAM_DISABLED)
				return;
			runTask(onRelease,TaskManager.DELAY_5SEC).stop();
		}
		public function put(p:Package):void
		{
			pdistribute(p);
		}
		private function onTest():void
		{
			RequestAssembler.getInstance().fireEvent( new Request(CMD.CTRL_TEST_OUT,null,structureID,[5]) );
			bTest.disabled = true;
			runTask(onRelease,TaskManager.DELAY_5SEC);
		}
		private function onRelease():void
		{
			bTest.disabled = false;
		}
	}
}
import components.abstract.functions.loc;
import components.interfaces.IDataAdapter;
import components.interfaces.IFormString;

class OutputAdapter implements IDataAdapter
{
	private var sw:int;
	
	public function adapt(value:Object):Object
	{
		sw = int(value);
		
		switch(sw) {
			case 1:
				return loc("g_enabled");
			case 2:
				return loc("out_switchon_1hz");
			case 3:
				return loc("out_short_impulse_6sec");
			case 4:
				return loc("g_disabled");
		}
		return loc("wire_state_unknwn");
	}
	
	public function change(value:Object):Object
	{
		return value;
	}
	
	public function perform(field:IFormString):void	{	}
	
	public function recover(value:Object):Object
	{
		return sw;
	}
}