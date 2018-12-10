package components.screens.ui
{
	import flash.display.Bitmap;
	
	import components.abstract.functions.loc;
	import components.basement.UI_BaseComponent;
	import components.events.GUIEventDispatcher;
	import components.events.SystemEvents;
	import components.gui.Header;
	import components.gui.triggers.TextButton;
	import components.gui.visual.Indent;
	import components.protocol.Package;
	import components.protocol.statics.OPERATOR;
	import components.abstract.IconLoader;
	import components.static.CMD;
	import components.system.SavePerformer;
	
	public class UIZones extends UI_BaseComponent
	{

		private var iconLoader:IconLoader;

		private var opts:Vector.<OptZonesInf>;
		public function UIZones()
		{
			super();
			
			init();
		}
		
		private function init():void
		{
			
				
			const headers:Array =
			[
				new Header
				(
					[
						{ label:loc( "sms_menu_zone" ), xpos:0, width: 70 },
						{ label:loc( "out_title" ), xpos:85, width:100 },
						{ label:loc( "g_show" ), xpos:185, width:100 }
						
					]
				),
				
				new Header
				(
					[
						{ label:loc( "sms_menu_zone" ), xpos:0, width: 70 },
						{ label:loc( "out_title" ), xpos:85, width:100 },
						{ label:loc( "g_show" ), xpos:185, width:100 }
						
					]
				),
				
				new Header
				(
					[
						{ label:loc( "sms_menu_zone" ), xpos:0, width: 70 },
						{ label:loc( "out_title" ), xpos:85, width:100 },
						{ label:loc( "g_show" ), xpos:185, width:100 }
						
					]
				)
				
			];
			
			this.addChild( headers[ 0 ] );
			
			opts = new Vector.<OptZonesInf>();
			var yy:int = globalY;
			var xx:int = globalX;
			var len:int = OPERATOR.getSchema( CMD.KBD_ZONES_NAME ).StructCount;
			var lastY:int = globalY;
			for (var i:int=0; i<len; i++) 
			{
				if( !(i%16) ) 
				{
					if( i )
					{
						const indent:Indent = drawIndent( yy );
						indent.y = 15;
						indent.alpha = .3;
						xx += opts[ i - 1 ].width - 60;
						indent.x = xx;
						xx += 30;
					}
					yy = 15;
					
					const header:Header = headers[ i / 16 ];
					header.y = yy;
					header.x = xx;
					yy += header.height + 40;
					this.addChild( header  );
					
					
				}
				
				opts.push( new OptZonesInf( i + 1 ) );
				opts[ i ].x = xx;
				opts[ i ].y = yy;
				yy += opts[ i ].height - 10;
				this.addChild( opts[ i ] );
				if( yy > lastY ) lastY = yy;
				
			}
			
			globalY = lastY + 20;
			drawSeparator( 700 );
			
			var butReset:TextButton = new TextButton;
			butReset.setUp( loc("sms_h_value_defaults" ), upDefault );
			butReset.y = globalY;
			butReset.x = globalX;
			this.addChild( butReset );
			
			globalY = butReset.y + butReset.height;
			globalX = butReset.x + butReset.width;
			
			iconLoader = new IconLoader();
			iconLoader.init();
			
			starterCMD = [ CMD.KBD_ZONES_NAME ];
		}
		
		override public function open():void
		{
			super.open();
			
			
			SavePerformer.trigger( { "cmd": refine } ); 
		}
		
		private function refine(value:Object):int
		{
			if(value is int) {
				switch(value) {
					case CMD.KBD_ZONES_NAME:
						
						return SavePerformer.CMD_TRIGGER_TRUE;
						
				}
			} else {
				
				GUIEventDispatcher.getInstance().fireSystemEvent( SystemEvents.onBlockNavigation, {"isBlock":true} );
				const bitmap:Bitmap = opts[ value.struct - 1 ].redrawValue();
				iconLoader.setAnyImageForLCD( 120 + value.struct, bitmap  );
				
			}
			return SavePerformer.CMD_TRIGGER_FALSE;
		}
		
		override public function put(p:Package):void
		{
			var len:int = OPERATOR.getSchema( CMD.KBD_ZONES_NAME ).StructCount;
			for (var i:int=0; i<len; i++) 
			{
				opts[ i ].putData( p );
			}
			loadComplete();
		}
		
		private function upDefault():void
		{
			var len:int = OPERATOR.getSchema( CMD.KBD_ZONES_NAME ).StructCount;
			for (var i:int=0; i<len; i++) 
			{
				opts[ i ].putRawData([ loc( "g_zone" ) + " ", ( i + 1 ) + ""  ] );
			}
			
		}
		
	}
}

import flash.display.Bitmap;

import components.abstract.TextSnapshoter;
import components.abstract.functions.loc;
import components.basement.OptionsBlock;
import components.gui.SimpleTextField;
import components.gui.fields.FSCheckBox;
import components.gui.fields.FSShadow;
import components.gui.fields.FSSimple;
import components.gui.fields.FormEmpty;
import components.protocol.Package;
import components.static.CMD;
import components.system.SavePerformer;


class OptZonesInf extends OptionsBlock
{
	public var isoData:Bitmap;

	private var multistring:FSSimple;
	private var checkerSecStr:SimpleTextField = new SimpleTextField("" );
	
	public function OptZonesInf( strId:int )
	{
		
		super();
		structureID = strId;
		
		init();
	}
	
	private function init():void
	{
		//globalX += 20;
		const horLine:int = globalY;
		
		FLAG_SAVABLE = false;
		
		multistring = addui( new FSSimple(), 0, loc( "rf_sen_h_zone" )+ " " + structureID, analiseText, 1, null, "", 21  ) as FSSimple;	
		attuneElement( 70, TextSnapshoter.WIDTH_TEXTFIELD, FSSimple.F_CELL_MULTYLINE );
		multistring.setCellInfo( loc( "rf_sen_h_zone" )+ " " + structureID );
		multistring.setHeight( TextSnapshoter.HEIGHT_TEXTFIELD );
		
		FLAG_SAVABLE = true;
		
		addui( new FSShadow(), CMD.KBD_ZONES_NAME, "", null, 1, null, "", 10 );
		addui( new FSShadow(), CMD.KBD_ZONES_NAME, "", null, 2, null, "", 10 );
		
		const box:FormEmpty = addui( new FSCheckBox(), CMD.KBD_ZONES_NAME, "", null, 3 );
		attuneElement( 0, NaN );
		getLastElement().y = horLine;
		getLastElement().x = multistring.width + 40;
		
	}
	
	private function analiseText():void
	{
		
		var str:String = multistring.getCellInfo() as String;
		/// защита от случайного переноса
		const reg:RegExp = /\r|\t|\n/gx; 
		if( str.search( reg ) == 0 || str.search( reg ) == 1 )str = str.replace( reg, "" );
		
		
		
		
		if( ( str.length >= 11 && str.indexOf( "\r" )  == -1 ) || multistring.cell.textWidth >= TextSnapshoter.WIDTH_TEXTFIELD ) 
		{
			
			const t1:String = str.substr( 0, 10 );
			const t2:String = str.substr( 10, str.length - 1 );
			
			str = t1 + "\r" + t2;
			multistring.cell.text = str;
			multistring.cell.setSelection( multistring.cell.text.length, multistring.cell.text.length );
		}
		
		
		
		/// удаляем последующие переносы
		var arr:Array = str.split("\r" );
		var len:int = arr.length;
		str = arr[ 0 ];
		var secondStr:String = "";
		for (var i:int=1; i<len; i++)
			secondStr += arr[ i ].slice( 0, arr[ i ].length );
		
		secondStr = cutLongLine( secondStr );
		str = cutLongLine( str );
		
		function cutLongLine( txt:String ):String
		{
			checkerSecStr.text = txt;
			
			while( checkerSecStr.text.length > 10 || checkerSecStr.textWidth > TextSnapshoter.WIDTH_TEXTFIELD )
			{
				
				checkerSecStr.text = txt.slice( 0, txt.length - 1 );
				txt = checkerSecStr.text;
			}
			
			return txt;
		}
		
		if( len > 1 && str.indexOf( "\r" ) == -1 ) str += "\r";
		str += secondStr;
		multistring.cell.text = str;
		
		
		
		const lineBreak:int = multistring.cell.text.indexOf( "\r" );
		
		getField( CMD.KBD_ZONES_NAME, 1 ).setCellInfo( multistring.cell.text.slice( 0, lineBreak >-1?lineBreak:int.MAX_VALUE ) );
		
		if( lineBreak > -1 )
		{
			getField( CMD.KBD_ZONES_NAME, 2 ).setCellInfo( multistring.cell.text.split( "\r"  )[ 1 ]  );
		}
		
		
		
		
		SavePerformer.remember( structureID, getField( CMD.KBD_ZONES_NAME, 1 ) );
		
		
		
	}
	
	public function redrawValue():Bitmap
	{
		isoData = TextSnapshoter.self.snapshotTextField( multistring.getCellInfo() as String );
		
		//this.addChild( isoData );
		///FIXME: Отладочный код, в продакшене не должно быть дубликатов
		return new Bitmap( isoData.bitmapData.clone() );
		
	}
	
	override public function putRawData( a:Array ):void 
	{
		multistring.setCellInfo( a[ 0 ] + a[ 1 ] );
		getField( CMD.KBD_ZONES_NAME, 1 ).setCellInfo( a[ 0 ] + a[ 1 ] );
		getField( CMD.KBD_ZONES_NAME, 2 ).setCellInfo( "" );
		getField( CMD.KBD_ZONES_NAME, 3 ).setCellInfo( 1 );
		
		SavePerformer.remember( structureID, getField( CMD.KBD_ZONES_NAME, 1 ) );
		SavePerformer.remember( structureID, getField( CMD.KBD_ZONES_NAME, 2 ) );
	}
	
	override public function putData(p:Package):void 
	{
		pdistribute( p );
		const txt1:String = getField( CMD.KBD_ZONES_NAME, 1 ).getCellInfo() as String;
		const txt2:String = "\r" + getField( CMD.KBD_ZONES_NAME, 2 ).getCellInfo() as String;
		multistring.setCellInfo( txt1 + txt2 );
		
	}
	
	
}