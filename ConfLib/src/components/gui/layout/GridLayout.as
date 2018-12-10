package components.gui.layout
{
	import components.gui.fields.FormEmpty;
	import components.interfaces.IResizeDependant;

	public class GridLayout implements IResizeDependant
	{
		private var fields:Vector.<FormEmpty>;
		private var groups:Array;
		private var y:int;
		private var x:int;
		
		public function GridLayout(ystart:int, xstart:int)
		{
			y = ystart;
			x = xstart;
		}
		public function add(f:FormEmpty, g:int):void
		{
			if (!fields)
				fields = new Vector.<FormEmpty>;
			fields.push(f);
			f.layoutgroup = g;
		}
		public function localResize(w:int, h:int, real:Boolean=false):void
		{
			if (fields) {
				var i:int;
				var len:int = fields.length;
				var maxw:int;
				var totalh:int;
				groups = new Array;
				
				for (i=0; i<len; i++) {
					if(fields[i].visible) {
						if (!groups[fields[i].layoutgroup])
							groups[fields[i].layoutgroup] = 0;
						groups[fields[i].layoutgroup] += fields[i].getHeight();
						totalh += fields[i].getHeight();
							
						if( maxw < fields[i].width )
							maxw = fields[i].width;
					}
				}
				
				len = groups.length;
				for (i=0; i<len; i++) {
					groups[i] = int((groups[i]/totalh)*100);
				}
				
				var columnw:int = x + maxw;	// ширина колонки
				var columns:int = w/columnw;	// количество колонок
				
				var sorted:Array = sortGroups(columns,maxw);	// массив с группами расставленными по колонкам
				
				var ly:int = y;
				var lx:int = x;
				
				len = fields.length;
				
				for (i=0; i<len; i++) {
					if (fields[i].visible) {
						fields[i].y = ly;
						fields[i].x = x + columnw * sorted[fields[i].layoutgroup];
						ly += fields[i].getHeight();
					}
					
					if( i<(len-1) && sorted[fields[i].layoutgroup] != sorted[fields[i+1].layoutgroup] ) {
						ly = y;
					}
				}
			}
		}
		private function sortGroups(columns:int, maxw:int):Array
		{
			var sorted:Array = [];
			var len:int = groups.length;
			var total:int;
			var current:int;
			for (var i:int=0; i<len; i++) {
				total += groups[i];
				sorted[i] = current;
				if( total >= int(100/columns) ) {
					current++;
					total = 0;
				}
			}
			return sorted;
		}
		private function getGroupWeight(g:int):int
		{
			var len:int = groups.length;
			var weight:int;
			for (var i:int=0; i<len; i++) {
				weight += groups[i];
				if (i == g)
					break;
			}
			return weight;
		}
	}
}