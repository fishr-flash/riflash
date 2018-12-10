package components.screens.ui
{
	import components.basement.UI_BaseComponent;
	import components.protocol.Package;
	import components.static.CMD;
	
	public class UIServer extends UI_BaseComponent
	{
		private var opts:Vector.<OptServer>;
		
		public function UIServer()
		{
			super();
			
			opts = new Vector.<OptServer>;
			for (var i:int=0; i<2; i++) {
				opts.push( new OptServer(i+1) );
				addChild( opts[i] );
				opts[i].x = globalX;
				opts[i].y = globalY;
				globalY += opts[i].complexHeight;
				
				if (i==0)
					drawSeparator(500-59);
			}
			opts[0].opt = opts[1];
			
			starterCMD = CMD.CTRL_SERVER_SETTINGS;
		}
		override public function put(p:Package):void
		{
			var len:int = opts.length;
			for (var i:int=0; i<len; i++) {
				opts[i].putData(p);
			}
			loadComplete();
		}
	}
}
import components.abstract.RegExpCollection;
import components.abstract.functions.loc;
import components.basement.OptionsBlock;
import components.gui.fields.FSCheckBox;
import components.gui.fields.FSSimple;
import components.gui.triggers.TextButton;
import components.protocol.Package;
import components.static.CMD;

class OptServer extends OptionsBlock
{
	public var opt:OptServer;
	private var bCopy:TextButton;
	
	public function OptServer(n:int)
	{
		super();
		
		structureID = n;
		
		var sh:int = 250;

		var server:String, port:String;
		if (n==1) {
			bCopy = new TextButton;
			addChild( bCopy );
			bCopy.x = 500-59;
			bCopy.y = globalY;
			bCopy.setUp(loc("server_copy_data_to_backup"), onClick );
			
			server = loc("server_main_ip");
			port = loc("server_main_port");
		} else {
			server = loc("server_backup_ip");
			port = loc("server_backup_port");
		}
		
		addui( new FSSimple, CMD.CTRL_SERVER_SETTINGS, server, null, 1, null, "", 63 );
		attuneElement( sh, 150, FSSimple.F_MULTYLINE );
		
		addui( new FSSimple, CMD.CTRL_SERVER_SETTINGS, port, null, 2, null, "0-9", 5, new RegExp( RegExpCollection.REF_PORT ));
		attuneElement( sh + 90, 60 );
		addui( new FSCheckBox, CMD.CTRL_SERVER_SETTINGS, loc("server_connect"), null, 3 );
		attuneElement( sh + 138 );
		complexHeight = globalY;
	}
	override public function putData(p:Package):void
	{
		pdistribute(p);
	}
	private function onClick():void
	{
		for (var i:int=0; i<3; i++) {
			opt.getField(CMD.CTRL_SERVER_SETTINGS,i+1).setCellInfo( getField(CMD.CTRL_SERVER_SETTINGS,i+1).getCellInfo() );
		}
		opt.remember(opt.getField(CMD.CTRL_SERVER_SETTINGS,1));
	}
}