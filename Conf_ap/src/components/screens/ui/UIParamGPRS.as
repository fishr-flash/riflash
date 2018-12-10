package components.screens.ui
{
	import components.abstract.RegExpCollection;
	import components.abstract.functions.loc;
	import components.basement.UI_BaseComponent;
	import components.gui.fields.FSCheckBox;
	import components.gui.fields.FSComboBox;
	import components.gui.fields.FSSimple;
	import components.gui.fields.FormString;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.screens.opt.OptGprsServer;
	import components.static.CMD;
	import components.system.UTIL;
	
	public class UIParamGPRS extends UI_BaseComponent
	{
		private var opt1:OptGprsServer;
		private var opt2:OptGprsServer;
		private var opth:OptGprsHeader;
		
		public function UIParamGPRS()
		{
			super();
			
			var fshift:int = 250;
			var fwidth:int = 250;
			
			opth = new OptGprsHeader;
			addChild( opth );
			opth.y = globalY;
			opth.x = globalX;
			globalY += opth.complexHeight;
			
			//drawSeparator();
			
			addui( new FormString, 0, loc("gprs_main_ip"), null, 1 );
			attuneElement( 600, NaN, FormString.F_TEXT_BOLD );
			
			opt1 = new OptGprsServer(2);
			addChild( opt1 );
			opt1.y = globalY;
			opt1.x = globalX;
			globalY += opt1.complexHeight;
			
			drawSeparator();
			
			addui( new FormString, 0, loc("gprs_backup_ip"), null, 1 );
			attuneElement( 600, NaN, FormString.F_TEXT_BOLD );
			
			opt2 = new OptGprsServer(1);
			addChild( opt2 );
			opt2.y = globalY;
			opt2.x = globalX;
			globalY += opt2.complexHeight;
			
			drawSeparator();
			
			structureID = 2;
			
			addui( new FSSimple, CMD.OP_GC_GPRS_NUM, loc("ui_gprs_tel"), null, 1, null, "WwPpTt*#|0-9", 16, new RegExp("^"+RegExpCollection.RE_TEL_PROVOD_K1+"$") );
			attuneElement( fshift, fwidth );
			addui( new FSSimple, CMD.OP_GN_GPRS_APN, loc("ui_gprs_access_point"), null, 1, null, "", 32/*, new RegExp("^"+ RegExpCollection.RE_IP_ADDRESS+"|"+RegExpCollection.RE_DOMEN+"$")*/ );
			attuneElement( fshift, fwidth );
			addui( new FSSimple, CMD.OP_GU_GPRS_APN_USER, loc("ui_gprs_username"), null, 1, null, "", 16 );
			attuneElement( fshift, fwidth );
			addui( new FSSimple, CMD.OP_GP_GPRS_APN_PASS, loc("ui_gprs_pass"), null, 1, null, "", 16  );
			attuneElement( fshift, fwidth );
			
			width = 570;
			height = 590;
		}
		override public function open():void
		{
			super.open();
			
			RequestAssembler.getInstance().fireEvent( new Request( CMD.OP_GC_GPRS_NUM, put, 2 ) );
			RequestAssembler.getInstance().fireEvent( new Request( CMD.OP_GN_GPRS_APN, put, 2 ) );
			RequestAssembler.getInstance().fireEvent( new Request( CMD.OP_GU_GPRS_APN_USER, put, 2 ) );
			RequestAssembler.getInstance().fireEvent( new Request( CMD.OP_GP_GPRS_APN_PASS, put, 2 ) );
			RequestAssembler.getInstance().fireEvent( new Request( CMD.OP_GS_SERVER_ADR, put, 1 ) );
			RequestAssembler.getInstance().fireEvent( new Request( CMD.OP_GG_SERVER_PORT, put, 1 ) );
			RequestAssembler.getInstance().fireEvent( new Request( CMD.OP_GI_SERVER_PASS, put, 1 ) );
			RequestAssembler.getInstance().fireEvent( new Request( CMD.OP_GS_SERVER_ADR, put, 2 ) );
			RequestAssembler.getInstance().fireEvent( new Request( CMD.OP_GG_SERVER_PORT, put, 2 ) );
			RequestAssembler.getInstance().fireEvent( new Request( CMD.OP_GI_SERVER_PASS, put, 2 ) ); 
			RequestAssembler.getInstance().fireEvent( new Request( CMD.OP_GT_GRPS_TRY, put ) );
			RequestAssembler.getInstance().fireEvent( new Request( CMD.OP_P_GPRS_COMPR, put ) );
		}
		override public function put(p:Package):void
		{
			switch(p.cmd) {
				case CMD.OP_GS_SERVER_ADR:
				case CMD.OP_GG_SERVER_PORT:
				case CMD.OP_GI_SERVER_PASS:
					if (p.structure == 1 ) {
						opt2.putData(p);
					} else
						opt1.putData(p);
						
					break;
				case CMD.OP_P_GPRS_COMPR:
					loadComplete();
				case CMD.OP_GT_GRPS_TRY:
					opth.putData(p);
					break;
				case CMD.OP_GC_GPRS_NUM:
				case CMD.OP_GN_GPRS_APN:
				case CMD.OP_GU_GPRS_APN_USER:
				case CMD.OP_GP_GPRS_APN_PASS:
					distribute( p.getStructure(2), p.cmd );
					break;
				default:
					distribute( p.getStructure(), p.cmd );
					break;
			}
		}
	}
}
import components.abstract.functions.loc;
import components.basement.OptionsBlock;
import components.gui.fields.FSCheckBox;
import components.gui.fields.FSComboBox;
import components.protocol.Package;
import components.static.CMD;
import components.system.UTIL;

class OptGprsHeader extends OptionsBlock
{
	public function OptGprsHeader()
	{
		super();
		
		var fshift:int = 250;
		var fwidth:int = 250;
		
		var list:Array = UTIL.getComboBoxList( [
			["0100","1 "+loc("time_min1_full")],["0200","2 "+loc("time_min2_full")],["0300" ,"3 "+loc("time_min2_full")],["0400","4 "+loc("time_min2_full")],["0500","5 "+loc("time_mins_full")],
			["0600","6 "+loc("time_mins_full")],["0700","7 "+loc("time_mins_full")],["0800","8 "+loc("time_mins_full")],["0900","8 "+loc("time_mins_full")], ["1000","10 "+loc("time_mins_full")]] );
		addui( new FSComboBox, CMD.OP_GT_GRPS_TRY, loc("gprs_delay_between_try"), null, 1, list );
		attuneElement( 250, NaN, FSComboBox.F_COMBOBOX_NOTEDITABLE | FSComboBox.F_MULTYLINE );
		addui( new FSCheckBox, CMD.OP_P_GPRS_COMPR, loc("ui_gprs_compr_mode"), null, 1 );
		attuneElement( 250 );
		
		complexHeight = globalY;
	}
	override public function putData(p:Package):void
	{
		pdistribute(p);
	}
}