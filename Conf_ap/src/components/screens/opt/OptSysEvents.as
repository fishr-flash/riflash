package components.screens.opt
{
	import flash.events.Event;
	
	import components.abstract.RegExpCollection;
	import components.abstract.functions.loc;
	import components.basement.OptionsBlock;
	import components.gui.fields.FSComboBox;
	import components.gui.fields.FSShadow;
	import components.interfaces.IFocusable;
	import components.interfaces.IFormString;
	import components.static.CMD;
	import components.system.SavePerformer;
	import components.system.UTIL;
	
	public class OptSysEvents extends OptionsBlock
	{
		public var active:Boolean=true;
		public var period:Boolean;
		
		public function OptSysEvents(txt:String,wid:int,struc:int, period:Boolean=false)
		{
			super();
			
			this.period = period;
			
			structureID = struc;
			var time_list:Array;
			var reg:String;
			
			if ( period ) {
				time_list = [ {label:loc("g_no"),data:"0"},
					{label:"1", data:"1"},
					{label:"6", data:"6"},
					{label:"12", data:"12"},
					{label:"24", data:"24"} ];
				reg = RegExpCollection.REF_0to24_none;
				createUIElement( new FSComboBox, CMD.OP_AA_ADDITIONAL_AUTOTEST, txt,null,1,time_list,"0-9:",2,new RegExp( reg ));
				getLastElement().setAdapter( new HexAdapter );
				attuneElement( wid,70 );
			} else {
				time_list = [ {label:loc("g_no"),data:"255:255"},
					{label:"00:00", data:"00:00"},
					{label:"08:00", data:"08:00"},
					{label:"16:00", data:"16:00"} ];
				reg = "^("+RegExpCollection.RE_00to2359+"|255:255|"+loc("g_no")+")$";
				
				createUIElement( new FSShadow, CMD.OP_AH_AUTOTEST_HOURS, "", null, 1 );
				createUIElement( new FSShadow, CMD.OP_AM_AUTOTEST_MINUTES, "", null, 1 );
				
				createUIElement( new FSComboBox, 0, txt,changeAutotest,1,time_list,"0-9:",5,new RegExp( reg ));
				attuneElement( wid,70, FSComboBox.F_COMBOBOX_TIME );
			}
		}
		public function set focusorder(v:int):void
		{
			(getField(0,1) as IFocusable).focusorder = v;
		}
		public function putRaw(re:Array):void
		{
			if (period)
				getField(CMD.OP_AA_ADDITIONAL_AUTOTEST,1).setCellInfo( re[0] );
			else
				getField(0,1).setCellInfo( mergeIntoTime( re[0], re[1] ) );
		}
		private function changeAutotest(target:IFormString):void
		{
			var info:String = String(getField(0,1).getCellInfo());
			/*if( info == "255,255" ) {
				getField(0,1).setCellInfo("0");
			} else
				getField(0,1).setCellInfo("1");
			*/
			var a:Array;
			if( info != "255,255" ) {
				a = info.split(",");
				active = true;
			} else {
				a = ["0","0"];
				active = false;
			}
			
			trace( structureID + " active: " + active );
			
			getField( CMD.OP_AH_AUTOTEST_HOURS,1 ).setCellInfo( UTIL.fz(a[0],2));
			getField( CMD.OP_AM_AUTOTEST_MINUTES,1 ).setCellInfo(UTIL.fz(a[1],2));
			
			if (target)	{// значит пришел искусственный эвент
				SavePerformer.remember(getStructure(),getField( CMD.OP_AH_AUTOTEST_HOURS,1 ));
				SavePerformer.remember(getStructure(),getField( CMD.OP_AM_AUTOTEST_MINUTES,1 ));
				this.dispatchEvent( new Event(Event.CHANGE) );
			}
		}
		public function set disable(b:Boolean):void
		{
			var f:IFormString = getField(0,1); 
			if (b) {
				f.setCellInfo( "255:255" );
				changeAutotest(null);
			}
			f.disabled = b;
		}
		public function none():void
		{
			getField(0,1).setCellInfo( "255:255" );
			changeAutotest(null);
		}
	}
}
import components.interfaces.IDataAdapter;
import components.interfaces.IFormString;

class HexAdapter implements IDataAdapter
{
	public function adapt(value:Object):Object
	{
		var res:int = int("0x"+value);
		return res;
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
		return int(value).toString(16).toUpperCase();
	}
}