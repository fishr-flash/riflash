package components.system
{
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import mx.core.FlexGlobals;
	
	import components.gui.triggers.ButtonSave;
	import components.interfaces.ISaveController;
	import components.interfaces.IThreadUser;
	import components.protocol.RequestAssembler;
	
	public class Controller implements ISaveController
	{
		private static var instance:Controller;
		
		public static function getInstance():Controller
		{
			if ( instance == null )
				instance = new Controller( new Initiator );
			return instance;
		}
		public function Controller(_initiator:Initiator)
		{
			useThread( new SavePerformer(this) );
			useThread( RequestAssembler.getInstance() );
		}
		
		public static var REGISTER_STATUSBAR:int=0x00;
		public static var REGISTER_SAVE:int=0x02;
		
		public function register( item:Object, type:int ):Object
		{
			switch( type ) {
				case REGISTER_SAVE:
					buttonSave = item as ButtonSave;
					buttonSave.addEventListener( MouseEvent.CLICK, save );
					return buttonSave;
			}
			return null;
		}
		public function updateSystemVariables(cmd:int, struct:int, a:Object):void {}
/********************************************************************
 * 		THREAD EMULATION
 * ******************************************************************/		
		
		private var timer:Timer;
		private var aThreadUsers:Array;
		public function useThread( target:IThreadUser):void
		{
			if ( !timer ) {
				aThreadUsers = new Array;
				timer = new Timer( 100 );
				timer.addEventListener( TimerEvent.TIMER, complete );
				timer.start();
			}
			aThreadUsers.push( target );
		}
		public function closeThread( target:IThreadUser ):void
		{
			for( var key:String in aThreadUsers ) {
				if (aThreadUsers[key] == target)
					aThreadUsers.splice( int(key), 1 );
			}
				
		}
		private function complete(ev:TimerEvent):void
		{
			for( var key:String in aThreadUsers )
				(aThreadUsers[key] as IThreadUser).threadTick();
		}
		
/********************************************************************
 * 		BUTTON SAVE
 * ******************************************************************/		
		
		public static var SAVE_SILENT_MODE:Boolean=false;
		private var buttonSave:ButtonSave;
		public function showSave(value:Boolean):void
		{
			if (value && SAVE_SILENT_MODE)
				return;
				
			buttonSave.visible = value;
		}
		public function saveButtonActive(value:Boolean):void
		{
			buttonSave.enabled = value;
		}
		public function save(ev:MouseEvent=null):void
		{
			if ( buttonSave.enabled ) {
				(FlexGlobals.topLevelApplication.stage).focus = null;
				buttonSave.visible = false;
				SavePerformer.save();
			}
		}
		public function isSaveActive():Boolean
		{
			return buttonSave.visible;
		}
	}
}
class Initiator { public function Initiator() }