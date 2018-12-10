package components.screens.opt
{
	import components.abstract.functions.loc;
	import components.basement.OptionsBlock;
	import components.gui.SimpleTextField;
	import components.protocol.Package;
	import components.static.CMD;
	import components.static.COLOR;
	
	public class OptCondIPRecorder extends OptionsBlock
	{

		private var alert:SimpleTextField;

		private var conditions:Array;
		public function OptCondIPRecorder( id:int )
		{
			super();
			
			
			
			init( id );
		}
		
		private function init(id:int):void
		{
			structureID = id;
			operatingCMD = CMD.GET_RECORD_CAM_STATE;
			
			const ww:int = 150;
			
			const sign:SimpleTextField = new SimpleTextField( loc( "of_the_camera" ) + " " + id, ww );
			addChildAtypical( sign );
			
			alert = new SimpleTextField( loc( "wire_state_unknwn" ), ww, COLOR.GREY_POPUP_OUTLINE );
			addChildAtypical( alert );
			
			conditions =
			[
				{ label:loc("his_disabled_f"), color: COLOR.RED_DARK },
				{ label:loc("cam_offrecord"), color: COLOR.YELLOW_SIGNAL },
				{ label:loc("cam_offrecord"), color: COLOR.YELLOW_SIGNAL },
				{ label:loc("cam_onrecord"), color: COLOR.GREEN_SIGNAL }
			];
			
		}
		
		override public function putData(p:Package):void 
		{
			const data:Array = p.getStructure( structureID );
			alert.text = conditions[ data[ 0 ] ][ "label" ];
			alert.textColor = conditions[ data[ 0 ] ][ "color" ];
			
		}
	}
}