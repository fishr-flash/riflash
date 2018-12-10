///********************************************************************
///* Copyright © 2011 fishr (fishr.flash@gmail.com)  
///********************************************************************


package su.fishr.geom 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.geom.Point;
   /**
	 *  Нарезает ДОбъект на фрагменты
	 * указанных размеров. Возвращает
	 * двух уровневый массив ( столбцы и ряды )
	 * фрагментов - Bitmap.
	 * 
	 * 
	 * @version                1.0
	 * @playerversion          Flash 9
	 * @langversion            3.0
	 * @author                 fishr
	 * @created                11.08.2011 0:59
	 * @since                  11.08.2011 0:59
	 */
    final public class CuttingDObject
	{
	/**-------------------------------------------------------------------------------
	* 
	*	   						V A R I A B L E ' S 	
	* 
	* --------------------------------------------------------------------------------
	*/
	//{
	        public static const AUTHOR:String = "fishr (fishr.flash@gmail.com)";
	//}
	
	/**-------------------------------------------------------------------------------
	* 
	*	 						P R O P E R T I E S 	
	* 
	* --------------------------------------------------------------------------------
	*/
	//{
	
	//}
	/**-------------------------------------------------------------------------------
	* 
	*								P U B L I C 	
	* 
	* --------------------------------------------------------------------------------
	*/
	//{
		
		/**
		 *  Нарезает экр.объект (DisplayObject) на
		 * фрагменты заданного размера. 
		 * Возвращает двух уровневый массив Bitmap-фрагментов.
		 * 
		 * @param	obj экр. объект (любой потомок DisplayObject с доступом к пикселам)
		 * @param	w ширина фрагмента
		 * @param	h высота фрагмента
		 * @param	vertical столбцы вертикальные или горизонтальные. По умолчанию горизонтальные.
		 * @return двухуровневый массив фрагментов Bitmap()
		 */
		static public function cuttingDObject(obj:DisplayObject, w:uint, h:uint, vertical:Boolean = false):Array
		{
			var sp:Sprite = new Sprite();
			var bData:BitmapData = new BitmapData( obj.width, obj.height, true);
			var fragments:Array;
			sp.addChild( obj );
			bData.draw( obj, new Matrix(), null, null, obj.getBounds( sp ), false);
			
			
			fragments = cuttingBitmapData( bData, w, h, vertical );
			
			return fragments;
		}
		
		
	//}
	
	/**-------------------------------------------------------------------------------
	* 
	*								P R I V A T E 	
	* 
	* --------------------------------------------------------------------------------
	*/	
	//{
		static private function cuttingBitmapData(bData:BitmapData, w:uint, h:uint, vertical:Boolean):Array 
		{
			var coloumn:Array = new Array();
			var widthFr:Number = w;
			var heightFr:Number = h;
			var rect:Rectangle = new Rectangle( 0, 0, widthFr, heightFr );
			var rows:Array;
			var size:String = vertical === true? "width":"height";
			var pos:String = vertical === true? "x":"y";
			
			while ( rect[pos] + rect[size] < bData[size] )
			{
				rows = cuttingRows( bData, rect, pos, size );
				coloumn.push( rows );
				rect[pos] += rect[size];
				
				if ( pos === "y" ) rect.x = 0;
				else rect.y = 0;
				
				
			}

			rect[size] = bData[size] - rect[pos];
			if ( pos === "y" ) rect.x = 0;
			else rect.y = 0;
			rows = cuttingRows( bData, rect, pos, size );
			coloumn.push( rows );
			
			return coloumn;
		}
		
		static private function cuttingRows(bData:BitmapData, rect:Rectangle, p:String, s:String):Array
		{
			var rows:Array = new Array();
			var fragmentData:BitmapData;
			var fragment:Bitmap;
			var pos:String = p === "y"? "x":"y";
			var size:String = s === "height"?"width":"height";
			var oldSize:int = rect[size]
			
			while ( rect[pos] + rect[size] < bData[size] )
			{
				fragmentData = new BitmapData(rect.width, rect.height, true, 0x00);
				fragmentData.copyPixels( bData, rect, new Point(0, 0), bData, new Point(rect.x, rect.y));
				fragment = new Bitmap( fragmentData );
				fragment.x = rect.x;
				fragment.y = rect.y;
				rows.push( fragment );
				rect[pos] += rect[size];
			}
			
			rect[size] = bData[size] - rect[pos];
			
			fragmentData = new BitmapData(rect.width, rect.height, true, 0x00);
			fragmentData.copyPixels( bData, rect, new Point(0, 0), bData, new Point(rect.x, rect.y));
			fragment = new Bitmap( fragmentData );
			fragment.x = rect.x;
			fragment.y = rect.y;
			rows.push( fragment );
			rect[size] = oldSize;
			return rows;
			
		}
	//}
		
		
	}

}