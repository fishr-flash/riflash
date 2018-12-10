package components.screens.ui
{
	import components.abstract.RegExpCollection;
	import components.abstract.functions.loc;
	import components.basement.UI_BaseComponent;
	import components.gui.fields.FSRadioGroup;
	import components.gui.fields.FSSimple;
	import components.gui.triggers.TextButton;
	import components.interfaces.IFormString;
	import components.protocol.Package;
	import components.static.CMD;
	import components.system.SavePerformer;
	import components.system.UTIL;
	
	public class UIParamsLan extends UI_BaseComponent
	{
		private var rg1:FSRadioGroup;
		private var mac_randomize:TextButton;
		
		/** Спец версия для 15го	*/
		
		public function UIParamsLan()
		{
			super();
			
			/**	Параметр 1 - получать данные по dhcp, 0x00 - нет, 0x01 - да
				Параметр 2 - ip адрес
				Параметр 3 - сетевая маска
				Параметр 4 - роутер по умолчанию
				Параметр 5 - адрес DNS сервера 1
				Параметр 6 - адрес DNS сервера 2*/
			
			rg1 = new FSRadioGroup( [ {label:loc("lan_autoget_ip"), selected:false, id:0x01 },
				{label:loc("lan_set_ip_manually"), selected:false, id:0x00 }], 1, 30 );
			addChild( rg1 );
			rg1.x = globalX;
			rg1.y = 10;
			rg1.width = 330;
			
			addUIElement( rg1, CMD.SET_NET,1, callLogic);
			globalY += rg1.height + 5;
			
			createUIElement( new FSSimple, CMD.SET_NET, loc("lan_ipadr"), null, 2, null, "0-9.", 15, new RegExp( "^"+ RegExpCollection.RE_IP_ADDRESS+"$") );
			attuneElement( 330, 130 );
			createUIElement( new FSSimple, CMD.SET_NET, loc("lan_subnet_mask"), null, 3, null, "0-9.", 15, new RegExp("^"+ RegExpCollection.RE_IP_ADDRESS+"$") );
			attuneElement( 330, 130 );
			createUIElement( new FSSimple, CMD.SET_NET, loc("lan_default_gateway"), null, 4, null, "0-9.", 15, new RegExp("^"+ RegExpCollection.RE_IP_ADDRESS+"$") );
			attuneElement( 330, 130 );
			createUIElement( new FSSimple, CMD.SET_NET, loc("lan_preferred_dns"), null, 5, null, "0-9.", 15 );
			attuneElement( 330, 130 );
			createUIElement( new FSSimple, CMD.SET_NET, loc("lan_alternate_dns"), null, 6, null, "0-9.", 15 );
			attuneElement( 330, 130 );
			
			starterCMD = CMD.SET_NET;
			height = 410;
		}
		override public function put(p:Package):void
		{
			switch (p.cmd) {
				case CMD.SET_NET:
					distribute( p.getStructure(), p.cmd );
					setEnabled( Boolean(int(p.getStructure()[0]) == 1) );
					loadComplete();
					break;
				/*case CMD.SET_OPENED_PORT:
					distribute( p.getStructure(), p.cmd );
					break;*/
				case CMD.SET_MAC_ADDR:
					getField( p.cmd, 1 ).setCellInfo( UTIL.formateZerosInFront( ( p.getStructure()[0] ).toString(16).toUpperCase(), 2 ) );
					getField( p.cmd, 2 ).setCellInfo( UTIL.formateZerosInFront( ( p.getStructure()[1] ).toString(16).toUpperCase(), 2 ) );
					getField( p.cmd, 3 ).setCellInfo( UTIL.formateZerosInFront( ( p.getStructure()[2] ).toString(16).toUpperCase(), 2 ) );
					getField( p.cmd, 4 ).setCellInfo( UTIL.formateZerosInFront( ( p.getStructure()[3] ).toString(16).toUpperCase(), 2 ) );
					getField( p.cmd, 5 ).setCellInfo( UTIL.formateZerosInFront( ( p.getStructure()[4] ).toString(16).toUpperCase(), 2 ) );
					getField( p.cmd, 6 ).setCellInfo( UTIL.formateZerosInFront( ( p.getStructure()[5] ).toString(16).toUpperCase(), 2 ) );
					
					loadComplete();
					break;
			}
		}
		private function callLogic(t:IFormString):void
		{
			setEnabled( Boolean(int(t.getCellInfo()) == 1) );
			SavePerformer.remember(structureID,t);
		}
		private function callRandomizer():void
		{
			var a:Array = UTIL.generateMAC();
			
			getField( CMD.SET_MAC_ADDR, 1 ).setCellInfo( UTIL.formateZerosInFront( (a[0]).toString(16).toUpperCase(), 2 ) );
			getField( CMD.SET_MAC_ADDR, 2 ).setCellInfo( UTIL.formateZerosInFront( (a[1]).toString(16).toUpperCase(), 2 ) );
			getField( CMD.SET_MAC_ADDR, 3 ).setCellInfo( UTIL.formateZerosInFront( (a[2]).toString(16).toUpperCase(), 2 ) );
			getField( CMD.SET_MAC_ADDR, 4 ).setCellInfo( UTIL.formateZerosInFront( (a[3]).toString(16).toUpperCase(), 2 ) );
			getField( CMD.SET_MAC_ADDR, 5 ).setCellInfo( UTIL.formateZerosInFront( (a[4]).toString(16).toUpperCase(), 2 ) );
			getField( CMD.SET_MAC_ADDR, 6 ).setCellInfo( UTIL.formateZerosInFront( (a[5]).toString(16).toUpperCase(), 2 ) );
			SavePerformer.remember( 1, getField( CMD.SET_MAC_ADDR, 1 ) );
		}
		private function setEnabled(b:Boolean):void
		{
			getField( CMD.SET_NET, 2 ).disabled = b;
			getField( CMD.SET_NET, 3 ).disabled = b;
			getField( CMD.SET_NET, 4 ).disabled = b;
			getField( CMD.SET_NET, 5 ).disabled = b;
			getField( CMD.SET_NET, 6 ).disabled = b;
		}
	}
}