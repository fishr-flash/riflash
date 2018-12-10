package components.screens.ui
{
	import flash.events.Event;
	
	import components.abstract.GroupOperator;
	import components.abstract.adapters.BitAdapter;
	import components.abstract.functions.getAllPartitionCCBList;
	import components.abstract.functions.loc;
	import components.abstract.functions.turnToPartitionBitfield;
	import components.abstract.servants.BitMasterMind;
	import components.abstract.servants.ResizeWatcher;
	import components.basement.UI_BaseComponent;
	import components.events.GUIEvents;
	import components.gui.Balloon;
	import components.gui.Header;
	import components.gui.MFlexListSelectable;
	import components.gui.fields.FSCheckBox;
	import components.gui.fields.FSComboBox;
	import components.gui.fields.FSComboCheckBox;
	import components.gui.fields.FSComboCheckBoxGroupDisabler;
	import components.gui.fields.FSRadioGroup;
	import components.gui.fields.FSShadow;
	import components.gui.triggers.TextButton;
	import components.interfaces.IFormString;
	import components.interfaces.IResizeDependant;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.protocol.statics.OPERATOR;
	import components.screens.opt.OptKeyTM;
	import components.screens.page.AddDialog;
	import components.static.CMD;
	import components.system.SavePerformer;
	import components.system.UTIL;
	
	public class UIKeysTMK9 extends UI_BaseComponent implements IResizeDependant
	{
		private var flist:MFlexListSelectable;
		private var rg:FSRadioGroup;
		private var bAdd:TextButton;
		private var bRemove:TextButton;
		private var bChange:TextButton;
		private var addDialog:AddDialog;
		private var go:GroupOperator;
		
		private var bitmm:BitMasterMind;
		private const max:int = 16;
		
		public function UIKeysTMK9()
		{
			super();

			go = new GroupOperator;
			
			const fShift:int = 350;
			const sShift:int = 91;
			
			bitmm = new BitMasterMind;
			addui( new FSShadow,CMD.K9_BIT_SWITCHES, "", null, 1 );
			bitmm.addContainer( getLastElement() );
			addui( new FSShadow,CMD.K9_BIT_SWITCHES, "", null, 2 );
			bitmm.addContainer( getLastElement() );
			
			addui( new FSCheckBox, 1, loc("tmkey_k5_on"), null, 1 );
			bitmm.addController( getLastElement(), 2, 6, onSwitch );
			attuneElement( fShift-17+ 64 + sShift );
			
			//var l:Array = UTIL.comboBoxNumericDataGenerator(1,6);
			var l:Array = UTIL.getComboBoxList( [[0,loc("g_no")],[1,1],[2,2],[3,3],[4,4],[5,5],[6,6]] ); 
			
			addui( new FSComboBox, CMD.K9_TM_LED_PART,loc("tmkey_k9_parts"), null, 1, l );
			attuneElement( fShift + sShift, 60, FSComboBox.F_COMBOBOX_NOTEDITABLE | FSComboBox.F_MULTYLINE );
			//getLastElement().setAdapter( new PartitionAdapter );
			
			globalY += 20;
			
			
			for (var i:int=1; i<8; i++) 
			{
				addui( new FSShadow, CMD.READER_TM, "", null, i  );	
			}
			
			
			createUIElement( new FSComboCheckBoxGroupDisabler, CMD.READER_TM,loc( "partition_for_intellect_reader" ), null, 8 );
			attuneElement( fShift, 150, FSComboCheckBox.F_MULTYLINE );
			(getLastElement() as FSComboCheckBox).turnToBitfield = turnToPartitionBitfield;
			(getLastElement() as FSComboCheckBoxGroupDisabler).blackText = loc("g_no");
			getLastElement().setAdapter( new BitAdapter() );
			drawSeparator(622);
			
			/*var h:Header = new Header( [ {label:"№",align:"center",xpos:30},
				{label:loc("ui_tmkey"), xpos:30+45},
				{label:loc("tmkey_k5_parts"), xpos:30+45+160, width:100},
				{label:loc("tmkey_k5_gbr"), xpos:30+45+160+280},
				{label:loc("tmkey_k5_force"), xpos:30+45+160+280+45} ], {size:12} );*/
			var h:Header = new Header( [ {label:"№",align:"center",xpos:30},
				{label:loc("ui_tmkey"), xpos:30+45},
				{label:loc("tmkey_k5_parts"), xpos:30+45+160, width:100},
				{label:loc("tmkey_k5_gbr"), xpos:30+45+160+280-39, align:"center", width:100},
				{label:loc("tmkey_k5_force"), xpos:30+45+160+280+50+16, width:120, align:"center"} ], {size:12} );
			addChild( h );
			h.y = globalY;
			globalY += 30;
			
			flist = new MFlexListSelectable(OptKeyTM);
			addChild(flist);
			flist.height = 600;
			flist.width = 780;
			flist.y = globalY;
			flist.x = globalX;
			flist.addEventListener( GUIEvents.EVOKE_READY, onRefresh );
			
			bAdd = addbutton(loc("g_add"), 1 );
			bChange = addbutton(loc("g_change"), 2 );
			bRemove = addbutton(loc("g_remove"), 3 );
			
			go.add("b", [bAdd, bChange, bRemove] );
			
			addDialog = new AddDialog;
			addChild( addDialog );
			addDialog.addEventListener( Event.COMPLETE, onComplete );
			addDialog.visible = false;
			addDialog.y = 120;
			
			width = 830;
			
			starterCMD = [CMD.K9_BIT_SWITCHES, CMD.K9_PART_PARAMS, CMD.K9_TM_LED_PART, CMD.K5_TM_KEY_CNT, CMD.READER_TM ];
			starterRefine( CMD.K9_AWIRE_TYPE );
		}
		override public function put(p:Package):void 
		{
			
			switch(p.cmd) {
				case CMD.K9_BIT_SWITCHES:
					LOADING = true;
					refreshCells( p.cmd );
					bitmm.put(p);
		/*			distribute( p.getStructure(), p.cmd );
					getField(1,1).setCellInfo( UTIL.isBit( 0, p.getStructure()[2] ));
					getField(1,2).setCellInfo( UTIL.isBit( 6, p.getStructure()[2] ) ? 1:0 );
					getField(1,3).setCellInfo( int(p.getStructure()[1]) & 0x0F );
					onBit();*/
					LOADING = false;
					break;
				case CMD.K5_TM_KEY_CNT:
					ResizeWatcher.addDependent(this);
					
					if( p.data[ 0 ][ 0 ] > max ) p.data[ 0 ][ 0 ] = 0;
					var count:int = p.getStructure()[0];
					
					if (count > 0)
						RequestAssembler.getInstance().fireReadSequence( CMD.K5_TM_KEY, put, count );
					else {
						flist.clearlist();
						ResizeWatcher.doResizeMe(this);
						onRefresh();
						loadComplete();
						
					}
					break;
				case CMD.K5_TM_KEY:
					flist.put(p);
					ResizeWatcher.doResizeMe(this);
					onRefresh();
					loadComplete();
					//SavePerformer.trigger( {after:after} )
					break;
				case CMD.K9_TM_LED_PART:
					distribute(p.getStructure(), p.cmd );
					break;
				
				case CMD.READER_TM:
					
					(getField( CMD.READER_TM, 8 ) as FSComboCheckBox).setList( getAllPartitionCCBList( p.getStructure()[7], true  ));
					var len:int = p.getStructure().length - 1;
					for (var i:int=0; i<len; i++) 
						getField( CMD.READER_TM, i + 1 ).setCellInfo( p.getStructure()[ i ] );
					
					break;
			}
			manualResize();
			this.height += 10;
			
			SavePerformer.trigger( {after:after} )
		}
		private function after():void
		{
			Balloon.access().show("sys_attention","k9_restart_to_apply");
		}
		override public function close():void
		{
			super.close();
			ResizeWatcher.removeDependent(this);
			addDialog.close();
			Balloon.access().close();
		}
		private function addbutton(title:String, n:int):TextButton
		{
			var b:TextButton = new TextButton;
			addChild( b );
			b.setUp( title, onClick, n );
			b.y = globalY;
			b.x = globalX;
			globalX += 200;
			return b;
		}
		private function onRefresh(e:Event=null):void
		{
			bAdd.disabled = flist.length == max;
			bChange.disabled = flist.selected < 0;
			bRemove.disabled = flist.selected < 0;
			manualResize();
		}
		private function onComplete(e:Event):void
		{	// Когда нажимается ОК в окне добавления/изменения ключей, чтобы переформировать список
			loadStart();
			RequestAssembler.getInstance().fireEvent( new Request(CMD.K5_TM_KEY_CNT,put));
		}
		private function onClick(n:int):void
		{
			switch(n) {
				case 1:	// add
					var kcount:int = OPERATOR.dataModel.getData(CMD.K5_TM_KEY_CNT)[0][0];
					addDialog.show(loc("tmkey_k5_add_num")+(kcount+1));
					break;
				case 2:	// change
					var a:Array = flist.extract()[flist.selected];
					addDialog.show(loc("tmkey_k5_num")+(flist.selected+1), a, flist.selected+1);
					break;
				case 3:	// remove
					loadStart();
					var str:int = flist.removeSelected()-1;
					var total:int = OPERATOR.dataModel.getData(CMD.K5_TM_KEY_CNT)[0][0];
					
					var list:Array = OPERATOR.dataModel.getData(CMD.K5_TM_KEY).slice();
					list.splice(str,1);
					var len:int = list.length;
					for (var i:int=str; i<len; i++) {
						RequestAssembler.getInstance().fireEvent( new Request(CMD.K5_TM_KEY, null, i+1, list[i] ));
					}
					RequestAssembler.getInstance().fireEvent( new Request(CMD.K5_TM_KEY_CNT, null, 1, [--total] ));
					if (total > 0)
						RequestAssembler.getInstance().fireReadSequence( CMD.K5_TM_KEY, put, total );
					else {
						var p:Package = new Package;
						p.data = [];
						p.structure = 0;
						flist.put(p,true);
						ResizeWatcher.doResizeMe(this);
						onRefresh(null);
						loadComplete();
					}
					addDialog.close();
					break;
			}
		}
		private function onSwitch(f:IFormString):void
		{
			var ob:Object = f.getCellInfo();
			var b:Boolean = int(f.getCellInfo())==1;
			getField(CMD.K9_TM_LED_PART, 1 ).disabled = !b;
			getField(CMD.READER_TM, 8 ).disabled = !b;
		}
	/*	private function onBit(t:IFormString=null):void
		{
			var b0:Boolean = int(getField(1,1).getCellInfo()) == 1;
			var b6:Boolean = int(getField(1,2).getCellInfo()) == 1;
			//var b7:Boolean rg
			var pnum:int = int(getField(1,3).getCellInfo());
			var bf3:int = int(getField(CMD.K9_BIT_SWITCHES,3).getCellInfo());
			bf3 = UTIL.changeBit( bf3, 0, b0 );
			bf3 = UTIL.changeBit( bf3, 6, b6 );
			var bf2:int = int(getField(CMD.K9_BIT_SWITCHES,2).getCellInfo());
			bf2 = (bf2 & 0xF0) | (pnum);
			getField(1,3).visible = int(rg.getCellInfo())==1 && b0;
			getField(CMD.K5_TM_DELAY,1).disabled = !b0;
			rg.disabled = !b0;
			
			if (t && !LOADING) {
				getField(CMD.K9_BIT_SWITCHES,2).setCellInfo(bf2);
				getField(CMD.K9_BIT_SWITCHES,3).setCellInfo(bf3);
				remember(getField(CMD.K9_BIT_SWITCHES,3));
			}
		}*/
		
		public function localResize(w:int, h:int, real:Boolean=false):void
		{
			var realH:int = flist.length*30;
			var preferredH:int = h - 190;
			var value:int = realH > preferredH ? preferredH : realH;
			flist.height = value;
			
			go.movey("b", flist.y + value + 10 );
			
			manualResize();
		}
	}
}
/*
import components.interfaces.IDataAdapter;
import components.interfaces.IFormString;

class PartitionAdapter implements IDataAdapter
{
	public function adapt(value:Object):Object
	{
		return int(value) + 1;
	}
	public function change(value:Object):Object
	{
		return value;
	}
	public function perform(field:IFormString):void	{	}
	public function recover(value:Object):Object
	{
		return int(value) - 1;
	}
}*/