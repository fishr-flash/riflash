package components.gui.visual.wire
{
	import flash.display.Bitmap;
	
	import mx.core.UIComponent;
	
	import components.abstract.Utility;
	import components.abstract.servants.TabOperator;
	import components.gui.fields.FormString;
	import components.interfaces.IFormString;
	import components.screens.ui.UIWire;
	import components.system.Library;
	import components.system.SavePerformer;
	import components.system.UTIL;
	
	public class WireResBlock extends UIComponent
	{
		private var wirePic:Bitmap;
		private var wireGuuard1close:Bitmap;
		private var wireGuuard2close:Bitmap;
		
		private var tRes0:FormString;
		private var tRes1:FormString;
		private var tRes2:FormString;
		private var tRes3:FormString;
		
		private var alarm1:Flare;
		private var alarm2:Flare;
		private var alarm3:Flare;
		
		private var needToRewrite:Boolean;
		private var type:int;
		
		public var structure:int;

		private var fail1:SmbFail;
		private var fail2:SmbFail;
		private var fail3:SmbFail;
		
		public function WireResBlock()
		{
			super();
			
			wireGuuard1close = new Library.cType2single;
			addChild( wireGuuard1close );
			wireGuuard1close.x = 49;
			wireGuuard1close.y = 150;
			wireGuuard1close.visible = false;
			
			wireGuuard2close = new Library.cType2single;
			addChild( wireGuuard2close );
			wireGuuard2close.x = 49;
			wireGuuard2close.y = 87;
			wireGuuard2close.visible = false;
			
			tRes0 = new FormString;
			tRes0.setId(0);
			addRes( tRes0 );
			tRes0.x = 67;
			tRes0.y = 239;
			
			tRes1 = new FormString;
			addRes( tRes1 );
			tRes1.setId(1);
			tRes2 = new FormString;
			addRes( tRes2 );
			tRes2.setId(2);
			tRes3 = new FormString;
			addRes( tRes3 );
			tRes3.setId(3);
			
			alarm1 = new Flare;
			addChild( alarm1 );
			alarm2 = new Flare;
			addChild( alarm2 );
			alarm3 = new Flare;
			addChild( alarm3 );
			
			
			
			fail1 = new SmbFail;
			this.addChild( fail1 );
			fail2 = new SmbFail;
			this.addChild( fail2 );
			fail3 = new SmbFail;
			this.addChild( fail3 );
			
		}
		public function getFields():Array
		{	// порядок изменен для правильной регистрации в таб операторе
			return [tRes1, tRes2, tRes3, tRes0 ];
		}
		private function addRes(f:FormString):void
		{
			addChild( f )
			f.attune( FormString.F_EDITABLE | FormString.F_ALIGN_CENTER );
			f.restrict("0-9.",4 );
			f.setWidth( 35 );
			f.setHeight( 14 );
			f.setFormat(10);
			f.mathMultiplication = 1000;
			f.focusgroup = TabOperator.GROUP_FIELDS_AFTER_TABLE;
		}
		public function fill( _info:Array ):void
		{
			needToRewrite = UTIL.testIsGarbage( 0, _info );	
			
			if ( !needToRewrite ) {
				tRes0.setCellInfo( String(_info[3]/1000) );
				tRes1.setCellInfo(String(_info[0]/1000));
				tRes2.setCellInfo(String(_info[1]/1000));
				tRes3.setCellInfo(String(_info[2]/1000));
			}
		}
		public function focusgroup(value:Number):void
		{
			tRes0.focusgroup = value;
			tRes1.focusgroup = value;
			tRes2.focusgroup = value;
			tRes3.focusgroup = value;
		}
		public function putState(zone:int):void
		{
			alarm1.visible = false;
			alarm2.visible = false;
			alarm3.visible = false;
			
			
			switch(type) {
				case UIWire.TYPE_WIRE_NO:
					needToRewrite = false;
					break;
				case UIWire.TYPE_WIRE_FIRE_NOBATTERY:
					switch(zone) {
						case 1:
						case 6:
							fail1.onPlay();
							fail2.onPlay();
							fail3.onPlay();
							break;
						case 5:
							alarm1.visible = true;
						case 4:
							alarm2.visible = true;
						case 3:
							alarm3.visible = true;
							fail1.onStop();
							fail2.onStop();
							fail3.onStop();
							
							break;
					}
					break;
				case UIWire.TYPE_WIRE_FIRE_BATTERY:
					switch(zone) {
						case 1:
						case 6:
							fail1.onPlay();
							fail2.onPlay();
							fail3.onPlay();
							break;
						case 2:
							alarm3.visible = true;
						case 3:
							alarm2.visible = true;
						case 4:
							alarm1.visible = true;
							fail1.onStop();
							fail2.onStop();
							fail3.onStop();
							break;
					}					
					break;
				case UIWire.TYPE_WIRE_GUARD_RESIST:
					
					
					switch(zone) {
						case 1:
						case 6:
							fail1.onPlay();
							fail2.onPlay();
							break;
						case Utility.GUARD_RESIST_ALL:
							alarm1.visible = true;
							alarm2.visible = true;
							fail1.onStop();
							fail2.onStop();
							fail3.onStop();
							break;
						case Utility.GUARD_RESIST_FIRST:
							alarm1.visible = true;
							fail1.onStop();
							fail2.onStop();
							fail3.onStop();
							break;
						case Utility.GUARD_RESIST_SECOND:
							alarm2.visible = true;
							fail1.onStop();
							fail2.onStop();
							fail3.onStop();
							break;
					}
					
					break;
				case UIWire.TYPE_WIRE_GUARD_DRY:
					fail1.onStop();
					fail2.onStop();
					fail3.onStop();
					if( Utility.GUARD_DRY_OPEN ) {
						if (zone == 1)
							alarm1.visible = false;
						else
							alarm1.visible = true;
					} else {
						if (zone == 1)
							alarm1.visible = true;
						else
							alarm1.visible = false;
					}
					break;
			}
		}
		public function show(_type:int, bitmask:int, _created:Boolean=false ):void
		{
			type = _type;
			
			
			if( wirePic && this.contains( wirePic ) )
				removeChild( wirePic );
			
			wireGuuard1close.visible = false;
			wireGuuard2close.visible = false;
			
			tRes0.visible = false;
			tRes1.visible = false;
			tRes2.visible = false;
			tRes3.visible = false;
			
			alarm1.visible = false;
			alarm2.visible = false;
			alarm3.visible = false;
			
			
			fail1.onStop();
			fail2.onStop();
			fail3.onStop();
			
			var isChanged:Boolean=false;
			
			switch(type) {
				case UIWire.TYPE_WIRE_NO:
					needToRewrite = false;
					return;
					break;
				case UIWire.TYPE_WIRE_FIRE_BATTERY:
					wirePic = new Library.cType1;
					
					tRes1.x = 39;
					tRes1.y = 97;
					tRes2.x = 39;
					tRes2.y = 141;
					tRes3.x = 39;
					tRes3.y = 187;
					
					alarm1.x = 60+50;
					alarm1.y = 87+10+8;
					alarm2.x = 60+50;
					alarm2.y = 150+10-10;
					alarm3.x = 60+50;
					alarm3.y = 180+10+3;
					
					fail1.x = 60+50;
					fail1.y = 87+10+8;
					fail2.x = 60+50;
					fail2.y = 150+10-10;
					fail3.x = 60+50;
					fail3.y = 180+10+3;
					
					tRes0.visible = true;
					tRes1.visible = true;
					tRes2.visible = true;
					tRes3.visible = true;
					
					if ( needToRewrite || _created ) {
						tRes0.setCellInfo("10");
						tRes1.setCellInfo("5.1");
						tRes2.setCellInfo("5.1");
						tRes3.setCellInfo("5.1");
					}
					break;
				case UIWire.TYPE_WIRE_GUARD_RESIST:
					wirePic = new Library.cType2;
					
					alarm1.x = 61;
					alarm1.y = 103;
					alarm2.x = 61;
					alarm2.y = 166;
					
					fail1.x = 61;
					fail1.y = 103;
					fail2.x = 61;
					fail2.y = 166;
					
					tRes1.x = 93;
					tRes1.y = 167;
					tRes2.x = 93;
					tRes2.y = 105;
					tRes0.visible = true;
					tRes1.visible = true;
					tRes2.visible = true;
					
					if ( needToRewrite || _created ) {
						tRes0.setCellInfo("10");
						tRes1.setCellInfo("5.1");
						tRes2.setCellInfo("8.2");
					}
					
					wireGuuard1close.visible = Boolean( (bitmask & (1<<0)) != 0 );
					wireGuuard2close.visible = Boolean( (bitmask & (1<<1)) != 0 );
					break;
				case UIWire.TYPE_WIRE_FIRE_NOBATTERY:
					wirePic = new Library.cType3;
					
					alarm1.x = 33;
					alarm1.y = 90;
					alarm2.x = 33;
					alarm2.y = 142;
					alarm3.x = 33;
					alarm3.y = 196;
					
					fail1.x = 33;
					fail1.y = 90;
					fail2.x = 33;
					fail2.y = 142;
					fail3.x = 33;
					fail3.y = 196;
					
					tRes1.x = 43;
					tRes1.y = 97;
					tRes2.x = 43;
					tRes2.y = 150;
					tRes3.x = 43;
					tRes3.y = 205;
					tRes0.visible = true;
					tRes1.visible = true;
					tRes2.visible = true;
					tRes3.visible = true;
					
					if ( needToRewrite || _created ) {
						tRes0.setCellInfo("2.4");
						tRes1.setCellInfo("2.4");
						tRes2.setCellInfo("2.4");
						tRes3.setCellInfo("2.4");
					}
					
					break;
				case UIWire.TYPE_WIRE_GUARD_DRY:
					alarm1.x = 33+51;
					alarm1.y = 90+145;
					
					fail1.x = 33+51;
					fail1.y = 90+145;
					
					switch( bitmask ) {
						case 0:
							wirePic = new Library.cType4o;
							break;
						case 1:
							wirePic = new Library.cType4c;
							break;
					}
					break;
			}
			
			if(_created)
				change(tRes0);
			
			needToRewrite = false;
			addChildAt( wirePic, 0 );
		}
		public function getResitors():Array
		{
			var arr:Array = new Array;
			if ( tRes0.visible )
				arr.push( Number(tRes0.getCellInfo()) );
			if ( tRes1.visible )
				arr.push( Number(tRes1.getCellInfo()) );
			if ( tRes2.visible )
				arr.push( Number(tRes2.getCellInfo()) );
			if ( tRes3.visible )
				arr.push( Number(tRes3.getCellInfo()) );
			
			return arr;
		}
		public function change(target:IFormString):void
		{
			var value:Number;
			var num:int;
			switch(type) {
				case UIWire.TYPE_WIRE_FIRE_BATTERY:
				case UIWire.TYPE_WIRE_FIRE_NOBATTERY:
					num = (target as FormString).getId();
					if ( num != 0 ) {
						switch(num) {
							case 1:
								value = Number(tRes1.getCellInfo());
								break;
							case 2:
								value = Number(tRes2.getCellInfo());
								break;
							case 3:
								value = Number(tRes3.getCellInfo());
								break;
						}
						if (num != 1)
							tRes1.setCellInfo( String(value/1000));
						if (num != 2)
							tRes2.setCellInfo( String(value/1000));
						if (num != 3)
							tRes3.setCellInfo( String(value/1000));		
					}
					break;
			}
			SavePerformer.remember(structure,target);
		}
	}
}
import flash.display.Bitmap;
import flash.display.GradientType;
import flash.display.Sprite;
import flash.events.Event;

import components.static.COLOR;
import components.system.Library;

class Flare extends Sprite
{
	private const total_cycles:int = 10;
	private var cycle:int;
	private var brighten:Boolean=true;
	
	public function Flare():void
	{
		//this.graphics.beginGradientFill( GradientType.RADIAL, [COLOR.RED,COLOR.RED,COLOR.RED], [1,0,0], [0,40,100]);
		this.addEventListener( Event.ENTER_FRAME, onFrame );
	}
	private function onFrame(e:Event):void
	{
		this.graphics.clear();
		if (brighten) {
			cycle++;
			cycle++;
			if (cycle > total_cycles)
				brighten = false;
		} else {
			cycle--;
			cycle--;
			if (cycle < 1 )
				brighten = true;
		}
		this.graphics.beginGradientFill( GradientType.RADIAL, [COLOR.RED,COLOR.RED,COLOR.RED], [1,0,0], [0,40,100]);
		this.graphics.drawCircle(0,0,5 + 2*cycle);
	}
}


class SmbFail extends Sprite
{

	private var _bmp:Bitmap;
	private var _negative:Boolean = false;
	private var _step:Number = .03;
	
	public function SmbFail()
	{
		_bmp = new Library.smFail;
		_bmp.x -= _bmp.width / 2;
		_bmp.y -= _bmp.height / 2;
		this.addChild( _bmp );
		_bmp.visible = false;
		
		
		this.scaleX = this.scaleY = .15;
	}
	
	public function onPlay():void
	{
		if( !this.stage ) return;
		
		if( !this.hasEventListener( Event.ENTER_FRAME ) ) _bmp.alpha = 0;
		_bmp.visible = true;
		_negative = false;
		
		this.addEventListener(Event.ENTER_FRAME, onFrame );
		this.stage.addEventListener( Event.REMOVED_FROM_STAGE, onStop )
	}
	
	public function onStop():void
	{
			
		this.removeEventListener(Event.ENTER_FRAME, onFrame );
		if( this.stage )this.stage.removeEventListener( Event.REMOVED_FROM_STAGE, onStop );
		_bmp.alpha = 0;
		_bmp.visible = false;
		
			
	}
	protected function onFrame(event:Event):void
	{
		/*if( _bmp.alpha > 1 )_negative = true;
		else if( _bmp.alpha < 0 ) _negative = false;
		
		_bmp.alpha += _negative?-_step:_step;*/
		
		if( _bmp.alpha < 0 ) _bmp.alpha = 1;
		
		_bmp.alpha -= _step;
	}
	
	
}