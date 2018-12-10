package components.screens.ui
{
	import flash.events.Event;
	
	import components.abstract.GroupOperator;
	import components.abstract.RegExpCollection;
	import components.abstract.adapters.DecimalToHHMMAdapter;
	import components.abstract.functions.loc;
	import components.abstract.servants.ResizeWatcher;
	import components.abstract.servants.UniqueValidator;
	import components.abstract.sysservants.PartitionServant;
	import components.basement.UI_BaseComponent;
	import components.events.GUIEvents;
	import components.gui.Balloon;
	import components.gui.Header;
	import components.gui.MFlexListSelectable;
	import components.gui.fields.FSComboBox;
	import components.gui.fields.FSSimple;
	import components.gui.triggers.TextButton;
	import components.interfaces.IResizeDependant;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.protocol.statics.OPERATOR;
	import components.screens.opt.OpUserCode;
	import components.static.CMD;
	import components.static.DS;
	import components.system.Controller;
	import components.system.SavePerformer;
	import components.system.UTIL;
	
	// Коды клавиатур
	
	public class UIRUserCode extends UI_BaseComponent implements IResizeDependant
	{
		private var maxkeys:int;
		
		private var flist:MFlexListSelectable;
		private var total:int;
		private var bAdd:TextButton;
		private var bRemove:TextButton;
		private var go:GroupOperator;
		
		private static var uv:UniqueValidator;
		public static function getValidator():UniqueValidator
		{
			if (!uv)
				uv = new UniqueValidator;
			return uv;
		}
		
		public function UIRUserCode()
		{
			super();
			
			go = new GroupOperator;
			
			if ( DS.isfam( DS.K5 ) )
				maxkeys = 0xff;
			else if (DS.isfam(DS.K9))
				maxkeys = 0xa;
			
			addui( new FSSimple, CMD.K5_KBD_MKEY, loc("k5_usercode_change"), null, 1, null, "0-9", 4, new RegExp("^(\\d{4})$") );
			attuneElement( 300 );
			getLastElement().setAdapter( new HexCodeAdapter );
			getValidator().register(getLastElement());
			
			drawSeparator(441);
			
			var header:Header = new Header( [{label:"",xpos:30},
				{label:loc("k5_usercode_code"),xpos:60, width:100},
				{label:loc("k5_usercode_part_ctrl"), xpos:200-35, width:150}, 
				{label:loc("k5_usercode_force"), xpos:332, width:100}],
				{size:11, align:"center"} );
			
			addChild( header );
			header.y = globalY;
			
			globalY += 30;
			
			flist = new MFlexListSelectable(OpUserCode);
			addChild(flist);
			flist.height = 600;
			flist.width = 450;
			flist.y = globalY;
			flist.x = globalX;
			flist.addEventListener( GUIEvents.EVOKE_READY, onRefresh );

			go.add( "moving",drawSeparator(441) );
			
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
			
			if (DS.isfam( DS.K9 )) {
				//drawSeparator(441);
				globalY += 34;
				go.add( "moving",drawSeparator(441) );
				var l:Array = UTIL.getComboBoxList([["00:00", loc("g_no")], ["00:30","00:30"], ["05:00", "05:00"], ["10:00","10:00"]]);
				addui( new FSComboBox, CMD.K5_KEY_BLOCK, loc("ui_user_block_key_incorrect"), null, 1, l, "0-9:", 5, new RegExp(RegExpCollection.REF_TIME_0000and0010to1000) );
				attuneElement( 330, 70, FSComboBox.F_COMBOBOX_TIME | FSComboBox.F_ADAPTER_OVERRIDES_RECOVERY );
				getLastElement().setAdapter( new DecimalToHHMMAdapter );
				go.add( "moving",getLastElement() );
			}
			
			width = 470;
			
			starterCMD = [CMD.K5_KBD_MKEY, CMD.K5_KBD_KEY_CNT];
			if ( DS.isfam( DS.K5 )) {
				starterRefine( CMD.K5_AWIRE_PART_CODE );
				starterRefine( CMD.K5_PART_PARAMS );
			} else if (DS.isfam(DS.K9)) {
				starterRefine( CMD.K9_AWIRE_TYPE );
				starterRefine( CMD.K9_BIT_SWITCHES );
				starterRefine( CMD.K5_KEY_BLOCK, true );
				starterRefine( CMD.K9_PART_PARAMS );
			}
			
			
		}
		override public function put(p:Package):void
		{
			switch(p.cmd) {
				case CMD.K5_KBD_KEY:
					flist.put( p );
					ResizeWatcher.doResizeMe(this);
					onRefresh(null);
					loadComplete();
					break;
				case CMD.K5_KBD_KEY_CNT:
					SavePerformer.trigger({after:after, prepare:prepare});
					if( p.data[ 0 ][ 0 ] > maxkeys ) p.data[ 0 ][ 0 ] = 0;
					total = p.getStructure()[0];
					ResizeWatcher.addDependent(this);
					if (total == 0) {
						flist.clearlist();
						ResizeWatcher.doResizeMe(this);
						onRefresh(null);
						loadComplete();
					} else
						RequestAssembler.getInstance().fireReadSequence( CMD.K5_KBD_KEY, put, total );
					break;
				case CMD.K5_KBD_MKEY:
				case CMD.K5_KEY_BLOCK:
					distribute( p.getStructure(), p.cmd );
					break;
			}
		}
		public function localResize(w:int, h:int, real:Boolean=false):void
		{
			var realH:int = flist.length*30;
			var preferredH:int = h - (170+70);
			var value:int = realH > preferredH ? preferredH : realH;
			flist.height = value;
			
			go.movey("moving", flist.y + value + 10 );
			
			bAdd.disabled = total >= maxkeys || !isValidPartition();
		}
		private function onRefresh(e:Event):void
		{
			bAdd.disabled = total >= maxkeys || !isValidPartition();
			bRemove.disabled = flist.selected < 0;
			getValidator().revalidate();
		}
		private function onAdd():void
		{
			if (total < maxkeys) {
				var part:int = getValidPartition();
				if (part > 0) {
					
					var code:String;
					var valid:Boolean=false;
					while (!valid) {
						code = UTIL.createPassword(4,true);
						valid = getValidator().isValid(code);
					}
					var data:Array = [int("0x"+code),part,0];
					var p:Package = new Package;
					p.data = [];
					p.data[total] = data;
					p.structure = ++total;
					RequestAssembler.getInstance().fireEvent( new Request(CMD.K5_KBD_KEY, null, total, data ));
					RequestAssembler.getInstance().fireEvent( new Request(CMD.K5_KBD_KEY_CNT, null, 1, [total] ));
					flist.add(p,true);
					ResizeWatcher.doResizeMe(this);
				} else
					Balloon.access().show("k5_usercode_unable_add","k5_usercode_no_special_parts");
			}
		}
		private function isValidPartition():Boolean
		{
			var a:Array
			if (DS.isfam( DS.K5 ))
				return true;//a = OPERATOR.dataModel.getData(CMD.K5_PART_PARAMS);
			else if (DS.isfam(DS.K9)) {
				a = OPERATOR.dataModel.getData(CMD.K9_PART_PARAMS);
			
				var len:int = a.length;
				for (var i:int=0; i<len; i++) {
					if (a[i] && a[i][4] == 0 && PartitionServant.isPartitionAssigned(i+1))
						return true;
				}
				return false;
			}
			return true;
		}
		private function getValidPartition():int
		{
			var a:Array, len:int, i:int;
			if (DS.isfam( DS.K5 )) {
				a = OPERATOR.dataModel.getData(CMD.K5_PART_PARAMS);
				len = a.length;
				for (i=0; i<len; i++) {
					if (a[i] && a[i][4] == 0)
						return 1<<i;
				}
				return 0;
			} else if (DS.isfam(DS.K9)) {
				a = OPERATOR.dataModel.getData(CMD.K9_PART_PARAMS);
				len = a.length;
				for (i=0; i<len; i++) {
					if (a[i] && a[i][4] == 0 && PartitionServant.isPartitionAssigned(i+1))
						return 1<<i;
				}
			}
			return 0;
		}
		private function onRemove():void
		{
			if (Controller.getInstance().isSaveButtonActive()) {
				Balloon.access().show("ui_key_k5_remove_impossible","ui_key_k5_save_first");
			} else {
				loadStart();
				var str:int = flist.removeSelected()-1;
				var list:Array = OPERATOR.dataModel.getData(CMD.K5_KBD_KEY).slice();
				list.splice(str,1);
				var len:int = list.length;
				for (var i:int=str; i<len; i++) {
					RequestAssembler.getInstance().fireEvent( new Request(CMD.K5_KBD_KEY, null, i+1, list[i] ));
				}
				RequestAssembler.getInstance().fireEvent( new Request(CMD.K5_KBD_KEY_CNT, null, 1, [--total] ));
				if (total > 0)
					RequestAssembler.getInstance().fireReadSequence( CMD.K5_KBD_KEY, put, total );
				else {
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
		private function prepare():void
		{
			loadStart();
		}
		private function after():void
		{
			///var alist:Array = OPERATOR.dataModel.getData(CMD.K5_KBD_KEY).slice();
			var list:Array = flist.extract();
			var str:int = -1;
			var len:int = list.length;
			for (var i:int=0; i<len; i++) {
				if (list[i][1] == 0) {
					if (str < 0)
						str = i;
					list.splice(i,1);
					i--;
					len--;
				}
			}
			if (len != total) {
				total = len;
				for (i=str; i<len; i++) {
					RequestAssembler.getInstance().fireEvent( new Request(CMD.K5_KBD_KEY, null, i+1, list[i] ));
				}
				RequestAssembler.getInstance().fireEvent( new Request(CMD.K5_KBD_KEY_CNT, null, 1, [total] ));
				if (total > 0)
					RequestAssembler.getInstance().fireReadSequence( CMD.K5_KBD_KEY, put, total );
				else
					RequestAssembler.getInstance().fireEvent( new Request( CMD.K5_KBD_KEY_CNT, put ));
			} else {
				loadComplete();
			}
		}
	}
}
import components.interfaces.IDataAdapter;
import components.interfaces.IFormString;
import components.system.UTIL;

class HexCodeAdapter implements IDataAdapter
{
	public function adapt(value:Object):Object
	{
		return UTIL.fz(int(value).toString(16),4);
	}
	public function change(value:Object):Object
	{
		return value;
	}
	public function perform(field:IFormString):void
	{
	}
	public function recover(value:Object):Object
	{
		return int("0x"+value);
	}
}