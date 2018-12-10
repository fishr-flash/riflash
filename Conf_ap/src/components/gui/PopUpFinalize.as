package components.gui
{
	import flash.display.Sprite;
	import flash.net.SharedObject;
	import flash.printing.PrintJob;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import mx.core.UIComponent;
	
	import components.abstract.servants.ResizeWatcher;
	import components.gui.fields.FSSimple;
	import components.gui.triggers.TextButton;
	import components.interfaces.IResizeDependant;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.protocol.statics.SERVER;
	import components.screens.ui.UISms;
	import components.static.CMD;
	import components.static.COLOR;
	import components.static.MISC;
	import components.system.UTIL;

	public final class PopUpFinalize extends UIComponent implements IResizeDependant
	{
		private static var inst:PopUpFinalize;
		public static function access():PopUpFinalize
		{
			if (!inst) inst = new PopUpFinalize;
			return inst;
		}
		
		private var bg:Sprite;
		private var mess:TextField;
		private var title:TextField;
		private var fImei:FSSimple;
		private var fOtk:FSSimple
		private var layer:UIComponent;
		private var bUploadDefaults:TextButton;
		private var bPrint:TextButton;
		private var bClose:TextButton;
		private var so:SharedObject;
		private var loadDef:Boolean;
		
		public function PopUpFinalize()
		{
			super();
			
			bg = new Sprite;
			addChild( bg );
			
			var tf:TextFormat = new TextFormat;
			tf.align = "center";
			tf.size = 12;
			
			layer = new UIComponent;
			addChild( layer );
			layer.graphics.beginFill( COLOR.GREY_POPUP_FILL );
			layer.graphics.drawRoundRect(0,0,400,300,5,5);
			layer.graphics.endFill();
			layer.graphics.lineStyle( 1, COLOR.GREY_POPUP_OUTLINE );
			layer.graphics.drawRoundRect(0,0,400,300,5,5);
			
			var ly:int = 5;
			
			title = new TextField;
			layer.addChild( title );
			title.x = 0;
			title.y = ly;
			ly += 30;
			title.width = 400;
			title.height = 30;
			title.selectable = false;
			title.defaultTextFormat = tf;
			title.htmlText = "<b><font face='Tahoma' size='16' color='#"+COLOR.RED.toString(16)+"'>Подготовка печати</font></b>"
			
			mess = new TextField;
			layer.addChild( mess );
			mess.x = 0;
			mess.y = ly;
			ly += 40
			mess.width = 400;
			mess.height = 30;
			mess.selectable = false;
			mess.wordWrap = true;
			mess.defaultTextFormat = tf;
			mess.htmlText = "<b><font face='Tahoma' size='14' color='#"+COLOR.SATANIC_GREY.toString(16)+"'>" + "Заполните все поля" + "</font></b>";
			
			bUploadDefaults = new TextButton;
			layer.addChild( bUploadDefaults );
			bUploadDefaults.setUp( "Загрузить настройки по умолчанию", onLoadDefaults );
			bUploadDefaults.x = 10;
			bUploadDefaults.y = ly;
			ly += 30;
			
			fImei = new FSSimple;
			layer.addChild( fImei );
			fImei.setName( "IMEI" );
			fImei.setWidth( 150 );
			fImei.setCellWidth( 225 );
			fImei.x = 10;
			fImei.y = ly;
			fImei.restrict("0-9", 15 );
			fImei.setUp( onChange );
			ly += 30;
			
			//fImei.setCellInfo("123456789012345");
			
			fOtk = new FSSimple;
			layer.addChild( fOtk );
			fOtk.setName( "Представитель ОТК" );
			fOtk.setWidth( 150 );
			fOtk.setCellWidth( 225 );
			fOtk.x = 10;
			fOtk.y = ly;
			fOtk.restrict( "А-Яа-я\. " );
			fOtk.setUp( onChange );
			ly += 55;
			
			bPrint = new TextButton;
			layer.addChild( bPrint );
			bPrint.setUp( "Печать", onPrint );
			bPrint.x = 100;
			bPrint.y = ly;
			
			bClose = new TextButton;
			layer.addChild( bClose );
			bClose.setUp( "Закрыть", close );
			bClose.x = 80+152;
			bClose.y = ly;
			
			this.visible = false;
		}
		public function close():void
		{
			this.visible = false;
			ResizeWatcher.removeDependent(this);
		}
		public function open():void
		{
			if (!this.visible) {
				loadDef = false;
				fImei.setCellInfo( "" );
				if (!so)
					so = SharedObject.getLocal( "RITM_"+MISC.COPY_VER + MISC.SAVE_PATH, "/" );
				if ( so.data["otkname"] != null )
					fOtk.setCellInfo(so.data["otkname"]);
				else
					fOtk.setCellInfo("");
				
				onChange();
				ResizeWatcher.addDependent(this);
				this.visible = true;
			}
		}
		public function localResize(w:int, h:int, real:Boolean=false):void
		{
			this.height = h-2 + 60;
			this.width = w + 246;
			
			layer.x = this.width/2 - 105;
			layer.y = h/2-100;

			bg.graphics.clear();
			bg.graphics.beginFill( COLOR.WHITE, 0.8 );
			bg.graphics.drawRect(0,0,this.width,this.height);
			bg.graphics.endFill();
		}
		private function onPrint():void
		{
			var s:Sprite = new Sprite;
			var t:TextField = new TextField;
			var tf:TextFormat = new TextFormat;
			tf.size = 10;
			tf.font = "Tahoma";
			t.defaultTextFormat = tf;
			s.graphics.beginFill( 0xffffff );
			s.graphics.drawRect(0,0,300,300);
			t.width = 500;
			t.x = 50;
			t.y = 330;
			s.addChild( t );
			
			so.data["otkname"] = String(fOtk.getCellInfo());

			var msg:String = "IMEI: "+fImei.getCellInfo() + "\r" +
				"Версия прошивки: " + SERVER.VER_FULL + "\r" +
				"Представитель ОТК: "+ fOtk.getCellInfo() + "\r" +
				"Дата проверки: " + UTIL.getDataString(true);
			t.text = msg;
			
			var p:PrintJob = new PrintJob;
			if (p.start()) {
				try 
					{ p.addPage(s);	} 
				catch(e:Error)
					{  }
			}
			p.send();
		}
		private function onLoadDefaults():void
		{
			fImei.disabled = true;
			fOtk.disabled = true;
			bClose.disabled = true;
			bPrint.disabled = true;
			bUploadDefaults.disabled = true;

			var len:int = UISms.SMS_REQUEST.length;
			for (var i:int=0; i<len; i++) {
				fire(CMD.OP_SM_SMS, UISms.SMS_DEFAULT[i], UISms.SMS_REQUEST[i]);				
			}
//			16.02.2015 16:31:15 -> com: +o=0050
			fire(CMD.OP_o_OBJECT,"0050");
//			16.02.2015 16:31:15 -> com: +FMW=1234
			fire(CMD.OP_FMR_MASTERKEY,["1234"])
//			16.02.2015 16:32:12 -> com: +AN=0
			fire(CMD.OP_AN_AUTOTEST_COUNT,["0"],1 );
//			16.02.2015 16:32:12 -> com: +AH0=00
			fire(CMD.OP_AH_AUTOTEST_HOURS, ["00"],1);
//			16.02.2015 16:32:12 -> com: +AM0=00
			fire(CMD.OP_AM_AUTOTEST_MINUTES, ["00"],1);
//			16.02.2015 16:32:12 -> com: +AH1=00
			fire(CMD.OP_AH_AUTOTEST_HOURS, ["00"],2);
//			16.02.2015 16:32:12 -> com: +AM1=00
			fire(CMD.OP_AM_AUTOTEST_MINUTES, ["00"],2);
//			16.02.2015 16:32:12 -> com: +AH2=00
			fire(CMD.OP_AH_AUTOTEST_HOURS, ["00"],3);
//			16.02.2015 16:32:12 -> com: +AM2=00
			fire(CMD.OP_AM_AUTOTEST_MINUTES, ["00"],3);
//			16.02.2015 16:32:12 -> com: +AA=0C
			fire(CMD.OP_AA_ADDITIONAL_AUTOTEST, ["0C"]);
//			16.02.2015 16:32:12 -> com: +PO=0010
			fire(CMD.OP_PO_POWER, ["0010"]);
//			16.02.2015 16:32:12 -> com: +WI=01
//			16.02.2015 16:32:12 -> com: +r=1
			fire(CMD.OP_r_HISTORY_EVENT_RESTART, ["1"]);
//			16.02.2015 16:38:31 -> com: +GC1=*99#
			fire(CMD.OP_GC_GPRS_NUM, ["*99#"]);
//			16.02.2015 16:38:31 -> com: +GN1=internet.mts.ru
			fire(CMD.OP_GN_GPRS_APN, ["internet.mts.ru"]);
//			16.02.2015 16:38:32 -> com: +GU1=mts
			fire(CMD.OP_GU_GPRS_APN_USER, ["mts"]);
//			16.02.2015 16:38:32 -> com: +GP1=mts
			fire(CMD.OP_GP_GPRS_APN_PASS, ["mts"]);
//			16.02.2015 16:38:32 -> com: +GS1=0.0.0.0
			fire(CMD.OP_GS_SERVER_ADR, ["0.0.0.0"]);
//			16.02.2015 16:38:32 -> com: +GG1=3058
			fire(CMD.OP_GG_SERVER_PORT, ["3058"]);
//			16.02.2015 16:38:32 -> com: +GI1=TestTest
			fire(CMD.OP_GI_SERVER_PASS, ["TestTest"]);
			fire(CMD.OP_GS_SERVER_ADR, ["0.0.0.0"],2);
			fire(CMD.OP_GG_SERVER_PORT, ["3058"],2);
			fire(CMD.OP_GI_SERVER_PASS, ["TestTest"],2);
//			16.02.2015 16:38:32 -> com: +GT=0300
			fire(CMD.OP_GT_GRPS_TRY, ["0300"]);
//			16.02.2015 16:38:32 -> com: +P=1
			fire(CMD.OP_P_GPRS_COMPR, ["1"]);
//			16.02.2015 16:42:05 -> com: +GA=0
			fire(CMD.OP_GA_LINK_CHANNEL_ONLINE, ["0"]);
//			16.02.2015 16:42:05 -> com: +H0=
			fire(CMD.OP_h_CH_TEL, [""], 1);
//			16.02.2015 16:42:05 -> com: +H1=
			fire(CMD.OP_h_CH_TEL, [""], 2);
//			16.02.2015 16:42:05 -> com: +H2=
			fire(CMD.OP_h_CH_TEL, [""], 3);
//			16.02.2015 16:42:05 -> com: +H3=
			fire(CMD.OP_h_CH_TEL, [""], 4);
//			16.02.2015 16:42:05 -> com: +H4=
			fire(CMD.OP_h_CH_TEL, [""], 5);
//			16.02.2015 16:42:05 -> com: +H5=
			fire(CMD.OP_h_CH_TEL, [""], 6);
//			16.02.2015 16:42:05 -> com: +H6=
			fire(CMD.OP_h_CH_TEL, [""], 7);
//			16.02.2015 16:42:05 -> com: +H7=
			fire(CMD.OP_h_CH_TEL, [""], 8);
//			16.02.2015 16:42:05 -> com: +AND0=
			fire(CMD.OP_AND_CH_COM_LINK, [""], 1);
//			16.02.2015 16:42:05 -> com: +AND1=
			fire(CMD.OP_AND_CH_COM_LINK, [""], 2);
//			16.02.2015 16:42:05 -> com: +AND2=
			fire(CMD.OP_AND_CH_COM_LINK, [""], 3);
//			16.02.2015 16:42:05 -> com: +AND3=
			fire(CMD.OP_AND_CH_COM_LINK, [""], 4);
//			16.02.2015 16:42:05 -> com: +AND4=
			fire(CMD.OP_AND_CH_COM_LINK, [""], 5);
//			16.02.2015 16:42:05 -> com: +AND5=
			fire(CMD.OP_AND_CH_COM_LINK, [""], 6);
//			16.02.2015 16:42:05 -> com: +AND6=
			fire(CMD.OP_AND_CH_COM_LINK, [""], 7);
//			16.02.2015 16:42:06 -> com: +AND7=
			fire(CMD.OP_AND_CH_COM_LINK, [""], 8);
//			16.02.2015 16:42:06 -> com: +DO=0
			fire(CMD.OP_DO_CH_DIRECTION_TYPE, ["000"],1);
			fire(CMD.OP_DO_CH_DIRECTION_TYPE, ["100"],2);
			fire(CMD.OP_DO_CH_DIRECTION_TYPE, ["200"],3);
			fire(CMD.OP_DO_CH_DIRECTION_TYPE, ["300"],4);
			fire(CMD.OP_DO_CH_DIRECTION_TYPE, ["400"],5);
			fire(CMD.OP_DO_CH_DIRECTION_TYPE, ["500"],6);
			fire(CMD.OP_DO_CH_DIRECTION_TYPE, ["600"],7);
			fire(CMD.OP_DO_CH_DIRECTION_TYPE, ["700"],8);
//			16.02.2015 16:42:06 -> com: +digt=1E
			fire(CMD.OP_digt_TIME_DIGIT_CALL, ["1E"]);
			fire(CMD.OP_T_WIRE_TYPE, ["1"]);
//			16.02.2015 16:43:40 -> com: +t00=00F
//			16.02.2015 16:43:40 -> com: +t01=0F3
//			16.02.2015 16:43:40 -> com: +t02=182
//			16.02.2015 16:43:40 -> com: +t03=1F6
//			16.02.2015 16:43:40 -> com: +t04=306
//			16.02.2015 16:43:40 -> com: +t10=00F
//			16.02.2015 16:43:40 -> com: +t11=0F3
//			16.02.2015 16:43:40 -> com: +t12=182
//			16.02.2015 16:43:40 -> com: +t13=1F6
//			16.02.2015 16:43:41 -> com: +t14=306
//			16.02.2015 16:43:41 -> com: +t20=00F
//			16.02.2015 16:43:41 -> com: +t21=0F3
//			16.02.2015 16:43:41 -> com: +t22=182
//			16.02.2015 16:43:41 -> com: +t23=1F6
//			16.02.2015 16:43:41 -> com: +t24=306
//			16.02.2015 16:43:41 -> com: +M=08050A08050A08050AFF 16.02.2015 16:43:41 -> com: +T=1
//			16.02.2015 16:47:38 -> com: +f=1380
//			16.02.2015 16:47:38 -> com: +z0=0013000
			fire(CMD.OP_z_ZONES, ["0013000"], 1);
//			16.02.2015 16:47:38 -> com: +z1=0013000
			fire(CMD.OP_z_ZONES, ["0013000"], 2);
//			16.02.2015 16:47:38 -> com: +z2=0013000
			fire(CMD.OP_z_ZONES, ["0013000"], 3);
//			16.02.2015 16:47:38 -> com: +z3=0013000
			fire(CMD.OP_z_ZONES, ["0013000"], 4);
//			16.02.2015 16:47:38 -> com: +z4=0013000
			fire(CMD.OP_z_ZONES, ["0013000"], 5);
//			16.02.2015 16:47:38 -> com: +z5=0113000
			fire(CMD.OP_z_ZONES, ["0113000"], 6);
//			16.02.2015 16:47:38 -> com: +CA=00
			fire(CMD.OP_CA_PARTITION_ALARM_COUNT, ["00"]);
//			16.02.2015 16:47:38 -> com: +p0=111001000
			fire(CMD.OP_p_PARTITION, ["111001000"], 1);
//			16.02.2015 16:47:38 -> com: +p1=010000000
			fire(CMD.OP_p_PARTITION, ["010000000"], 2);
//			16.02.2015 16:47:38 -> com: +p2=010000000
			fire(CMD.OP_p_PARTITION, ["010000000"], 3);
//			16.02.2015 16:47:39 -> com: +p3=010000000
			fire(CMD.OP_p_PARTITION, ["010000000"], 4);
//			16.02.2015 16:47:39 -> com: +p4=010000000
			fire(CMD.OP_p_PARTITION, ["010000000"], 5);
//			16.02.2015 16:47:39 -> com: +p5=010000000
			fire(CMD.OP_p_PARTITION, ["010000000"], 6);
//			16.02.2015 16:47:39 -> com: +k=1
//			16.02.2015 16:53:21 -> com: +k0=1234010
//			16.02.2015 16:51:57 -> com: +C=2
			fire(CMD.OP_C_AKARM_KEY, ["2"]);
//			16.02.2015 16:51:57 -> com: +x=00
//			16.02.2015 16:51:57 -> com: +b=00
//			16.02.2015 16:55:10 -> com: +H=0
//			16.02.2015 16:55:10 -> com: +Ti=01
//			16.02.2015 16:55:10 -> com: +rt=00
//			16.02.2015 16:55:59 -> com: +y=78
//			16.02.2015 16:55:59 -> com: +yc=0
//			16.02.2015 16:56:21 -> com: +E=0
			fire(CMD.OP_E_USE_ENGIN_NUMB, ["0"]);
//			16.02.2015 16:56:21 -> com: +J0=
			fire(CMD.OP_j_ENGIN_NUMB, [""], 1);
//			16.02.2015 16:56:21 -> com: +J1=
			fire(CMD.OP_j_ENGIN_NUMB, [""], 2);
//			16.02.2015 16:56:21 -> com: +J2=
			fire(CMD.OP_j_ENGIN_NUMB, [""], 3);
//			16.02.2015 16:56:21 -> com: +J3=
			fire(CMD.OP_j_ENGIN_NUMB, [""], 4);
//			16.02.2015 16:56:21 -> com: +J4=
			fire(CMD.OP_j_ENGIN_NUMB, [""], 5, onDefaultComplete);

			loadDef = true;
			
			function fire(c:int, d:String, s:int=1, delegate:Function=null ):void 
			{
				RequestAssembler.getInstance().fireEvent( new Request( c, delegate, s, [d]));
			}
		}
		private function onChange():void
		{
			fImei.disabled = !loadDef;
			fOtk.disabled = !loadDef || String(fImei.getCellInfo()).length != 15
			bPrint.disabled = !loadDef || String(fImei.getCellInfo()).length != 15 || String(fOtk.getCellInfo()).length < 5;
			bClose.disabled = false;
			bUploadDefaults.disabled = false;
		}
		private function onDefaultComplete(p:Package):void
		{
			onChange();
		}
	}
}