package components.screens.page
{
	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	
	import components.abstract.functions.loc;
	import components.basement.OptionsBlock;
	import components.gui.Balloon;
	import components.gui.fields.FSButton;
	import components.protocol.Package;
	import components.screens.ui.UIVersion;
	import components.static.CMD;
	
	public class VersionRitmLink extends OptionsBlock
	{
		public function VersionRitmLink()
		{
			super();
			
			addui( new FSButton, CMD.RITM_LINK_ID, loc("ritm_link"), onClick, 1 );
			attuneElement( UIVersion.shift );
			
			complexHeight = globalY-7;
		}
		override public function putData(p:Package):void
		{
			pdistribute(p);
		}
		private function onClick():void
		{
			var s:String = String(getField(CMD.RITM_LINK_ID,1).getCellInfo());
			if (s is String && s.length > 0) {
				Clipboard.generalClipboard.clear();
				var result:Boolean = Clipboard.generalClipboard.setData(ClipboardFormats.TEXT_FORMAT, s);
				
				if (result)
					Balloon.access().shownote( loc("ritm_link") + " "+ loc("options_in_buffer") );
				else
					Balloon.access().shownote( loc("sys_error_happens") );
			}
		}
	}
}