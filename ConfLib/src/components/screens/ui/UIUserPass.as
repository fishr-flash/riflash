package components.screens.ui
{
	import components.abstract.functions.loc;
	import components.abstract.servants.ResizeWatcher;
	import components.basement.UI_BaseComponent;
	import components.events.GUIEvents;
	import components.gui.OptList;
	import components.gui.SimpleTextField;
	import components.gui.fields.FSComboBox;
	import components.gui.fields.FSSimple;
	import components.gui.fields.FormEmpty;
	import components.interfaces.IResizeDependant;
	import components.protocol.Package;
	import components.screens.opt.OptUserPass;
	import components.static.CMD;
	import components.system.UTIL;
	
	public class UIUserPass extends UI_BaseComponent implements IResizeDependant
	{
		private var tPass:SimpleTextField;
		
		private var tUserCode:SimpleTextField;
		private var tUserPass:SimpleTextField;
		private var tPartition:SimpleTextField;
		private var tForceUse:SimpleTextField;
		
		public function UIUserPass()
		{
			super();
			globalY = 20;
			globalX = 10;
			structureID = 1;
			
			var form:FormEmpty = createUIElement( new FSSimple, CMD.MASTER_CODE, loc("g_mastercode"),null,1,null,"0-9",4, new RegExp("^(\\d\\d\\d\\d)$"));
			form.x = globalX;
			attuneElement( 120, 60 );
			
			tPass = new SimpleTextField( loc("ui_user_mastercode"), 300 );
			addChild( tPass );
			tPass.y = form.y-5;
			tPass.x = 220;
			
		//	globalY += 10;
			
			drawSeparator();
			 
			var aList:Array = [{label:loc("ui_user_noblock"), data:"00:00"},{label:"00:30", data:"00:30"},
				{label:"01:00", data:"01:00"},{label:"05:00", data:"05:00"},{label:"10:00", data:"10:00"}]
			
			createUIElement( new FSComboBox, CMD.KEY_BLOCK, loc("ui_user_block_key_incorrect"),null,1,
				aList,"",0,new RegExp("^(((\\d|0[0-9]):(\\d|[0-5]\\d))|10:00|"+loc("ui_user_noblock")+")$")).x = globalX;
			attuneElement( 360, 140, FSComboBox.F_COMBOBOX_TIME );
			
			drawSeparator();
			
			tUserCode = new SimpleTextField( loc("ui_user_num"), 100 );
			addChild( tUserCode );
			tUserCode.setSimpleFormat("center",-7,12,true);
			tUserCode.y = globalY + 10;
			tUserCode.x = 10;
			
			tPass = new SimpleTextField( loc("ui_user_code"), 110 );
			addChild( tPass );
			tPass.setSimpleFormat("center",-7,12,true);
			tPass.y = globalY + 10;
			tPass.x = 125;
			
			tPartition = new SimpleTextField( loc("ui_user_part"), 100 );
			addChild( tPartition );
			tPartition.setSimpleFormat("center",-7,12,true);
			tPartition.y = globalY + 15;
			tPartition.x = 250;
			
			tForceUse = new SimpleTextField( loc("ui_user_under_pressure"), 140 );
			addChild( tForceUse );
			tForceUse.setSimpleFormat("center",-7,12,true);
			tForceUse.y = globalY + 10;
			tForceUse.x = 365;
			
			aItems = new Array;
			
			list = new OptList;
			list.attune(CMD.USER_PASS,1,OptList.PARAM_ENABLER_IS_SWITCH | OptList.PARAM_NEED_ADDITIONAL_EVENTS | OptList.PARAM_ATLEAST_ONE_LINE | OptList.PARAM_V_SCROLLING_WHEN_NEEEDED,{uniqueParams:[{param:2, gen:OptList.GENERATION_RANDOM}]} );
			list.addEventListener( GUIEvents.onEventFiredSuccess, onListResize );
			
			addChild( list );
			list.y = globalY + tForceUse.getHeight() + 10;
			
			starterCMD = [CMD.MASTER_CODE, CMD.KEY_BLOCK, CMD.USER_PASS];
			height = 290;
		}
		override public function open():void
		{
			super.open();
			ResizeWatcher.addDependent(this);
		}
		override public function close():void
		{
			if( !this.visible ) return;
			
			super.close();
			list.close();
			ResizeWatcher.removeDependent(this);
		}
		public function localResize(w:int, h:int, real:Boolean=false):void
		{
			var realH:int = list.getActualHeight()+10;
			var preferredH:int = h - 210;
			list.height = realH > preferredH ? preferredH : realH;   
		}
		override public function put( p:Package ):void
		{
			switch( p.cmd ){
				case CMD.MASTER_CODE:
					getField(CMD.MASTER_CODE,1).setCellInfo( UTIL.formateZerosInFront(String( p.getStructure()[0] ),4) );
					break;
				case CMD.KEY_BLOCK:
					
					var value:String;
					value = UTIL.formateZerosInFront( (p.getStructure()[0]).toString(), 2)+":"+ UTIL.formateZerosInFront( (p.getStructure()[1]).toString(), 2 );
					var cb:FSComboBox = getField(CMD.KEY_BLOCK,1) as FSComboBox;
					
					cb.setCellInfo( value );
					break;
				case CMD.USER_PASS:
					var pack:Package = new Package;
					list.put( p, OptUserPass );
					ResizeWatcher.doResizeMe(this);
					loadComplete();
					break;
			}
		}
		private function onListResize(e:GUIEvents):void
		{
			ResizeWatcher.doResizeMe(this);
		}
	}
}
// 416 строк до рефакторинга