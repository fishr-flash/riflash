package components.screens.ui
{
	import flash.utils.getTimer;
	
	import components.abstract.GuardAdapter;
	import components.abstract.RegExpCollection;
	import components.abstract.functions.dtrace;
	import components.abstract.functions.loc;
	import components.basement.UI_BaseComponent;
	import components.gui.fields.FSCheckBox;
	import components.gui.fields.FSComboBox;
	import components.gui.fields.FSSimple;
	import components.gui.triggers.TextButton;
	import components.interfaces.IFormString;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.static.CMD;
	import components.system.UTIL;
	
	public class UIAuthorization extends UI_BaseComponent
	{
		private static const WIDTH_CELL:int = 450;
		private var guardField:FSSimple;
		private var dDisableGuard:TextButton;
		
		public function UIAuthorization()
		{
			super();
			
			init();
		}
		
		private function init():void
		{
			
			
			addui( new FSCheckBox, CMD.VR_IDENT_ENABLE, loc( "authorization_by_thefirst_wire" ), null, 1 );
			attuneElement( WIDTH_CELL, NaN );
			
			/*const time_list:Array  = [{label:"05:00", data:"05:00"},{label:"08:00", data:"08:00"},
				{label:"16:00", data:"16:00"} ];
			addui( new FSComboBox, CMD.VR_IDENT_TIMEOUT, loc("Время действия авторизации, сек."), null, 1, time_list, "0-9:", 5, new RegExp( RegExpCollection.REF_TIME_0000to1600 )  );
			attuneElement( WIDTH_CELL, 70 );
			getLastElement().setAdapter( new TmrResignAdapter );
			getLastElement().setCellInfo( "300" );*/
			
			const time_list:Array  = [{label:"05:00", data:"05:00"},{label:"08:00", data:"08:00"},
				{label:"16:00", data:"16:00"} ];
			addui( new FSComboBox, CMD.VR_IDENT_TIMEOUT, loc("period_authorization"), null, 1, generateListTmOut(), "0-9", 3, new RegExp( RegExpCollection.REF_15to600 )  );
			attuneElement( WIDTH_CELL, 70 );
			///NOTE: Oct 26, 2017, 3:15:36 note В вояджерах секунды передаются без доп. преобразований
			//getLastElement().setAdapter( new TmrResignAdapter );
			getLastElement().setCellInfo( "300" );
			
			addui( new FSCheckBox, CMD.VR_TM_ACTION, loc( "security_function_manage" ), null, 1 );
			attuneElement( WIDTH_CELL, NaN );
			
			starterCMD = [ CMD.VR_IDENT_ENABLE, CMD.VR_IDENT_TIMEOUT, CMD.VR_SMS_GUARD, CMD.VR_TM_ACTION ];
			
			function generateListTmOut():Array
			{
				const len:int = 10;
				const step:int = 15;
				var arr:Array = new Array( len );
				for (var i:int=0; i<len; i++) 
				{
					arr[ i ] = { label:( step + step* i ) + "", data:( step + step* i ) + "" };
				}
				
				return arr;
			}
		}
		
			
		
		override public function put(p:Package):void
		{
			switch( p.cmd ) 
			{
				/*case CMD.VR_IDENT_ENABLE:
					pdistribute( p );
					break;
				*/
				case CMD.VR_IDENT_TIMEOUT:
					pdistribute( p );
					loadComplete();
					break;
				
				case CMD.VR_SMS_GUARD:
					if (!guardField) {
						
						drawSeparator(WIDTH_CELL);
						
						guardField = addui( new FSSimple, CMD.VR_SMS_GUARD, loc("ui_verinfo_guard_mode"), null, 1 ) as FSSimple;
						attuneElement( WIDTH_CELL, NaN, FSSimple.F_CELL_NOTSELECTABLE | FSSimple.F_CELL_ALIGN_LEFT );
						getLastElement().setAdapter( new GuardAdapter );
						
						dDisableGuard = new TextButton;
						addChild( dDisableGuard );
						dDisableGuard.x = globalX + WIDTH_CELL + 110;
						dDisableGuard.y = getLastElement().y;
						dDisableGuard.setUp( loc("g_switchoff"), onChangeStateGuard );
					}
					
					if( p.getStructure()[0] != 0  )
					{
						
						dDisableGuard.setUp( loc("g_switchoff"), onChangeStateGuard );
					}
					else
					{
						
						dDisableGuard.setUp( loc("g_switchon"), onChangeStateGuard );
					}
					distribute(p.getStructure(), p.cmd);
					break;
				
				default:
					pdistribute( p );
					break;
			}
			//RequestAssembler.getInstance().fireEvent( new Request( CMD.ENGIN_NUMB, putEngineNum ) );
			
			
			
		}
		
		private function createTimerList():Array
		{
			var arr:Array = new Array;
			var len:int = 10;
			var multiply:Number = 5;
			var value:Number = multiply;
			for (var i:int=1; i<len; i++) 
			{
				value = i * multiply;
				arr.push( [ value, value ] ); 
			}
			
			return UTIL.getComboBoxList( arr );
		}
		
		private function onChangeStateGuard():void
		{
			const data:int = guardField.getCellInfo() == loc( "g_disabled_m" )?1:0;
			RequestAssembler.getInstance().fireEvent( new Request(CMD.VR_SMS_GUARD, checkStateGuard, 1, [ data ]));
			
		}
		
		private function checkStateGuard(p:Package ):void
		{
			RequestAssembler.getInstance().fireEvent( new Request(CMD.VR_SMS_GUARD, put, 1, null ));
		}
		
		/*private function delegateTOut( ifrm:IFormString ):void
		{
			
			var valCell:String = ifrm.getCellInfo().toString();
			
			var colonId:int = valCell.indexOf( ":" );
			if( valCell.length < 2 ||  colonId == 2 )
																return;
			var letters:Array = valCell.split( "" );
			if( colonId > -1 ) letters.splice( colonId, 1 );
			valCell = ( letters.splice( 2,0,":" ) as Array ).join("");
			
			ifrm.setCellInfo( valCell );
		}	*/
	}
}

import components.gui.fields.FSComboBox;
import components.interfaces.IDataAdapter;
import components.interfaces.IFormString;

class TmrResignAdapter implements IDataAdapter
{
	
	private var _field:FSComboBox;
	public function TmrResignAdapter()
	{
	}
	
	public function change(value:Object):Object
	{
		return value;
	}
	
	public function adapt(value:Object):Object
	{
		const res:String = Number( int( value ) * .1 ).toFixed( 0 ) ; 
		return res;
	}
	
	public function recover(value:Object):Object
	{
		
		const res:int = Number( value ) / .1 ; 
		
		return res;
	}
	
	public function perform(field:IFormString):void
	{
		_field = field as FSComboBox;
	}
}
/*import components.gui.fields.FSComboBox;
import components.interfaces.IDataAdapter;
import components.interfaces.IFormString;
import components.system.UTIL;

class TmrResignAdapter implements IDataAdapter
{
	
	public function adapt(value:Object):Object
	{
		
		var n:int = int(value);
		var h:int = Math.floor(n/60);
		var m:int = n - h*60;
		return UTIL.fz(h,2)+":"+UTIL.fz(m,2);
	}
	public function change(value:Object):Object
	{
		return value;
	}
	public function perform(field:IFormString):void
	{
		
	}
	public function recover(value:Object):Object
	{
		
		var res:int = 0;
		
		var h:int = int(String(value).slice(0,2));
		var m:int = int(String(value).slice(3,5));
		res = h*60+m;
		
		return res; 
	}
}*/