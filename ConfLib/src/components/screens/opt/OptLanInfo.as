package components.screens.opt
{
	import components.abstract.functions.loc;
	import components.basement.OptionsBlock;
	import components.gui.fields.FSSimple;
	import components.protocol.Package;
	import components.screens.ui.UIVersion;
	import components.static.CMD;
	import components.static.COLOR;
	
	public class OptLanInfo extends OptionsBlock
	{
		public function OptLanInfo(_struc:int)
		{
			super();
			operatingCMD = CMD.GET_NET;
			structureID = _struc;
			
			/**	Параметр 1 - информация, каким образом получены параметры 2-6, 0x00 - из команды SET_NET, 0x01 - через DHCP, 0xFF - нет подключения
				Параметр 2 - ip адрес
				Параметр 3 - сетевая маска
				Параметр 4 - роутер по умолчанию
				Параметр 5 - адрес DNS сервера 1
				Параметр 6 - адрес DNS сервера 2 */
			
			yshift = 0;
			var shift:int = UIVersion.shift;
			
			FLAG_SAVABLE = false;
			createUIElement( new FSSimple, 0, loc("lan_lan"),null,1);
			attuneElement( shift, 200, FSSimple.F_CELL_NOTSELECTABLE | FSSimple.F_CELL_ALIGN_LEFT );
			createUIElement( new FSSimple, operatingCMD, loc("lan_ipadr"),null,2);
			attuneElement( shift, 200, FSSimple.F_CELL_NOTSELECTABLE | FSSimple.F_CELL_ALIGN_LEFT );
			createUIElement( new FSSimple, operatingCMD, loc("lan_subnet_mask"),null,3);
			attuneElement( shift, 200, FSSimple.F_CELL_NOTSELECTABLE | FSSimple.F_CELL_ALIGN_LEFT );
			createUIElement( new FSSimple, operatingCMD, loc("lan_default_gateway"),null,4);
			attuneElement( shift, 200, FSSimple.F_CELL_NOTSELECTABLE | FSSimple.F_CELL_ALIGN_LEFT );
			createUIElement( new FSSimple, operatingCMD, loc("lan_preferred_dns"),null,5);
			attuneElement( shift, 200, FSSimple.F_CELL_NOTSELECTABLE | FSSimple.F_CELL_ALIGN_LEFT );
			createUIElement( new FSSimple, operatingCMD, loc("lan_alternate_dns"),null,6);
			attuneElement( shift, 200, FSSimple.F_CELL_NOTSELECTABLE | FSSimple.F_CELL_ALIGN_LEFT );
			
			complexHeight = globalY+27;
		}
		override public function putData(p:Package):void
		{
			switch( p.cmd ) {
				case CMD.GET_NET:
					var net:Array = p.getStructure(structureID);
					
					if (net[0] == 0xff) {
						getField( 0,1).setCellInfo( loc("lan_no_connection") );
						(getField( 0,1) as FSSimple).setTextColor( COLOR.RED );
						getField( operatingCMD,2).setCellInfo( "-" );
						(getField( operatingCMD,2) as FSSimple).setTextColor( COLOR.RED );
						getField( operatingCMD,3).setCellInfo( "-" );
						(getField( operatingCMD,3) as FSSimple).setTextColor( COLOR.RED );
						getField( operatingCMD,4).setCellInfo( "-" );
						(getField( operatingCMD,4) as FSSimple).setTextColor( COLOR.RED );
						getField( operatingCMD,5).setCellInfo( "-" );
						(getField( operatingCMD,5) as FSSimple).setTextColor( COLOR.RED );
						getField( operatingCMD,6).setCellInfo( "-" );
						(getField( operatingCMD,6) as FSSimple).setTextColor( COLOR.RED );
					} else {
						getField( 0,1).setCellInfo( loc("sys_connected") );
						(getField( 0,1) as FSSimple).setTextColor( COLOR.GREEN_DARK);
						getField( operatingCMD,2).setCellInfo( net[1] );
						(getField( operatingCMD,2) as FSSimple).setTextColor( COLOR.GREEN_DARK );
						getField( operatingCMD,3).setCellInfo( net[2]);
						(getField( operatingCMD,3) as FSSimple).setTextColor( COLOR.GREEN_DARK );
						getField( operatingCMD,4).setCellInfo( net[3] );
						(getField( operatingCMD,4) as FSSimple).setTextColor( COLOR.GREEN_DARK );
						getField( operatingCMD,5).setCellInfo( net[4] );
						(getField( operatingCMD,5) as FSSimple).setTextColor( COLOR.GREEN_DARK );
						getField( operatingCMD,6).setCellInfo( net[5] );
						(getField( operatingCMD,6) as FSSimple).setTextColor( COLOR.GREEN_DARK );
					}
					break;
			}
		}
	}
}