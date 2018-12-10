package components.screens.ui
{
	import components.abstract.RegExpCollection;
	import components.abstract.functions.dtrace;
	import components.abstract.functions.loc;
	import components.abstract.servants.TaskManager;
	import components.basement.UI_BaseComponent;
	import components.gui.fields.FSCheckBox;
	import components.gui.fields.FSSimple;
	import components.gui.fields.FormString;
	import components.gui.visual.SIMSignal;
	import components.interfaces.ITask;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.protocol.statics.CLIENT;
	import components.static.CMD;
	import components.system.SavePerformer;
	
	public class UIGeneralOptions extends UI_BaseComponent
	{
		private var task:ITask;
		private var signal:SIMSignal;
		
		public function UIGeneralOptions()
		{
			super();
			
			
			
			addui( new FSSimple, CMD.OP_o_OBJECT, loc("options_objnum"), null, 1, null,"B-Fb-f0-9", 4, new RegExp( RegExpCollection.REF_CODE_OBJECT ) );
			RegExpCollection
			attuneElement( 300, 100 );
			addui( new FSSimple, CMD.OP_FMR_MASTERKEY, loc("options_programming_code"), null, 1, null, "0-9", 4, new RegExp(/\d\d\d\d/g) );
			attuneElement( 300, 100, FSSimple.F_NOTSELECTABLE );
			
			signal = new SIMSignal;
			addChild(signal);
			signal.x = 300 + globalX;
			signal.y = globalY + 2;
			
			addui( new FormString, CMD.OP_AQ_GSM_SIGNAL, loc("ui_gprs_signal_level"), null, 1 );
			attuneElement( 300 );
			
			drawSeparator(441);
			
			addui( new FSCheckBox, CMD.OP_P2_IMEI, loc("gprs_use_imei_protocol"), null, 1 );
			attuneElement( 300 + 88 );
				
			starterCMD = [CMD.OP_o_OBJECT, CMD.OP_FMR_MASTERKEY, CMD.OP_P2_IMEI, CMD.OP_AQ_GSM_SIGNAL];
		}
		override public function close():void
		{
			super.close();
			if (task)
				task.kill();
			task = null;
		}
		override public function put(p:Package):void
		{
			if (p.cmd == CMD.OP_AQ_GSM_SIGNAL) {
				if (!task)
					task = TaskManager.callLater( onTick, CLIENT.TIMER_EVENT_SPAM );
				if (p.data) {
					var sig:Array = (p.data[0][0] as String).split(" ");
					signal.put31( int( "0x"+String(sig[1]) ) );
					SavePerformer.trigger( {"cmd":cmd} );
					loadComplete();
				} else {
					dtrace( "UIGeneralOptions:ERROR p.data == null>" );
				}
			} else
				distribute(p.getStructure(), p.cmd );
		}
		private function onTick():void
		{
			task.repeat();
			RequestAssembler.getInstance().fireEvent( new Request( CMD.OP_AQ_GSM_SIGNAL, put) );
		}
		private function cmd(value:Object):int
		{
			if (value is int ) {
				if (int(value) == CMD.OP_o_OBJECT)
					return SavePerformer.CMD_TRIGGER_TRUE;
			} else {
				var obj:String = String(getField(CMD.OP_o_OBJECT,1).getCellInfo());
				if (obj.length < 4) {
					while(obj.length < 4)
						obj = "0"+obj;
					getField(CMD.OP_o_OBJECT,1).setCellInfo(obj);
				}
				value.array[0] = obj;
			}
			return SavePerformer.CMD_TRIGGER_FALSE;
		}
	}
}