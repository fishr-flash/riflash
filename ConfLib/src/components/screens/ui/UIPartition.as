package components.screens.ui
{
	import mx.events.ResizeEvent;
	
	import components.abstract.DEVICESB;
	import components.abstract.RegExpCollection;
	import components.abstract.functions.loc;
	import components.abstract.servants.ResizeWatcher;
	import components.abstract.servants.TabOperator;
	import components.abstract.sysservants.PartitionServant;
	import components.basement.UI_BaseComponent;
	import components.events.GUIEvents;
	import components.gui.OptList;
	import components.gui.SimpleTextField;
	import components.gui.fields.FSCheckBox;
	import components.gui.fields.FSComboBox;
	import components.gui.fields.FSShadow;
	import components.gui.fields.FormEmpty;
	import components.gui.visual.Separator;
	import components.interfaces.IResizeDependant;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.protocol.statics.SERVER;
	import components.screens.opt.OptPartition;
	import components.static.CMD;
	import components.static.DS;
	import components.static.PART_FUNCT;
	
	public class UIPartition extends UI_BaseComponent implements IResizeDependant
	{
		private var tPartitionNum:SimpleTextField;
		private var tStatus:SimpleTextField;
		private var tAction:SimpleTextField;
		private var tCode:SimpleTextField;
		private var tDelay:SimpleTextField;
		
		private var sep:Separator;
		private var allowArm:Boolean;
		
		public function UIPartition()
		{
			super();
			
			tPartitionNum = new SimpleTextField( loc("ui_part_num"), 70 );
			tPartitionNum.setSimpleFormat( "left", -7 );
			addChild( tPartitionNum );
			tPartitionNum.x = 10;
			
			tStatus = new SimpleTextField( loc("ui_part_state"), 170);
			tStatus.setSimpleFormat( "center", -7 );
			addChild( tStatus );
			tStatus.x = tPartitionNum.x + tPartitionNum.width+5;
			
			tAction = new SimpleTextField( loc("ui_part_action"), 100);
			tAction.setSimpleFormat( "left", -7 );
			addChild( tAction );
			tAction.x = tStatus.x + tStatus.width + 30;
			
			tCode = new SimpleTextField( loc("ui_part_object"), 100);
			tCode.setSimpleFormat( "left", 0 );
			addChild( tCode );
			tCode.x = tAction.x + tAction.width + 40;
			
			tDelay = new SimpleTextField( loc("ui_part_exit_delay"), 130);
			tDelay.setSimpleFormat( "left", 0 );
			addChild( tDelay );
			tDelay.x = tCode.x + tCode.width + 13 - 18;
			
			list = new OptList;
			addChild( list );
			list.y = 46;
			list.width = 660;
			list.attune( CMD.PARTITION,1,OptList.PARAM_ATLEAST_ONE_LINE | OptList.PARAM_NEED_ADDITIONAL_EVENTS | OptList.PARAM_V_SCROLLING_WHEN_NEEEDED, { creationPattern:{2:0x50,3:"30"}, uniqueParams:[{param:1, gen:OptList.GENERATION_FIRSTFREE, genMin:1, genMax:100}] } );
	
			list.addEventListener( GUIEvents.onEventFiredSuccess, partitionFunct );
			
			sep = new Separator( 560 );
			addChild( sep );
			sep.y = 380;
			sep.x = 10;
			
			globalX = 10;
			
			createUIElement( new FSCheckBox, CMD.PART_SET, loc("ui_part_duplicate_evet_for_every_obj"),null, 1 ).x = globalX;
			attuneElement( 509 );
			getLastFocusable().focusgroup = TabOperator.GROUP_LAST;
			
			var l:Array = [{label:loc("g_no"), data:0},{label:"5", data:5},{label:"10", data:10}];
			createUIElement( new FSComboBox,CMD.PART_SET,loc("ui_part_max_event_after_guard"), null,
				2,l,"0-9",3,new RegExp( RegExpCollection.REF_0to255)).x = globalX;
			attuneElement( 350+102,70);
			getLastFocusable().focusgroup = TabOperator.GROUP_LAST;
			
			if (DS.isK14s || (DS.K16 && SERVER.DUAL_DEVICE && DEVICESB.release >= 8) ) {
				addui( new FSCheckBox, CMD.PART_SET, loc("ui_part_allow_guard_violated_zones"), null, 3 );
				attuneElement( 509 );
				allowArm = true;
			} else
				addui( new FSShadow, CMD.PART_SET, "", null, 3 );
			
			starterCMD = CMD.PARTITION;
			
			if( DS.isK14s && DS.release >= 11 )
			{
				addui( new FSCheckBox, CMD.PART_SET_TEST_LINK, loc( "part_set_test" ), null, 1 );
				attuneElement( 509 );
				starterRefine( CMD.PART_SET_TEST_LINK, true );
			}
			
			
			
			height = 255;
			width = 575;
		}
		override public function open():void
		{
			super.open();
			ResizeWatcher.addDependent(this);
		}
		override public function close():void
		{
			if ( !this.visible ) return;
			super.close();
			stage.removeEventListener( ResizeEvent.RESIZE, localResize );
			list.close();
			ResizeWatcher.removeDependent(this);
		}
		private function partitionFunct(ev:GUIEvents):void
		{
			switch( ev.getActionCode() ) {
				case OptList.ADD:
				case OptList.RESTORE:
					
					var opt:OptPartition = list.getLine( ev.getStructure() ) as OptPartition;
					PartitionServant.insertNewPartition( ev.getStructure(), int(opt.getField(CMD.PARTITION,2).getCellInfo()), int(opt.getField(CMD.PARTITION,1).getCellInfo()) );
					
					RequestAssembler.getInstance().fireEvent( new Request( CMD.PART_FUNCT, null, 1,[ ev.getStructure(), PART_FUNCT.TAKEOFFGUARD ] ));
					break;
				case OptList.REMOVE:
					
					PartitionServant.removePartition( ev.getStructure() );
					RequestAssembler.getInstance().fireEvent( new Request( CMD.PART_FUNCT, null, 1,[ ev.getStructure(), PART_FUNCT.REFRESH ] ));
					break;
			}
			ResizeWatcher.doResizeMe(this);
		}
		public function localResize(w:int, h:int, real:Boolean=false):void
		{
			var realH:int = list.getActualHeight();
			var preferredH:int = h - 135;
			list.height = realH > preferredH ? preferredH : realH;   
			var pos:int = list.y + list.height;
			var chkBoxPartSetTest:FormEmpty = getField( CMD.PART_SET_TEST_LINK, 1 ) as FormEmpty;
			
			sep.y = pos - 10;
			(getField(CMD.PART_SET,1) as FormEmpty).y = pos;
			if (allowArm) {
				(getField(CMD.PART_SET,3) as FormEmpty).y = pos + 30;
				(getField(CMD.PART_SET,2) as FormEmpty).y = pos + 60;
				if( chkBoxPartSetTest ) chkBoxPartSetTest.y = pos + 90;
			} else
				(getField(CMD.PART_SET,2) as FormEmpty).y = pos + 40;
		}
		override public function put( p:Package ):void
		{
			if( p.cmd == CMD.PART_SET_TEST_LINK )
			{
				pdistribute( p );
				
			}
			else
			{
				/**	Команда PARTITION ( Для Контакт-14 - структур 8, для Контакт-16 - структур 16 ) */	
				/**	Параметр 1 - Наличие раздела в приборе или номер раздела ( 0x00 - нет раздела в строке, 1-99 есть раздел с номером 1-99 ). */
				/** Параметр 2 - код объекта ( 0x0000-0xFFFF ); */
				/** Параметр 3 - задержка на выход, в секундах ( 0-255 ); */
				
				list.put( p, OptPartition );
				localResize(ResizeWatcher.lastWidth, ResizeWatcher.lastHeight);
				
				RequestAssembler.getInstance().fireEvent( new Request(CMD.PART_SET, getInfo ));
			}
			
			
			
			
		}
		private function getInfo( p:Package):void
		{
			if ( !p.error ) {
				
				getField(CMD.PART_SET,1).setCellInfo( String( p.getStructure()[0] ));
				getField(CMD.PART_SET,2).setCellInfo( String( p.getStructure()[1] ));
				getField(CMD.PART_SET,3).setCellInfo( String( p.getStructure()[2] ));
				
				/**	Команда PART_SET */
				/**	Параметр 1 - Дублировать системные события для каждого объекта (0x00 - нет, 0x01 - да ); */
				/**	Параметр 2 - Максимальное количество событий по разделу после постановки под охрану ( 1-255) */
				/**	Параметр 3 - Разрешить постановку ненормализованных разделов (0x00 - нет, 0x01 - да ); */
				
				RequestAssembler.getInstance().fireEvent( new Request( CMD.PART_STATE_ALL, processState ));
				loadComplete();
			}
		}
		override protected function processState(p:Package):void
		{
			if ( p.error || !this.visible ) return;
			//super.processState(p);
			super.processState(p);
			var len:int = p.length;
			var i:int;
			var opt:OptPartition;
			
			switch ( p.cmd ) {
				case CMD.PART_STATE_ALL:
					for( i=0; i<len; ++i ) {
						var status:int = p.data[i][0];
						opt = list.getLine(i+1) as OptPartition;
						if ( opt )
							opt.putStatus(status);
					}
					break;
			}
			if( !isSpamTimer() )
				initSpamTimer( CMD.PART_STATE_ALL, 0 );
		}
	}
}
// 610 before refactor 