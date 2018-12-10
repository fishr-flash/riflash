package components.resources
{
	import components.abstract.functions.loc;
	import components.static.DS;
	import components.system.CONST;

	public class EnergyModeString
	{
		// запрос закголовка для UI (название пункта RadioButton)
		public static function getHeader(num:int):String
		{
			var preset:int = CONST.PRESET_NUM;
			if (DS.isDevice(DS.VL0) )
				preset = 2;
			
			
			if (Strings[preset] && Strings[preset][num] ) 
				return Strings[preset][num].header;
			return defaults[num].header;
		}
		// запрос текста для UI (текст пункта RadioButton)
		public static function getText(num:int):String
		{
			var preset:int = CONST.PRESET_NUM;
			if (DS.isDevice(DS.VL0))
				preset = 2;
				
			if (Strings[preset] && Strings[preset][num] ) 
				return Strings[preset][num].text;
			return defaults[num].text;
		}
		private static var Strings:Vector.<Vector.<Object>> = new <Vector.<Object>>[ null,
			// VL section
			new <Object>[ null,	//	Клон В2
				{header:loc("vem_vl_1h"),
					text:loc("vem_vl_1t")},
				{header:loc("vem_vl_2h"),
					text:loc("vem_vl_2t")},
				{header:loc("vem_vl_3h"),
					text:loc("vem_vl_3t")},
				{header:loc("vem_vl_4h"),
					text:loc("vem_vl_4t")},
				null,
				null
			],
			// V2 section
			new <Object>[ null,
				{header:loc("vem_v2_1h"),
					text:loc("vem_v2_1t")},
				{header:loc("vem_v2_2h"),
					text:loc("vem_v2_2t")},
				{header:loc("vem_v2_3h"),
					text:loc("vem_v2_3t")},
				{header:loc("vem_v2_4h"),
					text:loc("vem_v2_4t")},
				null,
				null
			],
			// V3 section
			new <Object>[ null,
				null,
				{header:loc("vem_v6_1h"),
					text:loc("vem_v6_1t")},
				{header:loc("vem_v6_2h"),
					text:loc("vem_v6_2t")},
				{header:loc("vem_v6_3h"),
					text:loc("vem_v6_3t")},
				null,
				null
			],
			// V4 section
			null,
			// V5 section
			new <Object>[ null,
				null,
				{header:loc("vem_v5_1h"),
					text:loc("vem_v5_1t")},
				{header:loc("vem_v5_2h"),
					text:loc("vem_v5_2t")},
				{header:loc("vem_v5_3h"),
					text:loc("vem_v5_3t")},
				{header:loc("vem_v5_4h"),
					text:loc("vem_v5_4t")},
				null
			],
			// V6 section
			new <Object>[ null,
				null,
				{header:loc("vem_v6_1h"),
					text:loc("vem_v6_1t")},
				{header:loc("vem_v6_2h"),
					text:loc("vem_v6_2t")},
				{header:loc("vem_v6_3h"),
					text:loc("vem_v6_3t")},
				null,
				null
			],
			// V-L0 section
			null,
			// V-BRPM section
			new <Object>[ null,	
				{header:loc("vem_vl_1h"),
					text:loc("vem_vl_1t")},
				{header:loc("vem_vl_2h"),
					text:loc("vem_vl_2t")},
				{header:loc("vem_vl_3h"),
					text:loc("vem_vl_3t")},
				{header:loc("vem_vl_4h"),
					text:loc("vem_vl_4t")},
				null,
				null
			],
		];
		
		private static var defaults:Vector.<Object> = new <Object>[ null,
			{header:loc("vem_def_1h"),
				text:loc("vem_def_1t")},
			{header:loc("vem_def_2h"),
				text:loc("vem_def_2t")},
			{header:loc("vem_def_3h"),
				text:loc("vem_def_3t")},
			{header:loc("vem_def_4h"),
				text:loc("vem_def_4t")},
			{header:loc("vem_def_5h"),
				text:loc("send_coords_shedule")},
			{header:loc("vem_def_6h"),
				text:loc("vem_def_6t")},
		];
	}
}