package components.abstract
{
	public class Templates
	{
		[Embed(source='../../assets/templates/_rels/.rels', mimeType="application/octet-stream")]
		public static const XLSX_RELS:Class;
		
		[Embed(source='../../assets/templates/docProps/app.xml', mimeType="application/octet-stream")]
		public static const XLSX_APP:Class;

		[Embed(source='../../assets/templates/docProps/core.xml', mimeType="application/octet-stream")]
		public static const XLSX_CORE:Class;
		
		[Embed(source='../../assets/templates/xl/_rels/workbook.xml.rels', mimeType="application/octet-stream")]
		public static const XLSX_WORKBOOK_RELS:Class;
		
		[Embed(source='../../assets/templates/xl/theme/theme1.xml', mimeType="application/octet-stream")]
		public static const XLSX_THEME:Class;
		
		[Embed(source='../../assets/templates/xl/worksheets/sheet_start', mimeType="application/octet-stream")]
		public static const XLSX_START:Class;
		[Embed(source='../../assets/templates/xl/worksheets/sheet_end', mimeType="application/octet-stream")]
		public static const XLSX_END:Class;
		
		[Embed(source='../../assets/templates/xl/styles.xml', mimeType="application/octet-stream")]
		public static const XLSX_STYLES:Class;
		
		[Embed(source='../../assets/templates/xl/workbook.xml', mimeType="application/octet-stream")]
		public static const XLSX_WORKBOOK:Class;
		
		[Embed(source='../../assets/templates/[Content_Types].xml', mimeType="application/octet-stream")]
		public static const XLSX_CONTENT_TYPES:Class;
	}
}