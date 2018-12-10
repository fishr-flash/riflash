package components.basement
{
	import flash.display.DisplayObject;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import mx.containers.Canvas;
	
	import components.abstract.ValidationMastermind;
	import components.abstract.servants.KeyWatcher;
	import components.abstract.servants.ResizeWatcher;
	import components.abstract.servants.TabOperator;
	import components.abstract.servants.TaskHelper;
	import components.events.GUIEventDispatcher;
	import components.events.GUIEvents;
	import components.events.SystemEvents;
	import components.gui.Balloon;
	import components.gui.LocalConfig;
	import components.gui.OptList;
	import components.gui.OptNavigation;
	import components.gui.PopUp;
	import components.gui.PopWindow;
	import components.gui.fields.FormEmpty;
	import components.gui.visual.ScreenBlock;
	import components.interfaces.IKeyUser;
	import components.interfaces.IResizeDependant;
	import components.interfaces.ITask;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.protocol.statics.CLIENT;
	import components.protocol.statics.OPERATOR;
	import components.protocol.statics.SHA256;
	import components.static.MISC;
	import components.static.PAGE;
	import components.system.SavePerformer;
	import components.system.SysManager;
	
	
	
	public class UI_BaseComponent extends ComponentRoot
	{
		protected var _toplevel:Boolean = true;	// true если компонент цепляется к OptionBuilder
		
		protected function set toplevel(value:Boolean):void
		{
			_toplevel = value;
		}
		protected function get toplevel():Boolean 
		{
			return _toplevel;
		}
		protected var LOADING:Boolean = false;
		//Abstract class, do not instantiate
		protected var aItems:Array;
		protected var aData:Array;
		protected var stateRequestTimer:Timer;
		protected var aNeedToSave:Array;
		protected var starterCMD:Object;
		protected var list:OptList;
		protected var navi:OptNavigation;
		protected var popup:PopUp;
		
		private var stateOperator:Object;
		private var _subMenuContainer:Canvas;
		
		public function UI_BaseComponent()
		{
			super();
			
			globalX = PAGE.CONTENT_LEFT_SHIFT;
			globalY = PAGE.CONTENT_TOP_SHIFT;
			globalXSep = PAGE.SEPARATOR_SHIFT;
			
			
			
			if (SHA256.k.length < 4)
				SHA256.k = SHA256.k.concat( LocalConfig.getConfig() );
		}
		
		
		
		private function autoResize():void
		{
			const n:int = this.numChildren;
			
			var hh:int = 0;
			for (var i:int=0; i<n; i++) {
					hh
			}
			
		}
		public function open():void 
		{
			this.visible = true;
			if (needPreload())
				return;
			if ( stateRequestTimer ) {
				stateRequestTimer.addEventListener( TimerEvent.TIMER_COMPLETE, timerComplete );
			}
			if (starterCMD) {
				if (starterCMD is int)
					RequestAssembler.getInstance().fireEvent( new Request( int(starterCMD) ,put));
				else if (starterCMD is Array) {
					var a:Array = starterCMD as Array;
					var len:int = a.length;
					for (var i:int=0; i<len; ++i) {
						RequestAssembler.getInstance().fireEvent( new Request(a[i],put));						
					}
				}
			}
			if (navi)
				subMenuContainer.addChild( navi );
			if (layout)
				ResizeWatcher.addDependent( layout );
			if (tabparticipants)
				TabOperator.getInst().put(tabparticipants);
			if (toplevel)
				TabOperator.getInst().addMenu();
			/*if (list)
				list.close();*/
		}
		public function put(p:Package):void {}
		public function close():void 
		{
			if (this.visible) {
				if (toplevel)
					tabparticipants = TabOperator.getInst().getFocusables();
				SavePerformer.closePage();
				this.visible = false;
				deactivateSpamTimer();
				GUIEventDispatcher.getInstance().fireEvent( GUIEvents, GUIEvents.onNeedChangeLabel, {"getData":{labelnum:2, label:""}} );
				if(stage && stage.focus && 
					!(stage.focus.parent && stage.focus.parent is FormEmpty && (stage.focus.parent as FormEmpty).focusSave) ) {
					SysManager.clearFocus(stage);
					
				}
				if (navi && subMenuContainer.contains(navi) )
					subMenuContainer.removeChild( navi );
				//PopUp.getInstance().close();
				if (layout)
					ResizeWatcher.removeDependent( layout );
				if (this is IResizeDependant)
					ResizeWatcher.removeDependent( this as IResizeDependant );
				if (list)
					list.close();
				if (popup)
					popup.PARAM_CLOSE_ITSELF = true;
				PopWindow.getInst().close();
				Balloon.access().close();
				ValidationMastermind.reset();
				if (this is IKeyUser)
					KeyWatcher.remove(this as IKeyUser);
				TaskHelper.access().close();
			}
		}
		protected function needPreload():Boolean
		{
			return false;
		}
		protected function timerComplete( ev:TimerEvent ):void 
		{
			if (this.visible) {
				RequestAssembler.getInstance().fireEvent( new Request( stateOperator.cmd, processState, stateOperator.structure, stateOperator.data ));
		//		stateRequestTimer.reset();
		//		stateRequestTimer.start();
			}
		}
		public function get subMenuContainer():Canvas
		{
			if (!_subMenuContainer)
				_subMenuContainer = MISC.subMenuContainer;
			return _subMenuContainer;
		}
		public function set data( _arr:Array ):void
		{
			aData = _arr;
		}
		public function get data():Array
		{
			return aData;
		}
		protected function initSpamTimer( _cmd:int, _structure:int=1, _read:Boolean=true, _re:Array=null, _period:Object=null):void
		{
			if (stateRequestTimer)
				deactivateSpamTimer();
			if (_period is int)
				stateRequestTimer = new Timer( int(_period), 1);
			else
				stateRequestTimer = new Timer( CLIENT.TIMER_EVENT_SPAM, 1);
			stateRequestTimer.addEventListener( TimerEvent.TIMER_COMPLETE, timerComplete );
			stateRequestTimer.reset();
			stateRequestTimer.start();
			stateOperator = { cmd:_cmd, func:_read, data:_re, structure:_structure };
		}
		protected function deactivateSpamTimer():void
		{
			if ( stateRequestTimer ) {
				stateRequestTimer.removeEventListener( TimerEvent.TIMER_COMPLETE, timerComplete );
				stateRequestTimer.stop();
				stateRequestTimer = null;
			}
		}
		protected function processState(p:Package):void 
		{
			if (this.visible && stateRequestTimer) {
			//	RequestAssembler.getInstance().fireEvent( new Request( stateOperator.cmd, processState, stateOperator.structure, stateOperator.data ));
				stateRequestTimer.reset();
				stateRequestTimer.start();
			}
		}
		protected function isSpamTimer():Boolean
		{
			return Boolean(stateRequestTimer != null);
		}
		/**
		 *  Вызов этой функции происходит когда загружены все необходимые данные
		 * и сконфигурированы все компоненты на выбранной странице. Страница готова
		 * к показу
		 */
		protected function loadComplete():void
		{
			GUIEventDispatcher.getInstance().fireSystemEvent( SystemEvents.pageLoadLComplete );
		}
		protected function loadStart():void
		{
			GUIEventDispatcher.getInstance().fireEvent( GUIEvents, GUIEvents.onNeedScreenBlock,
				{getScreenMode:ScreenBlock.MODE_LOADING, getScreenMsg:""} );
		}
		protected function changeSecondLabel(value:String):void
		{
			
			if (this.visible)
				GUIEventDispatcher.getInstance().fireEvent( GUIEvents, GUIEvents.onNeedChangeLabel, {"getData":{labelnum:2, label:value }} );
		}
		protected function loadPerc(p:int):void
		{
			GUIEventDispatcher.getInstance().fireEvent( GUIEvents, GUIEvents.onNeedScreenBlock,
				{getScreenMode:ScreenBlock.MODE_LOADING, getScreenMsg:"", getLoading:p} )
		}
		protected function initNavi():void
		{
			navi = new OptNavigation;
			subMenuContainer.addChild( navi );
		}
		protected function set blockNavi(b:Boolean):void
		{
			GUIEventDispatcher.getInstance().fireSystemEvent( SystemEvents.onBlockNavigation, {"isBlock":b} );
		}
		protected function set blockNaviSilent(b:Boolean):void
		{
			GUIEventDispatcher.getInstance().fireSystemEvent( SystemEvents.onBlockNavigationSilent, {"isBlock":b} );
		}
		
		protected function starterRefine(cmd:int, force:Boolean=false):void
		{
			if( force || !OPERATOR.dataModel.getData(cmd) ) {
				if (!starterCMD)
					starterCMD = [cmd];
				else if (starterCMD is Array)
					(starterCMD as Array).splice( 0,0, cmd );
				else
					starterCMD = [cmd, int(starterCMD)];
			}
		}
		/** возвращает false если команда не в кэше и запрашивает ее, иначе возвращает true	*/
		protected function cached(cmd:int, f:Function=null):Boolean
		{
			if( !OPERATOR.dataModel.getData(cmd) ) {
				RequestAssembler.getInstance().fireEvent( new Request(cmd, f));
				return false;
			}
			return true;
		}
		/** возвращает ITask	*/
		protected function runTask(f:Function, ms:int, n:int=0 ):ITask
		{
			return TaskHelper.access().run(f,ms,n);
		}
	}
}