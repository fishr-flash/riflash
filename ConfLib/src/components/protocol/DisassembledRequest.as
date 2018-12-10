package components.protocol
{
	import components.abstract.servants.primitive.ProgressSpy;
	import components.protocol.statics.CLIENT;

	public class DisassembledRequest
	{
		private var parts:int;
		private var assemblege:Package;
		private var request:Request;
		private var spy:ProgressSpy;
		private var huge:Boolean=false;
		
		public function DisassembledRequest( _parts:int, _re:Request )
		{
			parts = _parts;
			request = _re;
		}
		public function isHuge():void
		{
			CLIENT.NO_CLONE_HUNT = true;
			huge = true;
		}
		public function attachSpy(s:ProgressSpy):void
		{
			spy = s; 
		}
		public function attach( p:Package ):void
		{
			if ( !assemblege ) {
				assemblege = p;
				assemblege.structure = request.structure;
				assemblege.request = request;
			} else
				assemblege.attach( p );
			
			if (spy)
				spy.report({current:assemblege.length, total:parts})
			
			if ( assemblege.length == parts) {
				assemblege.launch();
				if (huge)
					CLIENT.NO_CLONE_HUNT = false;
			}
		}
	}
}