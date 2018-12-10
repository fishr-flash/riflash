package components.screens.ui
{
	import components.abstract.GuardAdapter;
	import components.abstract.functions.loc;
	import components.abstract.servants.TaskManager;
	import components.gui.fields.FSSimple;
	import components.gui.triggers.TextButton;
	import components.interfaces.ITask;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.screens.opt.OptVerInfo;
	import components.screens.opt.OptVerInfoModem;
	import components.screens.opt.OptVerNavInfo;
	import components.static.CMD;
	import components.static.DS;
	
	public class UIVerInfo extends UIVersion
	{
		public static var OnlyOneSim:Boolean=false;
		
		private var sims:Vector.<OptVerInfo>;
		private var modems:Vector.<OptVerInfoModem>;
		private var optNavInfo:OptVerNavInfo;
		private var coldstart:Boolean=true;
		private var bDisableTracking:TextButton;
		private var dDisableGuard:TextButton;
		private var task:ITask;

		private var guardField:FSSimple;
		
		public function UIVerInfo()
		{
			super(3,0xff);
			
			sims = new Vector.<OptVerInfo>(2);
			modems = new Vector.<OptVerInfoModem>(2);
			
			globalY -= 10;
			

			if (DS.release >= 20) {
				
				drawSeparator(UIVersion.sepwidth);
				optNavInfo = addopt( new OptVerNavInfo) as OptVerNavInfo;
				globalY -= 10;
				
			}
			
			
			
			
			/**Команда VER_INFO
			 * Параметр 1 - Название прибора;
			 * Параметр 2 - Версия прошивки;
			 * Параметр 3 - Тип памяти;
			 * 
			 * Команда VER_INFO1 ( для приборов с двумя симкартами - две структуры )
			 * Параметр 1 - Тип соединения;
			 * Параметр 2 - Тип GSM модема;
			 * Параметр 3 - Версия прошивки модема;
			 * Параметр 4 - IMEI код;
			 * Параметр 5 - ID SIM карты;
			 * Параметр 6 - Сотовый оператор;*/
			
			height = 440;
			width = 830;
			
			var a:Array = [CMD.VER_INFO];
			
			if ( DS.release >= 20)
				a = a.concat( [CMD.NAV_INFO] );
			a = a.concat( [CMD.VER_INFO1] );
			
			
			
			if ( DS.release >= 24)
				a = a.concat( [CMD.TRAKING_MODE] );
			
			
			if ( DS.release >= 46)
				a = a.concat( [CMD.VR_SMS_GUARD] );
			
			
			
			
			starterCMD = a;
		}
		override public function put(p:Package):void
		{
			var data:Array;
			switch (p.cmd) {
				case CMD.VER_INFO:
					data = p.getStructure().slice();
					getField( CMD.VER_INFO,1 ).setCellInfo( DS.name );
					getField( CMD.VER_INFO,2 ).setCellInfo( data[1] + " "+DS.getCommit());
					break;
				case CMD.NAV_INFO:
					optNavInfo.putData(p);
					break;
				case CMD.VER_INFO1:
					data = p.data.slice();

					

					var len:int = data.length;
					OnlyOneSim = Boolean(len == 1 );
					for (var i:int=0; i<len; ++i) {
						if( !modems[i] ) {
							modems[i] = new OptVerInfoModem(i+1);
							addChild( modems[i] );
							modems[i].x = globalX;
							modems[i].y = globalY;
							globalY += modems[i].complexHeight;
						}
						modems[i].putRawData( data[i] );
						
						if( !DS.isDevice( DS.V_ASN ) )
								break;
					}
					
					for ( i=0; i<len; ++i) {
						if( !sims[i] ) {
							sims[i] = new OptVerInfo(i+1);
							addChild( sims[i] );
							sims[i].x = globalX;
							sims[i].y = globalY;
							globalY += sims[i].complexHeight;
						}
						sims[i].putRawData( data[i] );
					}
					loadComplete();
					break;
				case CMD.TRAKING_MODE:
					if (coldstart) {
						
						
						coldstart = false;
							
						
						drawSeparator(400);
						
						addui( new FSSimple, CMD.TRAKING_MODE, loc("ui_verinfo_watching_mode"), null, 1 );
						attuneElement( shift, NaN, FSSimple.F_CELL_NOTSELECTABLE | FSSimple.F_CELL_ALIGN_LEFT );
						getLastElement().setAdapter( new TrackingAdapter );
						
						bDisableTracking = new TextButton;
						addChild( bDisableTracking );
						bDisableTracking.x = globalX + shift + 110;
						bDisableTracking.y = getLastElement().y;
						bDisableTracking.setUp( loc("g_switchoff"), onTrackingDisable );
					}
					
					bDisableTracking.visible = Boolean(p.getStructure()[0] != 0);
					distribute(p.getStructure(), p.cmd);
					break;
				
				
				case CMD.VR_SMS_GUARD:
					if (!guardField) {
						
						drawSeparator(400);
						
						guardField = addui( new FSSimple, CMD.VR_SMS_GUARD, loc("ui_verinfo_guard_mode"), null, 1 ) as FSSimple;
						attuneElement( shift, NaN, FSSimple.F_CELL_NOTSELECTABLE | FSSimple.F_CELL_ALIGN_LEFT );
						getLastElement().setAdapter( new GuardAdapter );
						
						dDisableGuard = new TextButton;
						addChild( dDisableGuard );
						dDisableGuard.x = globalX + shift + 110;
						dDisableGuard.y = getLastElement().y;
						dDisableGuard.setUp( loc("g_switchoff"), onChangeStateGuard );
					}
					
					if( p.getStructure()[0] != 0  )
					{
						
						dDisableGuard.setUp( loc("g_switchoff"), onChangeStateGuard );
					}
					else
					{
						
						dDisableGuard.setUp( loc("g_switchon"), onChangeStateGuard );
					}
					distribute(p.getStructure(), p.cmd);
					break;
				
				
			}
		}
		override public function close():void
		{
			super.close();
			if (task)
				task.kill();
			task = null;
		}
		private function onTrackingDisable():void
		{
			RequestAssembler.getInstance().fireEvent( new Request(CMD.TRAKING_MODE, null, 1, [0]));
			if (!task)
				task = TaskManager.callLater( requestTracking, TaskManager.DELAY_1SEC*5 );
			else
				task.repeat();
		}
		private function requestTracking():void
		{
			RequestAssembler.getInstance().fireEvent( new Request(CMD.TRAKING_MODE, put));
		}
		
		private function onChangeStateGuard():void
		{
			const data:int = guardField.getCellInfo() == loc( "g_disabled_m" )?1:0;
			RequestAssembler.getInstance().fireEvent( new Request(CMD.VR_SMS_GUARD, checkStateGuard, 1, [ data ]));
			
		}
		
		private function checkStateGuard(p:Package ):void
		{
			RequestAssembler.getInstance().fireEvent( new Request(CMD.VR_SMS_GUARD, put, 1, null ));
		}
		
	}
}
import components.abstract.functions.loc;
import components.gui.fields.FSSimple;
import components.interfaces.IDataAdapter;
import components.interfaces.IFormString;
import components.static.COLOR;

class TrackingAdapter implements IDataAdapter
{
	private var color:uint;
	
	public function adapt(value:Object):Object
	{
		if ( int(value) == 0 ) {
			color = COLOR.RED;
			
			return loc("g_disabled_m");
		}
		color = COLOR.GREEN_DARK;
		return loc("g_enabled_m");
	}
	
	public function change(value:Object):Object
	{
		return value;
	}
	
	public function perform(field:IFormString):void
	{
		(field as FSSimple).setTextColor( color );
	}
	
	public function recover(value:Object):Object
	{
		return null;
	}
}

