package components.screens.ui
{
	import flash.events.Event;
	
	import mx.events.ResizeEvent;
	
	import components.abstract.ClientArrays;
	import components.abstract.GroupOperator;
	import components.abstract.VoyagerBot;
	import components.abstract.functions.loc;
	import components.abstract.servants.TabOperator;
	import components.abstract.servants.TaskManager;
	import components.basement.UI_BaseComponent;
	import components.gui.fields.FSComboBox;
	import components.gui.fields.FSRadioStandAlone;
	import components.gui.fields.FSShadow;
	import components.gui.fields.FormString;
	import components.gui.visual.Separator;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.resources.EnergyModeString;
	import components.screens.opt.OptModeCustom;
	import components.screens.opt.OptModeRoot;
	import components.static.CMD;
	import components.static.PAGE;
	import components.system.Controller;
	import components.system.SavePerformer;
	import components.system.UTIL;
	
	public class UIEnergyModeV2 extends UI_BaseComponent
	{
		private var STARTING:Boolean = false;
		private const G3Y:int = 236+10;
		private const G4Y:int = 349+10;
		private const G5Y:int = 462+10;
		private const G6Y:int = 562+10;
		
		private var rb1:FSRadioStandAlone;
		private var rb2:FSRadioStandAlone;
		private var rb3:FSRadioStandAlone;
		private var rb4:FSRadioStandAlone;
		
		private var opts:Vector.<OptModeRoot>;
		
		private var groups:GroupOperator;
		private var assemblege:Array;
		private var _selected:int;
		
		private var cbTimeZone:FSComboBox;
		private var BLOCK_SAVE:Boolean=false;
		
		public function UIEnergyModeV2()
		{
			super();
			
			opts = new Vector.<OptModeRoot>(9);
			
			//EnergyModeString.getHeader(1);
			
			structureID = 1;
			
			globalX = PAGE.CONTENT_LEFT_SHIFT;
			globalY = PAGE.CONTENT_TOP_SHIFT+10;
			
			groups = new GroupOperator;
			var textwid:int = 1050;
			
			FLAG_SAVABLE = false;
			
			rb1 = new FSRadioStandAlone;
			addChild( rb1 );
			rb1.attune( FSRadioStandAlone.F_HTML_TEXT );
			rb1.setName( UTIL.wrapHtml( EnergyModeString.getHeader(1) ) );
			rb1.y = globalY;
			rb1.x = globalX;
			rb1.tf.width = textwid;
			//rb1.tf.setSimpleFormat("left", 0,12);
			rb1.setUp( groupSelect, 1 );
			
			globalY += 30;
			
			createUIElement( new FormString, 0, "", null, 1);
			attuneElement( textwid,NaN,FormString.F_MULTYLINE | FormString.F_HTML_TEXT);
			getLastElement().setCellInfo( EnergyModeString.getText(1) );
			
			globalY += 10;
			drawSeparator();
			globalY += 10;
			
			rb2 = new FSRadioStandAlone;
			addChild( rb2 );
			rb2.attune( FSRadioStandAlone.F_HTML_TEXT );
			rb2.setName( UTIL.wrapHtml( EnergyModeString.getHeader(2) ) );
			rb2.y = globalY;
			rb2.x = globalX;
			rb2.tf.width = textwid;
			//rb2.tf.setSimpleFormat("left", 0,12,true);
			rb2.setUp( groupSelect, 3 );
			
			globalY += 30;
			
			createUIElement( new FormString, 0, "", null, 2);
			attuneElement( textwid,NaN,FormString.F_MULTYLINE | FormString.F_HTML_TEXT );
			getLastElement().setCellInfo( EnergyModeString.getText(2) );
			
			globalY += 10;
			var sep:Separator = drawSeparator();
			globalY += 10;
			
			
			rb3 = new FSRadioStandAlone;
			addChild( rb3 );
			rb3.attune( FSRadioStandAlone.F_HTML_TEXT );
			rb3.setName( UTIL.wrapHtml( EnergyModeString.getHeader(3) ) );
			rb3.y = globalY;
			rb3.x = globalX;
			rb3.tf.width = textwid;
			//rb3.tf.setSimpleFormat("left", 0,12,true);
			rb3.setUp( groupSelect, 5 );
			rb3.focusgroup = 500;
			
			globalY += 30;
			
			createUIElement( new FormString, 0, "", null, 2);
			attuneElement( textwid,NaN,FormString.F_MULTYLINE | FormString.F_HTML_TEXT );
			getLastElement().setCellInfo( EnergyModeString.getText(3) );
			
			groups.add("3", [rb3, getLastElement(), sep] );
			
			globalY += 10;
			sep = drawSeparator();
			globalY += 10;
			
			
			rb4 = new FSRadioStandAlone;
			addChild( rb4 );
			rb4.attune( FSRadioStandAlone.F_HTML_TEXT );
			rb4.setName( UTIL.wrapHtml(	EnergyModeString.getHeader(4) ) );
			rb4.y = globalY;
			rb4.x = globalX;
			rb4.tf.width = textwid;
			//rb4.tf.setSimpleFormat("left", 0,12,true);
			rb4.setUp( groupSelect, 7 );
			rb4.focusgroup = 700;
			
			globalY += 30;
			
			createUIElement( new FormString, 0, "", null, 2);
			attuneElement( textwid,NaN,FormString.F_MULTYLINE | FormString.F_HTML_TEXT );
			getLastElement().setCellInfo( EnergyModeString.getText(4) );
			
			groups.add("4", [rb4, getLastElement(), sep] );
		/*	
			globalY += 10;
			sep = drawSeparator();
			globalY += 10;
			
			createUIElement( new FormString, 0, "", null, 2);
			attuneElement( textwid,NaN,FormString.F_MULTYLINE | FormString.F_HTML_TEXT );
			getLastElement().setCellInfo( EnergyModeString.getText(6) );
			*/
			cbTimeZone = new FSComboBox;
			cbTimeZone.debugnum = 10;
			cbTimeZone.setName( loc("vem_shed_timezone") );
			addChild( cbTimeZone );
			cbTimeZone.setUp( onTimeZone );
			cbTimeZone.setList( ClientArrays.aTimeZones );
			cbTimeZone.setWidth( 250 );
			cbTimeZone.setCellWidth( 300 );
			cbTimeZone.attune( FSComboBox.F_COMBOBOX_NOTEDITABLE );
			cbTimeZone.x = globalX;
			cbTimeZone.focusgroup = TabOperator.GROUP_LAST;
			cbTimeZone.disabled = true;
			//createUIElement( new FSComboBox, 0, "Часовой пояс для расписания", onTimeZone, 5, ClientArrays.aTimeZones ) as FSComboBox;
			//			attuneElement( 200, 300, FSComboBox.F_COMBOBOX_NOTEDITABLE );
			
			globalY += 20;
			FLAG_SAVABLE = true;
			
			createUIElement( new FSShadow, CMD.VR_WORKMODE_CURRENT, "", null, 1 );
			createUIElement( new FSShadow, CMD.VR_WORKMODE_CURRENT, "", null, 2 );
			
			opts[1] = new OptModeRoot(1);
			opts[2] = new OptModeRoot(2);
			
			opts[3] = new OptModeRoot(3);
			opts[4] = new OptModeRoot(4);
			
			opts[5] = new OptModeRoot(5);
			opts[6] = new OptModeRoot(6);
			opts[6].x = globalX;
			opts[6].y = 310+10;
			
			opts[7] = new OptModeCustom(7);
			opts[8] = new OptModeCustom(8);
			opts[7].addEventListener( Event.CHANGE, onChange );
			opts[8].addEventListener( Event.CHANGE, onChange );
			addChild( opts[8] );
			opts[8].x = globalX + 370;
			opts[8].y = globalY-9;
			addChild( opts[7] );
			opts[7].x = globalX;
			opts[7].y = globalY-9;
			
			cbTimeZone.y = opts[7].y + opts[7].getHeight() + 20;
			
			this.width  = 1080;
		}
		override public function open():void
		{
			super.open();
			
			VoyagerBot.TIME_ZONE = (new Date).timezoneOffset/60*-1;
			SavePerformer.trigger( {"cmd":refine} );
			cbTimeZone.setCellInfo(VoyagerBot.TIME_ZONE);
			
			STARTING = true;
			RequestAssembler.getInstance().fireEvent( new Request(CMD.VR_WORKMODE_CURRENT, put));
			RequestAssembler.getInstance().fireEvent( new Request(CMD.VR_WORKMODE_SET, put));
			RequestAssembler.getInstance().fireEvent( new Request(CMD.VR_WORKMODE_ENGINE_START, put));
			RequestAssembler.getInstance().fireEvent( new Request(CMD.VR_WORKMODE_ENGINE_RUNS, put));
			RequestAssembler.getInstance().fireEvent( new Request(CMD.VR_WORKMODE_ENGINE_STOP, put));
			RequestAssembler.getInstance().fireEvent( new Request(CMD.VR_WORKMODE_START, put));
			RequestAssembler.getInstance().fireEvent( new Request(CMD.VR_WORKMODE_MOVE, put));
			RequestAssembler.getInstance().fireEvent( new Request(CMD.VR_WORKMODE_STOP, put));
			RequestAssembler.getInstance().fireEvent( new Request(CMD.VR_WORKMODE_PARK, put));
			RequestAssembler.getInstance().fireEvent( new Request(CMD.VR_WORKMODE_REGULAR, put));
			RequestAssembler.getInstance().fireEvent( new Request(CMD.VR_WORKMODE_SCHEDULE, put));
		}
		override public function put(p:Package):void
		{
			switch(p.cmd) {
				case CMD.VR_WORKMODE_CURRENT:
					assemblege = new Array;
					if (p.getStructure()[0] == 0) {
						groupSelect( 1 );
						RequestAssembler.getInstance().fireEvent( new Request(CMD.VR_WORKMODE_CURRENT, null, 1, [1,2]) );
						assemblege[p.cmd] = p.getStructure( 1 );
					} else {
						groupSelect( p.getStructure()[0] );
						assemblege[p.cmd] = p.getStructure();
					}
					if (p.getStructure()[0]+1 != p.getStructure()[1])
						RequestAssembler.getInstance().fireEvent( new Request(CMD.VR_WORKMODE_CURRENT, null, 1, [p.getStructure()[0],p.getStructure()[0]+1 ]) );
					break;
				case CMD.VR_WORKMODE_SET:
				case CMD.VR_WORKMODE_ENGINE_START:
				case CMD.VR_WORKMODE_ENGINE_RUNS:
				case CMD.VR_WORKMODE_ENGINE_STOP:
				case CMD.VR_WORKMODE_START:
				case CMD.VR_WORKMODE_MOVE:
				case CMD.VR_WORKMODE_STOP:
				case CMD.VR_WORKMODE_PARK:
				case CMD.VR_WORKMODE_EVENT:
				case CMD.VR_WORKMODE_REGULAR:
					assemblege[p.cmd] = p.data;
					break;
				case CMD.VR_WORKMODE_SCHEDULE:
					assemblege[p.cmd] = p.data;
					
					var len:int = opts.length;
					for (var i:int=0; i<len; ++i) {
						if (opts[i])
							opts[i].putAssemblege(assemblege);
					}
					
					loadComplete();
					STARTING = false;
					
					if (BLOCK_SAVE) {
						TaskManager.callLater(Controller.getInstance().saveButtonActive, 150, [false]);
						BLOCK_SAVE = false;
					}
					break;
			}
		}
		private function groupSelect(n:int):void
		{
			if (assemblege.length>0) {
				var len:int = opts.length;
				for (var i:int=0; i<len; ++i) {
					if (opts[i])
						opts[i].putAssemblege(assemblege);
				}
			}
			
			opts[6].visible = n == 5;
			opts[7].visible = n == 7;
			opts[8].visible = n == 7;
			cbTimeZone.visible = n == 7;
			
			rb1.selected = false;
			rb2.selected = false;
			rb3.selected = false;
			rb4.selected = false;
			
			this.height = 470;
			this.width = 1080;
			
			switch(n) {
				case 1:
					rb1.selected = true;
					groups.movey( "3", G3Y );
					groups.movey( "4", G4Y );
					
					break;
				case 3:
					rb2.selected = true;
					groups.movey( "3", G3Y );
					groups.movey( "4", G4Y );
					break;
				case 5:
					//this.height = 490;
					rb3.selected = true;
					groups.movey( "3", G3Y );
					groups.movey( "4", G4Y );
					break;
				case 7:
					rb4.selected = true;
					this.height = globalY + opts[7].getHeight() + 40;
					this.width = 940;
					groups.movey( "3", G3Y );
					groups.movey( "4", G4Y )
					break;
				default:
					BLOCK_SAVE = true;
					break;
			}
			
			stage.dispatchEvent( new ResizeEvent( ResizeEvent.RESIZE ));
			
			_selected = n;
			if (!STARTING) {
				getField( CMD.VR_WORKMODE_CURRENT, 1 ).setCellInfo( n );
				getField( CMD.VR_WORKMODE_CURRENT, 2 ).setCellInfo( n+1 );
				remember( getField( CMD.VR_WORKMODE_CURRENT, 1 ) );
			}
		}
		private function onTimeZone():void
		{
			VoyagerBot.changeTimeZone( int(cbTimeZone.getCellInfo()) );
			onChange();
		}
		private function refine(value:Object):int
		{
			if(value is int) {
				if( value  == CMD.VR_WORKMODE_SCHEDULE )
					return SavePerformer.CMD_TRIGGER_TRUE;
			} else {
				switch (value.struct) {
					case 7:
					case 19:
					case 31:
					case 43:
						opts[7].adaptTimeZone( value );
						break;
					case 8:
					case 20:
					case 32:
					case 44:
						opts[8].adaptTimeZone( value );
						break;
				}
				var finalcmd:int = value.cmd;
				return SavePerformer.CMD_TRIGGER_CONTINUE;
			}
			return SavePerformer.CMD_TRIGGER_FALSE;
		}
		private function onChange(e:Event=null):void
		{	
			
			// заставляет все поля расписания маркировать себя как измененные для сохранения
			(opts[7] as OptModeCustom).dispatchChange();
			(opts[8] as OptModeCustom).dispatchChange();
		}
	}
}