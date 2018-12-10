package components.abstract.servants
{
	import components.abstract.offline.OfflineProcessor;
	import components.interfaces.IConfigLoaderBot;
	import components.interfaces.IFormString;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.static.CMD;
	import components.static.NAVI;
	
	public class K2ConfigLoaderBot implements IConfigLoaderBot
	{
		private var important:Array;
		private var counterIncrease:Function;
		private var fComplete:Function;
		public function K2ConfigLoaderBot(fCounterIncrease:Function):void
		{
			counterIncrease = fCounterIncrease;
		}
		public function checkImportant(navi:int):Boolean
		{
			switch(navi) {
				case NAVI.TM_KEYS:
					if(!important)
						important = [];
					important.push( navi );
					counterIncrease();
					return true;
			}
			return false;
		}
		
		public function addImportant(a:Array):Array
		{
			return a;
		}
		public function doImportant(f:Function):void	
		{
			if(important) {
				var len:int = important.length;
				for (var i:int=0; i<len; ++i) {
					switch(important[i]) {
						case NAVI.TM_KEYS:
							fComplete = f;
							RequestAssembler.getInstance().fireEvent( new Request( CMD.TM_KEY2, deletePhase, 0, null, Request.NORMAL, Request.PARAM_SAVE ));
							break;
					}
				}
				important = null;
			}
		}
		private function deletePhase(p:Package):void
		{
			var len:int = p.length;
			var a:Array = [];
			for (var i:int=0; i<len; ++i) {
				if( p.getStructure(i+1)[0] == 1 )
					a.push( i+1 );
			}
			if (a.length > 0)
				new KeyRemoveSequencer(a,addPhase);
			else
				addPhase();
		}
		private function addPhase(p:Package=null):void
		{
			var saving:Array = OfflineProcessor.getData( CMD.TM_KEY2 );
			var a:Array = [];
			var len:int = saving.length;
			for (var i:int=0; i<len; ++i) {
				if (saving[i][0] == 1 )
					a.push( i+1 );
			}
			if (a.length > 0)
				new KeyAddSequencer(a,complete);
			else
				complete();
		}
		private function complete():void
		{
			fComplete();
		}
		public function interrupt():void	{}
		public function doListIntegration(l:Array, selected:Array, f:IFormString):void		{}
		public function doBeforeRead(a:Array):void	{	}
		public function doRefine(cmd:int, a:Array, str:int):void	{	}
		public function doActions(a:Array, f:Function, fcancel:Function):Boolean
		{
			return false;
		}
		public function doSaveRefine(cmd:int):void	{	}
		public function needRestart():Boolean
		{	// если по каким то причинам необходимо рестартнуть клиент после загрузки информации, функция возвращает true;
			return false;
		}
		public function fire(r:Request):void
		{
			RequestAssembler.getInstance().fireEvent(r);
		}
	}
}
import components.abstract.offline.OfflineProcessor;
import components.abstract.servants.TaskManager;
import components.protocol.Package;
import components.protocol.Request;
import components.protocol.RequestAssembler;
import components.static.CMD;
import components.static.RF_FUNCT;
import components.static.RF_STATE;

class KeyRemoveSequencer
{
	private var structure:int;
	private var structures:Array;
	private var fOnComplete:Function;
	
	public function KeyRemoveSequencer(strs:Array, fComplete:Function):void
	{
		structures = strs;
		fOnComplete = fComplete;
		next();
	}
	private function next():void
	{
		if (structures && structures.length > 0) {
			structure = structures.pop();
			RequestAssembler.getInstance().fireEvent( new Request( CMD.TM_KEY_FUNCT, null, 1, [structure, RF_FUNCT.DO_DEL], Request.NORMAL, Request.PARAM_SAVE  ));
			TaskManager.callLater( onState, 500 );
		} else {
			// Зануляем стейт, чтобы не было непредвиденных считываний
			RequestAssembler.getInstance().fireEvent( new Request( CMD.TM_KEY_STATE, fOnComplete, 1, [0,0], Request.NORMAL, Request.PARAM_SAVE ));
		}
	}
	private function onState(p:Package=null):void
	{
		if (p) {
			if( p.getStructure()[0] == structure && p.getStructure()[1] == RF_STATE.DELETED )
				next();
			else
				TaskManager.callLater( onState, 500 );
		} else
			RequestAssembler.getInstance().fireEvent( new Request( CMD.TM_KEY_STATE, onState, 1, null, Request.NORMAL, Request.PARAM_SAVE ));
	}
	
}

class KeyAddSequencer
{
	private var structure:int;
	private var structures:Array;
	private var fOnComplete:Function;
	
	public function KeyAddSequencer(strs:Array, fComplete:Function):void
	{
		structures = strs;
		fOnComplete = fComplete;
		next();
	}
	private function next(p:Package=null):void
	{
		if (structures && structures.length > 0) {
			structure = structures.pop();
			RequestAssembler.getInstance().fireEvent( new Request( CMD.TM_KEY_FUNCT, null, 1, [structure, RF_FUNCT.DO_ADD], Request.NORMAL, Request.PARAM_SAVE  ));
			TaskManager.callLater( onState, 500 );
		} else
			fOnComplete();
	}
	private function onState(p:Package=null):void
	{
		if (p) {
			if (p.getStructure()[0] == structure) {
				switch(p.getStructure()[1]) {
					case RF_STATE.SUCCESS:
						RequestAssembler.getInstance().fireEvent( new Request( CMD.TM_KEY2, onKeyExist, structure, null, Request.NORMAL, Request.PARAM_SAVE  ));
						break;
					case RF_STATE.CANNOTADD:
					case RF_STATE.ERROR:
						next();
						break;
					default:
						break;
				}
			} else
				TaskManager.callLater( onState, 500 );
		} else
			RequestAssembler.getInstance().fireEvent( new Request( CMD.TM_KEY_STATE, onState, 1 ));
	}
	private function onKeyExist(p:Package):void
	{
		if (p.getStructure()[0] == 1 ) {
			var a:Array = OfflineProcessor.getData( CMD.TM_KEY2 );
			var data:Array = OfflineProcessor.getData( CMD.TM_KEY2 )[structure-1];
			RequestAssembler.getInstance().fireEvent( new Request( CMD.TM_KEY2, next, structure, data, Request.NORMAL, Request.PARAM_SAVE ));
		} else
			next();
	}
}