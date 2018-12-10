package components.screens.ui
{
	import components.abstract.functions.loc;
	import components.abstract.servants.TaskManager;
	import components.gui.fields.FSSimple;
	import components.gui.triggers.TextButton;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.protocol.statics.OPERATOR;
	import components.protocol.statics.SERVER;
	import components.screens.opt.OptLanInfo;
	import components.screens.opt.OptVerInfo;
	import components.screens.opt.OptVerNavInfo;
	import components.screens.opt.OptVpn;
	import components.screens.page.VersionRitmLink;
	import components.static.CMD;
	import components.static.COLOR;
	import components.static.DS;
	
	public class UIVerInfoVPN extends UIVersion
	{
		private var optLan:OptLanInfo;
		private var optVpn:OptVpn;
		private var bRefresh:TextButton;
		private var infos:Vector.<OptVerInfo>;
		private var optNavInfo:OptVerNavInfo;
		private var ritmLink:VersionRitmLink;
		
		public function UIVerInfoVPN()
		{
			super(3);
			
			if ( !DS.isDevice(DS.R15)  && !DS.isDevice(DS.R15IP) ) {
			
				
				/// версия сопроцессора ( сторожевого таймера )
				addui( new FSSimple, 0, loc("service_current_coprocessor_ver"), null, 1 );
				attuneElement( shift, 400, FSSimple.F_CELL_NOTSELECTABLE | FSSimple.F_CELL_ALIGN_LEFT );
				( getLastElement() as FSSimple ).setTextColor( COLOR.GREEN_DARK );
				
				drawSeparator(sepwidth);
				globalY -= 9;
				
				optNavInfo = addopt( new OptVerNavInfo) as OptVerNavInfo;
				
				drawSeparator(sepwidth);
				globalY -= 10;
				
				createUIElement( new FSSimple, CMD.VER_INFO1, loc("ui_verinfo_modem"),null,2);
				attuneElement( shift, NaN, FSSimple.F_CELL_NOTSELECTABLE | FSSimple.F_CELL_ALIGN_LEFT );
				(getLastElement() as FSSimple).setTextColor( COLOR.GREEN_DARK );
	
				createUIElement( new FSSimple, CMD.VER_INFO1, loc("ui_verinfo_imei"),null,4);
				attuneElement( shift, 200, FSSimple.F_CELL_NOTSELECTABLE  | FSSimple.F_CELL_ALIGN_LEFT);
				(getLastElement() as FSSimple).setTextColor( COLOR.GREEN_DARK );
			
				globalY -= 7;
				
				height = 710+optNavInfo.complexHeight;
			}
			
			if( DS.isDevice(DS.R15)  || DS.isDevice(DS.R15IP) ) {
				
				drawSeparator(sepwidth);
				globalY -= 10;
				
				ritmLink = new VersionRitmLink;
				addChild( ritmLink );
				ritmLink.y = globalY;
				globalY += ritmLink.complexHeight;
				ritmLink.x = globalX;
				
				height = 390;
				starterCMD = [CMD.VER_INFO,CMD.RITM_LINK_ID,CMD.GET_NET,CMD.VPN_GET_INFO];
			} else
				starterCMD = [CMD.VER_INFO,CMD.VER_INFO1,CMD.GET_NET,CMD.NAV_INFO,CMD.VPN_GET_INFO];
		}
		private function refresh():void
		{
			if( !DS.isDevice(DS.R15)  && !DS.isDevice(DS.R15IP) )
				RequestAssembler.getInstance().fireEvent( new Request(CMD.VER_INFO1,put ));
			RequestAssembler.getInstance().fireEvent( new Request(CMD.GET_NET,put ));
			RequestAssembler.getInstance().fireEvent( new Request(CMD.VPN_GET_INFO,put ));
		}
		override public function put(p:Package):void
		{
			
			var len:int, i:int;
			switch(p.cmd) {
				case CMD.VER_INFO1:
					var vinfo1:Array = p.getStructure().slice();
					//getField( p.cmd ,1 ).setCellInfo( vinfo1[0] );
					getField( p.cmd ,2 ).setCellInfo( vinfo1[1] );
					//getField( p.cmd ,3 ).setCellInfo( vinfo1[2] );
					getField( p.cmd ,4 ).setCellInfo( vinfo1[3] );
					
					len = p.length;
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
					onTick();
					break;
				case CMD.VER_INFO:
					
					
					var vapp:String = p.getStructure(1)[1];
					var vsubv:Array = (p.getStructure(2)[0] as String).split(".");
					if (vapp is String && vsubv.length>1)
						getField( 0, 1 ).setCellInfo( vapp +" "+vsubv[1] );
					
					break;
				case CMD.RITM_LINK_ID:
					ritmLink.putData(p);
					break;
				case CMD.NAV_INFO:
					optNavInfo.putData(p);
					break;
				case CMD.GET_NET:
					if(!optLan) {
						globalY += 1;
						drawSeparator();
						globalY -= 10;
						optLan = new OptLanInfo(1);
						addChild( optLan );
						optLan.y = globalY;
						optLan.x = globalX;
						globalY += optLan.complexHeight - 10;
					}
					optLan.putData(p);
					break;
				case CMD.VPN_GET_INFO:
					if (!optVpn) {
						globalY -= 14;
						drawSeparator();
						globalY -= 10;
						optVpn = new OptVpn;
						addChild( optVpn );
						optVpn.y = globalY;
						optVpn.x = globalX;
						globalY += optVpn.complexHeight - 10;
						
						bRefresh = new TextButton;
						addChild( bRefresh );
						bRefresh.setUp( loc("g_update"), refresh );
						bRefresh.x = globalX;
						bRefresh.y = globalY;
					}
					optVpn.putData(p);
					
					var vinfo:Array = OPERATOR.dataModel.getData( CMD.VER_INFO )[0];
					getField( CMD.VER_INFO,1 ).setCellInfo( vinfo[0] );
					getField( CMD.VER_INFO,2 ).setCellInfo( vinfo[1] + " "+DS.getCommit() );
					RequestAssembler.getInstance().fireEvent( new Request(CMD.VER_INFO, put,0,null,0,0, 0xFC));
					loadComplete();
					break;
				case CMD.GSM_SIG_LEV:
					len = p.length;
					for( i=0; i<len; ++i ) {
						if( infos[i] != null && p.getStructure(i+1) is Array )
							infos[i].putState( p.getStructure(i+1) );
					}
					runTask(onTick, TaskManager.DELAY_2SEC );
					break;
			}
		}
		
		private function onTick():void
		{
			RequestAssembler.getInstance().fireEvent( new Request(CMD.GSM_SIG_LEV, put));
		}
	}
}