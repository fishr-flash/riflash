package components.gui.fields.lowlevel
{
	import flash.display.DisplayObject;
	import flash.display.InteractiveObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	
	import mx.collections.ArrayList;
	import mx.core.FlexGlobals;
	import mx.core.UIComponent;
	
	import components.gui.SimpleTextField;
	import components.gui.fields.lowlevel.interfaces.IComboBoxItem;
	import components.static.COLOR;
	import components.static.GuiLib;
	import components.static.KEYS;
	import components.system.SysManager;
	import components.system.UTIL;
	
	/**
	 * v 1.2 добавил выделение всех слов даблкликом
	 * v 1.1 добавил класс TimeText
	 * v 1.0 поправил отправку выбора того же самого элемента  246: 			if (selectedIndex != dd.index) {  */
	
	public class MComboBox extends Sprite
	{
		public static const OPTION_ALIGN_CENTER:int = 1;
		
		public static const DATA_CHANGED:String = "DATA_CHANGED";
		public static const DATA_CHANGED_NON_MOUSE:String = "DATA_CHANGED_NON_MOUSE";	// Event только для editable comboCheckBox, onFocusOut, onKey
		public static const CLOSE:String = "CLOSE_LIST";
		public static const OPEN:String = "OPEN_LIST";
		public static const MBUTTON_CLICK:String = "MBUTTON_CLICK";
		
		public static const S_CheckComboBox:int = 1;
		public static const S_EditableCheckComboBox:int = 2;
		public static const S_ListCheckBox:int = 3;
		public static const S_ListImageBox:int = 4;
		
		public static const M_Button:int = 1;
		
		public var CLICKABLE:Boolean = true;
		
		private const HEIGHT:int = 21;
		
		private const NORMAL:int = 1;
		private const OVER:int = 3;
		private const DOWN:int = 5;
	
		private var LOADING:Boolean = false;		// при setCellInfo не нужно сохранять, и соответственно выстреливать эвент Change
		private var OPENED:Boolean = false;
		
		private var layer:MovieClip;
		
		private var _over:Boolean;
		private var _enabled:Boolean=true;
		private var _width:Number = 100;
		private var _dataProvider:ArrayList;		
		private var _selectedIndex:int=-1;
		
		private var dd:DropDown;
		private var current:TimeText;
		private var UID:int = UTIL.generateUId();
		
		private var boxState:int;
		
/** Класс для отображения в списке комбобокса	*/
		public function MComboBox(state:int=0)
		{
			super();
			
			layer = new GuiLib.m_combobox;
			addChild( layer );
			layer.gotoAndStop(1);
			
			var cls:Class;
			var isComboBox:Boolean=true;
			var isImageBox:Boolean=false;
			var isEditable:Boolean=false;
			var isComboBoxEditable:Boolean = false;
			var isList:Boolean=false;
			boxState = state;
			switch(state) {
				case S_CheckComboBox:
					cls = MTextCheckBox;
					isComboBox = false;
					break;
				case S_EditableCheckComboBox:
					cls = MTextCheckBox;
					isComboBox = false;
					isEditable = true;
					isComboBoxEditable = true;
					break;
				case S_ListCheckBox:
					cls = MTextCheckBox;
					isComboBox = false;
					isList = true;
					layer.visible = false;
					break;
				case S_ListImageBox:
					cls = MImage;
					isImageBox = true;
					break;
				default:
					cls = SimpleTextField;
					break;
			}
			
			dd = new DropDown(height, cls);
			if ( getStage() != null )
				getStage().addChild( dd );
			dd.addEventListener( BoxEvent.IndexChange, indexChanged );
			dd.addEventListener( BoxEvent.MButton, onMButton );
			
			dd.isComboBox = isComboBox;
			dd.isList = isList;
			dd.isImageBox = isImageBox;
			
			current = new TimeText(height-1);
			current.isComboBoxEditable = isComboBoxEditable;
			addChild( current );
			editable = isEditable;
			current.visible = !isList;
			
			width = _width;
			enabled =_enabled;
			
			dataProvider = new ArrayList([]);
		}
		public function configure(c:int):void
		{
			switch(c) {
				case OPTION_ALIGN_CENTER:
					var tf:TextFormat = new TextFormat;
					tf.align = "center";
					current.defaultTextFormat = tf;
					current.setTextFormat( tf );
					break;
			}
		}
		public function set enabled(b:Boolean):void
		{
			
			
			_enabled = b;
			
			if (dd.isList) {
				current.alpha = 1;
				layer.alpha = 1;
				return;
			}
			
			if (b) {
				current.alpha = 1;
				layer.alpha = 1;
				layer.addEventListener(MouseEvent.MOUSE_DOWN, mDown);
				layer.addEventListener(MouseEvent.MOUSE_UP, mUp );
				layer.addEventListener(MouseEvent.ROLL_OVER, mOver);
				layer.addEventListener(MouseEvent.ROLL_OUT, mOut );
				
				this.addEventListener( FocusEvent.FOCUS_IN, onThisFocus );
				
				editable = dd.editable;
			} else {
				
				current.alpha = 0.5;
				current.type = TextFieldType.DYNAMIC;
				current.selectable = false
				
				current.removeEventListener(MouseEvent.MOUSE_DOWN, mDown);
				current.removeEventListener(MouseEvent.MOUSE_UP, mUp );
				current.removeEventListener(MouseEvent.ROLL_OVER, mOver);
				current.removeEventListener(MouseEvent.ROLL_OUT, mOut );
				current.removeEventListener( TimeText.CHANGE, confirm );
				
				layer.alpha = 0.5;
				layer.removeEventListener(MouseEvent.MOUSE_DOWN, mDown);
				layer.removeEventListener(MouseEvent.MOUSE_UP, mUp );
				layer.removeEventListener(MouseEvent.ROLL_OVER, mOver);
				layer.removeEventListener(MouseEvent.ROLL_OUT, mOut );
				
				this.removeEventListener( FocusEvent.FOCUS_IN, onThisFocus );
			}
		}
		public function get enabled():Boolean
		{
			return _enabled;
		}
		public function open(w:int=0, h:int=0, gx:int=0, gy:int=0):void
		{
			if (!dd.empty) {
				this.dispatchEvent( new Event(OPEN) );
				var p:Point;
				if (w==0 && h==0) {
					p = localToGlobal(new Point(0,0));
					dd.x = p.x;
					dd.y = p.y+height;
					dd.open(width,selectedIndex);
				} else {
					p = localToGlobal( new Point(this.x, this.y ));
					dd.x = gx;
					dd.y = gy;
					dd.openWithSize(w,h,selectedIndex);
				}
				OPENED = true;
			}
		}
		public function disable(_blockFree:int):void
		{
			var len:int = dataProvider.length;
			var block:Boolean;
			var textLen:int=0;
			var target:Object;
			for( var i:int; i<len; ++i ) {
				target = dataProvider.getItemAt(i);
				
				textLen = textLen < String(target.label).length? String(target.label).length:textLen;
				if(target.block )
					block = target.block != _blockFree;
				else
					block = false;
				
				if ( target.trigger == true )
					block = false;
				if ( _blockFree==-1) block = false;
				var item:IComboBoxItem = dd.getItemAt( i );
				if (item) {
					item.enabled = !block && !target.disabled;
					item.data = target;
				}
			}
		}
		override public function set width(value:Number):void
		{
			_width = value;
			layer.x = width - layer.width;
			current.width = width - layer.width;
		}
		override public function get width():Number
		{
			return _width;
		}
		override public function set height(value:Number):void
		{
			trace("Call unexpected height in MComboBox")
		}
		override public function get height():Number
		{
			return HEIGHT;
		}
		public function set selectedIndex(i:int):void
		{
			_selectedIndex = i;
		}
		public function get selectedIndex():int
		{
			return _selectedIndex;
		}
		public function set restrict(s:String):void
		{
			current.restrict = s;
		}
		public function set maxChars(i:int):void
		{
			current.maxChars = i;
		}
		public function get data():String
		{
			return dd.data;
		}
		public function set data(s:String):void
		{
			LOADING = true;
			dd.confirm(s);
		}
		public function set dataProvider(d:ArrayList):void
		{
			_dataProvider = d;
			dd.install( d );
		}
		public function get dataProvider():ArrayList
		{
			return _dataProvider;
		}
		public function set valid(b:Boolean):void
		{
			if (b)
				current.backgroundColor = COLOR.WHITE;
			else
				current.backgroundColor = COLOR.RED_INVALID;
		}
		public function set img(b:Class):void
		{
			if (b)
				current.img = b;
		}
		public function set text(s:String):void
		{
			current.text = s;
		}
		public function get text():String
		{
			return current.text;
		}
		public function get label():String
		{
			return dd.label;
		}
		public function set isTime(b:Boolean):void
		{
			current.time = b;
		}
		public function getFocusable():InteractiveObject
		{
			return current;
			//if( editable )
		}
		private function doOpen():void
		{
			if (CLICKABLE) {
				layer.gotoAndStop( DOWN );
				
				if (dd.visible) {
					close();
				} else {
					if (!dd.empty) {
						this.dispatchEvent( new Event(OPEN) );
						var p:Point = localToGlobal(new Point(0,0));
						dd.x = p.x;
						dd.y = p.y+height;
						dd.open(width,selectedIndex);
						
						getStage().addEventListener( MouseEvent.MOUSE_DOWN, onClose );
						getStage().addEventListener( KeyboardEvent.KEY_DOWN, onKey );
						getStage().addEventListener(MouseEvent.MOUSE_WHEEL, onClose );
						getStage().addEventListener(Event.RESIZE, onResize );
						
						getStage().addEventListener(Event.DEACTIVATE, onDeactivate);
					}
				}
			}
		}
/**	MISC			***/
		public function isOpened():Boolean
		{
			return OPENED;
		}
		private function getStage():Stage
		{
			if (stage)
				return stage;
			return FlexGlobals.topLevelApplication.stage;
		} 
		public function localResize(w:int, h:int, real:Boolean=false):void
		{
			if (real)
				close();
		}
		public function set editable(b:Boolean):void
		{
			dd.editable = b;
			current.selectable = b;
			
			if(dd.isList)
				return;
			
			if (b) {
				current.type = TextFieldType.INPUT;
				
				current.removeEventListener(MouseEvent.MOUSE_DOWN, mDown);
				current.removeEventListener(MouseEvent.MOUSE_UP, mUp );
				current.removeEventListener(MouseEvent.ROLL_OVER, mOver);
				current.removeEventListener(MouseEvent.ROLL_OUT, mOut );
				
				current.addEventListener( TimeText.CHANGE, confirm );
				
				current.addEventListener(FocusEvent.FOCUS_IN, onFocus );
				
				current.doubleClickEnabled = true;
				current.addEventListener( MouseEvent.DOUBLE_CLICK, mDClick );
				
			} else {
				current.type = TextFieldType.DYNAMIC;
				
				current.addEventListener(MouseEvent.MOUSE_DOWN, mDown);
				current.addEventListener(MouseEvent.MOUSE_UP, mUp );
				current.addEventListener(MouseEvent.ROLL_OVER, mOver);
				current.addEventListener(MouseEvent.ROLL_OUT, mOut );
				
				current.removeEventListener( Event.CHANGE, confirm );
				current.removeEventListener(FocusEvent.FOCUS_IN, onFocus );
				
				current.doubleClickEnabled = false;
				current.removeEventListener( MouseEvent.DOUBLE_CLICK, mDClick );
			}
		}
		public function close():void
		{
			OPENED = false;
			dd.close();
			
			getStage().removeEventListener(MouseEvent.MOUSE_WHEEL, onClose );
			getStage().removeEventListener(Event.RESIZE, onResize );
			getStage().removeEventListener(Event.DEACTIVATE, onDeactivate);
			
			if (!getStage().focus || getStage().focus != current) {
				getStage().removeEventListener( MouseEvent.MOUSE_DOWN, onClose );
				getStage().removeEventListener( KeyboardEvent.KEY_DOWN, onKey );
			}
			this.dispatchEvent( new Event(CLOSE) );
		}
/** EVENTS			***/
		private function onFocus(ev:Event):void
		{
			OPENED = true;
			current.addEventListener( FocusEvent.FOCUS_OUT, onFoucusOut);
			getStage().addEventListener( KeyboardEvent.KEY_DOWN, onKey );
			getStage().addEventListener( MouseEvent.MOUSE_DOWN, onClose );
		}
		private function onThisFocus(e:Event):void
		{
			this.addEventListener( FocusEvent.FOCUS_OUT, onThisFocusOut);
			if (boxState == S_ListCheckBox)
				dd.showSelection();
		}
		private function onThisFocusOut(e:Event):void
		{
			if( boxState != S_ListCheckBox ) {
				close();
				layer.gotoAndStop( NORMAL );
			} else
				dd.hideSelection();
		}
		private function onFoucusOut(ev:Event):void
		{
			trace("MComboBox.onFoucusOut(ev)");
			
			getStage().removeEventListener( KeyboardEvent.KEY_DOWN, onKey );
			current.removeEventListener( FocusEvent.FOCUS_OUT, onFoucusOut);
			this.removeEventListener( FocusEvent.FOCUS_OUT, onFoucusOut);
			getStage().removeEventListener( MouseEvent.MOUSE_DOWN, onClose );
			current.replace=true;
			
			/*if (dataProvider && dataProvider.source && dataProvider.source[0] ) {
				var uidf:int = UTIL.generateUId();
				dataProvider.source[0].uid = uidf;  
			}*/
			
			if (dd.visible || OPEN) {
				trace("dd.visible || OPEN");
				// нужно именно 2 закрытия
				// фикс для закрытия фокуса при смене его в такой же текстфилд
				close();
				if (parent && parent is UIComponent)
					(parent as UIComponent).callLater( close );
			}
			
			indexChanged(null);
		}
		private function onClose(ev:MouseEvent):void
		{
			if ( !this.contains(ev.target as DisplayObject) && !dd.contains(ev.target as DisplayObject) ) {
				close();
				SysManager.clearFocus(getStage());
			}
		}
		private function onDeactivate(e:Event):void
		{
			close();
		}
		private function onResize(ev:Event):void
		{
			close();
		}
		private function confirm(ev:Event):void
		{
			dd.confirm(current.text);
		}
		private function indexChanged(ev:BoxEvent=null):void
		{
			selectedIndex = dd.index;
			
			if (ev && ev.isMenuClicked() )
				current.replace = true;
			// если чекбокс то управление текстовым полем переходит в руки управляющего компонента
			if( current.replace && dd.isComboBox && !dd.isImageBox && dd.label != "")
				text = dd.label;
			if( current.replace && dd.isComboBox && dd.isImageBox )
				img = dd.img;
			if( LOADING )
				LOADING = false;
			else {
				if (!ev && current.isComboBoxEditable)
					this.dispatchEvent( new Event( DATA_CHANGED_NON_MOUSE ));
				else
					this.dispatchEvent( new Event( DATA_CHANGED ));
			}
		}
		private function onMButton(e:BoxEvent):void
		{
			this.dispatchEvent( new Event( MBUTTON_CLICK ) );
		}
		private function mDown(ev:MouseEvent):void
		{
				doOpen();
		}
		private function mUp(ev:MouseEvent):void
		{
			if (_over)
				layer.gotoAndStop( OVER );
			else
				layer.gotoAndStop( NORMAL );
		}
		private function mOver(ev:MouseEvent):void
		{
			_over = true;
			layer.gotoAndStop( OVER );
		}
		private function mOut(ev:MouseEvent):void
		{
			_over = false;
			layer.gotoAndStop( NORMAL );
		}
		private function onKey(ev:KeyboardEvent):void
		{
			if ( (ev.keyCode == KEYS.ESC || ev.keyCode == KEYS.Enter) ) {
				close();
				if (getStage().focus is SimpleTextField || getStage().focus is TimeText )
					SysManager.clearFocus(getStage());
				layer.gotoAndStop( NORMAL );
			}
		}
		
		private function mDClick(e:MouseEvent):void
		{
			var pos:int = (current.text as String).length;
			current.setSelection( 0, pos );
		}
/** KEY EVENTS			***/
		public function transferKey(key:int):void
		{
			if (dd.visible) {
				switch(key) {
					case KEYS.Enter:
						if( boxState == S_CheckComboBox || boxState == S_EditableCheckComboBox )
							break;
					case KEYS.Spacebar:
						dd.doSelection();
						layer.gotoAndStop( NORMAL );
						break;
					case KEYS.RightArrow:
					case KEYS.DownArrow:
						dd.doListNavigation(true);
						break;
					case KEYS.LeftArrow:
					case KEYS.UpArrow:
						dd.doListNavigation(false);
						break;
				}
			} else {
				switch(key) {
					case KEYS.Spacebar:
					case KEYS.Enter:
					case KEYS.LeftArrow:
					case KEYS.RightArrow:
					case KEYS.DownArrow:
					case KEYS.UpArrow:
						doOpen();
						break;
				}
			}
		}
	}
}
import flash.display.Bitmap;
import flash.display.DisplayObject;
import flash.display.Shape;
import flash.display.Sprite;
import flash.display.Stage;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.filters.DropShadowFilter;
import flash.geom.Point;
import flash.text.TextField;
import flash.text.TextFormat;

import mx.collections.ArrayList;
import mx.core.FlexGlobals;

import components.gui.fields.FSComboCheckBox;
import components.gui.fields.lowlevel.MCButton;
import components.gui.fields.lowlevel.MComboBox;
import components.gui.fields.lowlevel.interfaces.IComboBoxItem;
import components.gui.fields.lowlevel.parts.MScrolling;
import components.static.COLOR;
import components.static.KEYS;
import components.static.PAGE;
import components.system.UTIL;

class DropDown extends Sprite
{
	public var isComboBox:Boolean = true;	// false = check combobox	 true = обычный combobox
	public var isImageBox:Boolean = false;	// true = imageBox
	private var _isList:Boolean = false;		// является ли ListCheckBox'ом
	
	private var _index:int;
	public function set index(i:int):void
	{
		_index = i;
	}
	public function get index():int
	{
		return _index;
	}
	public var label:String;
	public var data:String;
	public var img:Class;
	public var empty:Boolean = false;
	
	private var h:int;
	private var w:int;
	private var num:int;
	private var lastSelectionPos:int;
	
	private var items:Vector.<IComboBoxItem>;
	private var names:ArrayList;
	private var selection:Shape;
	private var selCurrent:Shape;
	private var scroll:MScrolling;
	
	private const MARGIN:int=20;
	private const MARGIN_LEFT:int=40;
	
	public var editable:Boolean;
	public var preferredWidth:int; 			// ширина комбобокса
	private var itemsWidth:int;				// ширина самого широкого итема в комбобоксе
	
	private var _class:Class;
	private var certainHeight:int=0;
	
	public function DropDown(_h:int, cls:Class)
	{
		super();
		
		h = _h;
		
		_class = cls;
		
		var dropShadow:DropShadowFilter =  new DropShadowFilter(); 
		dropShadow.alpha = 0.5;
		dropShadow.distance = 2;
		dropShadow.blurX = 10;
		dropShadow.blurY = 6;
		dropShadow.angle = 90;
		
		scroll = new MScrolling(h);
		addChild( scroll );
		
		selection = new Shape;
		scroll.pane.addChild( selection );
		selection.x = 1;
		
		selCurrent = new Shape;
		scroll.pane.addChild( selCurrent );
		selCurrent.x = 1;
		
		this.filters = [dropShadow];
		items = new Vector.<IComboBoxItem>;
		
		this.visible = false;
	}
	public function install(_names:ArrayList):void
	{
		names = _names;
		if (names && names.length > 0)
			empty = false;
		else
			empty = true;
	}
	public function openWithSize(_w:int, _h:int, _index:int):void
	{
		certainHeight = _h;
		open(_w,_index);
	}
	public function open(_w:int, _index:int):void
	{
		num = names.length;
		w = _w;
		index = _index;
		preferredWidth = _w;
		itemsWidth = 0;
		selCurrent.y = 0;
		selection.y = 0;
		scroll.reset();
		if (index < 0)
			lastSelectionPos = 0;
		else
			lastSelectionPos = index*h;
		
		selection.visible = false;
		if (index<0) {
			selCurrent.visible = false;
			label = "";
		} else {
			selCurrent.visible = true;
			selCurrent.y = index*h;
			selection.y = selCurrent.y;
			label = names.getItemAt(index).label;
			data = names.getItemAt(index).data;
			img = names.getItemAt(index).img;
		}
		
		var len:int = names.length;
		for (var i:int=0; i<len; ++i) {
			if(isImageBox)
				items.push( new _class( names.getItemAt(i).img ));
			else {	// если ячейка является не обычной строкой списка а отдельным классом
				if ( names.getItemAt(i).cls != null ) {
					 var cls:int = names.getItemAt(i).cls;
					 switch (cls) {
						 case MComboBox.M_Button:
							 items.push( new MCButton( names.getItemAt(i).label ));
							 break;
					 }
				} else
					items.push( new _class( names.getItemAt(i).label ));
			}
			items[i].height = h;
			scroll.add( items[i] );
			items[i].y = i*h;
			if (items[i].width > itemsWidth)
				itemsWidth = items[i].width; 
			if (items[i].width > preferredWidth)
				preferredWidth = items[i].width;
			if (!isComboBox)
				items[i].data = names.getItemAt(i);
			
			items[i].enabled = !names.getItemAt(i).disabled;
		}
		
		this.addEventListener( MouseEvent.CLICK, mClick );
		this.addEventListener( MouseEvent.MOUSE_MOVE, mMove );
		this.addEventListener( MouseEvent.ROLL_OVER, mOver);
		this.addEventListener( MouseEvent.ROLL_OUT, mOut );
		
		draw();
		this.visible = true;
	}
	public function close():void
	{
		var len:int = items.length;
		for (var i:int=0; i<len; ++i) {
			scroll.pane.removeChild( items[i] as DisplayObject );
		}
		selection.graphics.clear();
		selCurrent.graphics.clear();
		
		items = new Vector.<IComboBoxItem>;
		
		this.removeEventListener( MouseEvent.CLICK, mClick );
		this.removeEventListener( MouseEvent.MOUSE_MOVE, mMove );
		this.removeEventListener( MouseEvent.ROLL_OVER, mOver);
		this.removeEventListener( MouseEvent.ROLL_OUT, mOut );
		this.visible = false;
	}
	public function confirm(s:String):void
	{
		index = -1;
		label = s;
		data = s;
		
		if ( isComboBox ) {
			var len:int = names.length;
			for (var i:int=0; i<len; ++i) {
				if ( s == String(names.getItemAt(i).data) ) {
					index = i;
					label = names.getItemAt(i).label;
					if (isImageBox) {
						//var c:Class = names.getItemAt(i).img;
						img = names.getItemAt(i).img;
					}
					break;
				}
			}
			if (visible) {
				selCurrent.y = index*h;
				selCurrent.visible = Boolean(index > -1);
			}
			if (index<0 && !editable) {
				label = "-";
			}		
		}
		this.dispatchEvent( new BoxEvent( BoxEvent.IndexChange, false ));
	}
	
	public function getItemAt(n:int):IComboBoxItem
	{
		if (n < items.length)
			return items[n];
		return null;
	}
	private function draw():void
	{
		selection.graphics.clear();
		selection.graphics.beginFill( COLOR.COMBOBOX_SELECTION );
		selection.graphics.drawRect( 0,0, preferredWidth-2,h );
		
		selCurrent.graphics.clear();
		if( isComboBox ) {
			selCurrent.graphics.beginFill( COLOR.COMBOBOX_SELECTION_CURRENT );
			selCurrent.graphics.drawRect( 0,0, preferredWidth-2,h );
		}
		
		var p:Point = localToGlobal(new Point(0,0));
		var realHeight:int = num*h;
		var sh:int = certainHeight>0 ? certainHeight : getStage().stageHeight;
		var maxH:int = sh - (p.y + MARGIN);
		if ( realHeight > maxH ) {
			//	realHeight = int(maxH/h)*h;
			if ( realHeight > sh - MARGIN*2)
				realHeight = int((sh-MARGIN*2)/h)*h;
			if( certainHeight == 0 )
				this.y -= ( realHeight - maxH);
			else
				this.y -= 20; 
		}
		
		scroll.size( preferredWidth+scroll.width,realHeight+1 );
		if (scroll.active)
			preferredWidth += scroll.width;
		
		var maxW:int = getStage().stageWidth - (p.x + MARGIN);
		if(preferredWidth > maxW) {
			if (preferredWidth > getStage().stageWidth - MARGIN_LEFT) {
				preferredWidth = getStage().stageWidth - MARGIN_LEFT;
				scroll.size( preferredWidth,realHeight+1 );
			}
			this.x += maxW - preferredWidth;
		} else {	//	если все влезает и никаких сдвигов делать не надо - правится отображение скроллинга
			if (itemsWidth < preferredWidth && scroll.active) {
				preferredWidth -= scroll.width;
				if(itemsWidth + scroll.width <=  preferredWidth)
					scroll.size( preferredWidth-1,realHeight );
				else
					preferredWidth = itemsWidth + scroll.width;
				scroll.size( preferredWidth,realHeight+1 );
			}
		}
		if (scroll.active && isComboBox)
			scroll.scrollTo(index);
		
		certainHeight = 0;
	}
	public function set isList(b:Boolean):void
	{
		scroll.background = !isList;
		if( b )
			this.filters = null;
	}
	public function get isList():Boolean
	{
		return _isList;
	}
	public function showSelection():void
	{	// только для ListCheckBox, потому что тут не вызывается open
		if (!selection.visible && !selCurrent.visible) {
		//	selection.y = 0;
			selection.visible = true;
		}
	}
	public function hideSelection():void
	{	// только для ListCheckBox, потому что тут не вызывается open
		selection.visible = false;
	}
	
	public function doListNavigation(down:Boolean):void
	{
		if (!selection.visible && !selCurrent.visible)
			selection.y = lastSelectionPos;
		else {
			if (!selection.visible )
				selection.visible = true;
			if (down)
				selection.y += h;
			else
				selection.y -= h;
		}
		
		if (selection.y < 0 )
			selection.y = (num-1)*h;
		if (selection.y > (num-1)*h )
			selection.y = 0;
		
		if (scroll.active && isComboBox)
			scroll.scrollTo( (selection.y/h)-1 );

		lastSelectionPos = selection.y; 
		
		selection.visible = true;
	}
	public function doSelection():void
	{
		index = selection.y/h;
		
		if (isComboBox) {
			if( names.getItemAt(index).cls != null ) {
				switch(names.getItemAt(index).cls) {
					case MComboBox.M_Button:
						close();
						this.dispatchEvent( new BoxEvent( BoxEvent.MButton, names.getItemAt(index).data ));
						break;
				}
			} else if (data != names.getItemAt(index).data) {
				label = names.getItemAt(index).label;
				data = names.getItemAt(index).data;
				img = names.getItemAt(index).img;
				this.dispatchEvent( new BoxEvent( BoxEvent.IndexChange, true ));
				close();
			}
			
		} else {
			if ( !names.getItemAt(index).disabled && !(names.getItemAt(index).trigger is int && names.getItemAt(index).trigger == FSComboCheckBox.TRIGGER_I_SEPERATOR) )
				this.dispatchEvent( new BoxEvent( BoxEvent.IndexChange, true ));
		}
	}
/**	EVENTS			***/
	private function mClick(ev:MouseEvent):void
	{
		if ( scroll.pane.contains(ev.target as DisplayObject) ) {
			doSelection();
		}
	}
	private function mMove(ev:MouseEvent):void
	{ 
		selection.y = (scroll.pane.y*-1) + int((mouseY-1)/h)*h;
		lastSelectionPos = selection.y; 
	}
	private function mOver(ev:MouseEvent):void
	{
		selection.visible = true;
	}
	private function mOut(ev:MouseEvent):void
	{
		selection.visible = false;
	}
	private function getStage():Stage
	{
		if (stage)
			return stage;
		return FlexGlobals.topLevelApplication.stage;
	}
}
class TimeText extends TextField
{
	public static const CHANGE:String = "TimeTextChange";
	
	public var isComboBoxEditable:Boolean = false;	// check combobox editable или обычный combobox
	public var replace:Boolean = true;	// true - позволять управляющему компоненту подменять щначение лейбла 
	
	private var _time:Boolean;
	private var key:int;
	private var reLetters:RegExp = /[A-Za-zА-Яа-я]/g;
	private var image:Bitmap;
	public var UID:int = UTIL.generateUId();
	
	public function TimeText(h:int)
	{
		super();
		
		var textf:TextFormat = new TextFormat;
		textf.font = PAGE.MAIN_FONT;
		//textf.leading = -7;
		this.defaultTextFormat = textf;
		
		this.height = h;
		
		this.wordWrap = false;
		this.border = true;
		this.borderColor = COLOR.SIXNINE_GREY;
		this.background = true;
		this.multiline = false;
		
		this.addEventListener( Event.CHANGE, onChange );
	}
	public function set time(b:Boolean):void
	{
		_time = b;
		maxChars = 6;
		
		this.addEventListener( KeyboardEvent.KEY_DOWN, onKey );
	}
	private function onKey(e:KeyboardEvent):void
	{
		key = e.keyCode;
	}
	private function onChange(e:Event):void
	{
		if (_time) {
			var txt:String = this.text;
			
			txt = txt.replace(/:/g, "");
			if ( txt.search(reLetters) > -1 ) {
				txt = txt.replace(reLetters, "0");
				this.setSelection(1,1);
				replace = false;
			}
			switch( txt.length ) {
				case 0:
					txt += "00:00";
					break;
				case 1:
					txt += "0:00";
					break;
				case 2:
					txt += ":00";
					break;
				case 3:
					txt = txt.substr(0,2) + ":" + txt.substr(2,1) + "0";
					break;
				case 4:
					var t1:String = txt.substr(0,2);
					var t2:String = txt.substr(2,2);
					
					txt = txt.substr(0,2) + ":" + txt.substr(2,2);
					break;
				case 5:
					txt = txt.substr(0,2) + ":" + txt.substr(2,2);
					break;
			}
			this.text = txt.substr(0,5);
			
			if ( (this.caretIndex == 2 || this.caretIndex == 3) && key != KEYS.Backspace )
				this.setSelection(this.caretIndex+1,this.caretIndex+1);
		}
		if (!isComboBoxEditable)
			this.dispatchEvent( new Event(CHANGE) );
	}
	override public function set text(value:String):void
	{
		super.text = value == null ? "" : value;
	}
	public function set img(b:Class):void
	{
		if (image && parent.contains(image) )
			parent.removeChild( image );
		image = new b;
		parent.addChild( image );
	}
}
class BoxEvent extends Event {
	public static const IndexChange:String = "IndexChange";
	public static const MButton:String = "MButton";
	
	private var serviceObject:Object;
	
	public function BoxEvent( type:String, value:Object=null ) 
	{
		switch(type) {
			case IndexChange:
				serviceObject = {isMenuClicked:Boolean(value)};
				break;
			case MButton:
				serviceObject = {getButtonId:int(value)};
				break;
			default:
				serviceObject = value;
				break;
		}
		super( type );
	}
	public function isMenuClicked():int			//	IndexChange
	{
		return serviceObject["isMenuClicked"];
	}
	public function getButtonId():int			//	MButton
	{
		return serviceObject["getButtonId"];
	}
}