package components.gui.visual.wire
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.geom.Rectangle;
	
	import mx.core.UIComponent;
	
	import components.abstract.Utility;
	import components.abstract.functions.loc;
	import components.gui.SimpleTextField;
	import components.gui.fields.FSShadow;
	import components.gui.triggers.TextButton;
	import components.interfaces.IFormString;
	import components.screens.ui.UIWire;
	import components.system.UTIL;
	
	public final class WirePanel extends UIComponent
	{
		public var f:Function;
		
		private static var globalWidth:int = 611;
		private static var coeff:Number;
		
		private var tError:SimpleTextField;
		private var bRevert:TextButton;
		
		private var fields:Array;
		private var hashStructToArr:Object = {1:0, 2:0, 3:1, 4:2, 5:3, 6:4, 7:5 };
		private var isNeedControl:Boolean = true;
		
		private function calcAcpToX(acp:int):int
		{
			var c:Number = globalWidth/(UIWire.MAX_LEVEL_ACP - UIWire.MIN_LEVEL_ACP);
			return (acp-UIWire.MIN_LEVEL_ACP)*c;
		}
		private function calcXtoAcp(x:int):int
		{
			var c:Number = globalWidth/(UIWire.MAX_LEVEL_ACP - UIWire.MIN_LEVEL_ACP);
			return x/c+UIWire.MIN_LEVEL_ACP;
		}
		
		private var thresholds:Vector.<WireThreshold>;
		private var mainUnit:WireUnitBig;
		private var rect:Rectangle;
		private var measure_unit:String;
		
		public function WirePanel(_measure:String, _fields:int=7)
		{
			super();
			thresholds = new Vector.<WireThreshold>;
			
			measure_unit = _measure;
			
			mainUnit = new WireUnitBig(0xff0000);
			addChild( mainUnit );
			mainUnit.y = -20;
			
			tError = new SimpleTextField(loc("level_wrong_values"));
			addChild( tError );
			tError.x = 192;
			
			bRevert = new TextButton;
			addChild( bRevert );
			bRevert.x = 181;
			bRevert.y = 15;
			bRevert.setUp( loc("level_return_defaults"), onRevert );
			
			rect = new Rectangle;
			rect.x = 0;
			rect.y = 0;
			rect.height = 0;
			
			this.height = 110;
			
			fields = new Array;
			for(var i:int; i<_fields; ++i) {
				fields.push( new FSShadow() );				
			}
		}
		public function getFields():Array
		{
			return fields;
		}
		protected function fireChange():void
		{
			var levels:Array = new Array;
			for(var key:String in fields ) {
				if( (fields[key] as IFormString).param == 7 ) {
					levels.push( UIWire.MAX_LEVEL_ACP );
					continue;
				}
				if( (fields[key] as IFormString).param == 1 ) {
					levels.push( UIWire.MIN_LEVEL_ACP );
					continue;
				}
				var tr:WireThreshold = thresholds[int(key)-1];
				if ( tr )
					levels.push( calcXtoAcp( tr.xpos ) );
			}
			levels.sort( Array.NUMERIC );
			
			for(var l:String in fields ) {
				// Костыльный фикс, на пожарных шлейфах  с питанием, может быть ситуация, когда шлейфы сохраняются слишкмо близко к границе.
				if( levels[l] > UIWire.MAX_LEVEL_ACP - 80 )
					levels[l] = UIWire.MAX_LEVEL_ACP - 80;
				(fields[l] as IFormString).setCellInfo( String( levels[l] ));
			}
			dispatchEvent( new Event( Event.CHANGE ) );
		}
		public function rename(arr:Array):void
		{
			for(var key:String in arr ) {
				getThreshByColor( arr[key].color ).text = arr[key].label;
			}
		}
		private function getThreshByColor(color:uint):WireThreshold
		{
			for(var key:String in thresholds ) {
				if( (thresholds[key] as WireThreshold).color == color )
					return thresholds[key] as WireThreshold;
			}
			return null;
		}
		public function getTarget():IFormString
		{
			return fields[0] as IFormString;
		}
		public function build(arr:Array):void
		{
			undraw();
			var totalThresholds:int = arr.length;
			isNeedControl = Boolean(totalThresholds>2);
				
			for( var key:String in arr ) {
				generate( arr[key].label, arr[key].color, int(key), int(key)+1==totalThresholds, Boolean(arr[key].passive) );
			}
			rect.width = globalWidth;
		}
		public function put(arr:Array):void
		{
			
			for( var keya:String in arr ) {
				(fields[keya] as IFormString).setCellInfo( String(arr[keya]) );
			}
			
			coeff = globalWidth/(UIWire.MAX_TIMELINE_OM-UIWire.MIN_TIMELINE_OM);
			
			var aDistrib:Array = arr.slice(1, arr.length-1 );
			
			for( var key:String in aDistrib) {
				setPosition( int(key), calcAcpToX(aDistrib[key]) );
			}
			
			interSelect();
		}
		public function putWireResistance(value:int):void
		{
			mainUnit.visible = true;
			mainUnit.x = calcAcpToX(value);
			updateUnit();
		}
		public function setPosition(item:int, pos:int):void
		{
			if ( thresholds.length > item && thresholds[item] ) 
				thresholds[item].xpos = pos;
		}
		public function generate( _title:String, _color:uint, _id:int, _isEnd:Boolean, passive:Boolean ):void
		{
			var pw:int = 10;
			var px:int = -100;
			var pthresh:WireThreshold = getPreviousThresh( thresholds.length-1 );
			if ( pthresh )
				px = pthresh.leftBorder;
			if ( _isEnd )
				pw = globalWidth-px + 100;
			
			var thresh:WireThreshold = new WireThreshold( _title, _color, _id, pw, px, _isEnd, measure_unit, passive );
			thresh.calcXAcp = calcXtoAcp;
			thresh.hiddenControl = !isNeedControl;
			thresh.register( canSlideFurther, pushNext, pullPrev );
			if ( !_isEnd )thresh.globalWidth = globalWidth;
			addChild( thresh );
			thresholds.push( thresh );
		}
		private function updateUnit():void
		{
			for( var key:String in thresholds ) {
				
				if ( (thresholds[key] as WireThreshold).getBorder().left <= mainUnit.x &&
					(thresholds[key] as WireThreshold).getBorder().right > mainUnit.x ) {
					mainUnit.reDraw( (thresholds[key] as WireThreshold).color );
					mainUnit.label = UIWire.LABEL_LEVEL_SIGN + UTIL.formateNumbersToLetters( Utility.mathACPtoOM(calcXtoAcp(mainUnit.x)) )+measure_unit;
					break;
				}
			}
		}
		private function getPreviousThresh( num:int ):WireThreshold
		{
			if ( num < 0 )
				return null;
			return thresholds[ num ] as WireThreshold;
		}
		private function pushNext( _x:int, _id:int ):void
		{
			for(var t:String in thresholds) {
				thresholds[t].visible = !Boolean(_x > globalWidth);
			}
			thresholds[_id+1].push( _x );
			if ( thresholds.length > _id+2 && thresholds[_id+1].isPassive ) {
trace(thresholds[_id+1].xpos +" - "+ thresholds[_id+2].xpos)
				thresholds[_id+1].xpos = thresholds[_id+2].xpos;
			}
				//thresholds[_id+2].xpos = thresholds[_id+2].xpos;
		}
		private function pullPrev(_x:int, _id:int):void
		{
			// для Костыля, левый край пассивного края надо сдвигать до упора вправо 
			if (_id>1 && thresholds[_id-1].isPassive )
				thresholds[_id-1].xpos = thresholds[_id-2].xpos;
		}
		private function canSlideFurther( _id:int ):Boolean
		{	// проверка на границу следующего ползунка и общая проверка на минимум и максимум допустимых на данном приборе
			interSelect();
			if ( thresholds[_id].xpos + 10 < thresholds[_id+1].leftBorder 
				&& thresholds[_id].xpos > calcAcpToX(UIWire.MIN_LEVEL_ACP) 
				&& thresholds[_id].xpos < calcAcpToX(UIWire.MAX_LEVEL_ACP ) ) {	
				fireChange();
				return true;
			}
			return false;
		}
		private function interSelect():Boolean
		{
			var len:int = thresholds.length;
			var interselection:Boolean;
			for (var i:int=0; i<len; ++i) {
				thresholds[i].layer = 0;
			}
			var d:DisplayObject;
			var counter:int=0;
			while(true) {
				if (counter < len ) {
					d = thresholds[counter].getHitTestBoject();
					counter++;
				} else
					break;
				if (!d)
					break;
				for ( i=0; i<len; ++i) {
					if( thresholds[i].getHitTestBoject() && d != thresholds[i].getHitTestBoject() && d.hitTestObject( thresholds[i].getHitTestBoject() ) ) {
						thresholds[i].layer++;
					}
				}
			}
			counter = 0;
			// требуется двойной прогон проверок на коллизии, с одного коллизии могут остаться
			while(true) {
				if (counter < len ) {
					d = thresholds[counter].getHitTestBoject();
					counter++;
				} else
					break;
				if (!d)
					break;
				for ( i=0; i<len; ++i) {
					if( thresholds[i].getHitTestBoject() && d != thresholds[i].getHitTestBoject() && d.hitTestObject( thresholds[i].getHitTestBoject() ) ) {
						thresholds[i].layer++;
					}
				}
			}
			
			return false;
		}
		private function onRevert():void
		{
			trace("WirePanel.onRevert()");
			f();
		}
		private function undraw():void
		{
			for( var key:String in thresholds ) {
				(thresholds[key] as WireThreshold).undraw();
				removeChild( thresholds[key] );
				thresholds[key] = null;
			}
			thresholds.length = 0;
		}
		override public function set visible(value:Boolean):void
		{
			super.visible = value;
			if ( !value )
				mainUnit.visible = false;
		}
	}
}