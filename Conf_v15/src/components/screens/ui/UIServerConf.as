package components.screens.ui
{
	import components.abstract.functions.loc;
	import components.basement.UI_BaseComponent;
	import components.gui.fields.FSCheckBox;
	import components.gui.triggers.TextButton;
	import components.protocol.Package;
	import components.static.CMD;
	
	public class UIServerConf extends UI_BaseComponent
	{
		private var srvs:Vector.<OptServerConf>;
		private var cb:FSCheckBox;
		private var bcopy:TextButton;
		
		public function UIServerConf()
		{
			super();
			
			addui( new FSCheckBox, CMD.PROTOCOL_TYPE, loc("ui_coords_server"), null, 1 );
			attuneElement(438);
			getLastElement().setAdapter( new ProtocolTypeAdapter );
			
			srvs = new Vector.<OptServerConf>;
			srvs.push( new OptServerConf(1) );
			addChild( srvs[0] );
			srvs[0].x = globalX;
			srvs[0].y = globalY;
			
			bcopy = new TextButton;
			addChild( bcopy );
			bcopy.setUp( loc("ui_coords_copy_to_reserve"), onCopy );
			bcopy.x = 500;
			bcopy.y = globalY+40;
			bcopy.focusgroup = 0;
			
			globalY += srvs[0].complexHeight;
			
			srvs.push( new OptServerConf(2) );
			addChild( srvs[1] );
			srvs[1].x = globalX;
			srvs[1].y = globalY;
			
			
			starterCMD = [CMD.CONNECT_SERVER, CMD.PROTOCOL_TYPE];
		}
		override public function put(p:Package):void
		{
			switch(p.cmd) {
				case CMD.PROTOCOL_TYPE:
					pdistribute(p);
					loadComplete();
					break;
				case CMD.CONNECT_SERVER:
					for (var i:int=0; i<2; ++i) {
						srvs[i].putRawData( p.getStructure(i+1) );
					}
					break;
			}
		}
		private function onCopy():void
		{
			var adr:Array = srvs[0].getAddress();
			srvs[1].setAddress( adr[0], adr[1] );
		}
	}
}
import components.abstract.RegExpCollection;
import components.abstract.functions.loc;
import components.basement.OptionsBlock;
import components.gui.fields.FSShadow;
import components.gui.fields.FSSimple;
import components.interfaces.IDataAdapter;
import components.interfaces.IFormString;
import components.static.CMD;

class OptServerConf extends OptionsBlock
{
	private var field1:IFormString;
	private var field2:IFormString;
	
	public function OptServerConf(s:int)
	{
		super();
		
		/**"Команда CONNECT_SERVER - подключение к серверу
			Параметр 1 - Номер объекта;
			Параметр 2 - Пароль объекта; //сейчас не используется для ЕГТС
			Параметр 3 - Адрес сервера приема сообщений, IP адрес или доменное имя;
			Параметр 4 - Порт сервера приема сообщений;*/
		
		operatingCMD = CMD.CONNECT_SERVER;
		structureID = s;
		
		globalXSep -= 20;
		drawSeparator();
		
		addui( new FSShadow, operatingCMD, "", null, 1 );
		addui( new FSShadow, operatingCMD, "", null, 2 );
		
		var srv:String = structureID == 1 ? loc("ui_coords_main") : loc("ui_coords_reserve");
		
		createUIElement( new FSSimple, operatingCMD, 
			loc("ui_wifi_ip")+" "+srv+" "+loc("wifi_ip_of_server"), null, 3, null, "", 63, new RegExp("^" + RegExpCollection.RE_IP_ADDRESS + "|" + RegExpCollection.RE_DOMEN + "$") );
		attuneElement( 300, 150, FSSimple.F_MULTYLINE );
		field1 = getLastElement();
		createUIElement( new FSSimple, operatingCMD, 
			loc("g_port")+" "+srv+" "+loc("wifi_of_server"), null, 4,null, "0-9", 5, new RegExp(RegExpCollection.REF_PORT));
		attuneElement( 400, 50 );
		field2 = getLastElement();
		complexHeight = globalY;
	}
	override public function putRawData(a:Array):void
	{
		distribute( a, operatingCMD );
	}
	public function setAddress(ip:String, port:int):void
	{
		if( field1.getCellInfo() != ip || int(field2.getCellInfo()) != port ) {  
			field1.setCellInfo( ip );
			field2.setCellInfo( port );
			remember( field1 );
		}
	}
	public function getAddress():Array
	{
		return [  String(field1.getCellInfo()), int(field2.getCellInfo()) ];
	}
}
class ProtocolTypeAdapter implements IDataAdapter
{
	public function adapt(value:Object):Object
	{
		if (int(value) == 0)
			return true;
		return false;
	}
	public function change(value:Object):Object
	{
		return value;
	}
	public function perform(field:IFormString):void
	{
	}
	public function recover(value:Object):Object
	{
		if (!value)
			return 3;
		return 0;
	}
}