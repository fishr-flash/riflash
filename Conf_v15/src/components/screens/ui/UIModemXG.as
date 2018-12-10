package components.screens.ui
{
	import components.abstract.functions.loc;
	import components.abstract.servants.TaskManager;
	import components.basement.UI_BaseComponent;
	import components.gui.fields.FSCheckBox;
	import components.gui.fields.FSShadow;
	import components.gui.fields.FSSimple;
	import components.gui.fields.FormString;
	import components.gui.visual.SIMSignal;
	import components.interfaces.ITask;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.static.CMD;
	import components.static.COLOR;
	import components.static.DS;
	
	public class UIModemXG extends UI_BaseComponent
	{
		private const LOCAL_SPAM_TIMER:int = 10000;
		
		private var task:ITask;
		private var signal:SIMSignal;
		private var opt:OptRoaming;
		
		public function UIModemXG()
		{
			super();
			
			var color:uint = COLOR.GREEN_DARK;
			var step:int = 220;
			
			addui( new FSSimple, CMD.EXT_MODEM_INFO, loc("gprs_ext_modem"), null, 1 );
			attuneElement(step, 300, FSSimple.F_CELL_NOTSELECTABLE | FSSimple.F_CELL_ALIGN_LEFT );
			(getLastElement() as FSSimple).setTextColor( color );
			addui( new FSShadow, CMD.EXT_MODEM_INFO, "", null, 2 );
			addui( new FSSimple, CMD.EXT_MODEM_INFO, loc("ui_verinfo_imei"), null, 3 );
			attuneElement(step, 300, FSSimple.F_CELL_NOTSELECTABLE | FSSimple.F_CELL_ALIGN_LEFT );
			(getLastElement() as FSSimple).setTextColor( color );
			addui( new FSSimple, CMD.EXT_MODEM_INFO, loc("ui_gprs_simcard_id"), null, 4 );
			attuneElement(step, 300, FSSimple.F_CELL_NOTSELECTABLE | FSSimple.F_CELL_ALIGN_LEFT );
			(getLastElement() as FSSimple).setTextColor( color );
			addui( new FSSimple, CMD.EXT_MODEM_INFO, loc("ui_gprs_operator"), null, 5 );
			attuneElement(step, 300, FSSimple.F_CELL_NOTSELECTABLE | FSSimple.F_CELL_ALIGN_LEFT);
			(getLastElement() as FSSimple).setTextColor( color );
			addui( new FSShadow, CMD.EXT_MODEM_INFO, "", null, 7 );
			
			signal = new SIMSignal;
			addChild( signal );
			signal.x = globalX + step;
			signal.y = globalY;
			signal.hideLabel();
			
			getLastElement().setAdapter(new SignalAdapter(signal.put));
			
			FLAG_SAVABLE = false;
			addui( new FormString, 0, loc("ui_wifi_signal_level"), null, 1 );
			attuneElement(step);
			FLAG_SAVABLE = true;
			
			drawSeparator();
			
			addui( new FSSimple, CMD.EXT_MODEM_INFO, loc("gprs_net_type"), null, 6 );
			attuneElement(step, 300, FSSimple.F_CELL_NOTSELECTABLE | FSSimple.F_CELL_ALIGN_LEFT );
			(getLastElement() as FSSimple).setTextColor( color );
			
			addui( new FSShadow, CMD.EXT_MODEM_NETWORK_CTRL, loc("gprs_connect_to")+" 2G", null, 1 );
			attuneElement(step);	
			addui( new FSCheckBox, CMD.EXT_MODEM_NETWORK_CTRL, loc("gprs_connect_to")+" 3G", null, 2 );
			attuneElement(step);
			addui( new FSCheckBox, CMD.EXT_MODEM_NETWORK_CTRL, loc("gprs_connect_to")+" 4G", null, 3 );
			attuneElement(step);
			
			height = 360;
			
			opt = new OptRoaming(3,step);
			addChild( opt );
			opt.x = globalX;
			opt.y = globalY;
			
			starterCMD = [CMD.NO_GPRS_ROAMING, CMD.EXT_MODEM_INFO, CMD.EXT_MODEM_NETWORK_CTRL];
		}
		override public function put(p:Package):void
		{
			switch(p.cmd) {
				case CMD.NO_GPRS_ROAMING:
					opt.putData(p);
					break;
				case CMD.EXT_MODEM_NETWORK_CTRL:
					update();
					loadComplete();
				case CMD.EXT_MODEM_INFO:
					distribute( p.getStructure(), p.cmd );
					break;
			}
		}
		override public function close():void
		{
			super.close();
			if( task ) {
				task.kill();
				task = null;
			}
		}
		private function update():void
		{
			if (!task)
				task = TaskManager.callLater( update, LOCAL_SPAM_TIMER);
			else {
				task.repeat();
				RequestAssembler.getInstance().fireEvent( new Request(CMD.EXT_MODEM_INFO, put));
			}
		}
	}
}
import components.abstract.functions.loc;
import components.basement.OptionsBlock;
import components.gui.fields.FSCheckBox;
import components.interfaces.IDataAdapter;
import components.interfaces.IFormString;
import components.protocol.Package;
import components.static.CMD;

class SignalAdapter implements IDataAdapter
{
	private var put:Function;
	public function SignalAdapter(f:Function):void
	{
		put = f;
	}
	public function adapt(value:Object):Object
	{
		var num:int = 0;
		switch(int(value)) {
			case 5:
				num = 25;
				break;
			case 4:
				num = 19;
				break;
			case 3:
				num = 13;
				break;
			case 2:
				num = 7;
				break;
			case 1:
				num = 1;
				break;
			case 0:
				num = 99;
				break;
			break;
		}
		put(num);
		
		return "";
	}
	public function change(value:Object):Object
	{
		return "";
	}
	public function perform(field:IFormString):void	{	}
	public function recover(value:Object):Object
	{
		return "";
	}
}
class OptRoaming extends OptionsBlock
{
	public function OptRoaming(s:int, step:int):void
	{
		super();
		
		structureID = s;
		operatingCMD = CMD.NO_GPRS_ROAMING;
		
		addui( new FSCheckBox, CMD.NO_GPRS_ROAMING, loc("ui_gprs_noroaming"), null, 1 );
		attuneElement(step);
	}
	override public function putData(p:Package):void
	{
		distribute( p.getStructure(getStructure()),p.cmd );
	}
}