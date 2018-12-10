package components.screens.ui
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	import components.abstract.RegExpCollection;
	import components.abstract.functions.loc;
	import components.abstract.servants.TabOperator;
	import components.abstract.servants.TaskManager;
	import components.basement.UI_BaseComponent;
	import components.events.AccEvents;
	import components.gui.fields.FSCheckBox;
	import components.gui.fields.FSComboBox;
	import components.gui.fields.FSShadow;
	import components.gui.fields.FSSimple;
	import components.gui.fields.FormEmpty;
	import components.gui.fields.FormString;
	import components.gui.limits.LimitGuideLineHU;
	import components.gui.limits.VectorDrawScreenU;
	import components.interfaces.IFormString;
	import components.interfaces.ITask;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.static.CMD;
	import components.static.COLOR;
	import components.static.DS;
	import components.system.SavePerformer;
	import components.system.UTIL;
	
	public class UISensorTemperatureV2 extends UI_BaseComponent
	{
		public static const STATE_TIMER:int = 1000;
		public static const MAX_PERIOD:int = 300;
		public static const SIGNAL_RESOLUTION:int = 1;
		
		
		private const VALUE_8V:Array = [8,10,12,14,16];
		private const VALUE_20V:Array = [20,22.5,25,27.5,30];
		private const HEADER_FIRSTSCREEN:Number = 45;
		private var vScreen:VectorDrawScreenU;
		
		private const LIMIT_VALUE:Array = [{max:1600, min:800},{max:3000, min:2000}];
		private var LIMIT_SWITCH:int;
		
		
		private var fsCpu:FormEmpty;
		private var fsOuter:FSSimple;
		private var firstScreen:VectorScreen;
		
		private var speedTask:ITask;
		
		private var hiLimit:FSSimple;
		
		private var lowLimit:FSSimple;
		private var lastTarget:LimitGuideLineHU;
		private var dragTarget:LimitGuideLineHU;
		private var hLimits:Vector.<LimitGuideLineHU>;
		private var grafHeight:int;
		private var grafWidth:int;

		private var slowTask:ITask;

		private var slowScreen:VectorScreen;
		
		public function UISensorTemperatureV2(group:int=0)
		{
			super();
			
			toplevel = false;
			globalY += 10;
			globalFocusGroup = group;
			
			
			init();
		}
		
		private function init():void
		{
			
			const oneColWidth:int = 650;
			const thoColWidth:int = 80;
			
			if( !DS.isfam( DS.K5AA ) )
			{
				fsCpu = addui( new FSSimple, CMD.GET_TEMPERATURE, loc("ui_temp_cpu"), null, 1  ) as FormEmpty;
				attuneElement( oneColWidth, thoColWidth, FSSimple.F_CELL_NOTSELECTABLE );
				(fsCpu as FSSimple ).setColoredBorder( COLOR.GREEN );
				addMeasure( getLastElement() as IFormString );
				
				drawSeparator( oneColWidth + thoColWidth + 100);
			}
			else
			{
				fsCpu = addui( new FSShadow, CMD.GET_TEMPERATURE, "", null, 1  ) as FormEmpty;
			}
			
			
			fsOuter = addui( new FSSimple, CMD.GET_TEMPERATURE, loc("ui_temp_ext_sensor"), null, 2  ) as FSSimple;
			attuneElement( oneColWidth, thoColWidth, FSSimple.F_CELL_NOTSELECTABLE );
			fsOuter.setColoredBorder( COLOR.RED );
			addMeasure( getLastElement() as IFormString );
			
			if( !DS.isVoyager() || DS.isDevice( DS.K16 ) || DS.isfam( DS.K9 ))
			{
				const list:Array = [];
				list.push( { data:0, label:loc("g_no"), select:true } );
				for (var j:int=1; j<= 32; j++) 
				{
					list.push( { data:j, label:j } );	
				}
				
				addui( new FSComboBox, CMD.SAVE_CID_TEMPERATURE, loc( "save_changes_temperature_more" ), null, 1, list );
				attuneElement( oneColWidth, thoColWidth );
				addMeasure( getLastElement() as IFormString );
			}
			
			
			
			var label:String = loc("g_event") + ' "' + loc( "vhis_179" ) + '" ';
			hiLimit = addui( new FSSimple, CMD.LIMITS_TEMP, label , updatePos, 2, null, "0-9 \\-", 3, new RegExp( RegExpCollection.REF_000to127 )  )  as FSSimple;
			attuneElement( oneColWidth, thoColWidth, FSSimple.F_CELL_NOTSELECTABLE );
			hiLimit.setColoredBorder( COLOR.RED );
			addMeasure( getLastElement() as IFormString );
			
			
			label = loc("g_event") + ' "' + loc( "vhis_180" ) + '" ';
			lowLimit = addui( new FSSimple, CMD.LIMITS_TEMP, label , updatePos, 1, null, "0-9 \\-", 3, new RegExp( RegExpCollection.REF_000to127 )   ) as FSSimple;
			attuneElement( oneColWidth, thoColWidth , FSSimple.F_CELL_NOTSELECTABLE );
			addMeasure( getLastElement() as IFormString );
			lowLimit.setColoredBorder( COLOR.GREEN );
			
			drawSeparator( oneColWidth + thoColWidth + 100);
			
			firstScreen = new VectorScreen(loc("ui_temp_update_5sec"), false);
			addChild( firstScreen );
			firstScreen.y = globalY + 10;
			firstScreen.x = ( ( oneColWidth + thoColWidth ) - firstScreen.width ) / 2;
			grafHeight = firstScreen.height;
			grafWidth = firstScreen.width - 95;
			
			hLimits = new Vector.<LimitGuideLineHU>;
			const dragRectH:Rectangle = new Rectangle( firstScreen.x + 80, firstScreen.y + HEADER_FIRSTSCREEN,0, firstScreen.height - HEADER_FIRSTSCREEN );
			for (var i:int=0; i<2; ++i) {
				hLimits[i] = new LimitGuideLineHU( grafWidth, COLOR.BLACK );
				hLimits[i].rect = dragRectH;
				hLimits[i].getFunction = getAcpByY;
				register( hLimits[i] );
				hLimits[ i ].customMeasure = loc( "measure_degree_m" );
			}
			
			globalY += firstScreen.height;
			
			slowScreen = new VectorScreen(loc("ui_temp_update_2min"), false);
			addChild( slowScreen );
			slowScreen.y = globalY + 40;
			slowScreen.x = ( ( oneColWidth + thoColWidth ) - slowScreen.width ) / 2;
			grafHeight = slowScreen.height;
			grafWidth = slowScreen.width - 95;
			
			starterCMD = [ CMD.GET_TEMPERATURE, CMD.LIMITS_TEMP ];
			
			if( !DS.isVoyager()  )starterCMD.push(  CMD.SAVE_CID_TEMPERATURE  );
			
			manualResize();
			
		}
		
		private function updatePos(iForm:IFormString):void
		{
			
			const value:int = int( iForm.getCellInfo());
			
			if( value < VectorScreen.BOTTOM_VALUE || value > VectorScreen.SIZE_SCALE + VectorScreen.BOTTOM_VALUE ) return;
			const isHi:Boolean = ( iForm == hiLimit );
			
			var currentLine:LimitGuideLineHU;
			
			if( isHi )
				if( hLimits[ 0 ].y < hLimits[ 1 ].y ) currentLine = hLimits[ 0 ];
				else currentLine = hLimits[ 1 ];
			else
				if( hLimits[ 0 ].y > hLimits[ 1 ].y ) currentLine = hLimits[ 0 ];
				else currentLine = hLimits[ 1 ];
			
			
			
			currentLine.y = getYByAcp( Math.round(value) );
			currentLine.updateCoords();
			colorizeHLimits( false, false );
		}
		
		private function register(d:DisplayObject):void
		{
			const rect:Rectangle = ( d as LimitGuideLineHU ).rect;
			d.addEventListener( MouseEvent.MOUSE_DOWN, mDown );
			d.addEventListener( Event.SELECT, onSelect );
			addChild( d );
			d.x = rect.x;
			d.y = rect.y;
		}
		
		private function unregister(d:DisplayObject):void
		{
			d.removeEventListener( MouseEvent.MOUSE_DOWN, mDown );
			d.removeEventListener( Event.SELECT, onSelect );
		}
		
		private function onSelect(e:Event):void
		{
			/*var o:Object = e.currentTarget;
			
			lastTarget = e.currentTarget as LimitGuideLineHU;
			if (lastTarget)
				stage.addEventListener( KeyboardEvent.KEY_DOWN, keyDown );
			else
				stage.removeEventListener( KeyboardEvent.KEY_DOWN, keyDown );
			dragTarget = null;*/
		}
		
		private function mDown(e:MouseEvent):void
		{
			dragTarget = e.currentTarget as LimitGuideLineHU;
			
			
			if (dragTarget is LimitGuideLineHU && dragTarget.limit > dragTarget.mouseX) {
				dragTarget = null;
				return;
			}
			TabOperator.getInst().iNeedFocus(dragTarget);
			
			dragTarget.select = true;
			if (lastTarget && dragTarget != lastTarget)
				lastTarget.select = false;
			
			setChildIndex( dragTarget, this.numChildren-1 );
			dragTarget.dragging = true;
			dragTarget.addEventListener( AccEvents.onSharedGuideLineMove, limitMove );
			dragTarget.startDrag(false, dragTarget.rect);
			
			stage.addEventListener( MouseEvent.MOUSE_UP, mUp );
			
			lastTarget = null;
		}
		
		private function mUp(e:MouseEvent):void
		{
			if (dragTarget) {
				dragTarget.dragging = false;
				dragTarget.stopDrag();
				dragTarget.updateCoords();
				colorizeHLimits(true);
				dragTarget.removeEventListener( AccEvents.onSharedGuideLineMove, limitMove );
			} else {
				if (lastTarget)
					lastTarget.select = false;
			}
			lastTarget = dragTarget;
			/*if (lastTarget)
				stage.addEventListener( KeyboardEvent.KEY_DOWN, keyDown );
			else
				stage.removeEventListener( KeyboardEvent.KEY_DOWN, keyDown );
			dragTarget = null;*/
			
			stage.removeEventListener( MouseEvent.MOUSE_UP, mUp );
		}
		
		private function limitMove(ev:Event):void
		{
			
			if (dragTarget)
				colorizeHLimits(true);
		}
		
		private function getYByAcp(acp:Number):Number
		{
			
			const relHeight:Number = firstScreen.height - HEADER_FIRSTSCREEN;
			const oneDegree:Number = relHeight / VectorScreen.SIZE_SCALE;
			const negative:Number = acp * oneDegree ;
			const pos:Number = ( firstScreen.y +  firstScreen.height )  - ( negative + HEADER_FIRSTSCREEN );
			
			
			
			
			return corrPos( pos );

			
			function corrPos( pos:Number ):Number
			{
				
				while( getAcpByY( pos )  < acp * 100 ) 
								pos = corrPos( pos - 1 );
					 
				return pos;
				
			}

		}
		
		private function getAcpByY(ypos:Number):Number
		{
			
			const relHeight:int = grafHeight - HEADER_FIRSTSCREEN;
			const relPos:Number = relHeight - ( ypos - firstScreen.y - HEADER_FIRSTSCREEN );
			
			const num:int = ( VectorScreen.SIZE_SCALE * ( relPos / relHeight ) ) + VectorScreen.BOTTOM_VALUE;
			
			return num * 100;
			
		}
		
		override public function open():void
		{
			super.open();
			loadComplete();
			
			speedTask = TaskManager.callLater( onSpeedTick, TaskManager.DELAY_1SEC*5 );
			slowTask = TaskManager.callLater( onTick, TaskManager.DELAY_2MIN );
			var d:Date = new Date;
			
			firstScreen.currentHour = d.hours + 1;
			if (firstScreen.currentHour > 23)
				firstScreen.currentHour -= 24;
			firstScreen.currentMinute = UTIL.fz(d.minutesUTC,2);
			firstScreen.open();
			
			slowScreen.currentHour = d.hours + 1;
			if (slowScreen.currentHour > 23)
				slowScreen.currentHour -= 24;
			slowScreen.currentMinute = UTIL.fz(d.minutesUTC,2);
			slowScreen.open();
			
			
			
		}
		
		
		
		override public function close():void
		{
			super.close();
			
			
			
			
		}
		
		
		override public function put(p:Package):void
		{
			var res:Number;
			switch( p.cmd ) 
			{
				case CMD.GET_TEMPERATURE:
					
					res = comb(int(VectorScreen.toSignedLitleEndian(p.getStructure(1))));
					
					if( !DS.isfam( DS.K5A ))
					{
						if ( !isNaN(res) ) {
							fsCpu.setCellInfo(res);
						} else {
							fsCpu.setCellInfo(loc("g_nodata"));
						}
					}
					
					if (fsOuter) {
						res = comb(int(VectorScreen.toSignedLitleEndian(p.getStructure(2))));
						if ( !isNaN(res) ) {
							fsOuter.setCellInfo(res);
						} else {
							fsOuter.setCellInfo(loc("g_nodata"));
						}
					}
					
					firstScreen.put( p );
					loadComplete();
					
					break;
				
				case CMD.LIMITS_TEMP:
					res = comb(int(VectorScreen.toSignedLitleEndian( [ p.getParam( 1, 1 ) ])) );
					
					if ( !isNaN(res) ) {
						lowLimit.setCellInfo(res);
					} else {
						lowLimit.setCellInfo(loc("g_nodata"));
					}
					
					moveLine( hLimits[0], res );
					
					
					
					res = comb(int(VectorScreen.toSignedLitleEndian( [ p.getParam( 2, 1 ) ])));
					
					if ( !isNaN(res) ) {
						hiLimit.setCellInfo(res);
					} else {
						hiLimit.setCellInfo(loc("g_nodata"));
					}
					
					moveLine( hLimits[1], res );
					
					
					
					break;
				
				
				default:
					pdistribute( p );		
					break;
			}
			//RequestAssembler.getInstance().fireEvent( new Request( CMD.ENGIN_NUMB, putEngineNum ) );
			
			function comb(value:int):Number
			{
				if (UTIL.mod(value) == 128)
					return NaN;
				/*if(value > 90)
					return 90;
				if (value < -30)
					return -30;*/
				return value;
			}
			
		}
		
		private function moveLine(t:LimitGuideLineHU, value:Number):void
		{
			t.y = getYByAcp( Math.round(value) );
			t.updateCoords();
			colorizeHLimits( false );
		}
		
		private function onSlowTick():void
		{
			// TODO Auto Generated method stub
			
		}
		
		private function addMeasure( elt:IFormString ):void
		{
			const yy:int = globalY;
			const xx:int = globalX;
			const space:int = 10;
			
			const measure:IFormString = addui( new FormString, 0, loc( "measure_degree_m" ), null, 1 );
			measure.y = elt.y;
			measure.x = elt.x + elt.width + space;
			
			globalY = yy;
			globalX = xx;
			
			
		}
		
		private function colorizeHLimits(save:Boolean=true, refresh:Boolean = true):void
		{
			var max:LimitGuideLineHU;
			var min:LimitGuideLineHU;
			var a:Array = [];
			for (var i:int=0; i<2; ++i) {
				hLimits[i].color = COLOR.BLUE;
				if (!max || max.y < hLimits[i].y)
					max = hLimits[i];
				if (!min || min.y > hLimits[i].y)
					min = hLimits[i];
				if (a)
					a.push(hLimits[i].y);
			}
			min.color = COLOR.RED;
			max.color = COLOR.BLUE;
			
			if( refresh ) upCellsLimit( a, save );
			
		}
		
		private function upCellsLimit( a:Array, save:Boolean = true ):void
		{
			if( !a.length ) return;
			
			if (a) 
			{
				a.sort( Array.NUMERIC );
				a = a.reverse();
				
				for (var i:int = 0; i < 2; i++ ) 
				{
					getField( CMD.LIMITS_TEMP, i + 1).setCellInfo( (getAcpByY( a[i] )/100).toString() );
				}
				
				if (save)
				{
					SavePerformer.remember( getStructure(), getField( CMD.LIMITS_TEMP, 1) ); 
					SavePerformer.remember( getStructure(), getField( CMD.LIMITS_TEMP, 2) ); 
				}
				
			}
		}
		
		private function slowPut(p:Package):void
		{
			slowScreen.put(p);
		}
		private function onTick():void
		{
			if (this.visible) {
				slowTask.repeat();
				RequestAssembler.getInstance().fireEvent( new Request(CMD.GET_TEMPERATURE, slowPut));
			}
		}
		private function onSpeedTick():void
		{
			if (this.visible) {
				speedTask.repeat();
				RequestAssembler.getInstance().fireEvent( new Request(CMD.GET_TEMPERATURE, put));
			}
		}
		
		
	}
}
import components.abstract.functions.loc;
import components.basement.UI_BaseComponent;
import components.gui.SimpleTextField;
import components.gui.fields.FormString;
import components.gui.limits.LimitHRuler;
import components.gui.limits.LimitVContainer;
import components.gui.limits.VectorDrawScreenU;
import components.protocol.Package;
import components.static.COLOR;
import components.static.DS;
import components.system.UTIL;

class VectorScreen extends UI_BaseComponent
{
	
	public static var SIZE_SCALE:int;
	public static var BOTTOM_VALUE:int;
	public var currentHour:int;
	public var currentMinute:String;
	
	private var tTemperature:SimpleTextField;
	private var vScreenCpu:VectorDrawScreenU;
	private var vScreenOuter:VectorDrawScreenU;
	private var graphxshift:Number;
	private var hruler:LimitHRuler;
	
	private const GRAPH_WIDTH:int = 600;
	private const GRAPH_HEIGHT:int = 200;
	//private const LIMIT_MAX:int = 105;
	private const LIMIT_MAX:int = 120;
	private const LIMIT_MIN:int = 0;
	
	private var graphStep:Number;
	
	public function VectorScreen(title:String, timeline:Boolean=true)
	{
		addui( new FormString, 0, title, null, 4 ).x = globalX + 60;
		attuneElement( 600 );
		
		var titles:Array  = [];
		
		
		const step:int = 15;
		const len:int = 9;
		var ttl:int = step * ( len - 3 );
		
		/// На этот размер шкалы будут ориентироваться маркеры для установки
		/// текущего выбранного пользователем целевого относительного значения 
		SIZE_SCALE = ttl;
		
		for (var i:int=0; i< len ; i++) 
		{
			
			titles.push( { title: ttl + "" } );
			ttl -= step;
		}
		
		
		
		
		/// Это минимальное значение относительных единиц указанных на шкале
		/// оно может быть ниже нуля
		BOTTOM_VALUE = ttl + step;
		SIZE_SCALE -= BOTTOM_VALUE;
		
		//var container:LimitVContainer = new LimitVContainer([{title:"-30"},{title:"-15"},{title:"0"},{title:"15"},{title:"30"},{title:"45"},{title:"60"},{title:"75"}].reverse(),GRAPH_WIDTH, GRAPH_HEIGHT);
		var container:LimitVContainer = new LimitVContainer( titles, GRAPH_WIDTH, GRAPH_HEIGHT);
		addChild( container );
		container.y = globalY;
		container.x = globalX + 50;
		container.alpha = 0.5;
		
		tTemperature = new SimpleTextField(loc("ui_temp_degree"),0,COLOR.SATANIC_INVERT_GREY);
		tTemperature.height = 30;
		addChild( tTemperature );
		tTemperature.y = globalY + 164;
		tTemperature.x = 10;
		tTemperature.rotationZ = -90;
		
		var gear:Object = {w:GRAPH_WIDTH, h:GRAPH_HEIGHT, max_period:300, signal_resolution:1};
		graphStep = GRAPH_WIDTH/gear.max_period;
		
		vScreenCpu = new VectorDrawScreenU(COLOR.GREEN,gear);
		addChild( vScreenCpu );
		vScreenCpu.setup( graphStep );
		vScreenCpu.getFunction = getYByAcpForPaint;
		vScreenCpu.fGetGlobalXShift = getXShift;
		vScreenCpu.x = globalX + 50;
		vScreenCpu.y = globalY;
		
		if ( DS.isfam(DS.K5 ) || DS.isDevice(DS.V2) ||  DS.isDevice( DS.K16) ) {
			vScreenOuter = new VectorDrawScreenU(COLOR.RED,gear);
			addChild( vScreenOuter );
			vScreenOuter.setup( graphStep );
			vScreenOuter.getFunction = getYByAcpForPaint;
			vScreenOuter.fGetGlobalXShift = getXShift;
			vScreenOuter.x = globalX + 50;
			vScreenOuter.y = globalY;
		}
		
		globalY += GRAPH_HEIGHT + 1;
		
		hruler = new LimitHRuler(rename);
		addChild( hruler );
		hruler.y = globalY;
		hruler.x = globalX + 50;
		hruler.alpha = 0.5;
		hruler.visible = timeline;
		if (timeline)
			height = globalY + 50;
		else
			height = globalY;
	}
	override public function open():void
	{
		super.open();
		graphxshift = 0;
		
		hruler.build(rename(false),GRAPH_WIDTH);
		if (vScreenOuter)
			vScreenOuter.clear();
		vScreenCpu.clear();
	}
	override public function put(p:Package):void
	{
		var res:Number = comb(int(toSignedLitleEndian(p.getStructure(1))));
		
		if ( !isNaN(res) )
			vScreenCpu.paint( res );
		else
			vScreenCpu.endFill();
		if (vScreenOuter) {
			res = comb(int(toSignedLitleEndian(p.getStructure(2))));
			if ( !isNaN(res) )
				vScreenOuter.paint( res );
			else
				vScreenOuter.endFill();
		}
		if (vScreenCpu.isFull())
			hruler.move( graphStep );
		graphxshift += graphStep;
		
		function comb(value:int):Number
		{
			if (UTIL.mod(value) == 128)
				return NaN;
			if(value > 90)
				return 90;
			if (value < -30)
				return -30;
			return value;
		}
	}
	private function getYByAcpForPaint(rawacp:Number):Number
	{
		
		var acp:int = rawacp + 30;
		var coef:Number = GRAPH_HEIGHT/(LIMIT_MAX-LIMIT_MIN);
		var num:Number = GRAPH_HEIGHT - ( acp-LIMIT_MIN )*coef;
		if (num < 0 )
			num = 0;
		if (num > GRAPH_HEIGHT )
			num = GRAPH_HEIGHT;
		return num;
	}
	private function getXShift():Number
	{
		return graphxshift;
	}
	private function rename(increase:Boolean=true):Array
	{
		if (increase)
			currentHour = eva(currentHour);
		
		var a:Array = new Array;
		var h:int = currentHour;
		for (var i:int=0; i<6; i++) {
			a.push( {title:UTIL.fz(h,2) + ":"+currentMinute} );
			h = eva(h);
		}
		return a;
		function eva(value:int):int
		{
			var v:int = value + 2;
			if (v > 23)
				v -= 24;
			return v;
		}
	}
	public static function toSignedLitleEndian(arr:Array ):String
	{
		var need_invert:Boolean = false;
		if( (arr[ arr.length-1 ] & (0xf << 7)) > 0 )
			need_invert = true;
		
		var value:int=0;
		var len:int = arr.length;
		for(var k:int=0; k<len; ++k) {
			value |= arr[k] << k*8;
		}
		
		if (need_invert) {
			var mask:int;
			for(k=0; k<len; ++k) {
				mask |= 0xFF << 8*k
			}
			return "-"+((value ^ mask)+1);
		}
		return value.toString();
	}
}