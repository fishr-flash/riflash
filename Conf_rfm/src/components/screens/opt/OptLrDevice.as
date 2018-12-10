package components.screens.opt
{
	import mx.controls.ProgressBar;
	
	import components.abstract.ClientArrays;
	import components.abstract.functions.loc;
	import components.basement.OptionListBlock;
	import components.gui.fields.FormString;
	import components.gui.triggers.TextButton;
	import components.gui.triggers.VisualButton;
	import components.interfaces.IFlexListItem;
	import components.interfaces.IRfDevice;
	import components.interfaces.IRfManager;
	import components.protocol.Package;
	import components.static.CMD;
	import components.static.COLOR;
	import components.static.GuiLib;
	import components.static.RF_STATE;
	
	import su.fishr.utils.searcPropValueInArr;
	
	public class OptLrDevice extends OptionListBlock implements IFlexListItem, IRfDevice
	{
		private const NUM:int=0;
		private const ADDRESS:int=1;
		private const TYPE:int=2;
		
		private static const STATES_LINE:Array =
			[
				{ code:0, state_loc:"rfd_no_add", color: COLOR.RED_DARK},
				{ code:1, state_loc:"rfd_adding", color:COLOR.CIAN },
				{ code:2, state_loc:"rfd_added_success", color:COLOR.CIAN},
				{ code:3, state_loc:"rfd_address_busy", color:COLOR.RED_DARK },
				{ code:4, state_loc:"rfd_add_fail", color:COLOR.RED_DARK },
				{ code:5, state_loc:"rfd_delete_success", color:COLOR.CIAN },
				{ code:6, state_loc:"rfd_delete_fail", color:COLOR.RED_DARK },
				{ code:7, state_loc:"rfd_restore_success", color:COLOR.CIAN },
				{ code:8, state_loc:"rfd_restore_fail", color:COLOR.RED_DARK }
				
			];
		
		private var STATUS:int;
		private var titles:Object;
		
		private var fields:Vector.<FormString>;
		private var pBar:ProgressBar;
		private var bRecover:TextButton;
		private var bCancel:VisualButton;
		private var pack:Package;
		private var manager:IRfManager;
		
		public function OptLrDevice(n:int, m:IRfManager)
		{
			super();
			
			structureID = n;
			manager = m;

			titles = manager.getTitles();
			
			fields = new Vector.<FormString>;
			
			globalX = 10;
			
			FLAG_SAVABLE = false;
			FLAG_VERTICAL_PLACEMENT = false;
			
			addui( new FormString, 0, String(n), null, 1 );
			attuneElement(60,NaN,FormString.F_ALIGN_CENTER );
			fields.push( getLastElement() as FormString);
			
			globalX = getLastElement().width + getLastElement().x;
			
			addui( new FormString, 0, "", null, 2 ).x = 80 + globalX;
			attuneElement(30);
			fields.push( getLastElement() as FormString);
			
			globalX = getLastElement().width + getLastElement().x;
			
			addui( new FormString, 0, "", null, 3 ).x =  globalX + 130;
			attuneElement(300);
			fields.push( getLastElement() as FormString);
			getLastElement().setAdapter( new TypeFieldAdapter );
			
			globalY = getLastElement().getHeight();
			
			SELECTION_Y_SHIFT = -1;
			drawSelection(520);
			
			bRecover = new TextButton;
			addChild( bRecover );
			bRecover.x = fields[TYPE].x + 200;//fields[TYPE].x + (fields[TYPE] as FormString).getWidth();
			bRecover.setUp(loc("g_restore"), onRecover );
			bRecover.visible = false;
			
			pBar = new ProgressBar;
			addChild( pBar );
			pBar.label = "";
			pBar.x = bRecover.x;
			pBar.enabled = true;
			pBar.indeterminate = true;
			pBar.width = 100;
			pBar.height = 5;
			pBar.y = 6;
			pBar.visible = false;
			
			bCancel = new VisualButton(GuiLib.close);
			addChild(bCancel);
			bCancel.x = 80;
			bCancel.setUp("",onAddCancel);
			bCancel.visible = false;
		}
		
		public function setState(n:int, p:Package=null):void
		{
			pBar.visible = false;
			bRecover.visible = false;
			bCancel.visible = false;
			STATUS = n;
			switch(n) {
				case RF_STATE.ADDING:
					pBar.visible = true;
					bCancel.visible = true;
					(fields[TYPE] as FormString).setTextColor( COLOR.CIAN );
					fields[TYPE].setCellInfo(titles["add"]);
					break;
				case RF_STATE.NOTFOUND:
					fields[TYPE].setCellInfo(titles["notfound"]);
					(fields[TYPE] as FormString).setTextColor( COLOR.RED );
					break;
				case RF_STATE.ALREADYEXIST:
					fields[TYPE].setCellInfo(titles["exist"]+ " " + p.getParamInt(2));
					(fields[TYPE] as FormString).setTextColor( COLOR.RED );
					break;
				case RF_STATE.CANCELED:
					fields[TYPE].setCellInfo(titles["cancelled"]);
					(fields[TYPE] as FormString).setTextColor( COLOR.SIXNINE_GREY );
					break;
				case RF_STATE.SUCCESS:
				case RF_STATE.RESTORE_SUCCESS:
					STATUS = RF_STATE.SUCCESS;
					break;
				case RF_STATE.DELETED:
					(fields[TYPE] as FormString).setTextColor( COLOR.ORANGE );
					fields[TYPE].setCellInfo(titles["deleted"]);
					bRecover.visible = true;
					break;
				default:
					put(pack);
					break;
			}
		}
		public function change(p:Package):void
		{
			
		}
		
		public function extract():Array
		{
			return null;
		}
		
		override public function get height():Number
		{
			return globalY;
		}
		
		public function isSelected():Boolean
		{
			return selection.visible;
		}
		
		public function kill():void
		{
		}
		
		public function put(p:Package):void
		{
			pack = p;
			/*if (p.getParamInt(1,structureID) == 1 || p.getParamInt(1,structureID) == 2 ) {
				(fields[TYPE] as FormString).setTextColor( COLOR.BLACK );
				STATUS = RF_STATE.SUCCESS;
				if( p.getParamInt(1,structureID) == 2 ) {
					(fields[TYPE] as FormString).setTextColor( COLOR.RED_BLOOD );
				}
				if (p.cmd == CMD.RF_SENSOR)
					fields[TYPE].setCellInfo( ClientArrays.aSensorTypeNames[ p.getParamInt(3,structureID) ] );
				else
					fields[TYPE].setCellInfo( loc("ui_trinket") );
			}*/
			
			
			/*const index:int = searcPropValueInArr( "code", p.getParamInt( 2, structureID ), STATES_LINE );//.data[ 1 ], STATES_LINE );
			fields[ ADDRESS ].setCellInfo( "10" );
			fields[TYPE].setCellInfo( loc( STATES_LINE[ index ][ "state_loc" ] ) );
			fields[TYPE].setTextColor( STATES_LINE[ index ][ "color" ] )*/
				
			fields[ ADDRESS ].setCellInfo(  structureID  );
			fields[ TYPE ].setCellInfo( p.getParamInt( 2, structureID ) );
		}
		
		public function putRaw(value:Object):void
		{
		}
		
		public function set selectLine(b:Boolean):void
		{
			selection.visible = b;
		}
		
		public function isAddable():Boolean
		{
			return pack.getParamInt(1,structureID) != 1;// && STATUS == RF_STATE.SUCCESS;
		}
		override public function isRemovable():Boolean
		{
			var re1:Boolean = pack.getParamInt(1,structureID) == 1;
			var re2:Boolean = STATUS == RF_STATE.SUCCESS;
			var re3:Boolean = pack.getParamInt(1,structureID) != 1 && STATUS == RF_STATE.SUCCESS;
			return (pack.getParamInt(1,structureID) == 1 || pack.getParamInt(1,structureID) == 2) && STATUS == RF_STATE.SUCCESS;
		}
		
		private function onRecover():void
		{
			manager.restore();
		}
		private function onAddCancel():void
		{
			manager.cancelAdd();
		}
	}
}

import components.abstract.servants.DevicesServant;
import components.interfaces.IDataAdapter;
import components.interfaces.IFormString;

class TypeFieldAdapter implements IDataAdapter
{
	public function change(value:Object):Object { return value; }	// меняет вбитое значение до валидации
	/**
	 * Вызывается при первой загрузке входных данных 
	 * @param value собственно данные полученые с прибора
	 * @return данные которые будут сообщены закрепленному компоненту
	 * 
	 */		
	public function adapt(value:Object):Object
	{
		
		return DevicesServant.instance.getLabel( value as int ); 
	}
	/**
	 * Вызывается при изменении значения эл-та, например
	 * при чеке чекбокса
	 *  
	 * @param value данные полученные компонентом в результате изменения состояния
	 * @return данные которые будут переданны на прибор в результате преобразования
	 * 
	 */		
	public function recover(value:Object):Object 
	{
		
		return DevicesServant.instance.getId( value as String ); 
	}
	/**
	 * Вызывается при первой загрузке входных данных 
	 * @param field элемент за которым закреплен адаптер
	 * @return 
	 * 
	 */	
	public function perform(field:IFormString):void {}
}