package components.gui.fields
{
	import flash.display.Bitmap;

	public class FSTextPic extends FormString
	{
		private var pic:Bitmap;
		
		public function FSTextPic()
		{
			super();
		}
		public function attachPic( _bmp:Class ):void
		{
			
			pic = new _bmp;
			addChild( pic );
			pic.x = tName.width;
		}
		override public function get width():Number
		{
			
			return pic?pic.x + pic.width:0;
			
		}
	}
}