package components.gui.visual
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.DropShadowFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import mx.containers.Canvas;
	import mx.core.UIComponent;
	
	import components.abstract.HistoryDataProvider;
	import components.abstract.SharedObjectBot;
	import components.abstract.servants.ResizeWatcher;
	import components.abstract.servants.VoyagerHistoryServant;
	import components.gui.fields.FSCheckBox;
	import components.gui.triggers.TextButton;
	import components.interfaces.IResizeDependant;
	import components.static.COLOR;
	import components.static.PAGE;
	
	import flashx.textLayout.container.ScrollPolicy;
	
	public class HistoryColumnSelector extends UIComponent implements IResizeDependant
	{
		private var fRefresh:Function;
		private var buttons:Vector.<FSCheckBox>;
		private var bOk:TextButton;
		private var bCancel:TextButton;
		private var form:Sprite;
		private var click:Sprite;
		private var bounds:Rectangle;
		private var current:UIComponent;	// то что в данный момент перетаскивается на мышке
		private var cont:Canvas;
		
		private const BUTTON_OK:int = 0;
		private const BUTTON_CANCEL:int = 1;
		private const STROKE_HEIGHT:int = 20;
		private var changed:Boolean;
		
		public function HistoryColumnSelector(dRefresh:Function)
		{
			super();
			this.visible = false;
			
			fRefresh = dRefresh;
			
			var dropShadow:DropShadowFilter = new DropShadowFilter(); 
			dropShadow.distance = 0; 
			dropShadow.angle = 45; 
			dropShadow.color = COLOR.BLACK; 
			dropShadow.alpha = 1; 
			dropShadow.blurX = 5; 
			dropShadow.blurY = 5; 
			dropShadow.strength = 1; 
			dropShadow.quality = BitmapFilterQuality.HIGH; 
			dropShadow.inner = false; 
			dropShadow.knockout = false; 
			dropShadow.hideObject = false; 
			
			click = new Sprite;
			addChild( click );
			click.addEventListener( MouseEvent.CLICK, onClick );
			
			form = new Sprite;
			addChild( form );
			form.filters = new Array(dropShadow);
			form.addEventListener( MouseEvent.ROLL_OUT, onRollOut );
			
			cont = new Canvas;
			addChild( cont );
			cont.width = 510;
			cont.verticalScrollPolicy = ScrollPolicy.ON;
			cont.horizontalScrollPolicy = ScrollPolicy.OFF;
			cont.width = 230;
			cont.y = 10;
			
			bounds = new Rectangle(10);
		}
		public function init():void
		{
			open();
			close(false);
		}
		public function togle():void
		{
			if (this.visible)
				close();
			else
				open();
		}
		public function close(dorefresh:Boolean=true):void
		{
			this.visible = false;
			if (changed) {
				HistoryDataProvider.applyVisibleParams();
				if (dorefresh)
					fRefresh();
				ResizeWatcher.removeDependent( this );
			}
		}
		public function reset():void
		{
			HistoryDataProvider.resetOrder();
			HistoryDataProvider.installParams(null);
			open();
			changed = true;
			close(true);
		}
		private function open():void
		{
			clear();
			
			var params:Object = {
				"HistoryDataProvider.HIS_COLLAPSED_PARAMS":HistoryDataProvider.HIS_COLLAPSED_PARAMS
			}
			var len:int = 256;
			var counter:int = 1;
			for (var i:int=0; i<len; ++i) {
				if (HistoryDataProvider.HIS_COLLAPSED_PARAMS[i] > 0) {
					addButton(VoyagerHistoryServant.PARAMS[i].title, i, counter++);
				}
			}
			if (buttons && buttons.length > 0) {
				
				ResizeWatcher.addDependent( this );
				
				this.visible = true;
				
				bounds.height = buttons.length*STROKE_HEIGHT;
				
				sortList();
			} else
				close();
		}
		private function addButton(title:String, value:int, place:int):void
		{
			if (value != 1) {
				if( !buttons )
					buttons = new Vector.<FSCheckBox>;
				var cb:FSCheckBox = new FSCheckBox;
				cont.addChild( cb );
				cb.setName( title );
				cb.setWidth( 180 );
				cb.setCellInfo( HistoryDataProvider.isVisible(value) );
				cb.setUp(onCheck, value );
				cb.y = buttons.length*STROKE_HEIGHT;
				cb.x = 10;
				cb.storedData = place;
				cb.addEventListener( MouseEvent.MOUSE_DOWN, onMDown );
				cb.addEventListener( MouseEvent.MOUSE_UP, onMUp );
				
				buttons.push( cb );
			}
		}
		private function clear():void
		{
			if (buttons && buttons.length > 0) {
				var len:int = buttons.length;
				for (var i:int=0; i<len; ++i) {
					cont.removeChild( buttons[i] );
				}
				buttons.length = 0;
			}
			changed = false;
		}
		private function onCheck(value:int):void
		{
			var len:int = buttons.length;
			for (var i:int=0; i<len; ++i) {
				if( buttons[i].getId() == value )
					break;
			}
			changed = true;
			HistoryDataProvider.changeParam(value, int(buttons[i].getCellInfo()) );
		}
		private function onClick(e:MouseEvent):void
		{
			close();
		}
		private function onRollOut(e:MouseEvent):void
		{
			if (current) {
				current.stopDrag();
				changed = true;
				buildList();
			}
		}
		private function onMDown(e:MouseEvent):void
		{
			current = e.currentTarget as UIComponent;
			current.startDrag(false,bounds);
		}
		private function onMUp(e:MouseEvent):void
		{
			if (current)
				current.stopDrag();
			else
				(e.currentTarget as UIComponent).stopDrag();
			current = null;
			changed = true;
			buildList();
		}
		private function sortList():void
		{
			HistoryDataProvider.HIS_ORDER_PARAMS = SharedObjectBot.get( SharedObjectBot.HISTORY_ORDER_PARAMS) as Vector.<int>;
			
			if( HistoryDataProvider.HIS_ORDER_PARAMS ) {
				var counter:int;
				var len:int = HistoryDataProvider.HIS_ORDER_PARAMS.length;
				var target:UIComponent;
				for (var i:int=0; i<len; ++i) {
					if (HistoryDataProvider.HIS_ORDER_PARAMS[i] > 0) {
						target = getCheckBoxById( HistoryDataProvider.HIS_ORDER_PARAMS[i] );
						// если при подцеплении из кэша какая то из ссылок не содержит реальной кнопки, значит был подключен другой прибор. Обнуляем список
						if (target)
							target.y = counter++;
						else {
							HistoryDataProvider.HIS_ORDER_PARAMS = new Vector.<int>(256);
							break;
						}
					}
				}
				buildList();
			} else
				HistoryDataProvider.resetOrder();
		}
		private function getCheckBoxById(itemid:int):FSCheckBox
		{
			var len:int = buttons.length;
			for (var i:int=0; i<len; ++i) {
				if( buttons[i].storedData == itemid )
					return buttons[i];
			}
			return null;
		}
		private function buildList():void
		{
			var len:int = buttons.length;
			buttons.sort(sortXorder);
			for (var i:int=0; i<len; ++i) {
				buttons[i].y = i*STROKE_HEIGHT;
				HistoryDataProvider.HIS_ORDER_PARAMS[i] = buttons[i].storedData;
			}
			SharedObjectBot.write( SharedObjectBot.HISTORY_ORDER_PARAMS, HistoryDataProvider.HIS_ORDER_PARAMS );
		}
		private function sortXorder(a:UIComponent, b:UIComponent):int
		{	// идет сортировка от малому к большему
			if( a.y < b.y )
				return -1;
			else if (a.y > b.y)
				return 1;
			return 0;
		}
		public function localResize(w:int, h:int, real:Boolean=false):void
		{
			this.x = ResizeWatcher.lastWidth - 250;
			
			var p:Point  = globalToLocal( new Point );
			
			var theight:int = 0;
			if( buttons )
				theight = buttons.length*STROKE_HEIGHT + 20;
			if (theight > h-21 )
				theight = h - 21;
			
			form.graphics.clear();
			form.graphics.beginFill( COLOR.ANGELIC_GREY );
			form.graphics.drawRoundRect(0,0,240,theight,5,5);
			form.graphics.endFill();
			
			click.graphics.clear();
			click.graphics.beginFill( COLOR.DEVCONSOLE_SYSTEM_BLUE, 0.3);
			click.graphics.drawRect(p.x + PAGE.MAINMENU_WIDTH + 10,p.y + 70,w,h);
			click.graphics.endFill();
			
			cont.height = theight-20;
		}
	}
}