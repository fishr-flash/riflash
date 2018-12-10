package components.protocol.workers
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	
	import mx.collections.Sort;
	import mx.collections.SortField;
	
	import components.abstract.Warning;
	import components.abstract.functions.loc;
	import components.events.GUIEventDispatcher;
	import components.events.SystemEvents;
	import components.protocol.SocketProcessor;
	import components.protocol.models.CommandSchemaModel;
	import components.protocol.models.ParameterSchemaModel;
	import components.protocol.statics.SERVER;

	public final class CommandSchemaWorker extends EventDispatcher
	{
		private var fileName:String = "CommandOptions.xml";
		private var id:int;
		private var schema:CommandSchemaModel;
		private var xmlData:XML;
		
		private var cmd:Object = new Object;
		
		public var exist:Boolean = true;
		
		public function CommandSchemaWorker( defaultxml:XML=null )
		{
			if ( defaultxml ) {
				xmlData = defaultxml;
				trace( "CMD загрузка дефолта" );
			} else {
				fileName = "CommandOptions." + SERVER.VER+ ".xml"
				var loader:URLLoader = new URLLoader();
				loader.addEventListener(Event.COMPLETE, onFileLoaded);
				loader.addEventListener(IOErrorEvent.IO_ERROR, onFileLoadFailed);
				loader.dataFormat = URLLoaderDataFormat.TEXT;
				loader.load(new URLRequest(this.fileName));
				
				trace( "CMD загрузка " + fileName);
			}
			
		}
		
		private function onFileLoadFailed(event:Event):void
		{
			exist = false;
			SocketProcessor.getInstance().close();
			GUIEventDispatcher.getInstance().fireSystemEvent( SystemEvents.onChangeOnline, {"isConnected":false} );
			trace( "CMD ошибка загрузки " + fileName );
			Warning.show( loc("g_not_found")+" " + fileName, Warning.TYPE_ERROR, Warning.STATUS_DEVICE );
		}
		public function GetSchema(id:int):CommandSchemaModel
		{
			
			this.id = id;
			if ( cmd[id] == null ) {
				return initParsing();
			} else return cmd[id];
		}
		private function onFileLoaded(event:Event):void
		{
			exist = true;
			var loader:URLLoader = URLLoader(event.target);
			xmlData = XML(loader.data);
			
			trace( "CMD загружено" + fileName);
			GUIEventDispatcher.getInstance().fireSystemEvent( SystemEvents.onCommandsLoaded, null );
		}
		private function initParsing():CommandSchemaModel 
		{
			schema = null;
			if ( !xmlData )
				return null;
			var root:XMLList = xmlData.child("Commands");
			var commands:XMLList = root.descendants("Command");
			for each (var command:XML in commands)
			{
				var currentId:int = int(Number(command.Id.toString()));
				if (this.id == currentId)
				{
					var name:String = command.Name.toString();
					var write:String = command.Write;// != null;
					var feature:String = command.Feature;// != null;
					var structCount:int = int(Number(command.StructCount.toString()));
					schema = new CommandSchemaModel(name, currentId, structCount);
					if (write)
						schema.Write = write;
					if (feature)
						schema.Feature = feature;
					var params:XMLList = command.descendants("Parameter");	
					for each (var param:XML in params)	
					{
						var order:int = int(Number(param.Order.toString()));
						var length:int = int(Number(param.Length.toString()));
						var readOnlyString:String = param.ReadOnly.toString().toLowerCase();
						var readOnly:Boolean = (readOnlyString == "false") ? false : true;
						var type:String = param.Type.toString();
						var p:ParameterSchemaModel = new ParameterSchemaModel(type, length, order, readOnly);
						schema.Parameters.addItem(p);
					}
					break;
				}
			}
			if (schema != null)
			{
				var sort:Sort = new Sort();
				sort.fields = [new SortField("Order", false, false)];
				schema.Parameters.sort = sort;
				schema.Parameters.refresh();	
			}
			cmd[this.id] = schema;
			return schema;
		//	var eventX:CommandSchemaEvent = new CommandSchemaEvent(CommandSchemaEvent.ModelLoaded, schema);
		//	dispatchEvent(eventX);
		}
	}
}