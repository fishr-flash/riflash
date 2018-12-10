package components.screens.opt
{
	import flash.display.Sprite;
	
	import mx.controls.ProgressBar;
	import mx.controls.ProgressBarLabelPlacement;
	
	import components.abstract.RegExpCollection;
	import components.abstract.functions.loc;
	import components.basement.OptionListBlock;
	import components.gui.fields.FSComboBox;
	import components.gui.fields.FSShadow;
	import components.gui.fields.FormEmpty;
	import components.gui.fields.FormString;
	import components.interfaces.IFormString;
	import components.static.CMD;
	import components.system.SavePerformer;
	
	public class OptNotify extends OptionListBlock
	{
		private var pBar:ProgressBar;
		private var f2:FormEmpty;
		private var f3:FormEmpty;
		private var f4:FormEmpty;
		private var f5:FormEmpty;
		private var f6:FormEmpty;
		
		private var block:Sprite;
		
		public function OptNotify(s:int)
		{
			super();
			
			structureID = s;
			operatingCMD = CMD.NOTIF_K2;
			FLAG_VERTICAL_PLACEMENT = false;
			
			FLAG_SAVABLE = false;
			createUIElement( new FormString, 0, s.toString(),null,1);
			globalX += 30;
			FLAG_SAVABLE = true;
			
			createUIElement( new FSShadow, operatingCMD, "1", null, 1 );
			
			f2 = createUIElement( new FormString, operatingCMD, "", null, 2, null, "0-9+",20, new RegExp( "^"+RegExpCollection.RE_TEL+"$"));
			attuneElement(170,NaN,FormString.F_EDITABLE );
			globalX += 175;
			f3 = createUIElement( new FormString, operatingCMD, "", null, 3, null, "",30 );
			attuneElement(270,NaN,FormString.F_EDITABLE );
			globalX += 275;
			
			f4 = createUIElement( new FSComboBox, operatingCMD, "", null, 4, [{label:loc("notify_disabled"),data:0x00},{label:loc("his_sms"),data:0x01}] );
			attuneElement( 95, NaN, FSComboBox.F_COMBOBOX_NOTEDITABLE );
			globalX += 100;
			
			var list:Array = [{label:loc("notify_disabled"),data:0x00},{label:loc("his_sms"),data:0x01},{label:loc("notify_phone_call"),data:0x02},{label:loc("notify_phone_call")+ " + " +loc("his_sms"),data:0x03}];
			f5 = createUIElement( new FSComboBox, operatingCMD, "", callLogic, 5, list );
			attuneElement( 190, NaN, FSComboBox.F_COMBOBOX_NOTEDITABLE );
			globalX += 195;
			
			list = [{label:loc("notify_try_unlimited"),data:0x00},{label:"5",data:5},{label:"10",data:10},{label:"100",data:100}];
			f6 = createUIElement( new FSComboBox, operatingCMD, "", null, 6, list,"0-9", 3, new RegExp( RegExpCollection.REF_0to255 ) );
			attuneElement( 75 );
			
			SELECTION_X_SHIFT = 0;
			SELECTION_Y_SHIFT = -1;
			drawSelection( 851 );
			
			block = new Sprite;
			addChild( block );
			block.graphics.beginFill( 0xffffff );
			block.graphics.drawRect(-10,0,833,23);
			block.graphics.endFill();
			block.visible = false;
			
			pBar = new ProgressBar;
			addChild( pBar );
			pBar.y = 0;
			pBar.x = 10;
			pBar.width = 500;
			pBar.height = 25;
			pBar.label = loc("notify_phone_add_inprogress");
			pBar.visible = false;
			pBar.maximum = 100;
			pBar.minimum = 0;
			pBar.enabled = true;
			pBar.indeterminate = true;
			pBar.labelPlacement = ProgressBarLabelPlacement.LEFT;
		}
		override public function putRawData(data:Array):void
		{
			distribute( data, operatingCMD );
			block.visible = false;
			pBar.visible = false;
			callLogic();
			SavePerformer.validate();
		}
		override public function call(value:Object, param:int):Boolean
		{
			if (param == structureID) {
				block.visible = true;
				pBar.visible = true;
			}
			return true;
		}
		private function callLogic(t:IFormString=null):void
		{
			var num:int = int(f5.getCellInfo());
			if (num == 2 || num == 3) {
				f6.disabled = false;
			} else {
				f6.disabled = true;
				if(t)
					f6.setCellInfo(2);
			}
			if(t)
				SavePerformer.remember(getStructure(),t);
		}
	}
}