///********************************************************************
///* Copyright © 2012 fishr (fishr.flash@gmail.com)  
///********************************************************************


package su.fishr.display 
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Stage;
	
	   

	/**
	 *  Центрирует виз.объект относительно 
	 * содержащего его родителя, либо относительно
	 * контейнера ссылка на который передана вторым
	 * аргументом.
	 * 
	 * @playerversion          Flash 9
	 * @langversion            3.0
	 * @author                 fishr
	 * @created                12.03.2012 19:57
	 * @since                  12.03.2012 19:57
	 */
	
	 
	public function AlignCenter( dObj:DisplayObject, container:DisplayObjectContainer = null ):DisplayObject
	{
		const parent:DisplayObjectContainer = container || dObj.parent;
		
		var textError:String = "Центрируемый объект должен находиться в списке отображения, ";
		textError += "либо в аргументах должен быть передан объект относительно ";
		textError += "которого произоводится центрирование. ";
		
		if ( !(parent) ) throw new Error(  textError  );
		
		if ( parent is Stage )
		{
			dObj.x = ( Stage(parent).stageWidth - dObj.width ) / 2;
			dObj.y = ( Stage(parent).stageHeight - dObj.height ) / 2;
		}
		else
		{
			dObj.x = ( ( parent.width / parent.scaleX ) - dObj.width ) / 2;
			dObj.y = ( (  parent.height / parent.scaleY ) - dObj.height ) / 2;
		}
		
		return dObj;
		
	}

}