package components.basement
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	
	import mx.controls.ProgressBar;
	import mx.controls.ProgressBarLabelPlacement;
	
	import components.abstract.functions.loc;
	import components.abstract.servants.TabOperator;
	import components.gui.triggers.TextButton;
	import components.interfaces.IFocusable;
	import components.interfaces.IListItem;
	import components.static.COLOR;
	
	public class OptionListBlock extends OptionsBlock implements IListItem
	{
		protected var selection:Sprite;
		protected var vselection:Sprite;
		protected var selector:Sprite;
		private var checkmateBg:Sprite;
		private var _unique:Object;
		
		protected var color_light:int = 0xf5f5f5;
		protected var color_dark:int = 0xededed;
		protected var color_vlight:int = 0xc8c8c8;
		protected var color_vdark:int = 0xaaaaaa;
		protected var SELECTION_X_SHIFT:int = -10;
		protected var SELECTION_Y_SHIFT:int = 0;
		protected var IS_WHITE:Boolean = true;
		
		private var block:Sprite;
		private var invisibleScreen:Sprite;
		private var pBar:ProgressBar;
		private var bCancel:TextButton;
		
		protected var _disabled:Boolean;
		
		public function get disabled():Boolean
		{
			return _disabled;
		}

		public function set disabled(value:Boolean):void
		{
			
			_disabled = value;
			
			var len:int = this.numChildren;
			for (var i:int=0; i<len; i++) 
			{
				if( ( this.getChildAt( i )  as Object ).hasOwnProperty( "disabled" ) )
					( this.getChildAt( i )  as Object ).disabled = _disabled;
				else if( ( this.getChildAt( i )  as Object ).hasOwnProperty( "enabled" ) )
					( this.getChildAt( i )  as Object ).enabled = !_disabled;
				
				if( ( this.getChildAt( i )  as Object ).hasOwnProperty( "mouseEnabled" ) )
					( this.getChildAt( i )  as Object ).mouseEnabled = !_disabled;
				
				if( ( this.getChildAt( i )  as Object ).hasOwnProperty( "mouseChildren" ) )
					( this.getChildAt( i )  as Object ).mouseChildren = !_disabled;
				
				
			}
			
			this.mouseChildren = !_disabled;
			this.mouseEnabled = !_disabled;
			
			if( selection )selection.alpha = _disabled?.4:1;
			
		}

		protected var isUnique:Function;
		
		
		
		public function OptionListBlock()
		{
			super();
			
			selector = new Sprite;
			addChild( selector );
			
			selection = new Sprite;
			addChild( selection );
			selection.visible = false;
			
			vselection = new Sprite;
			addChild( vselection );
			vselection.visible = false;
			
			complexHeight = 25;
		}
		protected function drawSelection(_width:int):void
		{
			selector.graphics.clear();
			selector.graphics.beginFill( 0xffffff, 0 );
			selector.graphics.drawRect(SELECTION_X_SHIFT,SELECTION_Y_SHIFT,_width,complexHeight-2);
			selector.graphics.endFill();
			
			selection.graphics.clear();
			selection.graphics.beginFill( 0xcde0f2 );
			selection.graphics.drawRect(SELECTION_X_SHIFT,SELECTION_Y_SHIFT,_width,complexHeight-2);
			selection.graphics.endFill();
		}
		protected function drawVSelection(_x:int, _width:int):void
		{
			vselection.graphics.clear();
		//	vselection.graphics.beginFill( COLOR.BLUE_LIGHT );
			
			if (IS_WHITE)
				vselection.graphics.beginFill( color_vlight, 0.6 );
			else
				vselection.graphics.beginFill( color_vdark, 0.6 );
			
			vselection.graphics.drawRect(_x,SELECTION_Y_SHIFT,_width,complexHeight-2);
			vselection.graphics.endFill();
		}
		protected function drawScreen():void
		{
			invisibleScreen = new Sprite;
			addChild( invisibleScreen );
			
			invisibleScreen.graphics.clear();
			invisibleScreen.graphics.beginFill( COLOR.WHITE, 0.0 );
			invisibleScreen.graphics.drawRect( 0,0,width,height);
			invisibleScreen.graphics.endFill();
		}
		public function isHeader():Boolean
		{
			return structureID == 0;
		}
		public function isRightClick(d:DisplayObject):Boolean
		{
			return invisibleScreen == d;
		}
		public function drawCheckMate(white:Boolean):void
		{
			IS_WHITE = white;
			
			if(!checkmateBg) {
				checkmateBg = new Sprite;
				addChildAt( checkmateBg,0 );
			}
			checkmateBg.graphics.clear();
			if (white)
				checkmateBg.graphics.beginFill( color_light );//0xf5f5f5 );
			else
				checkmateBg.graphics.beginFill( color_dark ); //0xededed );
			checkmateBg.graphics.drawRect(-10,-1,width,23);
			checkmateBg.graphics.endFill();
		}
		public function selectVertical(xpos:int):void
		{
		}
		public function select(value:Boolean):void
		{
			selection.visible = value;
		}
		public function set setTestUniqueFunction(value:Function):void
		{
			isUnique = value;
		}
		public function getUniqueData(param:int):String 
		{
			return "";
		}
		public function getFieldsData():Array 
		{
			return null;
		}
		public function call(value:Object, param:int):Boolean
		{
			return true;
		}
		public function get selectable():Boolean
		{
			if (block)
				return !block.visible;
			return true;
		}
		public function getUnique():String
		{
			return "";
		}
		public function unFocus():void
		{
			var len:int = this.numChildren;
			for (var i:int=0; i<len; ++i) {
				if( this.getChildAt(i) is IFocusable )
					TabOperator.getInst().remove( this.getChildAt(i) as IFocusable ); 
			}
		}
		public function setUnique(b:Boolean):void {};
		protected function drawLoading(w:int, txt:String, cancel:Function=null):void
		{
			block = new Sprite;
			addChild( block );
			block.graphics.beginFill( 0xffffff );
			block.graphics.drawRect(-10,0,w,23);
			block.graphics.endFill();
			block.visible = false;
			
			pBar = new ProgressBar;
			addChild( pBar );
			pBar.y = 0;
			pBar.x = 10;
			pBar.width = 400;
			pBar.height = 25;
			pBar.label = txt;
			pBar.visible = false;
			pBar.maximum = 100;
			pBar.minimum = 0;
			pBar.enabled = true;
			pBar.indeterminate = true;
			pBar.labelPlacement = ProgressBarLabelPlacement.LEFT;
			
			if (cancel is Function) {
				bCancel = new TextButton;
				addChild( bCancel );
				bCancel.setUp( loc("g_cancel_add"), cancel );
				bCancel.x = pBar.width + pBar.x + 10;
				bCancel.visible = false;
			}
		}
		protected function loadingVisible(value:Boolean):void
		{
			if (block) {
				block.visible = value;
				pBar.visible = value;
				if (bCancel)
					bCancel.visible = value; 
			}
		}
	}
}