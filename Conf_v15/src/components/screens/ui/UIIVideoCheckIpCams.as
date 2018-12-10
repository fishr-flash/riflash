package components.screens.ui
{
	import flash.events.Event;
	import flash.text.TextFormat;
	
	import components.abstract.functions.loc;
	import components.abstract.servants.TaskManager;
	import components.abstract.servants.WidgetMaster;
	import components.basement.UI_BaseComponent;
	import components.events.GUIEventDispatcher;
	import components.events.GUIEvents;
	import components.events.SystemEvents;
	import components.gui.SimpleTextField;
	import components.gui.fields.FormString;
	import components.gui.triggers.TextButton;
	import components.gui.visual.ScreenBlock;
	import components.interfaces.ITask;
	import components.interfaces.IWidget;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.protocol.statics.OPERATOR;
	import components.screens.opt.OptCondIPRecorder;
	import components.screens.opt.OptTakePhotoIpCam;
	import components.static.CMD;
	import components.static.COLOR;
	
	public class UIIVideoCheckIpCams extends UI_BaseComponent implements IWidget
	{

		private var optIpCamCondit:Vector.<OptCondIPRecorder>;
		private var waitingOfCam:int;
		private var waitAllCams:Boolean;
		private var optPhotos:Vector.<OptTakePhotoIpCam>;
		
		public function UIIVideoCheckIpCams()
		{
			super();
			
			init();
		}
		
		override public function put(p:Package):void
		{
			
			switch( p.cmd ) 
			{
				case CMD.GET_RECORD_CAM_STATE:
					putConditions( p );
					loadComplete();
					break;
				
				case CMD.SEND_PHOTO_SHOT:
					
					optPhotos[ waitingOfCam - 1 ].putData( p );
					
					break;
				
				default:
					pdistribute( p );		
					break;
			}
			
			
		}
		
		override public function open():void
		{
			super.open();
			WidgetMaster.access().registerWidget( CMD.SEND_PHOTO_SHOT, this );
			GUIEventDispatcher.getInstance().addEventListener( GUIEvents.CLICK_GET_PHOTO_SHOT, takeSnapshot );
		}
		
		override public function close():void
		{
			super.close();
			
			RequestAssembler.getInstance().doPing( true );
			GUIEventDispatcher.getInstance().removeEventListener( GUIEvents.CLICK_GET_PHOTO_SHOT, takeSnapshot );
			GUIEventDispatcher.getInstance().removeEventListener( GUIEvents.RECEPTION_PHOTO_COMPLETE, receptionPhotoComplete );
			WidgetMaster.access().unregisterWidget( CMD.SEND_PHOTO_SHOT );
		}
		
		private function init():void
		{
				
			
				const sign:SimpleTextField = new SimpleTextField( loc("condition_devices_records") + ": ", 600 );
				sign.setTextFormat( new TextFormat( null, null, null, true ) );
				addChildAtypical( sign );
				
				globalY += 10;
				
				var len:int = OPERATOR.getSchema( CMD.GET_RECORD_CAM_STATE ).StructCount;
				optIpCamCondit = new Vector.<OptCondIPRecorder>( len );
				var xx:int = globalX;
				var yy:int = globalY;
				for (var i:int=0; i<len; i++) 
				{
					optIpCamCondit[ i ]  = addopt( new OptCondIPRecorder( i + 1 ) ) as OptCondIPRecorder;
					optIpCamCondit[ i ].x = xx;
					optIpCamCondit[ i ].y = yy;
					
					if( i + 1 == len / 2 )
					{
						yy += optIpCamCondit[ i ].height;
						xx = globalX;
					}
					else
					{
						xx += optIpCamCondit[ i ].width + 20;
					}
					
					

				}
				
				globalY = yy + optIpCamCondit[ i - 1 ].height;
				
				drawSeparator( 700 );
				
				const sign2:SimpleTextField = new SimpleTextField( loc("take_photo_with_cams") + ": ", 600 );
				sign2.setTextFormat( new TextFormat( null, null, null, true ) );
				addChildAtypical( sign2 );
				
				
				var tbAllCamsPhotos:TextButton = new TextButton();
				tbAllCamsPhotos.setUp( loc( "get_photo_with_all_cams" ), onClick );
				tbAllCamsPhotos.x = globalX;
				tbAllCamsPhotos.y = globalY;
				globalY += tbAllCamsPhotos.height;
				this.addChild( tbAllCamsPhotos );
				
				addui( new FormString, 0, loc("Внимание! Выполнение этой команды \r может занять продолжительное время."), null, 1 );
				attuneElement( 300, NaN, FormString.F_TEXT_MINI | FormString.F_TEXT_BOLD );
				( getLastElement() as FormString ).setTextColor( COLOR.RED_BLOOD );
				
				optPhotos = new Vector.<OptTakePhotoIpCam>( len );
				for ( i=0; i<len; i++) 
				{
					optPhotos[ i ]  = this.addChild( new OptTakePhotoIpCam( i + 1 ) ) as OptTakePhotoIpCam;
					
					optPhotos[ i ].x = globalX;
					
					if( i && (i%2) )
						optPhotos[ i ].x = optPhotos[ i - 1 ].x + optPhotos[ i - 1 ].width + 20;
					else
						globalY += optPhotos[ i ].height;
					
					optPhotos[ i ].y = globalY;
					
					
				}
				
				
				
				
				starterCMD = [ CMD.GET_RECORD_CAM_STATE];
		
		}
		
		private function takeSnapshot(event:GUIEvents = null ):void
		{ 
			
			
			if( event )
			{
				waitAllCams = false;
				waitingOfCam = event.serviceObject.id;
				activateInterface( false );
				
			}
			else if( waitAllCams && waitingOfCam < optPhotos.length )
			{
				waitingOfCam++;
			}
			else
			{
				waitAllCams = false;
				waitingOfCam = 0;
				receptionPhotoComplete( null );
				return;
			}
			
			
			
			GUIEventDispatcher.getInstance().addEventListener( GUIEvents.RECEPTION_PHOTO_COMPLETE, receptionPhotoComplete );
			RequestAssembler.getInstance().fireEvent( new Request( CMD.GET_PHOTO_SHOT, null, 1, [ waitingOfCam, 0xFF, 0xFF ] ));
			RequestAssembler.getInstance().doPing( false );
			
			
			
			
		}
		
		private function receptionPhotoComplete(event:Event):void
		{
			if( !waitAllCams )
			{
				GUIEventDispatcher.getInstance().removeEventListener( GUIEvents.RECEPTION_PHOTO_COMPLETE, receptionPhotoComplete );
				activateInterface( true );
			}
			else
			{
				takeSnapshot();
			}
			
			repositionOptPh();
			
		}
		
		
		private function onClick(  ):void
		{
			waitingOfCam = 0;
			waitAllCams = true;
			activateInterface( false );
			takeSnapshot();
		}
		
		
		
		private function putConditions(p:Package):void
		{
			var len:int = optIpCamCondit.length;
			for (var i:int=0; i<len; i++)optIpCamCondit[ i ].putData( p );
			
		}		
		
		private function activateInterface( enabl:Boolean ):void
		{
			if( enabl )
			{
				
				GUIEventDispatcher.getInstance().fireEvent( GUIEvents, GUIEvents.onNeedScreenBlock );
				GUIEventDispatcher.getInstance().fireSystemEvent( SystemEvents.onBlockNavigation, {"isBlock":false } );
			}
			else
			{
				GUIEventDispatcher.getInstance().fireEvent( GUIEvents, GUIEvents.onNeedScreenBlock,
					{getScreenMode:ScreenBlock.MODE_ONLY_BLOCK, getScreenMsg:""} );
				GUIEventDispatcher.getInstance().fireSystemEvent( SystemEvents.onBlockNavigation, {"isBlock":true} );
				
			}
		}
		
		private function repositionOptPh():void
		{
			var len:int = optPhotos.length;
			var yy:int = optPhotos[ 0 ].y;
			var xx:int = optPhotos[ 0 ].x;
			var heightPrev:int;
			
			/// Чтобы корректно определить нижнюю границу экрана
			var bottomBorder:int;
			var bottomBorderId:int;
			
			/// для выравнивания столбцов
			var xBorder:int;
			
			for ( var i:int =0; i<len; i++) 
			{
				
				optPhotos[ i ].y = yy;
				optPhotos[ i ].x = xx;
				
				if( i && (i%2) ) /// нечетные камеры по индексу в массиве
				{
					optPhotos[ i ].x = optPhotos[ i - 1 ].x + optPhotos[ i - 1 ].width + 20;
					yy += heightPrev > optPhotos[ i ].height?heightPrev:optPhotos[ i ].height;
					if( optPhotos[ i ].x > xBorder ) xBorder = optPhotos[ i ].x;
				}	
				else
				{
					heightPrev = optPhotos[ i ].height;
				}
				
				if( optPhotos[ i ].y + optPhotos[ i ].height > bottomBorder )
				{
					bottomBorder = optPhotos[ i ].y + optPhotos[ i ].height;
					bottomBorderId = i;
				}
				
			}
			
			for ( i =0; i<len; i++)
				if( i && (i%2) )
					optPhotos[ i ].x = xBorder;
			
			/// поднимаем наверх эл-т имеющий самую нижнию границу для правильного ресайза экрана
			optPhotos[ bottomBorderId ].parent.addChild( optPhotos[ bottomBorderId ] ); 
			
			manualResize();
		}
		
	}
}