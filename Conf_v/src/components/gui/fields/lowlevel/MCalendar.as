package components.gui.fields.lowlevel
{
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import mx.core.FlexGlobals;
	import mx.core.UIComponent;
	
	import components.abstract.functions.loc;
	import components.abstract.servants.ResizeWatcher;
	import components.gui.fields.FSComboBox;
	import components.gui.triggers.MButton;
	import components.interfaces.IResizeDependant;
	import components.static.COLOR;
	import components.system.UTIL;
	
	import foundation.Founder;
	
	public class MCalendar extends UIComponent implements IResizeDependant
	{
		private const DAY_HASH:Array = [6,0,1,2,3,4,5];
		private const MINIMUM_YEAR:int = 2012;	// меньше этого года нельзя выбрать на календаре
		private var month_list:Array;
		private var year_list:Array;
		
		private var m:Manager;
		private var month:FSComboBox;
		private var year:FSComboBox;
		private var shiftY:int;
		private var time:TimeText;
		private var bOk:MButton;
		private var callback:Function;
		private var bg:Sprite;
		private var comp:UIComponent;
		private var w:int;
		
		public function MCalendar()
		{
			super();

			bg = new Sprite;
			addChild( bg );
			
			m = new Manager;
			
			month_list = UTIL.getComboBoxList( [[0,loc("m_jan")],[1,loc("m_feb")],[2,loc("m_mar")],[3,loc("m_apr")],[4,loc("m_may")],[5,loc("m_jun")],
				[6,loc("m_jul")],[7,loc("m_aug")],[8,loc("m_sep")],[9,loc("m_oct")],[10,loc("m_nov")],[11,loc("m_dec")]] );
		
			var d:Date = new Date;
			year_list = [];
			var years:Array = [];
			while(true) {
				if (d.fullYear < MINIMUM_YEAR)
					break;
				years.push( [d.fullYear,d.fullYear.toString()] );
				d.fullYear -= 1;
			}
			year_list = UTIL.getComboBoxList( years );
				
			shiftY = 2;
			
			month = add(2,98,month_list);
			year = add(102,60,year_list);
			
			shiftY += 26;
			build();
			shiftY += 5;
			time = new TimeText(20);
			addChild( time );
			time.x = 2;
			time.y = shiftY;
			
			bOk = new MButton(loc("g_ok"), onComplete);
			addChild( bOk );
			bOk.width = 87;
			bOk.x = time.x + time.width + 5;
			bOk.y = shiftY;
			
			shiftY += 23;
		}
		public function open(c:UIComponent, f:Function, d:Date=null):void
		{
			comp = c;
			callback = f;
			//this.visible = true;
			var ui:UIComponent = Founder.app.getUIStage();
			ui.addChild( this );
			
			if (d)
				setDate( d );
			else
				setDate( new Date );
			
			callLater(addListener);
			ResizeWatcher.addDependent(this);
		}
		public function localResize(w:int, h:int, real:Boolean=false):void
		{
			resize();
		}
		override public function get height():Number
		{
			return shiftY;
		}
		private function resize():void
		{
			var p:Point = comp.localToGlobal( new Point(0, 0) );
			this.x = p.x;
			this.y = p.y - height;;
			
			
			var st:Stage = getStage();
			
			if( (this.x + this.width) > st.width )
				this.x = st.width - (this.width+40);
			
			if( (this.y + this.height) > st.height )
				this.y = st.height - this.height;
			
			var pglobal:Point = globalToContent(new Point(0,0));
			
			this.graphics.clear();
			this.graphics.beginFill(COLOR.BLUE,0.0);
			this.graphics.drawRect(pglobal.x, pglobal.y,
				getStage().stageWidth, getStage().stageHeight);
			this.graphics.endFill();
		}
		private function addListener():void
		{
			this.addEventListener( MouseEvent.CLICK, onClickOutside );
		}
		public function setDate(d:Date):void
		{
			month.setCellInfo( d.month );
			year.setCellInfo( d.fullYear );
			time.text = UTIL.fz(d.hours,2)+":"+UTIL.fz(d.minutes,2)+":"+UTIL.fz(d.seconds,2);
			m.day = d.date;
		}
		public function getDate():Date
		{
			var d:Date = new Date( String(year.getCellInfo()), int(month.getCellInfo()), m.day, time.hour, time.min, time.sec ); 
			return d;
		}
		public function close():void
		{
			var ui:UIComponent = Founder.app.getUIStage();
			if (ui.contains(this) )
				ui.removeChild( this );
			//getStage().removeEventListener( MouseEvent.CLICK, onClickOutside );
			this.removeEventListener( MouseEvent.CLICK, onClickOutside );
			ResizeWatcher.removeDependent(this);
		}
		private function onComplete():void
		{
			close();
			callback(getDate());
		}
		private function onClickOutside(e:MouseEvent):void
		{
			if (e.target == this)
				this.close();
		//	if ( !(e.target.parent is MScrolling) && e.target != this && !UTIL.isChildOf(e.target as DisplayObject, this) )
		///		this.close();
		}
		private function add(xpos:int, width:int, l:Array):FSComboBox
		{
			var fs:FSComboBox = new FSComboBox;
			addChild( fs );
			fs.y = shiftY;
			fs.x = xpos;
			fs.setCellWidth(width);
			fs.setList( l );
			fs.attune( FSComboBox.F_COMBOBOX_NOTEDITABLE );
			return fs;
		}
		private function build():void
		{
			var d:Date = new Date;
			var day:Day;
			var len:int = getDayCount(d.getFullYear(), d.getMonth());
			var shiftX:int = 2;
			for (var i:int=0; i<len; i++) {
				d.date = (i+1);
				day = new Day(i+1, m);
				addChild( day );
				day.x = DAY_HASH[d.day]*day.shift+shiftX;
				day.y = shiftY;
				if (d.day == 0)
					shiftY += day.shift;
			}
			
			bg.graphics.beginFill( COLOR.LIGHT_DC_GREY );
			bg.graphics.drawRoundRect(0,0, day.shift*7 + 4, day.shift*6 + 33, 5,5 );
			
			width = day.shift*7 + 4;
			height = day.shift*6 + 33 + 70;
		}
		private function getDayCount(year:int, month:int):int
		{
			var d:Date=new Date(year, month, 0);
			return d.getDate();
		}
		private function getStage():Stage
		{
			if (stage)
				return stage;
			return FlexGlobals.topLevelApplication.stage;
		}
	}
}
import flash.display.Sprite;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.text.TextField;
import flash.text.TextFormat;

import components.gui.SimpleTextField;
import components.static.COLOR;
import components.static.KEYS;
import components.static.PAGE;

class Manager
{
	private var selection:int;
	private var days:Vector.<Day>;
	public function get day():int
	{
		var len:int = days.length;
		for (var i:int=0; i<len; i++) {
			if( days[i].selection )
				return i+1;
		}
		return 0;
	}
	public function set day(n:int):void
	{
		select( days[n-1] );
	}
	public function register(d:Day):void
	{
		if( !days )
			days = new Vector.<Day>;
		days.push( d );
	}
	public function select(d:Day):void
	{
		selection = d.num;
		var len:int = days.length;
		for (var i:int=0; i<len; i++) {
			days[i].selection  = d == days[i];
		}
	}
}
class Day extends Sprite
{
	private var m:Manager;
	private var t:SimpleTextField;
	private var _selected:Boolean;
	private const size:int = 22;
	
	
	public var num:int;
	
	public function Day(n:int, m:Manager)
	{
		super();
		
		m.register(this);
		
		t = new SimpleTextField("",size);
		t.height = size;
		addChild( t );
		t.text = n.toString();
		t.setSimpleFormat("center");
		
		num = n;
		this.m = m;
		
		drawBg();
		
		this.addEventListener(MouseEvent.CLICK,onClick);
		this.addEventListener(MouseEvent.ROLL_OVER,onOver);
		this.addEventListener(MouseEvent.ROLL_OUT,onOut);
	}
	public function get shift():int
	{
		return size + 1;
	}
	public function set selection(b:Boolean):void
	{
		if (_selected != b) {
			if (b)
				drawSelect();
			else
				drawBg();
			_selected = b;
		}
	}
	public function get selection():Boolean
	{
		return _selected;
	}
	private function drawBg():void
	{
		this.graphics.clear();
		this.graphics.beginFill( COLOR.ANGELIC_GREY);
		this.graphics.drawRoundRect(0,0,size,size,5,5);
		this.graphics.endFill();
		t.textColor = COLOR.SATANIC_GREY;
	}
	private function drawSelect():void
	{
		this.graphics.clear();
		this.graphics.beginFill( COLOR.WHITE);
		this.graphics.drawRoundRect(0,0,size,size,5,5);
		this.graphics.endFill();
		this.graphics.lineStyle(1, COLOR.SATANIC_GREY);
		this.graphics.drawRect(0,0,size-1,size-1);
		t.textColor = COLOR.BLACK;
	}
	private function drawOver():void
	{
		this.graphics.clear();
		if(_selected)
			this.graphics.beginFill( COLOR.WHITE);
		else
			this.graphics.beginFill( COLOR.ANGELIC_GREY);
		this.graphics.drawRoundRect(0,0,size,size,5,5);
		this.graphics.endFill();
		this.graphics.lineStyle(1, COLOR.SIXNINE_GREY);
		this.graphics.drawRect(0,0,size-1,size-1);
	}
	private function onClick(e:MouseEvent):void
	{
		drawSelect();
		m.select( this );
	}
	private function onOver(e:Event):void
	{
		drawOver();
	}
	private function onOut(e:Event):void
	{
		if (_selected)
			drawSelect();
		else
			drawBg();
	}
}
class TimeText extends TextField
{
	public static const CHANGE:String = "TimeTextChange";
	
	private var key:int;
	private var reLetters:RegExp = /[A-Za-zА-Яа-я]/g;
	
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
		this.selectable = true;
		this.type = "input";
		this.maxChars = 9;
		this.restrict = "0-9";
		this.width = 67;
		
		this.addEventListener( Event.CHANGE, onChange );
		this.addEventListener( KeyboardEvent.KEY_DOWN, onKey );
	}
	public function get hour():int
	{
		var txt:String = this.text;
		txt = txt.replace(/:/g, "");
		return int(txt.slice(0,2));
	}
	public function get min():int
	{
		var txt:String = this.text;
		txt = txt.replace(/:/g, "");
		txt = txt.substr(2,2);
		return int(txt);
	}
	public function get sec():int
	{
		var txt:String = this.text;
		txt = txt.replace(/:/g, "");
		txt = txt.substr(4,2);
		return int(txt);
	}
	private function onKey(e:KeyboardEvent):void
	{
		key = e.keyCode;
	}
	private function onChange(e:Event):void
	{
		var txt:String = this.text;
		
		txt = txt.replace(/:/g, "");
		
		var place:int = 0;
		var part:String = "";
		var result:String = "";
		while(true) {
			part = txt.substr(place,2);
			while (part.length < 2)
				part += "0";
			result += part;
			if (result.length >= 8) {
				this.text = result.substr(0,8);
				break;
			} else {
				place += 2;
				result += ":";
			}
		}
		if ( (this.caretIndex == 2 || this.caretIndex == 3 || this.caretIndex == 5 || this.caretIndex == 6) && key != KEYS.Backspace )
			this.setSelection(this.caretIndex+1,this.caretIndex+1);
	}
	override public function set text(value:String):void
	{
		super.text = value == null ? "" : value;
	}
}