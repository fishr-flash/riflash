package components.screens.opt
{
	import flash.events.Event;
	import flash.events.FocusEvent;
	
	import components.abstract.RegExpCollection;
	import components.abstract.functions.loc;
	import components.basement.OptionsBlock;
	import components.gui.fields.FSCheckBox;
	import components.gui.fields.FSShadow;
	import components.gui.fields.FSSimple;
	import components.gui.fields.FSSimpleConnectServerEGTS;
	import components.interfaces.IAbstractProcessor;
	import components.interfaces.IFormString;
	import components.static.CMD;
	import components.static.DS;
	import components.system.SavePerformer;
	
	public class OptConnectServer extends OptionsBlock
	{
		public static const SHOW_NOTHING:int = 0;
		public static const SHOW_OBJECT:int = 0x01;
		public static const SHOW_PASS:int = 0x02;
		
		private var field1:IFormString;
		private var field2:IFormString;
		private var field3:IFormString;
		private var field4:IFormString;
		private var bot:IAbstractProcessor;
		
		private var showObject:Boolean;
		private var showPass:Boolean;
		
		public var cloneEgts:Function;
		
		public function OptConnectServer(s:int, line1:String, line2:String, params:int=0 )//, showObject:Boolean=false)
		{
			super();
			
			structureID = s;
			showObject = (params & 0x01) > 0;
			showPass = (params & 0x02) > 0;
			operatingCMD = CMD.CONNECT_SERVER;
			
			var addshift:int = 30;
			
			if (showObject) {
				if(  structureID == 3 && ( !DS.isfam( DS.F_V ) || ( DS.isfam( DS.F_V ) && DS.release > 54 ) )  )
				{
					/// максимальное число для 4294967295
					createUIElement( new FSSimpleConnectServerEGTS, operatingCMD, 
						//loc("ui_connectsrv_object"), onSave, 1, null, "0-9", 5, new RegExp( RegExpCollection.REF_0to65535) );
						loc("ui_connectsrv_object"), onSave, 1, null, "0-9", 10 );
					
					//SavePerformer.trigger( {"prepare":refine } );
					attuneElement( 350+addshift, 100, FSSimple.F_MULTYLINE );
				}
				else
				{
					createUIElement( new FSSimple, operatingCMD, 
						loc("ui_connectsrv_object"), onSave, 1, null, "0-9", 5, new RegExp( RegExpCollection.REF_0to65535) );
					attuneElement( 390+addshift, 60, FSSimple.F_MULTYLINE );
				}
				
				
				field1 = getLastElement();
				
				if( showPass ) {
					FLAG_SAVABLE = false;
					FLAG_VERTICAL_PLACEMENT = false;
					createUIElement( new FSCheckBox, 0, loc("g_show_pass"), switchPassword, 1 ).x = 470+addshift;
					attuneElement( 130 );
					FLAG_SAVABLE = true;
					FLAG_VERTICAL_PLACEMENT = true;
					
					createUIElement( new FSSimple, operatingCMD,
						loc("ui_connectsrv_object_pass"), onPassword, 2, null , "A-Za-z0-9", 8 );
					attuneElement( 350+addshift, NaN, FSSimple.F_TEXT_AS_PASSWORD );
					field2 = getLastElement();
				} else
					field2 = createUIElement( new FSShadow, operatingCMD, "", null, 2 );
				
				
			} else {
				field1 = createUIElement( new FSShadow, operatingCMD, "", null, 1 );
				//field1 = getLastElement();
				field2 = createUIElement( new FSShadow, operatingCMD, "", null, 2 );
				//field2 = getLastElement();
			}
			
			createUIElement( new FSSimple, operatingCMD, 
				line1, null, 3, null, "", 63, new RegExp("^" + RegExpCollection.RE_IP_ADDRESS + "$" + "|" + RegExpCollection.RE_DOMEN + "$") );
			attuneElement( 300+addshift, 150, FSSimple.F_MULTYLINE );
			field3 = getLastElement();
			
			createUIElement( new FSSimple, operatingCMD, 
				line2, null, 4,null, "0-9", 5, new RegExp(RegExpCollection.REF_PORT));
			attuneElement( 400+addshift, 50 );
			field4 = getLastElement();
			
			
			complexHeight = globalY;
		}
		
		
		override public function putRawData(a:Array):void
		{
			distribute( a, operatingCMD );
			
			if(  structureID == 3 && ( !DS.isfam( DS.F_V ) || ( DS.isfam( DS.F_V ) && DS.release > 54 ) )  )
			{
				SavePerformer.trigger( {"prepare":refine } );
			}
		}
		public function set sbot(b:IAbstractProcessor):void
		{
			if (b) {
				bot = b;
				bot.callback = unlock;
				if (field1 is FSSimple) {
					(field1 as FSSimple).attune( FSSimple.F_CELL_NOTEDITABLE_EDITBOX );
					(field1 as FSSimple).addEventListener(FocusEvent.FOCUS_IN, onFocus);
					(field2 as FSSimple).attune( FSSimple.F_CELL_NOTEDITABLE_EDITBOX );
					(field2 as FSSimple).addEventListener(FocusEvent.FOCUS_IN, onFocus);
				}
				(field3 as FSSimple).attune( FSSimple.F_CELL_NOTEDITABLE_EDITBOX );
				(field4 as FSSimple).attune( FSSimple.F_CELL_NOTEDITABLE_EDITBOX );
				(field3 as FSSimple).addEventListener(FocusEvent.FOCUS_IN, onFocus);
				(field4 as FSSimple).addEventListener(FocusEvent.FOCUS_IN, onFocus);
			}
		}
		public function set password(value:String):void
		{
			field2.setCellInfo(value);
			remember(field2);
		}
		public function get password():String
		{
			return String(field2.getCellInfo());
		}
		public function clone(o:String, p:String):void
		{
			if( (field1.getCellInfo() != o || field2.getCellInfo() != p) ) {  
				field1.setCellInfo( o );
				field2.setCellInfo( p );
				remember( field1 );
			}
		}
		public function setAddress(ip:String, port:int):void
		{
			if( field3.getCellInfo() != ip || int(field4.getCellInfo()) != port ) {  
				field3.setCellInfo( ip );
				field4.setCellInfo( port );
				remember( field3 );
			}
		}
		public function getAddress():Array
		{
			return [  String(field3.getCellInfo()), int(field4.getCellInfo()) ];
		}
		public function set dispell(value:Boolean):void
		{
			getField(operatingCMD,3).disabled = value;
			getField(operatingCMD,4).disabled = value;
			this.visible = !value;
		}
		private function onSave(t:IFormString):void
		{
			field2.setCellInfo( "" );
			//cloneEgts(structureID, t.getCellInfo(), "");
			remember(t);
			
			
		}
		private function onPassword(t:IFormString):void
		{
			this.dispatchEvent( new Event(Event.CHANGE));
			remember(t);
		}
		private function switchPassword():void
		{
			if (bot && !bot.solved) {
				bot.process();
				return;
			}
			(field2 as FSSimple).displayAsPassword( Boolean( getField(0,1).getCellInfo()==0 ) );
		}
		
		private function refine():void
		{
			
			var o:Object = SavePerformer.oNeedToSave;
			
			
			if( o[CMD.CONNECT_SERVER] && o[CMD.CONNECT_SERVER][ structureID ] ) 
			{
				const compoundName:int = int( o[CMD.CONNECT_SERVER][ structureID ][ "1" ] );
				o[CMD.CONNECT_SERVER][ structureID + 1 ][ "1" ] = compoundName >> 16;
				o[CMD.CONNECT_SERVER][ structureID  ][ "1" ] = compoundName & 0xFFFF;	
			}
			
			
			
			
			
			
		}
		
		private function onFocus(e:Event):void
		{
			if (bot && !bot.solved)
				bot.process();
		}
		private function unlock():void
		{
			if (field1 is FSSimple) {
				(field1 as FSSimple).attune( FSSimple.F_CELL_EDITABLE_EDITBOX );
				(field1 as FSSimple).removeEventListener(FocusEvent.FOCUS_IN, onFocus);
				(field2 as FSSimple).attune( FSSimple.F_CELL_EDITABLE_EDITBOX );
				(field2 as FSSimple).removeEventListener(FocusEvent.FOCUS_IN, onFocus);
			}
			(field3 as FSSimple).attune( FSSimple.F_CELL_EDITABLE_EDITBOX );
			(field4 as FSSimple).attune( FSSimple.F_CELL_EDITABLE_EDITBOX );
			(field3 as FSSimple).removeEventListener(FocusEvent.FOCUS_IN, onFocus);
			(field4 as FSSimple).removeEventListener(FocusEvent.FOCUS_IN, onFocus);
		}
	}
}