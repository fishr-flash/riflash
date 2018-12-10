package components.screens.opt
{
	import components.abstract.RegExpCollection;
	import components.abstract.adapters.HexAdapter;
	import components.abstract.functions.loc;
	import components.abstract.servants.CIDServant;
	import components.abstract.servants.RPartServant;
	import components.basement.OptionListBlock;
	import components.gui.fields.FSComboBox;
	import components.gui.fields.FormEmpty;
	import components.gui.fields.FormString;
	import components.interfaces.IFlexListItem;
	import components.interfaces.IFormString;
	import components.protocol.Package;
	import components.protocol.statics.OPERATOR;
	import components.screens.ui.UIRWire;
	import components.static.CMD;
	import components.system.UTIL;
	
	public class OptRWireK5A extends OptionListBlock implements IFlexListItem
	{
		public var snum:int;
		
		private var fState:IFormString;
		private var fNum:IFormString;
		
		private var fEnterDelay:IFormString;
		private var fPartition:IFormString;
		private var fcid:IFormString;
		private var ftype:IFormString;		
		private var fdefaultstate:IFormString;
		
		public function OptRWireK5A(s:int)
		{
			super();
			
			
			
			FLAG_VERTICAL_PLACEMENT = false;
			globalX = 0;
			
			snum = s;
			
			PairLinkator.access().register(this);
			
			FLAG_SAVABLE = false;
			fNum = addui( new FormString, 0, s.toString(), null, 1 );
			attuneElement( 55 );
			globalX += 55;
			fState = addui( new FormString, CMD.K5_AWIRE_STATE, "", null, 1 );
			attuneElement( 100 );
			
			globalX += 100;
			var l:Array = UTIL.getComboBoxList([[0,loc("wire_state_open")],[1,loc("wire_state_closed")]]);
			fdefaultstate = addui( new FSComboBox, 3, "", onChange, snum, l);
			attuneElement( NaN, 120, FSComboBox.F_COMBOBOX_NOTEDITABLE );
			globalX += 125;
			FLAG_SAVABLE = true;
			
			fcid = addui( new FSComboBox, CMD.K5_AWIRE_PART_CODE, "", null, s  + 16, CIDServant.getEvent(CIDServant.CID_K5WIRE) );
			attuneElement( NaN, 200, FSComboBox.F_COMBOBOX_NOTEDITABLE );
			getLastElement().setAdapter( new HexAdapter );
			globalX += 205;
			
			var arrLNums:Array = [[0,"1"],[1,"2"],[2,"3"],[3,"4"],[4,"5"],
				[5,"6"],[6,"7"],[7,"8"]];
			if( snum  > 8 ) arrLNums = arrLNums.concat( [ [ 8, "9" ] ]  );
			
			
			l = UTIL.getComboBoxList( arrLNums );
			
			
			fPartition = addui( new FSComboBox, CMD.K5_AWIRE_PART_CODE, "", onPartition, s, l );
			attuneElement( NaN, 60, FSComboBox.F_COMBOBOX_NOTEDITABLE );
			globalX += 85;
			
			fEnterDelay = addui( new FormString, CMD.K5_AWIRE_DELAY, "", onPartition, s, l, "0-9", 3, new RegExp(RegExpCollection.REF_0to254) );
			getLastElement().setAdapter( new NumericAdapter );
			attuneElement( 60, NaN, FormString.F_ALIGN_CENTER | FormString.F_EDITABLE );
			globalX += 85;
			
			addui( new FormString, CMD.K5_PART_DELAY, "", null, s, l );
			getLastElement().setAdapter( new NumericAdapter );
			attuneElement( 100, NaN, FormString.F_ALIGN_CENTER );
			globalX += 105;
			
			ftype = addui( new FormString, 4, "", null, s, l );
			getLastElement().setAdapter( new TypeAdapter );
			attuneElement( 200 );
			
			width = 900;
			
			
		}
		
		public function put(p:Package):void
		{
			switch(p.cmd) {
				case CMD.K5_AWIRE_STATE:
					fState.setCellInfo( getStateName(p.getStructure(snum)[0]) );
					break;
				case CMD.K5_AWIRE_DELAY:
					getField(p.cmd, snum ).setCellInfo(p.getStructure()[snum-1]);
					onPartition(null);
				/*case CMD.K5_PART_DELAY:
					getField(p.cmd, snum ).setCellInfo(p.getStructure()[snum-1]);*/
					break;
				case CMD.K5_AWIRE_TYPE:
					var bw:BitWatcher = BitWatcher.access(); 
					bw.putData(p);
					getField(3,snum).setCellInfo( bw.getValue(snum) );
					break;
				case CMD.K5_AWIRE_PART_CODE:
					
					
					const partNm:String = snum > 8?"8":p.getStructure()[snum-1];
					
					
					getField(p.cmd, snum ).setCellInfo(  partNm );
					getField(p.cmd, snum + 16 ).setCellInfo(p.getStructure()[snum-1 + 16 ]);
					break
			}
		}
		
		private function getStateName(n:int):String
		{
			var normal:int = int(fdefaultstate.getCellInfo());
			
			switch(n) {
				case 0:
				case 1:
					return normal == n ? loc("wire_state_norm") : loc("wire_state_violated")  
				case 2:
					return loc("wire_state_accident");
			}
			return loc("wire_state_unknwn");
		}
		public function change(p:Package):void
		{
		}
		public function extract():Array
		{
			return null;
		}
		override public function get height():Number
		{
			return 30;
		}
		public function isSelected():Boolean
		{
			return false;
		}
		
		public function kill():void		{		}
		public function putRaw(value:Object):void		{		}
		public function set selectLine(b:Boolean):void		
		{	// true значит видны только нечетные
		}
		public function setPartittion(part:int):void
		{
			if( RPartServant.access().isFire(part+1)) {
				fPartition.setCellInfo(part);
				onPartition(null);
			} else {
				if ( RPartServant.access().isFire(int(fPartition.getCellInfo())+1) ) {
					fPartition.setCellInfo(part);
					onPartition(null);
				}
			}
		}
		private function onChange():void
		{
			BitWatcher.access().change( getField(3,snum).getCellInfo() == 1, snum );
		}
		private function onPartition(t:IFormString):void
		{
			var pnum:int = int(fPartition.getCellInfo());
			
			// включено ли хотя бы одно из 24 или пожар (разделы)
			var u:Boolean = RPartServant.access().isUtility(pnum+1);
			// включен ли пожарный раздел
			var fire:Boolean = RPartServant.access().isFire(pnum+1);
			var wdelay:int = int(fEnterDelay.getCellInfo());
			
			if (u) {
				(fEnterDelay as FormEmpty).attune( FormString.F_NOTSELECTABLE );
				if (wdelay != 0) {
					fEnterDelay.setCellInfo(0);
					remember(fEnterDelay);
				}
			} else
				(fEnterDelay as FormEmpty).attune( FormString.F_EDITABLE);
			
			if (fire) {
				// если включен прожар, надо проверить ЦИД, если что, то записать и сохранить
				var cidvalue:int = UTIL.isEven(snum) ? 0x110 : 0x118;
				if (fcid.getCellInfo() != cidvalue) {
					fcid.setCellInfo( cidvalue );
					remember(fcid);
				}
				if (fdefaultstate.getCellInfo() != "0") {
					fdefaultstate.setCellInfo(0);
					onChange();
				}
			}
			// если пожар включен - смена пожарного шлейфа заблокирована
			fcid.disabled = fire;
			fdefaultstate.disabled = fire;
			
			var type:int;
			var pdelay:int = OPERATOR.dataModel.getData(CMD.K5_PART_DELAY)[0][pnum];
			//var pdelay:int = RPartServant.access().getExitDelay(pnum);
			
			getField(CMD.K5_PART_DELAY, snum ).setCellInfo(pdelay);
			
			if (fire)
				type = TypeAdapter.FIRE;
			else if (pdelay == 0 && wdelay == 0)
				type = TypeAdapter.MGNOV;
			else if (pdelay > 0 && wdelay == 0)
				type = TypeAdapter.VYHOD;
			else if (pdelay == 0 && wdelay > 0)
				type = TypeAdapter.VHOD;
			else
				type = TypeAdapter.PROHOD;
				
			ftype.setCellInfo( type );
			
			if (t) {
				remember(t);
				PairLinkator.access().getpair(snum).setPartittion(pnum);
			}
		}
	}
}
import components.abstract.functions.loc;
import components.basement.OptionsBlock;
import components.gui.fields.FSShadow;
import components.interfaces.IDataAdapter;
import components.interfaces.IFormString;
import components.protocol.Package;
import components.screens.opt.OptRWireK5A;
import components.static.CMD;
import components.system.UTIL;

class TypeAdapter implements IDataAdapter
{
	public static const MGNOV:int = 0;
	public static const VHOD:int = 1;
	public static const PROHOD:int = 2;
	public static const VYHOD:int = 3;
	public static const FIRE:int = 4;
	
	public function adapt(value:Object):Object
	{
		switch(int(value)) {
			case 0:
				return loc("wire_type_insta");
			case 1:
				return loc("wire_type_entrance");
			case 2:
				return loc("wire_type_passing");
			case 3:
				return loc("wire_type_exit");
			case 4:
				return loc("wire_type_fire");
		}
		return value;
	}
	public function change(value:Object):Object
	{
		return null;
	}
	public function perform(field:IFormString):void	{	}
	public function recover(value:Object):Object
	{
		return null;
	}
}
class NumericAdapter implements IDataAdapter
{
	public function adapt(value:Object):Object
	{
		
		return UTIL.fz(value,3);
	}
	public function change(value:Object):Object
	{
		return value;
	}
	public function perform(field:IFormString):void	{	}
	public function recover(value:Object):Object
	{
		return value;
	}
}
class PairLinkator
{
	private static var inst:PairLinkator;
	public static function access():PairLinkator
	{
		if(!inst)
			inst = new PairLinkator;
		return inst;
	}
	
	private var list:Vector.<OptRWireK5A>;
	
	public function getpair(str:int):OptRWireK5A
	{
		if( UTIL.isEven(str) ) 
			return list[str-2];
		return list[str];
	}
	
	public function register(opt:OptRWireK5A):void
	{
		if (!list)
			list = new Vector.<OptRWireK5A>( 7 );
		list[opt.snum-1] = opt;
	}
}
class BitWatcher extends OptionsBlock
{
	private static var inst:BitWatcher;
	public static function access():BitWatcher
	{
		if(!inst)
			inst = new BitWatcher;
		return inst;
	}
	
	private var f:IFormString;
	
	public function BitWatcher()
	{
		super();
		
		structureID = 1;
		f = addui( new FSShadow, CMD.K5_AWIRE_TYPE, "", null, 1 );
	}
	override public function putData(p:Package):void
	{
		f.setCellInfo(p.getStructure()[0]);
		return;
		/*var bf:int = p.getStructure()[0];
		f.setCellInfo( (bf >> 8) | ((bf & 0x00FF) << 8 ); );*/
	}
	public function change(b:Boolean, num:int):void
	{
		var bfraw:int = int(f.getCellInfo());
		var bf:int = (bfraw >> 8) | ((bfraw & 0x00FF) << 8 );
		bf = UTIL.changeBit(bf,num-1,b);
		
		bfraw = (bf >> 8) | ((bf & 0x00FF) << 8 );
			
		f.setCellInfo(bfraw);
		remember(f);
	}
	public function getValue(s:int):int
	{
		var bfraw:int = int(f.getCellInfo());
		var bf:int = (bfraw >> 8) | ((bfraw & 0x00FF) << 8 );
		
		var b:Boolean = UTIL.isBit(s-1,bf );
		var r:int = b ? 1:0;
		return r;
	}
}