package components.basement
{
	import flash.display.Sprite;
	import flash.events.Event;
	
	import components.abstract.servants.TabOperator;
	import components.abstract.servants.TaskHelper;
	import components.interfaces.ITask;
	import components.protocol.Package;
	import components.static.COLOR;
	 
	public class OptionsBlock extends ComponentRoot
	{
		//Abstract class, do not instantiate
		protected var _old:Boolean;
		protected var internalLabel:String;
		protected var _complexHeight:int;
		protected var aData:Array;
		protected var _isDisabled:Boolean;
		protected var operatingCMD:int;
		
		public function OptionsBlock()
		{
			super();
		}
		public function set complexHeight( value:int ):void
		{
			_complexHeight = value;
			this.height = value;
		}
		public function get complexHeight():int
		{
			return _complexHeight;
		}
		public function getHeight():int {
			return _complexHeight;
		}
		public function getId():int
		{
			return structureID;
		}
		protected function changed():void
		{
			this.dispatchEvent( new Event( Event.CHANGE ));
		}
		protected function set yAllocation(value:Boolean):void
		{
			globalY = value == true ? 0:-1;
		}
		public function undraw():void
		{
			while (this.numChildren > 0) this.removeChildAt(0);
		}
		public function set old(value:Boolean):void
		{
			_old = value;
		}
		public function get old():Boolean
		{
			return _old;
		}
		public function isRemovable():Boolean
		{
			return true;
		}
		public function putState(re:Array):void {}
		public function putData(p:Package):void {}
		public function putRawData(a:Array):void {}
		public function set loading(value:Boolean):void 
		{
			TabOperator.ACTIVE = !value;
		}
		private var blocker:Sprite;
		public function set freeze(value:Boolean):void
		{
			
			
			if (value) {
				if (!blocker)
					blocker = new Sprite;
				addChild( blocker );
				blocker.graphics.clear();
				blocker.graphics.beginFill(COLOR.WHITE, 0.5);
				blocker.graphics.drawRect(0,0,this.width, this.height);
			} else {
				if (blocker && this.contains(blocker))
					removeChild(blocker);
			}
		}
		
		public function get freeze():Boolean
		{
			return ( blocker && blocker.parent );
		}
		protected function runTask(f:Function, ms:int, n:int=0 ):ITask
		{
			return TaskHelper.access().runLocal(f,ms,n,uid);
		}
		
		
	}
}
// 175 до рефакторинга