package components.system
{
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import mx.core.FlexGlobals;
	
	import components.abstract.functions.loc;
	import components.abstract.servants.CIDServant;
	import components.abstract.servants.RFSensorServant;
	import components.abstract.sysservants.PartitionServant;
	import components.gui.fields.FSComboCheckBox;
	import components.gui.triggers.ButtonSave;
	import components.interfaces.ISaveController;
	import components.interfaces.IThreadUser;
	import components.protocol.RequestAssembler;
	import components.static.CMD;
	import components.static.MISC;
	
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
		
		public function updateSystemVariables(cmd:int, struct:int, o:Object):void
		{
			switch( cmd ) {
				case CMD.RF_SYSTEM:
					RFSensorServant.PERIOD_OF_TRANSMISSION_ALARM = o[5];
					break;
				case CMD.PARTITION:
					PartitionServant.PARTITION[struct] = {"code":o[2], "section":o[1] }
					break;
			}
		}
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
		
		private var buttonSave:ButtonSave;
		public function showSave(value:Boolean):void
		{
			if (value && MISC.SAVE_SILENT_MODE)
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
/********************************************************************
 * 		Link Channels (CH)
 * ******************************************************************/
		public function getCHObjectCCBList(checkList:Object):Array
		{
			var code_all:int = 0xFFFF;
			for( var h:String in checkList) {
				if( int(checkList[h]) == code_all )
					return [{"label":loc("g_all"), "data":1, "trigger": FSComboCheckBox.TRIGGER_SELECT_ALL_INVERT, "senddata":code_all }];
			}
			var list:Array = new Array;
			list.push( {"label":loc("g_all"), "data":0, "trigger": FSComboCheckBox.TRIGGER_SELECT_ALL_INVERT, "senddata":code_all } );
			
			for(var c:String in checkList) {
				if (checkList[c] != 0) {
					var codeX16:String = UTIL.formateZerosInFront( int(checkList[c]).toString(16), 4).toUpperCase();
					list.push( {"labeldata":codeX16, "label":codeX16, "data":1 } );
				}
			}
			return list;
		}
		public function getCHPartitionCCBList(checkList:Object):Array
		{
			var code_all:int = 0xFF;
			var select_all:Boolean = false;
			for( var h:String in checkList) {
				if( int(checkList[h]) == code_all )
					return [{"label":loc("g_all"), "data":1, "trigger": FSComboCheckBox.TRIGGER_SELECT_ALL_INVERT, "senddata":code_all }];
			}
			var list:Array = new Array;
			list.push( {"label":loc("g_all"), "data":0, "trigger": FSComboCheckBox.TRIGGER_SELECT_ALL_INVERT, "senddata":code_all } );
			
			for(var c:String in checkList) {
				if (checkList[c] != 0)
					list.push( {"labeldata":checkList[c],"label":checkList[c],"data":1 } );
			}
			return list;
		}
		public function getCHUserAndDevicesCCBList(checkList:Object):Array
		{
			var code_all:int = 0xFFFF;
			for( var h:String in checkList) {
				if( int(checkList[h]) == code_all )
					return [{"label":loc("g_all"), "data":1, "trigger": FSComboCheckBox.TRIGGER_SELECT_ALL_INVERT, "senddata":code_all }];
			}
			var list:Array = new Array;
			list.push( {"label":loc("g_all"), "data":0, "trigger":FSComboCheckBox.TRIGGER_SELECT_ALL_INVERT, "senddata":code_all } );
			
			for(var c:String in checkList) {
				if (checkList[c] != 0) {
					var txt:String = (int(checkList[c]) >> 4).toString(16);
					list.push( {"labeldata": txt, "label":txt, "data":1 } );
				}
			}
			return list;
		}
		public function getCHEventCCBList(checkList:Object):Array
		{
			var list:Array = new Array;
			var code_all:int = 0xFFFF;
			list.push( {"label":loc("cid_all"), "data":0, "trigger": FSComboCheckBox.TRIGGER_SELECT_ALL, "senddata":code_all } );
			
			list.push( {"label":"-", "data":2, "trigger": FSComboCheckBox.TRIGGER_I_SEPERATOR } );
			
			list.push( {"label":loc("cid_alarm_guard"), "data":1, "trigger": FSComboCheckBox.TRIGGER_SELECT_GROUP, "group":1 } );
			list.push( {"label":loc("cid_alarm_guard_r"), "data":1, "trigger": FSComboCheckBox.TRIGGER_SELECT_GROUP, "group":2 } );
			list.push( {"label":loc("cid_alarm_fire"), "data":1, "trigger": FSComboCheckBox.TRIGGER_SELECT_GROUP, "group":3 } );
			list.push( {"label":loc("cid_alarm_fire_r"), "data":1, "trigger": FSComboCheckBox.TRIGGER_SELECT_GROUP, "group":4 } );
			list.push( {"label":loc("cid_offguard"), "data":1, "trigger": FSComboCheckBox.TRIGGER_SELECT_GROUP, "group":5 } );
			list.push( {"label":loc("cid_onguard"), "data":1, "trigger": FSComboCheckBox.TRIGGER_SELECT_GROUP, "group":6 } );
			list.push( {"label":loc("cid_autotests"), "data":1, "trigger": FSComboCheckBox.TRIGGER_SELECT_GROUP, "group":7 } );
			list.push( {"label":loc("cid_sysev"), "data":1, "trigger": FSComboCheckBox.TRIGGER_SELECT_GROUP, "group":8 } );
			list.push( {"label":loc("cid_otherev"), "data":1, "trigger": FSComboCheckBox.TRIGGER_SELECT_GROUP, "group":9 } );
			
			list.push( {"label":"-", "data":2, "trigger": FSComboCheckBox.TRIGGER_I_SEPERATOR } );
			
			var select_all:Boolean = false;
			for( var h:String in checkList) {
				select_all = int(checkList[h]) == code_all;
				if (select_all)
					break;
			}
			var select:int;
			var a:Array = CIDServant.getEvent();
			for( var key:String in a) {
				
				if( a[key].data == 0 )
					continue;
				
				var num:int = int( "0x"+a[key].data);
				var len:int = num.toString(16).length;
				var result:int = num >> 4 | (num & 0x000F) << 12;
				
				// Ищем совпадения пришедшие с прибора, отмечаем галочками
				select = 0;
				if (select_all)
					select = 1;
				else {
					for( var l:String in checkList) {
						if( checkList[l] == result ) {
							select = 1;
							break;
						}
					}
				}
				list.push( {"labeldata":a[key].data, 
					"label":a[key].label, 
					"data":select, 
					"group":a[key].group} );
			}
			return list;
		}
	}
}
class Initiator { public function Initiator() }