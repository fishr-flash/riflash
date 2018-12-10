package foundation.functions
{
	import mx.collections.ArrayCollection;
	
	import components.protocol.models.ParameterSchemaModel;
	import components.protocol.statics.OPERATOR;
	import components.static.CMD;
	import components.static.DS;

	public function passLocalRules():Boolean
	{
		switch(DS.alias) {
			case DS.isfam( DS.K5 ):
				// В релизе 5 изменилась длина параметра p1: 1 -> 2
				if (DS.release <= 4) {
					var a:ArrayCollection = OPERATOR.getSchema( CMD.K5_TIME_CPW).Parameters;
					(a[0] as ParameterSchemaModel).Length = 1;
				}
				break;
			case DS.K9:
			case DS.K9A:
			case DS.K9M:
			case DS.K9K:
				if (int(DS.app) == 3) {
					OPERATOR.getSchema( CMD.K5_G_PHONE).StructCount = 1;
					OPERATOR.getSchema( CMD.K5_G_APN).StructCount = 1;
					OPERATOR.getSchema( CMD.K5_G_APN_LOG).StructCount = 1;
					OPERATOR.getSchema( CMD.K5_G_APN_PASS).StructCount = 1;
				}
				break;
			case DS.K1:
			case DS.K1M:
				OPERATOR.getSchema( CMD.K5_G_PHONE).StructCount = 1;
				OPERATOR.getSchema( CMD.K5_G_APN).StructCount = 1;
				OPERATOR.getSchema( CMD.K5_G_APN_LOG).StructCount = 1;
				OPERATOR.getSchema( CMD.K5_G_APN_PASS).StructCount = 1;
				break;
		}
		return true;
	}
}