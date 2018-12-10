package components.gui.visual.out
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.geom.Rectangle;
	
	import mx.core.UIComponent;
	
	import components.abstract.functions.loc;
	import components.gui.SimpleTextField;
	import components.gui.triggers.TextButton;
	import components.gui.visual.wire.WireUnitBig;
	import components.interfaces.IFormString;
	import components.interfaces.IOutServant;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.system.SavePerformer;
	
	public class LevelPanel extends UIComponent
	{
		protected var servant:IOutServant;
		
		private var tError:SimpleTextField;
		private var bResetLevels:TextButton;
		
		protected var fields:Array;
		private var hashStructToArr:Object = {1:0, 2:0, 3:1, 4:2, 5:3, 6:4, 7:5 };
		private var isNeedControl:Boolean = true;
		
		protected var thresholds:Vector.<LevelThreshold>;
		protected var mainUnit:WireUnitBig;
		private var rect:Rectangle;
		protected var measure_unit:String;
		protected var operationCMD:int;
		
		private var levels:Array;		// информация собранная со всех полей при изменении
	
		public var structureID:int;
		
		public function LevelPanel()
		{
			super();
			thresholds = new Vector.<LevelThreshold>;
			
			mainUnit = new WireUnitBig(0xff0000);
			addChild( mainUnit );
			mainUnit.y = -20;
			mainUnit.visible = false;
			
			tError = new SimpleTextField(loc("level_wrong_values"));
			addChild( tError );
			tError.x = 192;
			tError.y = 1;
			
			bResetLevels = new TextButton;
			addChild( bResetLevels );
			bResetLevels.setUp(loc("level_return_defaults"), resetLevels );
			bResetLevels.x = 192;
			bResetLevels.y = 14;
			
			rect = new Rectangle;
			rect.x = 0;
			rect.y = 0;
			rect.height = 0;
			
			this.height = 110;
			measure_unit = "A";
		}
		public function changeStructure(s:int):void
		{
			structureID = s;
			
			SavePerformer.remove( operationCMD );
			structureID = s;
			for( var key:String in fields ) {
				if ( (fields[key] as IFormString).cmd == operationCMD ) {
					SavePerformer.add( operationCMD, s, fields[key] );
//					if (!isNaN(globalFocusGroup))
//						(aCells[key] as IFocusable).focusgroup = globalFocusGroup;
				}
			}
		}
		public function edges(min:int,max:int):void
		{
			servant.edges( min,max );
		}
		public function getFields():Array
		{
			return fields;
		}
		public function colorizeNorm(_color:uint):void
		{
			thresholds[1].bgcolor = _color;
		}
		public function rename(arr:Array):void
		{
			for(var key:String in arr ) {
				getThreshByColor( arr[key].color ).text = arr[key].label;
			}
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
				generate( arr[key].label, arr[key].color, int(key), int(key)+1==totalThresholds );
			}
			rect.width = servant.getXlength();
		}
		public function put(arr:Array):void
		{
			for( var keya:String in arr ) {
				(fields[keya] as IFormString).setCellInfo( String(arr[keya]) );
			}
			
			var lastx:int=0;
			var mostx:int=0;
			var len:int = arr.length;
			
			// расставляем пороги
			var fire:Boolean = thresholds.length == 5; 
			
			for (var j:int=0; j<len; j++) {
				lastx = servant.calcAPCtoX( (j==3 && fire) ? arr[j+1] : arr[j]);
				setPosition( j, lastx );
				if(mostx<lastx)
					mostx = lastx;
				// в пожарном на 1 порог меньше
				if (fire && j==3)
					break;
			}
			thresholds[thresholds.length-1].setw( (servant.getXlength()+100)-mostx );
			
			// если реальная длина больше чем рассчетная, надо укорачивать последний порог.
			len = thresholds.length;
			var tgw:int =0;
			for (var i:int=0; i<len; ++i) {
				tgw += thresholds[i].getw();
			}
			if(tgw != servant.getXlength()+200) {
				var exeed:int = tgw - (servant.getXlength()+200);
				thresholds[thresholds.length-1].setw( (servant.getXlength()+100)- (mostx +exeed) );
			}
			
			interSelect();
		}
		public function putWireResistance(value:int, on:Boolean=true):void
		{
			if( !mainUnit.visible )
				mainUnit.visible = true;

			
			mainUnit.x = servant.calcAPCtoX(value);
			updateUnit();
			if (!on)
				mainUnit.reDraw( 0x000000 );
		}
		public function setPosition(item:int, pos:int):void
		{
			if ( thresholds[item] )
				thresholds[item].xpos = pos;
		}
		public function generate( _title:String, _color:uint, _id:int, _isEnd:Boolean ):void
		{
			var pw:int = 10;
			var px:int = -100;
			var pthresh:LevelThreshold = getPreviousThresh( thresholds.length-1 );
			var xle:int = servant.getXlength();
			if ( pthresh )
				px = pthresh.leftBorder;
			if ( _isEnd )
				pw = xle-px+100;
			
			
			var thresh:LevelThreshold = new LevelThreshold( _title, _color, _id, pw, px, _isEnd, measure_unit, servant );
			
			thresh.hiddenControl = !isNeedControl;
			thresh.register( canSlideFurther, pushNext );
			if ( !_isEnd )
				thresh.globalWidth = servant.getXlength();
			addChild( thresh );
			thresholds.push( thresh );
		}
		public function getLevels():Array
		{
			return levels;
		}
		private function fireChange():void
		{
			levels = new Array;
			
			var len:int = fields.length;
			for (var i:int=0; i<5; i++) {
				var tr:LevelThreshold = thresholds[i];
				if ( tr )
					levels.push( servant.calcXtoACP(tr.xpos) );
			}
			levels.sort( Array.NUMERIC );
			
		/*	if (thresholds.length == 5)
				levels[0] = levels[1];*/
			if (thresholds.length == 6) {
				for (i=0; i<5; i++) {
					(fields[i] as IFormString).setCellInfo( String(levels[i]) );
				}
			} else {
				(fields[0] as IFormString).setCellInfo( String(levels[1]) );
				(fields[1] as IFormString).setCellInfo( String(levels[2]) );
				(fields[2] as IFormString).setCellInfo( String(levels[3]) );
				(fields[3] as IFormString).setCellInfo( String(levels[3] + ((levels[4]-levels[3])/2)) );
				(fields[4] as IFormString).setCellInfo( String(levels[4]) );
			}
			dispatchEvent( new Event( Event.CHANGE ) );
		}
		private function getThreshByColor(color:uint):LevelThreshold
		{
			for(var key:String in thresholds ) {
				if( thresholds[key].color == color )
					return thresholds[key];
			}
			return null;
		}
		private function updateUnit():void
		{
			var true_value:int = mainUnit.x;
			if( true_value == 0 )
				true_value = -1;
			if (mainUnit.x > servant.getXlength())
				mainUnit.x = servant.getXlength()+1;
			if (mainUnit.x < 0)
				mainUnit.x = 0;
			
			for( var key:String in thresholds ) {
				if ( thresholds[key].getBorder().left < mainUnit.x &&
					thresholds[key].getBorder().right >= mainUnit.x ) {
					mainUnit.reDraw( thresholds[key].color );
					mainUnit.label = servant.getLabelXtoI(true_value)+measure_unit;
					break;
				}
			}
		}
		private function getPreviousThresh( num:int ):LevelThreshold
		{
			if ( num < 0 )
				return null;
			return thresholds[ num ];
		}
		private function pushNext( _x:int, _id:int ):void
		{
			for(var t:String in thresholds) {
				thresholds[t].visible = !Boolean(_x > servant.getXlength());
			}
			thresholds[_id+1].push( _x );
		}
		private function canSlideFurther( _id:int ):Boolean
		{	// проверка на границу следующего ползунка и общая проверка на минимум и максимум допустимых на данном приборе
			interSelect();
			if ( thresholds[_id].xpos + 10 < thresholds[_id+1].leftBorder ) {
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
		private function undraw():void
		{
			for( var key:String in thresholds ) {
				thresholds[key].undraw();
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
		private function resetLevels():void
		{
			var arr:Array = servant.getDefaults();
			RequestAssembler.getInstance().fireEvent( new Request( operationCMD, null, structureID,arr ));
			put( arr.slice() );
		}
	}
}