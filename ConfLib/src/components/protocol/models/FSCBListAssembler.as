package components.protocol.models
{
	import components.abstract.functions.loc;
	import components.gui.fields.FSComboCheckBox;

	public class FSCBListAssembler
	{
		public function FSCBListAssembler()
		{
		}
		public static const ALL:int = 0xFFFF;
		public static function getList(a:Array, all:int=0):Array
		{
			var list:Array = [];
			var len:int = a.length;
			var separatorInserted:Boolean=false;
			list.push( {"label":loc("g_all_pages"), "data":all, "trigger": FSComboCheckBox.TRIGGER_SELECT_ALL, "senddata":ALL } );
			list.push( {"label":"-", "data":2, "trigger": FSComboCheckBox.TRIGGER_I_SEPERATOR } );
			
			var lab:String; 
			
			for (var i:int=0; i<len; ++i) {
				if (a[i].cmds) {
					
					lab = a[i].altLabel is String ? a[i].altLabel : a[i].label; 
					if( a[i].bottom == true ) {
						// если подключено два прибора по разным адресам - надо вставлять разделитель
						if (!separatorInserted) {
							list.splice(2,0, {"label":"-", "data":2, "trigger": FSComboCheckBox.TRIGGER_I_SEPERATOR } );
							separatorInserted = true;
						}
						list.splice(2,0,{"label":lab + (a[i].incomplete ? " ("+loc("g_page_uncomplete")+")":""), "data": !a[i].disabled ? all : 0 , "labeldata":a[i].data, "disabled":a[i].disabled} );
					} else
						list.push( {"label":lab + getIncomplete(), "data": !a[i].disabled ? all : 0 , "labeldata":a[i].data, "disabled":a[i].disabled} );
				}
			}
			return list;
			function getIncomplete():String
			{
				var s:String = a[i].incomplete ? " ("+loc("g_page_uncomplete")+")":"";
				return s;
			}
		}
	}
}