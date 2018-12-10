package components.screens.ui
{
	/** STANDART VOYAGER SELECT PAR 1.1 V-all	*/
	
	import flash.display.MovieClip;
	
	import mx.containers.Canvas;
	import mx.core.UIComponent;
	
	import components.abstract.HistoryDataProvider;
	import components.abstract.RegExpCollection;
	import components.abstract.functions.dtrace;
	import components.abstract.functions.loc;
	import components.abstract.servants.ResizeWatcher;
	import components.abstract.servants.TabOperator;
	import components.abstract.servants.VoyagerHistoryServant;
	import components.basement.UI_BaseComponent;
	import components.events.GUIEventDispatcher;
	import components.events.GUIEvents;
	import components.events.SystemEvents;
	import components.gui.Header;
	import components.gui.PopUp;
	import components.gui.SimpleTextField;
	import components.gui.fields.FSCheckBoxSimple;
	import components.gui.fields.FSSimple;
	import components.gui.fields.FormEmpty;
	import components.gui.fields.FormString;
	import components.interfaces.IResizeDependant;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.protocol.statics.OPERATOR;
	import components.static.CMD;
	import components.static.COLOR;
	import components.static.DS;
	import components.static.GuiLib;
	import components.static.MISC;
	import components.system.SavePerformer;
	
	public class UIHistoryStructure extends UI_BaseComponent implements IResizeDependant
	{
		private const LAST_SYSTEM_PARAM:int = 9;
		private const MAX_LENGHT_RECORD:int = 200;
		
		private var STRUCTURES:int;
		
		private var BITFIELDS:Vector.<Vector.<FSCheckBoxSimple>>;
		private var TITLEFIELDS:Vector.<FormString>;
		private var SAVE_BITS:Vector.<Array>;
		private var CONTROL_SAVE_BITS:Vector.<Array>; 
		
		private var created:Boolean = false;
		private var availableparams:Vector.<int>;
		
		private var greenProgressBars:Vector.<MovieClip>;
		
		private var cont:Canvas;
		private var contY:int = 0;
		private var startPointForCheckBox:int;
		private var shiftHash:Array = [0,130,75,66,50];
		private var adds:Array;	// содержит информацию для построения визуального списка и так же группы, для возможности проверять все ли члены группы выбраны при загрузке
		private var groupMemory:Array;	// содержит инфу а группах, для проверки есть ли в них неотмеченные галочки
		private var groupField:Array;	// ведущий параметр, который имеет свой филд, ведомые члены группы не имеют своюи филодв
		private var cbSelectAll:FSCheckBoxSimple;
		private var area:UIComponent;
		private var areaTitle:SimpleTextField;
		private var canYStart:int;
		private var canHeight:int;
		
		public function UIHistoryStructure()
		{
			super();

			
			//STRUCTURES = CONST.VOYAGER_PAR_STRUCTURES;
			STRUCTURES = 1;
			
			SAVE_BITS = new Vector.<Array>(STRUCTURES);
			
			FLAG_SAVABLE = false;
			
			//const reg:RegExp = /^1\d\d|\d?\d|200$/x;
			const reg:RegExp = /^200|1?\d?\d$/;
			createUIElement( new FSSimple, 0, loc("his_line_size"),null,1, null, "", 0, reg );
			attuneElement( 300, NaN, FSSimple.F_CELL_NOTSELECTABLE );
			//FLAG_SAVABLE = false;
			globalY -= 12;
			const lbl:String = loc( "misc_save_impossible" ) + "! " + loc("no_very_long" )  + " " + MAX_LENGHT_RECORD + " " + loc( "g_byte" ) + "!";
			addui( new FormString, 0, lbl, null, 3 );
			attuneElement( 550, NaN, FormString.F_TEXT_BOLD );
			( getLastElement() as FormString ).setTextColor( COLOR.RED_BLOOD );

			
			createUIElement( new FSSimple, 0, loc("his_total_lines"),null,2 );
			attuneElement( 300, NaN, FSSimple.F_CELL_NOTSELECTABLE );
			
			BITFIELDS = new Vector.<Vector.<FSCheckBoxSimple>>(STRUCTURES);
			
			if (MISC.COPY_DEBUG) {		
				drawSeparator(741);
				greenProgressBars = new Vector.<MovieClip>(STRUCTURES);
			}
			
			var startPoint:int = 670 - (STRUCTURES*shiftHash[STRUCTURES]); 
			startPointForCheckBox = 710 - (STRUCTURES*shiftHash[STRUCTURES]);
			
			var names:Array = [{label:loc("his_param_num"), width:100, xpos:-10, align:"center"},{label:loc("his_param_name"), width:200, xpos:90, align:"left"},
				{label:loc("his_param_size"), width:140, xpos:385, align:"center"}];
			
			for (var i:int=0; i<STRUCTURES; ++i) {
				addUI(i);
			}
			
			drawSeparator(741);
			
			var header:Header = new Header( names );
			addChild( header );
			header.y = globalY;
			header.x = globalX;
			
			cbSelectAll = new FSCheckBoxSimple;
			addChild( cbSelectAll );
			cbSelectAll.x = startPoint+(i*shiftHash[STRUCTURES]-30);
			cbSelectAll.y = globalY;
			cbSelectAll.setUp( onSelectAll );
			
			globalY += 30;
			
			cont = new Canvas;
			addChild( cont );
			cont.y = globalY;
			cont.x = globalX;
			cont.width = 700;
			cont.height = 400;
			
			TITLEFIELDS = new Vector.<FormString>(256);
			
			popup = PopUp.getInstance();
			
			starterCMD = [CMD.HISTORY_SIZE,CMD.HISTORY_AVAILABLE_PAR,CMD.HISTORY_SELECT_PAR];
			//starterCMD = CMD.HISTORY_SELECT_PAR;
			
			function addUI(n:int):void
			{
				if (MISC.COPY_DEBUG) {
					if (STRUCTURES == 1)
						createUIElement( new FormString, 0, loc("his_line_in_block"),null,n+3);
					else
						createUIElement( new FormString, 0, loc("his_line_in_block1")+", "+(i+1)+ " "+loc("his_line_in_block2"),null,n+3);
					attuneElement(300);
				}
				if (greenProgressBars) {
					greenProgressBars[i] = new GuiLib.cPbarMini;
					addChild( greenProgressBars[i] );
					greenProgressBars[i].y = globalY - 34;
					greenProgressBars[i].x = 350;
					greenProgressBars[i].gotoAndStop( 20 );
				}
				
				if (STRUCTURES>1)
					names.push( {label:loc("his_block")+" "+(i+1), width:100, xpos:startPoint+(i*shiftHash[STRUCTURES]), align:"center"} );
				else
					names.push( {label:loc("his_block"), width:100, xpos:startPoint+(i*shiftHash[STRUCTURES]-15), align:"center"} );
				
				BITFIELDS[i] = new Vector.<FSCheckBoxSimple>(256);
			}
		}
		override public function open():void
		{
			super.open();
			popup.PARAM_CLOSE_ITSELF = false;
			ResizeWatcher.addDependent(this);
		//	VoyagerBot.getInstance().askSensorAKBstatus(doEnable);
		}
		override public function close():void
		{
			super.close();
			ResizeWatcher.removeDependent(this);
			
			if(area && cont.contains(area) )
				cont.removeChild( area );
			
			var f:FormEmpty;
			while( cont.numChildren > 0 ) {
				f = cont.getChildAt(0) as FormEmpty;
				cont.removeChild(f);
				f.undraw();
			}
			
			var len:int = BITFIELDS.length;
			for (var i:int=0; i<len; ++i) {
				BITFIELDS[i] = new Vector.<FSCheckBoxSimple>(256);
			}
			
			TITLEFIELDS = new Vector.<FormString>(256);
			contY = 0;
			availableparams = null;
			created = false;
			
		}
		override public function put(p:Package):void
		{
			var i:int;
			switch(p.cmd) {
				case CMD.HISTORY_SIZE:
					HistoryDataProvider.TOTAL_MEMORY = p.getStructure()[0];
					dtrace("TOTAL_MEMORY="+HistoryDataProvider.TOTAL_MEMORY );
					break;
				case CMD.HISTORY_AVAILABLE_PAR:
					var a:Array = p.getStructure();
					if (!availableparams)
						availableparams = new Vector.<int>(256);
					
					for(i=0; i<32; ++i) {
						for(var k:int=0; k<8; ++k) {
							if( (a[i] & (1 << k)) > 0 ) {
								if (i*8+k == 0)
									availableparams[i*8+k] = 0;
								else
									availableparams[i*8+k] = 1;
							}
						}
					}
					
					
					
					//RequestAssembler.getInstance().fireEvent( new Request(CMD.HISTORY_SELECT_PAR, put));
					break;
				case CMD.HISTORY_SELECT_PAR:
					if (!availableparams)
						return;
					var counter:int=1;
					var h:String;
					var g:int;
					var bytes:int;
					canYStart = 0;
					canHeight = 0;
					if (!created) {
						adds = [];
						var groupmembers:Array;
						for( i=LAST_SYSTEM_PARAM; i<255; ++i ) {
							
							if( getGroup(VoyagerHistoryServant.PARAMS[i]) > 0) {
								
								bytes=0;
								h = getHeader(i);
								g = getGroup(VoyagerHistoryServant.PARAMS[i]);
								groupmembers = [i];
								// проверка не создана ли такая группа уже
								var sg:int = getSepareteGrupNum(adds, g);
								
								while(true) {
									bytes += VoyagerHistoryServant.PARAMS[i].byte;
									if ( getGroup(VoyagerHistoryServant.PARAMS[i+1]) == g ) {
										i++;
										groupmembers.push(i);
									} else 
										break;
								}
								if (availableparams[i] == 1) {
									if (sg == -1)	// если група создана, ей надо только обновить количество байт
										adds.push( [h, counter++, bytes, g, groupmembers] );
									else {
										adds[sg][2] += bytes;
										adds[sg][4] = (adds[sg][4] as Array).concat(groupmembers);
									}
								}
							} else {
								if (availableparams[i] == 1) { 
									const byte:int = int(VoyagerHistoryServant.PARAMS[i] == null ? 0 : VoyagerHistoryServant.PARAMS[i].byte);
									const invisible:Boolean = Boolean(VoyagerHistoryServant.PARAMS[i] == null ? false : VoyagerHistoryServant.PARAMS[i].invisible);
									adds.push( [getHeader(i), counter++, byte , i, invisible ]);
								}
							}
						}
						
						
						var len:int = adds.length;
						for (i=0; i<len; i++) {
							// здесь требуется передавать только параметр invisible
							add( adds[i][0], adds[i][1], adds[i][2], adds[i][3], adds[i][4] is Boolean ? adds[i][4] : false );
						}
						created = true;
					} else {
						for(i=0; i<256; ++i ) {
							if( TITLEFIELDS[i] is FormString)
								TITLEFIELDS[i].attune( FormString.F_TEXT_NOT_BOLD );
						}
					}
					
					visualize(p);
					
					vizualizeAreas();
					
					SavePerformer.trigger( {"after":fill} );
					loadComplete();
					break;
			}
		}
		private function getSepareteGrupNum(a:Array, g:int):int
		{
			var len:int = a.length;
			for (var i:int=0; i<len; i++) {
				if( a[i][3] == g )
					return i;
			}
			return -1;
		}
		private function getGroup(obj:Object):int
		{
			if (obj && obj.group && int(obj.group) > 0 )
				return obj.group;
			return 0;
		}
		private function getHeader(n:int):String
		{
			var obj:Object = VoyagerHistoryServant.PARAMS[n];
			if (obj)
				return obj.header != null ? obj.header : obj.title;
			return loc("his_param")+" "+n;
		}
		private function visualize(p:Package):void
		{
			cbSelectAll.setCellInfo(1);
			var arr:Array = HistoryDataProvider.caclHistoryBlockSize(p);
			getField(0,1).setCellInfo( arr[0] );
			getField(0,2).setCellInfo( arr[1] );
			var comp:Array = arr[2];
			

			
			if( arr[ 0 ] > MAX_LENGHT_RECORD )
			{
				SavePerformer.forgetBlank();
				getField( 0, 3 ).visible = true;
			}
			else 
			{
				getField( 0, 3 ).visible = false;	
			}
			
			var i:int;
			var perc:int;
			var sorted_bits:Array = [0,0,0,0];
			for(i=0; i<STRUCTURES; ++i) {
				for(var l:String in comp[i] ) {
					sorted_bits[i] += int(comp[i][l]);		
				}
				
				if ( greenProgressBars ) {
					perc = sorted_bits[i]/arr[0]*100; 
					greenProgressBars[i].label.text = sorted_bits[i] +" "+loc("g_loaded_from_bytes")+" " +arr[0] +"("+perc+"%)";
					greenProgressBars[i].gotoAndStop( perc == 0 ? 1:perc );
				}
			}

			var g:int;
			var value:int;
			groupMemory = [];
			groupField = [];
			for(i=0; i<STRUCTURES; ++i) {
				for(var f:int=0; f<256; ++f ) {
					value = comp[i][f] is int ? 1 : 0;
					g = getGroup(VoyagerHistoryServant.PARAMS[f]);
					
					if ( BITFIELDS[i][f] != null ) {
						if (g > 0) {
							if( groupMemory[g] ) {	// если группа существует, значит был найден отключенный параметр
								value = 0;
							} else if (!value) {	// если группы нет, и найден отключенный параметр - группа создается
								groupMemory[g] = true;
							}
							if (!groupField[g])
								groupField[g] = BITFIELDS[i][f];
						}
						(BITFIELDS[i][f] as FSCheckBoxSimple).setCellInfo(value);
						if (value==0)
							cbSelectAll.setCellInfo(0);
					} else {
						if (g > 0) {
							if (!value && groupField[g])
								(groupField[g] as FSCheckBoxSimple).setCellInfo(0);
						}
					}
				}
			}
		}
		private function vizualizeAreas():void
		{
			if (!area) {
				area = new UIComponent;

				areaTitle = new SimpleTextField(loc("his_can_params"), 500, COLOR.MENU_ITEM_BLUE );
				area.addChild( areaTitle );
				areaTitle.setSimpleFormat( "left", 0, 14, true );
				areaTitle.x = 29;
				areaTitle.y = 5;
			}
			area.visible = canHeight > 0;
			if (canHeight > 0) {
				
				if( !cont.contains( area ) )
					cont.addChildAt( area, 0 );
				else
					cont.setChildIndex(area,0);
				area.y = canYStart-4;
				area.graphics.clear();
				area.graphics.beginFill( COLOR.NAVI_MENU_LIGHT_BLUE_BG );
				//area.graphics.drawRect( 0, canXStart-4, 630, canHeight );
				area.graphics.drawRoundRect( 0, 0, 630, canHeight, 15,15 );
			}
		}
		
		private function add(label:String, index:int, bytes:int, param:int, invisible:Boolean):void
		{
			// если параметр попадает в область кановых памамертов
			if (param > 102 && param < 144) {
				if( canYStart == 0 ) {
					canYStart = contY;	// указываем где начинается область
					canHeight = 27;	// на 1 сдвиг больше из-за title
					contY += 27;	// сдвигнаем на 1 вниз, чтобы поместился title
				}
				canHeight += 27;	// при каждом параметре добавляем ширину на 1 сдвиг
			}
			
			if (!invisible) {
				var f:FormString = new FormString;
				f.height = 27;
				cont.addChild( f );
				f.setCellInfo( index.toString() );
				f.y = contY;
				f.x = 30;
				
				f = new FormString;
				cont.addChild( f );
				f.setCellInfo( loc(label) );
				f.setWidth( 400 );
				f.y = contY;
				f.x = 100;
				TITLEFIELDS[param] = f;
				
				f = new FormString;
				cont.addChild( f );
				f.setCellInfo( bytes.toString() );
				f.setWidth( 40 );
				f.y = contY;
				f.x = 450;
			}
			
			var c:FSCheckBoxSimple;
			
			for (var i:int=0; i<STRUCTURES; ++i) {
				c = new FSCheckBoxSimple;
				if (invisible)
					c.invisible = true;
				else {
					cont.addChild( c );
					TabOperator.getInst().add(c);
					c.x = startPointForCheckBox + (i*shiftHash[STRUCTURES]);
					c.setWidth(0);
					c.setUp( processBits, i );
					c.y = contY;
				}
				BITFIELDS[i][param] = c;
			}
			if (!invisible)
				contY += 27;
			
		}
		private function processBits(s:int):void
		{
			var bits:Array = new Array;
			
			var b:int=0;
			var i:int=0;
			var internal_bit_counter:int=0; 
			for( i=0; i< 256; ++i) {
				
				// Сбрасываем жирность с шрифта
				if( TITLEFIELDS[c] is FormString)
					TITLEFIELDS[c].attune( FormString.F_TEXT_NOT_BOLD );
				
				// не учитываем системные параметры
				if ( i<LAST_SYSTEM_PARAM  || i == 255 ) {
					if ( ((s>0 && i!=0) || s==0) && !(internal_bit_counter == 0 && bits.length == 0) ) 
						b |= 1 << internal_bit_counter;
				} else {
					var need_bit:Boolean = false;
					if ( BITFIELDS[s][i] == null ) {
						var f:FSCheckBoxSimple = BITFIELDS[s][ getGroup(VoyagerHistoryServant.PARAMS[i]) ] as FSCheckBoxSimple;
						if (f)
							need_bit = f.getCellInfo() == "1";
						else
							need_bit = false;
					} else
						need_bit = (BITFIELDS[s][i] as FSCheckBoxSimple).getCellInfo() == "1";
					
					if (need_bit)
						b |= 1 << internal_bit_counter;
				}
				internal_bit_counter++;
				if (internal_bit_counter > 7) {
					bits[ Math.floor(i/8) ] = b;
					b = 0;
					internal_bit_counter = 0;
				}
			}
			
			// Проверка на уже сохраненные данные
			var saved:Array = OPERATOR.dataModel.getData( CMD.HISTORY_SELECT_PAR )[s];
			var indetical:Boolean = true;
			var c:int
			
			for(c=0; c<32; ++c ) {
				if ( bits[c] != saved[c] ) {
					indetical = false;
					
					for(var k:int=0; k<8; ++k ) {
						if( (bits[c] & (1<<k)) != (saved[c] & (1<<k)) ) {
							if(TITLEFIELDS[(c*8+k)] is FormString)
								TITLEFIELDS[(c*8+k)].attune( FormString.F_TEXT_BOLD );
						}
					}
				}
			}
			if (indetical)
				SAVE_BITS[s] = null;
			else
				SAVE_BITS[s] = bits;
			
			var save_show:Boolean = false;
			for(var any:String in SAVE_BITS) {
				if( SAVE_BITS[any] is Array) {
					save_show = true;
					break;
				}
			}
			if(save_show)
				SavePerformer.rememberBlank();
			else
				SavePerformer.forgetBlank();
			
			updateVisual();
		}
		private function updateVisual():void
		{
			var p:Package = new Package;
			p.data = OPERATOR.dataModel.getData( CMD.HISTORY_SELECT_PAR ).slice();
			
			for(var any:String in SAVE_BITS) {
				if( SAVE_BITS[any] is Array)
					p.data[any] = SAVE_BITS[any];
			}
			visualize( p );
		}
		private function fill():void
		{
			if (DS.isDevice(DS.V15) || DS.isDevice(DS.V15IP))
				doSave();
			else {
				popup.construct( PopUp.wrapHeader("his_delete_when_save"), PopUp.wrapMessage(loc("sys_attention")+" "+loc("his_continue_save")), PopUp.BUTTON_YES | PopUp.BUTTON_NO, [doSave,doCancel] );
				popup.open();
			}
		}
		private function doSave():void
		{
			for(var i:int=0; i<STRUCTURES; ++i) {
				if (SAVE_BITS[i] != null)
					RequestAssembler.getInstance().fireEvent( new Request( CMD.HISTORY_SELECT_PAR, null, i+1, SAVE_BITS[i] ));
				SAVE_BITS[i] = null;
			}
			var scrMsg:String;
			
			if (!DS.isDevice(DS.V15) && !DS.isDevice(DS.V15IP))
				RequestAssembler.getInstance().fireEvent( new Request( CMD.HISTORY_DELETE, deleteComplete, 1, [1] ));
			
		//	new HistoryDeletingBot( CLIENT.TIMER_EVENT_SPAM, VoyagerBot.getHistoryDeleteTimeOut(),	deleteComplete, HistoryDeletingBot.SELECT_PAR );
			var c:int
			for(c=0; c<256; ++c ) {
				if( TITLEFIELDS[c] is FormString)
					TITLEFIELDS[c].attune( FormString.F_TEXT_NOT_BOLD );
			}
			
			popup.close();
		}
		public function doCancel():void
		{
			if ( OPERATOR.dataModel.getData( CMD.HISTORY_SELECT_PAR ) is Array) {
				var p:Package = Package.create( OPERATOR.dataModel.getData( CMD.HISTORY_SELECT_PAR ).slice(), 0 );
				p.cmd = CMD.HISTORY_SELECT_PAR;
				put(p);
				popup.close();
			}
			for(var i:int=0; i<STRUCTURES; ++i) {
				SAVE_BITS[i] = null;
			}
		}
		private function onSelectAll():void
		{
			var b:int = int(cbSelectAll.getCellInfo());
			
			var len:int = BITFIELDS[0].length;
			var waschange:Boolean=false;
			for (var i:int=0; i<len; i++) {
				if (BITFIELDS[0][i] != null && int(BITFIELDS[0][i].getCellInfo()) != b && !BITFIELDS[0][i].invisible ) {
					BITFIELDS[0][i].setCellInfo(b);
					waschange=true;
				}
			}
			if (waschange)
				processBits(0);
		}
		/*****************************************/
		private function deleteComplete(p:Package):void
		{
			RequestAssembler.getInstance().fireEvent( new Request( CMD.HISTORY_SELECT_PAR, getPar ));
		}
		private function getPar(p:Package):void
		{
			GUIEventDispatcher.getInstance().fireSystemEvent( SystemEvents.onBlockNavigation, {"isBlock":false} );
			GUIEventDispatcher.getInstance().fireEvent( GUIEvents, GUIEvents.onNeedScreenBlock );
			put(p);
		}
		
		private function BackSaveOverSize():void
		{
			
		}
		// Костыль : для вояджера только первая структура проверяется
		/*private function doEnable(b:Boolean):void
		{
			if (BITFIELDS[0] && BITFIELDS[0][VoyagerBot.PARAM_AKB] is FSCheckBoxSimple )
				BITFIELDS[0][VoyagerBot.PARAM_AKB].disabled = b;
		}*/
		public function localResize(w:int, h:int, real:Boolean=false):void
		{
			var pos:int = h - (cont.y+35) < 100 ? 100:h-(cont.y+35);
			cont.height = pos;
		}
	}
}