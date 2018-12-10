package su.fishr.display 
{
	import flash.display.Shape;
	import flash.display.Sprite;
	
	public function DrawFrame(w:Number, h:Number, subject:Sprite):void
	{
		with ( subject.graphics )
		{
			clear();
			lineStyle( 0, 0x00FF00, 0 );
			lineTo(1, 0);
			moveTo(w, 0);
			lineTo(w, 1 );
			moveTo(w, h );
			lineTo( w - 1, h );
			moveTo( 0, h );
			lineTo(0,  h - 1);
			endFill();
		}
	}
}