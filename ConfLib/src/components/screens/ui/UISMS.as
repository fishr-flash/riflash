package components.screens.ui
{
	import mx.core.UIComponent;
	
	import components.abstract.functions.loc;
	import components.abstract.servants.CIDServant;
	import components.abstract.servants.ResizeWatcher;
	import components.abstract.servants.TabOperator;
	import components.basement.UI_BaseComponent;
	import components.events.GUIEventDispatcher;
	import components.events.GUIEvents;
	import components.gui.DevConsole;
	import components.gui.Header;
	import components.gui.OptList;
	import components.gui.SimpleTextField;
	import components.gui.triggers.TextButton;
	import components.gui.visual.ScreenBlock;
	import components.gui.visual.Separator;
	import components.interfaces.IFocusable;
	import components.interfaces.IResizeDependant;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.screens.opt.OptSms_Param;
	import components.screens.opt.OptSms_Rctrl;
	import components.screens.opt.OptSms_key;
	import components.screens.opt.OptSms_part;
	import components.screens.opt.OptSms_text;
	import components.screens.opt.OptSms_user;
	import components.screens.opt.OptSms_zone;
	import components.static.CMD;
	import components.static.DS;
	import components.static.PAGE;
	import components.system.SavePerformer;
	import components.system.SysManager;
	
	public final class UISMS extends UI_BaseComponent implements IResizeDependant
	{
		private var p_param:OptSms_Param;
		private var p_breloki:OptList;
		private var p_user:OptList;
		private var p_zone:OptList;
		private var p_key:OptList;
		private var p_part:OptList;
		private var p_text:OptList;
		private var sep:Separator;
		private var text:SimpleTextField;
		private var b_text_default:TextButton;
		
		private var hZone:Header;
		private var hPartition:Header;
		private var hRctrl:Header;
		private var hUser:Header;
		private var hEvents:Header;
		private var hKey:Header;
		
		private var menu_params:int;
		private var menu_part:int;
		private var menu_zone:int;
		private var menu_trinket:int;
		private var menu_user:int;
		private var menu_text:int;
		private var menu_tmkeys:int;
		
		
		public function UISMS()
		{
			super();

			initNavi();
			navi.setUp( openPage );
			navi.width = PAGE.SECONDMENU_WIDTH;
			navi.height = 200;
			var menu:Array;
			if (DS.isK14s)
				menu= [loc("sms_menu_params"),loc("sms_menu_part"),loc("sms_menu_zone"),loc("sms_menu_trinket"),loc("sms_menu_user"),loc("sms_menu_event_text")];
			else
				menu= [loc("sms_menu_params"),loc("sms_menu_part"),loc("sms_menu_zone"),loc("sms_menu_tmkeys"),loc("sms_menu_trinket"),loc("sms_menu_user"),loc("sms_menu_event_text")];
				
			var len:int = menu.length;
			for(var i:int=0; i<len; ++i ) {
				navi.addButton( menu[i],i, i*500 );
				switch( menu[i] ) {
					case loc("sms_menu_params"):
						menu_params = i;
						p_param = new OptSms_Param;
						addChild( p_param );
						p_param.visible = false;
						p_param.x = globalX;//180;
						p_param.y = globalY;
						break;
					case loc("sms_menu_zone"):
						menu_zone = i;
						hZone = new Header( [{label:loc("sms_h_zone_num"),xpos:26, width:100},
							{label:loc("sms_h_zone"), xpos:-21, width:250},
						],{size:11, posRelative:true, align:"center", valign:"top"} );
						hZone.y = 10;
						addChild( hZone );
						hZone.visible = false;
						
						p_zone = new OptList;
						addChild( p_zone );
						p_zone.attune(CMD.SMS_ZONE,0, OptList.PARAM_NO_BLOCK_SAVE | OptList.PARAM_V_SCROLLING_WHEN_NEEEDED );
						p_zone.visible = false;
						p_zone.x = globalX;//170;
						p_zone.y = globalY + 40;
						p_zone.width = 345+95;
						break;
					case loc("sms_menu_tmkeys"):
						menu_tmkeys = i;
						hKey = new Header( [{label:loc("sms_h_tmkey_num"),xpos:26, width:100},
							{label:loc("sms_h_tmkey"), xpos:-21, width:250},
						],{size:11, posRelative:true, align:"center", valign:"top"} );
						hKey.y = 10;
						addChild( hKey );
						hKey.visible = false;
						
						p_key = new OptList;
						addChild( p_key );
						p_key.attune(CMD.SMS_TM,0, OptList.PARAM_NO_BLOCK_SAVE | OptList.PARAM_V_SCROLLING_WHEN_NEEEDED );
						p_key.visible = false;
						p_key.x = globalX;//170;
						p_key.y = globalY + 40;
						p_key.width = 345+95;
						break;
					case loc("sms_menu_part"):
						menu_part = i;
						hPartition = new Header( [{label:loc("sms_h_part_num"),xpos:26, width:100},
							{label:loc("sms_h_part"), xpos:-21, width:250},
						],{size:11, posRelative:true, align:"center", valign:"top"} );
						hPartition.y = 10;
						addChild( hPartition );
						hPartition.visible = false;
						
						p_part = new OptList;
						addChild( p_part );
						p_part.attune(CMD.SMS_PART,0, OptList.PARAM_NO_BLOCK_SAVE | OptList.PARAM_V_SCROLLING_WHEN_NEEEDED );
						p_part.visible = false;
						p_part.x = globalX;//170;
						p_part.y = globalY + 40;
						p_part.width = 345+95;
						break;
					case loc("sms_menu_trinket"):
						menu_trinket = i;
						hRctrl = new Header( [{label:loc("sms_h_trinket_num"),xpos:26, width:100},
							{label:loc("sms_h_trinket"), xpos:-21, width:250},
						],{size:11, posRelative:true, align:"center", valign:"top"} );
						hRctrl.y = 10;
						addChild( hRctrl );
						hRctrl.visible = false;
						
						p_breloki = new OptList;
						addChild( p_breloki );
						p_breloki.attune(CMD.SMS_R_CTRL,0, OptList.PARAM_NO_BLOCK_SAVE | OptList.PARAM_V_SCROLLING_WHEN_NEEEDED );
						p_breloki.visible = false;
						p_breloki.x = globalX;//170;
						p_breloki.y = globalY + 40;
						p_breloki.width = 345+95;
						break;
					case loc("sms_menu_user"):
						menu_user = i;
						hUser = new Header( [{label:loc("sms_h_user_num"),xpos:26, width:100},
							{label:loc("sms_h_user"), xpos:-21, width:250},
						],{size:11, posRelative:true, align:"center", valign:"top"} );
						hUser.y = 10;
						addChild( hUser );
						hUser.visible = false;
						
						p_user = new OptList;
						addChild( p_user );
						p_user.attune(CMD.SMS_USER,0, OptList.PARAM_NO_BLOCK_SAVE | OptList.PARAM_V_SCROLLING_WHEN_NEEEDED );
						p_user.visible = false;
						p_user.x = globalX;//170;
						p_user.y = globalY + 40;
						p_user.width = 345+95;
						break;
					case loc("sms_menu_event_text"):
						menu_text = i;
						hEvents = new Header( [{label:loc("sms_h_event_num"),xpos:104-14-40, width:300},
							{label:loc("sms_h_event"), xpos:121+14-170+40, width:300},
						],{size:11, posRelative:true, align:"center", valign:"top"} );
						hEvents.y = 10;
						addChild( hEvents );
						hEvents.visible = false;
						
						p_text = new OptList;
						addChild( p_text );
						p_text.attune(CMD.SMS_TEXT,0, OptList.PARAM_NO_BLOCK_SAVE | OptList.PARAM_V_SCROLLING_WHEN_NEEEDED );
						p_text.visible = false;
						p_text.x = globalX;//170;
						p_text.y = globalY + 40;
						p_text.width = 645;
						
						/*
						b_text_default = new TextButton
						addChild( b_text_default );
						b_text_default.setUp( loc("sms_h_event_defaults"), resetToDefaults );
						b_text_default.x = globalX+20;//190;
						b_text_default.y = globalY;*/
			//			b_text_default.visible = false;
						break;
				}
			}
			
			b_text_default = new TextButton
			addChild( b_text_default );
			b_text_default.setUp( loc("sms_h_event_defaults"), resetToDefaults );
			b_text_default.x = globalX+20;//190;
			b_text_default.y = globalY;
			b_text_default.visible = false;
			
			sep = new Separator;
			addChild( sep );
			sep.x = 10;
			sep.visible = false;
			
			text = new SimpleTextField("",450);
			addChild( text );
			text.setSimpleFormat("center");
			text.height = 60;
			text.x = 30;
			text.visible = false;
		}
		
		override public function open():void
		{
			super.open();
			loadComplete();
			ResizeWatcher.addDependent(this);
			b_text_default.visible = false;
		}
		override public function close():void
		{
			if( !this.visible ) return;
			SysManager.clearFocus(stage);
			super.close();
			p_breloki.close();
			ResizeWatcher.removeDependent(this);
			callVisualizer(null);
			navi.selection = -1;
		}
		public function localResize(w:int, h:int, real:Boolean=false):void
		{
			var pos:int = h - 100;
			if(p_breloki.visible)
				p_breloki.height = pos- 30;
			if(p_key && p_key.visible)
				p_key.height = pos- 30;
			if(p_user.visible)
				p_user.height = pos- 30;
			if(p_part.visible) {
				if( pos > 486 )
					pos = 486;
				p_part.height =  pos - 30;
			}
			if(p_zone.visible)
				p_zone.height = pos- 30;
			if(p_text.visible) {
				p_text.height = pos-30;
			}
			b_text_default.y = pos - 20;
			sep.y =  pos+20;
			text.y = pos+40;
		}
		private function openPage( num:Object ):void
		{
			SysManager.clearFocus(stage);
			SavePerformer.closePage();
			lock(true);
			callVisualizer(null);
			b_text_default.setName( loc("sms_h_value_defaults") );
			b_text_default.setId( int(num) );
			switch(num)	{
				case menu_params:
					RequestAssembler.getInstance().fireEvent( new Request( CMD.SMS_PARAM, selectPage ));
					break;
				case menu_part:
					RequestAssembler.getInstance().fireEvent( new Request( CMD.SMS_PART, selectPage ));
					break;
				case menu_zone:
					RequestAssembler.getInstance().fireEvent( new Request( CMD.SMS_ZONE, selectPage ));
					break;
				case menu_tmkeys:
					RequestAssembler.getInstance().fireEvent( new Request( CMD.SMS_TM, selectPage ));
					break;
				case menu_trinket:
					RequestAssembler.getInstance().fireEvent( new Request( CMD.SMS_R_CTRL, selectPage ));
					break;
				case menu_user:
					RequestAssembler.getInstance().fireEvent( new Request( CMD.SMS_USER, selectPage ));
					break;
				case menu_text:
					RequestAssembler.getInstance().fireReadSequence( CMD.SMS_TEXT, selectPage, CIDServant.getEvent().length-1 );
					b_text_default.setName( loc("sms_h_event_defaults") );
					//RequestAssembler.getInstance().fireEvent( new Request( CMD.SMS_TEXT, selectPage ));
					break;
			}
		}
		private function selectPage(p:Package):void
		{
			var f:IFocusable;
			switch(p.cmd)	{
				case CMD.SMS_PARAM:
					p_param.putRawData( p.getStructure() );
					callVisualizer(p_param);
					this.width = 665;
					this.height = 235;
					f = navi.getButtonById(menu_params);
					break;
				case CMD.SMS_ZONE:
					p_zone.put( Package.create( p.data.slice() ), OptSms_zone );
					text.text = loc("sms_change_zone");
					callVisualizer(p_zone);
					this.width = 530;
					f = navi.getButtonById(menu_zone);
					break;
				case CMD.SMS_PART:
					p_part.put( Package.create( p.data.slice() ), OptSms_part );
					text.text = loc("sms_change_part");
					callVisualizer(p_part);
					this.width = 530;
					f = navi.getButtonById(menu_part);
					break;
				case CMD.SMS_R_CTRL:
					p_breloki.put( Package.create( p.data.slice() ), OptSms_Rctrl );
					text.text = loc("sms_change_trinket");
					callVisualizer(p_breloki);
					this.width = 530;
					f = navi.getButtonById(menu_trinket);
					break;
				case CMD.SMS_USER:
					p_user.put( Package.create( p.data.slice() ), OptSms_user );
					text.text = loc("sms_change_user");
					callVisualizer(p_user);
					this.width = 530;
					f = navi.getButtonById(menu_user);
					break;
				case CMD.SMS_TEXT:
					
					p_text.put( Package.create( p.data.slice(0, CIDServant.getEvent().length-1 ) ), OptSms_text );
					text.text = loc("sms_change_event");
					callVisualizer(p_text);
					this.width = 700;
					f = navi.getButtonById(menu_text);
					break;
				case CMD.SMS_TM:
					p_key.put( Package.create( p.data.slice() ), OptSms_key );
					text.text = loc("sms_change_key");
					callVisualizer(p_key);
					this.width = 530;
					f = navi.getButtonById(menu_tmkeys);
					break;
			}
			TabOperator.getInst().restoreFocus(f);
			lock(false);
			localResize(ResizeWatcher.lastWidth,ResizeWatcher.lastHeight);
		}
		private function callVisualizer(obj:UIComponent):void
		{
			p_param.visible = Boolean(p_param == obj);
			p_breloki.visible = Boolean(p_breloki == obj);
			hRctrl.visible = Boolean(p_breloki == obj);
			
			p_user.visible = Boolean(p_user == obj);
			hUser.visible = Boolean(p_user == obj);
			
			p_zone.visible = Boolean(p_zone == obj);
			hZone.visible = Boolean(p_zone == obj);
			
			p_part.visible = Boolean(p_part == obj);
			hPartition.visible = Boolean(p_part == obj);
			
			p_text.visible = Boolean(p_text == obj);
			hEvents.visible = Boolean(p_text == obj);
			
			if (p_key) {
				p_key.visible = Boolean(p_key == obj);
				hKey.visible = Boolean(p_key == obj);
			}
			
			sep.visible = 	!p_param.visible && obj;
			text.visible =	!p_param.visible && obj;
			b_text_default.visible = p_breloki.visible || p_user.visible || p_zone.visible || p_part.visible || p_text.visible || (p_key && p_key.visible);
		}
		private function reset():void
		{
			var arr:Array = new Array;
			for( var i:int=0; i<256; ++i ) {
				arr.push(-1);
			}
			p_text.callEach(arr);
		}
		private function resetToDefaults(num:int):void
		{
			switch(num)	{
				case menu_part:
					p_part.callEach();
					break;
				case menu_zone:
					p_zone.callEach();
					break;
				case menu_tmkeys:
					p_key.callEach();
					break;
				case menu_trinket:
					p_breloki.callEach();
					break;
				case menu_user:
					p_user.callEach();
					break;
				case menu_text:
					var cid:Array = CIDServant.getEvent();
					var arr:Array = new Array;
					var l:int = cid.length;
					for( var i:int=0; i<l; ++i ) {
						if( cid[i+1] )				
							arr.push( int("0x"+cid[i+1].data) );
					}
					p_text.callEach(arr);
					break;
			}
		}
		private function lock(b:Boolean):void
		{
			if (b) {
				GUIEventDispatcher.getInstance().fireEvent( GUIEvents, GUIEvents.onNeedScreenBlock, 
					{getScreenMode:ScreenBlock.MODE_LOADING, getScreenMsg:""} );
				blockNavi = true;
				navi.focusable = false;
			} else {
				GUIEventDispatcher.getInstance().fireEvent( GUIEvents, GUIEvents.onNeedScreenBlock, null );
				blockNavi = false;
				navi.focusable = true;
			}
		}
	}
}