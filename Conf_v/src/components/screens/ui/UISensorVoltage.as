package components.screens.ui
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	import components.abstract.functions.loc;
	import components.abstract.servants.TabOperator;
	import components.basement.UI_BaseComponent;
	import components.events.AccEvents;
	import components.gui.fields.FSComboBox;
	import components.gui.fields.FSShadow;
	import components.gui.fields.FSSimple;
	import components.gui.limits.LimitGuideLineHU;
	import components.gui.limits.LimitUContainer;
	import components.gui.limits.VectorDrawScreenU;
	import components.gui.triggers.TextButton;
	import components.interfaces.IFocusable;
	import components.interfaces.IFormString;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.protocol.statics.OPERATOR;
	import components.static.CMD;
	import components.static.COLOR;
	import components.static.KEYS;
	import components.system.SavePerformer;
	
	public class UISensorVoltage extends UI_BaseComponent
	{
		public static const STATE_TIMER:int = 1000;
		public static const MAX_PERIOD:int = 300;
		public static const SIGNAL_RESOLUTION:int = 1;
		public static const GRAPH_WIDTH:int = 600;
		public static const GRAPH_HEIGHT:int = 200;
		private const VALUE_8V:Array = [8,10,12,14,16];
		private const VALUE_20V:Array = [20,22.5,25,27.5,30];
		private var vScreen:VectorDrawScreenU;
		
		private const LIMIT_VALUE:Array = [{max:1600, min:800},{max:3000, min:2000}];
		private var LIMIT_SWITCH:int;
		
		private var container:LimitUContainer;
		private var bRange0:TextButton;
		private var bRange1:TextButton;
		
		private var hLimits:Vector.<LimitGuideLineHU>;
		private var dragTarget:LimitGuideLineHU;
		private var lastTarget:LimitGuideLineHU;
		private var dragRectH:Rectangle;
		
		public function UISensorVoltage(group:int)
		{
			super();
			
			globalY += 10;
			toplevel = false;
			var shift:int = 580;
			globalFocusGroup = group;
			
			FLAG_SAVABLE = false;
			createUIElement( new FSSimple, 0, loc("sensor_engine_start"), null, 1 );
			attuneElement( shift-50, 150, FSSimple.F_CELL_NOTSELECTABLE | FSSimple.F_CELL_ALIGN_RIGHT );
			getLastElement().setCellInfo( loc("sensor_always_on") );
			FLAG_SAVABLE = true;
			
			createUIElement( new FSShadow, CMD.VR_VOLTAGE_SENSOR, "", null, 1 );
			
			//createUIElement( new FSShadow, CMD.VR_VOLTAGE_SENSOR, "", null, 2 );
			createUIElement( new FSComboBox, CMD.VR_VOLTAGE_SENSOR, loc("sensor_battery_low"), null, 2,
				[{label:loc("g_enabled_m"), data:1},{label:loc("g_disabled_m"), data:0}] );
			attuneElement( shift, NaN, FSComboBox.F_COMBOBOX_NOTEDITABLE );
			
			createUIElement( new FSShadow, CMD.VR_VOLTAGE_SENSOR, "", null, 3 );
			createUIElement( new FSShadow, CMD.VR_VOLTAGE_SENSOR, "", null, 4 );
			createUIElement( new FSShadow, CMD.VR_VOLTAGE_SENSOR, "", null, 5 );
			createUIElement( new FSShadow, CMD.VR_VOLTAGE_SENSOR, "", null, 6 );
			createUIElement( new FSShadow, CMD.VR_VOLTAGE_SENSOR, "", null, 7 );
			
			createUIElement( new FSSimple, CMD.VR_VOLTAGE_VALUE, loc("sensor_current_voltage"), null, 1 );
			attuneElement( shift + 50, 50, FSSimple.F_CELL_NOTSELECTABLE );
			(getLastElement() as FSSimple).setColoredBorder( COLOR.GREEN );
			
			FLAG_SAVABLE = false;
			createUIElement( new FSSimple, 0, loc("sensor_limit_charging_voyager")
				, null, 2 );
			attuneElement( shift + 50, 50, FSSimple.F_CELL_NOTSELECTABLE );
			(getLastElement() as FSSimple).setColoredBorder( COLOR.RED );
			
			createUIElement( new FSSimple, 0, loc("sensor_limit_alarm")
				, null, 3 );
			attuneElement( shift + 50, 50, FSSimple.F_CELL_NOTSELECTABLE );
			(getLastElement() as FSSimple).setColoredBorder( COLOR.BLUE );
			
			bRange0 = new TextButton;
			bRange0.setUp( loc("sensor_range_8_16"), callLogic, 2 );
			addChild( bRange0 );
			bRange0.x = globalX;
			bRange0.y = globalY;
			
			bRange1 = new TextButton;
			bRange1.setUp( loc("sensor_range_20_30"), callLogic, 3 );
			addChild( bRange1 );
			bRange1.x = globalX + 120;
			bRange1.y = globalY;
			
			globalY += 30;
			
			container = new LimitUContainer( GRAPH_WIDTH, GRAPH_HEIGHT, 5 );
			addChild( container );
			container.x = globalX + 20;
			container.y = globalY;
			container.alpha = 0.5;
			
			vScreen = new VectorDrawScreenU(COLOR.GREEN);
			addChild( vScreen );
			vScreen.setup( GRAPH_WIDTH/300 );
			vScreen.getFunction = getYByAcpForPaint;
			vScreen.x = container.x;
			vScreen.y = container.y;
			
			hLimits = new Vector.<LimitGuideLineHU>;
			dragRectH = new Rectangle(container.x,container.y,0,GRAPH_HEIGHT);
			for (var i:int=0; i<2; ++i) {
				hLimits[i] = new LimitGuideLineHU( GRAPH_WIDTH, COLOR.BLACK );
				hLimits[i].rect = dragRectH;
				hLimits[i].getFunction = getAcpByY;
				register( hLimits[i] );
			}
			
			this.height = 590;
			
			starterCMD = CMD.VR_VOLTAGE_SENSOR;
		}
		override public function open():void
		{
			super.open();
			stage.addEventListener( MouseEvent.MOUSE_UP, mUp );
		}
		override public function close():void
		{
			super.close();
			stage.removeEventListener( MouseEvent.MOUSE_UP, mUp );
			deactivateSpamTimer();
		}
		override public function put(p:Package):void
		{
			distribute( p.getStructure(), p.cmd );
			
			initSpamTimer( CMD.VR_VOLTAGE_VALUE, 1, true, null, STATE_TIMER );
			vScreen.clear();
			
			var a:Array = p.getStructure();
			
			LIMIT_SWITCH = a[2]; 
			if( a[2] == 0 )
				container.setup(VALUE_8V);
			else
				container.setup(VALUE_20V);
			
			var minU:int = a[2] == 0 ? a[3] : a[5];
			var maxU:int = a[2] == 0 ? a[4] : a[6];
			
			moveLine( hLimits[0], minU );
			moveLine( hLimits[1], maxU );
			
			if ( a[2] == 0 ) {
				getField( 0, 2).setCellInfo( a[3]/100 );
				getField( 0, 3).setCellInfo( a[5]/100 );
			} else {
				getField( 0, 2).setCellInfo( a[4]/100 );
				getField( 0, 3).setCellInfo( a[6]/100 );
			}
			
			bRange0.disabled = Boolean(a[2]==0);
			bRange1.disabled = Boolean(a[2]==1);
			
			colorizeHLimits(false);
			
			RequestAssembler.getInstance().fireEvent( new Request(CMD.VR_VOLTAGE_VALUE, processState, 1));
			
			loadComplete();
		}
		override protected function processState(p:Package):void 
		{
			super.processState(p);
			vScreen.paint( p.getStructure()[0] );
			getField( CMD.VR_VOLTAGE_VALUE, 1).setCellInfo( p.getStructure()[0]/100 );
		}
		private function register(d:DisplayObject):void
		{
			d.addEventListener( MouseEvent.MOUSE_DOWN, mDown );
			d.addEventListener( Event.SELECT, onSelect );
			addChild( d );
			d.x = container.x;
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
			dragTarget.startDrag(false, dragTarget.rect);
			dragTarget.addEventListener( AccEvents.onSharedGuideLineMove, limitMove );
			lastTarget = null;
		}
		private function onSelect(e:Event):void
		{
			var o:Object = e.currentTarget;
			
			lastTarget = e.currentTarget as LimitGuideLineHU;
			if (lastTarget)
				stage.addEventListener( KeyboardEvent.KEY_DOWN, keyDown );
			else
				stage.removeEventListener( KeyboardEvent.KEY_DOWN, keyDown );
			dragTarget = null;
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
			if (lastTarget)
				stage.addEventListener( KeyboardEvent.KEY_DOWN, keyDown );
			else
				stage.removeEventListener( KeyboardEvent.KEY_DOWN, keyDown );
			dragTarget = null;
		}
		private function limitMove(ev:Event):void
		{
			if (dragTarget)
				colorizeHLimits(true);
		}
		private function keyDown(ev:KeyboardEvent):void
		{
			if (lastTarget && TabOperator.getInst().currentFocus() == lastTarget) {
				var changed:Boolean = false;
				var shift:Number = LIMIT_SWITCH == 0 ? 0.5 : 1;
				
				switch(ev.keyCode) {
					case KEYS.UpArrow:
						if ( lastTarget.y - shift >= container.y ) {
							lastTarget.y -= shift;
							changed = true;
						} else if (lastTarget.y != container.y ) {
							lastTarget.y = container.y;
							changed = true;
						}
						break;
					case KEYS.DownArrow:
						if ( lastTarget.y < container.y + GRAPH_HEIGHT ) {
							lastTarget.y += shift;
							changed = true;
						} else if (lastTarget.y != container.y + GRAPH_HEIGHT) {
							lastTarget.y = container.y + GRAPH_HEIGHT;
							changed = true;
						}
						break;
				}
				if(changed) {
					lastTarget.updateCoords();
					colorizeHLimits(true);
				}
			}
		}
		private function colorizeHLimits(save:Boolean=true):void
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
			if (a) {
				a = a.sort( Array.NUMERIC );
				for (i=0; i<2; ++i) {
					getField( 0, i+2).setCellInfo( (getAcpByY( a[i] )/100).toString() );
				}
				if ( int(getField( CMD.VR_VOLTAGE_SENSOR, 3).getCellInfo()) == 0 ) {
					getField( CMD.VR_VOLTAGE_SENSOR, 4).setCellInfo( getAcpByY(a[0]) );
					getField( CMD.VR_VOLTAGE_SENSOR, 5).setCellInfo( getAcpByY(a[1]) );
				} else {
					getField( CMD.VR_VOLTAGE_SENSOR, 6).setCellInfo( getAcpByY(a[0]) );
					getField( CMD.VR_VOLTAGE_SENSOR, 7).setCellInfo( getAcpByY(a[1]) );
				}
				
				if (save)
					SavePerformer.remember( getStructure(), getField( CMD.VR_VOLTAGE_SENSOR, 1) ); 
			}
		}
		private function callLogic(num:int):void
		{
			var f:IFormString;
			var a:Array;
			switch(num) {
				case 2:
					bRange0.disabled = true;
					bRange1.disabled = false;
					f = getField( CMD.VR_VOLTAGE_SENSOR, 3);
					if ( int(f.getCellInfo()) != 0) {
						f.setCellInfo(0);
						SavePerformer.remember( getStructure(), f );
					}
					LIMIT_SWITCH = 0;
					container.setup(VALUE_8V);
					
					a = OPERATOR.dataModel.getData(CMD.VR_VOLTAGE_SENSOR)[0];
					
					moveLine( hLimits[0], a[3] );
					moveLine( hLimits[1], a[4] );
					
					hLimits[0].updateCoords();
					hLimits[1].updateCoords();
					colorizeHLimits(true);
					vScreen.clear();
					break;
				case 3:
					bRange0.disabled = false;
					bRange1.disabled = true;
					f = getField( CMD.VR_VOLTAGE_SENSOR, 3);
					if ( int(f.getCellInfo()) != 1) {
						f.setCellInfo(1);
						SavePerformer.remember( getStructure(), f );
					}
					LIMIT_SWITCH = 1;
					container.setup(VALUE_20V);
					
					a = OPERATOR.dataModel.getData(CMD.VR_VOLTAGE_SENSOR)[0];
					
					moveLine( hLimits[0], a[5] );
					moveLine( hLimits[1], a[6] );
					
					hLimits[0].updateCoords();
					hLimits[1].updateCoords();
					colorizeHLimits(true);
					vScreen.clear();
					break;
			}
		}
		private function moveLine(t:LimitGuideLineHU, value:Number):void
		{
			t.y = getYByAcp( Math.round(value) );
			t.updateCoords();
		}
		private function getYByAcp(acp:Number):Number
		{
			var coef:Number = GRAPH_HEIGHT/(LIMIT_VALUE[LIMIT_SWITCH].max-LIMIT_VALUE[LIMIT_SWITCH].min);
			var num:Number = (GRAPH_HEIGHT - ( acp-LIMIT_VALUE[LIMIT_SWITCH].min )*coef)+container.y;
			if (num < container.y || num > container.y + GRAPH_HEIGHT )
				num = container.y;
			return num;
		}
		private function getYByAcpForPaint(acp:Number):Number
		{
			var coef:Number = GRAPH_HEIGHT/(LIMIT_VALUE[LIMIT_SWITCH].max-LIMIT_VALUE[LIMIT_SWITCH].min);
			var num:Number = GRAPH_HEIGHT - ( acp-LIMIT_VALUE[LIMIT_SWITCH].min )*coef;
			if (num < 0 )
				num = 0;
			if (num > GRAPH_HEIGHT )
				num = GRAPH_HEIGHT;
			return num;
		}
		private function getAcpByY(ypos:Number):Number
		{
			var coef:Number = GRAPH_HEIGHT/(LIMIT_VALUE[LIMIT_SWITCH].max-LIMIT_VALUE[LIMIT_SWITCH].min);
			var num:Number = (GRAPH_HEIGHT-(ypos-container.y))/coef + LIMIT_VALUE[LIMIT_SWITCH].min;
			return num;
		}
		override public function addChild(child:DisplayObject):DisplayObject
		{
			if (child is IFocusable) {
				if (!isNaN(globalFocusGroup) )
					(child as IFocusable).focusgroup = globalFocusGroup;
				TabOperator.getInst().add(child as IFocusable);
			}
			return super.addChild(child);
		}
		/*private function doEnable(b:Boolean):void
		{
		getField( CMD.VR_VOLTAGE_SENSOR, 2 ).disabled = !b;
		}*/
	}
}