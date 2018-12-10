package components.interfaces
{
	public interface ISaveController
	{
		function showSave(b:Boolean):void;
		function saveButtonActive(b:Boolean):void;
		function updateSystemVariables(cmd:int, struct:int, o:Object):void;
	}
}