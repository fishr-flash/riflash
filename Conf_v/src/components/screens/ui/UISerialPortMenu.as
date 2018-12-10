package components.screens.ui
{
	import components.abstract.functions.loc;
	import components.abstract.servants.TabOperator;
	import components.basement.UI_BaseComponent;
	import components.protocol.Package;
	import components.static.CMD;
	import components.static.DS;
	
	public class UISerialPortMenu extends UI_BaseComponent
	{
		private var uis:Vector.<UI_BaseComponent>;
		private var ui:UI_BaseComponent;
		
		private const S_RS232:int = 1;
		private const S_RS485:int = 2;
		
		public function UISerialPortMenu()
		{
			super();
			
			uis = new Vector.<UI_BaseComponent>(2);
			
			initNavi();
			navi.setUp( onChoose, 10 );
			if ( DS.isfam( DS.V2 ) )
				navi.addButton( loc("misc_portrs232"), S_RS232, TabOperator.GROUP_BUTTONS + S_RS232*1000 );
			if (DS.release >= 36)
				navi.addButton( loc("misc_portrs485"), S_RS485, TabOperator.GROUP_BUTTONS + S_RS485*1000 );
		}
		override public function open():void
		{
			super.open();
			if ( navi.selection > -1 )
				onChoose( navi.selection );
			if (DS.release >= 36) {
				if( cached(CMD.CAN_CAR_ID,put) ) {
					loadComplete();
				}
			} else {
				loadComplete();
			}
		}
		override public function close():void
		{
			super.close();
			if (ui)
				ui.close();
			ui = null;
		}
		override public function put(p:Package):void
		{
			loadComplete();
		}
		private function onChoose(n:Number):void
		{
			if( ui )
				ui.close();
			
			switch(n) {
				case S_RS232:
					if (!uis[n-1]) {
						uis[n-1] = new UISerialPort(n);
						addChild( uis[n-1] );
						height = 520;
						width = 450;
					}
					uis[n-1].open();
					ui = uis[n-1];
					changeSecondLabel(loc("misc_portrs232"));
					loadStart();
					break;
				case S_RS485:
					if (!uis[n-1]) {
						uis[n-1] = new UISerialPort(n);
						addChild( uis[n-1] );
						height = 520;
						width = 450;
					}
					uis[n-1].open();
					ui = uis[n-1];
					changeSecondLabel(loc("misc_portrs485"));
					loadStart();
					break;
			}
			if (ui)
				ui.open();
			visualize( ui );
			
		}
		private function visualize(ui:UI_BaseComponent):void
		{
			var len:int = uis.length;
			for (var i:int=0; i<len; i++) {
				if( uis[i] )
					uis[i].visible = uis[i] == ui;
			}
		}
	}
}