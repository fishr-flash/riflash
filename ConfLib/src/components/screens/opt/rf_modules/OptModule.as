package components.screens.opt.rf_modules
{
	import flash.events.Event;
	
	import components.abstract.functions.loc;
	import components.abstract.servants.ResizeWatcher;
	import components.basement.OptionsBlock;
	import components.basement.UIRadioDeviceRoot;
	import components.events.GUIEventDispatcher;
	import components.events.GUIEvents;
	import components.gui.fields.FSShadow;
	import components.interfaces.IResizeDependant;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.protocol.statics.OPERATOR;
	import components.static.CMD;
	import components.static.RF_FUNCT;
	import components.system.SavePerformer;
	
	public class OptModule extends OptionsBlock implements IResizeDependant
	{
		
		
		public var label:String = "";
		public var labelParentPadejM:String;
		public var labelParentPadejS:String;
		public var labelParentPadejR:String;
		
		private var _myType:int;
		private var opts:Vector.<OptModulePart>;
		private var lenOpt:int;

		
		
		private function get myType():int
		{
			return _myType;
		}
		
		private function set myType( value:int ):void
		{
			if( value == _myType ) return;
			
			_myType = value;
			editLabels();
			
		}
		
		public function OptModule()
		{
			super();
			
			init();
		}
		
		
		
		private function init():void
		{
			operatingCMD = CMD.RF_CTRL;
			
			globalX = globalY = 10;
			
			addui( new FSShadow, operatingCMD, "", null, 1 ); // состояние модуля
			addui( new FSShadow, operatingCMD, "", null, 2 ); // тип модуля
			addui( new FSShadow, operatingCMD, "", null, 3 ); // выход 1
			addui( new FSShadow, operatingCMD, "", null, 4 ); // выход 2
			addui( new FSShadow, operatingCMD, "", null, 5 ); // выход 3
			
			
			opts = new Vector.<OptModulePart>();
			
			opts.push( this.addChild( new OptModulePart( 1 ) ) as OptModulePart );
			opts[ opts.length - 1 ].x = globalX;
			opts[ opts.length - 1 ].y = globalY;
			
			globalY = opts[ opts.length - 1 ].y + opts[ opts.length - 1 ].height;
			
			
			opts.push( this.addChild( new OptModulePart( 2 ) ) as OptModulePart );
			opts[ opts.length - 1 ].x = globalX;
			opts[ opts.length - 1 ].y = globalY;
			
			globalY = opts[ opts.length - 1 ].y + opts[ opts.length - 1 ].height;
			
			
			opts.push( this.addChild( new OptModulePart( 3 ) ) as OptModulePart );
			opts[ opts.length - 1 ].x = globalX;
			opts[ opts.length - 1 ].y = globalY;
			
			globalY = opts[ opts.length - 1 ].y + opts[ opts.length - 1 ].height;
			
			label = loc("navi_rf_modules");
			labelParentPadejM = loc("ui_rfmodule_padejm");
			labelParentPadejS = loc("ui_rfmodule_padejs");
			labelParentPadejR = loc("ui_rfmodule_padejr");
			
			
			GUIEventDispatcher.getInstance().addEventListener(GUIEvents.ON_RESIZE, onResizeOpts );
			GUIEventDispatcher.getInstance().addEventListener(GUIEvents.CHANGE_RFMODULE_TEMPLATE, changeRfmoduleTemplate );
			
			manualResize();
			
			
			
		}		
		
		override public function putData(p:Package):void
		{
			
			
			switch( p.cmd ) {
				case operatingCMD:
					
					structureID = p.structure;
					refreshCells(operatingCMD);
					
					
					const substrc:int = ( structureID  * 3 ) - 2;
					
					myType = int( p.data[ 1 ]  );
					globalFocusGroup = 200*(structureID-1)+50;
					
					if( myType != RF_FUNCT.TYPE_RFRELAY )
					{
						opts[ 2 ].visible = false;
						lenOpt = opts.length - 1;
					}
					else
					{
						opts[ 2 ].visible = true;
						lenOpt = opts.length;
					}
					
					
					const len:int = OPERATOR.getSchema( operatingCMD ).Parameters.length;
					for (var j:int=1; j<=len; j++)
						getField( operatingCMD, j ).setCellInfo( p.data[ j - 1 ] );
					
					
					
					var perStrc:int = 0;
					for (var l:int=0; l<lenOpt; l++) 
					{
						perStrc = substrc + l;
						opts[ l ].strc = perStrc;
						
						RequestAssembler.getInstance().fireEvent( new Request( CMD.RF_CTRL_OUT_STATE, addData, perStrc ));
						RequestAssembler.getInstance().fireEvent( new Request( CMD.RF_CTRL_TEMPLATE_ST_PART, addData, perStrc ));
						RequestAssembler.getInstance().fireEvent( new Request( CMD.RF_CTRL_TEMPLATE_AL_LST_PART, addData, perStrc ));
						RequestAssembler.getInstance().fireEvent( new Request( CMD.RF_CTRL_TEMPLATE_AL_PART, addData, perStrc ));
						RequestAssembler.getInstance().fireEvent( new Request( CMD.RF_CTRL_TEMPLATE_MANUAL_CNT, addData, perStrc ));
						RequestAssembler.getInstance().fireEvent( new Request( CMD.RF_CTRL_TEMPLATE_MANUAL_TIME, addData, perStrc ));
						RequestAssembler.getInstance().fireEvent( new Request( CMD.RF_CTRL_TEMPLATE_FAULT, addData, perStrc ));
						RequestAssembler.getInstance().fireEvent( new Request( CMD.RF_CTRL_TEMPLATE_UNSENT_MESS, addData, perStrc ));
						
					}
					
					
					
					break;
				
				default:
					
					break;
			}
			
			
			
			for (var i:int=0; i<lenOpt; i++) 
				opts[ i ].putData( p );
			
			
			
			
			
			
			
			
			this.dispatchEvent( new Event( UIRadioDeviceRoot.EVENT_LOADED ));
		}
		
		public function localResize(w:int, h:int, real:Boolean=false):void
		{
			this.height =  0;
			for (var i:int=0; i< lenOpt; i++) 
				this.height += opts[ i ].height;
			
			
			
		}
		
		
		
		public function close():void
		{
			for (var i:int=0; i< lenOpt; i++) 
							opts[ i ].close();
			label = "";
		}
		
		
		protected function changeRfmoduleTemplate(event:GUIEvents):void
		{
			
			
			getField( operatingCMD, event.serviceObject.param ).setCellInfo( event.serviceObject.data );
			SavePerformer.remember(structureID,  getField( operatingCMD, event.serviceObject.param ), true, false );
			
			ResizeWatcher.addDependent(this);
		}
		
		protected function onResizeOpts(event:GUIEvents):void
		{
			
			var len:int = opts.length;
			for (var i:int=1; i<len; i++) 
				opts[ i ].y = opts[ i - 1 ].y + opts[ i - 1 ].height + 20;
			
			
			
		}		

		
		
		private function addData( p:Package ):void
		{
			
			
			opts[ ( p.structure%3 || 3 ) - 1  ].putData( p );
			ResizeWatcher.doResizeMe(this);
		}
		
		/**
		 *  Предоставляет наименование представляемого прибора
		 * со склонениями, для выведения в меню, подменю
		 */
		private function editLabels():void
		{
			/*public static const TYPE_RFRELAY:uint = 0x0F;
			public static const TYPE_RFSIREN:uint = 0x10;
			public static const TYPE_RFBOARD:uint = 0x11;
			*/
			switch( _myType ) {
				case RF_FUNCT.TYPE_RFRELAY:
					label = loc("navi_rf_rele");
					labelParentPadejM = loc("navi_rf_rele");
					labelParentPadejS = loc("navi_rf_rele");
					labelParentPadejR = loc("navi_rf_rele");
					break;
				
				case RF_FUNCT.TYPE_RFBOARD:
					label = loc("navi_rf_board");
					labelParentPadejM = loc("ui_rfboard_pade");
					labelParentPadejS = loc("ui_rfboard_pade");
					labelParentPadejR = loc("ui_rfboard_pade");
					break;
				
				case RF_FUNCT.TYPE_RFSIREN:
					label = loc("navi_rf_siren");
					labelParentPadejM = loc("ui_rfsiren_padejm");
					labelParentPadejS = loc("ui_rfsiren_padejs");
					labelParentPadejR = loc("ui_rfsiren_padejr");
					break;
				
				default:
					label = loc("navi_rf_modules");
					labelParentPadejM = loc("ui_rfmodule_padejm");
					labelParentPadejS = loc("ui_rfmodule_padejs");
					labelParentPadejR = loc("ui_rfmodule_padejr");
					break;
			}
			
			/*LOCALE_NOT_FOUND = loc("ui_rfmodule_found");
			label_construct = loc("navi_rf_modules")+" ";*/
			
		}
		
		
	}
}
