package components.screens.ui
{
	import components.abstract.functions.loc;
	import components.abstract.servants.TaskManager;
	import components.basement.UI_BaseComponent;
	import components.gui.fields.FSComboBox;
	import components.gui.fields.FormString;
	import components.gui.triggers.TextButton;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.protocol.SocketProcessor;
	import components.static.CMD;
	import components.system.SavePerformer;
	import components.system.UTIL;
	
	public class UILinkChannels extends UI_BaseComponent
	{
		private var bApply:TextButton;
		
		public function UILinkChannels()
		{
			super();
			
			/**	Команда CH_VR_COM_LINK - каналы связи в приборе Вояджер 2N - WIFI
				Параметр 1 - установленные каналы связи, 0-только GPRS, 1-только GPRS, 2- только WIFI, 3-Сначала WIFI, затем GPRS */
			
			var l:Array = UTIL.getComboBoxList( [[1,loc("ui_linkch_gprs_only")],[2,loc("ui_linkch_wifi_only")],[3,loc("ui_linkch_wifi_then_gprs")]] );
			
			addui( new FSComboBox, CMD.CH_VR_COM_LINK, loc("ui_linkch_establish_connection"), null, 1, l );
			attuneElement( 250, 250, FSComboBox.F_COMBOBOX_NOTEDITABLE );
			getLastElement().setAdapter(new CHAdapter);
			
			globalY+=10;
			
			bApply = new TextButton;
			addChild( bApply );
			bApply.x = 400-26+83;
			bApply.y = globalY;
			bApply.setUp(loc("g_apply"), onApply );
			
			addui( new FormString, 0, loc("ui_linkch_change_after_connect"), null, 1 );
			attuneElement( 300, NaN, FormString.F_MULTYLINE );
			
			starterCMD = CMD.CH_VR_COM_LINK;
		}
		override public function put(p:Package):void
		{
			distribute(p.getStructure(),p.cmd);
			loadComplete();
		}
		private function onApply():void
		{
			SavePerformer.saveForce(onSave);
			loadStart();
			blockNaviSilent = true;
		}
		private function onSave():void
		{
			RequestAssembler.getInstance().fireEvent( new Request(CMD.REBOOT, null, 1, [1]));
			TaskManager.callLater( SocketProcessor.getInstance().reConnect, TaskManager.DELAY_1SEC*5 );
		}
	}
}
import components.interfaces.IDataAdapter;
import components.interfaces.IFormString;

class CHAdapter implements IDataAdapter
{
	public function adapt(value:Object):Object
	{
		if (int(value)==0)
			return 1;
		return value;
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
		return value;
	}
}