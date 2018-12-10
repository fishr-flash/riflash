package components.screens.opt
{
	import components.abstract.ClientArrays;
	import components.abstract.functions.loc;
	import components.basement.OptionsBlock;
	import components.gui.fields.FSCheckBox;
	import components.gui.fields.FSComboBox;
	import components.gui.fields.FSShadow;
	import components.gui.fields.FSSimple;
	import components.interfaces.IFormString;
	import components.protocol.Package;
	import components.static.CMD;
	import components.static.DS;
	
	public class OptSim extends OptionsBlock
	{
		public function OptSim(s:int, roaming:Boolean, onlyonesim:Boolean)
		{
			super();
			
			FLAG_SAVABLE = false;
			createUIElement( new FSComboBox, 0, onlyonesim == true ? "SIM "+loc("g_settings"):"SIM"+s+" "+loc("g_settings"), callDataFiller, 1, ClientArrays.aOperator );
			attuneElement( 200, 180, FSComboBox.F_COMBOBOX_NOTEDITABLE );
			FLAG_SAVABLE = true;
			
			structureID = s;
			operatingCMD = CMD.GPRS_SIM;
			
			if (!DS.isfam( DS.K5RT1 )&& !DS.isfam( DS.K5RT3 ))
				createUIElement( new FSSimple, operatingCMD, loc("ui_gprs_tel"),null,1,null,"",20);
			else
				addui( new FSShadow, operatingCMD, "", null, 1 );
			attuneElement( NaN,180 );
			createUIElement( new FSSimple, operatingCMD, loc("ui_gprs_access_point"),null,2,null,"",20);
			attuneElement( NaN,180 );
			createUIElement( new FSSimple, operatingCMD, loc("ui_gprs_username"),null,3,null,"",20);
			attuneElement( NaN,180 );
			createUIElement( new FSSimple, operatingCMD, loc("ui_gprs_pass"),null,4,null,"",20);
			attuneElement( NaN,180 );
			
			if (roaming) {
				createUIElement( new FSCheckBox, CMD.NO_GPRS_ROAMING, loc("ui_gprs_noroaming"), null, 1 );
				attuneElement( 368 );
			}
			
			complexHeight = globalY;
		}
		override public function putData(p:Package):void
		{
			distribute( p.getStructure(p.structure), p.cmd );
			if (p.cmd == operatingCMD)
				callDataAnalyzer();
		}
		public function renameTitle(ttl:String):void
		{
			getField(0,1).setName( ttl );
		}
		private function callDataFiller():void
		{
			if( int(getField(0,1).getCellInfo()) == 0 )
				callBlocker( false );
			else {
				callBlocker( true );
				distribute( ClientArrays.aOperatorConfigInfo[ (getField(0,1) as FSComboBox).getCellInfo() ], operatingCMD );
				remember( getField( operatingCMD, 1 ));
			}
		}
		private function callDataAnalyzer():void
		{
			var f1:IFormString  = getField( CMD.GPRS_SIM,1);
			var f2:IFormString  = getField( CMD.GPRS_SIM,2);
			var f3:IFormString  = getField( CMD.GPRS_SIM,3);
			var f4:IFormString  = getField( CMD.GPRS_SIM,4);
			
			var len:int = ClientArrays.aOperator.length;
			for(var i:int=1;i<len; ++i) {
				
				if( f1.getCellInfo() == ClientArrays.aOperatorConfigInfo[i][0] &&
					f2.getCellInfo() == ClientArrays.aOperatorConfigInfo[i][1] &&
					f3.getCellInfo() == ClientArrays.aOperatorConfigInfo[i][2] &&
					f4.getCellInfo() == ClientArrays.aOperatorConfigInfo[i][3] ) {
					
					getField( 0,1).setCellInfo(i);
					callBlocker( true );
					return;
				}
			}
			callBlocker( false );
			getField( 0,1).setCellInfo(0);
		}
		private function callBlocker(value:Boolean):void
		{
			getField( CMD.GPRS_SIM,1).disabled = value;
			getField( CMD.GPRS_SIM,2).disabled = value;
			getField( CMD.GPRS_SIM,3).disabled = value;
			getField( CMD.GPRS_SIM,4).disabled = value;
		}
	}
}