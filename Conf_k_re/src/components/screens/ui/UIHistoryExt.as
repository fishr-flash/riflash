package components.screens.ui
{
	import components.abstract.functions.loc;
	import components.abstract.servants.CIDServant;
	import components.abstract.servants.HistorySaverServant;
	import components.abstract.servants.K9HistorySaverServant;
	import components.events.GUIEventDispatcher;
	import components.events.GUIEvents;
	import components.gui.Header;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.protocol.statics.OPERATOR;
	import components.screens.opt.OptHistoryLine;
	import components.screens.opt.OptHistoryLineK9;
	import components.static.CMD;
	import components.static.DS;

	public class UIHistoryExt extends UIHistory
	{
		public static var K5_ACTIVE_CHANELS:Array;
		
		public function UIHistoryExt()
		{
			super();
			
			tAmount.restrict("0-9",4);
			
			var k5:Boolean = false;
			
			switch(DS.alias) {
				case DS.isfam( DS.K5 ):
					RequestAssembler.getInstance().fireEvent( new Request( CMD.K5_DIRECTIONS, put ));
					k5 = true;
				case DS.K5RT1:
				case DS.K5RT13G:
				case DS.K5RT1L:
				case DS.K5RT3:
				case DS.K5RT3L:
				case DS.K5RT33G:
					
					if( !k5 )RequestAssembler.getInstance().fireEvent( new Request( CMD.K5RT_DIRECTIONS, put ));
					servant = new HistorySaverServant([bXLSpageAll, bTXTpageAll],0,OptHistoryLine.getEmulatedvisualizeBitfield,OptHistoryLine.calcCIDCRC);
					(servant as HistorySaverServant).working_cmd = CMD.K5_HISTORY_REC;
					(servant as HistorySaverServant).historyAdapter = new K5HistoryAdapter;
					
					
					break;
				case DS.K9:
				case DS.K9A:
				case DS.K9M:
				case DS.K9K:
				case DS.K1:
				case DS.K1M:
					servant = new K9HistorySaverServant([bXLSpageAll, bTXTpageAll],0,OptHistoryLineK9.getEmulatedvisualizeBitfield,OptHistoryLineK9.calcCIDCRC);
					starterRefine( CMD.K9_DIRECTIONS );
					(servant as K9HistorySaverServant).working_cmd = CMD.K9_HISTORY_REC;
					break;
			}
				
			
			
			removeChild( bXLSpageAll );
			
			CIDServant.getEvent();
			
			askDelay = 30000;
			
			list.width = 1175+20+50+45;
			width = 1320;
		}
		override protected function getClass():Class 
		{
			switch(DS.alias) {
				case DS.isfam( DS.K5 ):
				case DS.K5RT1:
				case DS.K5RT13G:
				case DS.K5RT1L:
				case DS.K5RT3:
				case DS.K5RT3L:
				case DS.K5RT33G:
					return OptHistoryLine;
				case DS.K9:
				case DS.K9A:
				case DS.K9M:
				case DS.K9K:
				case DS.K1:
				case DS.K1M:
					return OptHistoryLineK9;
			}
			return null;
		}
		override protected function historyRec():void
		{
			if ( DS.isfam( DS.K5 ) )
				HISTORY_REC_CMD = CMD.K5_HISTORY_REC;
			else
				HISTORY_REC_CMD = CMD.K9_HISTORY_REC; 
		}
		override protected function loadSequence():void
		{
			
			
			if( !OPERATOR.dataModel.getData( CMD.HISTORY_VER ) ) {
				RequestAssembler.getInstance().fireEvent( new Request( CMD.HISTORY_VER, put ));
				return;
			} else
				HIS_HARD_MAX_STRUCTURES = OPERATOR.dataModel.getData( CMD.HISTORY_VER )[0][1];
			
			GUIEventDispatcher.getInstance().addEventListener( GUIEvents.onNeedPage, getPageListener );
			
			getPage(1);
		}
		
		override public function put(p:Package):void
		{
			switch( p.cmd )
			{
				
				case CMD.K5_DIRECTIONS:
				case CMD.K5RT_DIRECTIONS:
					K5_ACTIVE_CHANELS = p.data as Array;
					
					break;
				
				default: super.put( p );
			}
		}
		
		override protected function getHeader():Header
		{
			// №	Время	№ объекта	Код	Т\В	Событие	Раздел	Шлейф/ ТМ (ГБР)	Посылка	КС	Передано	Направления
			return new Header( [{label:loc("his_k5_num"),xpos:22-38, width:100},
				{label:loc("his_k5_time"), xpos:45+37, width:100, align:"left"},
				{label:loc("his_k5_objnum"), xpos:160+30-14, width:100},
				{label:loc("his_k5_code"), xpos:230+40-33, width:100}, 
				{label:loc("his_k5_alarm_restore"), xpos:230+45+45-35, width:100},
				{label:loc("his_k5_event"), xpos:360+45+20, width:100, align:"left"},
				{label:loc("his_k5_part"), xpos:590+41, width:100},
				{label:loc("his_k5_wire_tmkey"), xpos:660+45+20-27, width:140},
				{label:loc("his_k5_package"), xpos:745+45+20, width:100},
				{label:loc("his_k5_crc"), xpos:867+45-20, width:100}, 
				{label:loc("his_k5_sent"), xpos:900-8+45, width:100}, 
				{label:loc("his_k5_dir"), xpos:995+40+20, width:100, align:"left"} ], {size:11, border:false, align:"center"} );
		}
		override protected function getHistoryExportHeader():Array
		{
			var a:Array = [loc("his_k5_num"),
				loc("his_k5_time"),
				loc("his_k5_objnum"),
				loc("his_k5_code"), 
				loc("his_k5_alarm_restore"),
				loc("his_k5_event"),
				loc("his_k5_part"),
				loc("his_k5_wire_tmkey"),
				loc("his_k5_package"),
				loc("his_k5_crc"), 
				loc("his_k5_sent"), 
				loc("his_k5_dir")
			];
			
			var len:int = a.length;
			for (var i:int=0; i<len; i++) {
				a[i] = (a[i] as String).replace( /\r/g, " " );
			}
			return a;
		}
		override public function localResize(w:int, h:int, real:Boolean=false):void
		{
			super.localResize(w,h,real);
			
			var pos:int = h - 110;
			bTXTpageAll.y = pos + 40;
		}
	}
}
import components.interfaces.IAbstractAdapter;
import components.screens.opt.OptHistoryLine;

class K5HistoryAdapter implements IAbstractAdapter
{
	private var opt:OptHistoryLine;
	
	public function adapt(a:Object):Object
	{
		if( !opt )
			opt = new OptHistoryLine(1);
		var res:Array = opt.getParsedData( a as Array );
		return res;
	}
}