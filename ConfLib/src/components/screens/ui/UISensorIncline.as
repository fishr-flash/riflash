package components.screens.ui
{
	import flash.events.Event;
	
	import components.abstract.GroupOperator;
	import components.abstract.functions.loc;
	import components.abstract.servants.TaskManager;
	import components.basement.UI_BaseComponent;
	import components.gui.akc.AkcBox;
	import components.gui.fields.FSCheckBox;
	import components.gui.fields.FSColorSlider;
	import components.gui.fields.FSRadioGroup;
	import components.gui.fields.FSShadow;
	import components.gui.fields.FSSimple;
	import components.gui.fields.FSSlider;
	import components.gui.fields.FormString;
	import components.gui.triggers.TextButton;
	import components.interfaces.IFormString;
	import components.interfaces.ITask;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.protocol.statics.CLIENT;
	import components.resources.SensorMenuMeasures;
	import components.static.CMD;
	import components.static.COLOR;
	import components.static.DS;
	import components.static.PAGE;
	import components.system.UTIL;
	
	public class UISensorIncline extends UI_BaseComponent
	{
		public var blocked:Boolean;
		
		private const MAX_ANGLE:int = 45;
		public static const SPAM_TIMER:int = 100;
		
		public static const STATES:Array = [
			loc("ui_acc_unknown_state"),
			"",
			"",
			loc("ui_acc_no_rest"),
			loc("ui_acc_position_incorrect"),
			loc("ui_acc_calib_success") ];
		
		private var box:AkcBox;
		private var bRemember:TextButton;
		private var task:ITask;
		private var taskstates:ITask;
		
		private var sensor:ColorSensor;
		
		private var go:GroupOperator;
		private var anchor1:int;
		private var anchor2:int;
		
		private var isAcc:Boolean=false;
		
		public function UISensorIncline(group:int=100)
		{
			super();
			
			var shift:int = 300 + 112 - 40;
			globalY += 10;
			toplevel = false;
			globalFocusGroup = group;
			
			go = new GroupOperator;
			
			isAcc = DS.isDevice(DS.ACC2);
			
			
			if ( !isAcc ) {
			
				addui( new FSCheckBox, CMD.VR_SENSOR_SI, loc("ui_acc_evoke_turnover"), null, 1 );
				attuneElement( SensorMenuMeasures.MEASURE_SHIFT_CHECKBOX );
				addui( new FSCheckBox, CMD.VR_SENSOR_SI, loc("ui_acc_evoke_overturn"), null, 2 );
				attuneElement( SensorMenuMeasures.MEASURE_SHIFT_CHECKBOX );
				addui( new FSCheckBox, CMD.VR_SENSOR_SI, loc("ui_acc_evoke_incline"), onIncline, 3 );
				attuneElement( SensorMenuMeasures.MEASURE_SHIFT_CHECKBOX );
				
				drawSeparator(SensorMenuMeasures.MEASURE_SEPARATOR_SIZE);
	
				anchor1 = globalY;
			} else {
				addui( new FSShadow, CMD.VR_SENSOR_SI, "", null, 1 );
				addui( new FSShadow, CMD.VR_SENSOR_SI, "", null, 2 );
				addui( new FSShadow, CMD.VR_SENSOR_SI, "", null, 3 );
			}
				
			addui( new FSColorSlider, CMD.VR_SENSOR_SI, loc("ui_acc_incline_c"), null, 4, [{data:1, label:loc("g_min")},{data:MAX_ANGLE, label:loc("g_max")}] );
			attuneElement( shift );
			(getLastElement() as FSColorSlider).update( 0 );
			globalY += 10;
			go.add("hide", getLastElement() );
			
			addui( new FSSlider, CMD.VR_SENSOR_SI, loc("ui_acc_inc_time"), null, 6, [{data:1, label:loc("g_min")},{data:20, label:loc("g_max")}] );
			attuneElement( shift );
			go.add("hide", getLastElement() );
			
			
			if ( !isAcc ) {
				go.add("hide", drawSeparator(SensorMenuMeasures.MEASURE_SEPARATOR_SIZE));
				
				anchor2 = globalY;
				
				var fsRgroup:FSRadioGroup = new FSRadioGroup( [ {label:loc("ui_acc_ant_forward"), selected:false, id:1 },
					{label:loc("ui_acc_sideways"), selected:false, id:2 },
					{label:loc("ui_acc_usb_forward"), selected:false, id:3 },
					{label:loc("ui_acc_gsm_forward"), selected:false, id:4, x:360, resety:true },
					{label:loc("ui_acc_bat_forward"), selected:false, id:5, x:360 },
					{label:loc("ui_acc_ind_forward"), selected:false, id:6, x:360 }
				], 1, 30 );
				fsRgroup.y = globalY;
				fsRgroup.x = PAGE.CONTENT_LEFT_SHIFT;
				fsRgroup.width = 220;
				addChild( fsRgroup );
				addUIElement( fsRgroup, CMD.VR_SENSOR_SI, 5);
				go.add("up", fsRgroup );
				
				globalY += 95;
				
				bRemember = new TextButton;
				addChild( bRemember );
				bRemember.x = PAGE.CONTENT_LEFT_SHIFT;
				bRemember.y = globalY;
				bRemember.focusgroup = group;
				//globalY += 30;
				bRemember.setUp(loc("ui_acc_rem_start_pos"), onRemember );
				
				go.add("up", bRemember );
				
			} else
				addui( new FSShadow, CMD.VR_SENSOR_SI, "", null, 5 );
			
		
			FLAG_SAVABLE = false;
			addui( new FormString, 2, "", null, 1 ).x = 300;
			attuneElement(400);
			go.add("up", getLastElement() );
		
			if ( !isAcc ) {
				
				go.add("up", drawSeparator(SensorMenuMeasures.MEASURE_SEPARATOR_SIZE) );
				
				var anchor:int = globalY;
				
				addui( new FSSimple, 1, loc("ui_acc_angle_inc"), null, 3 );
				attuneElement(200,60, FSSimple.F_CELL_NOTSELECTABLE);
				go.add("up", getLastElement() );
				addui( new FSSimple, 1, loc("ui_acc_tangage"), null, 2 );
				attuneElement(200,60, FSSimple.F_CELL_NOTSELECTABLE);
				go.add("up", getLastElement() );
				addui( new FSSimple, 1, loc("ui_acc_roll"), null, 1 );
				attuneElement(200,60, FSSimple.F_CELL_NOTSELECTABLE);
				go.add("up", getLastElement() );
				
				globalY = anchor + 3;
				
				addui( new FSColorSlider, 3, "", null, 3, [{data:0, label:loc("g_min")},{data:180, label:loc("g_max")}] ).x = 173 + globalX;
				attuneElement( NaN, NaN, FSColorSlider.F_SLIDER_NOTEDITABLE | FSColorSlider.F_HIDE_VALUE );
				getLastElement().setCellInfo( 180 );
				go.add("up", getLastElement() );
				
				addui( new FSColorSlider, 3, "", null, 2, [{data:-180, label:loc("g_min")},{data:180, label:loc("g_max")}] ).x = 173 + globalX;
				attuneElement( NaN, NaN, FSColorSlider.F_SLIDER_NOTEDITABLE | FSColorSlider.F_HIDE_VALUE );
				getLastElement().setCellInfo( 180 );
				go.add("up", getLastElement() );
				
				addui( new FSColorSlider, 3, "", null, 1, [{data:-180, label:loc("g_min")},{data:180, label:loc("g_max")}] ).x = 173 + globalX;
				attuneElement( NaN, NaN, FSColorSlider.F_SLIDER_NOTEDITABLE | FSColorSlider.F_HIDE_VALUE );
				getLastElement().setCellInfo( 180 );
				go.add("up", getLastElement() );
			}
			box = new AkcBox(50,50,50);
			addChild( box );
			box.x = -60;
			box.y = globalY-100;
			go.add("up", box );
			
			width = 670;
			height = 730;
			starterCMD = CMD.VR_SENSOR_SI;
		}
		override public function put(p:Package):void
		{
			switch(p.cmd) {
				case CMD.VR_SENSOR_SI:
					
					distribute( p.getStructure(), p.cmd );
					task = TaskManager.callLater( onTask, SPAM_TIMER );
					if (!isAcc)
						onIncline(null);
					else {
						if (p.getStructure()[0] != 0) {
							getField(p.cmd,1).setCellInfo(0);
							remember( getField(p.cmd,1) );
						}
						if (p.getStructure()[2] != 1) {
							getField(p.cmd,3).setCellInfo(1);
							remember( getField(p.cmd,1) );
						}
						
					}
					loadComplete();
					break;
				case CMD.VR_SENSOR_SI_XY:
					box.rotate(p.getStructure()[0],p.getStructure(2)[0],0);
					
					(getField(CMD.VR_SENSOR_SI,4) as FSColorSlider).update( UTIL.toSigned(p.getStructure(3)[0],2) / 45 );
					
					if ( !isAcc ) {
						getField(1,1).setCellInfo( UTIL.toSigned(p.getStructure()[0],2) );
						getField(1,2).setCellInfo( UTIL.toSigned(p.getStructure(2)[0],2) );
						getField(1,3).setCellInfo( UTIL.toSigned(p.getStructure(3)[0],2) );
						
						(getField(3,1) as FSColorSlider).update(( UTIL.toSigned(p.getStructure()[0],2) + 180) / 360 );
						(getField(3,2) as FSColorSlider).update((UTIL.toSigned(p.getStructure(2)[0],2) + 180) / 360 );
						(getField(3,3) as FSColorSlider).update(UTIL.toSigned(p.getStructure(3)[0],2) / 180 );
					}
					break;
				case CMD.VR_SENSOR_SI_REMEMBER:
					if (p.getStructure()[0] == 1 || p.getStructure()[0] == 2)
						taskstates.repeat();
					else {
						var f:FormString = getField(2,1) as FormString;
						if (STATES.length > p.getStructure()[0] ) {
							if (p.getStructure()[0] == 3 || p.getStructure()[0] == 4)
								f.setTextColor( COLOR.RED );
							else if (p.getStructure()[0] == 5 )
								f.setTextColor( COLOR.GREEN );
							else
								f.setTextColor( COLOR.BLACK );
							f.setCellInfo( STATES[p.getStructure()[0]] );
						} else {
							f.setTextColor( COLOR.RED );
							f.setCellInfo( loc("ui_acc_cal_not_success") );
						}
						blockNavi = false;
						if (bRemember)
							bRemember.disabled = false;
						blocked = false;
						this.dispatchEvent( new Event( Event.CHANGE ) );
					}
					break;
			}
		}
		override public function open():void
		{
			super.open();
			getField(2,1).setCellInfo("");
			blocked = false;
			if (bRemember)
				bRemember.disabled = false;
			if ( isAcc ) {
				task = TaskManager.callLater( onTask, SPAM_TIMER );
				loadComplete();
			}
		}
		override public function close():void
		{
			super.close();
			if (task)
				task.kill();
			task = null;
			if(taskstates)
				taskstates.kill();
			taskstates = null;
			if ( !isAcc )
				getField(2,1).setCellInfo("");
		}
		private function onRequestStates():void
		{
			RequestAssembler.getInstance().fireEvent( new Request(CMD.VR_SENSOR_SI_REMEMBER, put));
		}
		private function onRemember():void
		{	// Параметр 1 - запомнить начальное положение (0x01)
			RequestAssembler.getInstance().fireEvent( new Request(CMD.VR_SENSOR_SI_REMEMBER, null, 1, [1]));
			if(!taskstates)
				taskstates = TaskManager.callLater(onRequestStates, CLIENT.TIMER_EVENT_DATE_SPAM);
			else
				taskstates.repeat();
			if (bRemember)
				bRemember.disabled = true;
			blockNavi = true;
			blocked = true;
			this.dispatchEvent( new Event( Event.CHANGE ) );
			(getField(2,1) as FormString).setTextColor( COLOR.BLACK );
			getField(2,1).setCellInfo(loc("ui_acc_cal_inprogress"));
		}
		private function onTask():void
		{
			RequestAssembler.getInstance().fireEvent( new Request(CMD.VR_SENSOR_SI_XY, put));
			task.repeat();
		}
	/*	private function onSetST():void
		{
			if (task)
				task.kill();
			var spam:int = int(getField(1,3).getCellInfo());
			task = TaskManager.callLater( onTask, spam );
		}*/
		/*private function onEpilepsy():void
		{
			var b:Boolean = int(getField(1,4).getCellInfo()) == 1;
			sensor.online = b;
		}*/
		private function onIncline(t:IFormString):void
		{
			var f:IFormString = getField( CMD.VR_SENSOR_SI, 3);
			var hide:Boolean = Boolean(f.getCellInfo() == 1);
			go.visible("hide", hide );
			go.movey("up", hide ? anchor2 : anchor1 );
			
			if (t)
				remember(t);
		}
	}
}
import flash.display.Sprite;

import components.static.COLOR;

class ColorSensor extends Sprite
{
	public var online:Boolean=false;
	
	private var red:Boolean;
	
	public function signal():void
	{
		if (online) {
			this.graphics.clear();
			if (red)
				this.graphics.beginFill( COLOR.GREEN_SIGNAL );
			else
				this.graphics.beginFill( COLOR.RED);
			this.graphics.drawRect(0,0,10,10);
			red = !red;
		}
	}
}