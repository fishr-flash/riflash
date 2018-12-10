package components.screens.ui
{
	import components.basement.OptionsBlock;
	import components.basement.UI_BaseComponent;
	import components.gui.fields.FSCheckBox;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.screens.opt.OptSim;
	import components.static.CMD;
	
	public class UISim extends UI_BaseComponent
	{
		private var simcards:Vector.<OptionsBlock>;
		private var use_roaming:Boolean;
		
		public function UISim(compr:Boolean, roaming:Boolean, use3g:Boolean = false)
		{
			super();
			simcards = new Vector.<OptionsBlock>;

			starterCMD = [CMD.GPRS_SIM];
			
			if (compr)
				(starterCMD as Array).push(CMD.GPRS_COMPR);
			if (roaming)
				(starterCMD as Array).push(CMD.NO_GPRS_ROAMING);
			if (use3g)
				(starterCMD as Array).push(CMD.MODEM_NETWORK_CTRL);
			
			use_roaming = roaming;
			this.width = 480;
		}
		override public function put(p:Package):void
		{
			var len:int;
			var i:int;
			
			switch(p.cmd) {
				case CMD.GPRS_SIM:
					len = p.length;
					if (simcards.length < p.length)
						simcards.length = p.length;
					
					for( i=0; i<len; ++i ) {
						if (simcards[i] == null) {
							if (i>0)
								drawSeparator(421);
							/*
							// требовалось для хотфикса аппаратногго бага симкарт 107
							if (DEVICES.getApp() == "107")
							
								simcards[i] = new OptSimHotFix(i+1,use_roaming, len==1);
							else*/
							simcards[i] = new OptSim(i+1,use_roaming, len==1);
							addChild( simcards[i] );
							simcards[i].x = globalX;
							simcards[i].y = globalY;
							globalY += simcards[i].height;
						}
						simcards[i].putData( p.detach(i+1));
					}
					this.height = simcards[len-1].y + simcards[len-1].height + 20;
					if( (starterCMD as Array).length == 1)
						loadComplete();
					break;
				case CMD.GPRS_COMPR:
					if( p.getStructure()[0] == 0 )
						RequestAssembler.getInstance().fireEvent( new Request(CMD.GPRS_COMPR, null, 1, [1]));
					loadComplete();
					break;
				case CMD.NO_GPRS_ROAMING:
					len = p.length;
					if (simcards.length < p.length)
						simcards.length = p.length;
					
					for( i=0; i<len; ++i ) {
						if (simcards[i] != null)
							simcards[i].putData( p.detach(i+1));
					}
					this.height += 20;
					loadComplete();
					break;
				case CMD.MODEM_NETWORK_CTRL:
					addui( new FSCheckBox, p.cmd, "MODEM_NETWORK_CTRL", null, 1 );
					distribute( p.getStructure(), p.cmd );
					this.height += 20;
					loadComplete();
			}
		}
	}
}