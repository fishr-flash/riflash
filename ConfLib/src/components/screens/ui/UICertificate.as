package components.screens.ui
{
	import components.abstract.functions.loc;
	import components.basement.UI_BaseComponent;
	import components.gui.fields.FSSimple;
	import components.gui.triggers.TextButton;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.static.CMD;
	
	public class UICertificate extends UI_BaseComponent
	{
		private var cert:Vector.<FSSimple>;
		private var bSend:TextButton;
		
		public function UICertificate()
		{
			super();
			
			addui( new FSSimple, CMD.CERTIFICATE_SAVE, loc("ui_cert_algorythm_type"), null, 1 );
			addui( new FSSimple, CMD.CERTIFICATE_SAVE, loc("ui_cert_size"), null, 2 );
			
			drawSeparator();
			
			addui( new FSSimple, CMD.CERTIFICATE_VERIFICATION, "IMEI", null, 1 );
			attuneElement( NaN, 500, FSSimple.F_CELL_SELECTABLE);
			addui( new FSSimple, CMD.CERTIFICATE_VERIFICATION, "CPU_ID", null, 2 );
			attuneElement( NaN, 500, FSSimple.F_CELL_SELECTABLE );
			addui( new FSSimple, CMD.CERTIFICATE_VERIFICATION, loc("ui_cert_algorythm_type"), null, 3 );
			attuneElement( NaN, NaN, FSSimple.F_CELL_SELECTABLE );
			addui( new FSSimple, CMD.CERTIFICATE_VERIFICATION, loc("ui_cert_size"), null, 4 );
			attuneElement( NaN, NaN, FSSimple.F_CELL_SELECTABLE );
			addui( new FSSimple, CMD.CERTIFICATE_VERIFICATION, loc("ui_cert_structs_amount_for_cert"), null, 5 );
			attuneElement( 300, NaN, FSSimple.F_CELL_SELECTABLE | FSSimple.F_MULTYLINE );
			
			drawSeparator();
			FLAG_SAVABLE = false;
			addui( new FSSimple, 0, loc("ui_cert_byte_sequence_delim")+" \",\"", null, 1 );
			attuneElement( 250, 300 );
			FLAG_SAVABLE = true;
			bSend = new TextButton;
			addChild( bSend );
			bSend.x = globalX;
			bSend.y = globalY;
			bSend.setUp( loc("ui_cert_write_bytes"), onByteChain );
			
			globalY += 30;
			
			drawSeparator();
			
			cert = new Vector.<FSSimple>;
			
			for (var i:int=0; i<512; ++i) {
				structureID = (i+1);
				cert.push( addui( new FSSimple, CMD.GET_CERTIFICATE, (i+1) + " "+loc("ui_cert_bytes_from_cert_buffer"), null, (i+1) ) );
				attuneElement(NaN, NaN, FSSimple.F_CELL_NOTSELECTABLE );
			}
			structureID = 1;
			drawSeparator();
			
			starterCMD = [CMD.CERTIFICATE_SAVE,	CMD.GET_CERTIFICATE, CMD.CERTIFICATE_VERIFICATION, ];
		}
		override public function put(p:Package):void
		{
			if (p.cmd == CMD.GET_CERTIFICATE) {
				for (var i:int=0; i<512; ++i) {
					cert[i].setCellInfo( p.getStructure(i+1)[0] );
				}
				loadComplete();
			} else
				distribute( p.getStructure(), p.cmd );
		}
		private function onByteChain():void
		{
			var a:Array = (getField(0,1).getCellInfo() as String).split(",");
			var len:int = a.length > 512 ? 512 : a.length ;
			for (var i:int=0; i<len; ++i) {
				RequestAssembler.getInstance().fireEvent( new Request( CMD.SET_CERTIFICATE, null, i+1, [int(a[i])] ));
			}
		}
	}
}