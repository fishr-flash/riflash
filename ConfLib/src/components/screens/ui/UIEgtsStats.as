package components.screens.ui
{
	import components.abstract.GroupOperator;
	import components.abstract.functions.loc;
	import components.abstract.servants.TaskManager;
	import components.abstract.servants.WidgetMaster;
	import components.basement.UI_BaseComponent;
	import components.gui.PopUp;
	import components.gui.triggers.TextButton;
	import components.interfaces.IWidget;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.protocol.statics.OPERATOR;
	import components.static.CMD;
	import components.static.MISC;
	import components.static.PAGE;
	
	public class UIEgtsStats extends UI_BaseComponent implements IWidget
	{
		private var opts:Vector.<OptEgtsStat>;
		private var bClear:TextButton;
		private var pageJustOpened:Boolean = true;
		private var go:GroupOperator;
		
		public function UIEgtsStats()
		{
			super();

			go = new GroupOperator;
			go.add("move", drawSeparator(540) );
			
			bClear = new TextButton;
			addChild( bClear );
			bClear.x = globalX;
			bClear.y = globalY;
			bClear.setUp( loc("egts_stat_clear"), onClear );
			go.add("move", bClear );
			
			globalY = PAGE.CONTENT_TOP_SHIFT;
			
			starterCMD = [CMD.EGTS_CNT_STAT_SEND_ENABLE, CMD.EGTS_CNT_STAT_COUNT];
		}
		override public function put(p:Package):void
		{
			switch(p.cmd) {
				case CMD.EGTS_CNT_STAT_SEND_ENABLE:
					if (p.getParamInt(1) != 1) {
						popup = PopUp.getInstance();
						popup.construct( PopUp.wrapHeader("sys_attention"), PopUp.wrapMessage(loc("egts_params_must_be_on")));
						popup.open();
					}
					break;
				case CMD.EGTS_CNT_STAT_COUNT:
					OPERATOR.getSchema( CMD.EGTS_CNT_STAT_VALUE ).StructCount = p.getParamInt(1);
					RequestAssembler.getInstance().fireEvent( new Request(CMD.EGTS_CNT_STAT_VALUE,put));
					starterCMD = [CMD.EGTS_CNT_STAT_SEND_ENABLE, CMD.EGTS_CNT_STAT_VALUE];
					//bClear.disabled = Boolean(p.getParamInt(1) > 2);
					break;
				case CMD.EGTS_CNT_STAT_VALUE:
					if (!opts) {
						opts = new Vector.<OptEgtsStat>;
					}
					
					var len:int = p.length;
					for (var i:int=0; i<len; i++) {
						if (opts.length <= i || !opts[i]) {
							opts.push( new OptEgtsStat(i+1) );
							addChild( opts[i] );
							opts[i].x = globalX;
							opts[i].y = globalY;
							globalY += 27;
							
							go.movey("move", globalY + 10 );
						}
						opts[i].putData(p);
					}
					
					if (pageJustOpened) {
						request();
						pageJustOpened = false;
						WidgetMaster.access().registerWidget(CMD.EGTS_CNT_STAT_VALUE,this);
					}
					
					loadComplete();
					
					if (MISC.COPY_DEBUG)
						RequestAssembler.getInstance().fireEvent( new Request(CMD.PING,put));
					break;
				/*case CMD.PING:
					
					
					break;*/
			}
		}
		override public function close():void
		{
			super.close();
			
			pageJustOpened = true;	// на выходе нужно выставлять флаг, что страница открыта первый раз
			RequestAssembler.getInstance().fireEvent( new Request(CMD.EGTS_CNT_GET_VALUES,put,1,[0]));
			WidgetMaster.access().unregisterWidget(CMD.EGTS_CNT_STAT_VALUE);
		}
		private function request():void
		{
			runTask(request,TaskManager.DELAY_10SEC*2);
			
			RequestAssembler.getInstance().fireEvent( new Request(CMD.EGTS_CNT_GET_VALUES,put,1,[30]));
		}
		private function onClear():void
		{
			runTask(doEnable,TaskManager.DELAY_5SEC,1);
			RequestAssembler.getInstance().fireEvent( new Request(CMD.EGTS_CNT_STAT_VALUE,null,1,[0]));
			RequestAssembler.getInstance().fireEvent( new Request(CMD.EGTS_CNT_STAT_VALUE,null,2,[0]));
			RequestAssembler.getInstance().fireEvent( new Request(CMD.EGTS_CNT_STAT_VALUE,null,3,[0]));
			bClear.disabled = true;
		}
		private function doEnable():void
		{
			bClear.disabled = false;
		}
	}
}
import components.abstract.functions.loc;
import components.basement.OptionsBlock;
import components.gui.fields.FSSimple;
import components.interfaces.IDataAdapter;
import components.interfaces.IFormString;
import components.protocol.Package;
import components.static.CMD;
import components.static.COLOR;
import components.system.UTIL;

class OptEgtsStat extends OptionsBlock
{
	private var ttls:Array = [
		loc("egts_stat_cn100"),loc("egts_stat_cn101"),loc("egts_stat_cn102"),loc("egts_stat_cn103"),
		loc("egts_stat_cn104"),	loc("egts_stat_cn105"), loc("egts_stat_cn110")
	];
	
	public function OptEgtsStat(n:int)
	{
		super();
		
		structureID = n;
		
		var ttl:String = loc("g_unknown");
		if ( !(n > ttls.length) )
		 	ttl = ttls[n-1]; 
		
		addui( new FSSimple, CMD.EGTS_CNT_STAT_VALUE, ttls[n-1], null, 1 );
		attuneElement( 380, 150, FSSimple.F_CELL_NOTSELECTABLE );
		(getLastElement() as FSSimple).setTextColor( COLOR.GREEN );
		getLastElement().setAdapter( new EgtsStatAdapter(n-1));
	}
	override public function putData(p:Package):void
	{
		pdistribute(p);
	}
}
class EgtsStatAdapter implements IDataAdapter
{
	private var iterator:int;
	private var date:Date;
	
	public function EgtsStatAdapter(n:int)
	{
		iterator = n;
	}
	public function adapt(value:Object):Object
	{
		var d:int = int(value);
		switch(iterator) {
			case 5:
				if (!date)
					date = new Date;
				date.time = d*1000;
				return UTIL.getUTCDateStamp(date);
		}
		return d;
	}
	public function change(value:Object):Object	{		return null;	}
	public function perform(field:IFormString):void	{	}
	public function recover(value:Object):Object	{		return null;	}
}