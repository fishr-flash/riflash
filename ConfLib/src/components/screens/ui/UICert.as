package components.screens.ui
{
	import flash.net.FileReference;
	import flash.text.TextField;
	import flash.utils.ByteArray;
	
	import components.abstract.GroupOperator;
	import components.abstract.functions.loc;
	import components.basement.UI_BaseComponent;
	import components.gui.FileBrowser;
	import components.gui.fields.FSSimple;
	import components.gui.fields.FormString;
	import components.gui.triggers.TextButton;
	import components.interfaces.IResizeDependant;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.static.CMD;
	import components.static.COLOR;
	import components.system.SavePerformer;
	import components.system.UTIL;
	
	public class UICert extends UI_BaseComponent implements IResizeDependant
	{
		private var field:HexField;
		private var bLoad:TextButton;
		private var bSave:TextButton;
		private var go:GroupOperator;
		
		public function UICert()
		{
			super();
			
			/** Команда CERTIFICATE_VERIFICATION - команда получения информации сервером для проверки подлинности с учетом сертификата (1499).

				Параметр 1 - IMEI
				Параметр 2 - CPU_ID
				Параметр 3 - Тип алгоритма шифрования для сертификата 0-сертификат не записан, 1- RSA-1024
				Параметр 4 - Размер сертификата в байтах (1..512)
				Параметр 5 - Количество структур, отведенных под хранение сертификата в приборе ( в текущем варианте 512 ) */
			
			addui( new FSSimple, 0, "IMEI", null, 1 );		//s20
			attuneElement( 80, 200, FSSimple.F_CELL_NOTEDITABLE_EDITBOX );
			(getLastElement().getFocusField() as TextField).backgroundColor = COLOR.WHITE; 
			(getLastElement() as FSSimple).setTextColor( COLOR.GREEN );
			
			addui( new FSSimple, 0, "CPU ID", null, 2 );	//s63
			attuneElement( 80, 520, FSSimple.F_CELL_NOTEDITABLE_EDITBOX );
			(getLastElement().getFocusField() as TextField).backgroundColor = COLOR.WHITE; 
			(getLastElement() as FSSimple).setTextColor( COLOR.GREEN );

			addui( new FormString, 0, loc("cert_title"), null, 3 );	//s63
			
			field = new HexField(this);
			addChild( field );
			field.height = 22;
			field.width = 485;
			field.border = true;
			field.x = globalX;
			field.y = globalY;
			globalY += field.height + 20;
			
			go = new GroupOperator;
			
			bLoad = new TextButton;
			addChild( bLoad );
			bLoad.y = globalY;
			bLoad.x = globalX;
			bLoad.setUp(loc("cert_load_from_file"), onCert, 1);
			globalY += 30;
			
			bSave = new TextButton;
			addChild( bSave );
			bSave.y = globalY;
			bSave.x = globalX;
			bSave.setUp(loc("cert_save_to_file"), onCert, 2);
			
			go.add("1", bLoad );
			go.add("1", bSave );
			
			starterCMD = CMD.CERTIFICATE_VERIFICATION;
		}
		override public function put(p:Package):void
		{
			switch(p.cmd) {
				case CMD.CERTIFICATE_VERIFICATION:
					SavePerformer.trigger({after:after});
					getField(0,1).setCellInfo( p.getParam(1) );
					getField(0,2).setCellInfo( p.getParam(2) );
					//OPERATOR.getSchema(CMD.GET_CERTIFICATE).StructCount = int(p.getParam(4));
					var capacity:int = int(p.getParam(4));
					if (capacity == 0) {
						field.put( "", HexField.CLEAR);
						loadComplete();
					} else
						RequestAssembler.getInstance().fireReadSequence( CMD.GET_CERTIFICATE, put, capacity );
					break;
				case CMD.GET_CERTIFICATE:
					var len:int = p.length;
					var s:String = "";
					for (var i:int=0; i<len; i++) {
						s += UTIL.fz(int(p.getParam(1,i+1)).toString(16),2);
					}
					field.put(s, HexField.DEVICE);
					loadComplete();
					break;
			}
		}
		private function onCert(n:int):void
		{
			if (n == 1)
				FileBrowser.getInstance().open( onGetFile );
			else
				FileBrowser.getInstance().save( field.data, "file_certificate" );
		}
		private function onGetFile(b:ByteArray, fr:FileReference):void
		{
			field.put( b.readMultiByte( b.bytesAvailable, "windows-1251" ), HexField.FILE);
		}
		private function after():void
		{
			var re:RegExp = /[A-Fa-f0-9]{2}/g
			var a:Array = field.data.match(re);
			
			var len:int = a.length;
			for (var i:int=0; i<len; i++) {
				RequestAssembler.getInstance().fireEvent( new Request(CMD.SET_CERTIFICATE,null,i+1, [int("0x"+a[i])]));
			}
			RequestAssembler.getInstance().fireEvent( new Request(CMD.CERTIFICATE_SAVE,null,1, [1,a.length]));
		}
		public function localResize(w:int, h:int, real:Boolean=false):void
		{
			go.movey( "1", field.y + field.height + 15);
			height = field.y + field.height + 90;
		}
	}
}
import flash.events.TextEvent;
import flash.text.TextField;
import flash.text.TextFieldType;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;

import components.abstract.servants.ResizeWatcher;
import components.interfaces.IResizeDependant;
import components.system.SavePerformer;
import components.system.UTIL;

class HexField extends TextField
{
	public var data:String;
	
	public static const BUFFER:int = 0;
	public static const FILE:int = 1;
	public static const DEVICE:int = 2;
	public static const KEYBOARD:int = 3;
	public static const CLEAR:int = 4;
	
	private var tf:TextFormat;
	private var retest:RegExp = new RegExp("^([A-Fa-f0-9]{1,})$");
	
	private var resizer:IResizeDependant;
	
	public function HexField(r:IResizeDependant)
	{
		super();

		resizer = r;
		
		tf = new TextFormat;
		tf.font = "Lucida Console"//PAGE.MAIN_FONT;
		tf.leading = 5;
		tf.size = 16;
		tf.align = TextFormatAlign.JUSTIFY; 
		tf.kerning = true; 
		this.defaultTextFormat = tf;
		
		this.multiline = true;
		this.wordWrap = true;
		this.selectable = false;
		
		this.type = TextFieldType.INPUT;
		
		this.addEventListener(TextEvent.TEXT_INPUT, onInput );
	}
	public function put(s:String, source:int):void
	{
		var len:int = s.length;
		s = s.replace(/[\s\\n]/g, "" );
		
		var b:Boolean = retest.test(s);
		
		if (b && UTIL.isEven(s.length) ) {
			
			data = s;
			var cycle:int = 0;
			var line:int = 0;
			var result:String = "";
			var lines:int=1;
			for (var i:int=0; i<len; i++) {
				
				if (cycle == 2) {
					line++;
					if (line==16) {
						s = s.slice(0,i) + "\n" + s.slice(i);
						line = 0;
						lines++;
					} else
						s = s.slice(0,i) + " " + s.slice(i);
					
					len++;
					
					cycle = 0;
					
				} else
					cycle++;
			}
			this.text = s.toUpperCase();
			
			this.height = lines*21 + 5;
			
			ResizeWatcher.doResizeMe(resizer);
			
			if (source != DEVICE)
				SavePerformer.rememberBlank();
		} else {
			
			switch(source) {
				case CLEAR:
					this.text = "";
					break;
				case BUFFER:
					this.text = "Данные из буфера обмена не являются сертификатом";
					break;
				case KEYBOARD:
					this.text = "Ввод сертификата вручную не поддерживается";
					break;
				case FILE:
					this.text = "Данный файл не является файлом сертификата";
					break;
			}
		}
	}
	private function onInput(e:TextEvent):void
	{
		e.preventDefault();
		if (e.text.length > 1)
			put(e.text, BUFFER);
		else
			put(e.text, KEYBOARD);
		
	}
}