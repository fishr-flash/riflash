package components.abstract
{
	import flash.utils.Dictionary;
	
	import components.abstract.servants.LcdIsoServant;
	import components.abstract.servants.primitive.LSDIsoData;
	import components.protocol.Package;
	import components.static.CMD;

	public class WriterIsoLCD3Bot extends CmdBot 
	{
		public var fUpdate:Function;
		
		private var _iconLoader:IconLoader;
		private var _fmemoryLocals:Dictionary = new Dictionary( true );

		private var _callOnComplete:Function;

		private var _totalItems:int = 0;

		private var _currentItem:int;
		
		
		public function WriterIsoLCD3Bot()
		{
			super();
			
			_iconLoader = new IconLoader( );
			_iconLoader.init();
			
			_fmemoryLocals[ CMD.KBD_PARTITION_NAME ] = 100;
			_fmemoryLocals[ CMD.KBD_ZONES_NAME ] = 120;
		}
		
		public function interrupt():void
		{
			_iconLoader.interrupt();
		}
		override public function after(cmd:int, f:Function):Object
		{
			
			_callOnComplete = f;
			const ents:Vector.<LSDIsoData> = LcdIsoServant.self.ents;
			
			const len:int = ents.length;
			_totalItems += len;
			for (var i:int=0; i<len; i++) {
				
				_iconLoader.setAnyImageForLCD( _fmemoryLocals[ ents[ i ].command ] + ents[ i ].struct, ents[ i ].isoData, null, onProgress  );
			}
			
			const p:Package = new Package();
			p.cmd = cmd;
			p.structure = 1;
				
			
			//if( _callOnComplete is Function ) _callOnComplete( p );
			/*_callOnComplete = null;*/
			//return [ 1, 1 ,2 ];
			//return null;
			return p;
		}
		
		private function onProgress( value:int ):void
		{
			
			
			if( value > -1 )
			{
				_currentItem = _totalItems - value;
				
				fUpdate( _currentItem, _totalItems );
				//pBar.label = pBar.label = loc("fw_loaded") + Math.ceil( ( _currentItem  /  _totalItems ) * 100 ) +"%";
			}
			else
			{
				const p:Package = new Package();
				p.cmd = 862;
				p.structure = 1;
				/*pBar.visible = false;
				btnUpload.disabled = false;*/
				if( _callOnComplete is Function ) _callOnComplete( p );
			}
			
		}
	}
}