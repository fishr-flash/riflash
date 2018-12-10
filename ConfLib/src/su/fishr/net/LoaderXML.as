///********************************************************************
///* Copyright © 2011 fishr (fishr.flash@gmail.com)  
///********************************************************************


package su.fishr.net 
{
	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
   /**
	 *  Загружает XML-документ.
	 * Сигнализирует об окончании загрузки.
	 * Если происходит ошибка загрузки выводит
	 * сообщение об ошибке на полученную по ссылке
	 * сцену, не сигнализирует об окончании и потому
	 * формирование визуального интерфейса не происходит.
	 * 
	 * @version                1.0
	 * @playerversion          Flash 9
	 * @langversion            3.0
	 * @author                 fishr
	 * @created                08.10.2011 0:20
	 * @since                  08.10.2011 0:20
	 */
	public class LoaderXML extends URLLoader
	{
		[Event (name="loadedXml", type="su.fishr.net.LoaderXML")];
	/**-------------------------------------------------------------------------------
	* 
	*	   						V A R I A B L E ' S 	
	* 
	* --------------------------------------------------------------------------------
	*/
	//{
	    static public const AUTHOR:String = "fishr (fishr.flash@gmail.com)";
		static public const LOADED_XML:String = "loadedXml";
	//}
	
	//}
	/**-------------------------------------------------------------------------------
	* 
	*								P U B L I C 	
	* 
	* --------------------------------------------------------------------------------
	*/
	//{
		public function LoaderXML()
		{
			super();
			
			configureListeners( this );
			
		}
		
		public function loadProp( url:String, directFile:String ):void
		{
			
			const rnd:String = url.indexOf("file://") === 0?"":"?_rnd=" + new Date().valueOf();
			const request:String = excludeUrl( url );
			const req:String = request + directFile + rnd;
			
			 load( new URLRequest( req ) );
		}
		
		override public function load( request:URLRequest ):void
		{
			
			
			
			try
			{
				super.load(  request );
			}
			catch ( e:Error )
			{
				throw( e );
			}
			
		}
		

	//}
	
	/**-------------------------------------------------------------------------------
	* 
	*								P R I V A T E 	
	* 
	* --------------------------------------------------------------------------------
	*/	
	//{
		private function configureListeners(dispatcher:IEventDispatcher):void {
			
            dispatcher.addEventListener(Event.COMPLETE, completeHandler);
            dispatcher.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
            dispatcher.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
        }

        private function completeHandler(event:Event):void {
            var loader:URLLoader = URLLoader(event.target);
			this.dispatchEvent( new DataEvent( LOADED_XML, false, false, loader.data ));
			
			
        }

 
        protected function securityErrorHandler(event:SecurityErrorEvent):void {
           
			throw( new Error( event ) );
        }


        protected function ioErrorHandler(event:IOErrorEvent):void {
           
			throw( new Error( event ) );
        }
		
		private function excludeUrl(url:String):String
		{
			var match:Array = url.split("/");
			match.pop();
			var strRequest:String = match.join("/") + "/";
			
			return strRequest;
		}
	//}
		
		
	}

}