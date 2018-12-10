package components.screens.ui
{
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	
	import components.abstract.GroupOperator;
	import components.abstract.functions.loc;
	import components.abstract.servants.TaskManager;
	import components.abstract.servants.WireServantK9;
	import components.basement.UI_BaseComponent;
	import components.events.GUIEvents;
	import components.gui.SimpleTextField;
	import components.gui.fields.FormEmpty;
	import components.gui.triggers.TextButton;
	import components.gui.visual.out.LevelPanelWire;
	import components.interfaces.ITask;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.protocol.statics.OPERATOR;
	import components.static.CMD;
	import components.static.COLOR;
	import components.static.DS;
	import components.system.Library;
	import components.system.SavePerformer;
	import components.system.UTIL;
	
	public class UIWireConfigK9 extends UI_BaseComponent
	{
		public static const COLOR_CUT_WIRE:uint = 0x1C75BC;
		public static const COLOR_NORM_WIRE:uint = 0x39B54A;
		public static const COLOR_ALARM_ZONE_I:uint = 0xC49A6C;
		public static const COLOR_ALARM_ZONE_II:uint = 0xF7941E;
		public static const COLOR_ALARM_ZONES:uint = 0x9E1F63;
		public static const COLOR_SHORT_CIRCUIT_WIRE:uint = 0xF15A29;
		public static const SHORT_CIRCUIT_DRY_WIRE:uint = 512;
		private static const _TOP_POSITION:uint = 30;
		
		public static var isDryWire:Boolean;
		
		private const fireArray:Array  = [ {label:loc("k5_wire_cut"),color:COLOR_CUT_WIRE}, {label:loc("k5_wire_norm"),color:COLOR_NORM_WIRE},
			{label:loc("k5_wire_warn"),color:0xC49A6C},{label:loc("k5_wire_alarm"),color:0x9E1F63},
			{label:loc("k5_wire_short_circuit"),color:COLOR_SHORT_CIRCUIT_WIRE}];;
		private const resArray:Array  = [ {label:loc("k5_wire_cut"),color:COLOR_CUT_WIRE}, {label:loc("k5_wire_both_open"),color:COLOR_NORM_WIRE},
			{label:loc("k5_wire_closed_open"),color:0xC49A6C},{label:loc("k5_wire_open_closed"),color:0xF7941E},
			{label:loc("k5_wire_both_closed"),color:0x9E1F63},{label:loc("k5_wire_short_circuit"),color:COLOR_SHORT_CIRCUIT_WIRE}];
		private var drywire:Bitmap;
		private var reswire:Bitmap;
		private var panel:LevelPanelWire;
		private var white:Sprite;
		private var sens:Vector.<Sensor>;
		private var dim:Array = [60,247,438,627,60,247,438,627];
		private var wa:WireAnalyzer;
		private var task:ITask;
		private var btns:Vector.<TextButton>;
		private var go:GroupOperator;
		private var title:SimpleTextField;
		
		// Настройки шлейфов
		
		public function UIWireConfigK9()
		{
			super();
			
			wa = new WireAnalyzer;
			const top:int = 50;
			
			drywire = new Library.cw3sensors;
			addChild( drywire );
			drywire.x = 50;
			drywire.y = _TOP_POSITION;
			drywire.visible = false;
			
			reswire = new Library.cw6sensors;
			addChild( reswire );
			reswire.x = 50;
			reswire.y = _TOP_POSITION;
			reswire.visible = false;
			
			var srv:WireServantK9 = new WireServantK9;
			srv.edges( 0x01e,0x3ff );
			
			sens = new Vector.<Sensor>;
			for (var i:int=0; i<3; i++) {
				sens.push( new Sensor(i) );
				addChild( sens[i] );
				sens[i].x = dim[i];
				if (i < 4)
					sens[i].y = _TOP_POSITION + 3;
				else
					sens[i].y = _TOP_POSITION + 416;
				sens[i].addEventListener( GUIEvents.EVOKE_TOGLE, onClick );
			}
			
			
			white = new Sprite;
			addChild( white );
			white.graphics.beginFill( COLOR.WHITE );
			white.graphics.drawRect( 0, 180, 720, 200 );
			white.visible = false;
			
			title = new SimpleTextField( loc("rfd_wire")+" ", 400 );
			addChild( title );
			title.setSimpleFormat("left",0,14,true);
			title.width = 320;
			title.height = 30;
			title.wordWrap = false;
			title.y = 190;
			title.x = 10;
			title.visible = false;
				
			panel = new LevelPanelWire(srv);
			addChild( panel );
			panel.build( fireArray );
			panel.addEventListener( Event.CHANGE, levelChanged );
			panel.visible = false;
			
			

			var aLevelFields:Array = panel.getFields();
			for( var keya:String in aLevelFields ) {
				addUIElement( (aLevelFields[keya] as FormEmpty), CMD.K5_ADC_TRESH, int(keya)+1, null, getStructure() ); 
			}
			
			panel.x = 110;
			panel.y = _TOP_POSITION + 260;
			
			globalY = _TOP_POSITION + 570;
			
			go = new GroupOperator;
			go.add( "1", drawSeparator(775) );
			
			btns = new Vector.<TextButton>(2);
			btns[0] = new TextButton;
			addChild( btns[0] );
			btns[0].setUp(loc("g_defaults"), onDefaults, 1 );
			btns[0].x = globalX;
			btns[0].y = globalY;
			globalY += 30;
			go.add( "1",btns[0] );
			
			height = 690;
			width = 800;
			
			starterCMD = [CMD.K9_BIT_SWITCHES, CMD.K5_ADC_TRESH, CMD.K5_ADC_GET];
			starterRefine(CMD.K9_PART_PARAMS);
			starterRefine(CMD.K9_AWIRE_TYPE);
		}
		override public function close():void
		{
			super.close();
			panel.visible = false;
			white.visible = false;
			title.visible = false;
			if( task )
				task.kill();
			task = null;
		}
		override public function put(p:Package):void
		{
			switch(p.cmd) {
				case CMD.K9_BIT_SWITCHES:
					isDryWire = UTIL.isBit(1, int(p.getParam(1,1)));
					reswire.visible = !isDryWire;
					drywire.visible = isDryWire;
					
					go.visible("1", !isDryWire);
					
					if(isDryWire)
						height = 570;
					else
						height = 690;
					
					break;
				case CMD.K5_ADC_TRESH:
					
					wa.add(sens);
					var a:Array = OPERATOR.dataModel.getData(CMD.K9_PART_PARAMS);
					
					/**	Команда K9_PART_PARAMS - параметры разделов
						Параметр 1 - состояние раздела, 0 - без охраны; 1 - под охраной, 2 - под охраной, была тревога
						Параметр 2 - Быстрая постановка: 1 - разрешена; 0 - запрещена 
						Параметр 3 - Ожидать передачу на пульт: 1 - разрешено; 0 - запрещено 
						Параметр 4 - Включать сирену при тревоге: 1 - разрешено; 0 - запрещено 
						Параметр 5 - 24-х-часовой раздел: 1 - да; 0 - нет 
						Параметр 6 - пожарный раздел: 1 - да; 0 - нет  
						Параметр 7 - задержка на выход для раздела, значения задержки в секундах	*/												
					
					var wire:Array = OPERATOR.dataModel.getData(CMD.K9_AWIRE_TYPE);
					
					/**	Команда K9_AWIRE_TYPE -  для записи и чтения параметров шлейфов 
						Параметр 1 - нормальное состояние шлейфов, значения: 0 - шлейф нормально-разомкнутый, 1 - нормально-замкнутый
						Параметр 2 - номер раздела, к которому относится шлейф  (значения с 0 по 5 соответствуют разделам с 1 по 6)
						Параметр 3 - код ACID для шлейфа
						Параметр 4 - задержка на вход для шлейфа, значение задержки в секундах "													
						По функционалу аналогична 3-м командам Контакта-5:
						+K5_AWIRE_TYPE,
						+K5_AWIRE_DELAY,
						+K5_AWIRE_PART_CODE */
					
					// пробегаемся по созданным сенсорам
					var len:int = sens.length;
					for (var i:int=0; i<len; i++) {
						
						if (isDryWire) {
							sens[i].init(true, a[wire[i][1]][5] == 1 );
						} else
							sens[i].init(false, 
								a[wire[i*2][1]][5] == 1, 
								wire[i*2][0] == 1, 
								wire[i*2+1][0] == 1 );
						//sens[i].init(false, a[wire[i*2]][5] == 1, UTIL.isBit(i*2,wstate), UTIL.isBit(i*2+1,wstate) );
					}
					loadComplete();
					
					
					break;
				case CMD.K5_ADC_GET:
					
					
					if( isDryWire )
						wa.dryPut(p)
					else
						wa.put( p );
					
						
					if (this.visible) {
						if( !task )
							task = TaskManager.callLater( onTick, TaskManager.DELAY_1SEC*5 );
						else
							task.repeat();
					}
					if (panel.visible)
						panel.putWireResistance( p.getStructure(panel.structureID)[0] );
					break;
			}
		}
		private function onTick():void
		{
			RequestAssembler.getInstance().fireEvent( new Request(CMD.K5_ADC_GET, put));
		}
		private function levelChanged(ev:Event=null):void
		{
			if (panel.visible) {
				SavePerformer.remember( panel.structureID, panel.getTarget() );
				//wa.update(panel.getLevels(), panel.structureID);
			}
		}
		private function onClick(e:Event):void
		{
			var isfire:Boolean = (e.currentTarget as Sensor).isfire;
			
			SavePerformer.closePage();
			var v:Boolean = false;
			var n:int = (e.currentTarget as Sensor).num;
			var a:Array;
			
			var wireType:Array = OPERATOR.dataModel.getData(CMD.K9_AWIRE_TYPE);
			
		/*	[ {label:loc("k5_wire_cut"),color:0x1C75BC}, {label:loc("k5_wire_both_open"),color:0x39B54A},
				{label:loc("k5_wire_closed_open"),color:0xC49A6C},{label:loc("k5_wire_open_closed"),color:0xF7941E},
				{label:loc("k5_wire_both_closed"),color:0x9E1F63},{label:loc("k5_wire_short_circuit"),color:0xF15A29}];
			*/
			if (!panel.visible || panel.visible && panel.structureID-1 != n ) {
				a = OPERATOR.dataModel.getData(CMD.K5_ADC_TRESH);
				
				
				var resGenerated:Array; 
				if( wireType[n*2][0] == 0 && wireType[n*2+1][0] == 0 ) {		//0,0
					resGenerated = 
						[ {label:loc("k5_wire_cut"),color:COLOR_CUT_WIRE}, 
							{label:loc("wire_norm"),color:COLOR_NORM_WIRE},
							{label:loc("wire_state_alarm_zone")+" 1",color:COLOR_ALARM_ZONE_I},
							{label:loc("wire_state_alarm_zone")+" 2",color:COLOR_ALARM_ZONE_II},
							{label:loc("wire_state_alarm_zones")+" 1,2",color:COLOR_ALARM_ZONES},
							{label:loc("k5_wire_short_circuit"),color:COLOR_SHORT_CIRCUIT_WIRE} ];
				} else if (wireType[n*2][0] == 1 && wireType[n*2+1][0] == 0) {	//0,1
					resGenerated = 
						[ {label:loc("k5_wire_cut"),color:COLOR_CUT_WIRE}, /// замкнут, разомкнут
							{label:loc("wire_state_alarm_zone")+" 1",color:COLOR_ALARM_ZONE_I},
							{label:loc("wire_norm"),color:COLOR_NORM_WIRE},
							{label:loc("wire_state_alarm_zones")+" 1,2",color:COLOR_ALARM_ZONES},
							{label:loc("wire_state_alarm_zone")+" 2",color:COLOR_ALARM_ZONE_II},
							{label:loc("k5_wire_short_circuit"),color:COLOR_SHORT_CIRCUIT_WIRE} ];
					
				} else if (wireType[n*2][0] == 1 ) {	//0,1 /// замкнут, замкнут
					resGenerated = 
						[ {label:loc("k5_wire_cut"),color:COLOR_CUT_WIRE},
							{label:loc("wire_state_alarm_zones")+" 1,2",color:COLOR_ALARM_ZONES},
							{label:loc("wire_state_alarm_zone")+" 2",color:COLOR_ALARM_ZONE_II},
							{label:loc("wire_state_alarm_zone")+" 1",color:COLOR_ALARM_ZONE_I},
							{label:loc("wire_norm"),color:COLOR_NORM_WIRE},
							{label:loc("k5_wire_short_circuit"),color:COLOR_SHORT_CIRCUIT_WIRE} ];
					
				} else if (wireType[n*2][0] == 0 && wireType[n*2+1][0] == 1) {	//1,0
					resGenerated = 
						[ {label:loc("k5_wire_cut"),color:COLOR_CUT_WIRE}, {label:loc("wire_state_alarm_zone")+" 2",color:COLOR_ALARM_ZONE_II},
							{label:loc("wire_state_alarm_zones")+" 1,2",color:COLOR_ALARM_ZONES}, {label:loc("wire_norm"),color:COLOR_NORM_WIRE},
							{label:loc("wire_state_alarm_zone")+" 1",color:COLOR_ALARM_ZONE_I},{label:loc("k5_wire_short_circuit"),color:COLOR_SHORT_CIRCUIT_WIRE} ];
				} else  {														//1,1
					resGenerated = 
						[ {label:loc("k5_wire_cut"),color:COLOR_CUT_WIRE}
							, {label:loc("wire_norm"),color:COLOR_NORM_WIRE}
							, {label:loc("wire_state_alarm_zones")+" 1,2",color:COLOR_ALARM_ZONES},
							{label:loc("wire_state_alarm_zone")+" 1",color:COLOR_ALARM_ZONE_I},{label:loc("wire_state_alarm_zone")+" 2",color:COLOR_ALARM_ZONE_II},
							{label:loc("wire_norm"),color:0x9E1F63},{label:loc("k5_wire_short_circuit"),color:COLOR_SHORT_CIRCUIT_WIRE} ];
				}
					
				
				if (isfire)
					panel.build( fireArray );
				else
					panel.build( resGenerated );
					//panel.build( resArray );
				
				//var thresh:Array = a[n].slice().reverse();
				var thresh:Array = a[n].slice();
				/*if (!isfire)
					thresh.splice(0,0,30);*/
				
				panel.put(thresh);
				panel.changeStructure( n+1 );
				
				v = true;
				panel.visible = true;
				
				a = OPERATOR.dataModel.getData(CMD.K5_ADC_GET);
				panel.putWireResistance( a[panel.structureID-1] );
			} else 
				panel.visible = false;
			white.visible = v;
			title.text = (e.currentTarget as Sensor).wiretitle;
			title.visible = v;
		}
		private function onDefaults(n:int):void
		{
			panel.visible = false;
			white.visible = false;
			title.visible = false;
			var len:int = OPERATOR.getSchema( CMD.K5_ADC_TRESH).StructCount;
			
			var i:int;
			
			for (i=0; i<len; i++) {
				//RequestAssembler.getInstance().fireEvent( new Request(CMD.K5_ADC_TRESH,put,i+1,[30,243,385,501,776]));
				RequestAssembler.getInstance().fireEvent( new Request(CMD.K5_ADC_TRESH,put,i+1,[30,245,386,502,774]));
			}
			//+K5_ADC_TRESH=1, 30, 243, 385, 501, 776
			
			// 00f	0f3	182	1f6	306
			//	00f	0f3	182	1f6	30
			//	15	243	386	502
			loadStart();
		}
	}
}
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.Event;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;

import mx.core.UIComponent;

import components.abstract.functions.loc;
import components.events.GUIEvents;
import components.gui.SimpleTextField;
import components.gui.triggers.TextButton;
import components.protocol.Package;
import components.protocol.statics.OPERATOR;
import components.screens.ui.UIWireConfigK9;
import components.static.CMD;
import components.static.COLOR;
import components.system.Library;

class Sensor extends UIComponent
{
	public var num:int;
	
	private var bConfig:TextButton;
	//private var title:SimpleTextField;
	
	private var s1:SensorVisual;
	private var s2:SensorVisual;
	private var s1ypos:int;
	private var s1yposalone:int;
	private var isdry:Boolean;
	
	public var isfire:Boolean;
	public var wiretitle:String;
	public var stateNormalClosed1:Boolean;
	public var stateNormalClosed2:Boolean;
	
	public function Sensor(n:int)
	{
		super();
		
		num = n;
		
		s1 = new SensorVisual( ( num * 2 ) + 2 );
		addChild( s1 );
		s2 = new SensorVisual( ( num * 2 ) + 1 );
		addChild( s2 );

		bConfig = new TextButton;
		addChild( bConfig );
		wiretitle = loc("k5_wire_config")+" " + (num*2+1) + ","+(num*2+2);
		bConfig.setUp( loc("k5_wire_config_0d0a")+" " + (num*2+1) + ","+(num*2+2), onClick );
		
		/*title = new SimpleTextField( loc("rfd_wire")+" "+(num+1) );
		addChild( title );
		title.setSimpleFormat("left",0,14);
		title.width = 120;
		title.height = 30;
		title.y = 13;*/
		
		if (n<4) {
			s1.x = 60;
			s2.x = 60;
			s2.y = 50;
			bConfig.y = 85;
			//title.y = 85;
			s1yposalone = 28;
		} else {
			s1.x = 60;
			s1.y = 36;
			s2.x = 60;
			s2.y = 87;
			s1yposalone = s1.y+17;
		}
		s1ypos = s1.y;
	}
	public function init(dry:Boolean, isFire:Boolean, normalclosed1:Boolean=false, normalclosed2:Boolean=false ):void
	{
		bConfig.visible = !dry;
		
		isfire = isFire;
		stateNormalClosed1 = normalclosed1;
		stateNormalClosed2 = normalclosed2;
		
		isdry = dry;
		
		s2.visible = !dry;
		s1.y = dry ? s1yposalone : s1ypos;
		s1.type( isFire ? SensorVisual.FIRE : SensorVisual.RES );
		s1.state(SensorVisual.NORM);
		
		s2.type( isFire ? SensorVisual.FIRE : SensorVisual.RES );
		
		s1.setDry( dry );	
		s2.state(SensorVisual.NORM);
	}
	public function update(t:int):void
	{
		
		
		
		if (isdry) {
			/** DRY			*********************/
			
			
			/**	Команда K9_AWIRE_TYPE -  для записи и чтения параметров шлейфов 
			 Параметр 1 - нормальное состояние шлейфов, значения: 0 - шлейф нормально-разомкнутый, 1 - нормально-замкнутый
			 Параметр 2 - номер раздела, к которому относится шлейф  (значения с 0 по 5 соответствуют разделам с 1 по 6)
			 Параметр 3 - код ACID для шлейфа
			 Параметр 4 - задержка на вход для шлейфа, значение задержки в секундах "													
			 По функционалу аналогична 3-м командам Контакта-5:
			 +K5_AWIRE_TYPE,
			 +K5_AWIRE_DELAY,
			 +K5_AWIRE_PART_CODE */
			
			// выяснить нормальное положение шлейфа
			/*var a:Array = OPERATOR.dataModel.getData(CMD.K5_AWIRE_TYPE);
			var bit:int = a[0][0] >> 8;
			var b:Boolean = UTIL.isBit(num,bit);*/
			
			var a:Array = OPERATOR.dataModel.getData(CMD.K9_AWIRE_TYPE);
			var b:Boolean = a[num][0] == 1;
			
			
			if (b) {	// если замкнутое
				switch(t) {
					case WireAnalyzer.CUT:
						s1.state( SensorVisual.NORM );
						s2.state( SensorVisual.NORM );
						break;
					default:
						s1.state( SensorVisual.ALARM );
						s2.state( SensorVisual.ALARM );
				}
			} else {	// если разомкнутое
				switch(t) {
					case WireAnalyzer.CUT:
						s1.state( SensorVisual.ALARM );
						s2.state( SensorVisual.ALARM );
						break;
					default:
						s1.state( SensorVisual.NORM );
						s2.state( SensorVisual.NORM );
				}
			}
		} else if (isfire ) {
			/** FIRE		*********************/
			
			switch(t) {
				case WireAnalyzer.KZ:
				case WireAnalyzer.CUT:
					if (isdry) {
						s1.state( SensorVisual.NORM );
						s2.state( SensorVisual.NORM );
					} else {
						s1.state( SensorVisual.CRASH );
						s2.state( SensorVisual.CRASH );
					}
					break;
				case WireAnalyzer.NORM:
					s1.state( SensorVisual.NORM );
					s2.state( SensorVisual.NORM );
					break;
				case WireAnalyzer.WARN_SECOND:
					s1.state( SensorVisual.NORM );
					s2.state( SensorVisual.ALARM );
					break;
				case WireAnalyzer.WARN:
				case WireAnalyzer.ALARM:
					s1.state( SensorVisual.ALARM);
					s2.state( SensorVisual.ALARM );
					break;
			}
			
			/** FIRE		**********************/
			
		} else {
			switch(t) {
				case WireAnalyzer.KZ:
				case WireAnalyzer.CUT:
					if (isdry) {
						s1.state( SensorVisual.NORM );
						s2.state( SensorVisual.NORM );
					} else {
						s1.state( SensorVisual.CRASH );
						s2.state( SensorVisual.CRASH );
					}
					break;
				case WireAnalyzer.NORM:
					if (stateNormalClosed1 != stateNormalClosed2) {
						s1.state( stateNormalClosed1 ? SensorVisual.NORM : SensorVisual.ALARM );
						s2.state( stateNormalClosed2 ? SensorVisual.NORM : SensorVisual.ALARM );
					} else {
						s1.state( stateNormalClosed1 ? SensorVisual.ALARM : SensorVisual.NORM );
						s2.state( stateNormalClosed2 ? SensorVisual.ALARM : SensorVisual.NORM );
					}
					break;
				case WireAnalyzer.WARN:
					if (stateNormalClosed1 != stateNormalClosed2) {
						s1.state( stateNormalClosed1 ? SensorVisual.ALARM : SensorVisual.NORM );
						s2.state( stateNormalClosed2 ? SensorVisual.NORM : SensorVisual.ALARM );
					} else {
						s1.state( stateNormalClosed1 ? SensorVisual.NORM : SensorVisual.ALARM );
						s2.state( stateNormalClosed2 ? SensorVisual.ALARM : SensorVisual.NORM );
					}
					break;
				case WireAnalyzer.WARN_SECOND:
					
					if (stateNormalClosed1 != stateNormalClosed2) {
						s1.state( stateNormalClosed1 ? SensorVisual.NORM : SensorVisual.ALARM );
						s2.state( stateNormalClosed2 ? SensorVisual.ALARM : SensorVisual.NORM );
					} else {
						s1.state( stateNormalClosed1 ? SensorVisual.ALARM : SensorVisual.NORM );
						s2.state( stateNormalClosed2 ? SensorVisual.NORM : SensorVisual.ALARM );
					}
					break;
				case WireAnalyzer.ALARM:
					if (stateNormalClosed1 != stateNormalClosed2) {
						s1.state( stateNormalClosed1 ? SensorVisual.ALARM : SensorVisual.NORM );
						s2.state( stateNormalClosed2 ? SensorVisual.ALARM : SensorVisual.NORM );
					} else {
						s1.state( stateNormalClosed1 ? SensorVisual.NORM : SensorVisual.ALARM);
						s2.state( stateNormalClosed2 ? SensorVisual.NORM : SensorVisual.ALARM );
					}
					break;
			}
			
		}
	}
	private function onClick():void
	{
		this.dispatchEvent( new Event(GUIEvents.EVOKE_TOGLE));
	}
}
class SensorVisual extends Sprite
{
	public static const FIRE:int = 3;
	public static const RES:int = 0;
	public static const NORM:int = 0;
	public static const CRASH:int = 1;
	public static const ALARM:int = 2;
	
	private var sens:Vector.<Bitmap>;
	private var sentype:int;

	private var _ind:int;

	private var _spNm:Sprite;
	
	public function SensorVisual( myInx:int )
	{
		_ind = myInx
		sens = new Vector.<Bitmap>;
		
		sens.push( new Library.cwsensornorm );
		addChild( sens[sens.length-1] );
		sens.push( new Library.cwsensorcrash );
		addChild( sens[sens.length-1] );
		sens.push( new Library.cwsensoralarm );
		addChild( sens[sens.length-1] );
		sens.push( new Library.cwfirenorm );
		addChild( sens[sens.length-1] );
		sens.push( new Library.cwfirecrash );
		addChild( sens[sens.length-1] );
		sens.push( new Library.cwfirealarm );
		addChild( sens[sens.length-1] );
		
		_spNm = createNm( _ind );
		this.addChild( _spNm );
	}
	public function type(t:int):void
	{
		
		sentype = t;
	}
	public function state(s:int):void
	{
		var len:int = sens.length;
		for (var i:int=0; i<len; i++) {
			sens[i].visible = false;
		}
		sens[s+sentype].visible = true;
	}
	public function setDry( dry:Boolean ):void
	{
		
		
		if( dry )
		{
			_spNm.parent.removeChild( _spNm );
			_spNm = createNm( _ind / 2 );
			this.addChild( _spNm );
		}
		else
		{
			_spNm.parent.removeChild( _spNm );
			_spNm = createNm( _ind  );
			this.addChild( _spNm );
		}
		
	}
	private function createNm( nm:int ):Sprite
	{
		const gdiam:int = 13;
		const clrLine:uint = 0x01bb0d;
		const clrBack:uint = 0x4eca56;
		const clrText:uint = 0x089311;
		
		
		const nmNb:SimpleTextField = new SimpleTextField(  nm + "", 30, clrText );
		
		nmNb.setTextFormat( new TextFormat( null, gdiam * 1.1, null, true, null, null, null, null, TextFormatAlign.CENTER ) );
		
		this.addChild( nmNb );
		
		
		const spr:Sprite = new Sprite();
		spr.graphics.beginFill( clrBack, .05 );
		spr.graphics.lineStyle( 3, clrLine, .6 );
		spr.graphics.drawCircle( ( gdiam / 2 ), ( gdiam / 2 ), gdiam );
		
		nmNb.y =  -5;
		nmNb.x = -9;
		
		
		spr.addChild( nmNb );
		spr.scaleX = spr.scaleY = .8;
		spr.y = -7;
		spr.x = 60;
		
		return spr;
	}
}
class WireAnalyzer
{
	public static const CUT:int = 0;
	public static const NORM:int = 1;
	public static const WARN_SECOND:int = 2;
	public static const WARN:int = 3;
	public static const ALARM:int = 4;
	public static const KZ:int = 5;
	
	private var sens:Vector.<Sensor>;
	
	public function add(v:Vector.<Sensor>):void
	{
		if(!sens)
			sens = v;
	}
	public function put(p:Package):void
	{
		
		var a:Array = OPERATOR.dataModel.getData( CMD.K5_ADC_TRESH );
		var len:int = p.length;
		for (var i:int=0; i<len; i++) {
			sens[i].update( getZone(a[i], p.getStructure(i+1)[0] ) );
		}
	}
	
	public function dryPut( p:Package ):void
	{
		
		var len:int = p.length;
		for (var i:int=0; i<len; i++) {
			sens[i].update( p.getStructure(i+1)[0] >=UIWireConfigK9.SHORT_CIRCUIT_DRY_WIRE?CUT:ALARM );
			
			
		}
	}
	
	public function update(a:Array, str:int):void
	{	 // обновить информацию по расположению лимитов
		
	}
	private function getZone(a:Array, value:int):int
	{
		var len:int = a.length;
		for (var i:int=0; i<len; i++) {
			if (value < a[i])
				return i;
		}
		return CUT;
	}
	
	
}