package components.screens.ui
{
	import flash.events.Event;
	import flash.events.FocusEvent;
	
	import components.abstract.ClientArrays;
	import components.abstract.LOC;
	import components.abstract.RegExpCollection;
	import components.abstract.SmsServant;
	import components.abstract.functions.loc;
	import components.abstract.servants.ResizeWatcher;
	import components.abstract.servants.TabOperator;
	import components.basement.UI_BaseComponent;
	import components.events.GUIEventDispatcher;
	import components.events.SystemEvents;
	import components.gui.Header;
	import components.gui.OptList;
	import components.gui.fields.FSCheckBox;
	import components.gui.fields.FSRadioGroup;
	import components.gui.fields.FSShadow;
	import components.gui.fields.FSSimple;
	import components.gui.triggers.TextButton;
	import components.interfaces.IResizeDependant;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.screens.opt.OptSms;
	import components.static.CMD;
	import components.system.SavePerformer;
	
	public class UISms extends UI_BaseComponent implements IResizeDependant
	{
		public static const UPDATE_NAME:int = 0;
		public static const UPDATE_DATA:int = 1;
		public static const TEST:int = 2;
		public static const TRIM_SPACES:int = 3;
		public static const UPDATE_CID:int = 4;
		public static const UPDATE_CID_IMEI:int = 5;
		
		private const SMS_USER:int = 1;
		private const SMS_CONACTID:int = 2;
		private const SMS_CONACTID_IMEI:int = 3;
		
		private var rg:FSRadioGroup;
		private var servant:SmsServant;
		private var but:TextButton;

		private var shield:Shield;
		
		
		public function UISms()
		{
			super();
			yshift = 0;
			var sepWidth:int = 584;
			
			rg = new FSRadioGroup( 
				[ 
					{label:loc("sms_send_to_user"), selected:false, id:SMS_USER },
					{label:loc("sms_send_cid"), selected:false, id:SMS_CONACTID },
					{label:loc("send_IMEI_in_CID"), selected:false, id:SMS_CONACTID_IMEI }
				], 1 );
			rg.y = globalY;
			rg.x = globalX;
			rg.setUp(doGuiLogic);
			rg.width = 496+39;
			addChild( rg )
			
			shield = new Shield( rg.width + 40 );
			this.addChild( shield );
			shield.x = rg.x;
			shield.y = rg.y + 60;
			
			
			//globalY += 165-64-29;
			globalY += rg.height + 10;
			
			drawSeparator(sepWidth);
			globalY -= 10;
			
			FLAG_SAVABLE = false;
			createUIElement( new FSSimple, 0, loc("options_objnum"), function f():void {}, 2, null, "B-Fb-f0-9", 4, new RegExp( RegExpCollection.REF_CODE_OBJECT));
			attuneElement( 487, 60 );
			getLastElement().addEventListener( FocusEvent.FOCUS_OUT, focusOut );
			getLastElement().setCellInfo("0050");
			
			
			
			but = new TextButton;
			addChild( but );
			but.x = globalX + 476;
			but.y = globalY;
			but.setUp(loc("g_apply").toLowerCase(), function f():void { stage.focus = null } );
			
			globalY += 30;
			FLAG_SAVABLE = true;
			
			
			drawSeparator(sepWidth);
			globalY -= 10;
			
			if (LOC.language == LOC.RU) {
				createUIElement( new FSCheckBox, CMD.SMS_SETTING_K2, loc("sms_send_translit"), null, 1 );
				attuneElement( 487+48 );
				createUIElement( new FSShadow, CMD.SMS_SETTING_K2, "", null, 2 );
				
			}
			
			addui( new FSCheckBox, CMD.SMS_DATE_TIME_NOTIF_K2, loc("add_date_time_of_precendent"), null, 1 );
			attuneElement( 487+48 );
			
			globalY += 10;
			drawSeparator(sepWidth);
			globalY -= 10;
			
			FLAG_SAVABLE = false;
			
			createUIElement( new FSCheckBox, 0, loc("sms_default_text"), callLogic, 1 );
			attuneElement( 487+48 );
			FLAG_SAVABLE = true;
			globalY += 10;
			drawSeparator(sepWidth);
			
			var header:Header = new Header( [{label:loc("g_event"),xpos:20, width:200},{label:loc("msgterm_msg"), xpos:317, width:400}],
				{size:12, leading:0} );
			addChild( header );
			header.y = globalY-10;
			globalY += 30;
			
			list = new OptList;
			addChild( list );
			list.y = globalY;
			list.height = 400;
			list.width = 840;
			list.attune( CMD.SMS_TEXT_K2, 0, OptList.PARAM_NO_BLOCK_SAVE );
			
			servant = SmsServant.getInst();
			
			width = 860;
			height = 245;
			
			if (LOC.language == LOC.RU)
				starterCMD = CMD.SMS_SETTING_K2;
				
			
		}
		override public function open():void
		{
			super.open();
			
			servant.load(put);
			
			SavePerformer.trigger( {"before":before, "after":after} ); 
		}
		override public function close():void
		{
			super.close();
			ResizeWatcher.removeDependent(this);
		}
		override public function put(p:Package):void
		{
			switch( p.cmd ) {
				case CMD.SMS_SETTING_K2:
					distribute( p.getStructure(), CMD.SMS_SETTING_K2 );
					break;
				case CMD.SMS_DATE_TIME_NOTIF_K2:
					pdistribute(  p  );
					break;
				case CMD.SMS_TEXT_K2:
					list.put( p, OptSms );
					list.callEach( ClientArrays.sms_text, TRIM_SPACES );
					list.callEach( ClientArrays.sms_text, UPDATE_NAME );
					if( list.callEach( ClientArrays.sms_text, TEST )) {
						list.disabled = true;
						getField(0,1).setCellInfo("1");
					} else {
						list.disabled = false;
						getField(0,1).setCellInfo("0");
					}
					ResizeWatcher.addDependent(this);
					
					callGuiLogic();
					
					loadComplete();
					
					break;
				case CMD.VER_INFO1:
					
					shield.enabled = !SmsServant.IMEI.length;
					
					break;
			}
		}
		private function before():void
		{
			list.callEach( ClientArrays.sms_text, TRIM_SPACES );
			
		}
		private function after():void
		{
			servant.checkNotifyData();
			
			loadStart();
			blockNavi = true;
			RequestAssembler.getInstance().fireEvent( new Request( CMD.PING, pastSaved ) );
			
			
		}
		
		private function pastSaved( p:Package ):void
		{
			blockNavi = false;
			loadComplete();
		}
		private function callLogic():void
		{
			if ( int(rg.getCellInfo()) == SMS_USER) {
				if ( getField(0,1).getCellInfo() == "1" ) { 
					list.callEach( ClientArrays.sms_text, UPDATE_DATA );
					list.disabled = true;
				} else
					list.disabled = false;
				if (TabOperator.getInst().currentFocus() != stage.focus)
					stage.focus = null;	//	чтобы выкинуть курсор с полей под блокирующим экраном
			} else if ( int(rg.getCellInfo()) == SMS_CONACTID  ) {
				list.callEach( ClientArrays.sms_contsctID, UPDATE_CID );
				servant.isCID = true;
			}
			else
			{
				list.callEach( ClientArrays.sms_contsctID, UPDATE_CID_IMEI );
				servant.isCID = true;
			}
		}
		private function focusOut(ev:Event):void	// вызывается при mouseOut из Code Object текстфилда
		{
			var f:FSSimple = getField( 0, 2 ) as FSSimple;
			var source:String = f.getCellInfo().toString();
			var result:String = "0050";
			if ( f.isValid() ) {
				while (source.length < 4) {
					source = "0"+source;
				}
				result = source.toUpperCase();
			}
			f.setCellInfo( result );
			SmsServant.CODE_OBJECT = result;
			if (servant.isCID)
				callLogic();
		}
		private function callGuiLogic():void	// вызывается при старте
		{
			rg.setCellInfo( servant.isCID ? SMS_CONACTID :servant.isUser? SMS_USER:SMS_CONACTID_IMEI );
			if (LOC.language == LOC.RU)
				getField( CMD.SMS_SETTING_K2, 1 ).disabled = !servant.isUser;
			getField( 0, 1 ).disabled = !servant.isUser;
			list.disabled = !servant.isUser;
			
			but.disabled = servant.isUser;
			getField( 0, 2 ).disabled = servant.isUser;
			if (!servant.isUser)
				getField( 0, 2 ).setCellInfo( SmsServant.CODE_OBJECT );
		}
		private function doGuiLogic():void		// срабатывает при нажатии RadioGroup
		{
			servant.isCID = int(rg.getCellInfo()) == SMS_CONACTID;
			servant.isUser = int(rg.getCellInfo()) == SMS_USER;
			
			if (LOC.language == LOC.RU)
				getField( CMD.SMS_SETTING_K2, 1 ).disabled = !servant.isUser;
			getField( 0, 1 ).disabled = !servant.isUser;
			getField( 0, 1 ).setCellInfo( !servant.isUser ? 0 : 1 );
			list.disabled = !servant.isUser;
			
			but.disabled = servant.isUser;
			getField( 0, 2 ).disabled = servant.isUser;
			if (!servant.isUser)
				getField( 0, 2 ).setCellInfo( SmsServant.CODE_OBJECT );
			
			callLogic();
		}
		public function localResize(w:int, h:int, real:Boolean=false):void
		{
			list.height = h - (list.y - 40);
		}
	}
}
import flash.display.Sprite;

class Shield extends Sprite
{
	private const COLOR:uint = 0xFFFFFF;
	private const ALPHA:Number = .6;
	private var _enable:Boolean = true;
	
	public function set enabled( value:Boolean ):void
	{
		if( _enable == value ) return;
		_enable = value;
		
		this.visible = _enable;
	}
	public function Shield( w:int = 400, h:int = 40 )
	{
		init( w, h);
	}
	
	private function init( w:int, h:int ):void
	{
		this.graphics.beginFill( COLOR, ALPHA );
		this.graphics.drawRect( 0, 0, w, h );
	}
}