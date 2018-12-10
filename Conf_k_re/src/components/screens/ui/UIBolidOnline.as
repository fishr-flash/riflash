package components.screens.ui
{
	import flash.events.MouseEvent;
	import flash.net.FileReference;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import mx.states.OverrideBase;
	
	import components.abstract.functions.loc;
	import components.abstract.servants.TaskManager;
	import components.basement.UI_BaseComponent;
	import components.gui.fields.FSSimple;
	import components.gui.triggers.TextButton;
	import components.interfaces.ITask;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.static.CMD;
	
	public class UIBolidOnline extends UI_BaseComponent
	{

		private var tField:FSSimple;

		private var tfBolidText:TextField;

		private var butSave:TextButton;

		private var butClear:TextButton;
		private var bolidLinkTask:ITask;

		private var bolidTaskRuning:Boolean;
		public function UIBolidOnline()
		{
			super();
			
			init();
		}
		
		private function init():void
		{
			
			var cmds:Array = new Array();
			
			FLAG_SAVABLE = false;
			
			butClear  = new TextButton();
			butClear.setUp( loc( "g_clear" ), onClear );
			butClear.x = globalX;
			butClear.y = globalY;
			this.addChild( butClear );
			globalY += butClear.height + 10;
			butClear.disabled = true;
							
			butSave  = new TextButton();
			butSave.setUp( loc( "g_save" ), onSave );
			butSave.x = butClear.x + butClear.width + 10;
			butSave.y = butClear.y;
			this.addChild( butSave );
			butSave.disabled = true;
			
							
			tfBolidText = createTextField();
			tfBolidText.addEventListener( MouseEvent.MOUSE_WHEEL, mouseDownScroll );
			tfBolidText.x = globalX;
			tfBolidText.y = globalY;
			globalY += tfBolidText.height + 10;
			this.addChild( tfBolidText );
			/*const contain:Container = new Container();
			contain.width = tfBolidText.width;
			contain.height = tfBolidText.height;
			contain.x = globalX;
			contain.y = globalY;
			globalY += contain.height + 10;
			
			contain.addChild( tfBolidText );
			*/
			
			cmds.push( CMD.K5RT_BOLID_ONLINE );
			
			
			
			
			starterCMD = cmds;
		}
		
		override public function open():void 
		{
			bolidTaskRuning = true;	
			super.open();
			loadComplete();
		}
				
		override public function put(p:Package):void
		{
			const str:String = p.data[ 0 ][ 0 ] + p.data[ 1 ][ 0 ] + "\n\r";
			
			if( bolidTaskRuning )
			{
				if ( !bolidLinkTask)
					
					bolidLinkTask = TaskManager.callLater(requestSignal,TaskManager.DELAY_1SEC / 5);
				else
					bolidLinkTask.repeat();
			}
			
			
			if( str.length < 10 ) return;
			
			var txt:String = tfBolidText.text;
			txt = str  + txt;
			
			
			if( txt.length > 10 )
			{
				butClear.disabled = butSave.disabled = false; 
				tfBolidText.text = txt;
			}
			else
			{
				butClear.disabled = butSave.disabled = true;
			}
			
			
		}
		
		override public function close():void
		{
			if( bolidLinkTask ) 
			{
				bolidLinkTask.stop();
				bolidLinkTask.kill();
				bolidTaskRuning = false;
			}
			
			
			bolidLinkTask = null;
			super.close();
			
			
		}
		
		private function createTextField():TextField
		{
			const fText:TextField = new TextField();
			fText.width = 800;
			fText.height = 600;
			fText.border = true;
			fText.multiline = true;
			fText.selectable = false;
			fText.borderColor = 0x999999;
			
			
			
			const tFormat:TextFormat = new TextFormat();
			tFormat.font = "Verdana";
			
			fText.defaultTextFormat = tFormat;
			
			return fText;
		}
		
		private function requestSignal():void
		{
			if( bolidLinkTask )RequestAssembler.getInstance().fireEvent( new Request(CMD.K5RT_BOLID_ONLINE,put));
		}
		
		private function mouseDownScroll(event:MouseEvent):void 
		{ 
			//tfBolidText.scrollV++; 
		} 
		
		private function onSave():void
		{
			const flieRef:FileReference = new FileReference();
			flieRef.save( tfBolidText.text, "bolid_data.txt" );
		}
		
		private function onClear():void
		{
			tfBolidText.text = "";
		}	
		
		
	}
}


