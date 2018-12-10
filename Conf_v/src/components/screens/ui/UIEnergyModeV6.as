package components.screens.ui
{
	import flash.events.Event;
	
	import mx.events.ResizeEvent;
	
	import components.abstract.ClientArrays;
	import components.abstract.GroupOperator;
	import components.abstract.VoyagerBot;
	import components.abstract.functions.loc;
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
	import components.screens.opt.OptModeCustomLight;
	import components.screens.opt.OptModeRegular;
	import components.screens.opt.OptModeRoot;
	import components.static.CMD;
	import components.static.COLOR;
	import components.static.PAGE;
	import components.system.SavePerformer;
	import components.system.UTIL;
	
	public class UIEnergyModeV6 extends UI_BaseComponent
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

		private var worning:FormEmpty;
		
		public function UIEnergyModeV6()
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
			
			/// Первый раздел
			rb1 = new FSRadioStandAlone;
			addChild( rb1 );
			rb1.attune( FSRadioStandAlone.F_HTML_TEXT );
			rb1.setName( UTIL.wrapHtml( EnergyModeString.getHeader(1) ) );
			rb1.y = globalY;
			rb1.x = globalX;
			rb1.tf.width = textwid;
			rb1.setUp( groupSelect, 1 );
			
			globalY += 30;
			
			createUIElement( new FormString, 0, "", null, 1);
			attuneElement( 800,NaN,FormString.F_MULTYLINE | FormString.F_HTML_TEXT);
			getLastElement().setCellInfo( EnergyModeString.getText(1) );

			globalY += 10;
			drawSeparator();
			globalY += 10;
			
			/// Второй раздел
			rb2 = new FSRadioStandAlone;
			addChild( rb2 );
			rb2.attune( FSRadioStandAlone.F_HTML_TEXT );
			rb2.setName( UTIL.wrapHtml( EnergyModeString.getHeader(2) ) );
			rb2.y = globalY;
			rb2.x = globalX;
			rb2.tf.width = textwid;
			rb2.setUp( groupSelect, 3 );
			
			globalY += 30;
			
			createUIElement( new FormString, 0, "", null, 2);
			attuneElement( 900,NaN,FormString.F_MULTYLINE | FormString.F_HTML_TEXT );
			getLastElement().setCellInfo( EnergyModeString.getText(2) );
			
			globalY += 10;
			var sep:Separator = drawSeparator();
			globalY += 10;
			
			
			/// Третий раздел
			rb3 = new FSRadioStandAlone;
			addChild( rb3 );
			rb3.attune( FSRadioStandAlone.F_HTML_TEXT );
			rb3.setName( UTIL.wrapHtml( EnergyModeString.getHeader(3) ) );
			rb3.y = globalY;
			rb3.x = globalX;
			rb3.tf.width = textwid;
			rb3.setUp( groupSelect, 5 );
			
			globalY += 30;
			
			createUIElement( new FormString, 0, "", null, 2);
			attuneElement( 800,NaN,FormString.F_MULTYLINE | FormString.F_HTML_TEXT );
			getLastElement().setCellInfo( EnergyModeString.getText(3) );
			
			groups.add("3", [rb3, getLastElement(), sep] );
			
			globalY += 10;
			sep = drawSeparator();
			globalY += 10;
			
			/// Четвертый раздел
			rb4 = new FSRadioStandAlone;
			addChild( rb4 );
			rb4.attune( FSRadioStandAlone.F_HTML_TEXT );
			rb4.setName( UTIL.wrapHtml(	EnergyModeString.getHeader(4) ) );
			rb4.y = globalY;
			rb4.x = globalX;
			rb4.tf.width = textwid;
			rb4.setUp( groupSelect, 7 );
			
			globalY += 30;
			
			createUIElement( new FormString, 0, "", null, 2);
			attuneElement( 800,NaN,FormString.F_MULTYLINE | FormString.F_HTML_TEXT );
			getLastElement().setCellInfo( EnergyModeString.getText(4) );
			
			groups.add("4", [rb4, getLastElement(), sep] );
			
			globalY += 10;
			sep = drawSeparator();
			globalY += 10;
				
			/// Пятый раздел
			rb5 = new FSRadioStandAlone;
			addChild( rb5 );
			rb5.attune( FSRadioStandAlone.F_HTML_TEXT );
			rb5.setName( UTIL.wrapHtml(EnergyModeString.getHeader(5)) );
			rb5.y = globalY;
			rb5.x = globalX;
			rb5.tf.width = textwid;
			rb5.setUp( groupSelect, 9 );
			
			globalY += 15;
			
			createUIElement( new FormString, 0, "", null, 2);
			attuneElement( 800,NaN, FormString.F_HTML_TEXT | FormString.F_TEXT_BOLD );
			getLastElement().setCellInfo( EnergyModeString.getText(5) );
			
			var f:FormEmpty = getLastElement();
			
			
			/// Шестой раздел
			groups.add("5", [rb5, f, sep] );
			
			globalY -= 20;
			sep = drawSeparator();
			globalY += 10;
			
			
			rb6 = new FSRadioStandAlone;
			addChild( rb6 );
			rb6.attune( FSRadioStandAlone.F_HTML_TEXT );
			rb6.setName( UTIL.wrapHtml( EnergyModeString.getHeader(6) ) );
			rb6.y = globalY;
			rb6.x = globalX;
			rb6.tf.width = textwid;
			rb6.setUp( groupSelect, 11 );
			
			globalY += 30;
				
			createUIElement( new FormString, 0, "", null, 2);
			attuneElement( 800,NaN,FormString.F_MULTYLINE | FormString.F_HTML_TEXT );
			getLastElement().setCellInfo( EnergyModeString.getText(6) );
			
			cbTimeZone = new FSComboBox;
			cbTimeZone.setName( loc("vem_shed_timezone") );
			addChild( cbTimeZone );
			cbTimeZone.setUp( onTimeZone );
			cbTimeZone.setList( ClientArrays.aTimeZones );
			cbTimeZone.setWidth( 250 );
			cbTimeZone.setCellWidth( 300 );
			cbTimeZone.attune( FSComboBox.F_COMBOBOX_NOTEDITABLE );
			cbTimeZone.x = globalX;
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
			opts[6] = new OptModeRoot(6);
			
			opts[7] = new OptModeRoot(7);
			opts[8] = new OptModeRegular(8);
			addChild( opts[8] );
			opts[8].x = globalX;
			opts[8].y = 423+10;
			
			//opts[9] = new OptModeRegular(9);
			
			opts[ 9 ] = new OptModeCustomLight( 9 );
			addChild( opts[9] );
			opts[9].x = globalX;
			opts[9].y = 530;
			//opts[9].rename( loc("vem_identify_coord_regulary_with_interval") );
			opts[10] = new OptModeCustomLight(10);
			//addChild( opts[10] );
			opts[10].x = globalX;
			opts[10].y = opts[9].y;
			
			opts[11] = new OptModeCustom(11);
			opts[12] = new OptModeCustom(12);
			addChild( opts[12] );
			opts[12].x = globalX + 370;
			opts[12].y = globalY + 30;
			addChild( opts[11] );
			opts[11].x = globalX;
			opts[11].y = opts[12].y;
			
			cbTimeZone.y = opts[11].y + opts[11].getHeight() + 20;

			
			FLAG_SAVABLE = false;
			
			
			
			worning =  addui( new FormString, 0, loc("vem_disable_sensor"), null, 2 );
			(getLastElement() as FormString).setTextColor( COLOR.RED );
			attuneElement( 700 );
			worning.visible = false;
			worning.y = G6Y + 115;
			
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
					
					
					assemblege[p.cmd] = back10minOfGPS( p.data );
					
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
		
		/**
		 * На сервер было отправлено время с поправкой на 10 минут для времени срабатывания
		 * GPS, чтобы показать пользователю именно то что он вводил берем его из времени
		 * установления связи с сервером
		 */
		private function back10minOfGPS(data:Array):Array
		{
			
			
			var len:int = data.length;
			for (var i:int=8; i<len; i+= 12) {
				data[ i ] = data[ i + 1 ].slice();
			}
			
			return data;
			
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
			
			worning.visible = false;
			
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
					this.height = 660;
					rb3.selected = true;
					groups.movey( "3", G3Y );
					groups.movey( "4", G4Y );
					groups.movey( "5", G5Y );
					groups.movey( "6", G6Y );
					break;
				case 7:
					this.height = 690;
					this.width = 905;
					rb4.selected = true;
					groups.movey( "3", G3Y );
					groups.movey( "4", G4Y );
					groups.movey( "5", G5Y+30 );
					groups.movey( "6", G6Y+30 );
					break;
				case 9:
					this.height = 750;
					this.width = 920;
					rb5.selected = true;
					groups.movey( "3", G3Y );
					groups.movey( "4", G4Y )
					groups.movey( "5", G5Y );
					groups.movey( "6", G6Y+164 );
					
					worning.visible = true;
					
					break;
				case 11:
					rb6.selected = true;
					this.height = globalY + opts[11].getHeight() + 40;
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
		/**
		 *  Перед отправкой на прибор время приводится 
		 * к гринвическому, а время 
		 * срабатывания GPS корректируется на 10 минут
		 * раньше, чтобы модем ко времени передачи
		 * располагал данными о координатах
		 *  
		 */
		private function refine(value:Object):int
		{
			if(value is int) {
				if( value  == CMD.VR_WORKMODE_SCHEDULE )
					return SavePerformer.CMD_TRIGGER_TRUE;
			} else {
				switch (value.struct) {
					case 9:
					case 21:
					case 33:
					case 45:
						/**
						 *  Определение координат должно быть установлено
						 * на 10 мин раньше, чем начнет работать модем для
						 * связи с сервером. Готовим для передачи скорректированное
						 * время для запроса координат
						 */
						//opts[9].adaptTimeZone( value );
						var duplicate:Object = 
						{
							array:(value.array as Array).slice(),
								cmd:value.cmd,
								data:{},
								struct:(value.struct+1)
						}
					
						var structs:Object = {};
						
						for( var key:String in value.data[CMD.VR_WORKMODE_SCHEDULE]) {
							structs[int(key) + 1] = value.data[CMD.VR_WORKMODE_SCHEDULE][key];
						}
						value.data[CMD.VR_WORKMODE_SCHEDULE][value.struct] = getChangedTime(value.data[CMD.VR_WORKMODE_SCHEDULE][value.struct]);
						duplicate.data[CMD.VR_WORKMODE_SCHEDULE] = structs;
						value.gpsCorrect = true;
						
						
						opts[9].adaptTimeZone( value );
						opts[10].adaptTimeZone( duplicate );
						break;
					/*case 10:
					case 22:
					case 34:
					case 46:
						opts[10].adaptTimeZone( value );
						break;*/
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
		
		/**
		 *  Определение координат должно быть установлено
		 * на 10 мин раньше, чем начнет работать модем для
		 * связи с сервером. Готовим для передачи скорректированное
		 * время для запроса координат
		 */
		private function getChangedTime(o:Object):Object
		{
			
			var clone:Object = {};
			for( var key:String in o) {
				clone[key] = o[key];
			}
			if (int(clone[9]) > 9) {
				clone[9] = int(clone[9])-10;
			} else {
				if( int(clone[8]) > 0 )  
					clone[8] = int(clone[8])-1;
				else
					clone[8] = 23;
				clone[9] = 60 + int(clone[9])-10;
			}
			return clone;
		}
		private function onChange(e:Event=null):void
		{	// заставляет все поля расписания маркировать себя как измененные для сохранения
			(opts[11] as OptModeCustom).dispatchChange();
			(opts[12] as OptModeCustom).dispatchChange();
			(opts[9] as OptModeCustom).dispatchChange();
			(opts[10] as OptModeCustom).dispatchChange();
		}
	}
}