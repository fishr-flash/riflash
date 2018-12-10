package components.screens.ui
{
	import components.abstract.GroupOperator;
	import components.abstract.RegExpCollection;
	import components.abstract.functions.loc;
	import components.abstract.servants.EgtsVehiclesServant;
	import components.basement.UI_BaseComponent;
	import components.gui.PopUp;
	import components.gui.fields.FSCheckBox;
	import components.gui.fields.FSComboBox;
	import components.gui.fields.FSComboBoxExt;
	import components.gui.fields.FSSimple;
	import components.gui.fields.FormString;
	import components.gui.triggers.TextButton;
	import components.interfaces.IFormString;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.protocol.statics.OPERATOR;
	import components.static.CMD;
	import components.static.DS;
	import components.system.SavePerformer;
	import components.system.UTIL;
	
	public class UIEgtsParams extends UI_BaseComponent
	{
		private var paramsOn:Boolean=false;	// включить параметры в составе истории или выключить
		private var bExpand:TextButton;
		private var go:GroupOperator;
		private var headers:Array;
		private var stable:Vector.<OptSTable>;
		private var selectedCypher:int;	// тип шифрования выбранный на данный момоент
		private var fieldCypherKey:FSSimple;	// ключ

		private var subcords:Vector.<OptEgtsTeledata>;
		
		public function UIEgtsParams()
		{
			super();
			
			if(  DS.isDevice( DS.V_ASN ) && DS.release > 57 )
			{
				addui( new FSSimple, CMD.VR_EGTS_IMEI, loc("imei_device"), 
					null, 1, null, "0-9", 20 );
				attuneElement( 200, 260, FSSimple.F_CELL_NOEDITBOX | FSSimple.F_CELL_ALIGN_RIGHT );
				
			}
			
			addui( new FSSimple, CMD.EGTS_UNIT_HOME_DISPATCHER_ID, loc("egts_id"), 
				null, 1, null, "0-9", 5, new RegExp(RegExpCollection.REF_0to65535));
			attuneElement( 400, 60 );
			
			if (DS.release >= 38 ) {
				
				drawSeparator(501);
				
				addui( new FSCheckBox, CMD.EGTS_CNT_STAT_SEND_ENABLE, loc("egts_stat_enable"), null, 1 );
				attuneElement( 400, 60 );
				
				starterCMD = [CMD.PROTOCOL_TYPE, CMD.EGTS_CNT_STAT_SEND_ENABLE, CMD.EGTS_UNIT_HOME_DISPATCHER_ID];
				
				if (DS.release >= 40 || DS.isfam( DS.V15 )) {
					
					if ( ( DS.isNoEGTSVojagers( DS.alias ) && DS.release >= 42 ) || DS.isfam( DS.V15 )) {
						addui( new FSCheckBox, CMD.EGTS_FLAG_ENABLE, loc("egts_send_priority_alarm"), null, 1 );
						attuneElement( 400, 60 );
						starterRefine(CMD.EGTS_FLAG_ENABLE,true);
					}
					
					
					if( DS.isfam( DS.V2, DS.V_ASN ) || DS.isfam( DS.V15 ))
					{
						addui( new FSCheckBox, CMD.VR_EGTS_PRIORITY, loc("egts_priority"), null, 1 );
						attuneElement( 400, 60 );
						starterRefine(CMD.VR_EGTS_PRIORITY,true);
					}
					else if( DS.isDevice( DS.V_ASN ) )
					{
						addui( new FSCheckBox, CMD.VR_EGTS_WORKMODE, loc("use_egts_online"), null, 1 );
						attuneElement( 400, 60 );
						starterRefine(CMD.VR_EGTS_WORKMODE,true);
					}
						
					drawSeparator(501);
					
					if( DS.release >= 46 || DS.isfam( DS.V15 ))
					{
						subcords = new Vector.<OptEgtsTeledata>();
						if( DS.isfam( DS.V2 ) && DS.release > 56 )
						{
							OPERATOR.getSchema( CMD.EGTS_SUBRECORD_TELEDATA_EN ).StructCount = 3;
						}
						const len:int = OPERATOR.getSchema( CMD.EGTS_SUBRECORD_TELEDATA_EN ).StructCount;
						
						for (var j:int=0; j<len; j++) 
						{
							subcords.push( new OptEgtsTeledata( j + 1 ) );
							subcords[ j ].y = globalY;
							subcords[ j ].x = globalX;
							globalY += subcords[ j ].height;
							this.addChild( subcords[ j ] );
							starterRefine(CMD.EGTS_SUBRECORD_TELEDATA_EN,true);
							
						}
						
						
						
						drawSeparator(501);
						
					}
					
					
					if( DS.release > 58 && DS.isfam( DS.F_V, DS.VL0, DS.V4, DS.V6, DS.V_BRPM  ) )
					{
						FLAG_SAVABLE = false;
						addui( new FormString, 0, loc( "data_of_vehicle" ) + ":", null, 1 );
						attuneElement( 460, NaN, FormString.F_TEXT_BOLD );
						FLAG_SAVABLE = true;
						
						addui( new FSSimple, CMD.VR_EGTS_VEHICLE_DATA, loc("vin_id"), null, 1, null, "0-9a-zA-Z", 17 );
						attuneElement( 300, 160 );
						
						
						addui( new FSComboBox, CMD.VR_EGTS_VEHICLE_DATA, loc("category_vehicle"), null, 2, EgtsVehiclesServant.instance.getVehiclesType(), "0-9", 17 );
						attuneElement( 200, 260 );
						
						addui( new FSComboBox, CMD.VR_EGTS_VEHICLE_DATA, loc("power_type_vehicle"), null, 3, EgtsVehiclesServant.instance.getPowersType(), "0-9", 17 );
						attuneElement( 200, 260 );
						
						
						
						
						starterRefine(CMD.VR_EGTS_VEHICLE_DATA,true);
						
						
						drawSeparator(501);
					}
					
					/** R41 - Команда EGTS_CRYPTO_ENABLE - использовать в ЕГТС протоколе шифрование
					 Параметр 1 - Шифрование, 1-включено ГОСТ, 0-выключено, 2-альтернативное"													*/
					var l:Array;
					if ( DS.isfam( DS.V15 ) || ( DS.isfam( DS.F_V ) && ( DS.release >= 42 ) && String(DS.bootloader).slice(0,1) == "2"  ) ) {					
						l = UTIL.getComboBoxList([[0,loc("g_disabled")],[1,loc("egts_gost")],[2,loc("egts_alt")]]);
						addui( new FSComboBox, CMD.EGTS_CRYPTO_ENABLE, loc("egts_cypher"), onCrypto, 1, l );
						attuneElement( 400-80, 140, FSComboBox.F_COMBOBOX_NOTEDITABLE );	
						
						
					} else {
						addui( new FSCheckBox, CMD.EGTS_CRYPTO_ENABLE, loc("egts_cypher"), onCrypto, 1 );
						attuneElement( 400, 60 );
					}
					
					bExpand = new TextButton;
					addChild( bExpand );
					bExpand.setUp("+ "+loc("g_additional"), onClick);
					bExpand.x = globalX;
					bExpand.y = globalY;
					
					globalY += 10;
					
					go = new GroupOperator;
					
					globalY += getLastElement().getHeight();
					
					fieldCypherKey = addui( new FSSimple, CMD.EGTS_CRYPTO_GOST_KEY, loc("egts_cypher_key_256"), null, 1, null, "0-9A-Fa-f",64,new RegExp("^(([0-9A-Fa-f]{64}))$") ) as FSSimple;
					attuneElement( 200, 550 );
					go.add("r40", getLastElement() );
					go.add("r42alt", getLastElement() );
					
					stable = new Vector.<OptSTable>;
					var opt:OptSTable;
					for (var i:int=0; i<9; i++) {
						opt = new OptSTable(i);
						addChild( opt );
						opt.x = globalX;
						opt.y = globalY;
						globalY += opt.complexHeight;
						go.add("r40",opt);
						if (i>0)
							stable.push( opt );
					}
					
					go.activate("");
					
					
					starterRefine(CMD.EGTS_CRYPTO_ENABLE,true);
					starterRefine(CMD.EGTS_CRYPTO_GOST_KEY,true);
					starterRefine(CMD.EGTS_CRYPTO_GOST_S_BOX,true);
				}
			} else
				starterCMD = [CMD.PROTOCOL_TYPE, CMD.EGTS_UNIT_HOME_DISPATCHER_ID];
			
			if(  DS.isDevice( DS.V_ASN ) && DS.release > 57 )
								starterRefine(CMD.VR_EGTS_IMEI,true);
		}
		override public function put(p:Package):void
		{
			var i:int, len:int;
			switch(p.cmd) {
				case CMD.PROTOCOL_TYPE:
					///FIXME: Debug value! Remove it now!
					break;
					if ( p.getStructure()[0] != 1 && p.getStructure()[0] !== 2 ) {
						popup = PopUp.getInstance();
						popup.construct( PopUp.wrapHeader("sys_attention"), PopUp.wrapMessage(loc("egts_must_be_on")));
						popup.open();
					} else {
						SavePerformer.trigger({cmd:refine});
					}
					break;
				case CMD.EGTS_UNIT_HOME_DISPATCHER_ID:
					loadComplete();
				case CMD.EGTS_CNT_STAT_SEND_ENABLE:
				case CMD.EGTS_FLAG_ENABLE:
					pdistribute(p);
					break;
				case CMD.VR_EGTS_IMEI:
					pdistribute(p);
					break;
				case CMD.VR_EGTS_VEHICLE_DATA:
					
					pdistribute(p);
					break;
				case CMD.EGTS_CRYPTO_ENABLE:
					pdistribute(p);
					onCrypto(null);
					break;
				case CMD.EGTS_CRYPTO_GOST_KEY:
					len = p.length;
					var s:String = "";
					for (i=0; i<len; i++) {
						s += UTIL.fz(p.getParamInt(1,i+1).toString(16),2).toUpperCase();
					}
					getField(p.cmd,1).setCellInfo(s);
					SavePerformer.trigger({cmd:refine});
					break;
				case CMD.EGTS_CRYPTO_GOST_S_BOX:
					len = p.length;
					for (i=0; i<len; i++) {
						stable[i].putData(p);
					}
					break;
				case CMD.HISTORY_SELECT_PAR:
					onSetParam(p);
					break;
				
				case CMD.VR_EGTS_PRIORITY:
					pdistribute( p );
					break;
				
				case CMD.VR_EGTS_WORKMODE:
					pdistribute( p );
					break;
				
				case CMD.EGTS_SUBRECORD_TELEDATA_EN:
					
					for each( var item:OptEgtsTeledata in subcords )
						item.putData( p );
					break;
			}
		}
		
		private function refine(value:Object):int
		{
			if(value is int) {
				switch(value) {
					case CMD.EGTS_CNT_STAT_SEND_ENABLE:
					case CMD.EGTS_CRYPTO_GOST_KEY:
						return SavePerformer.CMD_TRIGGER_TRUE;
				}
			} else {
				var cmd:int = value.cmd;
				switch(cmd) {
					case CMD.EGTS_CNT_STAT_SEND_ENABLE:
						paramsOn = Boolean(value.array[0] == 1);
						getField( CMD.EGTS_CNT_STAT_SEND_ENABLE, 1 ).setCellInfo(!paramsOn);
						PopUp.getInstance().construct(PopUp.wrapHeader("sys_attention"),PopUp.wrapMessage("his_delete_when_save"),PopUp.BUTTON_YES | PopUp.BUTTON_NO, [onSetParam] );
						PopUp.getInstance().open();
						return SavePerformer.CMD_TRIGGER_CONTINUE;
					case CMD.EGTS_CRYPTO_GOST_KEY:
						var len:int = 32;
						var s:String = String(getField(cmd,1).getCellInfo());
						
						var hex:Boolean = selectedCypher == 1; 
						var counter:int;
						for (var i:int=0; i<len; i++) {
							if (hex) {
								RequestAssembler.getInstance().fireEvent( new Request( CMD.EGTS_CRYPTO_GOST_KEY, null, i+1, [int("0x"+s.slice(counter,counter+2))] ));
								counter+=2;
							} else {
								if (i == s.length)
									break;
								RequestAssembler.getInstance().fireEvent( new Request( CMD.EGTS_CRYPTO_GOST_KEY, null, i+1, [s.charCodeAt(counter)] ));
								counter++;
							}
						}
						return SavePerformer.CMD_TRIGGER_CONTINUE;
				}
			}
			return SavePerformer.CMD_TRIGGER_FALSE;
		}
		
		private function onStats(t:IFormString):void
		{
			PopUp.getInstance().construct(PopUp.wrapHeader("sys_attention"),PopUp.wrapMessage("his_delete_when_save"),PopUp.BUTTON_YES | PopUp.BUTTON_NO, [onSetParam] );
			remember(t);
		}
		private function onSetParam(p:Package=null):void
		{
			//getField( CMD.EGTS_CNT_STAT_SEND_ENABLE, 1 ).setCellInfo(1);
			if (!p) {
				loadStart();
				RequestAssembler.getInstance().fireEvent( new Request(CMD.HISTORY_SELECT_PAR,put,0,null,0,Request.PARAM_SAVE));
			} else {
				
				/*
				0-7 - 0
				8-15	1
				16-23	2
				24-31	3
				32-39	4
				40-47	5
				48-55	6
				56-63	7
				*/
				// 56 - 57 - 58 - 59 - 60 - 61 - 62 - 63
				
				var bf:int = p.getParamInt(8);
				bf = UTIL.changeBit( bf,4,paramsOn );
				bf = UTIL.changeBit( bf,5,paramsOn );
				bf = UTIL.changeBit( bf,6,paramsOn );
				
				var a:Array = p.data[0].slice();
				a[7] = bf;
				
				RequestAssembler.getInstance().fireEvent( new Request(CMD.HISTORY_SELECT_PAR,null,1,a,0,Request.PARAM_SAVE));
				RequestAssembler.getInstance().fireEvent( new Request(CMD.EGTS_CNT_STAT_SEND_ENABLE,onComplete,1,[paramsOn ? 1:0],0,Request.PARAM_SAVE));
				getField( CMD.EGTS_CNT_STAT_SEND_ENABLE, 1 ).setCellInfo(paramsOn);
			}
		}
		private function onComplete(p:Package):void
		{
			loadComplete();
		}
		private function onCrypto(t:IFormString):void
		{
			selectedCypher = int(getField(CMD.EGTS_CRYPTO_ENABLE,1).getCellInfo());
			switch(selectedCypher) {
				case 0:
					go.activate("");
					cleanCypherFromSave();
					break;
				case 1:
					go.enable("r40");
					break;
				case 2:
					go.enable("r42alt");
					cleanCypherFromSave();
					break;
			}
			
			bExpand.visible = selectedCypher!=0;
			
			onClick(true);
			
			if (t)
				remember(t);
			
		}
		private function cleanCypherFromSave():void
		{
			for (var i:int=0; i<8; i++) {
				SavePerformer.forget(CMD.EGTS_CRYPTO_GOST_S_BOX,1+i);	
			}
		}
		private function onClick(close:Boolean=false):void
		{
			if (stable[0].visible || close) {
				bExpand.setName("+ "+loc("g_additional"));
				go.show("");
				
			} else {
				bExpand.setName("- "+loc("g_additional"));
				if (selectedCypher==1)
					go.show("r40");
				else
					go.show("r42alt");
				
				onTypeCypher();
				
				width = 910;
				height = 490;
			}
		}
		private function onTypeCypher():void
		{
			var cry:Array = OPERATOR.getData(CMD.EGTS_CRYPTO_GOST_KEY);
			var len:int = cry.length;
			var i:int;
			var s:String = "";
			switch(selectedCypher) {
				case 0:
					break;
				case 1:
					fieldCypherKey.rule = new RegExp("^(([0-9A-Fa-f]{64}))$");
					fieldCypherKey.restrict("0-9A-Fa-f",64);
					for (i=0; i<len; i++) {
						s += UTIL.fz(int(cry[i][0]).toString(16),2).toUpperCase();
					}
					break;
				case 2:
					fieldCypherKey.rule = null;
					fieldCypherKey.restrict(null,32);
					for (i=0; i<len; i++) {
						s += String.fromCharCode(cry[i][0]);
					}
					break;
			}
			fieldCypherKey.setCellInfo(s);
		}
	}
}
import components.abstract.adapters.HexAdapter;
import components.abstract.functions.loc;
import components.abstract.servants.UniqueValidator;
import components.basement.OptionsBlock;
import components.gui.fields.FSCheckBox;
import components.gui.fields.FormString;
import components.interfaces.IDataAdapter;
import components.interfaces.IFormString;
import components.protocol.Package;
import components.static.CMD;
import components.static.COLOR;
import components.static.DS;
import components.system.UTIL;

class OptSTable extends OptionsBlock
{
	private var uv:UniqueValidator;
	
	public function OptSTable(str:int)
	{
		super();
		
		uv = new UniqueValidator;
		
		structureID = str;
		operatingCMD = CMD.EGTS_CRYPTO_GOST_S_BOX;
		
		FLAG_VERTICAL_PLACEMENT = false;
		
		if( UTIL.isEven(str) )
			this.graphics.beginFill(COLOR.BLUE_LIGHT,0.1);
		else
			this.graphics.beginFill(COLOR.BLUE_LIGHT,0.3);
		
		complexHeight = 20;
		if (str == 0) {
			addui(new FormString, 0, loc("egts_sblock_num"), null, 1 );
			attuneElement(NaN,NaN,FormString.F_TEXT_BOLD );
			addui(new FormString, 0, loc("g_value"), null, 1 ).x = 120;
			attuneElement(320,NaN,FormString.F_TEXT_BOLD | FormString.F_ALIGN_CENTER );
			
			globalY += 20;
			complexHeight = 40;
			this.graphics.drawRect(0,20,440,20);
		} else
			this.graphics.drawRect(0,0,440,20);
		
		addui(new FormString, 0, str > 0 ? String(structureID):"", null, 1 );
		attuneElement(120,NaN,FormString.F_NOT_EDITABLE_WITH_BORDER);
		globalX = 100;
		
		var len:int = 16;
		for (var i:int=0; i<len; i++) {
			globalX += 20;
			if (str > 0) {
				addui(new FormString, operatingCMD, "", null, 1+i, null, "0-9A-Fa-f",1,new RegExp("^(([0-9A-Fa-f]{1}))$") ).x = globalX;
				attuneElement(20,NaN,FormString.F_EDITABLE | FormString.F_ALIGN_CENTER);
				uv.register(getLastElement());
				getLastElement().setAdapter( new HexAdapter );
			} else {
				addui(new FormString, operatingCMD, i.toString(16), null, 1+i ).x = globalX;
				attuneElement(20,NaN,FormString.F_NOT_EDITABLE_WITH_BORDER | FormString.F_ALIGN_CENTER);
			}
		}
	}
	override public function putData(p:Package):void
	{
		pdistribute(p);
		uv.revalidate();
	}
	public function set disabled(value:Boolean):void
	{
		for (var i:int=0; i<16; i++) {
			getField(operatingCMD,1+i).disabled = value;			
		}
		uv.disabled = value;
		if (!value)
			uv.revalidate();
	}
}


class OptEgtsTeledata extends OptionsBlock
{
	private var subrecords:Array; 
	public function OptEgtsTeledata( struct:int )
	{
		structureID = struct;
		operatingCMD = CMD.EGTS_SUBRECORD_TELEDATA_EN;
		var strSubrec:String;
		var onData:int;
		
		switch( structureID ) {
			case 1:
				onData = 20;
				break;
			case 2:
				onData = 21;
				break;
			case 3:
				onData = 24;
				break;
			default:
				break;
		}
		
		if( DS.isDevice( DS.V_ASN ) )
			subrecords = [ "EGTS_SR_ACCELL_DATA", "EGTS_SR_STATE_DATA",  "EGTS_SR_ABS_AN_SENS_DATA" ];
		else
			subrecords = [ "EGTS_SR_STATE_DATA", "EGTS_SR_ACCELL_DATA", "EGTS_SR_ABS_AN_SENS_DATA" ];
		
		 
		addui( new FSCheckBox(), operatingCMD, loc( "send_subrecord" ) + " " +  subrecords[ structureID - 1 ], null, 1 );
		attuneElement( 400, 60 );
		getLastElement().setAdapter( new AdaptSubrecordTeleData( onData ) );
	
		
	}
	
	override public function putData(p:Package):void
	{
		pdistribute( p );
	}
	
	
}


class AdaptSubrecordTeleData implements IDataAdapter
{

	private var chkBox:FSCheckBox;
	private var onData:int;
	
	public function AdaptSubrecordTeleData( on:int ):void
	{
		onData = on;
	}
	
	public function change(value:Object):Object	// меняет вбитое значение до валидации
	{
		
		return value;
	}
	/**
	 * Вызывается при первой загрузке входных данных 
	 * @param value
	 * @return 
	 * 
	 */		
	public function adapt(value:Object):Object
	{
		
		return value?1:0;
	}
	
	/**
	 * Вызывается при изменении значения эл-та, например
	 * при чеке чекбокса
	 *  
	 * @param value
	 * @return 
	 * 
	 */		
	public function recover(value:Object):Object
	{
		
		
		return value?onData:0;
	}
	/**
	 * Вызывается при первой загрузке входных данных \
	 * @param value
	 * @return 
	 * 
	 */	
	public function perform(field:IFormString):void
	{
		
		chkBox = field as FSCheckBox;
		
	}
}