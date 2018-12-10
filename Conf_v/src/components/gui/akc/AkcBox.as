package components.gui.akc
{
	import flash.display.Sprite;
	
	import components.static.COLOR;
	import components.system.UTIL;
	
	import sandy.core.Scene3D;
	import sandy.core.data.Polygon;
	import sandy.core.scenegraph.Camera3D;
	import sandy.core.scenegraph.Group;
	import sandy.materials.Appearance;
	import sandy.materials.ColorMaterial;
	import sandy.primitive.Box;
	import sandy.primitive.PrimitiveMode;
	
	public class AkcBox extends Sprite
	{
		private var scene:Scene3D;
		private var camera:Camera3D;
		private var primitive:Box;
		
		private const pTextures:Array = [COLOR.RED, COLOR.ORANGE, COLOR.YELLOW_SIGNAL, COLOR.GREEN, COLOR.CIAN, COLOR.BLUE];
		
		public function AkcBox(w:int=0, h:int=0, d:int=0)
		{
			super();
			//camera = new Camera3D(stage.stageWidth,stage.stageHeight);
			
			camera = new Camera3D(400,400);
			// --
			var rootGroup:Group = createScene(h,w,d);
			scene = new Scene3D("akc"+UTIL.generateUId(),this,camera,rootGroup);
			//primitive.rotateX = 0;
			scene.render();
			// --
		}
		private function createScene(w:int, h:int, d:int):Group
		{
			var g:Group = new Group();
			
			if (h==0 && w==0 && d== 0)
				primitive = new Box( "theBox", 80, 10, 50, PrimitiveMode.QUAD, 1 );
			else
				primitive = new Box( "theBox", w, h, d, PrimitiveMode.QUAD, 1 );
			primitive.appearance =  new Appearance(new ColorMaterial(0xFFAF00 ));//new Appearance ( new BitmapMaterial ( getBitmapData(side1) ) );
			var p:Array = primitive.aPolygons;
			for(var i:int=0; i<p.length; ++i ) {
				(p[i] as Polygon).appearance = new Appearance ( (new ColorMaterial ( pTextures[i] )));
			}
			g.addChild( primitive );
			return g;
		}
		public function rotate(rx:int, ry:int, rz:int):void
		{
			primitive.resetCoords();
			primitive.rotateX = -toSigned(ry);
			primitive.rotateY = toSigned(rz);
			primitive.rotateZ = toSigned(rx);
			
			scene.render();
		}
		private function toSigned(n:int, byteLen:int=2):int
		{
			if( (n & (0xf << (8*byteLen-1) )) > 0 )
				return 0xffff0000 | n;
			return n;
		}
	}
}