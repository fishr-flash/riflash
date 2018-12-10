package components.gui.fields
{
	import components.gui.SimpleTextField;
	import components.gui.fields.lowlevel.MRadio;
	
	import flash.events.MouseEvent;
	
	import mx.controls.RadioButton;
	
	public class FSRadio extends MRadio
	{
		protected var stringId:int;
		protected var fSend:Function;
		
		public var tf:SimpleTextField; 
		
		public function FSRadio()
		{
			super();
			
	//		this.tabEnabled = false;
	//		this.tabFocusEnabled = false;
		}
		public function setName( _name:String ):void 
		{
			if (!tf) {
				tf = new SimpleTextField(_name );
				tf.setSimpleFormat("left",0,14);
				tf.x  = 15;
				tf.y = -10;
				addChild( tf );
				this.width = tf.width+15;
				tf.height = 20;
			} else
				tf.text = _name;
		}
		public function setUp( _fsend:Function, _id:int=-1 ):void 
		{
			stringId = _id;
			fSend = _fsend;
		}
		public function getId():int
		{
			return stringId;
		}
		override protected function mClick(ev:MouseEvent):void
		{
			super.mClick(ev);
			fSend(stringId);
		}
		/*public function get selected():Boolean
		{
			return su.selected;
		}*/
	}
}