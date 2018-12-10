package components.screens.ui
{
	import flash.events.Event;
	
	import mx.events.ResizeEvent;
	
	import components.abstract.functions.loc;
	import components.abstract.servants.VjrEventsServant;
	import components.basement.UI_BaseComponent;
	import components.gui.SubsetVrgEvents;
	import components.gui.fields.FSCheckBox;
	import components.gui.fields.FormString;
	import components.interfaces.IFormString;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.static.CMD;
	import components.static.COLOR;
	
	public class UIVojagerEvents extends UI_BaseComponent
	{
		
		private var _subsets:Vector.<SubsetVrgEvents> = new Vector.<SubsetVrgEvents>;
		public function UIVojagerEvents()
		{
			super();
			
			init();
		}
		
		private function init():void
		{
			const servant:* = VjrEventsServant.instance
			addui( new FSCheckBox, CMD.VR_NEW_FLAG_ENABLE, loc( "switcher_events" ), switchModeEvents, 1 );
			attuneElement( 600 );
			
			addui( new FormString, 0, loc( "note_server_with_events" ), null, 1 );
			attuneElement( 800, NaN );
			( getLastElement() as FormString ).setTextColor( COLOR.RED_BLOOD );
			drawSeparator( 800 );
			
			
			
			
			starterCMD = [ CMD.VR_MSG_LIST ];
			//starterCMD = [ CMD.VR_NEW_FLAG_ENABLE ];
		}
		
		
		
		
		override public function open():void
		{
			super.open();
			
			/// чтобы обновить элементы, 
			/// между входами на экран была
			/// перезаписана конфигурация прибора
			/// из файла
			
			/*if( _subsets.length )
				RequestAssembler.getInstance().fireEvent( new Request( CMD.VR_MSG_LIST, put  ) );*/
			
			
		}
		override public function close():void
		{
			super.close();
			
		
			
		}
		
		override public function put(p:Package):void
		{
			
			var indx:int = NaN;
			
			switch( p.cmd ) 
			{
				case CMD.VR_NEW_FLAG_ENABLE:
					
					pdistribute( p );
					
					const data:Array = VjrEventsServant.instance.getList();
					
					
					var len:int = data.length;
					var i:int;
					if( !_subsets.length )
					{
						for ( i = 0; i<len; i++) 
						{
							
							_subsets.push( new SubsetVrgEvents( data[ i ] ) );
							_subsets[ i ].addEventListener( Event.RESIZE, resizeHandler );
							_subsets[ i ].x = globalX;
							_subsets[ i ].y = globalY;
							this.addChild( _subsets[ i ] );
							
							globalY += _subsets[ i ].vheight;
						}	
					}
					else
					{
						for ( i = 0; i<len; i++) 
							_subsets[ i ].put( data[ i ] );	
					}
					
					
					
					
					this.width += 400;
					
					loadComplete();
					break;
				
				case CMD.VR_MSG_LIST:
					VjrEventsServant.instance.setList( p.data );
					indx = VjrEventsServant.instance.getSettingsIndex();
					/// запрашиваем настройки только существующих событий
					while( indx )
					{
						RequestAssembler.getInstance().fireEvent( new Request( CMD.VR_MSG_SETTINGS, put, indx  ) );
						
						indx = VjrEventsServant.instance.getSettingsIndex();
					}
					
					RequestAssembler.getInstance().fireEvent( new Request( CMD.VR_NEW_FLAG_ENABLE, put  ) );
						
					break;
				case CMD.VR_MSG_SETTINGS:
					
					
					VjrEventsServant.instance.setSettings( p.structure, p.data );
					
					break;
				
				default:
							
					break;
			}
		}
		
		protected function resizeHandler(event:Event):void
		{
			const inx:int = _subsets.indexOf( event.target as SubsetVrgEvents );
			
			var len:int = _subsets.length;
			for (var i:int=inx + 1; i<len; i++) {
				_subsets[ i ].y = _subsets[ i - 1 ].y + _subsets[ i - 1 ].vheight;
			}
			
			
			manualResize();
			this.height = _subsets[ i - 1 ].y + _subsets[ i - 1 ].vheight + 30;
			
		}		
		
		private function switchModeEvents( t:IFormString ):void
		{
			remember( t );
			
		}
	}
}