package components.screens.ui
{
	import components.abstract.GroupOperator;
	import components.abstract.functions.loc;
	import components.basement.UI_BaseComponent;
	import components.gui.SimpleTextField;
	import components.gui.fields.FSRadioGroup;
	import components.gui.fields.FSShadow;
	import components.interfaces.IFormString;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.static.CMD;
	import components.static.DS;
	import components.system.SensorConst;
	
	public class UIConfig extends UI_BaseComponent
	{
		private var go:GroupOperator;
		private var anchor:int;
		private var fsRgroup:FSRadioGroup;
		private var fsAnimal:FSRadioGroup;
		private var fields:Vector.<IFormString>;
		
		public function UIConfig()
		{
			super();
			
			go = new GroupOperator;
			
			anchor = globalY;
			
			var title:SimpleTextField = new SimpleTextField(loc("wire_ext_configure"), 300 );
			addChild( title );
			title.setSimpleFormat("left", 0, 12, true );
			title.height = 250;
			title.width = 250;
			title.y = globalY;
			title.x = globalX;
			globalY += 30;
			go.add( "rdd", title );
			
			fsRgroup = new FSRadioGroup( [ {label:loc("wire_normal_closed"), selected:false, id:1 },
				{label:loc("wire_normal_opened"), selected:false, id:0 }], 1, 25 );
			fsRgroup.y = globalY;
			fsRgroup.x = globalX;
			fsRgroup.width = 250;
			fsRgroup.setAdapter( new DeviceDataAdapter ); 
			addChild( fsRgroup );
			addUIElement( fsRgroup, CMD.OP_ms_RDD1_ADDWIRE, 1);
			go.add( "rdd", fsRgroup );
			
			globalY = anchor;
			FLAG_SAVABLE = false;
			
			fsAnimal = new FSRadioGroup( [ {label:loc("sensor_without_anti_animal"), selected:false, id:0 },
				{label:loc("sensor_with_anti_animal"), selected:false, id:1 }], 1, 25 );
			fsAnimal.y = globalY;
			fsAnimal.x = globalX;
			fsAnimal.width = 250;
			fsAnimal.setAdapter( new DeviceDataAdapter ); 
			addChild( fsAnimal );
			fsAnimal.setUp( onChangeLimit );
			go.add( "rmd", fsAnimal );
			
			FLAG_SAVABLE = true;
			
			fields = new Vector.<IFormString>;
			fields.push( addui( new FSShadow, CMD.OP_pA_LIMIT, "", null, 1 ));
			fields.push( addui( new FSShadow, CMD.OP_pV_LIMIT, "", null, 1 ));
			fields.push( addui( new FSShadow, CMD.OP_pC_LIMIT, "", null, 1 ));
			fields.push( addui( new FSShadow, CMD.OP_pP_LIMIT, "", null, 1 ));
		}
		override public function open():void
		{
			super.open();
			
			var alias:String = DS.deviceAlias;
			switch(alias) {
				case SensorConst.TYPE_RDD1:
					RequestAssembler.getInstance().fireEvent( new Request(CMD.OP_ms_RDD1_ADDWIRE, put ));
					go.show("rdd");
					break;
				case SensorConst.TYPE_RMD:
					RequestAssembler.getInstance().fireEvent( new Request(CMD.OP_pAVCP_LIMITS, put ));
					go.show("rmd");
					break;
			}
		}
		override public function put(p:Package):void
		{
			switch(p.cmd) {
				case CMD.OP_ms_RDD1_ADDWIRE:
					var msg:String = String(p.getValidStructure()[0]).replace(/\r?\n?/,"");
					fsRgroup.setCellInfo( int(String(p.getValidStructure()[0]).replace(/\r?\n?/,"")) > 0 ? 1:0 );
					break;
				case CMD.OP_pAVCP_LIMITS:
					
					var s:String = String(p.getValidStructure()[0]).replace(/\r?\n?/g,"");
					if( String(p.getValidStructure()[0]).replace(/\r?\n?/g,"") == "1114061E03" )
						fsAnimal.setCellInfo(1);
					else
						fsAnimal.setCellInfo(0);
					break;
			}
			loadComplete();
		}
		private function onChangeLimit():void
		{
		/*	pic_cat.visible = !pic_cat.visible;
			pic_nocat.visible = !pic_nocat.visible;
			*/
			if (int(fsAnimal.getCellInfo())==1) {
				fields[0].setCellInfo( "06" );
				fields[1].setCellInfo( "07" );
				fields[2].setCellInfo( "0614" );
				fields[3].setCellInfo( "03" );
			} else {
				fields[0].setCellInfo( "11" );
				fields[1].setCellInfo( "14" );
				fields[2].setCellInfo( "061E" );
				fields[3].setCellInfo( "03" );
			}
				
			remember( fields[0] );
			remember( fields[1] );
			remember( fields[2] );
			remember( fields[3] );
		}
	}
}
import components.interfaces.IDataAdapter;
import components.interfaces.IFormString;

class DeviceDataAdapter implements IDataAdapter
{
	public function adapt(value:Object):Object
	{
		return null;
	}
	public function change(value:Object):Object
	{
		return null;
	}
	public function perform(field:IFormString):void
	{
	}
	public function recover(value:Object):Object
	{
		var s:String = String(value);
		while ( s.length < 2)
			s = "0"+s;
		return s;
	}
}