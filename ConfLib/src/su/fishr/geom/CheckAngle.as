///********************************************************************
///* Copyright © 2011 fishr (fishr.flash@gmail.com)  
///********************************************************************


package su.fishr.geom 
{
	import flash.geom.Point;
   /**
	 *   Содержит набор методов для определения
	 * угла точки относительно сцены или другого 
	 * объекта.
	 * 
	 * @version                1.0
	 * @playerversion          Flash 9
	 * @langversion            3.0
	 * @author                 fishr
	 * @created                20.07.2011 21:45
	 */
	public final  class CheckAngle
	{
	/**-------------------------------------------------------------------------------
	* 
	*	   						V A R I A B L E ' S 	
	* 
	* --------------------------------------------------------------------------------
	*/
	//{
	
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
		 *  Определяет угол наклона точки 
		 * по отношению левому, верхнему
		 * углу сцены
		 * 
		 * @param	pnt    точка угол наклона которой требуется найти.
		 * @param	rads   возвращаемое значение. Радианы - true, градусы - false (по умолчанию)
		 * @return  угол наклона.
		 */
		static public function checkAngleToStage( pnt:Point, rads:Boolean = false ):Number
		{
			var rad:Number = Math.atan2(  pnt.y, pnt.x);
			if ( rads === true )
			{
				return rad;
			}
			else
			{
				var angle:Number = calculateRadNDegree( rad );
				return angle;
			}
		}
		
		
		/**
		 * Опеределяет угол наклона точки по отношению
		 * к другой точке.
		 * 
		 * @param	pnt1   точка угол наклона которой
		 *                 требуется определить.
		 * @param	pnt2   точка по отношению к которой
		 * 				   требуется определить угол наклона.
		 * @param	rads   возвращаемое значение. Радианы - true, градусы - false (по умолчанию)
		 * @return   угол наклона.
		 */
		static public function checkAngleToOwerObj( pnt1:Point, pnt2:Point, rads:Boolean = false):Number
		{
			var rad:Number = Math.atan2( pnt1.y - pnt2.y, pnt1.x - pnt2.x );
			
			if ( rads === true )
			{
				return rad;
			}
			else
			{
				var angle:Number = calculateRadNDegree( rad );
				return angle;
			}
		}
		
		static public function calculateRadNDegree( value:Number, degree:Boolean = true ):Number
		{
			if ( degree ) return value * ( 180 / Math.PI );
			else return value * ( Math.PI / 180);
		}

	//}
	
	/**-------------------------------------------------------------------------------
	* 
	*								P R I V A T E 	
	* 
	* --------------------------------------------------------------------------------
	*/	
	//{
	
	//}
		
		
	}

}