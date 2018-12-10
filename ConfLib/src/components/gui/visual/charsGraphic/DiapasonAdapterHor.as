package components.gui.visual.charsGraphic 
{
	import flash.geom.Rectangle;
	public class DiapasonAdapterHor{
	
	private var _relStepV:Number;
	private var _relMax:Number;
	private var _relMin:Number;
	private var _ownerRect:Rectangle;
	
	public function DiapasonAdapterHor( relMin:Number, relMax:Number, rect:Rectangle = null )
	{
		_relStepV = rect.height / ( relMax - relMin );
		
		
		_relMax = relMax;
		_relMin = relMin;
		_ownerRect = rect;
	}
	
	public function getVPixSize( rel:Number ):Number
	{
		var res:Number = ( rel - _relMin ) * _relStepV;
		if ( res < (0 ) )
					res = 0;
		if ( res > ( ( _relMax - _relMin )  * _relStepV ) )
					res = ( _relMax - _relMin ) * _relStepV;
					
					
		return _ownerRect.height -  res;
	}
	
	public function getHPixSize( rel:Number ):Number
	{
		return  rel * _relStepV;
	}
	
	public function getRelative( pix:Number ):Number
	{
		return _relMin + ( _ownerRect.height - pix ) / _relStepV;
	}
	}

}