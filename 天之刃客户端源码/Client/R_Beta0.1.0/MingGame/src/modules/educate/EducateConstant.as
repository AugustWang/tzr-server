package modules.educate
{
	import com.utils.HtmlUtil;

	public class EducateConstant
	{
		public static const TITLE_NAMES:Array = ["无","初级导师","中级导师","高级导师","一代名师"];
		public static const TOL_VALUES:Array = [35000,35000,80000,200000,500000]; 
		public static const STUDENT_COUNTS:Array = [0,4,5,6,7];
		public static const CONDITIONS:Array = [0,40,1000,3500,7000];
		
		public static const TYPE_BS:int = 1;
		public static const TYPE_ST:int = 2;
		public static const TYPE_YQJB:int = 3;
		
		public static var RELATIVE_SG:int = 1; //师公
		public static var RELATIVE_SF:int = 2; //师傅
		public static var RELATIVE_TM:int = 3; //同门
		public static var RELATIVE_TD:int = 4; //徒弟
		public static var RELATIVE_TS:int = 5; //徒孙
		
		public static var RELATIVES:Array = ["","师祖",HtmlUtil.font("师傅","#fe00e9"),"同门","徒弟","徒孙"];
		public static var RELATIVES_COLORS:Array = ["","#FFD700","#ff7e00","#fe00e9","#0d79ff","#12cc95"];

		public function EducateConstant()
		{
		}
	}
}