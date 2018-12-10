package components.screens.ui
{
	import flash.events.Event;
	
	import mx.events.ResizeEvent;
	
	import components.abstract.ClientArrays;
	import components.abstract.GroupOperator;
	import components.abstract.VoyagerBot;
	import components.abstract.functions.loc;
	import components.abstract.servants.TabOperator;
	import components.basement.UI_BaseComponent;
	import components.gui.fields.FSComboBox;
	import components.gui.fields.FSRadioStandAlone;
	import components.gui.fields.FSShadow;
	import components.gui.fields.FormEmpty;
	import components.gui.fields.FormString;
	import components.gui.visual.Separator;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.resources.EnergyModeString;
	import components.screens.opt.OptModeCustom;
	import components.screens.opt.OptModeRegular;
	import components.screens.opt.OptModeRegularHours;
	import components.screens.opt.OptModeRoot;
	import components.static.CMD;
	import components.static.COLOR;
	import components.static.PAGE;
	import components.system.SavePerformer;
	import components.system.UTIL;
	
	public class UIEnergyModeV5 extends UI_BaseComponent
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
		private var rb5:FSRadioStandAlone;
		private var rb6:FSRadioStandAlone;
		private var cbTimeZone:FSComboBox;
		private var opts:Vector.<OptModeRoot>;
		
		private var groups:GroupOperator;
		private var groupsv:GroupOperator;
		private var assemblege:Array;
		private var _selected:int;
		
		public function UIEnergyModeV5()
		{
			super();
			
			opts = new Vector.<OptModeRoot>(13);
			
			EnergyModeString.getHeader(1);
			
			structureID = 1;
			
			globalX = PAGE.CONTENT_LEFT_SHIFT;
			globalY = PAGE.CONTENT_TOP_SHIFT+10;
			
			groups = new GroupOperator;
			groupsv = new GroupOperator;
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
			attuneElement( 800,NaN,FormString.F_MULTYLINE | FormString.F_HTML_TEXT);
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
			attuneElement( 900,NaN,FormString.F_MULTYLINE | FormString.F_HTML_TEXT );
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
			
			globalY += 30;
			
			createUIElement( new FormString, 0, "", null, 2);
			attuneElement( 800,NaN,FormString.F_MULTYLINE | FormString.F_HTML_TEXT );
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
			
			globalY += 30;
			
			createUIElement( new FormString, 0, "", null, 2);
			attuneElement( 830,NaN,FormString.F_MULTYLINE | FormString.F_HTML_TEXT );
			getLastElement().setCellInfo( EnergyModeString.getText(4) );
			
			groups.add("4", [rb4, getLastElement(), sep] );
			
			globalY += 10;
			sep = drawSeparator();
			globalY += 10;
				
			rb5 = new FSRadioStandAlone;
			addChild( rb5 );
			rb5.attune( FSRadioStandAlone.F_HTML_TEXT );
			rb5.setName( UTIL.wrapHtml(EnergyModeString.getHeader(5)) );
			rb5.y = globalY;
			rb5.x = globalX;
			rb5.tf.width = textwid;
			//rb5.tf.setSimpleFormat("left", 0,12,true);
			rb5.setUp( groupSelect, 9 );
			
			globalY += 30;
			
			createUIElement( new FormString, 0, "", null, 2);
			attuneElement( 800,NaN,FormString.F_MULTYLINE | FormString.F_HTML_TEXT );
			getLastElement().setCellInfo( EnergyModeString.getText(5) );
			
			var f:FormEmpty = getLastElement();
			var anch:int = globalY;
			
			globalY += 82;
			addui( new FormString, 0, loc("vem_disable_sensor"), null, 2 );
			(getLastElement() as FormString).setTextColor( COLOR.RED );
			attuneElement( 700 );
			groupsv.add("9", getLastElement() );
			groups.add("5", [rb5, f, getLastElement(), sep] );
			
			globalY = anch + 5;
			
			globalY += 10;
			sep = drawSeparator();
			globalY += 10;
			
			rb6 = new FSRadioStandAlone;
			addChild( rb6 );
			rb6.attune( FSRadioStandAlone.F_HTML_TEXT );
			rb6.setName( UTIL.wrapHtml( EnergyModeString.getHeader(6) ) );
			rb6.y = globalY;
			rb6.x = globalX;
			rb6.tf.width = textwid;
			//rb6.tf.setSimpleFormat("left", 0,12,true);
			rb6.setUp( groupSelect, 11 );
			
			globalY += 30;
				
			createUIElement( new FormString, 0, "", null, 2);
			attuneElement( 800,NaN,FormString.F_MULTYLINE | FormString.F_HTML_TEXT );
			getLastElement().setCellInfo( EnergyModeString.getText(6) );
			
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
			
			groups.add("6", [rb6, getLastElement(), sep, cbTimeZone] );
			
			globalY += 20;
			FLAG_SAVABLE = true;
			
			createUIElement( new FSShadow, CMD.VR_WORKMODE_CURRENT, "", null, 1 );
			createUIElement( new FSShadow, CMD.VR_WORKMODE_CURRENT, "", null, 2 );
			
			opts[1] = new OptModeRoot(1);
			opts[2] = new OptModeRoot(2);
			
			opts[3] = new OptModeRoot(3);
			opts[4] = new OptModeRoot(4);
			
			opts[5] = new OptModeRoot(5);
			opts[6] = new OptModeRegular(6);
			addChild( opts[6] );
			opts[6].x = globalX;
			opts[6].y = 310+10;
			
			opts[7] = new OptModeRegularHours(7);
			addChild( opts[7] );
			opts[7].x = globalX;
			opts[7].y = 423+10;
			opts[7].rename( loc("vem_idcoord_while_move_with_interval") );
			opts[8] = new OptModeRegular(8);
			addChild( opts[8] );
			opts[8].x = globalX;
			opts[8].y = 423+43;
			opts[8].rename( loc("vem_update_regulary_with_interval") );
			
			opts[9] = new OptModeRegular(9);
			addChild( opts[9] );
			opts[9].x = globalX;
			opts[9].y = 541+10;
			opts[9].rename( loc("vem_identify_coord_regulary_with_interval") );
			opts[10] = new OptModeRegular(10);
			addChild( opts[10] );
			opts[10].x = globalX;
			opts[10].y = 574+10;
			
			opts[11] = new OptModeCustom(11);
			opts[12] = new OptModeCustom(12);
			addChild( opts[12] );
			opts[12].x = globalX + 370;
			opts[12].y = globalY-22;

			addChild( opts[11] );
			opts[11].x = globalX;
			opts[11].y = globalY-22;
			
			cbTimeZone.y = opts[11].y + opts[11].getHeight() + 20;
			
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
			opts[9].visible = n == 9;
			opts[10].visible = n == 9;
			opts[11].visible = n == 11;
			opts[12].visible = n == 11;
			
			groupsv.show( n.toString() );
			
			rb1.selected = false;
			rb2.selected = false;
			rb3.selected = false;
			rb4.selected = false;
			rb5.selected = false;
			rb6.selected = false;
			
			this.width = 1080;
			
			switch(n) {
				case 1:
					this.height = 660;
					rb1.selected = true;
					groups.movey( "3", G3Y );
					groups.movey( "4", G4Y );
					groups.movey( "5", G5Y );
					groups.movey( "6", G6Y );
					
					break;
				case 3:
					this.height = 660;
					rb2.selected = true;
					groups.movey( "3", G3Y );
					groups.movey( "4", G4Y );
					groups.movey( "5", G5Y );
					groups.movey( "6", G6Y );
					break;
				case 5:
					this.height = 690;
					rb3.selected = true;
					groups.movey( "3", G3Y );
					groups.movey( "4", G4Y+30 );
					groups.movey( "5", G5Y+30 );
					groups.movey( "6", G6Y+30 );
					break;
				case 7:
					this.height = 690+33;
					this.width = 905;
					rb4.selected = true;
					groups.movey( "3", G3Y );
					groups.movey( "4", G4Y );
					groups.movey( "5", G5Y+30+33 );
					groups.movey( "6", G6Y+30+33 );
					break;
				case 9:
					this.height = 750;
					this.width = 920;
					rb5.selected = true;
					groups.movey( "3", G3Y );
					groups.movey( "4", G4Y )
					groups.movey( "5", G5Y );
					groups.movey( "6", G6Y+114 );
					break;
				case 11:
					rb6.selected = true;
					this.height = globalY + opts[11].getHeight() +40;
					this.width = 955;
					groups.movey( "3", G3Y );
					groups.movey( "4", G4Y )
					groups.movey( "5", G5Y );
					groups.movey( "6", G6Y );
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
					case 11:
					case 23:
					case 35:
					case 47:
						opts[11].adaptTimeZone( value );
						break;
					case 12:
					case 24:
					case 36:
					case 48:
						opts[12].adaptTimeZone( value );
						break;
				}
				var finalcmd:int = value.cmd;
				return SavePerformer.CMD_TRIGGER_CONTINUE;
			}
			return SavePerformer.CMD_TRIGGER_FALSE;
		}
		private function onChange(e:Event=null):void
		{	// заставляет все поля расписания маркировать себя как измененные для сохранения
			(opts[11] as OptModeCustom).dispatchChange();
			(opts[12] as OptModeCustom).dispatchChange();
		}
	}
}