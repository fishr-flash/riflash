package components.screens.ui
{
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	
	import components.abstract.GroupOperator;
	import components.abstract.functions.loc;
	import components.abstract.servants.TaskManager;
	import components.abstract.servants.WireServantK5;
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
	
	public class UIWireConfigK5 extends UI_BaseComponent
	{
		public static var isDryWire:Boolean;
		
		private const fireArray:Array  = [ {label:loc("k5_wire_cut"),color:0x1C75BC}, {label:loc("k5_wire_norm"),color:0x39B54A},
			{label:loc("k5_wire_warn"),color:0xC49A6C},{label:loc("k5_wire_alarm"),color:0x9E1F63},
			{label:loc("k5_wire_short_circuit"),color:0xF15A29}];;
		private const resArray:Array  = [ {label:loc("k5_wire_cut"),color:0x1C75BC}, {label:loc("k5_wire_both_open"),color:0x39B54A},
			{label:loc("k5_wire_closed_open"),color:0xC49A6C},{label:loc("k5_wire_open_closed"),color:0xF7941E},
			{label:loc("k5_wire_both_closed"),color:0x9E1F63},{label:loc("k5_wire_short_circuit"),color:0xF15A29}];
		private var drywire:Bitmap;
		private var reswire:Sprite;
		private var panel:LevelPanelWire;
		private var white:Sprite;
		private var sens:Vector.<Sensor>;
		private var dim:Array = [60,247,438,627,60,247,438,627];
		private var wa:WireAnalyzer;
		private var task:ITask;
		private var btns:Vector.<TextButton>;
		private var go:GroupOperator;
		private var title:SimpleTextField;
		
		public function UIWireConfigK5()
		{
			super();
			
			wa = new WireAnalyzer;
			
			drywire = new Library.cw8sensors;
			addChild( drywire );
			drywire.x = 50;
			drywire.y = 10;
			drywire.visible = false;

			reswire = new Sprite();
			reswire.addChild( new Library.cw16sensors );
			addChild( reswire );
			reswire.x = 50;
			reswire.y = 10;
			reswire.visible = false;
			
			shudowBadLabels( reswire as Sprite );
			
			
			var srv:WireServantK5 = new WireServantK5;
			srv.edges( 0x01e,0x3ff );
			
			sens = new Vector.<Sensor>;
			for (var i:int=0; i<8; i++) {
				sens.push( new Sensor(i) );
				addChild( sens[i] );
				sens[i].x = dim[i];
				if (i < 4)
					sens[i].y = 13;
				else
					sens[i].y = 426;
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
			panel.y = 270;
			
			
			
			if( DS.isfam( DS.K5,  DS.K5, DS.K53G, DS.K5AA, DS.A_BRD   ) )
			{
				this.addChild( new Shield );
				globalY = 350;
			}
			else
			{
				globalY = 580;	
			}
			
			
			
			
			go = new GroupOperator;
			go.add( "1", drawSeparator(775) );
			
			btns = new Vector.<TextButton>(2);
			btns[0] = new TextButton;
			addChild( btns[0] );
			btns[0].setUp(loc("k5_wire_note_res1"), onDefaults, 1 );
			btns[0].x = globalX;
			btns[0].y = globalY;
			globalY += 30;
			
			btns[1] = new TextButton;
			addChild( btns[1] );
			btns[1].setUp(loc("k5_wire_note_res2"), onDefaults, 2 );
			btns[1].x = globalX;
			btns[1].y = globalY;
			
			go.add( "1",btns[0] );
			go.add( "1",btns[1] );
			
			height = 690;
			width = 800;
			
			
			
			starterCMD = [CMD.K5_PART_PARAMS, CMD.K5_BIT_SWITCHES, CMD.K5_ADC_TRESH, CMD.K5_ADC_GET];
			/*if (!OPERATOR.dataModel.getData(CMD.K5_AWIRE_PART_CODE))
				(starterCMD as Array).splice( 0,0, CMD.K5_AWIRE_PART_CODE );*/
			/*if (!OPERATOR.dataModel.getData(CMD.K5_AWIRE_TYPE))
				(starterCMD as Array).splice( 0,0, CMD.K5_AWIRE_TYPE );*/
			
			starterRefine(CMD.K5_AWIRE_PART_CODE);
			starterRefine(CMD.K5_AWIRE_TYPE);
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
				case CMD.K5_BIT_SWITCHES:
					isDryWire = UTIL.isBit(7, p.getStructure()[2]);
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
					var a:Array = OPERATOR.dataModel.getData(CMD.K5_PART_PARAMS);
					var wire:Array = OPERATOR.dataModel.getData(CMD.K5_AWIRE_PART_CODE)[0];
					var wirestateraw:int = OPERATOR.dataModel.getData(CMD.K5_AWIRE_TYPE)[0][0];
					var wstate:int = (wirestateraw >> 8) | ((wirestateraw & 0x00FF) << 8 );
					
					var len:int = sens.length;
					for (var i:int=0; i<len; i++) {
						
						if (isDryWire) {
							sens[i].init(true, a[wire[i]][5] == 1 );
						} else
							sens[i].init(false, a[wire[i*2]][5] == 1, UTIL.isBit(i*2,wstate), UTIL.isBit(i*2+1,wstate) );
					}
					loadComplete();
					break;
				case CMD.K5_ADC_GET:
					wa.put(p);
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
			if (!panel.visible || panel.visible && panel.structureID-1 != n ) {
				a = OPERATOR.dataModel.getData(CMD.K5_ADC_TRESH);
				if (isfire)
					panel.build( fireArray );
				else
					panel.build( resArray );
				
				//var thresh:Array = a[n].slice().reverse();
				var thresh:Array = a[n].slice();
				/*if (!isfire)
					thresh.splice(0,0,30);*/
				
				panel.put(thresh);
				panel.changeStructure( n+1 );
				
				v = true;
				panel.visible = true;
				panel.parent.addChild( panel );
				
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
			//var a:Array = OPERATOR.dataModel.getData(CMD.K5_PART_PARAMS);
			// Если надо будет поправить шлейфы
			
			var diffs:Array;
			if( n == 1 )
				diffs = [ 30,470,610,806,1009 ];
			else
				diffs = [ 30,288,582,738, 1006 ];
					
			
			for (var i:int=0; i<8; i++) {
				RequestAssembler.getInstance().fireEvent( new Request(CMD.K5_ADC_TRESH,put,i+1, diffs ));
			}
			
			loadStart();
		}
		
		private function shudowBadLabels( screen:Sprite ):void
		{
			const coords:Array =
				[
					[ 18,1 ],
					[ 18, 51 ],
					[ 205,1 ],
					[ 205,51 ],
					[ 395,1 ],
					[ 395,51 ],
					[ 585,1 ],
					[ 585,51 ],
					
				];
			var len:int = coords.length;
			for (var i:int=0; i<len; i++) 
			{
				const spr:Sprite = createSh();
				spr.addChild( createNm( i%2?2:1 ) );
				spr.x = coords[ i ][ 0 ];
				spr.y = coords[ i ][ 1 ];
				spr.scaleX = spr.scaleY = 1.05;
				screen.addChild( spr );
			}
			
			
			
			function createSh():Sprite
			{
				
				const shd:Sprite = new Sprite;
				shd.graphics.beginFill( 0xFFFFFF, 1 );
				shd.graphics.drawRect( 0, 0, 45, 14 );
				
				return shd;
			}
			
			function createNm( nm:int = 1 ):SimpleTextField
			{
				const txt:String = "R" + nm +", k" + String.fromCharCode( 0x2126 );
				const lbl:SimpleTextField = new SimpleTextField( txt );
				lbl.setSimpleFormat( "left", 0, 10, true );
				/*const tf:TextFormat = new TextFormat( null, 10, null, true );
				lbl.defaultTextFormat = tf;*/
				
				lbl.text = txt;
				return lbl;
			}
		}
	}
}
import flash.display.Bitmap;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.Event;

import mx.core.UIComponent;

import components.abstract.functions.loc;
import components.events.GUIEvents;
import components.gui.SimpleTextField;
import components.gui.triggers.TextButton;
import components.protocol.Package;
import components.protocol.statics.OPERATOR;
import components.static.CMD;
import components.system.Library;
import components.system.UTIL;

class Sensor extends UIComponent
{
	public var num:int;
	
	private var bConfig:TextButton;
	private var title:SimpleTextField;
	
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
		
		s1 = new SensorVisual;
		addChild( s1 );
		s2 = new SensorVisual;
		addChild( s2 );

		bConfig = new TextButton;
		addChild( bConfig );
		wiretitle = loc("k5_wire_config")+" " + (num*2+1) + ","+(num*2+2);
		bConfig.setUp( loc("k5_wire_config_0d0a")+" " + (num*2+1) + ","+(num*2+2), onClick );
		
		title = new SimpleTextField( loc("rfd_wire")+" "+(num+1) );
		addChild( title );
		title.setSimpleFormat("left",0,14);
		title.width = 120;
		title.height = 30;
		title.y = 13;
		
		if (n<4) {
			s1.x = 60;
			s2.x = 60;
			s2.y = 50;
			bConfig.y = 85;
			title.y = 85;
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
		title.visible = dry;
		
		isfire = isFire;
		stateNormalClosed1 = normalclosed1;
		stateNormalClosed2 = normalclosed2;
		
		isdry = dry;
		
		s2.visible = !dry;
		s1.y = dry ? s1yposalone : s1ypos;
			
		s1.type( isFire ? SensorVisual.FIRE : SensorVisual.RES );
		s1.state(SensorVisual.NORM);
		
		s2.type( isFire ? SensorVisual.FIRE : SensorVisual.RES );
		s2.state(SensorVisual.NORM);
	}
	public function update(t:int):void
	{
		
		if (isdry) {
			/** DRY			*********************/
			
			// выяснить нормальное положение шлейфа
			var a:Array = OPERATOR.dataModel.getData(CMD.K5_AWIRE_TYPE);
			var bit:int = a[0][0] >> 8;
			var b:Boolean = UTIL.isBit(num,bit);
			
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
					s1.state( stateNormalClosed1 ? SensorVisual.ALARM : SensorVisual.NORM );
					s2.state( stateNormalClosed2 ? SensorVisual.ALARM : SensorVisual.NORM );
					break;
				case WireAnalyzer.WARN:
					s1.state( stateNormalClosed1 ? SensorVisual.ALARM : SensorVisual.NORM );
					s2.state( stateNormalClosed2 ? SensorVisual.NORM : SensorVisual.ALARM );					
					break;
				case WireAnalyzer.WARN_SECOND:
					s1.state( stateNormalClosed1 ? SensorVisual.NORM : SensorVisual.ALARM );
					s2.state( stateNormalClosed2 ? SensorVisual.ALARM : SensorVisual.NORM );
					break;
				case WireAnalyzer.ALARM:
					s1.state( stateNormalClosed1 ? SensorVisual.NORM : SensorVisual.ALARM);
					s2.state( stateNormalClosed2 ? SensorVisual.NORM : SensorVisual.ALARM );
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
	
	public function SensorVisual()
	{
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

class Shield extends Shape
{
	public function Shield()
	{
		
		
		drawSquare();
	}
	
	private function drawSquare():void
	{
		
		
		this.graphics.beginFill( 0xFFFFFF, 1 );
		this.graphics.drawRect( 380, 258, 285, 45 );
		this.graphics.beginFill( 0x25803c, 1 );
		this.graphics.drawRect( 225, 293, 155.5, 9.5 );
		this.graphics.beginFill( 0xFFFFFF, 1 );
		this.graphics.drawRect( 200, 258, 62, 65 );
		this.graphics.beginFill( 0xFFFFFF, 1 );
		this.graphics.drawRect( 40, 300, 730, 280 );
		
	}
}