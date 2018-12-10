package components.screens.ui
{
	import components.abstract.RegExpCollection;
	import components.abstract.functions.loc;
	import components.basement.UI_BaseComponent;
	import components.events.GUIEventDispatcher;
	import components.events.GUIEvents;
	import components.gui.Header;
	import components.gui.SimpleTextField;
	import components.gui.fields.FSCheckBox;
	import components.gui.fields.FSRadioGroup;
	import components.gui.fields.FSRadioGroupH;
	import components.gui.fields.FSSimple;
	import components.gui.visual.Separator;
	import components.interfaces.IFormString;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.screens.opt.OptLinkChannel;
	import components.static.CMD;
	import components.static.PAGE;
	import components.system.CONST;
	import components.system.Controller;
	import components.system.Library;
	import components.system.SavePerformer;
	import components.system.UTIL;
	
	public class UILinkChannels extends UI_BaseComponent
	{
		private var oGroup:Object; // Группа объектов радиобуттонов
		private var oArrows:Object;
		
		private var groups:Array;
		
		public function UILinkChannels()
		{
			super();
			
			aItems = new Array;
			
			addui( new FSCheckBox, CMD.OP_GA_LINK_CHANNEL_ONLINE, loc("ui_linkch_gprs_online"), null, 1 );
			
			var opt:OptLinkChannel;
			
			var header:Header = new Header( [{label:loc("ui_linkch_comm_channel"), width:1500, xpos:80},{label:loc("ui_linkch_pcn_phone"), width:200, xpos:320} ] );
			addChild( header );
			header.x = PAGE.CONTENT_LEFT_SHIFT + 50;
			header.y = 40;
			
			oGroup = new Object;
			oArrows = new Object;
			
			for( var i:int; i<CONST.LINK_CHANNELS_NUM; ++i ) {
				if (i>0) {
					oGroup[ UTIL.hash_0To1(i) ] = new FSRadioGroupH( [{label:loc("ui_linkch_and"), selected:true, id:0x01},{label:loc("ui_linkch_or"), selected:false, id:0x02}],i );
					addChild( (oGroup[ UTIL.hash_0To1(i) ] as FSRadioGroupH) );
					(oGroup[ UTIL.hash_0To1(i) ] as FSRadioGroupH).setUp( links );
					(oGroup[ UTIL.hash_0To1(i) ] as FSRadioGroupH).switchFormat( FSRadioGroupH.F_RADIO_RETURNS_OBJECT );
					(oGroup[ UTIL.hash_0To1(i) ] as FSRadioGroupH).x = 42 + 50 + 72;
					(oGroup[ UTIL.hash_0To1(i) ] as FSRadioGroupH).y = opt.y +34
					
					oArrows[ UTIL.hash_0To1(i) ] = new Library.cLinkArrow;
					addChild( oArrows[ UTIL.hash_0To1(i) ] );
					oArrows[ UTIL.hash_0To1(i) ].x = 12;
					oArrows[ UTIL.hash_0To1(i) ].visible = false;
					oArrows[ UTIL.hash_0To1(i) ].y = opt.y + 8;
				}
				opt = new OptLinkChannel( UTIL.hash_0To1(i) );
				addChild( opt );
				opt.y = (opt.getHeight()+25)*i+50 + 30;
				opt.x = PAGE.CONTENT_LEFT_SHIFT + 10;
				aItems[ UTIL.hash_0To1(i) ] = opt;
			}
			
			var sep1:Separator = new Separator( 910 );
			sep1.x = 10;
			sep1.y = opt.y  + opt.getHeight()+ 25;
			addChild( sep1 );
			
			globalY = sep1.y +20;
			
			var fsRgroup:FSRadioGroup = new FSRadioGroup( [ {label:loc("ui_linkch_stay_one_dir"), selected:false, id:0x01 },
				{label:loc("ui_linkch_go_next_dir"), selected:false, id:0x00 }], 1, 30 );
			fsRgroup.y = globalY;
			fsRgroup.x = PAGE.CONTENT_LEFT_SHIFT;
			fsRgroup.width = 700;
			addChild( fsRgroup );
			addUIElement( fsRgroup, CMD.OP_DO_CH_DIRECTION_TYPE, 1);
			
			globalY = fsRgroup.y + fsRgroup.getHeight()-7;
			globalY += 20;
			var stxt:SimpleTextField = new SimpleTextField( loc("ui_linkch_supposed_to_delete_history"), 900 );
			addChild( stxt );
			stxt.x = PAGE.CONTENT_LEFT_SHIFT;
			stxt.y = globalY;
			globalY += 25;
			
			stxt = new SimpleTextField( loc("ui_linkch_channel_desc_1"), 900 );
			addChild( stxt );
			stxt.x = PAGE.CONTENT_LEFT_SHIFT;
			stxt.y = globalY;
			globalY += 25;
			
			stxt = new SimpleTextField( loc("ui_linkch_channel_desc_2"), 900 );
			addChild( stxt );
			stxt.x = PAGE.CONTENT_LEFT_SHIFT;
			stxt.y = globalY;
			globalY += 25;
			
			drawSeparator(910);
			globalY-=8;
			
			addui( new FSSimple, CMD.OP_digt_TIME_DIGIT_CALL, loc("ui_linkch_response_waiting_time"), null, 1,
				null,"0-9",3, new RegExp(RegExpCollection.REF_5to120) ); 
			attuneElement( 500+152, 60, FSSimple.F_MULTYLINE );
			getLastElement().setAdapter(new HexAdapter);
			width = 960;
			height = 740;
		}
		override public function open():void
		{
			super.open();
			//LOADING = true;
			Controller.getInstance().changeLabel(loc("ui_linkch_attention_unsave"));
			
			RequestAssembler.getInstance().fireEvent( new Request( CMD.OP_h_CH_TEL, put, 1) );
			RequestAssembler.getInstance().fireEvent( new Request( CMD.OP_h_CH_TEL, put, 2) );
			RequestAssembler.getInstance().fireEvent( new Request( CMD.OP_h_CH_TEL, put, 3) );
			RequestAssembler.getInstance().fireEvent( new Request( CMD.OP_h_CH_TEL, put, 4) );
			RequestAssembler.getInstance().fireEvent( new Request( CMD.OP_h_CH_TEL, put, 5) );
			RequestAssembler.getInstance().fireEvent( new Request( CMD.OP_h_CH_TEL, put, 6) );
			RequestAssembler.getInstance().fireEvent( new Request( CMD.OP_h_CH_TEL, put, 7) );
			RequestAssembler.getInstance().fireEvent( new Request( CMD.OP_h_CH_TEL, put, 8) );

			RequestAssembler.getInstance().fireEvent( new Request( CMD.OP_digt_TIME_DIGIT_CALL, put) );
			RequestAssembler.getInstance().fireEvent( new Request( CMD.OP_GA_LINK_CHANNEL_ONLINE, put) );
			RequestAssembler.getInstance().fireEvent( new Request( CMD.OP_DO_CH_DIRECTION_TYPE, put) );
			
			RequestAssembler.getInstance().fireEvent( new Request( CMD.OP_AND_CH_COM_LINK, put, 1) );
			RequestAssembler.getInstance().fireEvent( new Request( CMD.OP_AND_CH_COM_LINK, put, 2) );
			RequestAssembler.getInstance().fireEvent( new Request( CMD.OP_AND_CH_COM_LINK, put, 3) );
			RequestAssembler.getInstance().fireEvent( new Request( CMD.OP_AND_CH_COM_LINK, put, 4) );
			RequestAssembler.getInstance().fireEvent( new Request( CMD.OP_AND_CH_COM_LINK, put, 5) );
			RequestAssembler.getInstance().fireEvent( new Request( CMD.OP_AND_CH_COM_LINK, put, 6) );
			RequestAssembler.getInstance().fireEvent( new Request( CMD.OP_AND_CH_COM_LINK, put, 7) );
			RequestAssembler.getInstance().fireEvent( new Request( CMD.OP_AND_CH_COM_LINK, put, 8) );
			
			RequestAssembler.getInstance().fireEvent( new Request( CMD.OP_D_LINK_CHANNEL, put) );
			
			GUIEventDispatcher.getInstance().addEventListener( GUIEvents.onGPRSOnline, chChanged );
			SavePerformer.trigger({"after":after});
		}
		override public function close():void
		{
			super.close();
			Controller.getInstance().changeLabel();
			GUIEventDispatcher.getInstance().removeEventListener( GUIEvents.onGPRSOnline, chChanged );
		}
		override public function put(p:Package):void
		{
			switch(p.cmd) {
				case CMD.OP_h_CH_TEL:
					(aItems[p.structure] as OptLinkChannel).putData(p);
					break;
				case CMD.OP_D_LINK_CHANNEL:
					var a:Array = (p.getStructure()[0] as String).split(" "); 
					for (var i:int=0; i<8; i++) {
						(aItems[i+1] as OptLinkChannel).putRawData([a[i]]);						
					}
					SavePerformer.LOADING = true;
					chChanged();
					SavePerformer.LOADING = false;
					loadComplete();
					break;
				case CMD.OP_digt_TIME_DIGIT_CALL:
				case CMD.OP_GA_LINK_CHANNEL_ONLINE:
				case CMD.OP_DO_CH_DIRECTION_TYPE:
					distribute( p.getStructure(), p.cmd );
					break;
				case CMD.OP_AND_CH_COM_LINK:
					if (p.structure == 1)
						groups = [];
					groups.push( p.getStructure(p.structure)[0] );
					if(p.structure == 8)
						linksVisualizeAndSave(groups);
					break;
			}
		}
		private function chChanged(ev:GUIEvents=null):void
		{
			var len:int = aItems.length;
			var disabledFound:Boolean;
			var i:int;
			for (i=0; i<len; i++) {
				if (!aItems[i])
					continue;
				(aItems[i] as OptLinkChannel).chEnabled = true;
			}
			
			var g:Array = [];
			var opt:OptLinkChannel;
			var gnum:int;
			for (i=0; i<len; i++) {
				if (!aItems[i])
					continue;
				opt = (aItems[i] as OptLinkChannel);
				
				if( !opt.chEnabled || disabledFound)  {
					if (disabledFound)
						opt.chEnabled = false;
					else
						disabledFound = true;
				}
				if (!disabledFound) {
					if (oGroup[i] && (oGroup[i] as IFormString).getCellInfo() == "2") {
						g[g.length-1] += String(gnum++);
					} else
						g.push( String(gnum++) ); 
				}
			}
			linksVisualizeAndSave(g);
			if (!SavePerformer.LOADING)
				SavePerformer.rememberBlank();
		}
		private function linksVisualizeAndSave(g:Array):void
		{
			var channels:Array = [];
			var foundbreak:Boolean;
			var i:int;
			for (i=0; i<9; i++) {
				if(oArrows[i])
					oArrows[i].visible = false;
				if( oGroup[i])
					(oGroup[i] as FSRadioGroupH).setCellInfo("1");
			}
			
			for (i=0; i<8; i++) {
				if (g[i]) {
					if(g[i] != "") {
						parseGroup(g[i]);
					} else
						foundbreak = true;
				}
			}
			groups = g;
			for (i=0; i<8; i++) {
				if( !groups[i] )
					groups[i] = "";
			}

			function parseGroup(line:String):void
			{
				var len:int = line.length;
				for (var j:int=0; j<len; j++) {
					channels[j] = true;
					var cellnum:int = int(line.charAt(j))+1;
					if (j>0) {
						if( oArrows[cellnum] ) {
							oArrows[cellnum].visible = true;
							(oGroup[cellnum] as FSRadioGroupH).setCellInfo("2");
						}
					} else {
						/*	if(oArrows[cellnum])
							oArrows[cellnum].visible = false;
						if( oGroup[cellnum])
							(oGroup[cellnum] as FSRadioGroupH).setCellInfo("1");*/
					}
				}
			}
		}
		private function links():void
		{
			chChanged();
		}
		private function after():void
		{
			var len:int = groups.length;
			for (var i:int=0; i<len; i++) {
				RequestAssembler.getInstance().fireEvent( new Request( CMD.OP_AND_CH_COM_LINK, null, i+1, [groups[i]] ));
			}
		}
	}
}
import components.interfaces.IDataAdapter;
import components.interfaces.IFormString;

class HexAdapter implements IDataAdapter
{
	public function adapt(value:Object):Object
	{
		var s:String = int("0x" + value).toString(10);
		return s;
	}
	
	public function change(value:Object):Object
	{
		return value;
	}
	
	public function perform(field:IFormString):void	{	}
	
	public function recover(value:Object):Object
	{
		var s:String = int(value).toString(16);
		while(s.length < 2) {
			s = "0"+s;
		}
		return s.toUpperCase();
	}
}