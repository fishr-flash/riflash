package components.protocol.models
{
	import mx.collections.ArrayCollection;
	
	import components.static.CMD;
	
	public final class CommandSchemaModel
	{
		private var name:String;
		private var id:int;
		private var structCount:int;
		private var parameters:ArrayCollection;
	/*	private var readStructSize:uint;
		private var readCommandSize:uint;
		private var writeStructSize:uint;
		private var writeCommandSize:uint;*/
		private var write:String;
		private var feature:String;
		
		public function CommandSchemaModel(name:String, id:int, structCount:int)
		{
			this.name = name;
			this.id = id;
			this.structCount = structCount;
			this.parameters = new ArrayCollection();
		}
		public function GetReadStructSize( _binary:Boolean ):int
		{
			var size:int = 0; 
			var p:ParameterSchemaModel;
			if ( _binary ) 
			{
				if (this.parameters.length != 0)	
				{	
					for each (p in this.parameters)
					{
						size += p.Length;
						if ( p.Type == "String" )
							size++;	// каждый String добивается 00 при окончании
					}
					size += 6; // индекс + структура + длина данных  
				}
			} else {
				size += 2; // окончание каждой строки это \r = 2
				if (this.parameters.length != 0)	
				{	
					for each (p in this.parameters)
					{
						if ( p.Type == "Decimal" )
							size += getDecimalStringLength( p.Length );
						else
							size += p.Length + 2; // строка всегда передается в кавычках
						size += 1; // окончание каждого параметра ","
					}
				}
			}
			return size;
			
			function getDecimalStringLength( _len:int ):int
			{
				var compile:String="0x";
				for(var i:int; i<_len; ++i) {
					compile += "FF";
				}
				return int(compile).toString().length + 1;// +1 для возможонго знака минус
			}
		}
		public function GetReadAllStructsAtonceSize():int
		{
			var size:int = 0; 
			var p:ParameterSchemaModel;
			if (this.parameters.length != 0)	
			{	
				for each (p in this.parameters)
				{
					size += p.Length;
					if ( p.Type == "String" )
						size++;	// каждый String добивается 00 при окончании
				}
			}
			
			return size;
			
			function getDecimalStringLength( _len:int ):int
			{
				var compile:String="0x";
				for(var i:int; i<_len; ++i) {
					compile += "FF";
				}
				return int(compile).toString().length + 1;// +1 для возможонго знака минус
			}
		}
		public function GetReadCommandSize( _binary:Boolean ):int
		{
			// индекс + структура + длина данных
			return 6 + this.GetReadAllStructsAtonceSize() * this.structCount;
		}
		public function GetWriteStructSize( _binary:Boolean ):int
		{
			var size:int = 0;
			var p:ParameterSchemaModel;
			if ( _binary ) {
				if (this.parameters.length != 0)	
				{	
					for each (p in this.parameters)
					{
						if (p.ReadOnly == false) {
							size += p.Length;

							if (p.Type == "String")
								size += 1; // конец строки всегда добивается 0
						}
					}
					size += 6; // индекс + структура + длина данных
				}
			} else {
				if (this.parameters.length != 0)	
				{	
					for each (p in this.parameters)
					{
						if (p.ReadOnly == false)
						{
							size += p.Length + 1; // окончание каждого параметра ","
							if (p.Type == "String")
								size += 2; // строка всегда передается в кавычках
						} else
							size += 1; // окончание каждого параметра ","
					}
				}
			}
			return size;
		}

		public function GetWriteCommandSize( _binary:Boolean ):int
		{
		//	trace( this.Name + " 1struc " + this.GetWriteStructSize( _binary ) + " all struc " + int(this.GetWriteStructSize( _binary ) * this.structCount) )
			
			return this.GetWriteStructSize( _binary ) * this.structCount;
		}

		public function get Parameters():ArrayCollection
		{
			return this.parameters;
		}
		
		public function set Parameters( params: ArrayCollection ):void
		{
			this.parameters = params;
		}
		
		
		public function getParamByStructure(struct:int):ParameterSchemaModel
		{
			return this.parameters[struct-1];
		}

		public function get StructCount():int
		{
			return this.structCount;
		}
		
		public function set StructCount(structCount:int):void
		{
			
			this.structCount = structCount;	
		}

		public function get Id():int
		{
			return this.id;
		}
		
		public function set Id(id:int):void
		{
			this.id = id;	
		}

		public function get Name():String
		{
			return this.name;
		}
		
		public function set Name(name:String):void
		{
			this.name = name;	
		}
		public function set Write(value:String):void
		{
			this.write = value;
		}
		public function get Write():String
		{
			if (!write)
				return this.name;
			return write;
		}
		public function get Feature():String
		{
			return feature;
		}
		public function set Feature(value:String):void
		{
			this.feature = value;
		}
	}
}