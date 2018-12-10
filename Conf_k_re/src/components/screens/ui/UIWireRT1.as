package components.screens.ui
{
	import components.abstract.functions.loc;
	import components.abstract.servants.CIDServant;
	import components.basement.UI_BaseComponent;
	import components.gui.fields.FSCheckBox;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.static.CMD;
	import components.static.DS;
	
	public class UIWireRT1 extends UI_BaseComponent
	{
		private var opts:Array;
		public static var actualCntWires:int;
		private static var maxCntWires:int;
		
		
		
		public function UIWireRT1()
		{
			super();
			
			
			opts = new Array();
			
			
			
			
			var listEvents:Array = CIDServant.getEvent();
			listEvents.shift();
			
			var OptClass:Class;
			
			
			switch( DS.alias ) {
				case DS.K5RT1:
				case DS.K5RT13G:
					OptClass = OptWireRT1;
					actualCntWires = maxCntWires = 2;
					break;
				
				case DS.K5RT1L:
					OptClass = OptWireRT1;
					actualCntWires = 1;
					maxCntWires = 2;
					break;
				
				case DS.K5RT3L:
				
					actualCntWires = 1;
					maxCntWires = 3;
					OptClass = OptWireRT3;
					
					break;
				
				default:
					OptClass = OptWireRT3;
					actualCntWires = maxCntWires = 3;
					break;
			}
			for (var i:int=0; i< maxCntWires ; i++) {
				
				opts.push( new OptClass(i+1, listEvents) );
				opts[i].x = globalX;
				opts[i].y = globalY;
				if( i < actualCntWires )
				{
					addChild( opts[i] );
					globalY += opts[i].complexHeight;
					if (i < 2)
						drawSeparator();
				}
				
				
				
				
			}
			
			height = 520;
			
			starterCMD = [ CMD.K5RT_AWIRE_TYPE ];
			
			if( DS.isfam( DS.K5RT3 )  )
			{
				
				addui( new FSCheckBox, CMD.K5RT_TAMPER, loc("on_tamper"), null, 1 );
				attuneElement( 447 );
				
				
				( starterCMD as Array ).push( CMD.K5RT_BOLID_LINK );
				( starterCMD as Array ).push( CMD.K5RT_TAMPER );
			}
			
			
			manualResize();
		}
		
		
		
		override public function put(p:Package):void
		{
			switch( p.cmd ) {
				case CMD.K5RT_AWIRE_TYPE:

					if( DS.isDevice( DS.K5RT1L ) 
						&& int( DS.app ) == 1 
						&& int( DS.release ) >= 5
						&& ( int( p.getParam( 1, 2 ) ) != 0 || int( p.getParam( 5, 2 ) ) != 0 ) )
					{
						
						
						p.data[ 1 ][ 0 ] = 0;
						p.data[ 1 ][ 4 ] = 0;
						RequestAssembler.getInstance().fireEvent( new Request( CMD.K5RT_AWIRE_TYPE, null, 2, p.data[ 1 ] ) );
					}
							 
						
					const len:int = opts.length;
					for (var i:int=0; i<len; i++) {
						opts[i].putData(p);
					}
						
					
					loadComplete();
					
					break;
				case CMD.K5RT_BOLID_LINK:
					if( !DS.isDevice( DS.K5RT3L ) )opts[ 2 ].freeze = p.data[ 0 ][ 0 ] == 0; 
					break;
				case CMD.K5RT_TAMPER:
					pdistribute( p );
					break;
				
			}
			
			
		}
		
		
	}
}
import components.abstract.RegExpCollection;
import components.abstract.adapters.CidAdapter;
import components.abstract.functions.loc;
import components.basement.OptionsBlock;
import components.gui.fields.FSCheckBox;
import components.gui.fields.FSComboBox;
import components.gui.fields.FSSimple;
import components.gui.fields.FormString;
import components.interfaces.IFormString;
import components.protocol.Package;
import components.protocol.Request;
import components.protocol.RequestAssembler;
import components.screens.ui.UIWireRT1;
import components.static.CMD;
import components.static.DS;
import components.system.SavePerformer;

class OptWireRT1 extends OptionsBlock
{
	public function OptWireRT1(str:int, listEvents:Array)
	{
		super();
		
		structureID = str;
		operatingCMD = CMD.K5RT_AWIRE_TYPE;

		/**"Команда K5_AWIRE_TYPE - код ACID формируемый на событие автотест
		 Параметр 1 - формировать событие при замыкании шлейфа, 1 - да, 0 - нет
		 Параметр 2 - код ACID для события замыкание шлейфа (вкл)
		 Параметр 3 - номер раздела для события замыкание шлейфа (0 - 99)
		 Параметр 4 - номер зоны для события замыкание шлейфа (0 - 999)
		 
		 Параметр 5 - формировать событие при размыкании шлейфа, 1 - да, 0 - нет
		 Параметр 6 - код ACID для события размыкание шлейфа (вкл)
		 Параметр 7 - номер раздела для события размыкание шлейфа (0 - 99)
		 Параметр 8 - номер зоны для события размыкание шлейфа (0 - 999) */
		
		addui( new FormString, 0, loc("rfd_wire") + " "+str, null, 1 );
		
		var w:int = 300;
		var wshort:int = 150;
		var cbw:int = 400;
		var fsw:int = 50;
		
		addui( new FSCheckBox, CMD.K5RT_AWIRE_TYPE, loc("rt1_wire_trigger"), onEnable, 1 );
		attuneElement(w+48+99);
		
		addui( new FSComboBox, CMD.K5RT_AWIRE_TYPE, loc("his_k5_code"), null, 2, listEvents );
		attuneElement(w-240, cbw, FSComboBox.F_COMBOBOX_NOTEDITABLE );
		getLastElement().setAdapter( new CidAdapter );
		FLAG_VERTICAL_PLACEMENT = false;
		addui( new FSSimple, CMD.K5RT_AWIRE_TYPE, loc("guard_partnum"), null, 3, null, "0-9", 2, new RegExp(RegExpCollection.COMPLETE_ATLEST1SYMBOL) );
		attuneElement(wshort,fsw);
		FLAG_VERTICAL_PLACEMENT = true;
		addui( new FSSimple, CMD.K5RT_AWIRE_TYPE, loc("g_zonenum"), null, 4, null, "0-9", 3, new RegExp(RegExpCollection.COMPLETE_ATLEST1SYMBOL) ).x = 300-41;
		attuneElement(wshort,fsw);
		
		addui( new FSCheckBox, CMD.K5RT_AWIRE_TYPE, loc("rt1_wire_restore"), onEnable, 5 );
		attuneElement(w+48+99);
		addui( new FSComboBox, CMD.K5RT_AWIRE_TYPE, loc("his_k5_code"), null, 6, listEvents );
		attuneElement(w-240, cbw, FSComboBox.F_COMBOBOX_NOTEDITABLE );
		getLastElement().setAdapter( new CidAdapter );
		FLAG_VERTICAL_PLACEMENT = false;
		addui( new FSSimple, CMD.K5RT_AWIRE_TYPE, loc("guard_partnum"), null, 7, null, "0-9", 2, new RegExp(RegExpCollection.COMPLETE_ATLEST1SYMBOL) );
		attuneElement(wshort,fsw);
		FLAG_VERTICAL_PLACEMENT = true;
		addui( new FSSimple, CMD.K5RT_AWIRE_TYPE, loc("g_zonenum"), null, 8, null, "0-9", 3, new RegExp(RegExpCollection.COMPLETE_ATLEST1SYMBOL) ).x = 300-41;
		attuneElement(wshort,fsw);
		
		complexHeight = globalY;
	}
	override public function putData(p:Package):void
	{
		SavePerformer.LOADING = true;
		pdistribute(p);
		onEnable(getField(p.cmd,1),false);
		onEnable(getField(p.cmd,5),false);
		SavePerformer.LOADING = false;
	}
	private function onEnable(t:IFormString, save:Boolean=true):void
	{
		var b:Boolean = int(t.getCellInfo()) == 0;
		getField(t.cmd,t.param+1).disabled = b;
		getField(t.cmd,t.param+2).disabled = b;
		getField(t.cmd,t.param+3).disabled = b;
		
		if (save)
			remember(t);
	}
}



class OptWireRT3 extends OptionsBlock
{
	public function OptWireRT3(str:int, listEvents:Array)
	{
		super();
		
		structureID = str;
		operatingCMD = CMD.K5RT_AWIRE_TYPE;

		/**"Команда K5_AWIRE_TYPE - код ACID формируемый на событие автотест
		 Параметр 1 - формировать событие при замыкании шлейфа, 1 - да, 0 - нет
		 Параметр 2 - код ACID для события замыкание шлейфа (вкл)
		 Параметр 3 - номер раздела для события замыкание шлейфа (0 - 99)
		 Параметр 4 - номер зоны для события замыкание шлейфа (0 - 999)
		 
		 Параметр 5 - формировать событие при размыкании шлейфа, 1 - да, 0 - нет
		 Параметр 6 - код ACID для события размыкание шлейфа (вкл)
		 Параметр 7 - номер раздела для события размыкание шлейфа (0 - 99)
		 Параметр 8 - номер зоны для события размыкание шлейфа (0 - 999) */
		
		addui( new FormString, 0, loc("rfd_wire") + " "+str, null, 1 );
		
		var w:int = 300;
		var wshort:int = 150;
		var cbw:int = 400;
		var fsw:int = 50;
		
		addui( new FSCheckBox, CMD.K5RT_AWIRE_TYPE, loc("ui_out_closed"), onEnable, 5 );
		attuneElement(w+48+99);
		
		addui( new FSComboBox, CMD.K5RT_AWIRE_TYPE, loc("his_k5_code"), null, 6, listEvents );
		attuneElement(w-240, cbw, FSComboBox.F_COMBOBOX_NOTEDITABLE );
		getLastElement().setAdapter( new CidAdapter );
		FLAG_VERTICAL_PLACEMENT = false;
		addui( new FSSimple, CMD.K5RT_AWIRE_TYPE, loc("guard_partnum"), null, 7, null, "0-9", 2, new RegExp(RegExpCollection.COMPLETE_ATLEST1SYMBOL) );
		attuneElement(wshort,fsw);
		FLAG_VERTICAL_PLACEMENT = true;
		addui( new FSSimple, CMD.K5RT_AWIRE_TYPE, loc("g_zonenum"), null, 8, null, "0-9", 3, new RegExp(RegExpCollection.COMPLETE_ATLEST1SYMBOL) ).x = 300-41;
		attuneElement(wshort,fsw);
		
		addui( new FSCheckBox, CMD.K5RT_AWIRE_TYPE, loc("ui_out_opened"), onEnable, 1 );
		attuneElement(w+48+99);
		addui( new FSComboBox, CMD.K5RT_AWIRE_TYPE, loc("his_k5_code"), null, 2, listEvents );
		attuneElement(w-240, cbw, FSComboBox.F_COMBOBOX_NOTEDITABLE );
		getLastElement().setAdapter( new CidAdapter );
		FLAG_VERTICAL_PLACEMENT = false;
		addui( new FSSimple, CMD.K5RT_AWIRE_TYPE, loc("guard_partnum"), null, 3, null, "0-9", 2, new RegExp(RegExpCollection.COMPLETE_ATLEST1SYMBOL) );
		attuneElement(wshort,fsw);
		FLAG_VERTICAL_PLACEMENT = true;
		addui( new FSSimple, CMD.K5RT_AWIRE_TYPE, loc("g_zonenum"), null, 4, null, "0-9", 3, new RegExp(RegExpCollection.COMPLETE_ATLEST1SYMBOL) ).x = 300-41;
		attuneElement(wshort,fsw);
		
		complexHeight = globalY;
	}
	override public function putData(p:Package):void
	{
		SavePerformer.LOADING = true;
		pdistribute(p);
		onEnable(getField(p.cmd,1),false);
		onEnable(getField(p.cmd,5),false);
		SavePerformer.LOADING = false;
		
		if( structureID > UIWireRT1.actualCntWires )
		{
			if( getField( p.cmd, 1 ).getCellInfo() )
			{
				getField( p.cmd, 1 ).setCellInfo( 0 );
				getField( p.cmd, 5 ).setCellInfo( 0 );
				RequestAssembler.getInstance().fireEvent( new Request( p.cmd, null, structureID, [ 0, 0, 0, 0,  0, 0, 0, 0  ] ) );
			}
			
			
		
			
		}
	}
	private function onEnable(t:IFormString, save:Boolean=true):void
	{
		var b:Boolean = int(t.getCellInfo()) == 0;
		getField(t.cmd,t.param+1).disabled = b;
		getField(t.cmd,t.param+2).disabled = b;
		getField(t.cmd,t.param+3).disabled = b;
		
		if (save)
			remember(t);
	}
}