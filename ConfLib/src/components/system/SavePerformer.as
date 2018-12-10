package components.system
{
	/** V 1.1
	 * Отправляет разные события, позволяет уходить со страницы не сохраняя ее
	 * V 1.0
	 * Отправляет готовность при сохранении	*/ 
	
	import components.abstract.functions.dtrace;
	import components.gui.Balloon;
	import components.interfaces.IFormString;
	import components.interfaces.ISaveAnalyzer;
	import components.interfaces.ISaveController;
	import components.interfaces.ISaveListener;
	import components.interfaces.IThreadUser;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.protocol.models.CommandSchemaModel;
	import components.protocol.models.ParameterSchemaModel;
	import components.protocol.statics.OPERATOR;
	import components.static.CMD;
	import components.static.MISC;
	
	/**
	 * 	 Менеджер сохранения, концентрирует данные о полях ( компонентах ) и их измененной информации
	 *  нуждающиеся в отправке на прибор. Производит финальную валидацию подготовленной информации.
	 * Дает сигнал для выведения активной надписи-кнопки "Сохранить данные".
	 * 
	 */
	public class SavePerformer implements IThreadUser
	{
		public static const EVENT_CANCEL:int = 0x00;
		public static const EVENT_COMPLETE:int = 0x01;
		public static const EVENT_ACTIVE:int = 0x02;	// нужен для запрета добавления линий в OptList если включен BlockSave (сохранение только если в целой табилце все валидно)
		public static const EVENT_SAVE_TRY:int = 0x03;	// срабатыват когда было нажато сохранение 
		
		public static const BLOCK_SAVE:String = "save_in_block_list";
		public static const INVERT_SAVE:String = "save_invert";
		
		public static const CMD_TRIGGER_FALSE:int = 0x00;
		public static const CMD_TRIGGER_TRUE:int = 0x01;
		public static const CMD_TRIGGER_BREAK:int = 0x02;
		public static const CMD_TRIGGER_CONTINUE:int = 0x03;
		
		public static const MODE_NORMAL:int = 0;	// дефолт, сохраняет по нажатию save 
		public static const MODE_ASK:int = 1;		// сохраняет только по спец послыке
		
		private static const FUNCT_SAVE:int = 0x01;	// вызывает сохранение в режиме MODE_NORMAL
		private static const FUNCT_SAVE_TRIGGER:int = 0x02;	// функция которая вызывается для сохранения триггеров если нечего сохранять кроме них
		private static const FUNCT_SAVE_TRIGGER_IF_SAVE_EMPTY:int = 0x03;	// вызывается, если требуется вызвать before а сохранение пустое
		private static const FUNCT_SAVE_ASK:int = 0x04; // вызывает сохранение в любом режиме
		
		private static var DO_SAVE:Boolean = false;
		
		public static var LOADING:Boolean = false;	// вовремя true механиз не принимает вызовы на сохранение
		
		public static var oNeedToSave:Object;
		private static var oFields:Object = new Object;
		private static var queue:Array = new Array;
		
		private static var listeners:Vector.<ISaveListener>;
		private static var controller:ISaveController;
		private static var mode:int;
		private static var callback:Function;
		private static var aftersave:Function
		
		
		/**
		 * 
		 * @param _c Controller дает возможность управлять выведением, активацией
		 * кнопки "Сохранить данные"
		 */
		public function SavePerformer(_c:ISaveController)
		{
			controller = _c; 
		}
		public static function switchMode(value:int=MODE_NORMAL):void
		{
			mode = value;
		}
		public static function addObserver(t:ISaveListener):void
		{
			if (!listeners)
				listeners = new Vector.<ISaveListener>;
			listeners.push(t);
		}
		public static function addAftersave(f:Function):void
		{
			aftersave = f;
		}
		public static function removeCompleteListener(t:ISaveListener):void
		{
			if (listeners) {
				var len:int = listeners.length;
				for (var i:int=0; i<len; ++i) {
					if(listeners[i] == t )
						listeners.splice(i,1);
				}
			}
		}
		
		public static function remove(cmd:int,struct:int=0):void
		{
			if ( struct > 0 ) {
				if ( oFields && oFields[cmd] != null && oFields[cmd][struct] != null )
					delete oFields[cmd][struct];
			} else {
				if ( oFields && oFields[cmd] != null )
					delete oFields[cmd];
			}
		}
		public static function addCMDParam(cmd:int, param:String, value:Object):void
		{
			if ( !oFields )
				oFields = new Object;
			
			if ( oFields[param] == null )
				oFields[param] = new Object;
			
			oFields[param][cmd] = value;
		}
		public static function add(_cmd:int, _struct:int, target:IFormString):void
		{
			var cmd:String = _cmd.toString();
			var struct:String = _struct.toString();
			
			if ( !oFields )
				oFields = new Object;
			
			if ( oFields[cmd] == null )
				oFields[cmd] = new Object;

			if ( oFields[cmd][struct] == null )
				oFields[cmd][struct] = new Object;
			
			oFields[cmd][struct][target.param] = target;
		}
		
		public static function closePage(killTriggers:Boolean=true):void
		{
			queue.length = 0;
			mode = MODE_NORMAL;
			oNeedToSave = new Object;
			controller.saveButtonActive( true );
			controller.showSave(false);
			fireEvent( EVENT_CANCEL );
			listeners = new Vector.<ISaveListener>;
			if( oFields && killTriggers ) {
				oFields["trigger"] = null;
				oFields[BLOCK_SAVE] = null;
			}
		}
		public static function forget(cmd:int,struct:int):void
		{
			if( oNeedToSave ) {
			
				if ( oNeedToSave[cmd] != null && oNeedToSave[cmd][struct] != null )
					delete oNeedToSave[cmd][struct];
				
				if ( oNeedToSave[cmd] != null ) {
					var empty:Boolean = true;
					for( var any:String in oNeedToSave[cmd] ) {
						empty = false;
						break;
					}
					
					if ( empty ) {
						delete oNeedToSave[cmd];
					
						empty = true;
						for( any in oNeedToSave ) {
							empty = false;
							break;
						}
						controller.showSave(!empty);	
					}
				}
			}
		}
		public static function forgetBlank():void
		{
			if ( oNeedToSave && oNeedToSave["funct"] is int )
				delete oNeedToSave["funct"];
			controller.showSave(false);
		}
		/** SavePerformer.trigger( {"before":erase, "after":fill, "cmd":refine, "prepare":prepare} );
		 * "prepare":Function - вызвается 1 раз перед формированием сохраненияблока данных
		 * "before":Function - вызвается 1 раз перед сохранением любого блока данных 
		 * "after":Function  - вызввается 1 раз после сохранения всех данных
		 * "cmd":Function - вызывается когда сохранение обрабатывает указанную команду
		 * "error":Function - вызывается когда параметр не валидный */
		public static function trigger(obj:Object=null):void
		{
			if ( !oFields )
				oFields = new Object;
			oFields["trigger"] = obj;
		}
		/** требуется для сохранения триггеров если больше нечего сохранять а запустить триггеры необходимо*/ 
		public static function rememberBlank():void
		{
			if ( !oNeedToSave )
				oNeedToSave = new Object;
					
			controller.showSave(true);
			oNeedToSave["funct"] = FUNCT_SAVE_TRIGGER;
		}
		public static function rememberIfEmpty():void
		{
			if ( !oNeedToSave )
				oNeedToSave = new Object;
			oNeedToSave["funct"] = FUNCT_SAVE_TRIGGER_IF_SAVE_EMPTY;
		}
		
		/**
		 * 	немедленно ставит в очередь данные эл-та на передачу 
		 *  в прибор ( для элементов у которых нет 
		 *  автоматической аналогичной функции или она
		 *  отключена )
		 */
		public static function remember( struct:int, target:IFormString, force_save:Boolean=false, doValidation:Boolean=true):void
		{
			
			
			
			if ( !LOADING && (queue.length == 0 || (queue[queue.length-1]["struct"] != struct || queue[queue.length-1]["target"] != target)) )
				queue.push( { struct:struct, target:target, save:force_save, dovalid:doValidation } );
			
				
			
		}
		public function threadTick():void
		{
			
			var close:Boolean;
			var len:int = queue.length;
			//for( var key:String in queue ) {
			for( var key:int = 0; key < len; key ++ ){
				switch( queue[key]["funct"] ) {
					case FUNCT_SAVE:
						fireEvent( EVENT_SAVE_TRY );
						if (mode == MODE_NORMAL) {
							DO_SAVE = true;
							close = queue[key]["pageClose"];
							Balloon.access().close();
						}
						break;
					case FUNCT_SAVE_ASK:
						DO_SAVE = true;
						close = queue[key]["pageClose"];
						break;
					default:
						writeMemory( queue[key]["struct"], queue[key]["target"], queue[key]["save"],queue[key]["dovalid"] );
						break;
				}
			}
				
			if (DO_SAVE)
				writeSave(close);
			queue.length = 0;
		}
		
		/**
		 * @private 
		 * 	Именно этот метод отвечает за подготовку и валидацию данных
		 * 
		 * 
		 */
		private static function writeMemory( struct:int, target:IFormString, force_save:Boolean, doValidation:Boolean):void
		{
			controller.showSave(true);
			
			if ( !oNeedToSave )
				oNeedToSave = new Object;
			
			var schema:CommandSchemaModel = OPERATOR.getSchema( target.cmd );
			
			
			// проходимся по всем элементам управления и считываем нужную информацию
			for( var param:String in oFields[target.cmd][struct] ) {
				
				var paramsList:Object = oFields[target.cmd][struct];
				
				// если параметр больше макс количества значит он из следующей структуры
				var real_param:int = int(param);
				var real_structure:int = struct;
				if ( real_param > schema.Parameters.length) {
					real_param -= schema.Parameters.length;
					real_structure++;
				}

				if ( oNeedToSave[target.cmd] == null )
					oNeedToSave[target.cmd] = new Object;
				
				if ( oNeedToSave[target.cmd][real_structure] == null ) {
					oNeedToSave[target.cmd][real_structure] = new Object;
					// если параметр из следующей структуры, то может быть использованы не все поля - их надо создать
					if ( int(param) > real_param ) {
						createFields( schema, oNeedToSave[target.cmd][real_structure] );
					}
				}
				
				var p:ParameterSchemaModel = schema.getParamByStructure(real_param);

				if ( p.Type == "String" )
					oNeedToSave[target.cmd][real_structure][real_param] = (paramsList[param] as IFormString).getCellInfo();//(oFields[target.cmd][param] as IFormString).getCellInfo();
				else {
					var obj:Object = (paramsList[param] as IFormString).getCellInfo();
					if ( obj is Array ) {
						for( var key:String in obj ) {
							oNeedToSave[target.cmd][real_structure][real_param + int(key)] = obj[key];
						}
					} else
						oNeedToSave[target.cmd][real_structure][real_param]	= int(obj);
				}
			}
			if( doValidation )
				validate();
			if ( force_save )
				save();
		}
		public static function validate():void
		{	// проверяем есть ли среди зарагистрированных полей хотябы одно невалидное поле
			var valid:Boolean = true;
			var field:IFormString;
			for( var cmd:String in oNeedToSave ) {
				for( var struc:String in oNeedToSave[cmd] ) {
					for( var param:String in oFields[cmd][struc] ) {
						field = oFields[cmd][struc][param] as IFormString;
						if ( !field || !field.isValid() ) {
							valid = false;
							break;
						}
					}
					if (!valid)
						break;
				}
				if (!valid)
					break;
			}
			var blockSavable:Boolean = true;
			if ( oFields[SavePerformer.BLOCK_SAVE] ) {
				for (var key:String in oFields[SavePerformer.BLOCK_SAVE] ) {
					if( oFields[SavePerformer.BLOCK_SAVE][key] is ISaveAnalyzer) {
						blockSavable = (oFields[SavePerformer.BLOCK_SAVE][key] as ISaveAnalyzer).isSavable();
						fireEvent(EVENT_ACTIVE);
						break;
					}
				}
			}
			
			controller.saveButtonActive( valid && blockSavable );
		}
		private static function createFields( schema:CommandSchemaModel, target:Object ):void
		{
			for( var param:String in schema.Parameters ) {
				var p:ParameterSchemaModel = schema.Parameters[param];
				if ( p.Type == "String" )
					target[int(param)+1] = "";
				else
					target[int(param)+1] = 0;
			}
		}
		public static function save(pageClose:Boolean=false):void
		{
			queue.push( { funct:FUNCT_SAVE, pageClose:pageClose } );
			if( oFields["trigger"] && oFields["trigger"]["click"] is Function ) // смотрим есть ли функция запуска триггеров, если есть - запускаем и стираем этот объект
				oFields["trigger"]["click"]();
		}
		public static function saveForce(f:Function=null):void
		{
			if (f is Function)
				callback = f;
			queue.push( { funct:FUNCT_SAVE_ASK, pageClose:false } );
		}
		
		/**
		 * @private
		 * 
		 *  После нажатия "Сохранить", здесь производятся последние
		 * изменения, собираются все заготовленные данные и отправляются на прибор.
		 */
		private static function writeSave(pageClose:Boolean=false):void
		{
			
			DO_SAVE = false;
			var beforeTriggered:Boolean = false;
			if ( oNeedToSave ) {
				if ( oNeedToSave["funct"] == FUNCT_SAVE_TRIGGER_IF_SAVE_EMPTY ) {	// Смотрим пустой ли сейв, если да впихиваем FUNCT_SAVE_TRIGGER в сохранялку
					var empty:Boolean = true;
					for( var any:String in oNeedToSave ) {
						if (any != "funct") {
							empty = false;
							break;
						}
					}
					if (empty)
						oNeedToSave["funct"] = FUNCT_SAVE_TRIGGER;
					else
						delete oNeedToSave["funct"];
				}
				if ( oNeedToSave["funct"] == FUNCT_SAVE_TRIGGER ) {					// смотрим есть ли функция запуска триггеров, если есть - запускаем и стираем этот объект
					if( !beforeTriggered && oFields["trigger"] && oFields["trigger"]["before"] is Function )
						oFields["trigger"]["before"]();
					beforeTriggered = true;
					delete oNeedToSave["funct"];
				}
				
				if( oFields["trigger"] && oFields["trigger"]["prepare"] is Function ) {	// какие либо действия перед перелистыванием объекта сохранения
																						// требуется если нужно переформировать объект сохранения
					oFields["trigger"]["prepare"]();
				}
				
				for( var cmd:String in oNeedToSave ) {
					// если команда отмечена в списке сейв блоков значит чтобы ее сохранить необходима валидация всех структур
					// если стоит pageClose значит осуществляется переход со страницы на страницу и несохраненные данные просто надо удалять
					if ( oFields[SavePerformer.BLOCK_SAVE] && oFields[SavePerformer.BLOCK_SAVE][cmd] is ISaveAnalyzer) {
						if( !(oFields[SavePerformer.BLOCK_SAVE][cmd] as ISaveAnalyzer).isSavable() ) {
							if ( pageClose )
								delete oNeedToSave[cmd];
							continue;
						}
					}
					
					for( var struc:String in oNeedToSave[cmd] ) {
						var param:String
						
						// Проверка не удалены ли параметры в структуре и нет ли не прошедших валидацию
						var structCantBeSaved:Boolean = false
						for( param  in oFields[cmd][struc] ) {
							
							var field:IFormString = oFields[cmd][struc][param] as IFormString;
							if ( !field || ( !field.isValid() && MISC.DEBUG_IGNORE_FIELD_ERRORS == 0 ) ) {
								dtrace( "Команда "+cmd+ ", структура " + struc + " param "+param+" не прошел валидацию" );
								delete oNeedToSave[cmd][struc];
								structCantBeSaved = true;
								break;
							}
						}
						
						if ( structCantBeSaved ) {
							dtrace( "ERROR: Команда "+OPERATOR.getSchema(int(cmd)).Name+" не была сохранена" );
							if( oFields["trigger"] && oFields["trigger"]["error"] is Function ) {	// какие либо действия если был пойман инвалиндый параметр
								// возвращает ture если можно продолжать, false если надо прервать отсылку всего блока
								if( oFields["trigger"]["error"](int(cmd)) == true )
									continue;
								else
									break;
							}
							
							continue;
						}
						
						var aData:Array = new Array;
						for( param in oNeedToSave[cmd][struc] ) {
							aData.push( oNeedToSave[cmd][struc][param] )
						}
						if ( oFields[SavePerformer.INVERT_SAVE] && oFields[SavePerformer.INVERT_SAVE][cmd] == true)
							aData.reverse();
						
						// Апдейтим системные переменные
						controller.updateSystemVariables( int(cmd), int(struc), oNeedToSave[cmd][struc] );
						
						if( !beforeTriggered && oFields["trigger"] && oFields["trigger"]["before"] is Function ) {
							oFields["trigger"]["before"]();
							if ( oFields["trigger"]["beforeOnce"] != null ) {
								oFields["trigger"]["before"] = null;
								oFields["trigger"]["beforeOnce"] = null;
							}
						}
						beforeTriggered = true;
						
						// Существует ли триггер который срабатывает на конкретную команду
						if (oFields["trigger"] && oFields["trigger"]["cmd"] is Function ) {
							if( oFields["trigger"]["cmd"](int(cmd)) == CMD_TRIGGER_TRUE ) {
								var sw:int = oFields["trigger"]["cmd"]({"cmd":int(cmd),"struct":int(struc),"data":oNeedToSave,"array":aData});
								if( sw == CMD_TRIGGER_BREAK )
									break;
								if( sw == CMD_TRIGGER_CONTINUE )
									continue;
							}
						}
						
						RequestAssembler.getInstance().fireEvent( new Request( int(cmd),null,int(struc),aData, Request.NORMAL, Request.PARAM_SAVE ));
					}
				}
			}
			// Отрабатывает, когда выполняется вся очередь сохранения
			if (callback is Function) {
				callback();
				callback = null;
			}
			if (beforeTriggered && oFields["trigger"] && oFields["trigger"]["after"] is Function )
				oFields["trigger"]["after"]();
			
			if( pageClose && oFields )
				oFields["trigger"] = null;

			if (aftersave is Function)	// любая функция, которая будет срабатывать после отработки блока сохранения
				aftersave();
			
			
			oNeedToSave = new Object;
			controller.showSave(false);
			fireEvent(EVENT_COMPLETE);
			if (pageClose)
				listeners = new Vector.<ISaveListener>;
		}
		private static function fireEvent(e:int):void
		{
			if (listeners) {
				var len:int = listeners.length;
				for (var i:int=0; i<len; ++i) {
					listeners[i].saveEvent(e);
				}
			}
		}
	}
}