package components.screens.ui
{
	import flash.media.Sound;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.utils.ByteArray;
	
	import components.abstract.WavPlayer;
	import components.abstract.functions.dtrace;
	import components.abstract.functions.loc;
	import components.abstract.servants.TaskManager;
	import components.basement.UI_BaseComponent;
	import components.gui.Balloon;
	import components.gui.FileBrowser;
	import components.gui.SimpleTextField;
	import components.gui.fields.FSCheckBox;
	import components.gui.fields.FSSimple;
	import components.gui.fields.FormString;
	import components.gui.triggers.TextButton;
	import components.interfaces.ITask;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.static.CMD;
	import components.static.COLOR;
	
	public class UICarInformer extends UI_BaseComponent
	{
		private var bPlayDevice:TextButton, bStopDevice:TextButton, bSelectFile:TextButton, bPlayPC:TextButton, bStopPC:TextButton;
		private var fsLoop:FSCheckBox;
		private var soundbytes:ByteArray;
		private var filename:String;
		private var sound:Sound;
		private var fsFilepath:FSSimple;
		private var task:ITask;
		private var wp:WavPlayer;
		private var tError:SimpleTextField;
		private var deviceBlocked:Boolean=false;
		
		private var status:Object = {1:{msg:loc("informer_playing"), color:COLOR.MENU_ITEM_BLUE},
			2:{msg:loc("informer_playing"), color:COLOR.MENU_ITEM_BLUE},
			3:{msg:loc("informer_error_playing"), color:COLOR.RED}}
		
		public function UICarInformer()
		{
			super();
			
			FLAG_SAVABLE = false;
			
			fsFilepath = addui( new FSSimple, 0, loc("informer_path"), null, 2) as FSSimple;
			attuneElement( 250, 400, FSSimple.F_MULTYLINE | FSSimple.F_CELL_ALIGN_LEFT);
			
			bSelectFile = new TextButton;
			addChild( bSelectFile );
			bSelectFile.x = globalX;
			bSelectFile.y = globalY;
			bSelectFile.setUp(loc("informer_file_for_play"), onSelect );
			
			addui( new FormString, 0, "", null, 3 ).x = 300;
			
			drawSeparator(691);
			
			bPlayPC = new TextButton;
			addChild( bPlayPC );
			bPlayPC.x = globalX;
			bPlayPC.y = globalY;
			bPlayPC.setUp(loc("informer_play_file"), onPlayPC );
			bPlayPC.disabled = true;
			
			bStopPC = new TextButton;
			addChild( bStopPC );
			bStopPC.x = globalX + 570;
			bStopPC.y = globalY;
			bStopPC.setUp(loc("informer_stop"), onStopPC );
			bStopPC.disabled = true;
			
			globalY += 30;
			
			bPlayDevice = new TextButton;
			addChild( bPlayDevice );
			bPlayDevice.x = globalX;
			bPlayDevice.y = globalY;
			bPlayDevice.setUp(loc("informer_device_play_file"), onPlayDevice );
			bPlayDevice.disabled = true;
			
			bStopDevice = new TextButton;
			addChild( bStopDevice );
			bStopDevice.x = globalX + 570;
			bStopDevice.y = globalY;
			bStopDevice.setUp(loc("informer_stop"), onStopDevice );
			
			fsLoop = addui( new FSCheckBox, 0, loc("informer_endless_play"), null, 3 ) as FSCheckBox; 
			fsLoop.x = 300;
			
			tError = new SimpleTextField("", 300);
			addChild( tError );
			tError.x = globalX;
			tError.y = globalY;
			tError.height = 50;
			tError.visible = false;
		}
		override public function open():void
		{
			super.open();
			loadComplete();
		}
		override public function put(p:Package):void
		{
			var s:int = p.getStructure()[0];
			switch(s) {
				case 3:
					Balloon.access().show( "sys_attention", "informer_error_fileplay" );
				case 1:
				case 2:
					tError.text = status[s].msg;
					tError.textColor = status[s].color;
					tError.visible = true;
					break;
				default:
					tError.visible = false;
					break;
			}
			deviceBlocked = s == 1 || s == 2;
			buttonsEnable(false);
			if (deviceBlocked)
				launchTask();
		}
		private function onPlayDevice():void
		{
			bPlayDevice.disabled = true;
			fsLoop.disabled = true;
			tError.visible = false;
			RequestAssembler.getInstance().fireEvent( new Request(CMD.SOUND_PLAY_FILE_NAME, null, 1, [0,String(fsFilepath.getCellInfo()),filename]));
			RequestAssembler.getInstance().fireEvent( new Request(CMD.SOUND_PLAY_FILE, null, 1, [ int(fsLoop.getCellInfo()) ==0 ? 1 : 2] ));
			launchTask();
		}
		private function onTimeout():void
		{
			RequestAssembler.getInstance().fireEvent( new Request(CMD.SOUND_PLAY_FILE, put ));
		}
		private function onPlayPC():void
		{
			if (!wp)
				wp= new WavPlayer;
			try {
				wp.play(soundbytes);
			} catch(error:Error) {
				dtrace( error.message );
			}
			
			soundbytes.position = 0;
		}
		private function onStopPC():void
		{
			if (wp)
				wp.stop();
		}
		private function onStopDevice():void
		{
			RequestAssembler.getInstance().fireEvent( new Request(CMD.SOUND_PLAY_FILE, null, 1, [0] ));
		}
		private function onSelect():void
		{
			buttonsEnable(true);
			FileBrowser.getInstance().open(onLoad, [new FileFilter("Waveform Audio File Format", "*.wav; *.wave;")], onCancel);
		}
		private function onCancel():void
		{
			buttonsEnable(false);
		}
		private function onLoad(b:ByteArray, fr:FileReference):void
		{
			sound = null;
			soundbytes = b;
			filename = fr.name;
			getField(0,3).setCellInfo( filename );
			bStopPC.disabled = false;
			buttonsEnable(false);
		}
		private function launchTask():void
		{
			if (!task)
				task = TaskManager.callLater( onTimeout, TaskManager.DELAY_3SEC );
			else
				task.repeat();
		}
		private function buttonsEnable(b:Boolean):void
		{
			bPlayPC.disabled = b;
			bPlayDevice.disabled = deviceBlocked || b;
			fsLoop.disabled = deviceBlocked || b;
		}
	}
}