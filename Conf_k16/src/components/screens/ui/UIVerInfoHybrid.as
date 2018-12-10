package components.screens.ui
{
	import components.abstract.functions.loc;
	import components.basement.UI_BaseComponent;
	import components.gui.fields.FSSimple;
	import components.gui.triggers.TextButton;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.protocol.statics.SERVER;
	import components.screens.opt.OptLanInfo;
	import components.screens.opt.OptVerInfo;
	import components.screens.opt.OptVerInfoBottom;
	import components.static.CMD;
	import components.static.COLOR;
	import components.static.DS;
	import components.static.MISC;
	
	public class UIVerInfoHybrid extends UI_BaseComponent
	{
		private var FLAG_ASK_BALANCE:Boolean = false;
		private var optLan:OptLanInfo;
		private var bRefresh:TextButton;
		private var infos:Vector.<OptVerInfo>;
		private var optVerInfoBottom:OptVerInfoBottom;
		
		public function UIVerInfoHybrid()
		{
			super();
			
			yshift = 0;
			
			optVerInfoBottom = new OptVerInfoBottom;
			addChild( optVerInfoBottom );
			optVerInfoBottom.x = globalX;
			optVerInfoBottom.y = globalY;
			globalY += optVerInfoBottom.getHeight();
			drawSeparator();
			globalY -= 10;
			
			var shift:int = UIVersion.shift;
			
			FLAG_SAVABLE = false;
			createUIElement( new FSSimple, CMD.VER_INFO, loc("ui_verinfo_device_name"),null,1);
			attuneElement( shift, 300, FSSimple.F_CELL_NOTSELECTABLE  | FSSimple.F_CELL_ALIGN_LEFT);
			(getLastElement() as FSSimple).setTextColor( COLOR.GREEN_DARK);
			createUIElement( new FSSimple, CMD.VER_INFO, loc("ui_verinfo_fw_ver"),null,2);
			attuneElement( shift, 250, FSSimple.F_CELL_NOTSELECTABLE | FSSimple.F_CELL_ALIGN_LEFT );
			(getLastElement() as FSSimple).setTextColor( COLOR.GREEN_DARK );
			
			/**Команда VER_INFO
			 * Параметр 1 - Название прибора;
			 * Параметр 2 - Версия прошивки;
			 * Параметр 3 - Тип памяти; */
			
			globalY += 10;
			drawSeparator();
			globalY -= 10;
			
			createUIElement( new FSSimple, CMD.VER_INFO1, loc("ui_verinfo_conn_type"),null,1);
			attuneElement( shift, NaN, FSSimple.F_CELL_NOTSELECTABLE | FSSimple.F_CELL_ALIGN_LEFT );
			(getLastElement() as FSSimple).setTextColor( COLOR.GREEN_DARK );
			createUIElement( new FSSimple, CMD.VER_INFO1, loc("ui_verinfo_modem"),null,2);
			attuneElement( shift, NaN, FSSimple.F_CELL_NOTSELECTABLE | FSSimple.F_CELL_ALIGN_LEFT );
			(getLastElement() as FSSimple).setTextColor( COLOR.GREEN_DARK );
			createUIElement( new FSSimple, CMD.VER_INFO1, loc("ui_verinfo_modem_fw_ver"),null,3);
			attuneElement( shift, NaN, FSSimple.F_CELL_NOTSELECTABLE | FSSimple.F_CELL_ALIGN_LEFT );
			(getLastElement() as FSSimple).setTextColor( COLOR.GREEN_DARK );
			createUIElement( new FSSimple, CMD.VER_INFO1, loc("ui_verinfo_imei"),null,4);
			attuneElement( shift, 200, FSSimple.F_CELL_NOTEDITABLE_NOTEDITBOX  | FSSimple.F_CELL_ALIGN_LEFT);
			(getLastElement() as FSSimple).setTextColor( COLOR.GREEN_DARK );
			
			height = 760;
			starterCMD = [CMD.VER_INFO,CMD.VER_INFO1,CMD.GET_NET];
		}
		private function refresh():void
		{
			SERVER.ADDRESS = SERVER.ADDRESS_TOP;
			RequestAssembler.getInstance().fireEvent( new Request(CMD.VER_INFO1,put ));
			RequestAssembler.getInstance().fireEvent( new Request(CMD.GET_NET,put ));
		}
		override public function put(p:Package):void
		{
			
			switch(p.cmd) {
				case CMD.VER_INFO:
					var vinfo:Array = p.getStructure().slice();
					switch (p.serverAdr) {
						case SERVER.ADDRESS_TOP:
							getField( CMD.VER_INFO,1 ).setCellInfo( loc(DS.name_k16) );
							if (MISC.COPY_DEBUG)
								getField( CMD.VER_INFO,2 ).setCellInfo( vinfo[1] + "." + DS.bootloader + " commit " + DS.commit);
							else
								getField( CMD.VER_INFO,2 ).setCellInfo( vinfo[1] + "." + DS.bootloader);
							break;
						case SERVER.ADDRESS_BOTTOM:
							optVerInfoBottom.putData(p);
							
							SERVER.ADDRESS = SERVER.ADDRESS_TOP;
							initSpamTimer( CMD.GSM_SIG_LEV, 0 );
							loadComplete();
							break;
					}
					break;
				case CMD.VER_INFO1:
					var vinfo1:Array = p.getStructure().slice();
					getField( p.cmd ,1 ).setCellInfo( vinfo1[0] );
					getField( p.cmd ,2 ).setCellInfo( vinfo1[1] );
					getField( p.cmd ,3 ).setCellInfo( vinfo1[2] );
					getField( p.cmd ,4 ).setCellInfo( vinfo1[3] );
					
					var len:int = p.length;
					var i:int;
					if (!infos) {
						var opt:OptVerInfo;
						infos = new Vector.<OptVerInfo>;
						for( i=0; i<len; ++i ) {
							opt = new OptVerInfo(i+1);
							addChild( opt );
							opt.y = globalY;//199+(i)*opt.getHeight();
							globalY += opt.getHeight();
							opt.x = globalX;
							opt.putRawData( p.getStructure(i+1) );
							infos.push(opt);
						}
					} else {
						for( i=0; i<len; ++i ) {
							infos[i].putRawData( p.getStructure(i+1) );
						}
					}
					break;
				case CMD.GET_NET:
					if(!optLan) {
						globalY += 10;
						drawSeparator();
						globalY -= 10;
						optLan = new OptLanInfo(1);
						addChild( optLan );
						optLan.y = globalY;
						optLan.x = globalX;
						globalY += optLan.complexHeight - 10;
						
						bRefresh = new TextButton;
						addChild( bRefresh );
						bRefresh.setUp( loc("g_update"), refresh );
						bRefresh.x = globalX;
						bRefresh.y = globalY;
						globalY += 40;
					}
					optLan.putData(p);
					
					RequestAssembler.getInstance().fireEvent( new Request(CMD.VER_INFO, put, 0, null, 0, 0, SERVER.ADDRESS_BOTTOM ));
					break;
				default:
					break;
			}
		}
		override protected function processState(p:Package):void 
		{
			super.processState(p);
			var len:int = p.length;
			for( var i:int=0; i<len; ++i ) {
				if( infos[i] != null && p.getStructure(i+1) is Array )
					infos[i].putState( p.getStructure(i+1) );
			}
		}
	}
}