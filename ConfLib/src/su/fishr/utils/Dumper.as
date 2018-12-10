///********************************************************************
///* Copyright © 2012 fishr (fishr.flash@gmail.com)  
///********************************************************************


package su.fishr.utils 
{
	import flash.utils.*;

	/**
	 * Возвращает форматированную строку, с перечислением
	 * доступных полей, акцессоров и их значений объекта ссылка на который
	 * получена в аргументах единственного публичного метода.
	 * 
	 * @playerversion          Flash 10
	 * @langversion            3.0
	 * @author                 fishr
	 * @created                20.05.2012 1:11
	 * @since                  20.05.2012 1:11
	 */
	final public class Dumper
	{
		static private var _timeDie:int;
		static private const _MAX_TIME_DIE:int = 200;

	/**-------------------------------------------------------------------------------
	* 
	*								P U B L I C 	
	* 
	* --------------------------------------------------------------------------------
	*/
	//{
		/**
		 * Конструктор класса никогда не вызывается,
		 * класс статический - экземпляров не создаем.
		 * 
		 * @throws Ошибка "Not create exemplar this"
		 */
		public function Dumper()
		{
			throw new Error( "Not create exemplar this" ) ;
		}	
		
		/**
		 * Имеет один обязательный параметр - объект любого сложного или простого типа.
		 * Возвращает форматированную строку, с переносами и табуляцей, в которой перечислены
		 * все доступные поля, акцессоры и их значения обнаруженные в полученном по ссылке в 
		 * аргументах вызова объекте.
		 * 
		 * <p>
		 * <b>Важно!</b> 
		 * <i>Класс не умеет обрабатывать циклические ссылки ( когда объект ссылается сам на себя в своих
		 * полях и т.п. ). Для предотвращения зацикливания время непрерывной работы скрипта ограничивается
		 * значением константы _MAX_TIME_DIE
		 * </i>
		 * </p>
		 * 
		 * <p>
		 * <b>Примечание.</b> Так как переменные числовых типов утрачивают первоначальный тип.
		 * Обнаруженные поля числовых типов описываются следующим образом:
		 *  - если значение - целое число в диапазоне <CODE>int</CODE> оно характерезуется типом <CODE>int</CODE>,
		 *  - если значение - целое положительное число за диапазоном <CODE>int</CODE> (но меньше <CODE>uint.MAX_VALUE</CODE> )оно характерезуется типом <CODE>uint</CODE>,
		 *  - во всех остальных случаях числа описываются типом <CODE>number</CODE>.
		 * </p>
		 * 
		 * <b>Примечание.</b> Данные xml-типов не разбираются, только указывается тип таких данных.
		 * 
		 * <p>
		 * 
		 * <b>Примечание.</b> В круглых скобках указывается тип поля, если этот тип - строка или числовой тип далее
		 * следуют цифры, которые при строковом типе указывают длину строки, в числовом кол-во цифр целой и дробной части числа
		 * в формате: целая_часть[.дробная_часть].
		 * </p>
		 * 
		 * <p>
		 * 
		 * <b>Примечание.</b> Максимальная длительность непрерывной обработки - 0.512 секунды. Максимальная длина возвращаемой строки - 1024 символов.
		 * </p>
		 * 
		 * <p>
		 * 
		 * <b>Примечание.</b> Парсинг ссылок на классы в полях DisplayObject-ов находящихся в списке отображения не выполняется.
		 * </p>
		 * 
		 * @param	arg объект любого типа информацию о доступных полях которого нужно получить
		 * @param	onType ( default: true ) флаг указывающий следует ли указывать тип возвращаемых данных
		 * @param	level ( default: -1 ) "глубина" просмотра вложенных объектов обнаруженных в разбираемом объекте
		 * @param	openClasses ( default: false ) нужно ли разбирать поля вложенных объектов со статическим типом данных,
		 * 			т.к. экземпляры нативных классов могут содержать данные о своих полях довольно внушительного объёма
		 * 			этот параметр по умолчанию отключен.
		 * @return  форматированную строку содержащую инофрмацию об обнаруженных доступных полях объекта переданного
		 *          в аргументах вызова метода.
		 */
		static public function dump( arg:*, level:int = -1, onType:Boolean = true, openClasses:Boolean = false ):String
		{
			
			if ( !arg ) return "No object body";
			
			var result:String;
			
			if( !_timeDie ) _timeDie = getTimer();
			
			if ( typeof arg !== "object" )
			{
				result = " value = ( " + analisisSimple( arg ) +  " ) "  + arg;
				_timeDie = 0;
				return  result;
			}
			else
			{
			
				if ( getQualifiedClassName( arg ) !== "flash.utils::ByteArray" 
					&& arg.hasOwnProperty( "stage" ) && arg.stage !== null) openClasses = false;

				result = analisisObject( arg, onType, level, "\r", openClasses, true);
				_timeDie = 0;
				
				return result;
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
	
		static private function dumpArray( arr:Array, onType:Boolean, level:int, space:String, openClasses:Boolean ):String
		{
			if ( level === 0 ) return   "Array " + ( onType?"( " + arr.length +  " )":"" ) + " /limiting level.../" ;
			else level --;
			
			const timer:int = getTimer(); 
			if ( timer > _timeDie + _MAX_TIME_DIE ) return " too long processing... ";
			
			var parseArray:String = "Array" + ( onType?"(" + arr.length +  "):":":"  );
			var stepSpace:String = space + "\t";
			var type:String;
			var descript:String;
			
			for ( var nm:String in arr )
			{
				if ( typeof arr[ nm ] !== "object" )
				{
					const typingValue:String = analisisSimple( arr[ nm ] );
					descript = stepSpace +  "[" + nm + "] => " + ( onType?"(" + typingValue + ") ":"" );
					
					parseArray += descript + ( ( typingValue === "xml" )?"/not shown.../":arr[ nm ] );
				}
				else
				{
					
					descript = stepSpace +  "[" + nm + "] => ";
					parseArray += descript + analisisObject( arr[ nm ], onType, level, stepSpace, openClasses  ) ;
				}
			}
			
			return parseArray;
		}
		
		static private function dumpObject( arg:Object , onType:Boolean, level:int, space:String, openClasses:Boolean  ):String
		{
			if ( level === 0 ) return   "Object /limiting level.../" ;
			else level --;
			
			const timer:int = getTimer(); 
			if ( timer > _timeDie + _MAX_TIME_DIE ) return " too long processing... ";
			
			var parseObject:String = "Object";
			var parseContent:String = "";
			
			var stepSpace:String = space +  "\t";
			var type:String;
			var descript:String;
			var countElems:int = 0;
			
			for ( var nm:String in arg )
			{
				if ( typeof arg[ nm ] !== "object" )
				{
					const typingValue:String = analisisSimple( arg[ nm ] );
					descript = stepSpace +  "" + nm + ":" + ( onType?"(" + typingValue + ") ":"" )

					parseContent += descript + ( ( typingValue === "xml" )?"/not shown.../":arg[ nm ] );
				}
				else
				{
					descript = stepSpace +  "" + nm + ":";
					parseContent += descript + analisisObject( arg[ nm ], onType, level, stepSpace, openClasses  ) ;
				}
				
				countElems++;
			}
			
			parseObject += " (" + countElems + "): " + parseContent;
			
			return parseObject;
		}
		
		static private function dumpClass( arg:*, onType:Boolean, level:int, space:String, openClasses:Boolean  ):String
		{
			
			
			
			if ( level === 0 ) return   arg.toString() + " /limiting level.../";
			else level--;
			
			const timer:int = getTimer(); 
			if ( timer > _timeDie + _MAX_TIME_DIE ) return " too long processing... ";
			
			var parseClass:String =  arg.toString() + ": ";
			var stepSpace:String = space +  "\t";
			var type:String;
			
			
			const xmlDescription:XML = describeType( arg );
			const variables:XMLList = xmlDescription.variable;
			const accessors:XMLList = xmlDescription.accessor;
			const constant:XMLList = xmlDescription.constant;
			const method:XMLList = xmlDescription.method;
			
			///variables
			var descript:String = "variables";
			parseClass += stepSpace + descript;
			
			stepSpace += "\t";
			
			var contenVar:String = "";
			var countElems:int = 0;
			
			for each ( var publicVar:XML in variables )
			{
				if ( typeof arg[ publicVar.@name ] !== "object" )
				{
					const typeVar:String = analisisSimple( arg[ publicVar.@name ] );
					descript = stepSpace +  "" + publicVar.@name + " = " + ( onType?"(" + typeVar + ") ":"" )
					contenVar += descript  + ( ( typeVar === "xml" )?"/not shown.../":( arg[ publicVar.@name ] ) );
				}
				else
				{
					descript = stepSpace +  " " + publicVar.@name + " = ";
					contenVar += 
						( arg[ publicVar.@name ] === null || arg[ publicVar.@name ] === undefined)?
							descript +  ( onType?"(" + publicVar.@type + ",0)":"" ) + arg[ publicVar.@name ]:
							descript + analisisObject( arg[ publicVar.@name ], onType, level, stepSpace, openClasses);
				}
				
				countElems++;
				
			}
			
			parseClass += " (" + countElems + "): " + contenVar;
			
			
			
			///constants
			descript = "constants";
			
			stepSpace = space +  "\t";
			parseClass += stepSpace + descript;
			var contentConst:String = "";
			countElems = 0;
		
			
			stepSpace += new Array( descript.length ).join( " " );
			
			for each ( var publicConst:XML in constant )
			{
				if ( typeof arg[ publicConst.@name ] !== "object" )
				{
					const typeConst:String = analisisSimple( arg[ publicConst.@name ] );
					descript = stepSpace +  "" + publicConst.@name + " = " + ( onType?"(" + typeConst + ") ":"" )
					contentConst += descript  + ( ( typeConst === "xml" )?"/not shown.../":( arg[ publicConst.@name ] ) );
				}
				else
				{
					descript = stepSpace +  " " + publicConst.@name + " = ";
					contentConst += 
						( arg[ publicConst.@name ] === null || arg[ publicConst.@name ] === undefined)?
							descript +  ( onType?"(" + publicConst.@type + ",0)":"" ) + arg[ publicConst.@name ]:
							descript + analisisObject( arg[ publicConst.@name ], onType, level, stepSpace + "\t", openClasses);
				}
				
				countElems++;
			}
			
			parseClass += " (" + countElems + "): " + contentConst;
			
			///accessors
			stepSpace = space +  "\t";
			descript = "accessors";
			parseClass += stepSpace + descript;
			stepSpace  += "\t";
			
			var contentAcc:String = "";
			countElems = 0;
			
			for each ( var publicAcc:XML in accessors )
			{
				if ( publicAcc.@access == "writeonly" ) continue;

				
				if ( typeof arg[ publicAcc.@name ] !== "object" )
				{
					
					const typeAcc:String = analisisSimple( arg[ publicAcc.@name ] );
					descript = stepSpace + publicAcc.@access +  " " + publicAcc.@name + " = " + ( onType?"(" + typeAcc + ") ":"" );
					contentAcc += descript + ( ( typeAcc === "xml" )?"/not shown.../":( arg[ publicAcc.@name ] ) );
					
				}
				else
				{
					descript = stepSpace + publicAcc.@access + " " + publicAcc.@name + " = ";
					
					contentAcc +=
						( arg[ publicAcc.@name ] === null || arg[ publicAcc.@name ] === undefined)? 
						descript +  ( onType?"(" +  publicAcc.@type + ",0)":"" ) + arg[ publicAcc.@name ]:
						descript + analisisObject( arg[ publicAcc.@name ], onType, level, stepSpace + "\t", openClasses);
						
						
				}
				
				countElems++;
				
			}
			
			parseClass += " (" + countElems + ") " + contentAcc;
			
			///methods
			stepSpace = space + "\t";
			descript = "methods";
			parseClass += stepSpace + descript;
			stepSpace  += "\t";
			var contentMethods:String = "";
			countElems = 0;
			for each ( var publicMethod:XML in method )
			{
				contentMethods += stepSpace + publicMethod.@name + ":" + publicMethod.@returnType;
				countElems++;
			}
			
			parseClass += " (" + countElems + ") " + contentMethods;

			
			return parseClass;
		}
		
		static private function dumpVector( arg:*, onType:Boolean, level:int, space:String, openClasses:Boolean  ):String
		{
			if ( level === 0 ) return   getQualifiedClassName( arg ) + " /limiting level.../";
			else level--;
			
			const timer:int = getTimer(); 
			if ( timer > _timeDie + _MAX_TIME_DIE ) return " too long processing... ";
			
			var parseVector:String = "( " + arg.length + " )";
			var stepSpace:String = space +  "\t";
			var type:String;
			var descript:String;
			
			for ( var nm:String in arg )
			{
				if ( typeof arg[ nm ] !== "object" )
				{
					const typingValue:String = analisisSimple( arg[ nm ] );
					descript = stepSpace +  "[" + nm + "] => " + ( onType?"(" + typingValue + ") ":"" )

					parseVector += descript +( ( typingValue === "xml" )?"/not shown.../":arg[ nm ] );
				}
				else
				{
					descript = stepSpace +  "[" + nm + "] => ";
					parseVector += descript + analisisObject( arg[ nm ], onType, level, stepSpace + "\t", openClasses  ) ;
				}
			}
			
			return parseVector;
		}
		
		
		static private function dumpDictionary( arg:*, onType:Boolean, level:int, space:String, openClasses:Boolean  ):String
		{
			if ( level === 0 ) return   getQualifiedClassName( arg ) + " /limiting level.../";
			else level--;
			
			const timer:int = getTimer(); 
			if ( timer > _timeDie + _MAX_TIME_DIE ) return " too long processing... ";
			
			var parseDict:String = getQualifiedClassName( arg );
			var parseContent:String = "";
			var stepSpace:String = space + "\t";
			var type:String;
			var descript:String;
			var countElem:int = 0;
			
			for ( var nm:* in arg )
			{
				if ( typeof arg[ nm ] !== "object" )
				{
					const typingValue:String = analisisSimple( arg[ nm ] );
					descript = stepSpace +  "[" + getQualifiedClassName( nm )+ "] => " + ( onType?"(" + typingValue + ") ":"" )

					parseContent += descript + ( ( typingValue === "xml" )?"/not shown.../":arg[ nm ] );
				}
				else
				{
					descript = stepSpace +  "[" + getQualifiedClassName( nm ) + "] => ";
					parseContent += descript + analisisObject( arg[ nm ], onType, level, stepSpace , openClasses  ) ;
				}
				
				countElem++;
			}
			
			parseDict += " (" + countElem +"): " + parseContent;
			
			return parseDict;
			
			
		}
		
		static private function dampByteArray(arg:*, onType:Boolean, level:int, space:String, openClasses:Boolean):String
		{
			if ( level === 0 ) return   "ByteArray /limiting level.../" ;
			else level --;

			const timer:int = getTimer(); 
			
			if ( timer > _timeDie + _MAX_TIME_DIE ) return " too long processing... ";
			
			var parseObject:String = "ByteArray";
			var parseContent:String = "";
			var stepSpace:String = space +  "\t";
			var type:String;
			var descript:String;
			
			parseContent += stepSpace +  "bytesAvailable:  " + arg.bytesAvailable + ( onType?" ( " + analisisSimple( arg.bytesAvailable ) + " ) ":"" );
			parseContent += stepSpace +  "endian: " + arg.endian + ( onType?" ( " + analisisSimple( arg.endian ) + " ) ":"" );
			parseContent += stepSpace +  "length: " + arg.length + ( onType?" ( " + analisisSimple( arg.length ) + " ) ":"" );
			parseContent += stepSpace +  "objectEncoding: " + arg.objectEncoding + ( onType?" ( " + analisisSimple( arg.objectEncoding ) + " ) ":"" );
			parseContent += stepSpace +  "position: " + arg.position +  ( onType?" ( " + analisisSimple( arg.position ) + " ) ":"" );

			parseObject += " (" + 5 + "): " + parseContent;
			
			return parseObject;
		}
		
		
		static private function analisisObject( arg:*, onType:Boolean, level:int, space:String, openClasses:Boolean, firstFlag:Boolean = false  ):String
		{
			var parseData:String;
			
			var classType:String = getQualifiedClassName( arg );
			
			if ( getQualifiedSuperclassName( arg ) === "flash.utils::ByteArray" ) classType = "flash.utils::ByteArray";
			
			switch ( classType ) 
			{
				case "flash.utils::ByteArray":
					parseData = dampByteArray(  arg, onType, level, space, openClasses );
				break;
				
				case "flash.utils::Dictionary":
					parseData = dumpDictionary( arg, onType, level, space, openClasses );
				break;
				
				case "Object": 
					
					parseData = dumpObject( arg, onType, level, space, openClasses );
				break;
						
				case "Array":
					parseData =  dumpArray( arg as Array, onType, level, space, openClasses );
				break;
				
				case ( classType.indexOf( "Vector" ) !== -1 )?classType:"":
					
					parseData = dumpVector( arg, onType, level, space, openClasses );
					
					break;
					
				default:
					
					if ( firstFlag && !( openClasses ) || openClasses &&  !(  arg.hasOwnProperty( "stage" ) && arg.stage !== null)) parseData = dumpClass( arg, onType, level, space, openClasses );
					else parseData = arg;
			}
					
			return parseData;
		}
		

		
		static private function analisisSimple( arg:* ):String
		{
			
			var type:String;
			
			if ( typeof arg === "xml" )
			{
				type = "xml";
			}
			else if ( typeof arg === "string" )
			{
				String( arg );
				type = "str" + "," + String( arg ).length;
			}
			else if ( typeof arg === "number" )
			{
				if ( arg is int ) 
				{
					type = "int";
					type += "," + String( arg + "").length;
				}
				else if ( arg as uint ) 
				{
					type = "uint";
					type += "," + String( arg + "").length;
				}
				else 
				{
					type = "number";
					const floor:int =  String( Math.floor( arg ) ).length;
					const fract:Array = ( arg + "" ).split( "." );
					const fractional:int = fract.length > 1?fract[ 1 ].length:0;
					
					type += "," + String( floor + "." + fractional);
				}
				
				
			}
			else if ( typeof arg === "boolean" ) type = "bool";
			else type = "";
			
			return type;
		}
	//}
		
		
	}

}