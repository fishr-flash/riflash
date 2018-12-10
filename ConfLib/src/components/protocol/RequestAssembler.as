package components.protocol
{
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	
	import components.abstract.Warning;
	import components.abstract.functions.dtrace;
	import components.abstract.functions.loc;
	import components.abstract.servants.TaskManager;
	import components.abstract.servants.primitive.ProgressSpy;
	import components.events.GUIEventDispatcher;
	import components.events.GUIEvents;
	import components.events.SystemEvents;
	import components.interfaces.IActiveErrorHandler;
	import components.interfaces.IActiveErrorSupporter;
	import components.interfaces.IRequestAssembler;
	import components.interfaces.IThreadUser;
	import components.protocol.models.CommandSchemaModel;
	import components.protocol.statics.CLIENT;
	import components.protocol.statics.OPERATOR;
	import components.protocol.statics.SERVER;
	import components.static.CMD;
	import components.static.DS;
	import components.static.MISC;
	
	/**
	 *  
	 * Занимается транспортом данных в сокет и из сокета.
	 */
	public class RequestAssembler implements IThreadUser, IRequestAssembler
	{
		private var SOCKET_READY:Boolean = true;
		private var CLEAR_STACK:Boolean = false;	// Если переменная активна, очищается очередь запросов и ожидается последний ответ на запрос
		private var requestWeight:int = 0;
		private var pBinary:ProtocolBinary;
		private var pText:ProtocolOldText;
		private var hiPriorityPackage:Array;
		private var queue:Vector.<Request>;
		private var queueLater:Vector.<Request>;	// Очередь для пакетов, которые были запрошены после clearQueueLater
		private var timerPing:Timer;
		private var timerPingBottom:Timer;
		private var prevent_cache:Vector.<int> = Vector.<int>([ ]); 
		private var functions:Vector.<int> = Vector.<int>([]);
		private var MAX_CMDS:int;
		
		private var requestServant:Vector.<Object> = new Vector.<Object>;
		
		private var proRequest:ProtocolRequest;
		private var ehandler:ErrorHandler;
		
		private static var instance:RequestAssembler;
		
		public static function getInstance():RequestAssembler
		{
			if ( instance == null ) {
				instance = new RequestAssembler;
			}
			return instance;
		}
		public function threadTick():void
		{
			processQueue();
		}
		public function RequestAssembler()
		{
			ehandler = new ErrorHandler;
			ehandler.register( reSend, clearRequest, stopAndFree );
			
			pBinary = new ProtocolBinary(reSend,delegateAssembler,this);
			pText = new ProtocolOldText(reSend,delegateAssembler,this);
			queue = new Vector.<Request>;
			
			pBinary.stats = [CLIENT.TIMER_IDLE^CLIENT.OLD_ADDRESS]; 
			
			timerPing = new Timer(CLIENT.TIMER_PING);
			timerPingBottom = new Timer(CLIENT.TIMER_PING);
			
		//	SocketProcessor.getInstance().fIsWatingForPacket = isSocketBusy;
			
			GUIEventDispatcher.getInstance().addEventListener( SystemEvents.onNeedClearQueue, clearStack );
			GUIEventDispatcher.getInstance().addEventListener( SystemEvents.onChangeOnline, onOnline );
		}
		public function isSocketBusy():Boolean
		{
			return !SOCKET_READY;
		}
		public function getClientAddress():int
		{
			return CLIENT.ADDRESS;
		}
		public function onError(e:int):void
		{	// вызывается когда протокол находит ошибку от прибора
			/*clearStack();
			SOCKET_READY = true;*/
			
			ehandler.onError(e);
		}
		public function activeHandler(h:IActiveErrorHandler=null):void
		{
			ehandler.activeHandler(h);
		}
		public function activeSupporter(s:IActiveErrorSupporter=null):void
		{
			ehandler.activeSupporter(s);
		}
		
		private function clearStack(ev:Event=null):void
		{
			SOCKET_READY = true;
			CLEAR_STACK = false;
			var pref:Object = {
				"CLIENT.IS_WRITING_FIRMWARE":CLIENT.IS_WRITING_FIRMWARE,
				"CLIENT.IS_WRITING_VIP_DATA":CLIENT.IS_WRITING_VIP_DATA
			}
					
			if (!CLIENT.IS_WRITING_FIRMWARE && !CLIENT.IS_WRITING_VIP_DATA ) {
				queue.length = 0;
				proRequest = null;
			}
			Warning.show("",Warning.TYPE_SUCCESS,Warning.STATUS_DEVICE_WRITING);
		}
		public function clearStackLater():void
		{	// Если запрос существует, значит клиент ожидает ответа - надо его дождаться, если гнет просто стираем всю ненужную очередь
			if (proRequest && proRequest.length > 0) {
				CLEAR_STACK = true;
			}
			if (!CLIENT.IS_WRITING_FIRMWARE && !CLIENT.IS_WRITING_VIP_DATA ) {
				queue.length = 0;
				if (!proRequest || proRequest.length == 0)
					Warning.show("",Warning.TYPE_SUCCESS,Warning.STATUS_DEVICE_WRITING);
			}
		}
		private function clearStackLaterComplete():void
		{
			clearStack();
			if(queueLater) {
				while(queueLater.length > 0)
					fireEvent( queueLater.pop() );
			}
			queueLater = null;
		}
		public function isAdrDifference():Boolean
		{	// проверить очередь на несовместимость адреса записанного в запросе и адреса подключенного в данный момент
			var len:int = queue.length;
			for (var i:int=0; i<len; ++i) {
				if( queue[i].serverAdr != SERVER.ADDRESS_TOP && queue[i].serverAdr != SERVER.ADDRESS_BOTTOM ) {
					return true;
				}
			}
			return true;
		}
		public function fireReadBlock(cmd:int, delegate:Function, a:Array, priority:int=0, param:int=0, spy:ProgressSpy=null):void
		{
			var len:int = a.length;
			var dRequest:DisassembledRequest = new DisassembledRequest( len, new Request( cmd, delegate ));
			if (len > 500)
				dRequest.isHuge();
			for( var i:int=0; i<len; ++i) {
				fireEvent( new Request( cmd, dRequest.attach, a[i], null, priority, param ));
			}
			dRequest.attachSpy(spy);
		}
		public function fireReadSequence( cmd:int, delegate:Function, max:int, min:int=1 ):void
		{
			var dRequest:DisassembledRequest = new DisassembledRequest( max+1-min, new Request( cmd, delegate ));
			for( var i:int=min; i<max+1; ++i) {
				fireEvent( new Request( cmd, dRequest.attach, i ));
			}
		}
		
		/** ensure - команда будет пересылаться 10 раз если будет приходить ошибка, потом уйдет в оффлайн
		 * 	urgent - команда имеет приоритет перед не urgent и будет отослана в приоритетной очереди */
		public function fireEvent( re:Request ):void
		{
			
			// Если включен CLEAR_STACK надо копить запросы пришедшие после его активации в отдельной очереди 
			if (CLEAR_STACK) {
				if( !queueLater )
					queueLater = new Vector.<Request>;
				queueLater.unshift( re );
				return;
			}
				
			if ( queue.length > 0 ) {
				var lastRequest:Request = queue[queue.length-1];
				
				// если запрос приоритетный
				if ( re.priority > 0 ) {
					var len:int = queue.length;
					var i:int;
					for( i=0; i<len; ++i) {
						// найти сначала очереди приоритет меньший и ставим перед ним
						if( re.priority > queue[i].priority ) {
							break;
						}
					}
					queue.splice(i,0, re );
					if (re.save)
						Warning.show("",Warning.TYPE_ERROR,Warning.STATUS_DEVICE_WRITING);
					return;
				}
				
				// проверка не клон ли
				if ( lastRequest.cmd == re.cmd && lastRequest.delegate == re.delegate && lastRequest.func == re.func && lastRequest.serverAdr == re.serverAdr && !re.dontClean) {
					if ( lastRequest.data && lastRequest.data == re.data && lastRequest.structure == re.structure )
						return;
					if ( !lastRequest.data && lastRequest.structure == re.structure )
						return;
				}
				
				
			}
			
			
			queue.push( re );
			if (re.save)
				Warning.show("",Warning.TYPE_ERROR,Warning.STATUS_DEVICE_WRITING);
		}
		private function sliceRequest(re:Request):void
		{
			var c:CommandSchemaModel = OPERATOR.getSchema( re.cmd );
			var len:int = c.StructCount;
			var r:Request;
			var dr:DisassembledRequest = new DisassembledRequest( len, re );
			for(var i:int=0; i<len; ++i ) {
				r = new Request( re.cmd, dr.attach, i+1, re.data, re.priority, re.param, re.serverAdr );
				r.smoothloader = re.smoothloader;
				queue.splice(i,0,r);
			}
		}
		private var lastQueueLength:int;
		private function cleanQueue():void
		{
			if (lastQueueLength != queue.length) {
				var len:int = queue.length;
				for (var i:int=0; i<len; ++i) {
					if ( i < queue.length )
						removeClones( queue[i] );
					else
						break;
				}
				lastQueueLength = queue.length;
			}
		}
		private function removeClones(r:Request):void
		{
			
			var len:int = queue.length;
			for (var i:int=0; i<len; ++i) {
				if ( i < queue.length) {
					if( queue[i] != r && !r.dontClean ) {
						if ( queue[i].cmd == r.cmd && queue[i].delegate == r.delegate && queue[i].func == r.func && queue[i].serverAdr == r.serverAdr ) {
							if ( (queue[i].data && isSameData(queue[i].data, r.data) && queue[i].structure == r.structure) ||
								(!queue[i].data && !r.data && queue[i].structure == r.structure ) ) {
								queue.splice(i,1);
							}
						}
					}
				} else
					break;
			}
			function isSameData(a1:Array, a2:Array):Boolean
			{
				if (a1.length == a2.length) {
					var lenq:int = a1.length;
					for (var q:int=0; q<len; ++q) {
						if (a1[q] != a2[q] )
							return false;
					}
					return true;
				}
				return false;
			}
		}
		private function getNext():Request
		{
			
			lastQueueLength--;
			return queue.shift();
		}
		private function processQueue():void
		{
			if ( queue.length == 0 || !SOCKET_READY )
				return;
			
			// блокировать отсылку команд в оффлайне при идущей прошивке
			if( !SocketProcessor.getInstance().connected && (CLIENT.IS_WRITING_FIRMWARE || CLIENT.IS_WRITING_VIP_DATA) )
				return;
			
			// значит есть активная посылка, которая ожидает ответа - нельзя формировать новые посылки
			if ( proRequest && proRequest.current > 0)
				return;
			
			if (queue.length > 1 && !CLIENT.IS_WRITING_FIRMWARE && !CLIENT.NO_CLONE_HUNT )
				cleanQueue();
			
			var q:Request = getNext();
			
			var cmd:CommandSchemaModel = OPERATOR.getSchema( q.cmd );
			if ( !cmd ) {
				clearStack();
				dtrace("ВНИМАНИЕ: КОММАНДЫ "+q.cmd+" НЕТ В КОММАНДОПШЕНС");
				return;
			}
			
			var sendRead:int = 14;
			var receiveRead:int = 14;
			var sendWrite:int = 14;
			var receiveWrite:int = 13;
			var q_next:Request;
			var next_size:int;
			var isRunCmd:Boolean = Boolean(CMD.RUN_CMD_HASH[q.cmd]);
			//DevConsole.write( "proRequest="+proRequest + " queue.length="+queue.length , DevConsole.SYSTEM );
			
			NetAdmin.init(q.serverAdr);
			
			if (CLIENT.PROTOCOL_BINARY)
				MAX_CMDS = SERVER.MAX_IND_CMDS;
			else
				MAX_CMDS = 1;
			
			var params:Object = {
				"SERVER.BUF_SIZE_SEND":SERVER.BUF_SIZE_SEND,
				"SERVER.BUF_SIZE_RECEIVE":SERVER.BUF_SIZE_RECEIVE,
				"SERVER.MAX_IND_CMDS":SERVER.MAX_IND_CMDS
			}
			
			// Константы инициализированы
			if ( SERVER.BUF_SIZE_SEND > 0 && SERVER.BUF_SIZE_RECEIVE > 0 && SERVER.MAX_IND_CMDS > -1 ) {
				if ( q.func == SERVER.REQUEST_READ ) {
					
					if ( !proRequest ) {
						proRequest = new ProtocolRequest(SERVER.REQUEST_READ);
						proRequest.delegate = delegateAssembler;
					} else if (proRequest.func != q.func ) {
						queue.splice(0,0,q);
						createPacket( proRequest );
						return;
					}
					
					requestWeight = q.structure == 0 ? cmd.GetReadCommandSize( CLIENT.PROTOCOL_BINARY ) : cmd.GetReadStructSize( CLIENT.PROTOCOL_BINARY );
					
					var sendReadTotal:int = proRequest ? sendRead + proRequest.length : sendRead;
					
					// Буфер устройства примет команду
					if ( SERVER.BUF_SIZE_RECEIVE >= sendReadTotal+2 ) {
						// Буфер устройства отошлет команду
						if ( SERVER.BUF_SIZE_SEND >= receiveRead + requestWeight + proRequest.size + 2 ) {
							// Создаем понятный для протокола формат
							
							//trace("");
							//trace("Start "+cmd.Name + " ("+cmd.Id+") " + int(sendRead + requestWeight) );
							proRequest.put( q, sendRead + requestWeight );
							
							while(true) {
								
								// Если очередь не пуста и при этом данная команда не отдельная
								if( queue.length > 0 && (proRequest.length+1)<= MAX_CMDS && !CMD.isSeparate(q.cmd) ) {
									// Выхватываем следующий объект из очереди
									q_next = queue[0];
									// Если адресация не совпадает, запрос не на чтение или следующая команда отдельная
									if ( q.mustBeLast || q_next.serverAdr != proRequest.serverAdr || q_next.func != proRequest.func || CMD.isSeparate(q_next.cmd) )
										break;
									cmd = OPERATOR.getSchema( q_next.cmd );
									
									if (!cmd) {
										trace("ВНИМАНИЕ: КОММАНДЫ "+q_next.cmd+" НЕТ В КОММАНДОПШЕНС");
										return;
									}
									
									next_size = q_next.structure == 0 ? cmd.GetReadCommandSize( CLIENT.PROTOCOL_BINARY ) : cmd.GetReadStructSize( CLIENT.PROTOCOL_BINARY );
									
									if(q_next.structure == 0 && SERVER.BUF_SIZE_SEND < proRequest.size + cmd.GetReadCommandSize( CLIENT.PROTOCOL_BINARY ) ) {
										sliceRequest(getNext());
										continue;
									}
									// Буфер устройства примет слепленный запрос
									if (SERVER.BUF_SIZE_SEND >= proRequest.size + next_size &&
										///FIXME: Поправлено вторично в связи с незаписью в прибор сохраненных данных (в-6 ) 4,08,2017
										//SERVER.BUF_SIZE_RECEIVE >= (sendRead + (proRequest.length+1) * 4)	) {
										SERVER.BUF_SIZE_RECEIVE >= proRequest.size + next_size	) {
										
										getNext();
										
										//trace(cmd.Name + " ("+cmd.Id+") " + next_size );
										proRequest.put( q_next, next_size );
										
										
										continue;
									}
								}
								break;
							}
							
							
							
							createPacket( proRequest );
						} else {
							if (q.structure == 0 ) {
								sliceRequest(q);
							} else {
								dtrace("Команда "+q.cmd+" не пролезает в буфер")
								dtrace("	SERVER.BUF_SIZE_SEND="+SERVER.BUF_SIZE_SEND );
								dtrace("	receiveRead="+receiveRead );
								dtrace("	requestWeight="+requestWeight );
								dtrace("	proRequest.size = "+proRequest.size +" proRequest.length = "+proRequest.length );
								dtrace("	"+proRequest.getStats() );
								dtrace("	q.structure="+q.structure );
								dtrace("	cmd.Id = "+cmd.Id + " cmd.Name = "+cmd.Name + " cmd.Parameters.length = "+cmd.Parameters.length );
								dtrace("	cmd.GetReadCommandSize( CLIENT.PROTOCOL_BINARY )="+cmd.GetReadCommandSize( CLIENT.PROTOCOL_BINARY ) );
								dtrace("	cmd.GetReadStructSize( CLIENT.PROTOCOL_BINARY )="+cmd.GetReadStructSize( CLIENT.PROTOCOL_BINARY ) );
							}
							proRequest = null;
						}
					}
				} else if ( q.func == SERVER.REQUEST_WRITE ) {
					
					// Если команда исполняемая
					if( isRunCmd ) {
						proRequest = new ProtocolRequest(SERVER.REQUEST_WRITE);
						proRequest.delegate = delegateAssembler;
						proRequest.put( q, 0 );
						createPacket( proRequest );
						return;
					}
					
					if ( !proRequest ) {
						proRequest = new ProtocolRequest(SERVER.REQUEST_WRITE);
						proRequest.delegate = delegateAssembler;
					} else if (proRequest.func != q.func ) {
						queue.splice(0,0,q);
						createPacket( proRequest );
						return;
					}
					
					requestWeight = q.structure == 0 ? cmd.GetWriteCommandSize( CLIENT.PROTOCOL_BINARY ) : cmd.GetReadStructSize( CLIENT.PROTOCOL_BINARY );
					
					// Буфер устройства примет команду
					if ( SERVER.BUF_SIZE_RECEIVE >= sendWrite + cmd.GetWriteStructSize( CLIENT.PROTOCOL_BINARY ) )	{
						// Буфер устройства отошлет команду
						if ( SERVER.BUF_SIZE_SEND >= receiveWrite ) {

							proRequest.put( q, sendWrite + cmd.GetWriteStructSize( CLIENT.PROTOCOL_BINARY ), isFunctional(q.cmd) );
							
							while(true) {
								// Если очередь не пуста
								if( queue.length > 0 && (proRequest.length+1)<= MAX_CMDS ) {
									// Выхватываем следующий объект из очереди
									q_next = queue[0];
									// Если запрос не на запись или внутри запроса исполняемая команда
									if ( q.mustBeLast || q_next.serverAdr != proRequest.serverAdr || q_next.func != proRequest.func || Boolean(CMD.RUN_CMD_HASH[q_next.cmd]) )
										break;
									cmd = OPERATOR.getSchema( q_next.cmd );
									
									next_size = cmd.GetWriteStructSize( CLIENT.PROTOCOL_BINARY );
									
									// Буфер устройства примет слепленный запрос, ответ тут не проверяется он всегда receiveWrite
									if (SERVER.BUF_SIZE_RECEIVE >= proRequest.size + next_size ) {
										
										if ( isFunctional(q_next.cmd) ) {
											if ( proRequest.functional )
												break;
											proRequest.put( q_next, next_size, true );
										} else
											proRequest.put( q_next, next_size );
										getNext();
										continue;
									}
								}
								break;
							}
							createPacket( proRequest );
						}
					}
				}
			} else {
				proRequest = new ProtocolRequest(q.func);
				proRequest.delegate = delegateAssembler;
				proRequest.put( q, 0 );
				createPacket( proRequest );
			}
		}
		
		private function createPacket( pr:ProtocolRequest ):void 
		{
			switch( CLIENT.PROTOCOL_BINARY )
			{
				case true:
					pBinary.processRequset( pr );
					break;
				case false:
					pText.processRequset( pr );
					break;
			}
		}
		public function responseSocket( _response:Array ):void
		{
			
			restartPing();
			switch( CLIENT.PROTOCOL_BINARY )
			{
				case true:
					pBinary.processResponse( _response );
					break;
				case false:
					pText.processResponse( _response );
					break;
			}
			if (_response)
				Warning.show( loc("sys_connected")+" " +DS.name+" (" + DS.getStatusVersion()+")", Warning.TYPE_SUCCESS, Warning.STATUS_DEVICE );
		}
		public function initSocket( _request:ByteArray ):void 
		{
			SOCKET_READY = false;
			SocketProcessor.getInstance().sendGeneratedRequest( _request, responseSocket );
			
			restartPing();
		}
		private function restartPing():void
		{
			if (proRequest) {
				switch(proRequest.serverAdr) {
					case SERVER.ADDRESS_TOP:
						doPing( Boolean( MISC.DEBUG_DO_PING == 1 ));						
						break;
					case SERVER.ADDRESS_BOTTOM:
						doPingBottom( Boolean( MISC.DEBUG_DO_PING == 1 ));
						break;
				}
			}
		}
		private function pingDevice(ev:TimerEvent):void
		{
			if ( (queue.length == 0 && (proRequest == null || proRequest.serverAdr != SERVER.ADDRESS_TOP)) && MISC.DEBUG_DO_PING && CLIENT.SYSTEM_LOADED ) {
				if (CLIENT.PROTOCOL_BINARY)
					fireEvent( new Request( CMD.PING,null,0,null,Request.EXTREME,0,SERVER.ADDRESS_TOP ));
				else {
					if (!MISC.VINTAGE_BOOTLOADER_ACTIVE)
						fireEvent( new Request( CMD.OP_sp_STOP_PANEL ));
				}
			}
		}
		private function pingBottomDevice(ev:TimerEvent):void
		{
			if ( (queue.length == 0 || (proRequest == null || proRequest.serverAdr != SERVER.ADDRESS_BOTTOM)) && MISC.DEBUG_DO_PING && SERVER.DUAL_DEVICE && CLIENT.SYSTEM_LOADED)
				fireEvent( new Request( CMD.PING,null,0,null,Request.EXTREME,0,SERVER.ADDRESS_BOTTOM ));	
		}
		
		/**
		 * 
		 *  Остановка/запуск PING
		 * 
		 * @param value true - запустить, false - остановить
		 */
		public function doPing(value:Boolean):void
		{
			
			if ( value ) {
				timerPing.addEventListener(TimerEvent.TIMER, pingDevice );
				timerPing.reset();
				timerPing.start();
			} else {
				timerPing.removeEventListener(TimerEvent.TIMER, pingDevice );
				timerPing.stop();
			}
		}
		public function doPingBottom(value:Boolean):void
		{
			if ( value ) {
				timerPingBottom.addEventListener(TimerEvent.TIMER, pingBottomDevice );
				timerPingBottom.reset();
				timerPingBottom.start();
			} else {
				timerPingBottom.removeEventListener(TimerEvent.TIMER, pingBottomDevice );
				timerPingBottom.stop();
			}
		}
		private function errorPackage():Package
		{
			var p:Package = new Package;
			p.error = false;
			return p;
		}
		
		public function delegateAssembler(post:Vector.<Package>, packetNumber:int=0):void
		{
			
			
			var len:int;
			var i:int;
			var p:Package;
			var error:String = "Найден пакет без ответа, идет пересылка";
			
			if (post.length > 0 ) {
			
				if (!post[0] ) {
					error = "Ответ от прибора null";
				} else if (post[0].broken) {	// broken помечается недошедший от прибора пакет
					error = "Ответ от прибора не дошел или дошел только кусок пакета";
				} else if (post[0].success) {
					if (proRequest) {
						// если в запросе на чтение пришел ответ на запись надо стирать весь стэк 
						if (proRequest.func == SERVER.REQUEST_WRITE) {
							len = proRequest.length;
							for( i=0; i<len; ++i) {
								p = new Package;
								p.success = true;
								p.request = proRequest.getData(i);
								p.cmd = p.request.cmd;
								p.structure = p.request.structure;
								if (post[0].data)
									p.data = post[0].data;
								OPERATOR.update( p.request );
								p.launch();
							}
						} else {
							dtrace("В запросе на чтение команды "+OPERATOR.getSchema(proRequest.getCmd(0)).Name+" ("+proRequest.getCmd(0)+") пришел ответ на запись");
							clearStack();
						}
					}/* else
						dtrace("proRequest = null");*/
					
				} else {
					len = post.length;
					for( i=0; i<len; ++i) {
						post[i].request = getRequest(post[i].cmd, post[i].structure);
						OPERATOR.update( post[i] );
						post[i].launch();
					}
				}
			}

			if (proRequest) {
				len = proRequest.length;
				for (i=0; i<len; ++i) {
					if( !proRequest.isComplete(i) ) {
						dtrace( error );
						if( post[0].broken ) // пересылать запрос стоит только если прибор не ответил
							reSend();
						else
							TaskManager.callLater(reSend,1000);	// подождать минуту может быть запрос доедет, если нет - переслать
						return;
					}
				}
				// если current реквест на чтение или реквест с пометкой сохранение но при этом длина очереди 0 или следующий не имеет save
				//if( proRequest.func == SERVER.REQUEST_READ || (proRequest.save && ( queue.length==0 || !queue[0].save ))) {
				if( queue.length==0 || (proRequest.func == SERVER.REQUEST_READ && !isWritePackageinQueue()) ) {
					Warning.show("",Warning.TYPE_SUCCESS,Warning.STATUS_DEVICE_WRITING);
				}
				proRequest = null;
			}
			SOCKET_READY = true;
			if (CLEAR_STACK)
				clearStackLaterComplete();
		}
		private function isWritePackageinQueue():Boolean
		{
			var len:int = queue.length;
			for (var i:int=0; i<len; ++i) {
				if( queue[i].save || queue[i].func == SERVER.REQUEST_WRITE )
					return true;
			}
			return false;
		}
		private function getRequest(_cmd:int, _structure:int):Request
		{
			if (proRequest) {
				var len:int = proRequest.length;
				for(var i:int=0; i<len; ++i) {
					if( proRequest.getCmd(i) == _cmd && proRequest.getStruc(i) == _structure && !proRequest.isComplete(i) ) {	
												// подбираем не готовый подходящей по запросу структуры и команды запрос
						return proRequest.getData(i);
					}
				}
				dtrace("ERROR: Команда "+ _cmd + " пришла без запроса");
			}
			return null;
		}
		public function clearRequest():void
		{
			proRequest = null;
		}
		public function stopAndFree():void
		{
			queue.length = 0;
			proRequest = null;
			clearStack();
			SOCKET_READY = true;
		}
		private function reSend():void
		{
			if (proRequest) {
				if ( CLIENT.IS_WRITING_FIRMWARE || CLIENT.ALWAYS_TRY || proRequest.sent < CLIENT.ENSURE_TRY_TIMES) {
					proRequest.resend();
					createPacket(proRequest);
				} else {
					Warning.show( loc("sys_not_responding")+" " +DS.name+" (" + DS.getStatusVersion()+")", Warning.TYPE_ERROR, Warning.STATUS_DEVICE );
					SocketProcessor.getInstance().disconnect();
				}
			}
		}
		private function isFunctional(_cmd:int):Boolean
		{
			var len:int = functions.length;
			for(var i:int=0; i<len; ++i ) {
				if( functions[i] == _cmd )
					return true;
			}
			return false;
		}
		private function onOnline(e:SystemEvents):void
		{
			if (!e.isConneted()) {
				if( proRequest && proRequest.length > 0 && (CLIENT.IS_WRITING_FIRMWARE || CLIENT.IS_WRITING_VIP_DATA) ) {
					var len:int = proRequest.length;
					for (var i:int=0; i<len; ++i) {
						var r:Request = proRequest.getCurrent();
						queue.unshift( r );
					}
					proRequest = null;
				}
				SocketProcessor.getInstance().clear();
				
				Warning.show("",Warning.TYPE_SUCCESS,Warning.STATUS_DEVICE_WRITING);
			} else {
				if (queue.length > 0 && isWritePackageinQueue() )
					Warning.show("",Warning.TYPE_ERROR,Warning.STATUS_DEVICE_WRITING);					
			}
		}
		public function online():Boolean
		{
			return SocketProcessor.getInstance().connected;
		}
		public function getstats():String
		{
			var txt:String = "RequestAssembler ---------------\n"+
				"queue.length: "+queue.length+ "\n"+
				"SOCKET_READY: "+SOCKET_READY+ "\n"+
				"CLIENT.IS_WRITING_FIRMWARE: "+ CLIENT.IS_WRITING_FIRMWARE+ "\n"+
				"CLIENT.IS_WRITING_VIP_DATA: "+ CLIENT.IS_WRITING_VIP_DATA+ "\n"+
				"CLIENT.PROTOCOL_BINARY: "+CLIENT.PROTOCOL_BINARY+ "\n"+
				"proRequest: "+ Boolean(proRequest);
			if (proRequest)
				txt += "\n"+proRequest.getStats();
			return txt;
		}
/******************** TCP CLIENT  *********************************/
		private var pTCP:ProtocolTCP;
		
		public function TCPRequest(u:String, f:Function):void
		{
			if (!pTCP)
				pTCP = new ProtocolTCP();
			pTCP.connect( u, f, false );
		}
		public function TCPClose():void
		{
			if(pTCP)
				pTCP.disconnect();
		}
/******************** HTTP CLIENT *********************************/
		
		private var pHttp:ProtocolHttp;
		private var httpFifoServant:HttpFIFOServant;
		private var fErrorListener:Function;
		
		public function HTTPSetUp(url:String, user:String="", pass:String=""):void
		{
			if (pHttp) {
				pHttp.disconnect();
				if (fErrorListener != null)
					pHttp.removeEventListener( GUIEvents.EVOKE_CONNECTION_ERROR, fErrorListener );
				if (httpFifoServant)
					pHttp.removeEventListener( GUIEvents.EVOKE_READY, httpFifoServant.launch );
				fErrorListener = null;
			}
			pHttp = new ProtocolHttp(url,user,pass);
			
			
		}
		public function HTTPRequest(u:String, f:Function, useTimeout:Boolean=false):void
		{
			
			if (pHttp) {
				/*if (CLIENT.USE_HTTP_FIFO_SERVANT) {
					if (!httpFifoServant) {
						httpFifoServant = new HttpFIFOServant(pHttp.connect, isHttpREADY);
						pHttp.addEventListener( GUIEvents.EVOKE_READY, httpFifoServant.launch );
					}
					httpFifoServant.put( pHttp.connect, [u,f,useTimeout] );
					if (pHttp.READY)
						pHttp.disconnect();
				} else {*/
					pHttp.connect(u,f,useTimeout);
				//}
			}
		}
		
		public function HTTPClose(b:Boolean=false):void
		{
			if (pHttp)
				pHttp.disconnect();
		}
		public function isHTTPOpen():Boolean
		{
			return pHttp && pHttp.connected;
		}
		public function HTTPErrorListener(f:Function):void
		{
			if (pHttp) {
				pHttp.addEventListener( GUIEvents.EVOKE_CONNECTION_ERROR, f );
				fErrorListener = f;
			}
		}
		private function isHttpREADY():Boolean
		{
			return pHttp.READY;
		}
	}
}
import flash.display.Stage;
import flash.events.Event;

import mx.core.FlexGlobals;

import components.abstract.servants.abstract.QueueFIFOServant;
import components.protocol.statics.SERVER;

class NetAdmin {
	public static function init(adr:int):void
	{
		switch(adr) {
			case SERVER.ADDRESS_TOP:
				SERVER.BUF_SIZE_RECEIVE = SERVER.TOP_BUF_SIZE_RECEIVE;
				SERVER.BUF_SIZE_SEND = SERVER.TOP_BUF_SIZE_SEND;
				SERVER.MAX_IND_CMDS = SERVER.TOP_MAX_IND_CMDS;
				break;
			case SERVER.ADDRESS_BOTTOM:
				SERVER.BUF_SIZE_RECEIVE = Math.min( SERVER.BOTTOM_BUF_SIZE_RECEIVE, SERVER.TOP_BUF_SIZE_RECEIVE );
				SERVER.BUF_SIZE_SEND = Math.min( SERVER.BOTTOM_BUF_SIZE_SEND, SERVER.TOP_BUF_SIZE_SEND );
				SERVER.MAX_IND_CMDS = Math.min( SERVER.BOTTOM_MAX_IND_CMDS, SERVER.TOP_MAX_IND_CMDS );
				break;
		}
	}
}
class HttpFIFOServant extends QueueFIFOServant
{
	private var fReady:Function;
	
	public function HttpFIFOServant(f:Function, ready:Function)
	{
		super();
		
		fReady = ready;
	}
	public function launch(e:Event):void
	{
		getStage().addEventListener( Event.ENTER_FRAME, later );
	}
	private function later(e:Event):void
	{
		if (fReady() == true) {
			var o:Object = take();
			if (o) {
				var a:Array = o.args as Array;
				o.callback( a[0], a[1], a[2] );
			}
		}
	}
	private function getStage():Stage
	{
		return FlexGlobals.topLevelApplication.stage;
	} 
}