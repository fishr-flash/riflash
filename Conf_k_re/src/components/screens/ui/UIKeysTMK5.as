package components.screens.ui
{
	import flash.events.Event;
	
	import components.abstract.GroupOperator;
	import components.abstract.functions.loc;
	import components.abstract.servants.ResizeWatcher;
	import components.basement.UI_BaseComponent;
	import components.events.GUIEvents;
	import components.gui.Header;
	import components.gui.MFlexListSelectable;
	import components.gui.fields.FSCheckBox;
	import components.gui.fields.FSComboBox;
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
	import components.system.UTIL;
	
	public class UIKeysTMK5 extends UI_BaseComponent implements IResizeDependant
	{
		private var flist:MFlexListSelectable;
		private var rg:FSRadioGroup;
		private var bAdd:TextButton;
		private var bRemove:TextButton;
		private var bChange:TextButton;
		private var addDialog:AddDialog;
		private var go:GroupOperator;
		
		public function UIKeysTMK5()
		{
			super();

			go = new GroupOperator;
			
			addui( new FSShadow,CMD.K5_BIT_SWITCHES, "", null, 1 );
			addui( new FSShadow,CMD.K5_BIT_SWITCHES, "", null, 2 );
			addui( new FSShadow,CMD.K5_BIT_SWITCHES, "", null, 3 );
			
			addui( new FSCheckBox, 1, loc("tmkey_k5_on"), onBit, 1 );
			getLastElement().visible = false;
			/*attuneElement( 350+38, 50 );
			addui( new FSSimple, CMD.K5_TM_DELAY, loc("tmkey_k5_ignore_time"), null, 1, null, "0-9", 3, new RegExp(RegExpCollection.REF_1to254) );
			attuneElement( 350, 50 );*/
			
			addui( new FSShadow(), CMD.K5_TM_DELAY, "", null, 1 );
			
			addui( new FSCheckBox(), CMD.SEND_TM_KEY_TO_SERVER, loc( "send_tm_key_to_server" ), null, 1 );
			attuneElement( 500, NaN );
			
			rg = new FSRadioGroup( [
				{label:loc("tmkey_k5_diode_tm"), selected:false, id:0},
				{label:loc("tmkey_k5_diode_dup"), selected:false, id:1}
			], 1, 30 );
			rg.width = 400-12;
			//addChild( rg );
			rg.x = globalX;
			rg.y = globalY;
			addUIElement( rg, 1, 2, onBit );
			//globalY += rg.getHeight() + 10;
			
			FLAG_VERTICAL_PLACEMENT = false;
			var l:Array = UTIL.comboBoxNumericDataGenerator(1,16);
			addui( new FSComboBox, 1, "", onBit, 3, l ).x = 315;
			attuneElement( 40, NaN, FSComboBox.F_COMBOBOX_NOTEDITABLE );
			getLastElement().y -= 41;
			getLastElement().visible = false;
			getLastElement().setAdapter( new PartitionAdapter );
			FLAG_VERTICAL_PLACEMENT = true;
			
			//drawSeparator(632);
			
			var h:Header = new Header( [ {label:"№",align:"center",xpos:30},
				{label:loc("ui_tmkey"), xpos:30+45},
				{label:loc("tmkey_k5_parts"), xpos:30+45+160, width:100},
				{label:loc("tmkey_k5_gbr"), xpos:30+45+160+280-39, align:"center", width:100},
				{label:loc("tmkey_k5_force"), xpos:30+45+160+280+50+16, width:150, align:"center"} ], {size:12} );
			addChild( h );
			h.y = globalY;
			globalY += 30;
			
			flist = new MFlexListSelectable(OptKeyTM);
			addChild(flist);
			flist.height = 600;
			flist.width = 780-110;
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
			addDialog.y = 160;
			
			width = 730;
			
			starterCMD = [CMD.K5_BIT_SWITCHES, CMD.K5_PART_PARAMS, CMD.K5_TM_DELAY, CMD.K5_PART_OUT, CMD.K5_TM_KEY_CNT, CMD.SEND_TM_KEY_TO_SERVER];
			starterRefine(CMD.K5_AWIRE_PART_CODE);
		}
		override public function put(p:Package):void 
		{
			
			
			switch(p.cmd) {
				case CMD.K5_BIT_SWITCHES:
					LOADING = true;
					refreshCells( p.cmd );
					distribute( p.getStructure(), p.cmd );
					getField(1,1).setCellInfo( UTIL.isBit( 0, p.getStructure()[2] ));
					getField(1,2).setCellInfo( UTIL.isBit( 6, p.getStructure()[2] ) ? 1:0 );
					getField(1,3).setCellInfo( int(p.getStructure()[1]) & 0x0F );
					onBit();
					LOADING = false;
					break;
				case CMD.K5_TM_KEY_CNT:
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
					ResizeWatcher.addDependent(this);
					onRefresh();
					loadComplete();
					break;
				case CMD.K5_TM_DELAY:
					distribute( p.getStructure(), p.cmd );
					break;
				case CMD.K5_PART_OUT:
		//			distribute( p.getStructure(), p.cmd );
					break;
				
				case CMD.SEND_TM_KEY_TO_SERVER:
					distribute( p.getStructure(), p.cmd );
					break;
				
			}
		}
		override public function close():void
		{
			super.close();
			ResizeWatcher.removeDependent(this);
			addDialog.close();
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
			bAdd.disabled = flist.length == 0xff;
			bChange.disabled = flist.selected < 0;
			bRemove.disabled = flist.selected < 0;
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
		private function onBit(t:IFormString=null):void
		{
			var b0:Boolean = int(getField(1,1).getCellInfo()) == 1;
			var b6:Boolean = int(getField(1,2).getCellInfo()) == 1;
			//var b7:Boolean rg
			var pnum:int = int(getField(1,3).getCellInfo());
			var bf3:int = int(getField(CMD.K5_BIT_SWITCHES,3).getCellInfo());
			bf3 = UTIL.changeBit( bf3, 0, b0 );
			bf3 = UTIL.changeBit( bf3, 6, b6 );
			var bf2:int = int(getField(CMD.K5_BIT_SWITCHES,2).getCellInfo());
			bf2 = (bf2 & 0xF0) | (pnum);
			//getField(1,3).visible = int(rg.getCellInfo())==1 && b0;
			getField(CMD.K5_TM_DELAY,1).disabled = !b0;
			rg.disabled = !b0;
			
			if (t && !LOADING) {
				getField(CMD.K5_BIT_SWITCHES,2).setCellInfo(bf2);
				getField(CMD.K5_BIT_SWITCHES,3).setCellInfo(bf3);
				remember(getField(CMD.K5_BIT_SWITCHES,3));
			}
		}
		
		public function localResize(w:int, h:int, real:Boolean=false):void
		{
			var realH:int = flist.length*34;
			var preferredH:int = h - 260;
			var value:int = realH > preferredH ? preferredH : realH;
			flist.height = value;
			
			go.movey("b", flist.y + value + 10 );
		}
	}
}
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
}