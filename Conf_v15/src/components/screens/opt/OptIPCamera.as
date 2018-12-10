package components.screens.opt
{
	import components.abstract.RegExpCollection;
	import components.abstract.functions.loc;
	import components.basement.OptionsBlock;
	import components.gui.fields.FSCheckBox;
	import components.gui.fields.FSShadow;
	import components.gui.fields.FSSimple;
	import components.interfaces.IFormString;
	import components.protocol.Package;
	import components.static.CMD;
	
	public class OptIPCamera extends OptionsBlock
	{

		private var _portIp:FSSimple;

		private var onCheck:Boolean;
		
		public function get portIp():FSSimple
		{
			return _portIp;
		}
		
		public function set portIp(value:FSSimple):void
		{
			_portIp = value;
		}
		
		public function OptIPCamera( struct:int )
		{
			super();
			
			
			structureID = struct;
			operatingCMD = CMD.VIDEO_IP_CAM_SETTINGS;
			
			init();
		}
		
		

		private function init():void
		{
			const widthTitle:int = 100;
			const widthCell:int = 400;
			const chk:FSCheckBox = addui( new FSCheckBox(), operatingCMD, loc( "cam_cam" ) + " " + structureID, null, 1 ) as FSCheckBox;
			attuneElement( 100, 20 );
			
			FLAG_SAVABLE = false;
			globalX = chk.x + chk.width + 40;
			const urlField:FSSimple = addui( new FSSimple(), 0, loc( "sw_ipcams" ), delegateMerge, 1, null, "", 127 ) as FSSimple;
			attuneElement( widthTitle, widthCell );
			urlField.y = chk.y;
			globalY -= urlField.height;
			
			addui( new FSSimple(), 0, loc( "rtsp" ), delegateMerge, 2, null, "", 127 );
			attuneElement( widthTitle, widthCell );
			
			addui( new FSSimple(), 0, loc( "rtsp" ) + " II", delegateMerge, 3, null, "", 127 );
			attuneElement( widthTitle, widthCell );
			
			addui( new FSSimple(), 0, loc( "mjpeg" ), delegateMerge, 4, null, "", 127 );
			attuneElement( widthTitle, widthCell );
			FLAG_SAVABLE = true;
			
			
			addui( new FSShadow(), operatingCMD, "", null, 2, null, "", 63 );
			addui( new FSShadow(), operatingCMD, "", null, 3, null, "", 63 );

			addui( new FSShadow(), operatingCMD, "", null, 4, null, "", 63 );
			addui( new FSShadow(), operatingCMD, "", null, 5, null, "", 63 );

			addui( new FSShadow(), operatingCMD, "", null, 6, null, "", 63 );
			addui( new FSShadow(), operatingCMD, "", null, 7, null, "", 63 );

			addui( new FSShadow(), operatingCMD, "", null, 8, null, "", 63 );
			addui( new FSShadow(), operatingCMD, "", null, 9, null, "", 63 );

			addui( new FSSimple, operatingCMD, loc( "g_port" ), delegateChkPort, 10, null, "0-9", 5 );
			attuneElement( widthTitle * .7, 80 );
			getLastElement().x = 512;
			
		}
		
		private function delegateChkPort( ifield:IFormString):void
		{
			if( !getField( operatingCMD, 1 ).disabled )onCheck = getField( operatingCMD, 1 ).getCellInfo() == true;
			
			if( !getField( operatingCMD, 10 ).getCellInfo() )
			{
				getField( operatingCMD, 1 ).setCellInfo( 0 );
				getField( operatingCMD, 1 ).disabled = true;
			}
			else if( getField( 0, 1 ).getCellInfo() != "" )
			{
				
					
				getField( operatingCMD, 1 ).disabled = false;
				if( onCheck )getField( operatingCMD, 1 ).setCellInfo( 1 );
				remember( ifield );
			}
			
			delegateMerge();
			
		}
		
		private function delegateMerge( ):void
		{
			if( !getField( operatingCMD, 1 ).disabled )onCheck = getField( operatingCMD, 1 ).getCellInfo() == true;
			
			var mergef1:IFormString;
			var mergef2:IFormString;
			for (var i:int=1; i < 5; i++) 
			{
				const value:String = getField( 0, i ).getCellInfo() as String;
				
				if( value.length )
				{
					mergef1 = getField( operatingCMD, i*2 );
					mergef2 = getField( operatingCMD, ( i*2 ) + 1 );
					
					
					
					mergef1.setCellInfo( value.slice( 0, 63 ) );
					mergef2.setCellInfo( value.slice( 63 ) );
					
					remember( mergef1 );
					remember( mergef2 );
				}
				
				
				
				
			}
			
			if( !String( getField( 0, 1 ).getCellInfo()).match( new RegExp( RegExpCollection.COMPLETE_ATLEST8SYMBOL ) )  )
			{
				getField( operatingCMD, 1 ).setCellInfo( 0 );
				getField( operatingCMD, 1 ).disabled = true;
			}
			else if( getField( operatingCMD, 10 ).getCellInfo() != 0 ) 
			{
				
				
				getField( operatingCMD, 1 ).disabled = false;
				if( onCheck )getField( operatingCMD, 1 ).setCellInfo( 1 );
			}
			
			
		}		
		
		
		override public function putData(p:Package):void
		{
			
			getField( operatingCMD, 1 ).setCellInfo( p.data[ structureID - 1 ][ 0 ] );
			getField( 0, 1 ).setCellInfo( p.data[ structureID - 1 ][ 1 ] +  p.data[ structureID - 1 ][ 2 ] );
			getField( 0, 2 ).setCellInfo( p.data[ structureID - 1 ][ 3 ] +  p.data[ structureID - 1 ][ 4 ] );
			getField( 0, 3 ).setCellInfo( p.data[ structureID - 1 ][ 5 ] +  p.data[ structureID - 1 ][ 6 ] );
			getField( 0, 4 ).setCellInfo( p.data[ structureID - 1 ][ 7 ] +  p.data[ structureID - 1 ][ 8 ] );

			getField( operatingCMD, 10 ).setCellInfo( p.data[ structureID - 1 ][ 9 ] );
			
		}
		
		
		
		
	}
}