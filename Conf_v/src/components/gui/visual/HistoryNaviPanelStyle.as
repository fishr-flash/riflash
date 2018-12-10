package components.gui.visual
{
	import flash.display.InteractiveObject;
	
	import mx.core.UIComponent;
	
	import components.abstract.functions.loc;
	import components.abstract.servants.TabOperator;
	import components.events.GUIEventDispatcher;
	import components.events.GUIEvents;
	import components.gui.fields.FormString;
	import components.gui.triggers.MButton;
	import components.interfaces.IFocusable;
	import components.protocol.statics.CLIENT;
	
	public class HistoryNaviPanelStyle extends UIComponent
	{
		public var totallines:int;
		
		private const BUTTON_PAGE_PREV:int = 1;
		private const BUTTON_PAGE_NEXT:int = 2;
		private const BUTTON_DECADE_NEXT:int = 3;
		private const BUTTON_DECADE_PREV:int = 4;
		private const BUTTON_PAGE_JUMP:int = 5;
		private const BUTTON_PAGE_REFRESH:int = 6;
		private const C_MAX_BUTTONS_VISIBLE:int = 10;
		
		private var page_line_buttons:Vector.<MButton>;
		private var page_b_prev:MButton;
		private var page_decade_b_prev:MButton;
		private var page_b_next:MButton;
		private var page_decade_b_next:MButton;
		private var page_b_jump:MButton;
		private var page_b_refresh:MButton;
		private var page_jump_total:FormString;
		private var page_jump_input:FormString;
		
		public var page_current:int = 1;
		
		public function HistoryNaviPanelStyle()
		{
			super();
			
			page_line_buttons = new Vector.<MButton>;
			
			page_decade_b_prev = new MButton( "<<",switchPage, BUTTON_DECADE_PREV );
			addButton( page_decade_b_prev );
			page_decade_b_prev.disabled = true;
		//	page_decade_b_prev.width = 22;
			page_decade_b_prev.focusorder = 1;
			
			page_b_prev = new MButton( "<",switchPage, BUTTON_PAGE_PREV ); 
			addButton( page_b_prev );
			page_b_prev.x = page_decade_b_prev.width;
			page_b_prev.disabled = true;
			page_b_prev.focusorder = 2;
			
			page_b_next = new MButton( ">",switchPage, BUTTON_PAGE_NEXT );
			addButton( page_b_next );
			page_b_next.focusorder = 13
			
			page_decade_b_next = new MButton( ">>",switchPage, BUTTON_DECADE_NEXT );
			addButton( page_decade_b_next );
		//	page_decade_b_next.width = 22;
			page_decade_b_next.focusorder = 14;
			
			page_jump_input = new FormString;
			addButton( page_jump_input );
			page_jump_input.restrict("0-9",5);
			page_jump_input.attune( FormString.F_EDITABLE | FormString.F_ALIGN_CENTER | FormString.F_OFF_KEYBOARD_REACTIONS);
			page_jump_input.setWidth( 45 );
			page_jump_input.setCellInfo(1);
			page_jump_input.focusorder = 15;
			
			page_jump_total = new FormString;
			addButton( page_jump_total );
			page_jump_total.setWidth( 70 );
			page_jump_total.attune( FormString.F_NOTSELECTABLE );
			page_jump_total.focusorder = 16;
			
			page_b_jump = new MButton( loc("his_jump"),switchPage, BUTTON_PAGE_JUMP );
			addButton( page_b_jump );
			page_b_jump.focusorder = 17;
			
			page_b_refresh = new MButton( loc("g_refresh_page"),switchPage, BUTTON_PAGE_REFRESH );
			addButton( page_b_refresh );
			page_b_refresh.focusorder = 18;
		}
		public function update(tl:int):void
		{
			totallines = tl;
			var cycles:int = Math.ceil(totallines/CLIENT.HISTORY_LINES_PER_PAGE);
			var but:MButton;
			var i:int;
			
			page_jump_total.setName( loc("g_loaded_from_bytes")+" "+cycles );
			
			if(page_line_buttons.length>0) {
				var len_buttons:int = page_line_buttons.length; 
				for(i=0; i<len_buttons; ++i ) {
					if(page_line_buttons[i] != null) {
						removeChild( page_line_buttons[i] );
						page_line_buttons[i] = null;
					}
				}
				page_line_buttons.length = 0;
			}
			
			var lastx:int = page_b_prev.x + page_b_prev.width + 5;
			var existcounter:int=0;
			for(i=0; i<cycles; ++i ) {
				
				var currentDecade:int = Math.floor((page_current-1)/10)*C_MAX_BUTTONS_VISIBLE;
				
				if( i < currentDecade || i > currentDecade + C_MAX_BUTTONS_VISIBLE - 1 ) {
					page_line_buttons.push( null );
					continue;
				}
				but = new MButton( String(int(i+1)),selectPage, i+1 );
				addButton( but );
				//	but.width = 7;
				but.x = lastx;
				lastx += but.width;
				page_line_buttons[i] = but;
				but.focusorder = 3 + existcounter++;
				but.pressed = Boolean( but.id == page_current );
			}
			var but_len:int;
			if( page_line_buttons.length > C_MAX_BUTTONS_VISIBLE )
				but_len = C_MAX_BUTTONS_VISIBLE;
			else
				but_len = page_line_buttons.length;
			
			page_b_next.x = lastx + 5;
			page_decade_b_next.x = page_b_next.x + page_b_next.width;
			page_b_jump.x = page_decade_b_next.width + page_decade_b_next.x + 20;
			page_jump_input.x = page_b_jump.width + page_b_jump.x + 5;
			page_jump_total.x = page_jump_input.getWidth() + page_jump_input.x + 10;
			page_b_refresh.x = page_jump_total.getWidth() + page_jump_total.x + 10; 
			if (page_b_refresh.x < 555)
				page_b_refresh.x = 555;
			
			page_b_next.disabled = page_current + 1 > page_line_buttons.length; 
			page_decade_b_next.disabled = page_current + 10 > page_line_buttons.length;
			
			page_jump_input.disabled = page_line_buttons.length == 0;
			page_jump_total.disabled = page_line_buttons.length == 0;
			page_b_jump.disabled = page_line_buttons.length == 0;
		}
		private function addButton(f:IFocusable):void
		{
			addChild(f as InteractiveObject);
			TabOperator.getInst().add(f);
			f.focusgroup = TabOperator.GROUP_TABLE;
		}
		private function switchPage(num:int):void
		{
			switch(num) {
				case BUTTON_PAGE_NEXT:
					page_current++;
					break;
				case BUTTON_PAGE_PREV:
					page_current--;
					break;
				case BUTTON_DECADE_NEXT:
					if(page_current+10 <= page_line_buttons.length)
						page_current += 10;
					break;
				case BUTTON_DECADE_PREV:
					if(page_current-10 > 0 )
						page_current -= 10;
					break;
				case BUTTON_PAGE_JUMP:
					var page:int = int(page_jump_input.getCellInfo());
					if( page > 0 && page <= page_line_buttons.length ) 
						page_current = page;
					else
						return;
					break;
				case BUTTON_PAGE_REFRESH:
					if( page_current > page_line_buttons.length )
						page_current = page_line_buttons.length;
					if (page_current < 1)
						page_current = 1;
					break;
			}
			page_b_next.disabled = page_current + 1 > page_line_buttons.length; 
			page_b_prev.disabled = page_current - 1 < 1;
			page_decade_b_next.disabled = page_current+10 > page_line_buttons.length;
			page_decade_b_prev.disabled = page_current-10 < 1;
			selectPage(page_current);
		}
		public function selectPage(num:int):void
		{
			page_current = num;
			page_jump_input.setCellInfo(num);
			GUIEventDispatcher.getInstance().fireEvent( GUIEvents, GUIEvents.onNeedPage, {"getData":num});
		}
	}
}