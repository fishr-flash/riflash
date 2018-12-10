///********************************************************************
///* Copyright © 2012 fishr (fishr.flash@gmail.com)  
///********************************************************************


package su.fishr.text 
{
	
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.text.TextField;
	
   

	/**
	 *   Дополняет стандартный класс TextField
	 * средствами обработки содержимого тегов
	 * <img></img> html-контента:
	 * 
	 * - обрабатывает возможные ошибки
	 * загрузки визуальных эл-тов
	 * объекта TextField,
	 * - генерирует события успешной загрузки
	 * визуальных эл-тов в составе html-текста,
	 * - предоставляет ссылки на лоадеры виз.эл-тов через
	 * массив loaders.
	 * 
	 * 
	 * @playerversion          Flash 9
	 * @langversion            3.0
	 * @author                 fishr
	 * @created                04.07.2012 2:35
	 * @since                  04.07.2012 2:35
	 */
	public  class TextFieldImgs extends TextField
	{
		[Event (name="addedImg", type="su.fishr.text.TextFieldIOs")];
	/**-------------------------------------------------------------------------------
	* 
	*	   						V A R I A B L E ' S 	
	* 
	* --------------------------------------------------------------------------------
	*/
	//{
		/**
		 *  Константное значение определяющее тип события успешного
		 * окончания загрузки очередного отображаемого эл-та определенного
		 * в тегах <img> html-контента переданного полю htmlText экземпляра
		 * TextField
		 */
		static public const ADDED_IMG:String = "addedImg";
		static private const AUTHOR:String = "fishr (fishr.flash@gmail.com)";
		public var loaders:Array = new Array();
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
		public function TextFieldImgs()
		{
			super();
			
			this.addEventListener(Event.ADDED, onAdded );

		}
		
		
	//}
	
	/**-------------------------------------------------------------------------------
	* 
	*								P R I V A T E 	
	* 
	* --------------------------------------------------------------------------------
	*/	
	//{
		
		private function onAdded(e:Event):void 
		{
			if ( e.target is Loader && e.target.parent === this )
			{
				with ( Loader( e.target ).contentLoaderInfo )
				{
					addEventListener( IOErrorEvent.IO_ERROR, ioErrorHandler );
					addEventListener( Event.COMPLETE, completeLoad );
				}
			}
			
		}

		private function completeLoad(e:Event):void 
		{
			loaders.push( e.target.loader );
			this.dispatchEvent( new Event( ADDED_IMG ) );
		}
		
		private function ioErrorHandler(e:IOErrorEvent):void 
		{
			////////////////////////// T R A C E ///////////////////////////////
			var d:Date = new Date();
			trace(d.valueOf() + ". TextFieldIOs::ioErrorHandler()  : " + e);
			//////////////////////// E N D  T R A C E //////////////////////////
		}
	//}
		
		
	}

}