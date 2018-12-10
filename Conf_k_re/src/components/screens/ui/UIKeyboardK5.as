package components.screens.ui
{
	import flash.events.Event;
	
	import components.abstract.GroupOperator;
	import components.abstract.adapters.DecimalToHHMMAdapterKeyboardK5;
	import components.abstract.functions.loc;
	import components.abstract.servants.ResizeWatcher;
	import components.abstract.servants.UniqueValidator;
	import components.basement.UI_BaseComponent;
	import components.events.GUIEvents;
	import components.gui.Balloon;
	import components.gui.Header;
	import components.gui.MFlexListSelectable;
	import components.gui.fields.FSBitBox;
	import components.gui.fields.FSCheckBox;
	import components.gui.fields.FSComboBox;
	import components.gui.fields.FSShadow;
	import components.gui.fields.FormEmpty;
	import components.gui.triggers.TextButton;
	import components.interfaces.IFormString;
	import components.interfaces.IResizeDependant;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.protocol.statics.OPERATOR;
	import components.screens.opt.OpKeyboard;
	import components.static.CMD;
	import components.system.Controller;
	import components.system.UTIL;
	
	public class UIKeyboardK5 extends UI_BaseComponent implements IResizeDependant
	{
		private var flist:MFlexListSelectable;
		private var total:int;
		private var bAdd:TextButton;
		private var bRemove:TextButton;
		private var go:GroupOperator;
		
		private var fblock:IFormString;
		private var fblocktrigger:IFormString;
		
		private static var uv:UniqueValidator;
		public static function getValidator():UniqueValidator
		{
			if (!uv)
				uv = new UniqueValidator;
			return uv;
		}
		
		public function UIKeyboardK5()
		{
			super();
			
			var wid:int = 400;
			
			addui( new FSBitBox, CMD.K5_BIT_SWITCHES, loc("ui_key_k5_panic_on"), null, 1, [3] );
			attuneElement( wid + 3 );
			addui( new FSShadow, CMD.K5_BIT_SWITCHES, "", null, 2 );
			addui( new FSShadow, CMD.K5_BIT_SWITCHES, "", null, 3 );
			
			var l:Array = UTIL.getComboBoxList([[0,loc("g_switchedoff")],[500,loc("500")],[5000,loc("5000")],[15000,loc("15000")],[30000,loc("30000")]]);
			

			var arr:Array = UTIL.getComboBoxList([["00:00", loc("g_no")], ["00:30","00:30"], ["05:00", "05:00"], ["10:00","10:00"], ["60:00","60:00"]]);
			fblock = addui( new FSComboBox, CMD.K5_KEY_BLOCK, loc("ui_user_block_key_incorrect"), onBlockDisablePassive, 1, arr, "0-9:", 5, new RegExp( /([0-5]\d:[0-5]\d)|(60:00)/) );
			attuneElement( 336, 80, FSComboBox.F_COMBOBOX_TIME | FSComboBox.F_ADAPTER_OVERRIDES_RECOVERY );
			getLastElement().setAdapter( new DecimalToHHMMAdapterKeyboardK5 );
			
			fblocktrigger = addui( new FSCheckBox, 0, loc("k5_sysev_disable_block"), onBlockDisable, 4 );
			(fblocktrigger as FormEmpty).x = 420-157;
			attuneElement( 168 );
			
			
			
			
			
				
			drawSeparator(341+22+90);	
			
			var header:Header = new Header( [{label:loc("g_number"),xpos:20, width:150},
				{label:loc("ui_key_k5_adr"),align:"center",xpos:70-32, width:150},
				{label:loc("ui_key_k5_objnum"),align:"center",xpos:160, width:150}], {size:11} );
			
			addChild( header );
			header.y = globalY;
			globalY += 30;
			
			flist = new MFlexListSelectable(OpKeyboard);
			addChild(flist);
			flist.height = 600;
			flist.width = 780;
			flist.y = globalY;
			flist.x = globalX;
			flist.addEventListener( GUIEvents.EVOKE_READY, onRefresh );
			
			go = new GroupOperator;
			
			go.add( "moving",drawSeparator(341+22+90));
			
			bAdd = new TextButton;
			addChild( bAdd );
			bAdd.setUp( loc("g_add"), onAdd );
			bAdd.x = globalX;
			bAdd.y = globalY;
			go.add( "moving",bAdd );
			
			bRemove = new TextButton;
			addChild( bRemove );
			bRemove.setUp( loc("g_remove"), onRemove );
			bRemove.x = globalX + 120;
			bRemove.y = globalY;
			
			go.add( "moving",bRemove );
			
			starterCMD = [CMD.K5_BIT_SWITCHES, CMD.K5_KEY_BLOCK, CMD.K5_KBD_COUNT];
		}
		override public function put(p:Package):void
		{
			switch(p.cmd) {
				case CMD.K5_BIT_SWITCHES:
					refreshCells( p.cmd );
					distribute( p.getStructure(), p.cmd );
					break;
				case CMD.K5_KBD_NUMOBJ:
					onRefresh(null);
					loadComplete();
				case CMD.K5_KBD_INDEX:				
					flist.put( p, p.cmd == CMD.K5_KBD_INDEX );
					ResizeWatcher.doResizeMe(this);
					break;
				case CMD.K5_KEY_BLOCK:
					distribute( p.getStructure(), p.cmd );
					onBlockDisablePassive(null);
					break;
				case CMD.K5_KBD_COUNT:
					total = p.getStructure()[0] == 0xFF?0:p.getStructure()[0];
					ResizeWatcher.addDependent(this);
					if (total == 0) {
						onRefresh(null);
						loadComplete();
					} else {
						RequestAssembler.getInstance().fireReadSequence( CMD.K5_KBD_INDEX, put, total );
						RequestAssembler.getInstance().fireReadSequence( CMD.K5_KBD_NUMOBJ, put, total );
					}
					break;
			}
		}
		public function localResize(w:int, h:int, real:Boolean=false):void
		{
			var realH:int = flist.length*30;
			var preferredH:int = h - 170;
			var value:int = realH > preferredH ? preferredH : realH;
			flist.height = value;
			
			go.movey("moving", flist.y + value + 10 );
		}
		private function onAdd():void
		{
			if (Controller.getInstance().isSaveButtonActive()) {
				Balloon.access().show("ui_key_k5_add_impossible","ui_key_k5_save_first");
			} else if (total <= 0xf) {
				
				var code:int = 0;
				var valid:Boolean=false;
				while (!valid) {
					code++;
					valid = getValidator().isValid(code);
				}
				total++;
				var p:Package = new Package;
				p.data = [];
				p.cmd = CMD.K5_KBD_INDEX;
				p.data[total-1] = [code];
				p.structure = total;
				RequestAssembler.getInstance().fireEvent( new Request(CMD.K5_KBD_INDEX, null, total, [code] ));
			//	flist.add(p,true);
				var a:Array = [p];
				p = new Package;
				p.data = [];
				p.cmd = CMD.K5_KBD_NUMOBJ;
				p.data[total-1] = [0];
				p.structure = total;
				RequestAssembler.getInstance().fireEvent( new Request(CMD.K5_KBD_NUMOBJ, null, total, [0] ));
				a.push(p);
				flist.addpack(a,true);
				
				RequestAssembler.getInstance().fireEvent( new Request(CMD.K5_KBD_COUNT, null, 1, [total] ));
				
				ResizeWatcher.doResizeMe(this);
				onRefresh(null);
			} else
				Balloon.access().show("ui_key_k5_add_impossible","ui_key_k5_exceed16");
		}
		private function onRemove():void
		{
			if (Controller.getInstance().isSaveButtonActive()) {
				Balloon.access().show("ui_key_k5_remove_impossible","ui_key_k5_save_first");
			} else {
				loadStart();
				var str:int = flist.removeSelected()-1;
				var list:Array = OPERATOR.dataModel.getData(CMD.K5_KBD_INDEX).slice();
				list.splice(str,1);
				var len:int = list.length;
				for (var i:int=str; i<len; i++) {
					RequestAssembler.getInstance().fireEvent( new Request(CMD.K5_KBD_INDEX, null, i+1, list[i] ));
				}
				list = OPERATOR.dataModel.getData(CMD.K5_KBD_NUMOBJ).slice();
				list.splice(str,1);
				len = list.length;
				for (i=str; i<len; i++) {
					RequestAssembler.getInstance().fireEvent( new Request(CMD.K5_KBD_NUMOBJ, null, i+1, list[i] ));
				}
				
				RequestAssembler.getInstance().fireEvent( new Request(CMD.K5_KBD_COUNT, null, 1, [--total] ));
				if (total > 0) {
					RequestAssembler.getInstance().fireReadSequence( CMD.K5_KBD_INDEX, put, total );
					RequestAssembler.getInstance().fireReadSequence( CMD.K5_KBD_NUMOBJ, put, total );
				} else {
					var p:Package = new Package;
					p.data = [];
					p.structure = 0;
					flist.put(p,true);
					ResizeWatcher.doResizeMe(this);
					onRefresh(null);
					loadComplete();
				}
			}
		}
		private function onBlockDisable(t:IFormString):void
		{
			var b:Boolean = fblocktrigger.getCellInfo() == 1;
			fblock.disabled = b; 
			if (b)
				fblock.setCellInfo(0);
			else
				fblock.setCellInfo(20);
			remember(fblock);
		}
		private function onBlockDisablePassive(t:IFormString):void
		{
			
			var iszero:Boolean = int(fblock.getCellInfo()) == 0;
			
			fblocktrigger.setCellInfo( iszero );
			getField(CMD.K5_KEY_BLOCK,1).disabled = iszero;
			if (t)
				remember( t );
		}
		private function onRefresh(e:Event):void
		{
			bRemove.disabled = flist.selected < 0;
		//	bAdd.disabled = flist.length >= 16;
			bAdd.disabled = flist.length >= 255;
			getValidator().revalidate();
		}
	}
}
import components.interfaces.IDataAdapter;
import components.interfaces.IFormString;

class AdapterDoubler implements IDataAdapter
{
	public function adapt(value:Object):Object
	{
		return int(int(value)/2);
	}
	public function change(value:Object):Object
	{
		if(String(value).length == 0)
			return 0;
		return value;
	}
	public function perform(field:IFormString):void	{	}
	public function recover(value:Object):Object
	{
		return int(value)*2;
	}
}