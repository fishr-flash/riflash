package components.abstract.functions
{
	public function turnToPartitionBitfield( arr:Array ):int
	{
		var num:int = 0;
		var len:int = arr.length;
		for (var i:int=0; i<len; i++) {
			num |= int(arr[i])
		}
		return num;
	}
}