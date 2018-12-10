package components.abstract.servants
{
	import components.abstract.sysservants.PartitionServant;
	import components.events.GUIEventDispatcher;
	import components.events.SystemEvents;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.protocol.statics.OPERATOR;
	import components.static.CMD;
	import components.static.PART_FUNCT;
	import components.system.UTIL;

	public class K9PartitionManager
	{
		public function K9PartitionManager()
		{
		}
		
		private static var inst:K9PartitionManager;
		public static function access():K9PartitionManager
		{
			if(!inst)
				inst = new K9PartitionManager;
			return inst;
		}
		public function launch():void
		{
			if (!OPERATOR.getData(CMD.K9_AWIRE_TYPE))
				RequestAssembler.getInstance().fireEvent(new Request(CMD.K9_AWIRE_TYPE));
			
			
			
			RequestAssembler.getInstance().fireEvent(new Request(CMD.K9_PART_PARAMS,onPartition));
			RequestAssembler.getInstance().fireEvent(new Request(CMD.K9_EXIT_PART,onPartition));
			RequestAssembler.getInstance().fireEvent(new Request(CMD.K9_PERIM_PART,onPartition));
			RequestAssembler.getInstance().fireEvent(new Request(CMD.READER_TM,onPartition));
			
			RequestAssembler.getInstance().fireEvent(new Request(CMD.K5_TM_KEY_CNT,onPartition));
			RequestAssembler.getInstance().fireEvent(new Request(CMD.K5_KBD_KEY_CNT));
			
			
			
			lastcmd = 0;
		}
		private var lastcmd:int;
		private var laststruct:int;

		
		
		private function onPartition(p:Package):void
		{
			var i:int, lenj:int, j:int, replace:int, bf:int;
			var structs:Array = [];
			var firstchanged:int = -1;	// номер структуры первой измененной записи
			var value:int;
			var changed:Boolean;
			switch(p.cmd) {
				case CMD.K9_PART_PARAMS:
					var len:int = p.length;
					lenj = p.data[0].length;
					var needsave:Boolean = false;
					for (i=0; i<len; i++) {
						if( !PartitionServant.isPartitionAssigned(i+1) ) {
							needsave = false;
							for (j=0; j<lenj; j++) {
								if ( p.getParam(j+1,i+1) != 0 ) {
									needsave = true;
									break;
								}
							}
							if( needsave )
								RequestAssembler.getInstance().fireEvent(new Request(CMD.K9_PART_PARAMS,null,i+1,[0,0,0,0,0,0,0],Request.NORMAL,Request.PARAM_SAVE));
						}
					}
					break;
				case CMD.K9_EXIT_PART:
				case CMD.K9_PERIM_PART:
					value = int(p.getParam(1));
					changed = false;
					for (i=0; i<8; i++) {
						if( (!PartitionServant.isPartitionAssigned(i+1) || isSystemPartition(i+1) ) && UTIL.isBit(i,value) ) {
							value = UTIL.changeBit(value,i,false);
							changed = true;
						}
					}
					if (changed) {
						RequestAssembler.getInstance().fireEvent(new Request(p.cmd,null,1,[value],Request.NORMAL,Request.PARAM_SAVE));
					}
					break;
				case CMD.K5_TM_KEY_CNT:
					if (p.getParamInt(1) != 0)
						RequestAssembler.getInstance().fireReadSequence( CMD.K5_TM_KEY, onPartition, p.getParamInt(1) );
						//RequestAssembler.getInstance().fireReadSequence( CMD.K5_TM_KEY, null, p.getParamInt(1) );
					else	// если ТМ ключи проверять не надо, запускается следующий блок
						RequestAssembler.getInstance().fireEvent(new Request(CMD.K5_KBD_KEY_CNT,onPartition));
					break;
				case CMD.READER_TM:
					value = int(p.getParam(8));
					
					changed = false;
					for (i=0; i<8; i++) {
						if( (!PartitionServant.isPartitionAssigned(i+1) || isSystemPartition(i+1) ) && UTIL.isBit(i,value) ) {
							p.data[ 0 ][ 7 ]  = UTIL.changeBit(value,i,false);
							changed = true;
						}
					}
					
					if (changed) {
						RequestAssembler.getInstance().fireEvent(new Request(p.cmd,null,1,p.data[ 0 ] ,Request.NORMAL,Request.PARAM_SAVE));
					}
					break;
				case CMD.K5_TM_KEY:
				case CMD.K5_KBD_KEY:
					
					
					/// кол-во ключей
					len = p.length;
					
					
					for (i=0; i<len; i++) {
						/// получаем битовую маску разделов закрепленных за ключом
						bf = p.getParamInt( getPartStructure(p.cmd),i+1);
						replace = bf;
						// если партишен не назначен ни на какой шлейф или партишен 24часа - удаляем из ключей
						for (j=0; j<6; j++) {	// проверка битовой маски партишенов
							
							/// проверка бита соотв. раздела
							/// если бит включен
							if( UTIL.isBit(j,bf) 
								/// и раздел соотв. этому биту не наличествует
								&& (!PartitionServant.isPartitionAssigned(j+1)
									/// или назначен за 24 часа
									|| isPartition24Hours(j+1)) ) 
							{
								/// выключаем бит в маске
								replace = UTIL.changeBit( replace, j, false );
								
								
							}
						}
						// если исходное битовое поле отличается от измененного, значит был удален запрещенный партишен 
						if (replace != bf && replace > 0) {
							if (firstchanged < 0)
								firstchanged = i+1;
							structs.push( createStructure(p, i, replace) );
							lastcmd = p.cmd;
						} else if (replace == 0 && firstchanged < 0) {	// если партишенов нет вообще и это первый ключ, его придется удалить
							firstchanged = i+1;
							lastcmd = p.cmd;
				//			deleted.push({data:p.data[i],index:i});
						} else if (replace == 0 ) {	// если партишенов нет вообще и это не первый ключ
							lastcmd = p.cmd;
				//			deleted.push({data:p.data[i],index:i});
						} else {	// если не было изменений
							//if (firstchanged > -1)	// если был найдено изменение, придется запомнить ключ чтобы возможно сместить его потом по структуре вниз (если было удаление) 
								structs.push( p.data[i] );
						}
					}
					
					
					
					
					if (lastcmd != p.cmd) {	// изменений не было вообще
						if (isLast(p.cmd))	// если команда последняя - надо заканчивать, либо запускать следующую
							onComplete(null);
						else
							RequestAssembler.getInstance().fireEvent(new Request(CMD.K5_KBD_KEY_CNT,onPartition));
					} else {
						len = structs.length;
						
						for (i=0; i<len; i++) {
							if (isLast(p.cmd)) {
								RequestAssembler.getInstance().fireEvent(new Request(p.cmd,onComplete,i + 1,
									structs[i],Request.NORMAL,Request.PARAM_SAVE));
								laststruct = firstchanged+i;
								
								
							} else {
								
								RequestAssembler.getInstance().fireEvent(new Request(p.cmd,null, i + 1,
									structs[i],Request.NORMAL,Request.PARAM_SAVE));
							}
						}
						
						
						var cmd_cnt:int = getCmdCnt(p.cmd);
						
						
						if (OPERATOR.getParamInt(cmd_cnt,1) != ( laststruct - 1 ) ) {	// необходимо обновить общее количество ключей
							
							if (isLast(p.cmd)) {
								
								RequestAssembler.getInstance().fireEvent(new Request(cmd_cnt,onComplete,1,[structs.length],Request.NORMAL,Request.PARAM_SAVE));
								//RequestAssembler.getInstance().fireEvent(new Request(cmd_cnt,onComplete,1 ) );
								lastcmd = cmd_cnt;
								laststruct = 1;
							} else {
								
								
								RequestAssembler.getInstance().fireEvent(new Request(cmd_cnt,null,1,[structs.length],Request.NORMAL,Request.PARAM_SAVE));
								//RequestAssembler.getInstance().fireEvent(new Request(cmd_cnt,null,1 ) );
								RequestAssembler.getInstance().fireEvent(new Request(CMD.K5_KBD_KEY_CNT,onPartition));
							}
						}
				//		fireBalloon(deleted);
					}
					break;
				case CMD.K5_KBD_KEY_CNT:
					
					
					if (p.getParamInt(1) != 0) {
						RequestAssembler.getInstance().fireReadSequence( CMD.K5_KBD_KEY, onPartition, p.getParamInt(1) );
						lastcmd = p.cmd;
					} else
						onComplete(null); // значит никаких изменений не было добавлено
					
					break;
			}
			
			selectPartsOfLeft();
		}
		private function onComplete(p:Package):void
		{
			if ( p == null || (lastcmd == p.cmd && laststruct == p.structure) ) {
				blockNaviSilent = false;
				loadComplete();
			}
		}
	/*	private function fireBalloon(a:Array):void
		{
			if (a && a.length > 0) {
				var phex:int, index:int;
				var code:String, part:String = "", msg:String = "";
				var len:int = a.length;
				for (var j:int=0; j<len; j++) {
					phex = a[j].data[1];
					index = a[j].index;
					code = int(a[j].data[0]).toString(16).toUpperCase();
					var is24:Boolean;
					var isPart:Boolean;
					
					for (var i:int=0; i<16; i++) {
						if( UTIL.isBit(i,phex) ) {
							if (part.length > 0)
								part += ", ";
							part += i+1;
							if(isPartition24Hours(i+1))
								is24 = true;
							if(PartitionServant.isPartitionAssigned(i+1))
								isPart = true;
						}
					}
					
					var ending:String;
					if ( is24 )
						ending = "раздел 24";
					if ( isPart )
						ending = "удален раздел";
					if (part.length == 0)
						part = loc("g_no").toLowerCase();
					
					msg = loc("k9_usercode_deleted") +": " +(index + 1)+" ("+code +")\r" +
						loc("k9_usercode_part_linked") + ": " + part +"\r" + ending;
					
					
				}
				Balloon.access().showResizable("sys_attention",msg,400);
			}
		}*/
		
/****	UTIL				****/
		private function getPartStructure(cmd:int):int
		{
			switch(cmd) {
				case CMD.K5_KBD_KEY:
					return 2;
				case CMD.K5_TM_KEY:
					return 9;
			}
			return 0;
		}
		private function createStructure(p:Package, i:int, bf:int):Array
		{
			switch(p.cmd) {
				case CMD.K5_KBD_KEY:
					return [p.getParamInt(1,i+1),bf,p.getParam(3,i+1)];
				case CMD.K5_TM_KEY:
					var a:Array = (p.data[i] as Array).slice();
					a[8] = bf;
					return a;
			}
			return null;
		}
		private function isLast(cmd:int):Boolean
		{
			return cmd == CMD.K5_KBD_KEY;
		}
		private function getCmdCnt(cmd:int):int
		{
			switch(cmd) {
				case CMD.K5_KBD_KEY:
					return CMD.K5_KBD_KEY_CNT;
				case CMD.K5_TM_KEY:
					return CMD.K5_TM_KEY_CNT;
			}
			return 0;
		}
		private function isPartition24Hours(struct:int):Boolean
		{
			var a:Array = OPERATOR.getData(CMD.K9_PART_PARAMS);
			if ( int(a[struct-1][4]) == 1)
				return true;
			return false;
		}
		private function isSystemPartition(struct:int):Boolean
		{
			var a:Array = OPERATOR.getData(CMD.K9_PART_PARAMS);
			if ( int(a[struct-1][4]) == 1 || int(a[struct-1][5]) == 1 )
				return true;
			return false;
		}
		private function set blockNaviSilent(b:Boolean):void
		{
			GUIEventDispatcher.getInstance().fireSystemEvent( SystemEvents.onBlockNavigationSilent, {"isBlock":b} );
		}
		private function loadComplete():void
		{
			GUIEventDispatcher.getInstance().fireSystemEvent( SystemEvents.pageLoadLComplete );
		}
		
		private function selectPartsOfLeft():void
		{
			var b:Boolean = UTIL.isBit( 1, OPERATOR.dataModel.getData( CMD.K9_BIT_SWITCHES )[ 0 ][ 0 ] );
			
			var wire:Array = OPERATOR.dataModel.getData( CMD.K9_AWIRE_TYPE );
			var partsUpdateState:Array = new Array;
			/// если сухие смотрим только первую половину шлейфов
			var len:int = b?wire.length / 2:wire.length;
			const partis:Array = new Array;
			// перебираем шлейфы и смотрим какие разделы в них указаны
			for (var i:int=0; i<len; i++) 
				partis[ wire[ i ][ 1 ] ] = 1;
			
			len = wire.length;	
			for (var j:int=0; j<len; j++) 
				if( !partis[ j ] ) partsUpdateState.push( j );
			
			len = partsUpdateState.length;
			for (var h:int=0; h<len; h++) 
				RequestAssembler.getInstance().fireEvent( new Request( CMD.PART_FUNCT, null, 1, [ partsUpdateState[ h ] + 1, PART_FUNCT.TAKEOFFGUARD ] ));
		}
	}
}