package components.protocol.models
{
	public final class ParameterSchemaModel
	{
		private var type:String;
		private var length:int;
		private var order:int;
		private var readOnly:Boolean;
		
		public function ParameterSchemaModel(type:String, length:int, order:int, readOnly:Boolean)
		{
			this.type = type;
			this.length = length;
			this.order = order;
			this.readOnly = readOnly;
		}

		public function get ReadOnly():Boolean
		{
			return this.readOnly;
		}
		
		public function set ReadOnly(readOnly:Boolean):void
		{
			this.readOnly = readOnly;	
		}

		public function get Order():int
		{
			return this.order;
		}
		
		public function set Order(order:int):void
		{
			this.order = order;	
		}

		public function get Length():int
		{
			return this.length;
		}
		
		public function set Length(length:int):void
		{
			this.length = length;	
		}

		public function get Type():String
		{
			return this.type;
		}
		
		public function set Type(type:String):void
		{
			this.type = type;	
		}
	}
}