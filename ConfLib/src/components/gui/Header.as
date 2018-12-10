package components.gui
{
	import mx.core.UIComponent;
	
	public class Header extends UIComponent
	{
		public static const ALIGN_CENTER:String = "center";
		public static const ALIGN_LEFT:String = "left";
		public static const ALIGN_RIGHT:String = "right";
		private var headers:Vector.<SimpleTextField>;
		private var cPositions:Array = [ 0 ];
		
		public function get coloumnPositions():Array
		{
			return cPositions;
		}
		
		public function Header(arr:Array, global:Object=null)
		{
			super();
			
			var size:int = 12;
			var leading:int = 1;
			var posRelative:Boolean = false;
			var valign:String = "normal";
			var align:String;
			var border:Boolean = false;
			if (global){
				if(global.size)
					size = global.size;
				if(global.leading)
					leading = global.leading;
				if (global.posRelative)
					posRelative = global.posRelative;
				if (global.valign)
					valign = global.valign;
				if (global.border)
					border = true;
				if (global.align is String)
					align = global.align;
			}
			
			var stf:SimpleTextField;
			var localX:int;
			var previousX:int=0;
			headers = new Vector.<SimpleTextField>;
			var len:int = arr.length;
			for (var column:int=0; column<len; column++) {
				
			//for(var column:String in arr) {
				//trace( arr[column].width );
				var w:int = 0;
				if(arr[column].width)
					w = arr[column].width; 
				
				stf = new SimpleTextField( arr[column].label, w );
				var aln:String = "left";
				if (align)
					aln = align;
				if(arr[column].align)
					aln = arr[column].align;
					
				stf.setSimpleFormat(aln,leading,size,true);
				stf.border = border;
				addChild( stf );
				if ( arr[column].xpos is int ) {
					if (posRelative)
						stf.x = previousX + arr[column].xpos;
					else
						stf.x = arr[column].xpos;
				} else {
					stf.x = localX;
					localX += stf.width + 10;
				}
				switch(valign) {
					case "normal":
						if ( stf.numLines > 1 ) {
							stf.y -= int(stf.height/4);
						}
						break;
					case "top":
						break;
				}
				previousX = stf.x + stf.width;
				cPositions.push( previousX );
				headers.push( stf );
			}
		}
		/**
		 *  Выводит рамки текст. блоков
		 * для облегчения позиционирования
		 */
		public function showBorder():void
		{
			var len:int = headers.length;
			for (var i:int=0; i<len; i++) {
				headers[ i ].border = true;
			}
			
		}
		public function vis(num:int, value:Boolean):void
		{
			if ( num < headers.length )
				headers[num].visible = value;
		}
	}
}