package components.screens.opt
{
	import components.abstract.RegExpCollection;
	import components.abstract.functions.loc;
	import components.basement.OptionListBlock;
	import components.gui.Balloon;
	import components.gui.PopUp;
	import components.gui.fields.FSCheckBox;
	import components.gui.fields.FSShadow;
	import components.gui.fields.FormString;
	import components.gui.triggers.TextButton;
	import components.interfaces.IFlexListItem;
	import components.interfaces.IFormString;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.protocol.statics.OPERATOR;
	import components.static.CMD;
	import components.static.COLOR;
	import components.system.SavePerformer;
	import components.system.UTIL;
	
	public class OptPartitionK9 extends OptionListBlock implements IFlexListItem
	{
		//private var fsdelay:FsDelay;
		private var checks:Vector.<IFormString>;
		private var dryWire:Boolean=false;
		private var bPart:TextButton;
		private var state:int;
		private var assigned:Boolean;
		
		private const GUARD_TAKE:int = 1;
		private const GUARD_REMOVE:int = 2;
		
		public function OptPartitionK9(s:int)
		{
			super();
			
			structureID = s;
			
			
			/**	Команда K5_PART_PARAMS - параметры разделов
				не работает	Параметр 1 - состояние раздела, 0 - без охраны; 1 - под охраной, 2 - под охраной, была тревога
				не работает	Параметр 2 - Быстрая постановка: 1 - разрешена; 0 - запрещена
				Параметр 3 - Ожидать передачу на пульт: 1 - разрешено; 0 - запрещено
				Параметр 4 - Включать сирену при тревоге: 1 - разрешено; 0 - запрещено
				Параметр 5 - 24-х-часовой раздел: 1 - да; 0 - нет
				Параметр 6 - пожарный раздел: 1 - да; 0 - нет		*/
			
			/**	Команда K9_PART_PARAMS - параметры разделов
				Параметр 1 - состояние раздела, 0 - без охраны; 1 - под охраной, 2 - под охраной, была тревога
				Параметр 2 - Быстрая постановка: 1 - разрешена; 0 - запрещена 
				Параметр 3 - Ожидать передачу на пульт: 1 - разрешено; 0 - запрещено 
				Параметр 4 - Включать сирену при тревоге: 1 - разрешено; 0 - запрещено 
				Параметр 5 - 24-х-часовой раздел: 1 - да; 0 - нет 
				Параметр 6 - пожарный раздел: 1 - да; 0 - нет  
				Параметр 7 - задержка на выход для раздела, значения задержки в секундах "					*/
			
			operatingCMD = CMD.K9_PART_PARAMS;
			
			FLAG_VERTICAL_PLACEMENT = false;
			
			addui( new FormString, 0, String(structureID), null, 1 );
			globalX += 50;
			
			checks = new Vector.<IFormString>;
			
			addui( new FormString, CMD.PART_STATE_ALL, "", null, 1 );
			getLastElement().setAdapter( new StateAdapter(needOverride,isAssigned) );
			globalX += 200;
			
			bPart = new TextButton;
			addChild( bPart );
			bPart.setUp("", onSet );
			bPart.x = globalX;
			globalX += 100;
			
			addui( new FSShadow, operatingCMD, "", null, 1 );
//			getLastElement().setAdapter( new StateAdapter );
			addui( new FSCheckBox, operatingCMD, "", null, 2 );
			attuneElement(0);
			globalX += 100;
			addui( new FSShadow, operatingCMD, "", null, 3 );
			//attuneElement(0);
			//globalX += 100;
			addui( new FSCheckBox, operatingCMD, "", null, 4 );
			attuneElement(0);
			globalX += 100;
			addui( new FSCheckBox, operatingCMD, "", onTrigger, 5 );
			attuneElement(0);
			globalX += 100;
			checks.push( getLastElement() );
			addui( new FSCheckBox, operatingCMD, "", onTrigger, 6 );
			attuneElement(0);
			globalX += 82;
			checks.push( getLastElement() );
			
			addui( new FormString, operatingCMD, "", onTrigger, 7, null , "0-9", 3, new RegExp(RegExpCollection.REF_0to255) );
			attuneElement(50,NaN,FormString.F_EDITABLE | FormString.F_ALIGN_CENTER);
			globalX += 82;
			checks.push( getLastElement() );
			
			addui( new FSShadow, CMD.SMS_PART, "", null, 1 );
			
			addui( new FormString, CMD.SMS_PART, "", null, 2, null, "", 15 );
			attuneElement( 100,NaN,FormString.F_EDITABLE | FormString.F_ALIGN_CENTER);
			
		/*	fsdelay = new FsDelay(structureID);
			addChild( fsdelay );
			fsdelay.x = globalX;
			fsdelay.y = globalY;*/
			
			width = 750;
		}
		
		override public function get height():Number
		{
			return 30;
		}
		
		public function putRaw(value:Object):void	
		{
		}
		public function kill():void		{		}
		public function change(p:Package):void		
		{
			switch(p.cmd) {
				
				case CMD.SMS_PART:
					
					
					
					getField(p.cmd,1).setCellInfo( p.getParam( 1, structureID ) < 0xFF?p.getParam( 1, structureID ):structureID );
					getField(p.cmd, 2).setCellInfo( p.getParam( 2, structureID ) );
					
					break;
				
			}
		}
		public function put(p:Package):void
		{
			switch(p.cmd) {
				case CMD.K9_PART_PARAMS:
					distribute( p.getStructure(structureID),p.cmd);
					getField(p.cmd,3).setCellInfo(0);	// параметр 3 всегда должен быть 0
					
					checkForUnused();
					
					break;
				case CMD.SMS_PART:
									
					getField(p.cmd,1).setCellInfo( structureID );
					getField(p.cmd, 2).setCellInfo( p.getParam( 2, structureID ) );
					//checkForUnused();
					break;
				case CMD.K9_BIT_SWITCHES:
					dryWire = UTIL.isBit(1,p.getStructure()[0]);
					
					getField(operatingCMD,6).disabled = dryWire || !assigned;
					
					checkForUnused();
					onTrigger(null);
					break;
				case CMD.PART_STATE_ALL:
					distribute( p.getStructure(structureID),p.cmd);
					state = p.getStructure(structureID)[0];
					
					if (state == 1)
						bPart.setName( loc("ui_part_takeon") );
					else {
						bPart.setName( loc("ui_part_takeoff") );
						// 165 Нужно дать возможность снятия пожарной тревоги из программы конфигурации
						if (isfire && (state == 3 || state == 8) )
							bPart.disabled = false;
					}
					break;
			}
		}
		public function extract():Array		{	return null	}
		public function set selectLine(b:Boolean):void	{		}
		public function isSelected():Boolean
		{
			return false
		}
		
		private var isfire:Boolean;
		
		private function onTrigger(t:IFormString=null):void
		{
			
			
			// надо убедиться, что не выбраны оба
			if (!assigned)
				return;
			
			if (checks[0].getCellInfo() == 1 && checks[1].getCellInfo() == 1) {
				checks[0].setCellInfo(0);
				checks[1].setCellInfo(0);
				remember(checks[0]);
			}
			checks[0].disabled = checks[1].getCellInfo() == 1 ;
			checks[1].disabled = checks[0].getCellInfo() == 1 || dryWire;
			
			var isutil:Boolean = int(checks[0].getCellInfo())==1 || int(checks[1].getCellInfo())==1;
			isfire = int(checks[1].getCellInfo())==1;
			
			var fsdelay:FormString = getField(operatingCMD,7) as FormString;
			fsdelay.disabled = isutil;
			bPart.disabled = isutil;
			
			if (isutil) {
				var b:Boolean = int(fsdelay.getCellInfo())!=0;
				fsdelay.setCellInfo(0);
				if (b)
					SavePerformer.remember( 1, fsdelay );
			}
			
			if (t) {
				remember(t);
				Balloon.access().show( "sys_attention", "ui_part_note_select24" );
			}
			
			
		}
		private function onSet():void
		{
			var p:PopUp = PopUp.getInstance();
			var code:String = int(OPERATOR.dataModel.getData(CMD.OBJECT)[0]).toString(16);
			
			if (state == 1) {
				p.construct( PopUp.wrapHeader( "sys_attention"), 
					PopUp.wrapMessage( loc("ui_part_accept_remote_takeon")+" "+getBlack(structureID.toString()) +" "+loc("ui_part_accept_remote_object")+" "+getBlack(code) ), 
					PopUp.BUTTON_YES | PopUp.BUTTON_NO, [onDoSet] );
			} else {
				p.construct( PopUp.wrapHeader( "sys_attention" ), 
					PopUp.wrapMessage( loc("ui_part_accept_remote_takeoff")+" "+getBlack(structureID.toString()) +" "+loc("ui_part_accept_remote_object")+" "+getBlack(code)), 
					PopUp.BUTTON_YES | PopUp.BUTTON_NO, [onDoSet] );
			}
			p.open();
			
			function getBlack(s:String):String
			{
				return "<font face='Tahoma' size='14' color='#"+COLOR.RED.toString(16)+"'>" +s+"</font>";
			}
		}
		private function onDoSet():void
		{
			if (state == 1)
				RequestAssembler.getInstance().fireEvent( new Request(CMD.PART_FUNCT, null, 1, [structureID,GUARD_TAKE]));
			else
				RequestAssembler.getInstance().fireEvent( new Request(CMD.PART_FUNCT, null, 1, [structureID,GUARD_REMOVE]));
		}
		private function needOverride():Boolean
		{
			return getField(operatingCMD,5).getCellInfo() == 1;
		}
		private function isAssigned():Boolean
		{
			return assigned;
		}
		private function checkForUnused():void
		{
			var a:Array = OPERATOR.getData(CMD.K9_AWIRE_TYPE);
			assigned = false;
			
			
			var len:int = a.length - 1;
			for (var i:int=len; i > -1; i--) {
				
				if ( int(a[i][1])+1 == structureID  ) {
					if( !dryWire || ( dryWire && i < 3 ) ) assigned = true;
					
					
				}
			}
			
			
			
			bPart.disabled = !assigned;
			getField(operatingCMD,2).disabled = !assigned;
			getField(operatingCMD,4).disabled = !assigned;
			getField(operatingCMD,5).disabled = !assigned;
			getField(operatingCMD,6).disabled = !assigned;
			getField(operatingCMD,7).disabled = !assigned;
			
		}
	}
}
import components.abstract.RegExpCollection;
import components.abstract.functions.loc;
import components.basement.OptionsBlock;
import components.gui.fields.FormString;
import components.interfaces.IDataAdapter;
import components.interfaces.IFormString;
import components.static.CMD;
import components.static.COLOR;

class StateAdapter implements IDataAdapter
{
	private var color:uint;
	private var fNeedOverride:Function;
	private var fIsAssigned:Function;
	
	public function StateAdapter(f:Function, isassigned:Function):void
	{
		fNeedOverride = f;
		fIsAssigned = isassigned;
	}
	public function adapt(value:Object):Object
	{
		/**"Команда PART_STATE_ALL - состояние всех разделов ( 16 структур для К16 и K5, 8 структур для К14 )
		Прибор меняет значения принудительно по запросу и самостоятельно при изменениях в разделах.

		Параметр 1 - текущее состояние раздела. 
		 * Индекс раздела соответствует разделу из PARTITION. состояние раздела 
		 * 0x00 - неизвестное состояние, 
		 * 0x01 - снят с охраны, 
		 * 0x02 - под охраной, 
		 * 0x03 - тревога (охранная и пожарная) в разделе не под охраной (24 часа), 
		 * 0x04 - отсчет задержки, 
		 * 0x05 - нет связи (для сетевых разделов), 
		 * 0x06 - ошибка, нет раздела; 
		 * 0x07 - ошибка команды разделу; 
		 * 0x08 - тревога (охранная и пожарная) под охраной);"													
		 * 0x09 - Проверка сервера;"*/													
		
		color = COLOR.BLACK;
		var mod:int = int(value);
		if (!fIsAssigned()) {
			color = COLOR.SATANIC_INVERT_GREY;
			return loc("ui_part_state_offguard");
		}
		if (fNeedOverride() && mod == 1)	// оверрайдить надо только стейт "снят с охраны" если включается 24часа
			mod = 2;
		
		switch(mod) {
			case 0:
				return loc("ui_part_state_unknwn");
			case 1:
				color = COLOR.YELLOW_SIGNAL;
				return loc("ui_part_state_offguard");
			case 2:
				color = COLOR.GREEN;
				return loc("ui_part_state_onguard");
			case 3:
				color = COLOR.RED;
				return loc("sensor_alarm");
			case 4:
				return loc("ui_part_state_delay");
			case 5:
				return loc("ui_part_state_offline");
			case 6:
				return loc("ui_part_state_error_nopart");
			case 7:
				return loc("ui_part_state_error_cmd");
			case 8:
				color = COLOR.RED;
				return loc("sensor_alarm");	
			case 9:
				color = COLOR.YELLOW_SIGNAL;
				return loc("ui_part_chserver");	
		}
		
		return loc("ui_part_state_unknwn");
		
	}
	public function change(value:Object):Object	{	return null;	}
	public function perform(field:IFormString):void	
	{
		(field as FormString).setTextColor( color );
	}
	public function recover(value:Object):Object
	{
		return int(value);
	}
}
class FsDelay extends OptionsBlock
{
	private var fs:IFormString;
	public function FsDelay(p:int)
	{
		super();
		
		globalX = 0;
		globalY = 0;
		
		fs = addui( new FormString, CMD.K5_PART_DELAY, "", null, p, null, "0-9", 3, new RegExp(RegExpCollection.REF_0to255) );
		attuneElement(50,NaN,FormString.F_EDITABLE | FormString.F_ALIGN_CENTER);
	}
	public function getFastField():IFormString
	{
		return fs;
	}
	public function setCellInfo(n:int):void
	{
		fs.setCellInfo( n );
	}
	public function set disabled(b:Boolean):void
	{
		fs.disabled = b;
	}
	public function reset():Boolean
	{	// true если информация была изменена, false если информация такая же
		var b:Boolean = int(fs.getCellInfo())!=0;
		if (b)
			fs.setCellInfo(0);
		return b;
	}
}