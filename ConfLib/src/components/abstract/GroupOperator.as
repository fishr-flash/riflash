package components.abstract
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	
	import components.abstract.servants.TaskManager;
	import components.interfaces.IFormString;
	import components.interfaces.ITask;

	public class GroupOperator
	{
		private var groups:Object;
		private var anchors:Object;
		private var patterns:Object;
		
		public var names:Array;
		
		
		public function GroupOperator()
		{
			groups = new Object;
			names = new Array;
		}
		/** Name of group and DisplayObject or Array of DisplayObjects
		 * <br>add("group1", button1) 
		 * <br>add("group1", [button1, button2])
		 * */
		public function add(s:String, d:Object):void
		{
			if (!groups[s])
				groups[s] = [];
			if (d is DisplayObject)
				(groups[s] as Array).push( d );
			else if (d is Array) {
				var len:int = (d as Array).length;
				for (var i:int=0; i<len; ++i) {
					if (d[i] is DisplayObject)
						(groups[s] as Array).push( d[i] );
				}
			}
			
			if( names.indexOf( s ) == -1 )names.push( s );
		}
		public function show(s:String):void
		{
			for (var key:String in groups ) {
				for (var keya:String in groups[key]) {
					(groups[key][keya] as DisplayObject).visible = false; 
				}
			}
			if (groups[s] != null ) {
				for (key in groups[s]) {
					(groups[s][key] as DisplayObject).visible = true; 
				}
			}
		}
		public function activate(s:String):void
		{
			for (var key:String in groups ) {
				for (var keya:String in groups[key]) {
					(groups[key][keya] as DisplayObject).visible = false;
					if (groups[key][keya].hasOwnProperty("disabled")) {
						groups[key][keya]["disabled"] = true;
					}
				}
			}
			if (groups[s] != null ) {
				for (key in groups[s]) {
					(groups[s][key] as DisplayObject).visible = true;
					if (groups[s][key].hasOwnProperty("disabled")) {
						groups[s][key]["disabled"] = false;
					}
				}
			}
		}
		public function enable(s:String):void
		{
			for (var key:String in groups ) {
				for (var keya:String in groups[key]) {
					if (groups[key][keya].hasOwnProperty("disabled")) {
						groups[key][keya]["disabled"] = true;
					}
				}
			}
			if (groups[s] != null ) {
				for (key in groups[s]) {
					if (groups[s][key].hasOwnProperty("disabled")) {
						groups[s][key]["disabled"] = false;
					}
				}
			}
		}
		
		public function setAnchor(s:String, value:int):void
		{
			if( !anchors )
				anchors = new Object;
			anchors[s] = value;
		}
		public function getAnchor(key:String):int
		{
			return anchors[key];
		}
		public function visible(s:String, b:Boolean):void
		{
			
			var key:String;
			if (s) {
				if( groups[s] ) {
					for(key in groups[s] ) {
						(groups[s][key] as DisplayObject).visible = b;
					}
				} else
					trace( "GroupManager: no such group "+s );
			} else {
				for(var g:String in groups ) {
					for(key in groups[g] ) {
						(groups[g][key] as DisplayObject).visible = b;
					}
				}
			}
			
			
		}
		public function disabled(s:String, b:Boolean):void
		{
			var key:String;
			if (s) {
				if( groups[s] ) {
					for(key in groups[s] ) {
						if (groups[s][key] is IFormString)
							(groups[s][key] as IFormString).disabled = b;
						else if ( Object( groups[ s ][ key ]).hasOwnProperty( "disabled" ) )
							( groups[ s ][ key ] as Object ).disabled = b;
					}
				} else
					trace( "GroupManager: no such group "+s );
			} else {
				for(var g:String in groups ) {
					for(key in groups[g] ) {
						if (groups[s][key] is IFormString)
							(groups[s][key] as IFormString).disabled = b;
					}
				}
			}
		}
		
		public function removeFromTheSceneGroups( ):void
		{
			var len:int = names.length;
			for (var i:int=0; i<len; i++) 
				removeFromTheScene( names[ i ] );
			
		}
		public function removeFromTheScene( s:String ):void
		{
			var key:String;
			if( groups[s] ) {
				for(key in groups[s] ) {
					if (groups[s][key] is DisplayObject && (groups[s][key] as DisplayObject ).parent )
						(groups[s][key] as DisplayObject ).parent.removeChild( (groups[s][key] as DisplayObject ) ) 
				}
			} else
				trace( "GroupManager: no such group "+s );
		}
		
		public function addToTheScene( s:String, scene:DisplayObjectContainer ):void
		{
			var key:String;
			if( groups[s] ) {
				for(key in groups[s] ) {
					if (groups[s][key] is DisplayObject )
						scene.addChild( (groups[s][key] as DisplayObject ) ) 
				}
			} else
				trace( "GroupManager: no such group "+s );
		}
		public function movex(s:String, n:Number):void
		{
			var key:String;
			var delta:Number = NaN;
			if (s) {
				if( groups[s] ) {
					for(key in groups[s] ) {
						if (isNaN(delta))
							delta = (groups[s][key] as DisplayObject).x - n;
						(groups[s][key] as DisplayObject).x -= delta;
					}
				} else
					trace( "GroupManager: no such group "+s );
			} else {
				for(var g:String in groups ) {
					delta = NaN;
					for(key in groups[g] ) {
						if (isNaN(delta))
							delta = (groups[s][key] as DisplayObject).x - n;
						(groups[g][key] as DisplayObject).x -= delta;
					}
				}
			}
			/*
			var key:String;
			if (s) {
				if( groups[s] ) {
					for(key in groups[s] ) {
						(groups[s][key] as DisplayObject).x += n;
					}
				} else
					trace( "GroupManager: no such group "+s );
			} else {
				for(var g:String in groups ) {
					for(key in groups[g] ) {
						(groups[g][key] as DisplayObject).x += n;
					}
				}
			}
			*/
		}
		public function movey(s:String, n:Number):void
		{
			var key:String;
			var delta:Number = NaN;
			if (s) {
				if( groups[s] ) {
					for(key in groups[s] ) {
						if (isNaN(delta))
							delta = (groups[s][key] as DisplayObject).y - n;
						(groups[s][key] as DisplayObject).y -= delta;
					}
				} else
					trace( "GroupManager: no such group "+s );
			} else {
				for(var g:String in groups ) {
					delta = NaN;
					for(key in groups[g] ) {
						if (isNaN(delta))
							delta = (groups[s][key] as DisplayObject).y - n;
						(groups[g][key] as DisplayObject).y -= delta;
					}
				}
			}
		}
		public function alpha(s:String, n:Number):void
		{
			var key:String;
			if (s) {
				if( groups[s] ) {
					for(key in groups[s] ) {
						(groups[s][key] as DisplayObject).alpha = n;
					}
				} else
					trace( "GroupManager: no such group "+s );
			} else {
				for(var g:String in groups ) {
					for(key in groups[g] ) {
						(groups[g][key] as DisplayObject).y = n;
					}
				}
			}
		}
		private var smoothqueue:Array
		private var task:ITask;
		private var groupmarker:String;
		public function smoothx(s:String, n:Number):void
		{
			groupmarker = s;
			smoothqueue = new Array;
			smoothqueue.push(int(n/2));
			smoothqueue.push(int(n/4));
			smoothqueue.push(int(n/8));
			smoothqueue.push(int(n/16));
			smoothqueue.push(int(n/32));
			smoothqueue.push( n - (smoothqueue[0] + smoothqueue[1] + smoothqueue[2] + smoothqueue[3] + smoothqueue[4]) );
			
			task = TaskManager.callLater(onTick, 20);
		}
		
		
		private function onTick():void
		{
			movex(groupmarker,smoothqueue.shift());
			if (smoothqueue.length > 0) {
				task.repeat();
			} else
				task.kill();
		}
		
		
		
		/** Params: {x:int, y:int, visible:boolean}	*/
		public function addPattern(s:String,d:Object,params:Object):void
		{
			if(!patterns)
				patterns = new Object;
			if ( !patterns[s] )
				patterns[s] = [];
			(patterns[s] as Array).push({t:d, params:params});
		}
		public function executePattern(key:String, params:Array):void
		{
			var len:int = (patterns[key] as Array).length;
			for (var i:int=0; i<len; ++i) {
				var lenj:int = params.length;
				for (var j:int=0; j<lenj; ++j) {
					switch(params[j]) {
						case "y":
							patterns[key][i].t.y = patterns[key][i].params.y; 						
							break;
						case "x":
							patterns[key][i].t.x = patterns[key][i].params.x;
							break;
						case "visible":
							patterns[key][i].t.visible = patterns[key][i].params.visible;
							break;
					}
				}
			}
		}
	}
}