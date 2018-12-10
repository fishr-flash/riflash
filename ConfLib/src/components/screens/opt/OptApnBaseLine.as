package components.screens.opt
{
	import components.abstract.functions.loc;
	import components.basement.OptionListBlock;
	import components.gui.fields.FormString;
	import components.interfaces.IFlexListItem;
	import components.protocol.Package;
	import components.protocol.statics.OPERATOR;
	import components.static.CMD;
	
	public class OptApnBaseLine extends OptionListBlock implements IFlexListItem
	{
		private var fImsi:FormString;
		private var fOperator:FormString;
		private var fApn:FormString;
		private var fUser:FormString;
		private var fPass:FormString;
		private var pcounter:int;
		
		public function OptApnBaseLine(s:int)
		{
			super();
			
			structureID = s;
			
			globalFocusGroup = 500*s;
			
			FLAG_VERTICAL_PLACEMENT = false;
			fImsi = add("IMSI",100,5);
			fOperator = add("ui_apn_operator",100);
			fApn = add("ui_apn_access_point",350);
			fUser = add("g_user",100 );
			fPass = add("g_pass",100);
			
			
			width = globalX;
		}
		private function add(title:String, w:int, maxchars:int=20):FormString
		{
			
			addui( new FormString, CMD.GPRS_APN_BASE, loc(title), null, ++pcounter, null, "",  OPERATOR.getSchema( CMD.GPRS_APN_BASE ).Parameters[ pcounter - 1 ].Length ).x = globalX;
			
			globalX += w + 10;
			if (structureID==0)
				attuneElement( w, NaN, FormString.F_ALIGN_CENTER | FormString.F_TEXT_BOLD );
			else
				attuneElement( w, NaN, FormString.F_ALIGN_CENTER | FormString.F_EDITABLE );
			return getLastElement() as FormString;
		}
		
		override public function get height():Number
		{
			return 23;
		}
		
		public function kill():void
		{
		}
		public function change(p:Package):void
		{
			put(p);
			remember( getField(p.cmd,1) );
		}
		public function put(p:Package):void
		{
			distribute( p.getStructure(structureID), p.cmd );
		}
		public function putRaw(value:Object):void
		{
		}
		public function extract():Array		
		{
			return [fImsi.getCellInfo(), fOperator.getCellInfo(), fApn.getCellInfo(), fUser.getCellInfo(), fPass.getCellInfo()];	
		}
		public function set selectLine(b:Boolean):void	{		}
		public function isSelected():Boolean
		{
			return false
		}
	}
}