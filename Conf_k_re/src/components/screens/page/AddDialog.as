package components.screens.page
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.events.FlexEvent;
	
	import components.abstract.functions.loc;
	import components.abstract.servants.ResizeWatcher;
	import components.abstract.sysservants.PartitionServant;
	import components.basement.UI_BaseComponent;
	import components.gui.SimpleTextField;
	import components.gui.fields.FSCheckBox;
	import components.gui.fields.FSCheckBoxSimple;
	import components.gui.fields.FSSimple;
	import components.gui.fields.FormEmpty;
	import components.gui.triggers.TextButton;
	import components.interfaces.IResizeDependant;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.protocol.statics.OPERATOR;
	import components.static.CMD;
	import components.static.COLOR;
	import components.static.DS;
	import components.system.UTIL;

	public class AddDialog extends UI_BaseComponent implements IResizeDependant
	{
		private var title:SimpleTextField;
		private var fkey:FSSimple;
		private var fforce:FSCheckBox;
		private var bRead:TextButton;
		private var bOk:TextButton;
		private var bCancel:TextButton;
		private var xvalue:int = 30;
		private var yvalue:int = 10;
		private var bg:Sprite;
		private var window:Sprite;
		private var checks:Vector.<FSCheckBoxSimple>;
		private var checkstitle:Vector.<SimpleTextField>;
		private var totalpartition:int;
		
		private const READ:int = 1;
		private const CHECK_ALL:int = 2;
		private const OK:int = 3;
		private const CANCEL:int = 4;
		
		private var isEdit:Boolean;
		private var struct:int;
		private var fskey:FSKey;

		private var warnWin:WarningWindow;
		
		public function AddDialog()
		{
			super();
			
			bg = new Sprite;
			addChild( bg );
			addEventListener( MouseEvent.CLICK, onClose );
			
			window = new Sprite;
			addChild( window );
			window.graphics.beginFill( COLOR.GREY_POPUP_FILL );
			window.graphics.drawRoundRect(xvalue,yvalue,400,190,5,5);
			window.graphics.endFill();
			window.graphics.lineStyle(1, COLOR.GREY_POPUP_OUTLINE );
			window.graphics.drawRoundRect(xvalue,yvalue,400,190,5,5);
			window.graphics.endFill();
			
			globalX = 40;
			globalY += 10;
			
			title = new SimpleTextField("");
			place( title );
			title.setSimpleFormat("left",0,14);
			title.width = 200;
			title.height = 200;
			globalY += 30;
			
			FLAG_SAVABLE = false;
			fskey = addui( new FSKey, 2, loc("ui_tmkey"), null, 1, null, "0-9A-Fa-f",17 ) as FSKey;
			attuneElement( 60, 180 );
			(getLastElement() as FormEmpty).addEventListener( FlexEvent.CHANGE_END, onValidationComplete );
			
			bRead = new TextButton;
			place( bRead );
			bRead.setUp(loc("tmkey_k5_read"), onClick, READ );
			bRead.x = globalX + 271;
			bRead.y = globalY - 33;
			
			var ax:int = globalX;
			checks = new Vector.<FSCheckBoxSimple>;
			checkstitle = new Vector.<SimpleTextField>;
			
			var len:int;
			 
			if ( DS.isfam( DS.K5, DS.K5A, DS.K5GL  )) 
			{
				len = 17;
				totalpartition = 16;
				
			}
			else if( DS.isfam( DS.K5, DS.K5, DS.K53G )  )
			{
				len = 9;
				totalpartition = 8;
			}
			else if (DS.isfam(DS.K9)) 
			{
				len = 7;
				totalpartition = 6;
			}
			
			
			for (var i:int=0; i<len; i++) {
				if (i==totalpartition) {
					globalX += 5;
					checkstitle.push(new SimpleTextField(loc("g_all"), 30));
					place(checkstitle[i]);
					globalX += 5;
				} else {
					checkstitle.push(new SimpleTextField((i+1).toString(), 20));
					place(checkstitle[i]);
				}
				
				checkstitle[i].height = 20;
				checkstitle[i].x -= 4;
				checkstitle[i].setSimpleFormat("center");
				
				checks.push(new FSCheckBoxSimple);
				place( checks[i] );
				checks[i].y = globalY + 15;
				if (i==len-1) {
					checks[i].setUp( onClick, CHECK_ALL );
				} else {
					checks[i].setUp( onCheck, i );
				}
				globalX += 22;			
			}
			globalX = ax;
			globalY += 45;
			
			FLAG_VERTICAL_PLACEMENT = false;
			addui( new FSCheckBox, 2, loc("ui_tmkey_takeoff_force"), null, 2 );
			attuneElement( 200 );
			
			globalX += 312;
			addui( new FSCheckBox, 2, loc("ui_tmkey_gbr"), null, 3 )
			attuneElement( 50 );
			globalX -= 312;
			
			globalY += 40;
			globalX += 70;
			
			bOk = new TextButton;
			addChild( bOk );
			bOk.setUp(loc("g_apply"), onClick, OK);
			bOk.x = globalX;
			bOk.y = globalY;
			
			bCancel = new TextButton;
			addChild( bCancel );
			bCancel.setUp(loc("g_do_cancel"), onClick, CANCEL);
			bCancel.x = globalX + 155;
			bCancel.y = globalY;
			
			
			FLAG_SAVABLE = false;
			
			warnWin = new WarningWindow();
			this.addChild( warnWin );
			
			
		}
		
		override public function open():void
		{
			super.open();
			ResizeWatcher.addDependent(this);
			
			recalculateChecks();
		}
		override public function close():void
		{
			super.close();
			ResizeWatcher.removeDependent(this);
		}
		override public function put(p:Package):void
		{
			var a:Array = p.getStructure();
			var s:String = "";
			for (var i:int=0; i<8; i++) {
				s += UTIL.fz(int(a[i]).toString(16),2).toUpperCase(); 
			}
			
			fskey.setCellInfo( s );
			onValidationComplete(null);
			
			loadComplete();
		}
		public function show(msg:String, a:Array=null, str:int=0):void
		{
			title.text = msg;
			isEdit = a is Array;
			struct = str;
			fskey.curstr = str;
			var i:int;
			if (a) {
				fskey.setCellInfo(a[0]);
				getField(2,2).setCellInfo(a[2]);
				
				var bf:int = a[1];
				var b:Boolean = checks[totalpartition].getCellInfo();
				for (i=0; i<totalpartition; i++) {
					checks[i].setCellInfo( UTIL.isBit( i, a[1] ));
				}
				var gbr:int = (a[3] & 1) == 0 ? 1:0;
				getField(2,3).setCellInfo( gbr );
			} else {
				fskey.setCellInfo("0000000000000000");
				fskey.curstr = -1;
				onValidationComplete(null);
				getField(2,2).setCellInfo(0);
				getField(2,3).setCellInfo( 0 );
				for (i=0; i<totalpartition; i++) {
					if( !checks[i].disabled )
						checks[i].setCellInfo(0);
				}
			}
			this.open();
		}
		private function onClick(n:int):void
		{
			var i:int, len:int;
			switch(n) {
				case READ:
					RequestAssembler.getInstance().fireEvent( new Request(CMD.K5_TM_CUR_KEY, put));
					loadStart();
					break;
				case CHECK_ALL:
					var b:Boolean = checks[totalpartition].getCellInfo();
					for (i=0; i<totalpartition; i++) {
						if( !checks[i].disabled ) {
							checks[i].setCellInfo( b );
							recalculateChecks();
						}
					}
					break;
				case OK:
					var kcount:int = OPERATOR.dataModel.getData(CMD.K5_TM_KEY_CNT)[0][0];
					if (kcount < 0xff) {
						var a:Array = fskey.getCellInfo() as Array;
						
						var bf:int;
						var bf0:int;
						var bf8:int;
						for (i=0; i<totalpartition; i++) {
							
							if( int(checks[i].getCellInfo()) == 1) {
								if (i < 8)
									bf0 = UTIL.changeBit( bf0, i, true );
								else
									bf8 = UTIL.changeBit( bf8, i-8, true );
							}
						}
						bf = bf0 | (bf8 << 8);
						a.push( bf );
						var force:int = int(getField(2,2).getCellInfo());
						a.push( force );
						
						//int(getField(2,3).getCellInfo())
						
						var gbr:int = UTIL.changeBit( 0, 0, int(getField(2,3).getCellInfo()) == 0 );
						
						a.push( gbr );
						
						if( isEdit ) {
							RequestAssembler.getInstance().fireEvent( new Request( CMD.K5_TM_KEY, null, struct, a ));
						} else {
							RequestAssembler.getInstance().fireEvent( new Request( CMD.K5_TM_KEY_CNT, null, 1, [++kcount] ));
							RequestAssembler.getInstance().fireEvent( new Request( CMD.K5_TM_KEY, null, kcount, a ));
						}
						this.dispatchEvent( new Event(Event.COMPLETE));
						this.close();
					}
					break;
				case CANCEL:
					this.close();
					break;
			}
		}
		private function onCheck(n:int):void
		{
			recalculateChecks();
		}
		private function recalculateChecks():void
		{
			var a:Array
			if ( DS.isfam( DS.K5, DS.K5A, DS.K5AA, DS.A_BRD, DS.K5GL  )) 
			{
				a = OPERATOR.dataModel.getData(CMD.K5_PART_PARAMS);
				
			}
			else if( DS.isfam( DS.K5,  DS.K5, DS.K53G )  )
			{
				a = OPERATOR.dataModel.getData(CMD.K5_PART_PARAMS);
				a.splice( 8, a.length - 8 );
			}
			else if (DS.isfam(DS.K9))
				a = OPERATOR.dataModel.getData(CMD.K9_PART_PARAMS);
			
			var atleast1selected:Boolean = false;
			
			var selectedgroup:int=-1;
			var len:int = a.length
			for (var i:int=0; i<len; i++) {
				
				if( !atleast1selected && int(checks[i].getCellInfo() == 1) )
					atleast1selected = true;
				
				checks[i].disabled = a[i][4] == 1 || !PartitionServant.isPartitionAssigned(i+1);
				checks[i].storedData = getGroup(a[i]);
				
				if( selectedgroup < 0 && int(checks[i].getCellInfo()) > 0 )
					selectedgroup = checks[i].storedData; 
				
				if (a[i][4] == 1)
					checkstitle[i].textColor = COLOR.BLUE;
				if (a[i][5] == 1)
				checkstitle[i].textColor = COLOR.RED;
			}
			
			if (selectedgroup > -1) {
				for (i=0; i<len; i++) {
					checks[i].disabled = selectedgroup != checks[i].storedData || !PartitionServant.isPartitionAssigned(i+1);
					if (a[i][4] == 0 && a[i][5] == 0)
						checkstitle[i].textColor = checks[i].disabled ? COLOR.SATANIC_INVERT_GREY : COLOR.BLACK;
				//	checkstitle[i].textColor = checks[i].disabled ? COLOR.SATANIC_INVERT_GREY : COLOR.BLACK;
				}
			}
			
			bOk.disabled = !fskey.isValid() || !atleast1selected;
			
			function getGroup(arr:Array):int
			{
				if( arr[4] == 1 )	//	24
					return 1;
				if( arr[5] == 1 )	// fire
					return 2;
				return 0;
			}
		}
		private function isAtleast1Selected():Boolean
		{
			if(checks) {
				var len:int = checks.length;
				for (var i:int=0; i<len; i++) {
					if( int(checks[i].getCellInfo() == 1) )
						return true;
				}
			}
			return false;
		}
		private function onValidationComplete(e:Event):void
		{
			const valid:Boolean = fskey.isValid(); 
			bOk.disabled = !valid || !isAtleast1Selected();
			
			if( !valid )
			{
				const mess:String = "   "  + loc( "sys_error" )+ "! " + loc( "warn_no_input_double_tm" );
				warnWin.show( loc( "sys_attention" ), mess );
			}
			
			
		}
		private function onClose(e:Event):void
		{
			if (e.target == bg)
				this.close();
		}
		private function place(d:DisplayObject):void
		{
			addChild( d );
			d.x = globalX;
			d.y = globalY;
		}
		public function localResize(w:int, h:int, real:Boolean=false):void
		{
			bg.graphics.clear();
			bg.graphics.beginFill( COLOR.WHITE, 0.7 );
			bg.graphics.drawRect(0,0,w,h);
			bg.graphics.endFill();
		}
	}
}
import flash.events.Event;

import mx.events.FlexEvent;

import components.gui.fields.FSSimple;
import components.protocol.statics.OPERATOR;
import components.static.CMD;

class FSKey extends FSSimple
{
	public var curstr:int;	// структура выбранного ключа
	
	override protected function change(ev:Event):void
	{
		var s:String = _cell.text;
		s.replace(/[^0-9.]/g, "");
		while (s.length < 16)
			s += "0";
		
		cellInfo = s.slice(0,16).toUpperCase();
		_cell.text = cellInfo;
		
		isValid();
		this.dispatchEvent( new Event(FlexEvent.CHANGE_END));
	}
	override public function getCellInfo():Object
	{
		var a:Array = [];
		var len:int = cellInfo.length;
		for (var i:int=0; i<len; i+=2) {
			a.push( int("0x"+cellInfo.slice(i, i+2)) ); 
		}
		return a;
	}
	override protected function validate( str:String, ignorSave:Boolean=false ):Boolean
	{
		/*if (forceValid>0)
			return forceValid == 1;
		if ( rule && !_disabled )
			valid = Boolean( str.search( rule ) == 0 );
		else
			valid = true;
		
		// Если одтеьлное поле верно и есть валидирующий бот - надо протестить общую валидацию
		if (valid && vbot && !_disabled )
			valid = vbot.isValid(this);
		// Если обнаруживается неверное поле оно сразу отправляет себя что сохранялка знала что есть неверное поле
		if (!valid && AUTOMATED_SAVE && !ignorSave)
			fSend( this );
		
		return valid;*/
		
		/// На К9 дубликаты ключей выявляются в приборе, на К5 такого нет, контролируем в здесь
		
		/*if( DEVICES.alias == DEVICES.K5 || DEVICES.alias == DEVICES.K53G || DEVICES.alias == DEVICES.K5GL ||DEVICES.alias == DEVICES.K5A)
		{*/
			var a:Array = OPERATOR.dataModel.getData(CMD.K5_TM_KEY) || [];
			///FIXME: Debug value! Remove it now! Вообще как то неправильно брать общее возможное кол-во ключей, тогда как есть кол-во реальных
			//var len:int = OPERATOR.dataModel.getData(CMD.K5_TM_KEY_CNT)[0][0];
			var len:int = a.length;
			valid = true;
			for (var i:int=0; i<len; i++) {
				
				if ( curstr == i+1 )
					continue;
				if (uint( "0x" + cellInfo.slice(0,2)) == a[i][0] &&
					uint("0x" + cellInfo.slice(2,4)) == a[i][1] &&
					uint("0x" + cellInfo.slice(4,6)) == a[i][2] &&
					uint("0x" + cellInfo.slice(6,8)) == a[i][3] &&
					uint("0x" + cellInfo.slice(8,10)) == a[i][4] &&
					uint("0x" + cellInfo.slice(10,12)) == a[i][5] &&
					uint("0x" + cellInfo.slice(12,14)) == a[i][6] &&
					uint("0x" + cellInfo.slice(14,16)) == a[i][7] ) {
					
					
					valid = false;
					return valid;
				}
			}
		//}
	
		
		
		return super.validate( str, ignorSave );
	}
}