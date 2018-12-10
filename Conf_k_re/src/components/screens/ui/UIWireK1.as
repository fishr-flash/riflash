package components.screens.ui
{
	import flash.text.TextFieldAutoSize;
	
	import components.abstract.functions.loc;
	import components.basement.UI_BaseComponent;
	import components.gui.Header;
	import components.protocol.Package;
	import components.static.CMD;
	import components.static.DS;
	
	public class UIWireK1 extends UI_BaseComponent
	{
		private var opts:Vector.<OptPanic>;
		
		public function UIWireK1()
		{
			super();
			
			
			
				
			var header:Header = new Header( configureHeaders() );
			addChild( header );
			header.y = globalY;
			///FIXME: Debug value! Remove it now!
			//header.x = 450;
			
			globalY += 40;
			/**"Команда K9_AWIRE_TYPE -  для записи и чтения параметров шлейфов 
			 Параметр 1 - нормальное состояние шлейфов, значения: 0 - шлейф нормально-разомкнутый, 1 - нормально-замкнутый
			 Параметр 2 - номер раздела, к которому относится шлейф  (значения с 0 по 5 соответствуют разделам с 1 по 6)
			 Параметр 3 - код ACID для шлейфа
			 Параметр 4 - задержка на вход для шлейфа, значение задержки в секундах "													*/
			
			opts = new Vector.<OptPanic>;

			var len:int = DS.release < 9?1:2;
			
			for (var i:int=0; i<len; i++) {
				opts.push( new OptPanic(i+1));
				addChild( opts[i] );
				opts[i].x = globalX;
				opts[i].y = globalY;
				globalY += opts[i].complexHeight;
			}
			
			
			starterCMD = [ CMD.K9_AWIRE_TYPE, CMD.AWIRE_CHANGE_DELAY ];
		}
		override public function put(p:Package):void
		{
			opts[0].putData(p);
			if( opts.length > 1 )opts[1].putData(p);
			if( p.cmd === CMD.AWIRE_CHANGE_DELAY )loadComplete();
		}
		
		private function configureHeaders():Array
		{
			const wths:Array = [ 120, 460, 200, 200 ];
			const locs:Array = [ "description", "event_of_AdemcoId", "input_time_signal_trigger", "k5_wire_norm_state" ];
			var hdrs:Array = [];
			
			var xx:int = 0;
			var ln:int = wths.length;
			for (var j:int=0; j<ln; j++)
			{
				hdrs.push( { label:loc(locs[ j ] ), width:wths[ j ], xpos:xx, align:TextFieldAutoSize.CENTER  } );
				xx += wths[ j ];
			}	
			
			return hdrs;
		}
	}
}
import components.abstract.RegExpCollection;
import components.abstract.adapters.AdapterDottTimes;
import components.abstract.adapters.HexAdapter;
import components.abstract.functions.loc;
import components.abstract.servants.CIDServant;
import components.basement.OptionsBlock;
import components.gui.fields.FSComboBox;
import components.gui.fields.FSShadow;
import components.protocol.Package;
import components.static.CMD;

class OptPanic extends OptionsBlock
{
	public function OptPanic(str:int)
	{
		super();
		
		structureID = str;
		
		operatingCMD = CMD.K9_AWIRE_TYPE;
		
		
		
		addui( new FSShadow, operatingCMD, "", null, 2 );
		
		addui( new FSComboBox, operatingCMD, loc("rf_sen_h_zone") + " "+ str, null, 3, CIDServant.getEvent(CIDServant.CID_K5WIRE) ); //CIDServant.CID_K5WIRE
		attuneElement( 120, 400, FSComboBox.F_COMBOBOX_NOTEDITABLE );
		getLastElement().setAdapter( new HexAdapter );
		
		
		globalX = getLastElement().x + getLastElement().width + 90;
		globalY = getLastElement().y;
		
		
		const tm_list:Array = [
			{ label: 0, data:0 },
			{ label: 1, data:1 },
			{ label: 2, data:2 },
			{ label: 3, data:3 },
			{ label: 4, data:4 },
			{ label: 5, data:5 },
			{ label: 6, data:6 },
			{ label: 7, data:7 },
			{ label: 8, data:8 },
			{ label: 9, data:9 },
			{ label: 10, data:10 }
			];
		
		addui( new FSComboBox, CMD.AWIRE_CHANGE_DELAY, "", null, 1, tm_list, "0-9", 3, new RegExp( RegExpCollection.COMPLETE_0to10and_dot, "simx" ) );
		getLastElement().setCellInfo( 0 );
		getLastElement().setAdapter( new AdapterDottTimes );
		attuneElement( NaN, 60, FSComboBox.F_ALIGN_CENTER );
		
		globalX = getLastElement().x + getLastElement().width + 110;
		globalY = getLastElement().y;
		
		if( structureID == 2 )
		{
			
			
			var mode_list:Array = 
				[ 
					{label: loc( "g_wire_open" ), data:0},
					{label: loc( "g_wire_closed" ), data:1}
					
				];
			
			addui( new FSComboBox, CMD.K9_AWIRE_TYPE, loc( "" ), null, 1,  mode_list  );
			attuneElement( NaN, 170 );
			getLastElement().y = ( getField( operatingCMD, 3 ) as FSComboBox ).y;
			( getLastElement() as FSComboBox ).setCellInfo( 0 );
			
		}
		else
		{
			addui( new FSShadow, operatingCMD, "", null, 1 );
		}
		
		addui( new FSShadow, operatingCMD, "", null, 4 );
		
		complexHeight = getLastElement().height + 15;
	}
	override public function putData(p:Package):void
	{
		pdistribute(p);
	}
}

class HexAdapterCid extends HexAdapter
{
	override public function adapt(value:Object):Object
	{
		/*var r1:String = int(value).toString(16).toUpperCase();
		var r:int =  int("0x"+(int(value)& 0x0FFF));*/
		if (int(value) > 0)
			return (super.adapt(value) as String).slice(1);
		return 0;
	}
	override public function recover(value:Object):Object
	{
		var r:int = int(super.recover(value)) | (1 << 12); 
		return r;
	}
}