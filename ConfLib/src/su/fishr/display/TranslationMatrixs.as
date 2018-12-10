package su.fishr.display 
{
	import flash.display.DisplayObject;
	import flash.geom.Matrix;
	import flash.geom.Matrix3D;
	/**
	 * 
	 *  Класс предназначен для трансляции матриц
	 * отображаемых объектов из объекта matrix в 
	 * matrix3D и обратно.
	 * @private
	 * @author fish_r
	 */
	public final class TranslationMatrixs 
	{
		private static var _rawData:Vector.<Number>;
		
		/**
		 *  Транслирует обратимую matrix3D в 
		 * "простую" matrix2D DisplayObject-а
		 * @param	obj - любой объект-наследник класса DisplayObject
		 */
		public static function transInMatrix(obj:DisplayObject):void
		{
			var matrix3D:Matrix3D;
			var matrix:Matrix;
			
			
			if (!obj.transform.matrix)
			{
				matrix3D = obj.transform.matrix3D;
				_rawData = matrix3D.rawData;
				
				/**
				 * В результате извлечения данных объекта matrix3D
				 * получаем вектор содержащий данные матрицы3Д, например:
				 * 
				 * 1,0,0,0, | 0,2.9981725215911865,0.10469848662614822,0  | ,0,-0.03489949554204941,0.9993908405303955,0 | ,-12,-28,0,1
				 * 1,0,0,0, | 0,1                  ,0                 ,0  | ,0,0                   ,1                 ,0 | ,-12,-28,2,1
				 * 
				 *   1,   0, 0, 0, 
				 *   0,   1, 0, 0, 
				 *   0,   0, 1, 0,
				 * -12, -28, 2, 1.
				 * 
				 * Где указанные цифры эквивалентны последовательности матрицы
				 * 4х4:
				 * 
				 *  a,  b,  0,  0,
				 *  c,  d,  0,  0,
				 *  0,  0,  z,  0,
				 * tx, ty, tz, tw.
				 * 
				 */
				
				 
				/**
				 * создаем объект 2-х мерной матрицы
				 */
				matrix = new Matrix( _rawData[0], _rawData[1], _rawData[4], _rawData[5], _rawData[12], _rawData[13]);
				
				/**
				 * обнуляем matrix3D и сообщаем
				 * matrix-у созданное значение
				 */
				obj.transform.matrix3D = null;
				obj.transform.matrix = matrix;
			}
			else
			{
				/**
				 *  Матрица объекта не равна null, поэтому 
				 * не применяем преобразование
				 */
				
				////////////// T R A C E  //////////////////
				trace("Utils.TranslationMatrixs.transInMatrix. Переданный объект содержит настроенную матрицу " + 
					" Преобразование не было произведено. obj.transform.matrix : " + obj.transform.matrix);
				////////////// A N D  T R A C E  ///////////
			}
		}
		
		public static function transInMatrix3D(obj:DisplayObject):void
		{
			
			var matrix:Matrix;
			var rawData:Vector.<Number>;
			
			
			
			if (obj.transform.matrix !== null)
			{
				
				
				matrix = obj.transform.matrix;
				rawData = Vector.<Number>([   matrix.a,    matrix.b,     _rawData[2],    _rawData[3], 
										      matrix.c,    matrix.d,     _rawData[6],    _rawData[7],
										   _rawData[8], _rawData[9],   	_rawData[10],   _rawData[11],
										     matrix.tx,   matrix.ty,    _rawData[14],  	_rawData[15] ]);
				obj.transform.matrix = null;
				
				
				obj.z = obj.z;
				obj.transform.matrix3D.rawData = rawData;
			}
			else
			{
				////////////// T R A C E  //////////////////
				trace("Utils.TranslationMatrixs.transInMatrix3D. " + 
				" Переданный объект не содержит настроенной матрицы. Преобразование не произведено." +
				", obj.transform.matrix : " + obj.transform.matrix);
				////////////// A N D  T R A C E  ///////////
			}
				
		}
		
	}

}