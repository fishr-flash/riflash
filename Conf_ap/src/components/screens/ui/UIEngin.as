package components.screens.ui
{
	import components.abstract.functions.loc;
	import components.basement.UI_BaseComponent;
	import components.gui.fields.FSCheckBox;
	import components.gui.fields.FormString;
	import components.interfaces.IFormString;
	import components.protocol.Package;
	import components.protocol.Request;
	import components.protocol.RequestAssembler;
	import components.screens.opt.OptEngineNumb;
	import components.static.CMD;
	
	public class UIEngin extends UI_BaseComponent
	{
		private var screens:Vector.<OptEngineNumb>;
		public function UIEngin()
		{
			super();

			screens = new Vector.<OptEngineNumb>;
			var opt:OptEngineNumb;
			for(var i:int=0; i<5; ++i) {
				opt = new OptEngineNumb(i+1);
				addChild( opt );
				opt.y = globalY;
				opt.x = globalX;
				globalY += opt.getHeight();
				screens.push( opt); 
			}
			globalY += 10;
			drawSeparator(311);
			createUIElement( new FSCheckBox, CMD.OP_E_USE_ENGIN_NUMB, loc("ui_engin_allow_config_from_anytel"),onAnyNumber,1 );
			getLastElement().setAdapter( new Inverter );
			attuneElement( 258,NaN, FormString.F_MULTYLINE );
			
			width = 400;
			height = 390;
		}
		override public function open():void
		{
			super.open();
			
			RequestAssembler.getInstance().fireEvent( new Request( CMD.OP_j_ENGIN_NUMB, put, 1) );
			RequestAssembler.getInstance().fireEvent( new Request( CMD.OP_j_ENGIN_NUMB, put, 2) );
			RequestAssembler.getInstance().fireEvent( new Request( CMD.OP_j_ENGIN_NUMB, put, 3) );
			RequestAssembler.getInstance().fireEvent( new Request( CMD.OP_j_ENGIN_NUMB, put, 4) );
			RequestAssembler.getInstance().fireEvent( new Request( CMD.OP_j_ENGIN_NUMB, put, 5) );
			
			RequestAssembler.getInstance().fireEvent( new Request( CMD.OP_E_USE_ENGIN_NUMB, put, 1 ) );
		}
		override public function put(p:Package):void
		{
			switch( p.cmd ) {
				case CMD.OP_j_ENGIN_NUMB:
					screens[p.structure-1].putRawData( p.getStructure(p.structure) );
					break;
				case CMD.OP_E_USE_ENGIN_NUMB:
					distribute(p.getValidStructure(), p.cmd );
					onAnyNumber(null);
					loadComplete();
					break;
			}
		}
		private function onAnyNumber(t:IFormString):void
		{
			var f:IFormString = getField(CMD.OP_E_USE_ENGIN_NUMB,1);
			var b:Boolean = f.getCellInfo() == 0;
				
			var len:int = screens.length;
			for (var i:int=0; i<len; i++) {
				screens[i].disabled = b;
			}
			if (t)
				remember( getField(CMD.OP_E_USE_ENGIN_NUMB,1) );
		}
	}
}
import components.interfaces.IDataAdapter;
import components.interfaces.IFormString;

class Inverter implements IDataAdapter
{
	public function adapt(value:Object):Object
	{
		if (int(value) == 0)
			return 1;
		return 0;
	}
	public function change(value:Object):Object
	{
		return null;
	}
	public function perform(field:IFormString):void
	{
	}
	public function recover(value:Object):Object
	{
		if (int(value) == 0)
			return 1;
		return 0;
	}
}