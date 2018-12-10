package components.screens.opt
{
	import components.abstract.RegExpCollection;
	import components.abstract.adapters.StringCutterAdapter;
	import components.abstract.functions.loc;
	import components.basement.OptionsBlock;
	import components.gui.fields.FSCheckBox;
	import components.gui.fields.FSShadow;
	import components.gui.fields.FSSimple;
	import components.gui.fields.FormString;
	import components.interfaces.IFormString;
	import components.protocol.Package;
	import components.protocol.statics.OPERATOR;
	import components.static.CMD;
	import components.system.SavePerformer;
	
	/**
	 *  Дубликат OptRSim специально созданный
	 * чтобы обойти баг с перепутанными симками
	 */
	public class OptRSimK9 extends OptionsBlock
	{
		private var fields:Vector.<FSSimple>;
		private var flens:Vector.<IFormString>;
		private var _fApnAuto:IFormString;
		private var selected:int;
		private var lastApnData:Array;
		private var refineOn:Boolean;
		private var putModeChkBox:int;
		
		public function get fApnAuto():IFormString
		{
			return _fApnAuto;
		}
		
		public function OptRSimK9(s:int, onlyonesim:Boolean = false, fakesim:Boolean = true)
		{
			super();
			
			
			
			fields = new Vector.<FSSimple>;
			flens = new Vector.<IFormString>;
			
			var fakes:int;
			if (onlyonesim)
				fakes = s;
			else
				fakes = s == 1?2:1;
			
			FLAG_SAVABLE = false;
			if (fakesim)
				createUIElement( new FormString, 1, loc("ui_gprs_simcard")+" "+fakes, null, 1);
			else
				createUIElement( new FormString, 1, loc("ui_gprs_simcard")+" "+s, null, 1);
			attuneElement( 200 );
			FLAG_SAVABLE = true;
			
			structureID = s; 
			
			_fApnAuto = addui( new FSCheckBox, CMD.GPRS_APN_AUTO, loc("ui_gprs_autoset_apn_setting"), null, 1 );
			_fApnAuto.visible = false;
			attuneElement( 308-40 );
			
			flens.push( addui( new FSShadow, CMD.K5_G_PHONE, "", null, 1 ) );
			flens.push( addui( new FSShadow, CMD.K5_G_APN, "", null, 1 ) );
			flens.push( addui( new FSShadow, CMD.K5_G_APN_LOG, "", null, 1 ) );
			flens.push( addui( new FSShadow, CMD.K5_G_APN_PASS, "", null, 1 ) );
			
			fields.push( addui( new FSSimple, CMD.K5_G_PHONE, loc("ui_gprs_tel"),null,2,null,"",15, new RegExp(RegExpCollection.REF_NOT_EMPTY)) as FSSimple );
			getLastElement().setAdapter( new StringCutterAdapter(getField(CMD.K5_G_PHONE,1)));
			attuneElement( NaN,180 );
			fields.push( addui( new FSSimple, CMD.K5_G_APN, loc("ui_gprs_access_point"),null,2,null,"",31,new RegExp(RegExpCollection.REF_NOT_EMPTY)) as FSSimple );
			getLastElement().setAdapter( new StringCutterAdapter(getField(CMD.K5_G_APN,1)));
			attuneElement( NaN,180 );
			fields.push( addui( new FSSimple, CMD.K5_G_APN_LOG, loc("ui_gprs_username"),null,2,null,"",15) as FSSimple );
			getLastElement().setAdapter( new StringCutterAdapter(getField(CMD.K5_G_APN_LOG,1)));
			attuneElement( NaN,180 );
			fields.push( addui( new FSSimple, CMD.K5_G_APN_PASS, loc("ui_gprs_pass"),null,2,null,"",15) as FSSimple );
			getLastElement().setAdapter( new StringCutterAdapter(getField(CMD.K5_G_APN_PASS,1)));
			attuneElement( NaN,180 );
			
			complexHeight = globalY;
			
			
			 
		}
		
		
		
		
		

		override public function putData(p:Package):void
		{
			
	//		getField(CMD.K5_G_PHONE,1).setName(loc("ui_gprs_tel"));
			if (p.cmd == CMD.GPRS_APN_SELECT) {
				selected = p.getStructure(structureID)[0];
				if (selected==0)
					lastApnData = null; 
				loadSelected();
				
			} else {
				
				if (p.cmd == CMD.GPRS_SIM && isApnWorking())
				{
					
					loadSelected();
				}
				else 
				{
					distribute( p.getStructure(p.structure), p.cmd );
				}
				
				
			}
			if (p.cmd == CMD.GPRS_APN_AUTO)
			{
				
				
				/// фолдит разделы если установлена галочка чекбокса
				onApn(null);
				
			}
			
			
		}
		override public function putRawData(a:Array):void
		{
	//		getField(CMD.K5_G_PHONE,1).setName(loc("ui_gprs_current_sim_operator"));
			lastApnData = a.slice();
			
			getField(CMD.K5_G_PHONE,1).setCellInfo(String(a[0]).length);
			getField(CMD.K5_G_PHONE,2).setCellInfo(a[0]);
			getField(CMD.K5_G_APN,1).setCellInfo(String(a[1]).length);
			getField(CMD.K5_G_APN,2).setCellInfo(a[1]);
			getField(CMD.K5_G_APN_LOG,1).setCellInfo(String(a[2]).length);
			getField(CMD.K5_G_APN_LOG,2).setCellInfo(a[2]);
			getField(CMD.K5_G_APN_PASS,1).setCellInfo(String(a[3]).length);
			getField(CMD.K5_G_APN_PASS,2).setCellInfo(a[3]);
		}
		
		public function changeStateChkBox( state:Object ):void
		{
			_fApnAuto.setCellInfo( state );
			
			remember( _fApnAuto );
		}
		
		
		
		private function callBlocker(value:Boolean):void
		{
			/*fields[0].disabled = value;
			fields[1].disabled = value;
			fields[2].disabled = value;
			fields[3].disabled = value;*/
			if (value) {
				fields[0].attune( FSSimple.F_CELL_NOTEDITABLE_NOTEDITBOX | FSSimple.F_CELL_BOLD);
				fields[0].setName( loc("ui_gprs_current_sim_operator_k9") );
				fields[0].visible = false;
				fields[1].visible = false;
				fields[2].visible = false;
				fields[3].visible = false;
			/*	fields[1].attune( FSSimple.F_CELL_NOTEDITABLE_NOTEDITBOX );
				fields[2].attune( FSSimple.F_CELL_NOTEDITABLE_NOTEDITBOX );
				fields[3].attune( FSSimple.F_CELL_NOTEDITABLE_NOTEDITBOX );*/
			} else {
				fields[0].setName( loc("ui_gprs_tel") );
				fields[0].attune( FSSimple.F_CELL_EDITABLE_EDITBOX | FSSimple.F_CELL_NO_BOLD);
				fields[0].visible = true;
				fields[1].visible = true;
				fields[2].visible = true;
				fields[3].visible = true;
				/*fields[1].attune( FSSimple.F_CELL_EDITABLE_EDITBOX );
				fields[2].attune( FSSimple.F_CELL_EDITABLE_EDITBOX );
				fields[3].attune( FSSimple.F_CELL_EDITABLE_EDITBOX );*/
			}
		}
		
		/**
		 * Скрывает поля по сигналу установки или снятия
		 * чекбокса
		 * 
		 */
		public function onApn(t:IFormString):void
		{
			
			if (t)
			{
				
				isAuto( t.getCellInfo() == 1);
			}
			else
			{
				var apndata:int = int( getField(CMD.GPRS_APN_AUTO,1).getCellInfo() );
				isAuto( apndata == 1 );
			}
			
				
		}
		private function isAuto(b:Boolean):void
		{
			callBlocker(b);
			
			if (b)
				loadSelected();
			else {
				distribute( OPERATOR.dataModel.getData(CMD.K5_G_PHONE)[structureID-1], CMD.K5_G_PHONE);
				distribute( OPERATOR.dataModel.getData(CMD.K5_G_APN)[structureID-1], CMD.K5_G_APN);
				distribute( OPERATOR.dataModel.getData(CMD.K5_G_APN_LOG)[structureID-1], CMD.K5_G_APN_LOG);
				distribute( OPERATOR.dataModel.getData(CMD.K5_G_APN_PASS)[structureID-1], CMD.K5_G_APN_PASS);
			}
		}
		private function loadSelected():void
		{
			if (lastApnData)
				putRawData(lastApnData);
		}
		private function isApnWorking():Boolean
		{
			return _fApnAuto.getCellInfo() == 1;
			
		}
	}
	
	
}
