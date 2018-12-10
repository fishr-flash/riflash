package components.screens.ui
{
	import flash.events.Event;
	
	import mx.controls.TextArea;
	
	import components.abstract.functions.loc;
	import components.abstract.servants.WidgetMaster;
	import components.basement.UI_BaseComponent;
	import components.gui.Header;
	import components.gui.fields.FSComboBox;
	import components.gui.fields.FormEmpty;
	import components.gui.fields.FormString;
	import components.gui.triggers.TextButton;
	import components.interfaces.IFormString;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.protocol.statics.CLIENT;
	import components.screens.opt.OptUnformalizedMessage;
	import components.static.CMD;
	import components.static.MISC;
	import components.static.PAGE;
	import components.system.UTIL;
	
	public class UIMessageTerminal extends UI_BaseComponent
	{
		private var tMsgLog:TextArea;
		private var otps:Vector.<OptUnformalizedMessage>;
		private var bSendOperator:TextButton;
		
		public function UIMessageTerminal()
		{
			super();
			
			FLAG_SAVABLE = false;
			
			createUIElement( new FormString, 0, loc("msgterm_send_to_v"), null, 1 );
			attuneElement( 500, NaN, FormString.F_NOTSELECTABLE );
			
			var header:Header = new Header( [{label:loc("msgterm_string"),xpos:10},{label:loc("msgterm_string_text"), xpos:150},
				{label:loc("msgterm_blink"), xpos:320}, {label:loc("msgterm_sound"), xpos:385}, {label:loc("msgterm_lifetime"), xpos:440, width:200} ],
				{size:11} );
			addChild( header );
			header.y = 45;
			header.x = 20;
			
			otps = new Vector.<OptUnformalizedMessage>(4,true);
			
			var len:int = 3;
			for (var i:int=0; i<len; ++i) {
				otps[i] = new OptUnformalizedMessage(i+1);
				addChild( otps[i] );
				otps[i].y = 70 + i*25;
				otps[i].x = PAGE.CONTENT_LEFT_SHIFT+20;
				otps[i].addEventListener( OptUnformalizedMessage.EVENT_SEND, onSend );
			}
			
			globalY = otps[i-1].y + 30;
			
			var bSendAll:TextButton = new TextButton;
			addChild( bSendAll );
			bSendAll.x = 505+40;
			bSendAll.y = globalY;
			bSendAll.setUp( loc("msgterm_send_all"), onSendAll );
			
			var bClearAll:TextButton = new TextButton;
			addChild( bClearAll );
			bClearAll.x = 625+40;
			bClearAll.y = globalY;
			bClearAll.setUp( loc("msgterm_clear_all"), onClearAll );
			
			globalY += 25; 
			
			drawSeparator(652+130);
			
			createUIElement( new FormString, 0, loc("msgterm_send_msg"), null, 1 );
			attuneElement( 500, NaN, FormString.F_NOTSELECTABLE );
			
			var list:Array = new Array;
			for (var key:String in MESSAGES_OPERATOR_DRIVER) {
				if (key != "label")
					list.push( [int(key), MESSAGES_OPERATOR_DRIVER[key].label ] );
			}
			
			var operatorGList:Array = UTIL.getComboBoxList(list);
			FLAG_SAVABLE = true;	// флаг сохранения включается для того, чтобы была ссылка на вызвавший объект
			createUIElement( new FSComboBox, 1, loc("msgterm_group"), onOperatorGroupSelect, 1, operatorGList );
			attuneElement( 100, 384, FSComboBox.F_COMBOBOX_NOTEDITABLE );
			getLastElement().setCellInfo( 1 );
			FLAG_SAVABLE = false;
			
			bSendOperator = new TextButton;
			addChild( bSendOperator );
			bSendOperator.x = 570;
			bSendOperator.y = getLastElement().y;
			bSendOperator.setUp( loc("g_send"), onSendOperator );
			
			createUIElement( new FSComboBox, 1, loc("msgterm_msg"), null, 2 );
			attuneElement( 100, 384, FSComboBox.F_COMBOBOX_NOTEDITABLE );
			
			createUIElement( new FormString, 1, loc("msgterm_status_wait"), null, 3 ).x = 520;
			attuneElement( 150, NaN, FormString.F_NOTSELECTABLE );
			getLastElement().y = (getField(1,2) as FormEmpty).y;
			
			onOperatorGroupSelect(getField(1,1));
			
			globalY -= 30;
			
			drawSeparator(652+130);
			
			createUIElement( new FormString, 0, loc("msgterm_msg_from_driver"), null, 1 );
			attuneElement( 500, NaN, FormString.F_NOTSELECTABLE );
			
			tMsgLog = new TextArea;
			tMsgLog.tabFocusEnabled = false;
			tMsgLog.tabEnabled = false;
			tMsgLog.x = PAGE.CONTENT_LEFT_SHIFT;
			tMsgLog.y = globalY;
			tMsgLog.selectable = true;
			tMsgLog.editable = false;
			tMsgLog.height = 200;
			tMsgLog.width = 600;
		//	tMsgLog.addEventListener( "htmlTextChanged", onScroll );
		//	tMsgLog.addEventListener(TextEvent.LINK, linkHandler);
			addChild(tMsgLog)
			
			MISC.DEBUG_ANSWER_PROTOCOL2 = 1;
			WidgetMaster.access().registerWidget( CMD.V2D_MESSAGE_DRIVER, new DriverAnswerWidget(getField(1,3),tMsgLog) );
			
			height = 590;
			
		}
		override public function open():void
		{
			super.open();
			loadComplete();
			bSendOperator.disabled = false;
		}
		private function onSend(e:Event):void
		{
			doSend( e.currentTarget as OptUnformalizedMessage );
		}
		private function doSend(opt:OptUnformalizedMessage):void
		{
			RequestAssembler.getInstance().fireEvent( 
				new Request( CMD.V2D_MESSAGE_BASE, null, opt.getStructure(), opt.getMsg(), 0,0,CLIENT.MESSAGE_TERMINAL_ADDRESS ));
		}
		private function onSendAll():void
		{
			doSend(otps[0]);
			doSend(otps[1]);
			doSend(otps[2]);
		}
		private function onClearAll():void
		{
			otps[0].clear();
			otps[1].clear();
			otps[2].clear();
		}
		
		private function onOperatorGroupSelect(t:IFormString):void
		{
			var gnum:int = int(t.getCellInfo());
			
			var list:Array = new Array;
			var select:String;
			for (var key:String in MESSAGES_OPERATOR_DRIVER[gnum] ) {
				if (key != "label") {
					list.push( [int(key), MESSAGES_OPERATOR_DRIVER[gnum][key] ] );
					if (!select)
						select = key;
				}
			}
			(getField(1,2) as FSComboBox).setList( UTIL.getComboBoxList(list) );
			(getField(1,2) as FSComboBox).setCellInfo( select );
			getField(1,3).setCellInfo( loc("msgterm_status_wait") );
		}
		private function onSendOperator():void
		{
			bSendOperator.disabled = true;
			RequestAssembler.getInstance().fireEvent( 
				new Request( CMD.V2D_MESSAGE_DISP, onSendOperatorSuccess, 1, [int(getField(1,1).getCellInfo()),int(getField(1,2).getCellInfo()),0,0,4], 0,0,CLIENT.MESSAGE_TERMINAL_ADDRESS ));
			
		}
		private function onSendOperatorSuccess(p:Package):void
		{
			getField(1,3).setCellInfo( loc("msgterm_status_sent") );
			bSendOperator.disabled = false;
		}
		private var MESSAGES_OPERATOR_DRIVER:Object = {
			1:{
				label:loc("msgterm_op_msg_10"),
				1:loc("msgterm_op_msg_11"),
				2:loc("msgterm_op_msg_12")	
			},
			2:{
				label:loc("msgterm_op_msg_20"),
				11:loc("msgterm_op_msg_21"),
				12:loc("msgterm_op_msg_22"),
				13:loc("msgterm_op_msg_23"),
				14:loc("msgterm_op_msg_24"),
				15:loc("msgterm_op_msg_25"),
				16:loc("msgterm_op_msg_26"),
				17:loc("msgterm_op_msg_27"),
				18:loc("msgterm_op_msg_28"),
				19:loc("msgterm_op_msg_29")				
			},
			3:{
				label:loc("msgterm_op_msg_30"),
				21:loc("msgterm_op_msg_31"),
				22:loc("msgterm_op_msg_32"),
				23:loc("msgterm_op_msg_33"),
				24:loc("msgterm_op_msg_34"),
				25:loc("msgterm_op_msg_35"),
				26:loc("msgterm_op_msg_36"),
				27:""
			}
		}
	}
}
import mx.controls.TextArea;

import components.abstract.functions.loc;
import components.interfaces.IFormString;
import components.interfaces.IWidget;
import components.protocol.Package;
import components.system.UTIL;

class DriverAnswerWidget implements IWidget
{
	private var MESSAGES_DRIVER_OPERATOR:Object = {
		1:{ 
			label:loc("msgterm_d_msg_10"),
			1:loc("msgterm_d_msg_11"),
			2:loc("msgterm_d_msg_12"),
			3:loc("msgterm_d_msg_13"),
			4:loc("msgterm_d_msg_14"),
			5:loc("msgterm_d_msg_15"),
			6:loc("msgterm_d_msg_16"),
			7:loc("msgterm_d_msg_17")
		},
		2:{
			label:loc("msgterm_d_msg_20"),
			8:loc("msgterm_d_msg_21"),
			9:loc("msgterm_d_msg_22"),
			10:loc("msgterm_d_msg_23"),
			11:loc("msgterm_d_msg_24"),
			12:loc("msgterm_d_msg_25")
		},
		3:{
			label:loc("msgterm_d_msg_30"),
			13:loc("msgterm_d_msg_31"),
			14:loc("msgterm_d_msg_32"),
			15:loc("msgterm_d_msg_33"),
			16:loc("msgterm_d_msg_34"),
			17:loc("msgterm_d_msg_35"),
			18:loc("msgterm_d_msg_36"),
			19:loc("msgterm_d_msg_37")
		},
		4:{
			label:loc("msgterm_d_msg_40"),
			20:loc("msgterm_d_msg_41"),
			21:loc("msgterm_d_msg_42"),
			22:loc("msgterm_d_msg_43"),
			23:loc("msgterm_d_msg_44")
		},
		5:{
			label:loc("msgterm_d_msg_50"),
			24:loc("msgterm_d_msg_51"),
			25:loc("msgterm_d_msg_52"),
			26:loc("msgterm_d_msg_53"),
			27:loc("msgterm_d_msg_54"),
			28:loc("msgterm_d_msg_55")
		},
		0:{
			label:loc("msgterm_d_msg_00"),
			29:loc("msgterm_d_msg_01"),
			30:loc("msgterm_d_msg_02"),
			31:loc("msgterm_d_msg_03"),
			32:loc("msgterm_d_msg_04")
		}
	}
	private var msg:IFormString;
	private var log:TextArea;
	private var memory:String = "";
	
	public function DriverAnswerWidget(t:IFormString, tlog:TextArea)
	{
		msg = t;
		log = tlog;
	}
	public function put(p:Package):void
	{
		switch(p.getStructure()[1]) {
			case 29:
				msg.setCellInfo( loc("msgterm_d_msg_state_got") );
				break;
			case 30:
				msg.setCellInfo( loc("msgterm_d_msg_state_read") );
				break;
			default:
				var date:Date = new Date;
				memory = loc("msgterm_msg")+" "+ UTIL.fz(date.day,2) + "-" + UTIL.fz(date.month+1,2) +"-"+ date.fullYear+"," +UTIL.fz(date.hours,2)+":"+UTIL.fz(date.minutes,2)+".\r"+
				loc("msgterm_group")+" " + MESSAGES_DRIVER_OPERATOR[p.getStructure()[0]].label +"\r" +
				MESSAGES_DRIVER_OPERATOR[p.getStructure()[0]][p.getStructure()[1]]+"\r" + memory;
				log.text = memory;
				break;
		}
	}
}