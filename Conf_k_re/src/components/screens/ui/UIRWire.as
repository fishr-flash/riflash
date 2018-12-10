package components.screens.ui
{
	import components.abstract.GroupOperator;
	import components.abstract.functions.loc;
	import components.abstract.servants.BitMasterMind;
	import components.abstract.servants.CIDServant;
	import components.abstract.servants.K9PartitionManager;
	import components.abstract.servants.RPartServant;
	import components.abstract.servants.TaskManager;
	import components.basement.UI_BaseComponent;
	import components.gui.Balloon;
	import components.gui.Header;
	import components.gui.MFlexListWire;
	import components.gui.SimpleTextField;
	import components.gui.fields.FSCheckBox;
	import components.gui.fields.FSComboBox;
	import components.gui.fields.FSRadioGroup;
	import components.gui.fields.FSShadow;
	import components.interfaces.ITask;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.protocol.statics.OPERATOR;
	import components.screens.opt.OptRWire;
	import components.screens.opt.OptRWireK5A;
	import components.screens.opt.OptWireK9;
	import components.static.CMD;
	import components.static.DS;
	import components.system.SavePerformer;
	
	// Параметры шлейфов
	
	public class UIRWire extends UI_BaseComponent
	{
		public static var TOTAL_WIRE:int;
		public static var compact:Boolean = false;
		
		private var flist:MFlexListWire;
		private var fsRgroup:FSRadioGroup;
		private var task:ITask;
		private var go:GroupOperator;
		private var maxanchor:int;
		private var bitmm:BitMasterMind;
		private var partsUpdateState:Array =  new Array;
		
		private var h_max:int;
		private var h_min:int;
		private var size_delta:int;
		
		public function UIRWire()
		{
			super();
			
			var swidth:int = 920;
			
			
			bitmm = new BitMasterMind;
			
			
			if (DS.isfam(DS.K9)) {
				TOTAL_WIRE = 6
				h_max = 460;
				h_min = 300;
				size_delta = 90;
				flist = new MFlexListWire(OptWireK9);
				
				addui( new FSShadow, CMD.K9_BIT_SWITCHES, "", null, 1 );
				bitmm.addContainer( getLastElement() );
				addui( new FSShadow, CMD.K9_BIT_SWITCHES, "", null, 2 );
				bitmm.addContainer( getLastElement() );
			}
			else if ( DS.isfam( DS.K5, DS.K5A,  DS.K5GL  ) ) {
				TOTAL_WIRE = 16;
				h_max = 735;
				h_min = 500;
				size_delta = 240;
				flist = new MFlexListWire(OptRWire);
				
				addui( new FSShadow, CMD.K5_BIT_SWITCHES, "", null, 1 );
				bitmm.addContainer( getLastElement() );
				addui( new FSShadow, CMD.K5_BIT_SWITCHES, "", null, 2 );
				bitmm.addContainer( getLastElement() );
				addui( new FSShadow, CMD.K5_BIT_SWITCHES, "", null, 3 );
				bitmm.addContainer( getLastElement() );
			} else {
				
				TOTAL_WIRE = 8;
				h_max = 460;
				h_min = 300;
				size_delta = 110;
				flist = new MFlexListWire(OptRWireK5A);
				
				addui( new FSShadow, CMD.K5_BIT_SWITCHES, "", null, 1 );
				bitmm.addContainer( getLastElement() );
				addui( new FSShadow, CMD.K5_BIT_SWITCHES, "", null, 2 );
				bitmm.addContainer( getLastElement() );
				addui( new FSShadow, CMD.K5_BIT_SWITCHES, "", null, 3 );
				bitmm.addContainer( getLastElement() );
				
			}
			
			addui( new FSComboBox, CMD.K5_FAULT_CODE, loc("k5_wire_failure_code"), null, 1, CIDServant.getEvent(CIDServant.CID_K5WIRE) );
			getLastElement().setAdapter( new HexAdapterCid );
			attuneElement( 345, 350, FSComboBox.F_COMBOBOX_NOTEDITABLE );
			
			
				globalY += 20;
			if( !DS.isDevice( DS.A_BRD ) )
			{
				addui( new FSCheckBox, 0, loc( "send_event_1381" ), null, 1, null );
				attuneElement( 682, NaN );
			}
			if( DS.isfam( DS.K5, DS.A_BRD ) )
				bitmm.addController( getLastElement(), 3, 3 );
			else if( DS.isfam( DS.K9 ) )
				bitmm.addController( getLastElement(), 2, 7 );
			
			
			drawSeparator(swidth);
			globalY += 15;
			
			var header:Header = new Header( [{label:loc("k5_wire_num"),align:"center",xpos:10},
				{label:loc("k5_wire_state"), xpos:90},
				{label:loc("k5_wire_norm_state"),align:"center",width:120, xpos:185},
				{label:loc("k5_wire_ademcoid"), align:"center", width:200,xpos:310}, 
				{label:loc("k5_wire_partnum"), align:"center", xpos:513}, 
				{label:loc("k5_wire_enterdelay"),align:"center", width:100, xpos:600-19},
				{label:loc("k5_wire_exitdelay"),align:"center", width:100, xpos:690-5},
				{label:loc("k5_wire_type"), align:"center", xpos:785}
			], {size:11} );
			addChild( header );
			header.y = globalY;
			
			globalY += 30;
			
			
			addChild(flist);
			flist.height = 500;
			flist.width = 900;
			flist.y = globalY;
			flist.x = globalX;
			
			
			
			
			
			/*if ( DS.isfam( DS.K5,  DS.K5, DS.K53G ) )
				globalY += 275;
			else if (DS.isfam( DS.K5,  DS.isfam( DS.K5AA ), DS.K5GL   ) )*/
			if( DS.isfam( DS.K5, DS.K5A ) )
				globalY += 490;
			else if (DS.isfam(DS.K9))
				globalY += 190;
			else if ( DS.isDevice( DS.K5A ))
				globalY += 250;
			
			go = new GroupOperator;
			
			maxanchor = globalY;
			
			go.add("1",drawSeparator( swidth ));
			
			fsRgroup = new FSRadioGroup( 
				[ 
					{label:loc("k5_wire_res"), selected:false, id:0 },
					{label:loc("k5_wire_dry"), selected:false, id:1 }
				], 1, 30 );
			fsRgroup.y = globalY;
			fsRgroup.x = globalX;
			fsRgroup.width = 220;
			addUIElement( fsRgroup, 0, 1 );
			addChild( fsRgroup );
			//fsRgroup.setUp( onChangeWire );
			go.add("1",fsRgroup);
			globalY += 60;
			if (DS.isfam( DS.K5 ))
				bitmm.addController( fsRgroup, 3, 7, onChangeWire );
			else if (DS.isfam(DS.K9))
				bitmm.addController( fsRgroup, 1, 1, onChangeWireK9 );
			
			if( !DS.isDevice( DS.K5AA ) && !DS.isDevice( DS.A_BRD ) )
			{
				const s:SimpleTextField = new SimpleTextField(loc("k5_wire_dry_note"));
				addChild( s );
				go.add("1",s);
				s.x = globalX;
				s.y = globalY;
			}
			
			
			width = 910;
			height = 735;
			
			//starterCMD = [CMD.K5_PART_PARAMS, CMD.K5_BIT_SWITCHES, CMD.K5_FAULT_CODE, CMD.K5_AWIRE_STATE, CMD.K5_AWIRE_PART_CODE, CMD.K5_AWIRE_DELAY, CMD.K5_PART_DELAY, CMD.K5_AWIRE_TYPE ];
			if ( DS.isfam( DS.K5 )) {
				starterCMD = [CMD.K5_BIT_SWITCHES, CMD.K5_FAULT_CODE, CMD.K5_AWIRE_STATE, CMD.K5_AWIRE_PART_CODE, CMD.K5_PART_DELAY, CMD.K5_AWIRE_DELAY, CMD.K5_AWIRE_TYPE ];
				if( !RPartServant.access().active() )
					(starterCMD as Array).splice( 0,0, CMD.K5_PART_PARAMS );
			} else if (DS.isfam(DS.K9)) {
				starterCMD = [CMD.K9_BIT_SWITCHES, CMD.K9_PART_PARAMS, CMD.K5_FAULT_CODE, CMD.K5_AWIRE_STATE, CMD.K9_AWIRE_TYPE];
			}
			
			
		}
		
			
		
		override public function put(p:Package):void
		{
			if (!this.visible)
				return;
			
			switch(p.cmd) {
				case CMD.K5_PART_PARAMS:
					LOADING = true;
					break;
				case CMD.K9_BIT_SWITCHES:
				case CMD.K5_BIT_SWITCHES:
					
					//SavePerformer.trigger( {cmd:cmd, after:after} );
					if ( DS.isfam( DS.K5 ))
					{
						SavePerformer.trigger( {after:after, click:click} );
						
					}
					else if (DS.isfam(DS.K9))
						SavePerformer.trigger( {after:afterK9, click:click} );
					
					LOADING = true;
					refreshCells(p.cmd);
					/*	refreshCells(CMD.K5_BIT_SWITCHES);
					var bf:int = p.getStructure()[2];
					if ( (bf & 1 << 7) > 0 ) {
					compact = true;
					fsRgroup.setCellInfo(1);
					} else {
					compact = false;
					fsRgroup.setCellInfo(0);
					}*/
					
					
					
					bitmm.put(p);
					//onChangeWire();
				case CMD.K5_FAULT_CODE:
					distribute( p.getStructure(), p.cmd );
					break;
				case CMD.K5_AWIRE_STATE:	//	16 str
					flist.put(p,LOADING);
					if (!task)
						task = TaskManager.callLater(onState,TaskManager.DELAY_3SEC);
					else
						task.repeat();
					break;
				case CMD.K5_PART_DELAY:
					flist.put(p,false);
					break;
				case CMD.K5_AWIRE_TYPE:
				case CMD.K9_AWIRE_TYPE:
					LOADING = false;
					flist.compact( compact );
					loadComplete();
				case CMD.K5_AWIRE_PART_CODE:
				case CMD.K5_AWIRE_DELAY:
					flist.put(p,false);
					break;
				// Для правильного сохранения шлейфов
				case CMD.K5_KBD_KEY_CNT:
					/// || 1 - кастыль, т.к. при значении p.getStructure()[0] == 0, запрос не делается ни разу и конф-р зависает
					RequestAssembler.getInstance().fireReadSequence( CMD.K5_KBD_KEY,put,p.getStructure()[0] || 1 );
				case CMD.K5_KBD_KEY:
					after();
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
		private function minimize(b:Boolean):void
		{
			go.movey("1", b ? maxanchor - size_delta : maxanchor );
			height = b ? h_min:h_max;
		}
		private function onState():void
		{
			RequestAssembler.getInstance().fireEvent(new Request(CMD.K5_AWIRE_STATE,put));
		}
		private function onChangeWire(o:Object = null):void
		{
			var b:Boolean = int(fsRgroup.getCellInfo()) == 1;
			compact = b;
			minimize(b);
			flist.compact( b );
			
			if (!LOADING && b) {
				

				var a:Array = OPERATOR.dataModel.getData( CMD.K5_PART_PARAMS );
				var len:int = a.length;
				for (var i:int=0; i<len; i++) {
					
					a[i][5] = 0;
					
					RequestAssembler.getInstance().fireEvent( new Request( CMD.K5_PART_PARAMS, null, i+1, a[i] ));
					
				}
				Balloon.access().show( "sys_attention","k5_wire_cant_use_fire");
			}
		}
		
		private function onChangeWireK9(o:Object = null):void
		{
			var b:Boolean = int(fsRgroup.getCellInfo()) == 1;
			compact = b;
			minimize(b);
			flist.compact( b );
			
			if (!LOADING && b) {
				Balloon.access().show( "sys_attention","k5_wire_cant_use_fire");
			}
			
		}
		
		private function click():void
		{
			blockNaviSilent = true;
			loadStart();
		}
		private var totalsent:int;	// если найдены структуры K5_KBD_KEY_CNT которые надо поменять, надо знать их количество

		
		private function after():void
		{
		
			if( DS.isfam( DS.K5 ) )
			{
				totalsent = 1;
				onSuccess( null );
				return;
			}
			
			var wire:Array = OPERATOR.dataModel.getData(CMD.K5_AWIRE_PART_CODE)[0];
			var up:Array = OPERATOR.dataModel.getData(CMD.K5_KBD_KEY);
			// если юзеры еще на запрашивались, надо их запросить
			
			
			if (!up) {
				RequestAssembler.getInstance().fireEvent( new Request(CMD.K5_KBD_KEY_CNT, put));
				return;
			}
			// создание маски, по которой будут отфильтровываться лишние разделы
			var pmask:int;
			const lent:int = DS.isfam( DS.K5 )?16:8;
			for (i=0; i<lent; i++) {
				pmask |= 1 << wire[i] 
			}
			var len:int = up.length;
			var bf:int;
			for (var i:int=0; i<len; i++) {
				bf = pmask & up[i][1];
				if (bf != up[i][1]) {
					RequestAssembler.getInstance().fireEvent( new Request(CMD.K5_KBD_KEY, onSuccess, i+1, [up[i][0],bf,up[i][2]], Request.NORMAL,Request.PARAM_SAVE ));
					totalsent++;
					
					
				}
			}
			if (totalsent == 0) {
				blockNaviSilent = false;
				loadComplete();
			}
			
			RequestAssembler.getInstance().fireEvent( new Request(CMD.K5_KBD_KEY_CNT, null, 1,[ totalsent ], Request.NORMAL,Request.PARAM_SAVE ));
			
			
			
		}
		
		/** Работа с отключенными партишенами К9	*/
		private function afterK9():void
		{
			K9PartitionManager.access().launch();
			loadComplete();
			
			
		}
		
		private function onSuccess(p:Package):void
		{
			totalsent--;
			if (totalsent == 0) {
				loadComplete();
				blockNaviSilent = false;
			}
		}
		
		private function selectPartsOfLeft():void
		{
			var b:Boolean = int(fsRgroup.getCellInfo()) == 1;
			var wire:Array = OPERATOR.dataModel.getData( CMD.K9_AWIRE_TYPE );
			partsUpdateState = new Array;
			
			var len:int = b?wire.length /2:wire.length;
			const partis:Array = new Array;
			// перебираем шлейфы и смотрим какие разделы в них указаны
			for (var i:int=0; i<len; i++) 
				partis[ wire[ i ][ 1 ] ] = 1;
			
			len = wire.length;	
			for (var j:int=0; j<len; j++) 
				if( !partis[ j ] ) partsUpdateState.push( j );
		}
	}
}
import flash.display.Sprite;

import components.abstract.adapters.HexAdapter;

class HexAdapterCid extends HexAdapter
{
	override public function adapt(value:Object):Object
	{
		/*var r1:String = int(value).toString(16).toUpperCase();
		var r:int =  int("0x"+(int(value)& 0x0FFF));*/
		if (int(value) > 0)
			return (super.adapt(value) as String).slice(1);
		return 0;
	}
	override public function recover(value:Object):Object
	{
		var r:int = int(super.recover(value)) | (1 << 12); 
		return r;
	}
}

class Shield extends Sprite
{
	public function Shield()
	{
		drawSquare();
		this.x = 10;
		this.y = 348;
	}
	
	private function drawSquare():void
	{
		
		this.graphics.beginFill( 0xFFFFFF, 1 );
		this.graphics.drawRect( 0, 0, 890, 250 );
		
	}
}