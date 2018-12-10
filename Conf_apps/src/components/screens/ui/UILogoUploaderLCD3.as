package components.screens.ui
{
	import flash.events.Event;
	
	import components.abstract.GroupOperator;
	import components.abstract.functions.loc;
	import components.basement.UI_BaseComponent;
	import components.events.GUIEvents;
	import components.gui.fields.FormString;
	import components.protocol.Package;
	import components.protocol.statics.CLIENT;
	import components.abstract.IconLoader;
	import components.static.CMD;
	import components.static.DS;
	import components.static.NAVI;
	
	public class UILogoUploaderLCD3 extends UI_BaseComponent
	{
		
		private var iconLoader:IconLoader;
		private var g:GroupOperator;
		private var h:int;
		private var opts:Vector.<OptKBDLogo> = new Vector.<OptKBDLogo>;
		public function UILogoUploaderLCD3()
		{
			super();
			
			iconLoader = new IconLoader;
			addChild( iconLoader );
			iconLoader.y = globalY;
			iconLoader.x = globalX;
			
			
			
			//g = logoLoader.height;
			
			g = new GroupOperator;
			
			g.add( "1", drawSeparator() );
			
			if( !DS.isfam( DS.LCD3 ) )
			{
				addui( new FormString, 0, loc("lcdkey_disable_usb_to_look_at_logo"), null, 1 );
				attuneElement( 400 );
				g.add( "1", getLastElement() );
				
			}
			
			opts.push( new OptKBDLogo( CMD.KBD_LOGO, 1 ) );
			this.addChild( opts[ 0 ] );
			opts[ 0 ].y = globalY;
			opts[ 0 ].x = globalX;
			g.add( "1", opts[ 0 ] );
			
			globalY += opts[ opts.length - 1 ].height;
			
			opts.push( new OptKBDLogo( CMD.KBD_LOGO, 2  ) );
			this.addChild( opts[ 1 ] );
			opts[ 1 ].y = globalY;
			opts[ 1 ].x = globalX;
			
			g.add( "1", opts[ 1 ] );
			
			globalY += opts[ opts.length - 1 ].height;
			
			
			
			
			
			
			
			
			
			starterCMD = [ CMD.KBD_LOGO ];
		}
		
		
		override public function open():void
		{
			super.open();
			iconLoader.init();
			iconLoader.setNewId( 1 );
			
			g.movey("1", 70);
			
			iconLoader.addEventListener( GUIEvents.EVOKE_CHANGE_HEIGHT, onChangeHeight );
			
			if (CLIENT.AUTOPAGE_WHILE_WRITING == NAVI.LOGO)
				onChangeHeight(null);
		}
		override public function close():void
		{
			iconLoader.removeEventListener( GUIEvents.EVOKE_CHANGE_HEIGHT, onChangeHeight );
		}
		
		override public function put(p:Package):void
		{
			opts[ 0 ].putData( p );
			opts[ 1 ].putData( p );
			loadComplete();
		}
		
		private function onChangeHeight(e:Event):void
		{
			g.movey("1", iconLoader.height + 60);
			
		}
	}
}
import components.abstract.functions.loc;
import components.basement.OptionsBlock;
import components.gui.fields.FSCheckBox;
import components.gui.fields.FSShadow;
import components.protocol.Package;
import components.static.DS;


class OptKBDLogo extends OptionsBlock
{
	
	public function OptKBDLogo(  opCmd:int, struct:int )
	{
		structureID = struct;
		operatingCMD = opCmd;
		
		init();
	}
	
	private function init():void
	{
		var label:String = "";
		
		switch( structureID ) 
		{
			case 1:
				if( DS.isfam( DS.LCD3 ) ) 
					label = loc( "show_logo" );
				else
					label = loc( "show_logo_on_start" );
				break;
			case 2:
				label = loc("power_on_on_screen" );
				break;
			
		}
		
		if( structureID == 1 || ( structureID == 2 && DS.isDevice( DS.LCD3 ) ))
		{
			addui( new FSCheckBox, operatingCMD, label, null, 1 );
			attuneElement( 500 );
		}
		else
		{
			addui( new FSShadow, operatingCMD, "", null, 1 );
		}
		
	}
	
	override public function putData(p:Package):void
	{
		pdistribute( p );
	}
}
