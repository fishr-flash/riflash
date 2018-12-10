package components.screens.ui
{
	import flash.events.Event;
	
	import components.abstract.RegExpCollection;
	import components.abstract.functions.loc;
	import components.abstract.servants.TaskManager;
	import components.basement.UI_BaseComponent;
	import components.gui.Header;
	import components.gui.PopUp;
	import components.gui.fields.FSComboBox;
	import components.gui.fields.FSSimple;
	import components.gui.triggers.TextButton;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.screens.opt.OptIPCamera;
	import components.static.CMD;
	import components.system.SavePerformer;
	
	public class UIVideoIPCofigCams extends UI_BaseComponent
	{

		private var cams:Vector.<OptIPCamera>;
		private var countCams:int = 6;

		private var rebootBtn:TextButton;
		public function UIVideoIPCofigCams()
		{
			super();
			
			
			init();
		}
		
		private function init():void
		{
			globalX = 60;
			
			globalY += 20;
			const panding:int = 300;
			addui( new FSSimple, CMD.VIDEO_SIDE_NUMDER_VEHICLE, loc( "marking_object" ), null, 1, null, "", 32 );
			attuneElement( panding, 80, FSSimple.F_CELL_ALIGN_CENTER );
			
			drawSeparator( 630 );
			
			var list:Array = new Array();
			
			
			list= 
				[
					{ data:1, label:1 },
					{ data:8, label:8 },
					{ data:10, label:10 },
					{ data:15, label:15 },
					{ data:20, label:20 },
					{ data:25, label:25 },
				]
			
			const fpsField:FSComboBox = addui( new FSComboBox(), CMD.VIDEO_IP_CAM_FPS, loc("cam_fps" ), null, 1, list, "0-9", 2, new RegExp( RegExpCollection.REF_1to60 ) ) as FSComboBox;
			attuneElement( panding, NaN, FSComboBox.F_ALIGN_CENTER );
			//fpsField.x = 325;
			
			/*const fpsField:FSSimple = addui( new FSSimple(), CMD.VIDEO_IP_CAM_FPS, loc( "cam_fps" ), null, 1, null, "0-9", 2, new RegExp( RegExpCollection.REF_1to60 ) ) as FSSimple;
			attuneElement( 200, NaN );
			fpsField.x = 325;
			*/
			
			list= 
				[
					{ data:1, label:1 },
					{ data:2, label:2 },
					{ data:5, label:5 },
					{ data:10, label:10 },
					{ data:15, label:15 },
					{ data:30, label:30 },
					{ data:60, label:60 },
				]
			
			
			
			list[ 0 ][ "selected" ] = true;
			
			const sizeRecord:FSComboBox = addui( new FSComboBox(), CMD.VIDEO_FILE_RECORDING_TIME, loc("cam_rec_duration" ) + " 1-60 " + loc("util_056789min"), null, 1, list, "0-9", 2, new RegExp( RegExpCollection.REF_1to60 ) ) as FSComboBox;
			attuneElement( panding, NaN, FSComboBox.F_ALIGN_CENTER );
			//sizeRecord.x = 262;
			
			sizeRecord.setCellInfo( 1 );
			
			rebootBtn = new TextButton();
			addChild( rebootBtn );
			rebootBtn.setUp( loc( "reboot_ip_cams" ), onReboot );
			rebootBtn.y  = globalY;
			rebootBtn.x = globalX;
			
			globalY = rebootBtn.y + rebootBtn.height;
			
			drawSeparator( 630 );
			
			const header:Header = new Header
			(
				[
					{ label:loc( "g_switchon" ) + "/" + loc( "g_switchoff" ), width:180, xpos:globalX - 20 },
					{ label:loc( "url_rtsp_the_camera" ), width:220 , xpos:320 }
					
				],
				{ size: 12 }
			);
			header.y = globalY;
			this.addChild( header );
			
			globalY += header.height+ 40;
			
			
			cams = new Vector.<OptIPCamera>( countCams );
			const yy:int = 10;
			for (var i:int=0; i<countCams; i++) 
			{
				cams[ i ] = new OptIPCamera( i + 1 );
				addopt( cams[ i ] );
				cams[ i ].x = globalX;
				if( i ) cams[ i ].y = cams[ i - 1 ].y + cams[ i - 1 ].height + yy;
				else cams[ i ].y = globalY;
				
				
				
			}
			
			const lastCam:OptIPCamera = cams[ cams.length - 1 ]; 
			globalY = lastCam.y + lastCam.height + yy; 
			
			super.manualResize();
			
			/// пока отключено так как не обрабатывается на приборе
			starterCMD = [ CMD.VIDEO_IP_CAM_FPS, CMD.VIDEO_SIDE_NUMDER_VEHICLE, CMD.VIDEO_IP_CAM_SETTINGS, CMD.VIDEO_FILE_RECORDING_TIME ];
			//starterCMD = [ CMD.VIDEO_IP_CAM_FPS, CMD.VIDEO_IP_CAM_SETTINGS ];
			
			
		}
		
		private function onReboot(  ):void
		{
			var p:PopUp = PopUp.getInstance();
			p.construct(PopUp.wrapHeader("sys_attention"), 
			PopUp.wrapMessage("reboot_ip_cams_warning"), 
			PopUp.BUTTON_OK | PopUp.BUTTON_CANCEL, [doFormat] );
			p.open();
			
			RequestAssembler.getInstance().fireEvent( new Request(CMD.VIDEO_IP_CAM_RESET, put, 1, null, 0, 1 ));
			
		}
		
		private function doFormat():void
		{
			rebootBtn.disabled = true;
			RequestAssembler.getInstance().fireEvent( new Request(CMD.VIDEO_TVIN_POWER, onFormatSuccess, 1, [ 1 ], 0, 1));
		}
		
		private function onFormatSuccess(p:Package):void
		{
			TaskManager.callLater( doRestart, TaskManager.DELAY_1MIN );
		}
		private function doRestart():void
		{
			rebootBtn.disabled = false;
		}
		
		private function delegateLock():Function
		{
			// TODO Auto Generated method stub
			return null;
		}
		
		/**
		 *  Проверяет совпадает ли номер вводимого порта
		 * с введенными в другие поля, девалидирует в случае
		 * нахождения совпадения.
		 */
		private function onChangePort( evt:Event ):void
		{
			
			var port:FSSimple = evt.currentTarget as FSSimple;
			
			if( port.forceValid == 2 ) port.forceValid = 0;
			const value:String = port.getCellInfo() as String;
			
			if( value.length < 5 ) return;
			
			var anval:String;
			var len:int = cams.length;
			for (var i:int=0; i<len; i++) 
			{
				if( cams[ i ].portIp == port ) continue;
				anval = cams[ i ].portIp.getCellInfo() as String;
				
				if( anval == value ) port.forceValid = 2;
				
				
			}
			
			
			
		}
		
		override public function open():void
		{
			super.open();
			
			//SavePerformer.trigger( { "cmd": refine } ); 
		}
		
		override public function put(p:Package):void
		{
			switch( p.cmd ) 
			{
				case CMD.VIDEO_IP_CAM_SETTINGS:
					
					for (var i:int=0; i<countCams; i++) 
					{
						cams[ i ].putData( p );	
					}
					
					loadComplete();
					break;
				
				default:
					
					pdistribute( p );
					
					
					break;
			

			}
			
			
		}
		
		/**
		 *  Особенность формирования данных в том, 
		 * что один параметр слишком длинный и его
		 * разбили на два, при получении мы сращиваем два
		 * параметра для отображения в ТФ, а перед отправкой разбиваем
		 * на два
		 * 
		 */
		private function refine( value:Object ):int
		{
			if(value is int) {
				switch(value) {
					case CMD.VIDEO_IP_CAM_SETTINGS:
					return SavePerformer.CMD_TRIGGER_TRUE;
						
				}
			} else {
				
				
				
				var fullUrl:String = value.array[ 1 ]; 
				value.array[ 1 ] = fullUrl.substr( 0, 62 );
				value.array[ 2 ] = fullUrl.substr( 62 );
				
			}
			return SavePerformer.CMD_TRIGGER_FALSE; 
			
			
			
			
		}
	}
}