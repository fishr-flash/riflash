package components.screens.ui
{
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import components.abstract.functions.loc;
	import components.basement.UI_BaseComponent;
	import components.events.GUIEventDispatcher;
	import components.events.GUIEvents;
	import components.gui.fields.FSCheckBox;
	import components.gui.fields.FormString;
	import components.gui.visual.Indent;
	import components.gui.visual.ScreenBlock;
	import components.protocol.Package;
	import components.protocol.RequestAssembler;
	import components.protocol.statics.SERVER;
	import components.static.CMD;
	import components.static.DS;
	import components.static.MISC;
	import components.system.SavePerformer;
	
	public class UILockFromWriters extends UI_BaseComponent
	{

		private var chb:FSCheckBox;

		private var timerDeleting:Timer;
		public function UILockFromWriters()
		{
			super();
			
			init();
		}
		
		private function init():void
		{
			starterCMD = [ ];
				
				chb  = addui( new FSCheckBox(), CMD.CH_COM_LINK_LOCK, loc( "lock_from_writer_option" ), null, 1 ) as FSCheckBox;
				attuneElement( 400 );
				globalY += 50;
				//chb.bitnum = 0xff;
				chb.setAdapter( new ChbAdapter() );
				
				
				chb.disabled = (  SERVER.CONNECTION_TYPE == !( SERVER.CONNECTION_GPRS ) ) || !SERVER.isGeoritm() && MISC.COPY_DEBUG == false;
				
				
				
			starterCMD.push( CMD.CH_COM_LINK_LOCK );
			
				FLAG_SAVABLE = false;
				
				const fString:FormString = new FormString();
				fString.alpha = .9;
				fString.setWidth( 500 );
				//fString.attune( FormString.F_MULTYLINE );
				const comment:String = DS.isDevice( DS.A_BRD )?"lock_from_writer_comment_cut":"lock_from_writer_comment";
				fString.setName( loc( comment ) );
				fString.x = globalX;
				fString.y = globalY + 125;
				
				this.addChild( fString );
				
				const indent:Indent = drawIndent( fString.height );
				indent.x = globalX;
				indent.y = fString.y - 135;
				fString.x = indent.x + indent.width + 5;
				
				globalY = indent.y + indent.height;
				globalX += 20;
				
				drawSeparator( );
				
			/// на K-16 запрос VER_INFO1 не делается и неизвестен на этапе загрузки конфигуратора
			/// поэтому обрабатываем его отдельно
			if( !SERVER.CONNECTION_TYPE ) starterCMD.unshift( CMD.VER_INFO1 );
			
			
		}
		
		override public function put(p:Package):void
		{
			
			
			switch( p.cmd ) {
				case CMD.VER_INFO1:
					
					chb.disabled = ( String( p.getStructure()[ 0 ] ).toLowerCase() == !( SERVER.CONNECTION_GPRS ) ) || !SERVER.isGeoritm() && MISC.COPY_DEBUG == false;
					
					break;

				default:
					// долбаный кастыль, потому что адаптер не удалось приспособить
					/// для изменения состаяния чекбокса при входе на экран
					if( p.data[ 0 ][ 0 ] == 0 ) p.data[ 0 ][ 0 ] = 1;
					else p.data[ 0 ][ 0 ] = 0;
					
					
					pdistribute( p );		
					if( DS.isfam( DS.K14 ) ) SavePerformer.trigger( { "after":upSafeScreen } );
					
					loadComplete();
					break;
			}
			
		}
		
			
		
		private function upSafeScreen():void
		{
						
			var txt:String = loc("sys_process_take_awhile");
			GUIEventDispatcher.getInstance().fireEvent( GUIEvents, GUIEvents.onNeedScreenBlock, 
				{getScreenMode:ScreenBlock.MODE_LOADING_TEXT, getScreenMsg:txt} );
			blockNavi = true;
			
			timerDeleting = new Timer( 25000, 1 );
			timerDeleting.addEventListener( TimerEvent.TIMER_COMPLETE, deleteIncomplete );
			timerDeleting.reset();
			timerDeleting.start();
		}
		
		private function deleteIncomplete(ev:TimerEvent):void
		{
			//Warning.show( "Подключен "+SERVER.READABLE_VER+", Ошибка удаления истории", Warning.TYPE_ERROR, Warning.STATUS_DEVICE );
			GUIEventDispatcher.getInstance().fireEvent( GUIEvents, GUIEvents.onNeedScreenBlock );
			blockNavi = false;
			RequestAssembler.getInstance().doPing(true);
		}
	}
}
import components.interfaces.IDataAdapter;
import components.interfaces.IFormString;

class ChbAdapter implements IDataAdapter
{
	public function ChbAdapter()
	{
	}
	
	public function change(value:Object):Object
	{
		
		return value;
	}
	
	public function adapt(value:Object):Object
	{
		
		
		return value;
	}
	
	public function recover(value:Object):Object
	{
		
		if( value ) return 0x00;
		else return 0xff;
	}
	
	public function perform(field:IFormString):void
	{
		
		
		
		
	}
}