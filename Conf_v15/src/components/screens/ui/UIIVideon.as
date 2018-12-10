package components.screens.ui
{
	import components.abstract.functions.dtrace;
	import components.abstract.functions.loc;
	import components.abstract.servants.TaskManager;
	import components.basement.UI_BaseComponent;
	import components.gui.fields.FSCheckBox;
	import components.gui.fields.FSSimple;
	import components.gui.triggers.TextButton;
	import components.interfaces.IFormString;
	import components.interfaces.ITask;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.static.CMD;
	import components.static.COLOR;
	import components.system.SavePerformer;
	
	public class UIIVideon extends UI_BaseComponent
	{
		private var task:ITask;
		private var bCommand:TextButton;
		private var wasCameraSwitch:Boolean=false;
		private var needCameraRequest:Boolean=false;
		
		public function UIIVideon()
		{
			super();
			
			var shift:int = 300;
			var shift2:int = 400;
			var sshift:int = 541;
			
			
			/**"Команда VIDEO_IV_SETTINGS - настройки IVIDION

			Параметр 1 - Активировать IVIDION, 0-нет, 1-да
			Параметр 2 - MAC - адрес для подключения
			Параметр 3 - Адрес электронной почты
			Параметр 4 - Идентификатор пользователя IVIDION (UIN)
			Параметр 5 - Имя сервера
			Параметр 6 - Пароль
			Параметр 7 - Имя камеры"	*/													
			
			
			addui( new FSCheckBox, CMD.VIDEO_IV_SETTINGS, loc("cam_ivideon"), onIvideon, 1 );
			attuneElement(shift);
			
			drawSeparator(sshift);
			
			
			
			addui( new FSSimple, CMD.VIDEO_IV_SETTINGS, loc("cam_mac"), null, 2 );
			attuneElement(shift,shift2,FSSimple.F_CELL_NOTSELECTABLE | FSSimple.F_CELL_ALIGN_LEFT);
			(getLastElement() as FSSimple).setTextColor( COLOR.GREEN );
			drawSeparator(sshift);
			
			addui( new FSSimple, CMD.VIDEO_IV_SETTINGS, loc("cam_email"), null, 3 );
			attuneElement(shift,shift2,FSSimple.F_CELL_NOTSELECTABLE | FSSimple.F_CELL_ALIGN_LEFT);
			(getLastElement() as FSSimple).setTextColor( COLOR.GREEN );
			addui( new FSSimple, CMD.VIDEO_IV_SETTINGS, loc("cam_ivideon_uin"), null, 4 );
			attuneElement(shift,shift2,FSSimple.F_CELL_NOTSELECTABLE | FSSimple.F_CELL_ALIGN_LEFT);
			(getLastElement() as FSSimple).setTextColor( COLOR.GREEN );
			addui( new FSSimple, CMD.VIDEO_IV_SETTINGS, loc("cam_srv_name"), null, 5 );
			attuneElement(shift,shift2,FSSimple.F_CELL_NOTSELECTABLE | FSSimple.F_CELL_ALIGN_LEFT);
			(getLastElement() as FSSimple).setTextColor( COLOR.GREEN );
			addui( new FSSimple, CMD.VIDEO_IV_SETTINGS, loc("g_pass"), null, 6, null, "", 63 );
			attuneElement(shift,200, FSSimple.F_CELL_NOTSELECTABLE | FSSimple.F_CELL_ALIGN_LEFT);
			(getLastElement() as FSSimple).setTextColor( COLOR.GREEN );
			addui( new FSSimple, CMD.VIDEO_IV_SETTINGS, loc("cam_name"), null, 7 );
			attuneElement(shift,shift2, FSSimple.F_CELL_NOTSELECTABLE | FSSimple.F_CELL_ALIGN_LEFT);
			(getLastElement() as FSSimple).setTextColor( COLOR.GREEN );
			
			
			
			drawSeparator(sshift);
			
			addui( new FSSimple, CMD.VIDEO_IV_STATUS, loc("g_status"), null, 1 );
			attuneElement(shift,shift2,FSSimple.F_CELL_NOTSELECTABLE | FSSimple.F_CELL_ALIGN_LEFT);
			getLastElement().setAdapter( new StatusAdapter );
			(getLastElement() as FSSimple).setTextColor( COLOR.GREEN );
			
			bCommand = new TextButton;
			addChild( bCommand );
			bCommand.setUp(loc("cam_reset"), onClick );
			bCommand.x = globalX;
			bCommand.y = globalY;
			
			height = 380;
			
			starterCMD = [CMD.VIDEO_IV_SETTINGS, CMD.VIDEO_IV_STATUS];
		}
		override public function put(p:Package):void
		{
			distribute(p.getStructure(),p.cmd);
			switch(p.cmd) {
				case CMD.VIDEO_IV_SETTINGS:
					bCommand.disabled = false;
					wasCameraSwitch = false;
					loadComplete();
					break;
				case CMD.VIDEO_IV_STATUS:
					getField(p.cmd,1).setCellInfo(p.getStructure()[0])
					if (!task)
						task = TaskManager.callLater( onRequest, TaskManager.DELAY_10SEC );
					else
						task.repeat();
					break;
				case CMD.VIDEO_IV_COMMAND:
					bCommand.disabled = false;
					RequestAssembler.getInstance().fireEvent( new Request(CMD.VIDEO_IV_SETTINGS,put));
					break;
			}
		}
		override public function open():void
		{
			super.open();
			SavePerformer.trigger({cmd:cmd, after:after});
		}
		override public function close():void
		{
			super.close();
			
			if(task)
				task.kill();
			task = null;
		}
		private function onIvideon(t:IFormString):void
		{
			wasCameraSwitch = true;
			remember(t);
		}
		private function onRequest():void
		{
			if (this.visible) {
				RequestAssembler.getInstance().fireEvent( new Request(CMD.VIDEO_IV_STATUS,put));
				if( int(getField(CMD.VIDEO_IV_STATUS,1).getCellInfo()) == 2) {
					RequestAssembler.getInstance().fireEvent( new Request(CMD.VIDEO_IV_SETTINGS,put) );
				}
			}
		}
		private function onClick():void
		{
			bCommand.disabled = true;
			RequestAssembler.getInstance().fireEvent( new Request(CMD.VIDEO_IV_COMMAND,put,1,[1]));
		}
		private function cmd(value:Object):int
		{
			if (value is int ) {
				if (int(value) == CMD.VIDEO_IV_SETTINGS && wasCameraSwitch)
					return SavePerformer.CMD_TRIGGER_TRUE;
			
			} else {
				
				needCameraRequest = true;
			}
			return SavePerformer.CMD_TRIGGER_FALSE;
		}
		private function after():void
		{
			if (needCameraRequest)
				RequestAssembler.getInstance().fireEvent( new Request(CMD.VIDEO_IV_SETTINGS,put));
			needCameraRequest = false;
		}
	}
}
import components.abstract.functions.loc;
import components.interfaces.IDataAdapter;
import components.interfaces.IFormString;

class StatusAdapter implements IDataAdapter
{
	private var status:int;
	
	public function adapt(value:Object):Object
	{
		/** Команда VIDEO_IV_STATUS - состояние подключения
			Параметр 1 - 0-Не подключено, 1-Подключено, 2-Привязывается */
		
		status = int(value); 
		switch(status) {
			case 0:
				return loc("cam_not_attached");
			case 1:
				return loc("cam_attached");
			case 2:
				return loc("cam_binding");
		}
		return loc("cam_unkwn_status")+" " + String(value);
	}
	public function change(value:Object):Object
	{
		return null;
	}
	public function perform(field:IFormString):void
	{
	}
	public function recover(value:Object):Object
	{
		return status;
	}
}