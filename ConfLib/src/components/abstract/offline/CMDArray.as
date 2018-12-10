package components.abstract.offline
{
	public dynamic class CMDArray extends Array
	{
		public var address:int;
		public function CMDArray(adr:int=0)
		{
			address=adr;
			super();
		}
	}
}