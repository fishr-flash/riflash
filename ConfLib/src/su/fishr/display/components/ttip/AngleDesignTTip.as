///********************************************************************
///* Copyright © 2013 fishr (fishr.flash@gmail.com)  
///********************************************************************


package su.fishr.display.components.ttip 
{
	
	import flash.display.DisplayObjectContainer;
	import flash.display.Graphics;
	import flash.display.InteractiveObject;
	import flash.events.Event;
	import flash.events.TimerEvent;
	
   

	/**
	 * ...
	 * @playerversion          Flash 9
	 * @langversion            3.0
	 * @author                 fishr
	 * @created                7/22/2013 5:09 
	 * @since                  7/22/2013 5:09 
	 */
	public  class AngleDesignTTip extends SimpleTTTip
	{
	/**-------------------------------------------------------------------------------
	* 
	*	   						V A R I A B L E ' S 	
	* 
	* --------------------------------------------------------------------------------
	*/
	//{
		static private const AUTHOR:String = "fishr (fishr.flash@gmail.com)";
		protected const _ELLIPCE:int = 12;
		
		private const _SIDE_TRIANGLE:int = 10;
		
		
	//}
	
	/**-------------------------------------------------------------------------------
	* 
	*	 						P R O P E R T I E S 	
	* 
	* --------------------------------------------------------------------------------
	*/
	//{
	
	//}
	/**-------------------------------------------------------------------------------
	* 
	*								P U B L I C 	
	* 
	* --------------------------------------------------------------------------------
	*/
	//{
		public function AngleDesignTTip( listenIntObject:InteractiveObject, container:DisplayObjectContainer, tttext:String, mouseOrient:Boolean = false  )
		{
			super(listenIntObject, container, tttext, mouseOrient);
			
		}
		
	//}
	
	/**-------------------------------------------------------------------------------
	* 
	*								P R I V A T E 	
	* 
	* --------------------------------------------------------------------------------
	*/	
	//{
	
		override protected function init( listenIntObject:InteractiveObject, container:DisplayObjectContainer, tttext:String, mouseOrient:Boolean ):void
		{
			_distance = 15;
			super.init( listenIntObject, container, tttext, mouseOrient );
		}
		override protected function timerWaiteComplete(e:TimerEvent):void 
		{
			this.visible = false;
			super.timerWaiteComplete( e );
			drawBack();
			selectPointsDraw();
			this.visible = true;
		}
		
		private function selectPointsDraw():void 
		{
			var ppp:/*Number*/Array = new Array( 6 );
			var basePoint:/*Number*/Array = new Array( 2 );
			
			switch ( _autoAlign) 
			{
				case  ALIGN_TOP:
					
					basePoint[ 0 ] = _stageP[ 0 ] - this.x;
					basePoint[ 1 ] = this.height + _SIDE_TRIANGLE;
					
					if ( _stageP[ 0 ] <  (  this.x + _SIDE_TRIANGLE + _ELLIPCE ) ) basePoint[ 0 ] = _SIDE_TRIANGLE + ( _ELLIPCE * 2 );
					if ( _stageP[ 0 ] > ( this.x + this.width - ( _SIDE_TRIANGLE  + _ELLIPCE  ) ) ) basePoint[ 0 ] = this.width - ( _SIDE_TRIANGLE + _ELLIPCE );
					ppp[ 0 ] = [ basePoint[ 0 ] - _SIDE_TRIANGLE,  this.height ] ;
					ppp[ 1 ] = [ basePoint[ 0 ], basePoint[ 1 ] ];
					ppp[ 2 ] = [ basePoint[ 0 ] + _SIDE_TRIANGLE, this.height  ] ;
					
					ppp[ 3 ] = [ basePoint[ 0 ] - _SIDE_TRIANGLE,  this.height - _shift ] ;
					ppp[ 4 ] = [ basePoint[ 0 ], basePoint[ 1 ]  - _shift] ;
					ppp[ 5 ] = [ basePoint[ 0 ] + _SIDE_TRIANGLE, this.height - _shift  ] ;
					
					drawTriange( ppp );
					
				break;
				
			   case ALIGN_RIGHT:
				
				   basePoint[ 0 ] =  -_SIDE_TRIANGLE;
				   basePoint[ 1 ] =  this.height / 2;
				   
					ppp[ 0 ] = [ 0,  basePoint[ 1 ] - _SIDE_TRIANGLE ] ;
					ppp[ 1 ] = [ basePoint[ 0 ], basePoint[ 1 ] ];
					ppp[ 2 ] = [ 0, basePoint[ 1 ] + _SIDE_TRIANGLE] ;
					
					ppp[ 3 ] = [ 0  + _shift, basePoint[ 1 ] - _SIDE_TRIANGLE ] ;
					ppp[ 4 ] = [ basePoint[ 0 ]   + _shift, basePoint[ 1 ]] ;
					ppp[ 5 ] = [ 0 + _shift , basePoint[ 1 ] + _SIDE_TRIANGLE] ;
					drawTriange( ppp );
					
					break;
				
				case ALIGN_BOTTOM:
					
					basePoint[ 0 ] = _stageP[ 0 ] - this.x;
					basePoint[ 1 ] = 0 - _SIDE_TRIANGLE;
					
					if ( _stageP[ 0 ] <  (  this.x + _SIDE_TRIANGLE + _ELLIPCE ) ) basePoint[ 0 ] = _SIDE_TRIANGLE + _ELLIPCE;
					if ( _stageP[ 0 ] > ( this.x + this.width - ( _SIDE_TRIANGLE  + _ELLIPCE ) ) ) basePoint[ 0 ] = this.width - ( _SIDE_TRIANGLE + _ELLIPCE );
					ppp[ 0 ] = [ basePoint[ 0 ] - _SIDE_TRIANGLE,  basePoint[ 1 ] + _SIDE_TRIANGLE] ;
					ppp[ 1 ] = [ basePoint[ 0 ], basePoint[ 1 ] ];
					ppp[ 2 ] = [ basePoint[ 0 ] + _SIDE_TRIANGLE,  basePoint[ 1 ] + _SIDE_TRIANGLE] ;
					
					ppp[ 3 ] = [ basePoint[ 0 ] - _SIDE_TRIANGLE,  basePoint[ 1 ] + _SIDE_TRIANGLE + _shift] ;
					ppp[ 4 ] = [ basePoint[ 0 ], basePoint[ 1 ] + _shift] ;
					ppp[ 5 ] = [ basePoint[ 0 ] + _SIDE_TRIANGLE,  basePoint[ 1 ] + _SIDE_TRIANGLE + _shift] ;
					drawTriange( ppp );
					
					break;
					
				case ALIGN_LEFT:
					basePoint[ 0 ] = this.width +_SIDE_TRIANGLE;
					basePoint[ 1 ] =  this.height / 2;
					
					ppp[ 0 ] = [ this.width,  basePoint[ 1 ] - _SIDE_TRIANGLE ] ;
					ppp[ 1 ] = [ basePoint[ 0 ], basePoint[ 1 ] ];
					ppp[ 2 ] = [ this.width, basePoint[ 1 ] + _SIDE_TRIANGLE] ;
					
					ppp[ 3 ] = [ this.width  - _shift,  basePoint[ 1 ] - _SIDE_TRIANGLE ] ;
					ppp[ 4 ] = [ basePoint[ 0 ] - _shift, basePoint[ 1 ] ];
					ppp[ 5 ] = [ this.width  - _shift, basePoint[ 1 ] + _SIDE_TRIANGLE] ;
					drawTriange( ppp );
					
					break;
				
				default:
					
				
			}
		}
		
		
		override protected function outHandler( e:Event ):void 
		{
			super.outHandler( e );
			drawBack();
		}
		
		
		protected function drawTriange(  ppp:Array ):void 
		{
			this.graphics.moveTo( ppp[ 0 ][ 0 ], ppp[ 0 ][ 1 ] );
			this.graphics.lineStyle( 0, _colorBack, 0 );
			this.graphics.beginFill( _colorBack);
			this.graphics.lineTo( ppp[ 1 ][ 0 ], ppp[ 1 ][ 1 ] );
			this.graphics.lineTo( ppp[ 2 ][ 0 ], ppp[ 2 ][ 1 ] );
			this.graphics.beginFill( _colorFront )
			this.graphics.moveTo( ppp[ 3 ][ 0 ], ppp[ 3 ] [ 1 ] );
			this.graphics.lineTo( ppp[ 4 ][ 0 ], ppp[ 4 ][ 1 ] );
			this.graphics.lineTo( ppp[ 5 ][ 0 ], ppp[ 5 ][ 1 ] );
			this.graphics.endFill();
			
		}
		
		override protected function drawBack( graphics:Graphics = null):void 
		{
			if ( !graphics ) graphics = this.graphics;
			graphics.clear();
			graphics.beginFill( _colorBack );
			graphics.drawRoundRect( 0, 0, _ttField.width + 20, _ttField.height + 5,  _ELLIPCE, _ELLIPCE );
			graphics.beginFill( _colorFront );
			graphics.drawRoundRect( _shift / 2, _shift / 2, _ttField.width + 20 - _shift, _ttField.height + 5 - _shift , _ELLIPCE, _ELLIPCE);
			graphics.endFill();
		}
	//}
		
		
	}

}