package components.protocol.statics
{
	import components.abstract.functions.dtrace;
	import components.abstract.offline.OfflineProcessor;
	import components.protocol.SocketProcessor;
	import components.protocol.models.CommandSchemaModel;
	import components.protocol.models.DataModel;
	import components.protocol.workers.CommandSchemaWorker;

	public class OPERATOR
	{
/********************************************************************
 * 		CMD SCHEMA
 * ******************************************************************/
		private static var cmd:CommandSchemaWorker;
		public static function installSchema( defaultxml:XML=null ):void
		{
			cmd = new CommandSchemaWorker( defaultxml );
		}
		public static function getSchema( _id:int ):CommandSchemaModel
		{
			return cmd.GetSchema(_id);
		}
		public static function schemaExist():Boolean
		{
			return cmd.exist;
		}
/********************************************************************
 * 		DATA MODEL
 * ******************************************************************/
		public static function get currentDataModel():DataModel
		{
			if (SocketProcessor.getInstance().connected)
				return dataModel;
			return OfflineProcessor.dataModel;
		}
		private static var datamodel:DataModel;
		public static function get dataModel():DataModel
		{
			if (!datamodel)
				datamodel = new DataModel;
			return datamodel;
		}
		public static function getData(cmd:int):Array
		{
			return dataModel.getData(cmd);
		}
		public static function getParamInt(cmd:int,param:int,structure:int=1):int
		{
			
			try {
				return int(dataModel.getData(cmd)[structure-1][param-1]);
			} catch(error:Error) {
				dtrace( "error@OPERATOR.getParam(cmd:"+cmd+")");
			}
			return -1;
		}
		public static function getParamString(cmd:int,param:int,structure:int=1):String
		{
			try {
				return String(dataModel.getData(cmd)[structure-1][param-1]);
			} catch(error:Error) {
				dtrace( "error@OPERATOR.getParam(cmd:"+cmd+")");
			}
			return null;
		}
		public static function clearDataModel():void
		{
			datamodel = new DataModel;
		}
		public static function update(o:Object):void
		{
			dataModel.update(o);
		//	OfflineProcessor.updateData(o);
		}
	}
}