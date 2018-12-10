package components.screens.ui
{
	import components.abstract.functions.loc;
	import components.abstract.servants.TabOperator;
	import components.basement.UI_BaseComponent;
	import components.events.GUIEvents;
	import components.gui.Header;
	import components.gui.OptList;
	import components.gui.PopUp;
	import components.gui.SimpleTextField;
	import components.gui.fields.FSSimple;
	import components.gui.visual.Separator;
	import components.interfaces.ISaveListener;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.protocol.statics.OPERATOR;
	import components.screens.opt.OptNotify;
	import components.static.CMD;
	import components.static.COLOR;
	import components.static.RF_STATE;
	import components.system.SavePerformer;
	
	public class UINotify extends UI_BaseComponent implements ISaveListener
	{
		private var sep:Separator;
		private var field1:FSSimple;
		private var lastState:Array;
		private var warn:SimpleTextField;
		
		private var request:Request;
		
		private const TEL_ADDING:int = 0x01;
		private const TEL_ADD_SUCCESS:int = 0x02;
		
		private var ADDING:int= 0;
		
		public function UINotify()
		{
			super();
			
			var header:Header = new Header( [{label:loc("notify_phone"),xpos:18, width:200},{label:loc("notify_note"), xpos:276, width:200},
				{label:loc("notify_events"), xpos:399,width:200,align:"center"},{label:loc("notify_alarms"), xpos:436+94,width:200,align:"center"},
				{label:loc("notify_try"), xpos:636+39,width:200,align:"center"}],
				{size:12, leading:0} );
			addChild( header );
			header.x = 30;
			
			list = new OptList;
			list.y = 30;
			list.width = 858+30;
			addChild( list );
//			list.attune( CMD.NOTIF_K2, 1, OptList.PARAM_NEED_ADDITIONAL_EVENTS | OptList.PARAM_SCROLLING_ALWAYS_HIIDDEN | OptList.PARAM_STRICT_RESTORE,
//				{uniqueParams:[{param:2, gen:OptList.GENERATION_FIRSTFREE}], saveBefore: OptList.REMOVE | OptList.RESTORE} );
			list.attune( CMD.NOTIF_K2, 1, OptList.PARAM_NEED_ADDITIONAL_EVENTS | OptList.PARAM_SCROLLING_ALWAYS_HIIDDEN | OptList.PARAM_STRICT_RESTORE,
				{saveBefore: OptList.REMOVE | OptList.RESTORE} );
			list.attune_numerical( 50, 10 );
			list.addEventListener( GUIEvents.onEventFiredSuccess, updateHeight );
			list.overrideAdd( overrideAdd );
			list.overrideRemove( overrideRemove );
			list.buttonsExistance(true, true, false);
			
			sep = drawSeparator( 850 );
			field1 = createUIElement( new FSSimple, CMD.NOTIF_K2_LIMIT, loc("notify_note1"),
				null, 1,null,"0-3",1 ) as FSSimple;
			attuneElement( 759+30, 60 );
			field1.x = 10;
			field1.focusgroup = TabOperator.GROUP_FIELDS_AFTER_TABLE;
			
			warn = new SimpleTextField( loc("notify_note2"), 900, COLOR.RED );
			addChild( warn );
			warn.x = 10;
			
			width = 880;
		}
		override public function open():void
		{
			super.open();
			list.select(0);
			SavePerformer.trigger({"prepare":prepare, "after":after});
			RequestAssembler.getInstance().fireEvent( new Request( CMD.NOTIF_K2, put ));
			RequestAssembler.getInstance().fireEvent( new Request( CMD.NOTIF_K2_LIMIT, put ));
		}
		override public function put(p:Package):void
		{
			switch( p.cmd ) {
				case CMD.NOTIF_K2:
					list.put( p, OptNotify );
					updateHeight();
					break;
				case CMD.NOTIF_K2_LIMIT:
					field1.setCellInfo( p.getStructure(1)[0] );
					initSpamTimer( CMD.NOTIF_K2_STATE );
					loadComplete();
					break;
			}
		}
		private function updateHeight(ev:GUIEvents=null):void
		{
			list.height = list.getActualLinesCount()*25+50;
			field1.y = list.y + list.height - 35; 
			sep.y = list.y + list.height;
			warn.y = sep.y + 40; 
			
			height = list.y + list.height + 80;
		}
		override protected function processState(p:Package):void
		{
			super.processState(p);
			/**	Команда NOTIF_K2_STATE - состояние настройки телефонов оповещения
			 * Параметр 1 - порядковый номер телефона оповещения ( 1..8 )
			 * Параметр 2 - Статус ( 0x00 - нет статуса или не определен; 
			 * 			0x01 - идет добавление телефона; 
			 * 			0x04 - телефон добавлен; 
			 * 			0x09 - места для добавления больше нет; )	*/
			
			if (p.getStructure()[0] > 0 ) {
				switch( p.getStructure()[1] ) {
					case RF_STATE.ADDING:
					case RF_STATE.SUCCESS:
						RequestAssembler.getInstance().fireEvent( new Request( CMD.NOTIF_K2, insert, p.getStructure()[0] ));
						if ( p.getStructure()[1] == 1 )
							ADDING = p.getStructure()[0];
						break;
					default:
						if (!popup)
							popup = PopUp.getInstance();
						switch (p.getStructure()[1]) {
							case RF_STATE.ALREADYEXIST:
								popup.construct( PopUp.wrapHeader( "sys_error"), PopUp.wrapMessage(loc("notify_phone_already_exist")), PopUp.BUTTON_OK );
								list.select(p.getStructure()[0]);
								break;
							default:
								var txt:String = loc("g_error_unkwn") + " №" + p.getStructure()[1];
								if (  RF_STATE.NAMES_UNI[p.getStructure()[1]] != null )
									txt = RF_STATE.NAMES_UNI[ p.getStructure()[1]];
								popup.construct( PopUp.wrapHeader( "sys_error"), PopUp.wrapMessage( txt ), PopUp.BUTTON_OK );
								break;
						}
						popup.open();
				}
				RequestAssembler.getInstance().fireEvent( new Request( CMD.NOTIF_K2_STATE, null, 1,[0,0] ));
			}
		}
		private function overrideRemove(r:Request):void
		{
			OPERATOR.update(r);
			if ( !arrange() ) 
				RequestAssembler.getInstance().fireEvent(r);
			after();
		}
		private function isHole(a:Array):Boolean
		{
			var len:int = a.length;
			var hole:Boolean=false;
			var empty:Boolean=false;
			for (var i:int=0; i<len; ++i) {
				if (a[i][0] == 1) {
					if (empty) {
						hole = true;
						break;
					}
				} else
					empty = true;
			}
			return hole;
		}
		private function arrange():Boolean
		{
			var a:Array = OPERATOR.currentDataModel.getData(CMD.NOTIF_K2);
			
			var len:int = a.length;
			var hole:Boolean=isHole(a);
			if (hole) {
				var data:Array = [];
				for ( var i:int=0; i<len; ++i) {
					if (a[i][0] == 1)
						data.push( a[i] );
				}
				while(data.length < a.length)
					data.push( [0,"","",0,0,0] );
				for ( i=0; i<len; ++i) {
					RequestAssembler.getInstance().fireEvent( new Request(CMD.NOTIF_K2, null, i+1, data[i]));
				}
				RequestAssembler.getInstance().fireEvent( new Request( CMD.NOTIF_K2, put ));
			}
			return hole;
		}
		private function overrideAdd(r:Request):void
		{
			if (r.structure > 1)
				r.data = [1,"","",0,1,2];
			else
				r.data = [1,"","",1,3,0];
			SavePerformer.addObserver(this);
		//	SavePerformer.save();
			request = r;
		}
		private function insert(p:Package):void
		{
			list.putStructure(p);
			if ( ADDING > 0 ) {
				list.callEach(null, ADDING );
				ADDING = 0;
			}
		}
		private function prepare():void
		{
			var o:Object = SavePerformer.oNeedToSave;
			var a:Array;
			if (o[CMD.NOTIF_K2] is Object) {
				for (var key:String in o[CMD.NOTIF_K2]) {
					a = [];
					for (var keya:String in o[CMD.NOTIF_K2][key] ) {
						a.push( o[CMD.NOTIF_K2][key][keya] );
					}
					OPERATOR.update( new Request(CMD.NOTIF_K2, null, int(key), a) );
				}
			}
			if ( isHole(OPERATOR.currentDataModel.getData(CMD.NOTIF_K2)) )
				delete o[CMD.NOTIF_K2];
			arrange();
		}
		private function after():void
		{
			RequestAssembler.getInstance().fireEvent( new Request(CMD.EVENT_LOG_DELETE,null,1,[UIHistory.HIS_DELETE]));
		}
		public function saveEvent(e:int):void
		{
			if (e == SavePerformer.EVENT_COMPLETE) {
				var p:Package = new Package;
				p.cmd = request.cmd;
				p.structure = request.structure;
				p.data = request.data;
				p.success = true;
				request.delegate(p);
				request = null;
				SavePerformer.removeCompleteListener(this);
			}
		}
	}
}