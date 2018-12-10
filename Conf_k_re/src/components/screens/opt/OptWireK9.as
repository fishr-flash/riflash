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
	
	public class OptWireK9 extends OptionListBlock implements IFlexListItem
	{
		public var snum:int;
		
		private var fState:IFormString;
		private var fNum:IFormString;
		
		private var fEnterDelay:IFormString;
		private var fPartition:IFormString;
		private var fcid:IFormString;
		private var ftype:IFormString;		
		private var fdefaultstate:IFormString;
		
		public function OptWireK9(s:int)
		{
			super();
			
			FLAG_VERTICAL_PLACEMENT = false;
			globalX = 0;
			
			structureID = s;
			snum = s;
			
			PairLinkator.access().register(this);
			
//			FLAG_SAVABLE = false;
			fNum = addui( new FormString, 0, s.toString(), null, 1 );
			attuneElement( 55 );
			globalX += 55;
			fState = addui( new FormString, CMD.K5_AWIRE_STATE, "", null, 1 );
			attuneElement( 100 );
			
			globalX += 100;
			var l:Array = UTIL.getComboBoxList([[0,loc("wire_state_open")],[1,loc("wire_state_closed")]]);
			fdefaultstate = addui( new FSComboBox, CMD.K9_AWIRE_TYPE, "", null, 1, l);
			attuneElement( NaN, 120, FSComboBox.F_COMBOBOX_NOTEDITABLE );
			globalX += 125;
//			FLAG_SAVABLE = true;

			var a:Array  = CIDServant.getEvent(CIDServant.CID_K5WIRE);
			
			fcid = addui( new FSComboBox, CMD.K9_AWIRE_TYPE, "", null, 3, CIDServant.getEvent(CIDServant.CID_K5WIRE) );
			attuneElement( NaN, 200, FSComboBox.F_COMBOBOX_NOTEDITABLE );
			getLastElement().setAdapter( new HexAdapter );
			globalX += 205;
			
			l = UTIL.getComboBoxList([[0,"1"],[1,"2"],[2,"3"],[3,"4"],[4,"5"],[5,"6"]]);
			
			fPartition = addui( new FSComboBox, CMD.K9_AWIRE_TYPE, "", onPartition, 2, l );
			attuneElement( NaN, 60, FSComboBox.F_COMBOBOX_NOTEDITABLE );
			globalX += 85;
			
			fEnterDelay = addui( new FormString, CMD.K9_AWIRE_TYPE, "", onPartition, 4, l, "0-9", 3, new RegExp(RegExpCollection.REF_0to254) );
			getLastElement().setAdapter( new NumericAdapter );
			attuneElement( 60, NaN, FormString.F_ALIGN_CENTER | FormString.F_EDITABLE );
			globalX += 85;
			
			addui( new FormString, CMD.K5_PART_DELAY, "", null, s, l );
			getLastElement().setAdapter( new NumericAdapter );
			attuneElement( 100, NaN, FormString.F_ALIGN_CENTER );
			globalX += 105;
			
			ftype = addui( new FormString, 4, "", null, s, l );
			getLastElement().setAdapter( new TypeAdapter );
			attuneElement( 100 );
			
			width = 900;
		}
		public function put(p:Package):void
		{
			switch(p.cmd) {
				case CMD.K5_AWIRE_STATE:
					fState.setCellInfo( getStateName(p.getStructure(snum)[0]) );
					break;
				/*case CMD.K5_AWIRE_DELAY:
					getField(p.cmd, snum ).setCellInfo(p.getStructure()[snum-1]);
					onPartition(null);
				/*case CMD.K5_PART_DELAY:
					getField(p.cmd, snum ).setCellInfo(p.getStructure()[snum-1]);*/
					break;
				case CMD.K9_AWIRE_TYPE:
					distribute(p.getStructure(snum),p.cmd);
					onPartition(null);
					break;
				case CMD.K5_AWIRE_PART_CODE:
					getField(p.cmd, snum ).setCellInfo(p.getStructure()[snum-1]);
					getField(p.cmd, snum + UIRWire.TOTAL_WIRE ).setCellInfo(p.getStructure()[snum-1 + UIRWire.TOTAL_WIRE]);
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
				remember(fPartition);
			} else {
				if ( RPartServant.access().isFire(int(fPartition.getCellInfo())+1) ) {
					fPartition.setCellInfo(part);
					onPartition(null);
					remember(fPartition);
				}
			}
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
				//	onChange();
				}
			}
			// если пожар включен - смена пожарного шлейфа заблокирована
			fcid.disabled = fire;
			fdefaultstate.disabled = fire;
			
			var type:int;
			var pdelay:int = RPartServant.access().getExitDelay(pnum);//int(fEnterDelay.getCellInfo());
			
			getField(CMD.K5_PART_DELAY, snum ).setCellInfo(pdelay);
			
			if (fire) {
				// если шлей пожарный при сухих контактах - он автоматом должен быть мгновенный
				var isdry:Boolean = UTIL.isBit(1,int(OPERATOR.dataModel.getData(CMD.K9_BIT_SWITCHES)[0][0]));
				if (isdry)
					type = TypeAdapter.MGNOV;
				else
					type = TypeAdapter.FIRE;
			} else if (pdelay == 0 && wdelay == 0)
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
import components.interfaces.IDataAdapter;
import components.interfaces.IFormString;
import components.screens.opt.OptWireK9;
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
	
	private var list:Vector.<OptWireK9>;
	
	public function getpair(str:int):OptWireK9
	{
		if( UTIL.isEven(str) ) 
			return list[str-2];
		return list[str];
	}
	
	public function register(opt:OptWireK9):void
	{
		if (!list)
			list = new Vector.<OptWireK9>(5);
		list[opt.snum-1] = opt;
	}
}