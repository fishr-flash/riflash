package components.screens.opt
{
	import flash.utils.ByteArray;
	
	import components.abstract.functions.loc;
	import components.abstract.servants.Queuebot;
	import components.abstract.servants.TabOperator;
	import components.basement.OptionListBlock;
	import components.gui.SimpleTextField;
	import components.gui.fields.FormString;
	import components.protocol.RequestAssembler;
	
	public class OptFirmwareItem extends OptionListBlock
	{
		public var file:String="";
		
		private var fsname:FormString;
		private var fsinfo:SimpleTextField;
		
		private const title:String = loc("sys_build_ver")+" ";
		
		public function OptFirmwareItem(value:int)
		{
			super();
			
			structureID = value;
			complexHeight = 50;
			drawSelection(525);
			
			FLAG_VERTICAL_PLACEMENT = false;
			FLAG_SAVABLE = false;
			fsname = createUIElement( new FormString, 0, "name", null, 1 ) as FormString; 
			//fsname.attune( FormString.F_EDITABLE );
			//TabOperator.getInst().add( fsname );
			var fake:FocusableFake = new FocusableFake;
			addChild( fake );
			TabOperator.getInst().add( fake );
			
			fsinfo = new SimpleTextField("", 300 );
			addChild( fsinfo );
			fsinfo.setSimpleFormat("left",5);
			fsinfo.x = 160;
			fsinfo.width = 354;
			fsinfo.height = 48;
			fsinfo.wordWrap = true;
			//fsinfo.border = true;
		}
		override public function putRawData(data:Array):void
		{
			file = data[0];
			fsname.setCellInfo( title+file );
			if (data[1] == true) {
		//		callLater( RequestAssembler.getInstance().HTTPRequest, ["upgrade."+ file + ".info", onGetInfo] );
				callLater( Queuebot.access().add, [ 
					function():void {
						RequestAssembler.getInstance().HTTPRequest("upgrade."+ file + ".info", Queuebot.access().got)
					}, onGetInfo ]
				);
			} else
				fsinfo.text = "";
		}
		
		private function onGetInfo(a:Array):void
		{
			var b:ByteArray = a[0];
			var s:String = b.readUTFBytes(b.bytesAvailable);
			fsinfo.text = s;
		}
	}
}
import flash.display.InteractiveObject;
import flash.display.Sprite;

import components.abstract.servants.TabOperator;
import components.interfaces.IFocusable;

class FocusableFake extends Sprite implements IFocusable
{
	private var order:Number;
	private var group:Number;

	public function FocusableFake(_order:int=0)
	{
		order = order;
		group = TabOperator.GROUP_TABLE;
	}
	public function doAction(key:int, ctrl:Boolean=false, shift:Boolean=false):void
	{
		
	}
	public function focusSelect():void
	{
		
	}
	public function set focusable(b:Boolean):void
	{
		
	}
	public function get focusable():Boolean
	{
		return true;
	}
	public function set focusgroup(value:Number):void
	{
		group = value;
	}
	public function set focusorder(value:Number):void
	{
		order = value;	
	}
	public function get focusorder():Number
	{
		return order + group;
	}
	public function getFocusField():InteractiveObject
	{
		return this;
	}
	public function getFocusables():Object
	{
		return this;
	}
	public function getType():int
	{
		return TabOperator.TYPE_NORMAL;
	}
	public function isPartOf(io:InteractiveObject):Boolean
	{
		return this == io;
	}
}