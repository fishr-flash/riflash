package components.gui.fields
{
	import flash.display.InteractiveObject;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import components.abstract.servants.TabOperator;
	import components.gui.SimpleTextField;
	import components.gui.fields.lowlevel.MSlider;
	import components.interfaces.IFocusable;
	import components.interfaces.IFormString;
	import components.static.COLOR;
	import components.static.KEYS;

	public class FSSlider extends FormString implements IFormString, IFocusable
	{
		protected var cell:MSlider;
		private var min:int;
		private var max:int;
		private var invalid:Shape;
		
		protected var tmin:SimpleTextField;
		protected var tmax:SimpleTextField;
		protected var tvalue:SimpleTextField;
		
		protected var ACCURATE:Boolean;
		
		public function FSSlider()
		{
			super();
			construct();
		}
		private function construct():void 
		{
			tmin = new SimpleTextField("0", 40 );
			tmin.setSimpleFormat("left",0,10);
			addChild( tmin );
			tmin.y = -11;
			tmin.x = 200-tmin.width;
			
			tmax = new SimpleTextField("0", 40 );
			tmax.setSimpleFormat("right",0,10);
			addChild( tmax );
			tmax.y = -11;
			
			tvalue = new SimpleTextField("0", 30 );
			tvalue.setSimpleFormat("center",0,10);
			addChild( tvalue );
			tvalue.y = -11;
			
			createSlider();
			addChild( cell );
			cell.x = 200;
			cell.y = 3;
			cell.addEventListener( Event.CHANGE, change );
			cell.addEventListener( MouseEvent.MOUSE_DOWN, mDown );
			
			tmax.x = 200 + (cell.width);
			tvalue.x = tmin.x + tmin.width;
			
			this.valid = true;
		}
		protected function createSlider():void
		{
			cell = new MSlider;
		}
		private function mDown(e:MouseEvent):void
		{
			callLater( TabOperator.getInst().iNeedFocus, [this] );
		}
		private function moveTextToSlider():void
		{
			tvalue.x = cell.x + int(cell.position*cell.width) - tvalue.width/2;
		}
		override protected function change(ev:Event):void
		{
			if (ACCURATE)
				cellInfo = (cell.position*(max-min)+min).toString();
			else
				cellInfo = int(cell.position*(max-min)+min).toString();
			moveTextToSlider();
				
			tvalue.text = cellInfo;
			valid = true;
			send();
			dispatchEvent(new Event(Event.CHANGE));
		}
		public function renameLimits(min:String, max:String):void
		{
			tmin.text = min;
			tmax.text = max;
		}
		override public function setList( a:Array, _selectedIndex:int=-1 ):void
		{
			min = a[0].data;
			max = a[1].data;
			
			tmin.text = String(a[0].data);
			tmax.text = String(a[1].data);
			
			cell.setUp( a[0].label, a[1].label );
		}
		override public function getCellInfo():Object 
		{
			return cellInfo;
		}
		override public function setCellInfo(value:Object):void
		{
			validate(value.toString());
			moveTextToSlider();
			cellInfo = String(value);
			tvalue.text = cellInfo;
		}
		override public function setWidth(_num:int):void
		{
			tName.width = _num;
			cell.x = tName.width+1;
			
			tmin.x = cell.x - tmin.width;
			tmax.x = cell.x + (cell.width);
			
			moveTextToSlider();
		}
		override public function setCellWidth( _num:int ):void		{	}
		override public function get width():Number
		{
			return cell.x + cell.width;
		}
		override protected function drawValid(value:Boolean):void
		{
			if( value ) {
				if (invalid)
					invalid.visible = false;
			} else {
				if(!invalid) {
					invalid = new Shape;
					addChildAt(invalid,0);
					invalid.graphics.beginFill( COLOR.RED_INVALID );
					invalid.graphics.drawRect(cell.x,cell.y,cell.width, 20 );
				}
				invalid.visible = true;
			}
		}
		override protected function validate( str:String, ignorSave:Boolean=false ):Boolean
		{
			var n:Number = Number(str) - min;
			var raw:Number = Number(str);
			if ( raw < min || raw > max) {
				cell.setPosition( 0.5 );
				valid = false;
			} else {
				valid = true;
				cell.setPosition( n/(max-min) );
			}
			
			
			
			// Если обнаруживается неверное поле оно сразу отправляет себя что сохранялка знала что есть неверное поле
			if (!valid && AUTOMATED_SAVE && !ignorSave)
				fSend( this );
			return valid;
		}
		override public function doAction(key:int,ctrl:Boolean=false, shift:Boolean=false):void
		{
			if (cell.isControlled()) {
				
				// вычисляем минимальное значение для сдвика ползунка с клавиатуры. Если значение = 1, минимальный сдвиг будет 0.01
				var increment:Number = 1/(max - min);
				if(increment == 1)
					increment = 0.01;
				
				var value:Number = cell.position;
				switch(key) {
					case KEYS.LeftArrow:
						value -= increment;
						if (value < 0)
							value = 0;
						cell.setPosition(value);
						change(null);
						break;
					case KEYS.RightArrow:
						value += increment;
						if (value > 1)
							value = 1;
						cell.setPosition(value);
						change(null);
						break;
				}
			}
		}
		
		override public function getFocusField():InteractiveObject
		{
			return cell;
		}
		override public function getFocusables():Object
		{
			return cell;
		}
		override public function getType():int
		{
			if (cell.isControlled())
				return TabOperator.TYPE_ACTION;
			return TabOperator.TYPE_DISABLED;
		}
		override public function isPartOf(io:InteractiveObject):Boolean
		{
			return cell == io;
		}
	}
}