package components.abstract.functions
{
	
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.text.TextFormatAlign;
	
	import components.abstract.functions.loc;
	import components.gui.SimpleTextField;
	
	public function createLockScreen( protec:DisplayObjectContainer ):Sprite
	{
		
		const fwall:Sprite = new Sprite();
		fwall.graphics.beginFill( 0xFFFFFF, .75 );
		fwall.graphics.drawRect(0, 0, protec.width, protec.height );
		fwall.name = "fwall";
		
		protec.addChild( fwall );
		
		const label:SimpleTextField = new SimpleTextField( loc("warning_settings_blocked"), 650, 0xBB0000 );
		label.setSimpleFormat( TextFormatAlign.CENTER, 0, 20, true );
		fwall.addChild( label );
		label.x =  ( protec.width - label.width ) / 2;
		label.y = ( protec.height - label.height ) / 2;
		
		
		
		return fwall;
	}
}

