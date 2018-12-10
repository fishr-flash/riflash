package components.screens.ui
{
	import components.abstract.functions.loc;
	import components.abstract.servants.TaskManager;
	import components.basement.OptionsBlock;
	import components.basement.UI_BaseComponent;
	import components.gui.fields.FSShadow;
	import components.gui.fields.FSSimple;
	import components.gui.fields.FormString;
	import components.gui.visual.SIMSignal;
	import components.interfaces.ITask;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.screens.opt.OptVerInfoMain;
	import components.screens.opt.OptVerInfoWiFi;
	import components.screens.opt.OptVpn;
	import components.static.CMD;
	import components.static.COLOR;
	import components.static.PAGE;
	
	public class UIVerInfoCam extends UI_BaseComponent
	{
		private var opts:Vector.<OptionsBlock>;
		private var signal:SIMSignal;
		private var task:ITask;
		
		public function UIVerInfoCam()
		{
			super();
			
			var shift:int = 190 + PAGE.CONTENT_LEFT_SHIFT;
			var sepw:int = 500;
			yshift = 0;
			
			opts = new Vector.<OptionsBlock>;
			
			add( new OptVerInfoMain ); 
			
			drawSeparator(sepw);
			globalY-=10;
			
			addui( new FormString, 0, loc("gprs_ext_usb_modem"), null, 1 );
			attuneElement(NaN,NaN,FormString.F_TEXT_BOLD);
			
			addui( new FSSimple, CMD.EXT_MODEM_INFO, loc("gprs_ext_modem"), null, 1 );
			attuneElement( shift, 300,  FSSimple.F_CELL_ALIGN_LEFT | FSSimple.F_CELL_NOTSELECTABLE );
			(getLastElement() as FSSimple).setTextColor( COLOR.GREEN_DARK );
			addui( new FSShadow, CMD.EXT_MODEM_INFO, "", null, 2 );
			addui( new FSSimple, CMD.EXT_MODEM_INFO, loc("ui_verinfo_imei"), null, 3 );
			attuneElement( shift, 300,  FSSimple.F_CELL_ALIGN_LEFT | FSSimple.F_CELL_NOTSELECTABLE );
			(getLastElement() as FSSimple).setTextColor( COLOR.GREEN_DARK );
			addui( new FSSimple, CMD.EXT_MODEM_INFO, loc("ui_gprs_simcard_id"), null, 4 );
			attuneElement( shift, 300,  FSSimple.F_CELL_ALIGN_LEFT | FSSimple.F_CELL_NOTSELECTABLE );
			(getLastElement() as FSSimple).setTextColor( COLOR.GREEN_DARK );
			addui( new FSSimple, CMD.EXT_MODEM_INFO, loc("ui_gprs_operator"), null, 5 );
			attuneElement( shift, 300,  FSSimple.F_CELL_ALIGN_LEFT | FSSimple.F_CELL_NOTSELECTABLE );
			(getLastElement() as FSSimple).setTextColor( COLOR.GREEN_DARK );
			addui( new FSShadow, CMD.EXT_MODEM_INFO, "", null, 6 );
			addui( new FSShadow, CMD.EXT_MODEM_INFO, "", null, 7 );
			
			signal = new SIMSignal;
			addChild( signal );
			signal.x = 220 + PAGE.CONTENT_LEFT_SHIFT;
			signal.y = globalY;
			
			addui( new FormString, 0, loc("ui_gprs_signal_level"), null, 3 );
			
			globalY+=10;
			
			drawSeparator(sepw);
			globalY-=10;
			
			add( new OptVerInfoWiFi );
			
			drawSeparator(sepw);
			globalY-=10;
			
			add( new OptVpn );
			
			height = globalY;
			
			starterCMD = [CMD.EXT_MODEM_INFO, CMD.WIFI_GET_NET, CMD.VPN_GET_INFO]; 
		}
		override public function put(p:Package):void
		{
			switch(p.cmd) {
				case CMD.EXT_MODEM_INFO:
					opts[0].putData(null);
					signal.putStraight( int(p.getStructure()[6])*20, true ); 
					pdistribute(p);
					if (this.visible) {
						if (!task)
							task = TaskManager.callLater( request, TaskManager.DELAY_30SEC );
						else
							task.repeat();
					}
					loadComplete();
					break;
				case CMD.WIFI_GET_NET:
					opts[1].putData(p);
					break;
				case CMD.VPN_GET_INFO:
					opts[2].putData(p);
					break;
			}
		}
		override public function close():void
		{
			super.close();
			if (task)
				task.kill();
			task = null;
		}
		private function request():void
		{
			RequestAssembler.getInstance().fireEvent( new Request( CMD.EXT_MODEM_INFO, put));
			RequestAssembler.getInstance().fireEvent( new Request( CMD.WIFI_GET_NET, put));
			RequestAssembler.getInstance().fireEvent( new Request( CMD.VPN_GET_INFO, put));
		}
		private function add(o:OptionsBlock):void
		{
			opts.push(o);
			var i:int = opts.length-1;
			addChild( opts[i] );
			opts[i].x = globalX;
			opts[i].y = globalY;
			globalY += opts[i].complexHeight;
		}
	}
}