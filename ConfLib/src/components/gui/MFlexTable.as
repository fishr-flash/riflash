package components.gui
{
	import flash.display.Sprite;
	
	import mx.controls.DataGrid;
	import mx.controls.dataGridClasses.DataGridColumn;
	import mx.core.ClassFactory;
	
	import components.interfaces.IMTableAdapter;
	import components.protocol.Package;
	
	public class MFlexTable extends DataGrid
	{
		private var hdr:Array;
		private var colwidth:Array;	// column width, 0 - resizable column
		private var precalculatedwidth:int;	// cuummulative default width of all columns
		private var constwidthcells:int;	// amount of cells that have width > 0
		private var dp:Array;				// source of dataprovider
		
		private var adapter:IMTableAdapter;
		
		public function MFlexTable(ad:IMTableAdapter=null)
		{
			super();
			
			tabFocusEnabled = false;
			
			if (ad)
				adapter = ad;
			
			this.setStyle("headerColors", ["#FF0000", 0x0000FF]);
		}
		/** set up table header: a[ name, name, ... ]	*/
		public function set headers(h:Array):void
		{
			colwidth = new Array;
			
			hdr = [];
			var a:Array = [];
			var len:int = h.length;
			for (var i:int=0; i<len; i++) {
				a.push( getDG(h[i]) );
			}
			columns = a;
			
			function getDG(o:Object):DataGridColumn
			{
				var c:DataGridColumn;
				if(o is String) {
					c = new DataGridColumn(String(o));
					//c.headerRenderer = 
					colwidth.push(0);
					hdr.push( String(o) );
				} else {
					c = new DataGridColumn(o[0]);
					colwidth.push(o[1]);
					constwidthcells++;
					hdr.push( o[0] );
				}
				
				var va:Object = c.headerRenderer;
			
				assignItemRenderer(c);
				assignHeaderRenderer(c,o);
				
				precalculatedwidth += colwidth[colwidth.length-1];
				c.sortable = false;
				return c;
			}
		}
		public function resize():void
		{
			var w:int = width - precalculatedwidth;
			var len:int = columns.length;
			var cellwidth:int = w/(len-constwidthcells);
			for (var i:int=0; i<len; i++) {
				if (colwidth[i] > 0 ) {
					columns[i].width = colwidth[i];
				} else {
					columns[i].width = cellwidth;
				}
			}
		}
		public function clearlist():void
		{
			dp = null;
			this.dataProvider = [];
		}
		/** Array or Package	*/
		public function put(data:Object):void
		{
			dp = [];
			
			var t:Array;
			if (data is Array)
				t = data as Array;
			if (data is Package)
				t = (data as Package).data;
			var len:int = t.length;
			
			for (var i:int=0; i<len; i++) {
				dp.push( getLine(t[i],i) );
			}
			this.dataProvider = dp;
		}
		/** Array or Package	*/
		public function add(p:Package):void
		{
			if( !dp )
				dp = [];
			if (p.length > 0) {
				var len:int = p.length;
				for (var i:int=0; i<len; i++) {
					dp.push( getLine(p.getStructure(i+1),i) );					
				}
			} else
				dp.push( getLine(p.getValidStructure(),0) ); 
			this.dataProvider = dp;
		}
		public function insertStack(a:Array):void
		{
			if( !dp )
				dp = [];
			
			var len:int = a.length;
			for (var i:int=0; i<len; i++) {
				dp.unshift(getLine(a[i],0));
			}
			
			this.dataProvider = dp;
		}
		public function addStack(a:Array):void
		{
			if( !dp )
				dp = [];
			
			var len:int = a.length;
			for (var i:int=0; i<len; i++) {
				dp.push(getLine(a[i],0));
			}
			
			this.dataProvider = dp;
		}
		protected function assignItemRenderer(c:DataGridColumn):void
		{
			if(adapter && adapter.isCellRenderer)
				adapter.assignCellRenderer(c);
		}
		protected function assignHeaderRenderer(c:DataGridColumn, o:Object):void
		{
			c.headerRenderer
				= new ClassFactory(WhiteHeader);
		}
		private function getLine(data:Array, num:int):Object
		{
			var o:Object = {};
			
			var a:Array;
			if( adapter && adapter.isAdapt )
				a = adapter.adapt(data,num);
			else
				a = data.slice();
			var len:int = a.length;
			var hlen:int = hdr.length;
			for (var i:int=0; i<len; i++) {
				if (i < hlen)
					o[hdr[i]] = a[i];
				else {
					o[(i-hlen).toString()] = a[i];
				}
			}
			return o;
		}
		override protected function drawRowBackground(s:Sprite, rowIndex:int, y:Number, height:Number, color:uint, dataIndex:int):void
		{
			var c:uint = color;
			if (adapter && adapter.isRowColor )
				c = adapter.getRowColor(dataIndex,color)
			
			super.drawRowBackground(s,rowIndex,y,height,c,dataIndex);
		}
	}
}
import flash.display.Sprite;

import mx.controls.dataGridClasses.DataGridItemRenderer;

import components.static.COLOR;

class WhiteHeader extends DataGridItemRenderer
{
	public function WhiteHeader():void
	{
		super();
		
		setStyle('fontWeight', 'bold');
		setStyle('textAlign', 'center');
		
		background = true;
		backgroundColor = COLOR.WHITE;
		
		/*border = true;
		borderColor = COLOR.SIXNINE_GREY;*/
	}
	override public function set height(value:Number):void
	{
		super.height = value + 3;
	}
	override public function set y(value:Number):void
	{
		super.y = 0;
	}
}