package components.screens.ui
{
	import flash.events.DataEvent;
	
	import components.abstract.functions.loc;
	import components.abstract.servants.WidgetMaster;
	import components.gui.fields.FSSimple;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.static.CMD;
	import components.static.COLOR;

	public class UIDstVerInfo extends UIVersion
	{

		private var widgetAlarm:WidgetDstAlarm;

		private var statesAlarm:Array;
		
		public function UIDstVerInfo()
		{
			super(3);
			
			statesAlarm = [ "<b><font color='#" + COLOR.GREEN_DARK.toString( 16 ) +"' > " + loc( "test_norm" ) + "</font></b>" , 
								"<b><font color='#" + COLOR.RED_BLOOD.toString( 16 ) +"' > " + loc( "sensor_alarm" )  + "</font></b>" ];
			
			addui( new FSSimple, CMD.DST_ALARM, loc( "sensor_state" ), null, 1, null );
			attuneElement( 297, 200, FSSimple.F_CELL_ALIGN_LEFT 
													| FSSimple.F_HTML_TEXT
													| FSSimple.F_CELL_NOTEDITABLE_NOTEDITBOX
													| FSSimple.F_NOTSELECTABLE
													 );
			
			//RequestAssembler.getInstance().fireEvent( new Request( CMD.DST_ALARM, alarmPut ) );
			
			widgetAlarm = new WidgetDstAlarm;
			
			
			WidgetMaster.access().registerWidget( CMD.DST_ALARM, widgetAlarm );
			
			starterCMD = CMD.DST_ALARM;
			
			
		}
		
		override public function put(p:Package):void
		{
			
			alarmPut( p );
			loadComplete();
		}
		
		private function alarmPut( p:Package ):void
		{
						
			getField( CMD.DST_ALARM, 1 ).setCellInfo( statesAlarm[ int( p.data[ 0 ][ 0 ] ) > 0?1:0 ] );
			
		}
		override public function open():void
		{
			
			super.open();
			//RequestAssembler.getInstance().fireEvent( new Request( CMD.DST_ALARM, alarmPut ) );
			widgetAlarm.addEventListener( WidgetDstAlarm.DST_ALARM_EVENT, alarmHandler );
			
		}
		
		protected function alarmHandler(event:DataEvent):void
		{
			
			getField( CMD.DST_ALARM, 1 ).setCellInfo( statesAlarm[ int( event.data ) ] );
			
		}
	}
}
import flash.events.DataEvent;
import flash.events.EventDispatcher;

import components.interfaces.IWidget;
import components.protocol.Package;

class WidgetDstAlarm extends EventDispatcher implements IWidget
{
	public static const DST_ALARM_EVENT:String = "dstAlarmEvent";
	public function put(p:Package):void
	{
		
		this.dispatchEvent( new DataEvent( DST_ALARM_EVENT, false, false, int( p.data[ 0 ][ 0 ] ) > 0?"1":"0"  ) );
	}
	
}