package components.screens.ui
{
	import components.abstract.GroupOperator;
	import components.abstract.RegExpCollection;
	import components.abstract.functions.loc;
	import components.abstract.servants.K5PartitionManager;
	import components.abstract.servants.ResizeWatcher;
	import components.abstract.servants.TaskManager;
	import components.basement.UI_BaseComponent;
	import components.gui.Header;
	import components.gui.MFlexListWire;
	import components.gui.fields.FSCheckBox;
	import components.gui.fields.FSComboBox;
	import components.gui.fields.FSShadow;
	import components.interfaces.IResizeDependant;
	import components.interfaces.ITask;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.protocol.statics.OPERATOR;
	import components.screens.opt.OpPartition;
	import components.static.CMD;
	import components.static.DS;
	import components.system.SavePerformer;
	import components.system.UTIL;
	
	public class UIPartitionK5 extends UI_BaseComponent implements IResizeDependant
	{
		private var flist:MFlexListWire;
		private var go:GroupOperator;
		private var bitpackage:Package;	// чтобы сохранить бит свитчи и вставить их после создания 
		private var savedstructs:Object;
		private var savedfirestr:Object;
		private var task:ITask;
		
		public function UIPartitionK5()
		{
			super();
			
			/**
			 Команда K5_PART_PARAMS - параметры разделов
			 Параметр 1 - состояние раздела, 0 - без охраны; 1 - под охраной, 2 - под охраной, была тревога
			 Параметр 2 - Быстрая постановка: 1 - разрешена; 0 - запрещена
			 Параметр 3 - Ожидать передачу на пульт: 1 - разрешено; 0 - запрещено
			 Параметр 4 - Включать сирену при тревоге: 1 - разрешено; 0 - запрещено
			 Параметр 5 - 24-х-часовой раздел: 1 - да; 0 - нет
			 Параметр 6 - пожарный раздел: 1 - да; 0 - нет
			 */
			
			flist = new MFlexListWire(OpPartition);
			
			flist.height = 350;
			
			var header:Header
			
			
			if( DS.alias == DS.K5 
				//|| DS.isDevice(DS.A_BRD ) 
				|| DS.isDevice(DS.K53G) )
			{
				const hdrs:Array =
					[
						{label:loc("ui_part_k5_num"),xpos:30},
						{label:loc("ui_part_k5_state"),xpos:30+50, width: 200, align:"center"},
						{label:loc("ui_part_k5_fast_guard"),align:"center",xpos:195+150-37+4, width:150},
						{label:loc("ui_part_k5_siren_when_alarm"), align:"center", xpos:300+150-37, width:150}, 
						{label:loc("ui_part_k5_part24"),align:"center",xpos:395+150-33, width:150},
						{label:loc("ui_part_k5_partfire"),align:"center",xpos:490+150-37+8, width:150},
						{label:loc("ui_part_k5_delay"),align:"center",xpos:600+150-12, width:100},
						{label:loc("ui_part_k5_delay"),align:"center",xpos:600+150-12, width:100},
						{label:loc("name_part"),align:"center",xpos:600+150 + 100 - 5, width:100}
					];
				if( DS.release == 12 ) hdrs.splice( hdrs.length - 1, 1 );
				 header	= new Header( hdrs, {size:11} );	
				 
				 flist.width = 950;
			}
			else if( DS.alias == DS.A_BRD )
			{
				header	= new Header( [{label:loc("ui_part_k5_num"),xpos:30},
					{label:loc("ui_part_k5_state"),xpos:30+50, width: 200, align:"center"},
					{label:loc("ui_part_k5_fast_guard"),align:"center",xpos:195+150-37+4, width:150},
					{label:loc("ui_part_k5_siren_when_alarm"), align:"center", xpos:300+150-37, width:150}, 
					{label:loc("ui_part_k5_part24"),align:"center",xpos:500, width:150},
					//{label:loc("ui_part_k5_partfire"),align:"center",xpos:490+150-37+8, width:150},
					{label:loc("ui_part_k5_delay"),align:"center",xpos:500 + 150, width:100},
					{label:loc("name_part"),align:"center",xpos:500 + 150 + 100, width:100}], {size:11} );
				
				flist.width = 780;
				flist.height = 700;
				
				flist.width = 880;
			}
			else if( DS.alias == DS.K5GL )
			{
				header	= new Header( [{label:loc("ui_part_k5_num"),xpos:30},
					{label:loc("ui_part_k5_state"),xpos:30+50, width: 200, align:"center"},
					{label:loc("ui_part_k5_fast_guard"),align:"center",xpos:195+150-37+4, width:150},
					{label:loc("ui_part_k5_siren_when_alarm"), align:"center", xpos:300+150-37, width:150}, 
					{label:loc("ui_part_k5_part24"),align:"center",xpos:395+150-33, width:150},
					//{label:loc("ui_part_k5_partfire"),align:"center",xpos:490+150-37+8, width:150},
					{label:loc("ui_part_k5_delay"),align:"center",xpos:650, width:100},
					{label:loc("ui_part_k5_delay"),align:"center",xpos:650, width:100},
					{label:loc("name_part"),align:"center",xpos:600+150 + 100 - 5, width:100}], {size:11} );
				
				flist.width = 880;
			}
			else if( DS.isfam( DS.K5AA ) )
			{
				header	= new Header( [{label:loc("ui_part_k5_num"),xpos:30},
					{label:loc("ui_part_k5_state"),xpos:30+50, width: 200, align:"center"},
					{label:loc("ui_part_k5_fast_guard"),align:"center",xpos:195+150-37+4, width:150},
					//{label:loc("ui_part_k5_siren_when_alarm"), align:"center", xpos:300+150-37, width:150}, 
					{label:loc("ui_part_k5_part24"),align:"center",xpos:395+50-33, width:150},
					//{label:loc("ui_part_k5_partfire"),align:"center",xpos:490+150-37+8, width:150},
					{label:loc("ui_part_k5_delay"),align:"center",xpos:550, width:100},
					{label:loc("ui_part_k5_delay"),align:"center",xpos:550, width:100},
					{label:loc("name_part"),align:"center",xpos:600+50 + 20  - 5, width:100}], {size:11} );
				
				flist.width = 780;
				flist.height = 700;
			}
			
			
			globalY += 10;
			addChild( header );
			header.y = globalY;
			globalY+=30;
			globalY += 10;
			
			
			addChild(flist);
			
			
			flist.y = globalY;
			flist.x = globalX;
			
			
			globalY = flist.height;
			
			go = new GroupOperator;
			
			/**K5_PART_EVCOUNT	*/
			
			go.add("down", drawSeparator(950) );
			
			var w:int = 400;
			var list:Array = UTIL.getComboBoxList( [[10,"10"],[150,"150"],[254,"254"],[0,loc("ui_part_k5_nolimits")]] );
			addui( new FSComboBox, CMD.K5_PART_EVCOUNT, loc("ui_part_k5_event_limit"), null, 1, list, "0-9", 2, new RegExp(RegExpCollection.REF_0_10to254) );
			go.add("down", getLastElement() );
			attuneElement( w, 150 );
			
			if( !DS.isDevice( DS.K5A ) )
			{
				/**K5_SYR_LEN	*/
				list = UTIL.getComboBoxList( [[10,"10"],[15,"15"],[20,"20"],[30,"30"],[60,"60"],[125,"125"],[255,loc("ui_part_k5_continuously")]] );
				//addui( new FSSimple, CMD.K5_SYR_LEN, "Длительность работы сирены (сек)", null, 1, null, "0-9", 3, new RegExp(RegExpCollection.REF_0to255) );
				addui( new FSComboBox, CMD.K5_SYR_LEN, loc("ui_part_k5_time_siren"), null, 1, list, "0-9", 3, new RegExp(RegExpCollection.REF_001to125) );
				go.add("down", getLastElement() );
				getLastElement().setAdapter(new SyrLenAdapter);
				attuneElement( w, 150 );
				
				/**	K5_SYR_PAR	*/
				
				
				list = UTIL.getComboBoxList( [[0,loc("ui_part_k5_syr_disabled")],[1, loc("ui_part_k5_syr_1hz")],[2,loc("ui_part_k5_syr_05hz")],[3,loc("ui_part_k5_always_on")]] );
				
			
				
				addui( new FSComboBox, CMD.K5_SYR_PAR, loc("ui_part_k5_syr_mode_fire_warning"), null, 1, list  );
				attuneElement( w, 150, FSComboBox.F_COMBOBOX_NOTEDITABLE );
				go.add("down", getLastElement() );
				
				addui( new FSComboBox, CMD.K5_SYR_PAR, loc("ui_part_k5_syr_mode_fire_alarm"), null, 2, list  );
				attuneElement( w, 150, FSComboBox.F_COMBOBOX_NOTEDITABLE );
				go.add("down", getLastElement() );
				
				addui( new FSComboBox, CMD.K5_SYR_PAR, loc("ui_part_k5_syr_mode_guard_alarm"), null, 3, list  );
				attuneElement( w, 150, FSComboBox.F_COMBOBOX_NOTEDITABLE );
				go.add("down", getLastElement() );
				/** Отключение сирены кнопкой ОТМЕНА на клавиатуре (0 - не отключать сирену, 1 - отключать сирену) */
				addui( new FSCheckBox, CMD.K5_BIT_SWITCHES, loc("ui_part_k5_cancel_syr"), null, 1 );
				attuneElement( w + 137, NaN, FSComboBox.F_COMBOBOX_NOTEDITABLE );
				(getLastElement() as FSCheckBox).bitnum = 4;
				go.add("down", getLastElement() );
				
			}
			else if( DS.isfam( DS.K5,  DS.K5, DS.K53G, DS.K5GL  ) )
			{
				
				addui( new FSShadow, CMD.K5_BIT_SWITCHES, "", null, 1 );
			}
		
			
			
			
			
			addui( new FSCheckBox(), CMD.PART_SET_TEST_LINK, loc( "part_set_test" ), null, 1 );
			attuneElement( w + 137, 11 );
			go.add("down", getLastElement() );
			//getLastElement().setAdapter( new PartTestLinkAdapter );
			
			
			addui( new FSShadow,CMD.K5_BIT_SWITCHES, "", null, 2 );
			addui( new FSShadow,CMD.K5_BIT_SWITCHES, "", null, 3 );
			
			manualResize();
			
			starterCMD = [CMD.K5_BIT_SWITCHES,
						CMD.K5_PART_EVCOUNT,
						CMD.K5_PART_PARAMS,
						CMD.PART_STATE_ALL,
						CMD.PART_SET_TEST_LINK,
						CMD.K5_PART_DELAY];
			
			if(  DS.isfam( DS.K5, DS.K5A ))
			{
				(starterCMD as Array).splice( 2,0, CMD.K5_SYR_LEN );
				(starterCMD as Array).splice( 2,0, CMD.K5_SYR_PAR );
			}
			
			if( DS.release > 12)
			{
				(starterCMD as Array).splice( 2,0, CMD.SMS_PART );
			}
				
			if( !OPERATOR.dataModel.getData(CMD.K5_AWIRE_DELAY) )
				(starterCMD as Array).splice( 0,0, CMD.K5_AWIRE_DELAY );
			if( !OPERATOR.dataModel.getData(CMD.K5_AWIRE_PART_CODE) )
				(starterCMD as Array).splice( 0,0, CMD.K5_AWIRE_PART_CODE );
			if( !OPERATOR.dataModel.getData(CMD.OBJECT) )
				(starterCMD as Array).splice( 0,0, CMD.OBJECT );
			if( !OPERATOR.dataModel.getData(CMD.K5_AWIRE_TYPE) )
				(starterCMD as Array).splice( 0,0, CMD.K5_AWIRE_TYPE );
			
			manualResize();
			
			
			this.height = 800;
			
		}
		override public function put(p:Package):void
		{
			switch(p.cmd) {
				case CMD.K5_BIT_SWITCHES:
					bitpackage = p;
					refreshCells( p.cmd, true );
				case CMD.K5_PART_EVCOUNT:
				case CMD.K5_SYR_LEN:
				case CMD.K5_SYR_PAR:
					distribute(p.getStructure(),p.cmd);
					break;
				case CMD.K5_PART_DELAY:
					flist.putPack(p.getStructure());
					loadComplete();
					SavePerformer.trigger( {cmd:cmd, after:after} );
					
					ResizeWatcher.addDependent(this);
					break;
				case CMD.PART_STATE_ALL:
					flist.put(p,false);
					if (this.visible) {
						if(!task)
							task = TaskManager.callLater(requestState,TaskManager.DELAY_10SEC);
						else
							task.repeat();
					}
					break;
				case CMD.K5_PART_PARAMS:
					flist.put(p, false);
					flist.put(bitpackage,false);
					break;
				case CMD.SMS_PART:
					flist.put(p, false);
					
					break;
				case CMD.PART_SET_TEST_LINK:
					pdistribute( p );
					break;
			}
		}
		override public function close():void
		{
			super.close();
			if (task)
				task.kill();
			task = null;
		}
		public function localResize(w:int, h:int, real:Boolean=false):void
		{
			if (h < 352)
				return;
			var maxh:int = DS.alias == DS.K5 || DS.isDevice(DS.K53G) || DS.isfam( DS.K5AA, DS.K5A )?flist.length*30:(flist.length / 2 )*30;
			var hv:int = h - 220;
			if ( hv > maxh ) {
				flist.height = maxh;
				hv = maxh;
			} else
				flist.height = hv;
			
			go.movey("down", hv + 70 );
		}
		private function requestState():void
		{
			RequestAssembler.getInstance().fireEvent( new Request(CMD.PART_STATE_ALL, put ));
		}
		private function cmd(value:Object):int
		{
			if (value is int ) {
				if (int(value) == CMD.K5_PART_PARAMS)
					return SavePerformer.CMD_TRIGGER_TRUE;
			} else {
				
				
				for( var key:String in value.data[value.cmd]) {
					//	нужно заполнять сейвпамять только пожарными и 24 партишенами 
					if ( value.data[value.cmd][key][5] > 0 || value.data[value.cmd][key][6] > 0 ) {
						if (!savedstructs)
							savedstructs = {};
						savedstructs[key] = true;
					}
					if ( value.data[value.cmd][key][6] > 0 ) {
						if (!savedfirestr)
							savedfirestr = {};
						savedfirestr[key] = true;
					}
				}
			}
			return SavePerformer.CMD_TRIGGER_FALSE;
		}
		private function setDelayZero(partstr:int, delay:Array):void
		{
			// если в шлейфе выставлен партишен с fire/24 - обнуляем задержку 
			var a:Array = OPERATOR.dataModel.getData(CMD.K5_AWIRE_PART_CODE)[0];
			for (var i:int=0; i<16; i++) {
				if (a[i] == partstr)
					delay[i] = 0;
			}
		}
		private function after():void
		{
			blockNaviSilent = true;
			loadStart();
			
			if (savedstructs) {
				var key:String;
				
				var a:Array = OPERATOR.dataModel.getData(CMD.K5_AWIRE_DELAY)[0];
				// обнуление задержек шлейфов по запомненным измененным fire или 24
				for( key in savedstructs) {
					setDelayZero( int(key)-1, a );
				}
				savedstructs = null;
				RequestAssembler.getInstance().fireEvent( new Request(CMD.K5_AWIRE_DELAY, null,1 , a, Request.URGENT, Request.PARAM_SAVE));
				
				if (savedfirestr) {
					a = OPERATOR.dataModel.getData(CMD.K5_AWIRE_PART_CODE)[0];
					/** Команда K5_AWIRE_PART_CODE - номера разделов, к которым относятся шлейфы и коды ACID для шлейфов
						Параметры 1-16 - номера разделов (значения с 0 по 15 соответствуют разделам с 1 по 16)
						Параметры 17-32 - коды ACID для шлейфов													*/
					var bfraw:int = OPERATOR.dataModel.getData(CMD.K5_AWIRE_TYPE)[0];
					var bf:int = (bfraw >> 8) | ((bfraw & 0x00FF) << 8 );
					
					var len:int = a.length;
					for (var i:int=0; i<len; i++) {
						if ( isOneOf(a[i]+1) ) {
							a[i+16] = setCIDFireByNum(i+16);
							var pnum:int = getPair(i); 
							var wnum:int = getPair(i+16);
							a[wnum] = setCIDFireByNum(wnum);
							a[pnum] = a[i];
							
							bf = UTIL.changeBit(bf,i,false);
							bf = UTIL.changeBit(bf,pnum,false);
						}
					}
					bfraw = (bf >> 8) | ((bf & 0x00FF) << 8 );
					RequestAssembler.getInstance().fireEvent( new Request(CMD.K5_AWIRE_PART_CODE, null,1 , a, Request.URGENT, Request.PARAM_SAVE));
					RequestAssembler.getInstance().fireEvent( new Request(CMD.K5_AWIRE_TYPE, null,1 , [bfraw], Request.URGENT, Request.PARAM_SAVE));
					
					function isOneOf(partnum:int):Boolean
					{
						for( key in savedfirestr) {
							if (int(key) == partnum)
								return true;
						}
						return false;
					}
					function getPair(pairnum:int):int
					{
						return UTIL.isEven(pairnum) ? pairnum + 1 : pairnum - 1;
					}
					function setCIDFireByNum(structnum:int):int
					{
						return UTIL.isEven(structnum) ? 0x118 : 0x110;
					}
				}
			}
			K5PartitionManager.access().launch();
		}
	}
}
import components.interfaces.IDataAdapter;
import components.interfaces.IFormString;

class SyrLenAdapter implements IDataAdapter
{
	public function adapt(value:Object):Object
	{
		if (value == 0xff)
			return value;
		return int(value)/2;
	}
	public function change(value:Object):Object
	{
		return value;
	}
	public function perform(field:IFormString):void	{			}
	public function recover(value:Object):Object
	{
		if (value == 0xff)
			return value;
		return int(value)*2;
	}
}

class PartTestLinkAdapter implements IDataAdapter
{
	public function adapt(value:Object):Object
	{
		
		return value == 0?1:0;
	}
	public function change(value:Object):Object
	{
		return value;
	}
	public function perform(field:IFormString):void	{			}
	public function recover(value:Object):Object
	{
		return value == 0?1:0;
	}
	
	
}