///********************************************************************
///* Copyright © 2012 fishr (fishr.flash@gmail.com)  
///********************************************************************


package su.fishr.utils 
{
	

	/**
	 *  Добавляет к сообщенным данным ведущие нули.
	 * В основном применительно к датам, но может и ещё где.
	 * @playerversion          Flash 9
	 * @langversion            3.0
	 * @author                 fishr
	 * @created                17.08.2012 3:14
	 * @since                  17.08.2012 3:14
	 */
	
	public function AddZerroDate( valueDate:Number, len:uint = 2 ):String
	{
		var res:String = valueDate.toString();
		while ( res.length < len ) res = "0" + res;
		return res;
	}

}