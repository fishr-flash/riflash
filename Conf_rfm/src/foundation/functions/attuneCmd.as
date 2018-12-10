package foundation.functions
{
	import components.protocol.statics.OPERATOR;
	import components.static.CMD;
	import components.static.DS;

	public function attuneCmd():void
	{	// функция не может операться на аппаратную версию прибора, она загружается позже
		switch(DS.alias) {
			case DS.MR1:
			case DS.MS1:
			case DS.MT1:
				OPERATOR.getSchema(CMD.ESP_SET_NET).StructCount = 1;
				break;
		}
	}
}