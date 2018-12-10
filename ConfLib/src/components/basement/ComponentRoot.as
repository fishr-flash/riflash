package components.basement
{
	import flash.display.DisplayObject;
	
	import mx.core.UIComponent;
	
	import components.abstract.servants.TabOperator;
	import components.gui.fields.FSShadow;
	import components.gui.fields.FormEmpty;
	import components.gui.layout.GridLayout;
	import components.gui.visual.Indent;
	import components.gui.visual.Separator;
	import components.interfaces.IFocusable;
	import components.interfaces.IFormString;
	import components.protocol.Package;
	import components.protocol.statics.OPERATOR;
	import components.static.PAGE;
	import components.system.SavePerformer;
	import components.system.UTIL;
	
	/**
	 *  Базовый для классов отображения Opt... и UI..
	 * Является базовым  для  контейнеров всех отображаемых эл-тов.
	 * Размещает, позиционирует, настраивает, передаваемые эл-ты,
	 * предоставляет интерфейс для доступа к размещенным эл-там.
	 *  
	 */
	public class ComponentRoot extends UIComponent
	{
		private var INDEND_SHIFT:int = 0;
		
		protected var aCells:Array;
		protected var globalY:int;
		protected var globalX:int;
		protected var globalXSep:int;
		protected var structureID:int=1;
		protected var hashStructures:Object;
		protected var yshift:int=10;
		protected var xshift:int=10;
		/**
		 * Указывает будет ли нижеследующий элемент использоваться
		 * для считывания информации для отправки на прибор. Как
		 * правило устанавливается перед элементами не несущими
		 * информационной нагрузки с т.з. прошивки прибора.
		 *  
		 */		
		protected var FLAG_SAVABLE:Boolean=true;
		protected var FLAG_VERTICAL_PLACEMENT:Boolean=true;
		protected var FLAG_AUTORESIZE:Boolean=true;
		protected var tabparticipants:Vector.<IFocusable>;
		protected var globalFocusGroup:Number=NaN;
		protected var layout:GridLayout;
		
		private var layoutGroup:int;
		public var dcells:Object = {};
		
		public function ComponentRoot()
		{
			super();
		}
		
		
		
		
		protected function addUIElement( _class:IFormString, _cmd:int, _param:int, _delegate:Function=null, _forceStruct:int=0 ):void
		{
			if ( !aCells )
				aCells = new Array;
			aCells.push( _class );
			
			if ( _delegate == null )
				_class.setUp( remember );
			else
				_class.setUp( _delegate );
			
			_class.param = _param;
			_class.cmd = _cmd;
			if ( FLAG_SAVABLE ) {
				_class.AUTOMATED_SAVE = true;
				var struct:int = _forceStruct > 0 ? _forceStruct:structureID;
				SavePerformer.add( _cmd, struct, _class );
			}
			if (!(_class is FSShadow)) {
				updateSize(_class);
				TabOperator.getInst().add( _class as IFocusable );
			}
		}
		protected function addopt(opt:OptionsBlock):OptionsBlock
		{
			addChild( opt );
			opt.x = globalX;
			opt.y = globalY;
			globalY += opt.complexHeight;
			return opt;
		}
		
		
		
		
		/**
		 * Основной метод для размещения компонентов ( кроме классов FSRadioGroup... ).
		 * ( на самом деле алиас метода createUIElement )
		 * Размещает и регистрирует в системе сохранения ( SavePerformer ).
		 * 
		 * @param _class:Object объект наследующий надкласс FormEmpty
		 * @param _cmd:int код команды, обычно команды протокола, используется для идентификации
		 * @param _name:String собственное имя компонента
		 * @param _delegate:Function функция обработчик которая будет вызвана при загрузке новой информации для эл-та
		 * @param _param:int ид параметра
		 * @param _list:Array
		 * @param _restrict:String допустимые значения которые может хранить этот элемент, например "0-9" - укажет, что в поле можно вводить только цифры 
		 * @param _maxChars:int допустимая длина строки вводимых данных
		 * @param _rule:RegExp регулярное выражение ограничивающее ввод только допустимыми значениями
		 * @return FormEmpty
		 * 
		 */		
		protected function addui( _class:FormEmpty, _cmd:int, _name:String, 
											_delegate:Function, _param:int, _list:Array=null, 
											_restrict:String="", _maxChars:int=0, _rule:RegExp=null ):FormEmpty
		{
			return createUIElement(_class,_cmd,_name,_delegate,_param,_list,_restrict,_maxChars,_rule);
		}
		
		protected function createUIElement( _class:FormEmpty, _cmd:int, _name:String, 
											_delegate:Function, _param:int, _list:Array=null, 
											_restrict:String="", _maxChars:int=0, _rule:RegExp=null ):FormEmpty
		{
			
			
			if (_cmd > 5 ) {
				if( !dcells[ OPERATOR.getSchema(_cmd).Name ] )
					dcells[ OPERATOR.getSchema(_cmd).Name ] = {};
				if( !dcells[ OPERATOR.getSchema(_cmd).Name ][structureID] )
					dcells[ OPERATOR.getSchema(_cmd).Name ][structureID] = [];
				var a1:Array = dcells[ OPERATOR.getSchema(_cmd).Name ][structureID];
				(dcells[ OPERATOR.getSchema(_cmd).Name ][structureID] as Array).push(_param);
			}
			
			if ( !aCells )
				aCells = new Array;
			if( getLastElement() == _class )
				return _class;
			if (_param>0)
				aCells.push( _class );
			
			if (!(_class is FSShadow)) {
				
				TabOperator.getInst().add( _class as IFocusable );
				if (!isNaN(globalFocusGroup))
					(_class as IFocusable).focusgroup = globalFocusGroup;
				
				addChild( _class );
				
				if ( _list )
					_class.setList( _list );
				
				_class.restrict( _restrict, _maxChars );
				if( _rule )	// чтобы не затирать автосгенеренную Re
					_class.rule = _rule;
				
				if (!layout) { 
					_class.x = globalX;
					_class.y = globalY;
					if (INDEND_SHIFT > 0)	// если был сделан отстутп слева, после добавления одоного абзаца надо возвращать отсутп обратно
						globalX = INDEND_SHIFT;
					
					if ( FLAG_VERTICAL_PLACEMENT )
						globalY += _class.getHeight()+yshift;
				} else
					layout.add(_class, layoutGroup);
				
				if ( _delegate == null && FLAG_SAVABLE )
					_class.setUp( remember );
				else
					_class.setUp( _delegate );
				
			}
			
			_class.param = _param;
			_class.cmd = _cmd;
			_class.setName( _name );
			
			if (!(_class is FSShadow))
				updateSize(_class);
			
			if ( FLAG_SAVABLE ) {
				_class.AUTOMATED_SAVE = true;
				SavePerformer.add( _cmd, structureID, _class );
			}
			
			return _class;
		}
		
		
		/**
		 * 
		 *  Настраивает и позиционирует последний виз. элемент добавленный через вызов addui().
		 * 
		 * 
		 * @param   _width ширина первого поля элемента, обычно лейбла, если элемент сам является лейблом то это становится собственно его шириной
		 * @param   _cellWidth ширина 2го эл-та,
		 * @param   _format битовая маска для внутренней обработки элементом
		 * @param   _notDataHolder неиспользуемый парам  
		 * 
		 */
		protected function attuneElement( _width:Number=NaN, _cellWidth:Number=NaN, _format:int=0, _notDataHolder:Boolean=false ):void
		{
			if ( aCells && aCells.length > 0 ) {
				var element:FormEmpty = aCells[ aCells.length-1 ] as FormEmpty;
				if ( !isNaN(_width) ) {
					element.setWidth( _width );
					updateSize(element);
				}
				if ( !isNaN(_cellWidth) ) {
					element.setCellWidth( _cellWidth );
					updateSize(element);
				}
				if ( _format>0 ) 
					element.attune( _format );
				if(_notDataHolder)
					aCells.pop();
			}
		}
		protected function getLastElement():FormEmpty
		{
			if ( aCells && aCells.length > 0 )
				return aCells[ aCells.length-1 ] as FormEmpty;
			return null;
		}
		protected function getLastFocusable():IFocusable
		{
			if ( aCells && aCells.length > 0 )
				return aCells[ aCells.length-1 ] as IFocusable;
			return null;
		}
		protected function elementEnabled(value:Boolean):void
		{
			if ( aCells && aCells.length > 0 ) {
				var element:FormEmpty = aCells[ aCells.length-1 ] as FormEmpty;
				element.disabled = !value;
			}
		}
		public function getStructure():int
		{
			if ( hashStructures )
				return hashStructures[structureID];
			return structureID;
		}
		/**
		 *  Оповестить механизм сохранения об изменении 
		 * данных, в данном случае конкретного поля,
		 * после этого пользователь видит на странице
		 * активную надпись "Сохранить изменения"
		 * 
		 */
		protected function remember(target:IFormString):void
		{
			SavePerformer.remember( getStructure(), target );
		}
		
		/**
		 *  В некоторых случаях необходимо создать поля под той же командой, на разных экранах,
		 * в этом случае оно может не отсылать данные. Эта функция служит для очистки информации
		 * в SavePerformer о данных сформированных ранее, на другой странице...
		 * 
		 * 
		 */
		protected function refreshCells(_cmd:int, cleanCMD:Boolean=true, customStructureID:int=0):void
		{
			if (cleanCMD)
				SavePerformer.remove( _cmd );
			var str:int = structureID;
			if (customStructureID>0)
				str = customStructureID;
			for( var key:String in aCells ) {
				if ( (aCells[key] as IFormString).cmd == _cmd ) {
					SavePerformer.add( _cmd, str, aCells[key] );
					if (!isNaN(globalFocusGroup))
						(aCells[key] as IFocusable).focusgroup = globalFocusGroup;
				}
			}
		}
		
		public function getField(cmd:int,param:int):IFormString
		{ 
			for(var key:String in aCells) {
				if( (aCells[key] as IFormString).param == param && (aCells[key] as IFormString).cmd == cmd )
					return (aCells[key] as IFormString)
			}
			return null;
		}
		protected function mergeIntoTime(first:Object, second:Object):String
		{
			try {
				return UTIL.formateZerosInFront( (first).toString(), 2)+":"+ UTIL.formateZerosInFront( (second).toString(), 2 );
			} catch(error:Error) {
				return "00:00";
			}
			return "00:00";
			
		}
		
		protected function distribute(data:Array, cmd:int):void
		{
			var len:int = data.length;
			for(var i:int=0; i<len; ++i ) {
				getField(cmd,i+1).setCellInfo( data[i] );
			}
		}
		protected function pdistribute(p:Package):void
		{
			distribute(p.getStructure(structureID),p.cmd);
		}
		protected function drawSeparator(value:int=500):Separator
		{
			var sep:Separator = new Separator(value);
			addChild( sep );
			if ( FLAG_VERTICAL_PLACEMENT ) {				
				sep.y = globalY+yshift;
				sep.x = globalXSep;
				globalY += 30;
			}
			updateSize(sep);
			return sep;
		}
		protected function drawIndent(value:int=23):Indent
		{
			INDEND_SHIFT = globalX;
			globalX += PAGE.INDENT_SHIFT;
			
			var ind:Indent = new Indent(value);
			addChild( ind );
			if ( FLAG_VERTICAL_PLACEMENT ) {
				ind.y = globalY;
				ind.x = globalX;
				//globalY += 30;
				globalX += 10;
			}
			updateSize(ind);
			return ind;
		}
		protected function useLayout():void
		{
			layout = new GridLayout(globalY, globalX);
		}
		protected function newLayoutGroup():void
		{
			layoutGroup++;
		}
		private function updateSize(c:Object):void
		{
			const margin:int = 10;
			const wdt:int = c.width + c.x + margin;
			const hgt:int = c.height + c.y + margin;
			
			if( FLAG_AUTORESIZE ) {
				if ( this.width < wdt)
					this.width = wdt;
				if ( this.height < hgt)
					this.height = hgt;
			}
		}
		
		/**
		 * Если последний эл-нт добавляется в контейнер экрана
		 * не через метод addui(); updateSize() автоматически не 
		 * вызывается, поэтому оставляем возможность "ручного" 
		 * вызова ресайза. 
		 * 
		 */		
		public function manualResize():void 
		{
			if( !this.numChildren ) return;
			
			var child:DisplayObject;
			var len:int = this.numChildren;
			for (var i:int=0; i<len; i++) {
				child = this.getChildAt( i );
				if( child.visible && child.alpha ) updateSize( child );
				
			}
			
			
		}
		
		override public function addChild(child:DisplayObject):DisplayObject
		{
			if (child is IFocusable)
				TabOperator.getInst().add(child as IFocusable);
			
			const ch:DisplayObject = super.addChild(child);
			
			manualResize();
			return ch;
		}
		
		override public function removeChild(child:DisplayObject):DisplayObject
		{
			if (child is IFocusable)
				TabOperator.getInst().remove(child as IFocusable);
			
			const ch:DisplayObject = super.removeChild(child);
			
			manualResize();
			return ch;
		}
		
		public function addChildAtypical( dobj:DisplayObject):void
		{
			dobj.x = globalX;
			dobj.y = globalY;
			addChild( dobj );
			globalY += dobj.height;
			manualResize();
			
		}
	}
}