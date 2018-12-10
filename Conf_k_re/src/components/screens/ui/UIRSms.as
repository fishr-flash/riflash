package components.screens.ui
{
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	
	import components.abstract.GroupOperator;
	import components.abstract.LOC;
	import components.abstract.functions.loc;
	import components.abstract.servants.ResizeWatcher;
	import components.basement.UI_BaseComponent;
	import components.gui.MFlexList;
	import components.gui.triggers.TextButton;
	import components.interfaces.IResizeDependant;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.protocol.statics.OPERATOR;
	import components.resources.Resources;
	import components.screens.opt.OptRSms;
	import components.static.CMD;
	import components.static.DS;
	import components.static.MISC;
	import components.static.PAGE;
	
	public class UIRSms extends UI_BaseComponent implements IResizeDependant
	{
		public static const EVENT_LAT:String = "EVENT_LAT";
		public static const EVENT_CYR:String = "EVENT_CYR";
		public static var SMS_TEXT:Array;
		public static var SMS_DEFAULT:Array;
		
		private const F_APPLY:int=1;
		private const F_LAT:int=2;
		private const F_CYR:int=3;
		
		private var flist:MFlexList;
		private var totalrequest:int;
		private var totalgot:int;
		private var bLoadDefaults:TextButton;
		private var bNumerate:TextButton;
		private var go:GroupOperator;
		
		public function UIRSms()
		{
			super();
			
			flist = new MFlexList(OptRSms);
			addChild( flist );
			
			
			if (LOC.language == LOC.RU) {
				flist.width = 1220;
				width = 1230;
			} else {
				flist.width = 1220-150;
				width = 1230-150;
			}
			flist.x = PAGE.SEPARATOR_SHIFT;
			flist.y = PAGE.CONTENT_TOP_SHIFT;
			
			go = new GroupOperator;
			
			go.add( "1", drawSeparator(1020) );
			
			bLoadDefaults = new TextButton;
			addChild( bLoadDefaults );
			bLoadDefaults.x = globalX;
			bLoadDefaults.y = globalY;
			bLoadDefaults.setUp(loc("sms_k5_defaults"), onDefaults );
			go.add( "1", bLoadDefaults );
			
			if (MISC.COPY_DEBUG) {
				bNumerate = new TextButton;
				addChild( bNumerate );
				bNumerate.x = globalX + 300;
				bNumerate.y = globalY;
				bNumerate.setUp(loc( "renumber_sms" ), onNumerate);
				go.add( "1", bNumerate );
			}
				
			var a:Array = Resources.SmsArray();
			SMS_TEXT = a[0];
			
			
			
			SMS_DEFAULT = a[1];
		}
		override public function open():void
		{
			super.open();
			
			bLoadDefaults.visible = false;
			totalrequest = 0;
			totalgot = 0;
			OptRSms.globalcounter = 1;
			var i:int;
			
			var len:int = OPERATOR.getSchema( CMD.K5_SMS_TEXT).StructCount;
			if (DS.isfam(DS.K1)) {
				
				for (i=0; i<len; i++) {
					
					if (SMS_TEXT[i] is String) {
						RequestAssembler.getInstance().fireEvent( new Request( CMD.K5_SMS_TEXT, put, i) );
						totalrequest++;
					}
				}
			} else {
				for (i=0; i<len; i++) {
					RequestAssembler.getInstance().fireEvent( new Request( CMD.K5_SMS_TEXT, put, i+1) );
					
					totalrequest++;
				}
			}
			flist.clearlist();
		}
		override public function put(p:Package):void
		{
			var i:IEventDispatcher = flist.add(p,true);
			i.addEventListener( EVENT_CYR, onCyr );
			i.addEventListener( EVENT_LAT, onLat );
			totalgot++;
			if (totalrequest == totalgot) {
				bLoadDefaults.visible = true;
				//height = flist.height+30;
				height = bLoadDefaults.y + 30;
				ResizeWatcher.addDependent(this);
				loadComplete();
			}
		}
		private function onNumerate():void
		{
			var len:int = OPERATOR.getSchema( CMD.K5_SMS_TEXT).StructCount;
			for (var i:int=0; i<len; i++) {
				RequestAssembler.getInstance().fireEvent(new Request(CMD.K5_SMS_TEXT, null, i+1, [String(i+1).length, String(i+1)]));
			}
		}
		private function onLat(e:Event):void
		{
			(e.currentTarget as OptRSms).smstext = translit( (e.currentTarget as OptRSms).smstext ); 
		}
		private function onCyr(e:Event):void
		{
			(e.currentTarget as OptRSms).smstext = convertFromTranslit( (e.currentTarget as OptRSms).smstext );
		}
		private function translit(s:String):String
		{
			var arr:Array = new Array(["А","A"],["Б","B"],["В","V"],["Г","G"],["Д","D"],["Е","E"],["Ё","E"],["Ж","ZH"],["З","Z"],["И","I"],["Й","Y"],["К","K"],["Л","L"],["М","M"],["Н","N"],["О","O"],["П","P"],["Р","R"],["С","S"],["Т","T"],["У","U"],["Ф","F"],["Х","H"],["Ц","Ts"],["Ч","Ch"],["Ш","Sh"],["Щ","Sch"],["Ъ",""],["Ы","Yi"],["Ь",""],["Э","E"],["Ю","Yu"],["Я","Ya"],
				["а","a"],["б","b"],["в","v"],["г","g"],["д","d"],["е","e"],["ё","e"],["ж","zh"],["з","z"],["и","i"],["й","y"],["к","k"],["л","l"],["м","m"],["н","n"],["о","o"],["п","p"],["р","r"],["с","s"],["т","t"],["у","u"],["ф","f"],["х","h"],["ц","ts"],["ч","ch"],["ш","sh"],["щ","sch"],["ъ",String.fromCharCode(35)],["ы","yi"],["ь",String.fromCharCode(37)],["э","e"],["ю","yu"],["я","ya"]);
			var r:String = "";
			//	текущая буква
			var b:String = "";
			var lenS:uint = s.length;
			var lenA:uint = arr.length;
			var i:uint = 0;
			var j:uint;
			while (i < lenS) {
				b = s.substr(i,1);
				j = 0;
				while (j < lenA) {
					if (b == arr[j][0]) {
						b = arr[j][1];
					}
					j++;
				}
				r +=  b;
				i++;
			}
			return r;
		}
		private function onDefaults():void
		{
			flist.putPack( SMS_DEFAULT );
		}
		public function convertFromTranslit(inputString:String):String 
		{
			var ru2en:Object= {
				ru_str : "АБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩъЫьЭЮЯабвгдеёжзийклмнопрстуфхцчшщъыьэюя",
				en_str : ['A','B','V','G','D','E','JO','ZH','Z','I','Y','K','L','M','N','O','P','R','S','T',
					'U','F','H','TS','CH','SH','SCH',String.fromCharCode(35),'YI',String.fromCharCode(39),'YE','YU',
					'YA','a','b','v','g','d','e','jo','zh','z','i','y','k','l','m','n','o','p','r','s','t','u','f',
					'h','ts','ch','sh','sch',String.fromCharCode(35),'yi',String.fromCharCode(39),'ye','yu','ya']
			};
			var tmp_str:Array;
			
			//  Сначала идет замена всех трехбуквенных комбинаций, потом двух и одной
			for (var i:Number = 3; i > 0; i--) {
				for (var key:String in ru2en.en_str) {
					if (ru2en.en_str[key].length == i) {
						inputString = inputString.replace(new RegExp(ru2en.en_str[key], "g"), ru2en.ru_str.charAt(key));
					}
				}
			}
			return inputString;
		}
		
		public function localResize(w:int, h:int, real:Boolean=false):void
		{
			flist.height = h - 85;
			go.movey("1", h - 60);
		}
	}
}