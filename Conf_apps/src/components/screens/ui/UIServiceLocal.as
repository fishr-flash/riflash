package components.screens.ui
{
	import components.interfaces.IServiceFrame;
	import components.screens.page.UploaderGraphicsForLCD3;
	import components.static.DS;
	import components.static.MISC;
	

	public class UIServiceLocal extends UIServiceAdv
	{
		public static const SEPARATOR_WIDTH:int = 370;
		
		public function UIServiceLocal()
		{
			super();
		}
		override protected function getModuls():Array 
		{
			var arr:Array;
			if( DS.isfam( DS.LCD3 ) ) arr = [ addConfigOfLCD3,  addUploaderLCD3 ];
			else arr = [ addConfig ];
			
			
			
			if (MISC.COPY_DEBUG)
				arr = arr.concat( [ addFirmware ] );
			
			return arr;
		}
		
		protected function addUploaderLCD3():IServiceFrame
		{
			var target:UploaderGraphicsForLCD3 = new UploaderGraphicsForLCD3();
			target.visible = false;
			addChild( target );
			target.x = globalX;
			target.y = 170;
			return target;
		}
	}
}