package functions
{

	import flash.utils.ByteArray;
	
	// ActionScript file
	public function replaceCommand_906( b:ByteArray ):ByteArray
	{
		b.position = 0;
		var xml:XML = XML( b.toString() );
		b.position = 0;
		const param3:XML =  <ParameterDataModel>
									<Order>3</Order>
									<Value>11000</Value>
								</ParameterDataModel>;
		
		const param5:XML =  <ParameterDataModel>
									<Order>5</Order>
									<Value>12000</Value>
								</ParameterDataModel>;
		
		
		const model:XML = xml.CommandDataModel.(Id == 906 )[ 0 ];
		
		/// если данные команды отсутствуют ( напр сохранены не все разделы )
		if( !model ) 
			return b;
		const parent:XML = model.Structures[ 0 ].StructureDataModel[ 0 ].Parameters[ 0 ];
		
		
		const count:int = parent.ParameterDataModel.length();
		if ( count < 5 )
		{
			parent.replace( 2, param3 );
			parent.appendChild( param5 );
		}
		
		
		
		
		b = new ByteArray();
		b.writeUTFBytes( '<?xml version="1.0" encoding="utf-8"?> \r\n' + xml.toString() );
		b.position = 0;
		
		return b;
	}
}
