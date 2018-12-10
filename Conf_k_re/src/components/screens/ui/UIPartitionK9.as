package components.screens.ui
{
	import components.abstract.GroupOperator;
	import components.abstract.RegExpCollection;
	import components.abstract.functions.loc;
	import components.abstract.servants.K9PartitionManager;
	import components.abstract.servants.ResizeWatcher;
	import components.abstract.servants.TaskManager;
	import components.basement.UI_BaseComponent;
	import components.gui.Balloon;
	import components.gui.Header;
	import components.gui.MFlexList;
	import components.gui.fields.FSCheckBox;
	import components.gui.fields.FSComboBox;
	import components.gui.fields.FSShadow;
	import components.interfaces.IResizeDependant;
	import components.interfaces.ITask;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.protocol.statics.OPERATOR;
	import components.protocol.statics.SERVER;
	import components.screens.opt.OptPartitionK9;
	import components.static.CMD;
	import components.system.SavePerformer;
	import components.system.UTIL;
	
	public class UIPartitionK9 extends UI_BaseComponent implements IResizeDependant
	{
		private var flist:MFlexList;
		private var go:GroupOperator;
		private var bitpackage:Package;	// чтобы сохранить бит свитчи и вставить их после создания 
		private var savedstructs:Object;
		private var savedfirestr:Object;
		private var task:ITask;
		
		public function UIPartitionK9()
		{
			super();
			
			var header:Header = new Header( [{label:loc("ui_part_k5_num"),xpos:30},
				{label:loc("ui_part_k5_state"),xpos:30+50, align:"left", width:200},
				{label:loc("ui_part_k5_fast_guard"),align:"center",xpos:195+150-37+4, width:150},
				{label:loc("ui_part_k5_siren_when_alarm"), align:"center", xpos:300+150-37, width:150}, 
				{label:loc("ui_part_k5_part24"),align:"center",xpos:395+150-33, width:150},
				{label:loc("ui_part_k5_partfire"),align:"center",xpos:490+150-37+8, width:150},
				{label:loc("ui_part_k5_delay"),align:"center",xpos:600+150-12, width:100},
				{label:loc("name_part"),align:"center",xpos:600+150 + 100 - 5, width:100}], {size:11} );
			
			globalY += 10;
			addChild( header );
			header.y = globalY;
			globalY+=30;
			globalY += 10;
			
			flist = new MFlexList(OptPartitionK9);
			addChild(flist);
			flist.height = 600;
			flist.width = 960;
			flist.y = globalY;
			flist.x = globalX;
			
			globalY = 600;
			
			go = new GroupOperator;
			
			/**K5_PART_EVCOUNT	*/
			
			go.add("down", drawSeparator( flist.width ) );
			
			var w:int = 500;
			var list:Array = UTIL.getComboBoxList( [[10,"10"],[50,"50"],[100,"100"],[0,loc("ui_part_k5_nolimits")]] );
			addui( new FSComboBox, CMD.K5_PART_EVCOUNT, loc("ui_part_k5_event_limit"), null, 1, list, "0-9", 2, new RegExp(RegExpCollection.REF_0_10to254) );
			attuneElement( w, 150 );
			go.add("down", getLastElement() );
			addui( new FSCheckBox(), CMD.PART_SET_TEST_LINK, loc( "part_set_test" ), null, 1 );
			attuneElement( w, 11 );
			go.add("down", getLastElement() );
			
			
			addui( new FSShadow,CMD.K9_BIT_SWITCHES, "", null, 1 );
			addui( new FSShadow,CMD.K9_BIT_SWITCHES, "", null, 2 );
			
			
			
			
			SERVER.TOP_MAX_IND_CMDS = 1;
			SERVER.BOTTOM_MAX_IND_CMDS = 1;
			
			starterCMD = [CMD.K9_BIT_SWITCHES, CMD.K5_PART_EVCOUNT , CMD.PART_SET_TEST_LINK, CMD.K9_PART_PARAMS,CMD.PART_STATE_ALL, CMD.SMS_PART];
			if( !OPERATOR.dataModel.getData(CMD.K9_AWIRE_TYPE) )
				(starterCMD as Array).splice( 0,0, CMD.K9_AWIRE_TYPE );
			if( !OPERATOR.dataModel.getData(CMD.OBJECT) )
				(starterCMD as Array).splice( 0,0, CMD.OBJECT );
		}
		override public function put(p:Package):void
		{
			switch(p.cmd) {
				case CMD.K9_BIT_SWITCHES:
					bitpackage = p;
					refreshCells( p.cmd, true );
				case CMD.K5_PART_EVCOUNT:
					distribute(p.getStructure(),p.cmd);
					break;
				case CMD.PART_STATE_ALL:
					flist.put(p,false);
					if (this.visible) {
						if(!task)
							task = TaskManager.callLater(requestState,TaskManager.DELAY_10SEC);
						else
							task.repeat();
					}
					loadComplete();
				//	SavePerformer.trigger( {cmd:cmd, after:after} )
					ResizeWatcher.addDependent(this);
					break;
				case CMD.PART_SET_TEST_LINK:
					pdistribute( p );
					break;
				case CMD.SMS_PART:
					
					flist.put(p, false);
					
					break;
				case CMD.K9_PART_PARAMS:
					flist.put(p);
					flist.put(bitpackage,false);
					
					loadComplete();
					SavePerformer.trigger( {cmd:cmd, after:after} )
					ResizeWatcher.addDependent(this);
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
			var maxh:int = flist.length*30;
			var hv:int = h - 300;
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
				if (int(value) == CMD.K9_PART_PARAMS)
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
		private function setDelayZero(partstr:int, wiretype:Array):void
		{	// если в шлейфе выставлен партишен с fire/24 - обнуляем задержку
			var len:int = wiretype.length;
			for (var i:int=0; i<len; i++) {
				if (wiretype[i][1] == partstr) {
					wiretype[i][3] = 0;
					savedStructsWireType[i+1] = true;
				}
			}
		}
		private function setFirePairPartition(partstr:int, wiretype:Array):void
		{	// если парный резистивный шлейф имеет разные привязки к партишенам - их надо привести к одному пожарному партишену
			var len:int = wiretype.length;
			for (var i:int=0; i<len; i++) {
				if (wiretype[i][1] == partstr) {
					if ( UTIL.isEven((i+1)) )
					{
						wiretype[i-1][1] = partstr;
						wiretype[i-1][0] = 0;
					}
					else
					{
						wiretype[i+1][1] = partstr;
						wiretype[i+1][0] = 0;
						savedStructsWireType[i+1] = true;
					}
						
				}
				
				/// ставим шлейф установленного раздела в пожар в состояние нормально-разомкнуто принудительно
				wiretype[ i ][ 0 ] = 0;
			}
			
			
		}
		private function setFireCID(partstr:int, wiretype:Array):void
		{	// если в шлейфе выставлен партишен с fire/24 - выставляем CID 0x118 - четным, 0x110 - нечетным;
			var len:int = wiretype.length;
			for (var i:int=0; i<len; i++) {
				if (wiretype[i][1] == partstr) {
					if ( UTIL.isEven((i+1)) )
						wiretype[i][2] = 0x110;
					else
						wiretype[i][2] = 0x118;
					savedStructsWireType[i+1] = true;
				}
			}
		}
		private var savedStructsWireType:Object;	// содержит номера структур для сохранения K9_AWIRE_TYPE
		private function after():void
		{
			savedStructsWireType = {};
			
			blockNaviSilent = true;
			loadStart();
			
			if (savedstructs) {
				var key:String;
				
				/** Команда K9_AWIRE_TYPE -  для записи и чтения параметров шлейфов 
					Параметр 1 - нормальное состояние шлейфов, значения: 0 - шлейф нормально-разомкнутый, 1 - нормально-замкнутый
					Параметр 2 - номер раздела, к которому относится шлейф  (значения с 0 по 5 соответствуют разделам с 1 по 6)
					Параметр 3 - код ACID для шлейфа
					Параметр 4 - задержка на вход для шлейфа, значение задержки в секундах 													
					
					По функционалу аналогична 3-м командам Контакта-5:
					+K5_AWIRE_TYPE,
					+K5_AWIRE_DELAY,
					+K5_AWIRE_PART_CODE 			*/
				
				/*	Команда K5_AWIRE_DELAY - задержки на вход для шлейфов
					Параметры 1-16 - задержки на вход для шлейфов 1-16 соответственно, значения задержек в секундах										*/
				
				var a:Array = OPERATOR.dataModel.getData(CMD.K9_AWIRE_TYPE);
				// обнуление задержек шлейфов по запомненным измененным fire или 24
				for( key in savedstructs) {
					setDelayZero( int(key)-1, a );
					
				}
				savedstructs = null;

				if (savedfirestr) {
					
					for( key in savedfirestr) {
						setFirePairPartition( int(key)-1, a );
						
						
					}
					for( key in savedfirestr) {
						setFireCID( int(key)-1, a );
					}
					savedfirestr = null;		
					
					
				}
				
				
				for( key in savedStructsWireType) {
					RequestAssembler.getInstance().fireEvent( new Request(CMD.K9_AWIRE_TYPE, null, int(key) , a[int(key)-1],  Request.URGENT, Request.PARAM_SAVE));
				}
				
				
			}
			
			K9PartitionManager.access().launch();
			
			Balloon.access().show("sys_attention","k9_restart_to_apply");
			
			
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