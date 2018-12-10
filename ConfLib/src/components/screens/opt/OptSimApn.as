package components.screens.opt
{
	import components.abstract.ClientArrays;
	import components.abstract.functions.loc;
	import components.basement.OptionsBlock;
	import components.gui.fields.FSCheckBox;
	import components.gui.fields.FSComboBox;
	import components.gui.fields.FSSimple;
	import components.gui.fields.FormString;
	import components.interfaces.IFormString;
	import components.protocol.Package;
	import components.protocol.statics.OPERATOR;
	import components.static.CMD;
	
	public class OptSimApn extends OptionsBlock
	{
		private var selected:int;
		private var fApnAuto:IFormString;
		
		public function OptSimApn(s:int, roaming:Boolean, onlyonesim:Boolean)
		{
			super();
			
			FLAG_SAVABLE = false;
			createUIElement( new FormString, 0, onlyonesim == true ? loc("ui_gprs_simcard"):loc("ui_gprs_simcard")+" "+s, null, 1 );
			attuneElement( 180, NaN, FormString.F_NOTSELECTABLE );
			FLAG_SAVABLE = true;
			
			structureID = s;
			operatingCMD = CMD.GPRS_SIM;

			fApnAuto = addui( new FSCheckBox, CMD.GPRS_APN_AUTO, loc("ui_gprs_autoset_apn_setting"), onApn, 1 );
			attuneElement( 408+80 );
			
			
			
			createUIElement( new FSSimple, operatingCMD, loc("ui_gprs_tel"),null,1,null,"", OPERATOR.getSchema( operatingCMD ).Parameters[ 0 ].Length);
			attuneElement( 240,350 );
			createUIElement( new FSSimple, operatingCMD, loc("ui_gprs_access_point"),null,2,null,"", OPERATOR.getSchema( operatingCMD ).Parameters[ 1 ].Length );
			attuneElement( 240,350 );
			createUIElement( new FSSimple, operatingCMD, loc("ui_gprs_username"),null,3,null,"", OPERATOR.getSchema( operatingCMD ).Parameters[ 2 ].Length);
			attuneElement( 240,350 );
			createUIElement( new FSSimple, operatingCMD, loc("ui_gprs_pass"),null,4,null,"", OPERATOR.getSchema( operatingCMD ).Parameters[ 3 ].Length);
			attuneElement( 240,350 );
			
			if (roaming) {
				createUIElement( new FSCheckBox, CMD.NO_GPRS_ROAMING, loc("ui_gprs_noroaming"), null, 1 );
				attuneElement( 408+80 );
			}
			
			complexHeight = globalY;
		}
		private function isAuto(b:Boolean):void
		{
			callBlocker(b);
			if (b)
				loadSelected();
			else
				distribute( OPERATOR.dataModel.getData(CMD.GPRS_SIM)[structureID-1], CMD.GPRS_SIM);
		}
		public function putRoaming(n:int):void
		{
			getField(CMD.NO_GPRS_ROAMING,1).setCellInfo(n);
		}
		override public function putData(p:Package):void
		{
			if (p.cmd == CMD.GPRS_APN_SELECT) {
				selected = p.getStructure(structureID)[0];
				loadSelected();
			} else {
				if (p.cmd == CMD.GPRS_SIM && isApnWorking())
					loadSelected();
				else
					distribute( p.getStructure(p.structure), p.cmd );
			}
			if (p.cmd == CMD.GPRS_APN_AUTO)
				onApn(null);
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
		private function callBlocker(value:Boolean):void
		{
			if (value) {
				(getField(operatingCMD,1) as FSSimple).attune( FSSimple.F_CELL_NOTEDITABLE_NOTEDITBOX | FSSimple.F_CELL_BOLD);
				(getField(operatingCMD,1) as FSSimple).setName( loc("ui_gprs_current_sim_operator") );
				(getField(operatingCMD,2) as FSSimple).attune( FSSimple.F_CELL_NOTEDITABLE_NOTEDITBOX );
				(getField(operatingCMD,3) as FSSimple).attune( FSSimple.F_CELL_NOTEDITABLE_NOTEDITBOX );
				(getField(operatingCMD,4) as FSSimple).attune( FSSimple.F_CELL_NOTEDITABLE_NOTEDITBOX );
			} else {
				(getField(operatingCMD,1) as FSSimple).setName( loc("ui_gprs_tel") );
				(getField(operatingCMD,1) as FSSimple).attune( FSSimple.F_CELL_EDITABLE_EDITBOX | FSSimple.F_CELL_NO_BOLD);
				(getField(operatingCMD,2) as FSSimple).attune( FSSimple.F_CELL_EDITABLE_EDITBOX );
				(getField(operatingCMD,3) as FSSimple).attune( FSSimple.F_CELL_EDITABLE_EDITBOX );
				(getField(operatingCMD,4) as FSSimple).attune( FSSimple.F_CELL_EDITABLE_EDITBOX );
			}
		}
		private function loadSelected():void
		{
			if (isApnWorking()) {
				
				var p:Object = {
					"OPERATOR.getSchema(CMD.GPRS_APN_BASE).StructCount":OPERATOR.getSchema(CMD.GPRS_APN_BASE).StructCount,
					"OPERATOR.dataModel.getData( CMD.GPRS_APN_BASE )":OPERATOR.dataModel.getData( CMD.GPRS_APN_BASE )
				}
				
				if (selected == 0)
					distribute( [loc("ui_gprs_operator_not_defined")," ","",""], CMD.GPRS_SIM );
				else if (selected == 0xff)
					distribute( [loc("ui_gprs_sim_not_set"),"","",""], CMD.GPRS_SIM );
				else if ( selected <= OPERATOR.getSchema(CMD.GPRS_APN_BASE).StructCount && OPERATOR.dataModel.getData( CMD.GPRS_APN_BASE ) ) {
					var baseitem:Array = OPERATOR.dataModel.getData( CMD.GPRS_APN_BASE )[selected-1];
					distribute( baseitem.slice(1), CMD.GPRS_SIM );
					(getField(operatingCMD,1) as FSSimple).attune( FSSimple.F_NOTSELECTABLE | FSSimple.F_CELL_BOLD );
					getField( CMD.GPRS_SIM,1).disabled = false;
				}
			}
		}
		private function onApn(t:IFormString):void
		{
			var apndata:int = int( getField(CMD.GPRS_APN_AUTO,1).getCellInfo() );
			isAuto(apndata == 1);
			if (t)
				remember(t);
		}
		private function isApnWorking():Boolean
		{
			return fApnAuto.getCellInfo() == 1;
		}
	}
}