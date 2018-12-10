///*************************************
///*  © fishr (fishr.flash@gmail.com)  *
///*************************************

package su.fishr.display 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	
   /**
	 * Вспомогательный класс для изменения
	 * размеров растрового изображения и/или
	 * получения копии отображаемого содержимого
	 * переданного в аргументах наследника DisplayObject-а
	 * со сглаживанием, или без сглаживания.
	 * 
	 * @version                1.0
	 * @playerversion          Flash 9
	 * @langversion            3.0
	 * @author                 fishr
	 * @created                27.06.2011 13:03
	 */
	public final  class SmoothResizeDObject
	{
	/**-------------------------------------------------------------------------------
	* 
	*	   						V A R I A B L E ' S
	*
	* --------------------------------------------------------------------------------
	*/
	//{
	
		private static const IDEAL_RESIZE_PERCENT:Number = .5;
		private static var _rectShift:Rectangle;
		
	//}
	/**-------------------------------------------------------------------------------
	* 
	*								P U B L I C 	
	* 
	* --------------------------------------------------------------------------------
	*/
	//{
		{
			_rectShift = new Rectangle();
			
		}
		
		/**
		 * 	Усиленное сглаживание. Метод возвращает копию экр. объекта
		 * отрисованную в объект <code>Bitmap</code> со сглаживанием
		 * кратным значению второго аргумента вызова.
		 *  Создает копию изображения сглаживание которого напоминает
		 * действие фильтра Blur, однако, несколько другого качества
		 * и с неразмытыми краями.
		 * 
		 * @param	obj <code>DisplayObject</code> (любой его наследник)
		 *              с открытым доступом к пикселям, не превышающий
		 *              максимально допустимого размера
		 * @param	grad требуемая кратность сглаживания.
		 * @return	экземпляр Bitmap отрисованный с требуемым сглаживанием.
		 */
		static public function strongSmoothing( obj:DisplayObject, grad:int):Bitmap
		{
			var bitmap:Bitmap;
			var bitmapBig:Bitmap;
			var wth:int = obj.width;
			
			bitmap = SmoothResizeDObject.resizeDisplayObject( obj, "width", wth, false );
			
			for ( var i:int = 0; i < grad; i++ )
			{
				bitmapBig = SmoothResizeDObject.resizeDisplayObject( bitmap, "width", bitmap.width / 2, false );
				bitmap.bitmapData.dispose();
				bitmap = null;
				bitmap = SmoothResizeDObject.resizeDisplayObject( bitmapBig, "width", wth, true );
				bitmapBig.bitmapData.dispose();
				bitmapBig = null;
				
			}
			
			return bitmap;
		}
		/**
		 * Принимает отображаемый объект наследующий DisplayObject,
		 * с открытым доступом к пикселам, 
		 * возвращает копию объекта отрисованного в
		 * Bitmap требуемого размера.
		 * Умеет работать с объектами повернутыми
		 * вокруг своей оси. Или масштабированным
		 * по осям x,y. 
		 * <p>
		 * <b>Внимание.</b>
		 *   Если свойство <code>matrix</code> объекта равно <code>null</code> попытка
		 * использовать метод вызовет ошибку.
		 * </p>
		 * 
		 * @param	dObj любой объект наследующий DisplayObject
		 * @param	prop одно из двух свойств объекта, которому требуется пропорционально изменить размер,
		 * 			<code>height</code> или <code>width</code>
		 * @param	size требуемый "выходной" размер заданной в <code>param</code> строны (другая
		 *          сторона изображения будет уменьшена пропорционально).
		 * @param	smooth выключить сглаживание (по умолчанию включено - true), имеет смысл выключить если нужна
		 *          точная копия DisplayObject отрисованная в Bitmap без изменения масштаба.
		 * @return  копия визуального содержимого экр. объекта полученного в параметрах вызова метода.
		 */
		static public function resizeDisplayObject(dObj:DisplayObject, prop:String, size:Number, smooth:Boolean = true):Bitmap
		{
			var scale:Number;
			var bitmap:DisplayObject;
			/// копируем копируем изменения матрицы.
			_rectShift = dispCorrection(dObj);
			bitmap = resizes(dObj, 1, smooth);
			_rectShift.x = _rectShift.y = 0;
			
			
			
			switch (dObj[prop] !== size)
			{
			
				case dObj[prop] > size:
				
					scale = .5;
					
					while ( bitmap[prop] * scale > size )
					{
						bitmap = resizes( bitmap, scale, smooth );
					}
					
					break;
				
				case dObj[prop] < size:
					
					scale = 2;

					while ( bitmap[prop] * scale < size )
					{
						bitmap = resizes( bitmap, scale, smooth );
					}
					
					break;
			}
			
			scale = size / bitmap[prop];
			bitmap = resizes(bitmap, scale, smooth);
			
			return bitmap as Bitmap;
		}
		
		/**
		 *  Масштабирует, затем обрезает (клипинг) переданный DisplayObject.
		 * 
		 * @param	obj любой экр.объект наследующий DisplayObject
		 * @param	w целевая ширина
		 * @param	h целевая высота
		 * @param	align определяет сохраняемую область (возможные значения: <code>"left"</code>, <code>"right"</code>, <code>"center"</code>)
		 * 			по умолчанию <code>"center"</code>
		 * @param	indent - отступ слевой стороны (если требуется не равномерное смещение
		 * @return  <code>Bitmap</code> - копия переданного <code>DisplayObect</code>
		 * 
		 * @private
		 */
		static public function clipingDObject(obj:DisplayObject, w:Number, h:Number, align:String = "center", indent:Number = 0):Bitmap
		{
			var bitmap:Bitmap = SmoothResizeDObject.resizeDisplayObject( obj, "height", h, true);
			
			if ( bitmap.width < w ) bitmap = SmoothResizeDObject.resizeDisplayObject( bitmap, "width", w );
			
			var rect:Rectangle = new Rectangle( ( bitmap.width - w ) / 2, ( bitmap.height - h ) / 2, w, h );
			var newBitmapData:BitmapData = new BitmapData( w, h, true, 0x00);
			newBitmapData.copyPixels( bitmap.bitmapData, rect, new Point(0, 0));
			var newBitmap:Bitmap = new Bitmap( newBitmapData );
			
			return newBitmap;
			
			
		}
		
		
		///solution of JacobWright (http://jacwright.com/221/high-quality-high-performance-thumbnails-in-flash/)
		/**@private**/
		static public function resizeImage(source:BitmapData, width:uint, height:uint, constrainProportions:Boolean = true):BitmapData
		{

			var scaleX:Number = width/source.width;
			var scaleY:Number = height/source.height;
			if (constrainProportions) {
					if (scaleX > scaleY) scaleX = scaleY;
					else scaleY = scaleX;
			}

			var bitmapData:BitmapData = source;

			if (scaleX >= 1 && scaleY >= 1) {
					bitmapData = new BitmapData(Math.ceil(source.width*scaleX), Math.ceil(source.height*scaleY), true, 0);
					bitmapData.draw(source, new Matrix(scaleX, 0, 0, scaleY), null, null, null, true);
					return bitmapData;
			}

			// scale it by the IDEAL for best quality
			var nextScaleX:Number = scaleX;
			var nextScaleY:Number = scaleY;
			while (nextScaleX < 1) nextScaleX /= IDEAL_RESIZE_PERCENT;
			while (nextScaleY < 1) nextScaleY /= IDEAL_RESIZE_PERCENT;

			if (scaleX < IDEAL_RESIZE_PERCENT) nextScaleX *= IDEAL_RESIZE_PERCENT;
			if (scaleY < IDEAL_RESIZE_PERCENT) nextScaleY *= IDEAL_RESIZE_PERCENT;

			var temp:BitmapData = new BitmapData(bitmapData.width*nextScaleX, bitmapData.height*nextScaleY, true, 0);
			temp.draw(bitmapData, new Matrix(nextScaleX, 0, 0, nextScaleY), null, null, null, true);
			bitmapData = temp;

			nextScaleX *= IDEAL_RESIZE_PERCENT;
			nextScaleY *= IDEAL_RESIZE_PERCENT;

			while (nextScaleX >= scaleX || nextScaleY >= scaleY) {
					var actualScaleX:Number = nextScaleX >= scaleX ? IDEAL_RESIZE_PERCENT : 1;
					var actualScaleY:Number = nextScaleY >= scaleY ? IDEAL_RESIZE_PERCENT : 1;
					temp = new BitmapData(bitmapData.width*actualScaleX, bitmapData.height*actualScaleY, true, 0);
					temp.draw(bitmapData, new Matrix(actualScaleX, 0, 0, actualScaleY), null, null, null, true);
					bitmapData.dispose();
					nextScaleX *= IDEAL_RESIZE_PERCENT;
					nextScaleY *= IDEAL_RESIZE_PERCENT;
					bitmapData = temp;
			}

			return bitmapData;
		}
	//}
	
	/**-------------------------------------------------------------------------------
	* 
	*								P R I V A T E 	
	* 
	* --------------------------------------------------------------------------------
	*/	
	//{
		
		
		private static function resizes(dObj:DisplayObject, scale:Number, smooth:Boolean):Bitmap
		{

			var bitmapData:BitmapData = new BitmapData(dObj.width * scale, dObj.height * scale, true, 0x00);
			bitmapData.lock();

			var scaleMatrix:Matrix = new Matrix(dObj.transform.matrix.a * scale,
												dObj.transform.matrix.b,
												dObj.transform.matrix.c,
												dObj.transform.matrix.d * scale,
												dObj.transform.matrix.tx - dObj.x - _rectShift.x,
												dObj.transform.matrix.ty - dObj.y - _rectShift.y);
			

			bitmapData.draw( dObj, 
							scaleMatrix, 
							dObj.transform.colorTransform, 
							"normal", 
							null,
							smooth);
			
			
			var bitmap:Bitmap = new Bitmap(bitmapData, "auto", smooth);
			bitmap.x +=dObj.x + _rectShift.x;
			bitmap.y +=dObj.y + _rectShift.y;
		
			
			bitmapData.unlock();
			
			/// Удаляем отработавший объект
			/// ...если это не тот который был принят
			/// в арг. вызова...
			if ( scale !== 1)
			{
				with( Bitmap(dObj))
				{
						bitmapData.dispose();
						bitmapData = null;
				}
				
				dObj = null;
			}

			
			return bitmap;
			
			
			
		}
		
		
		/**
		 *  Высчитывает смещение объекта относительно
		 * его внутренней системы координат, для 
		 * поправки размещения на сцене.
		 * @param	obj
		 * @return
		 */
		private static function dispCorrection(obj:DisplayObject):Rectangle
		{
			var sp:Sprite = new Sprite();
			var rect:Rectangle;
			var childIndex:uint;
			
			
			if ( obj.parent !== null)
			{
				childIndex = obj.parent.getChildIndex(obj);
				obj.parent.addChildAt(sp, childIndex);
				sp.x = obj.x;
				sp.y = obj.y;
				sp.addChild(obj);
				rect = obj.getBounds(sp);
				rect.x -= obj.x;
				rect.y -= obj.y;
				sp.parent.addChildAt(obj, childIndex);
				obj.x = sp.x;
				obj.y = sp.y;
				obj.parent.removeChild(sp);
				sp = null;
				
			}
			else
			{
				sp.addChild(obj);
				rect = obj.getBounds(sp);
				rect.x -= obj.x;
				rect.y -= obj.y;
				sp.removeChild(obj);
				sp = null;
				
				
			}
			
			return rect;
			
		}
		
		
	//}
		
		
	}

}
