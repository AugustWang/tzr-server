package modules.help
{
	import com.loaders.CommonLocator;
	import com.ming.core.IDataRenderer;
	import com.ming.events.ItemEvent;
	import com.ming.ui.constants.ScrollPolicy;
	import com.ming.ui.containers.List;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.TextInput;
	import com.ming.ui.controls.core.UIComponent;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	import modules.help.itemrender.ListItem;
	import modules.help.vo.SearchResult;
	
	public class SearchView extends UIComponent
	{
		//搜索框
		private var searchText:TextInput;
		//搜索后的list列表
		private var searchList:List;
		//搜索后每一项的详细信息
		private var infoView:InfoView;
		//搜索结果
		private var result:Array;
//		//疑问关键词
		private var doubtArray:Array = ["吗","怎么","什么","如何","哪里","哪个","哪些"];
//		//对象关键词
		private var objectArray:Array = ["银子","快捷键","技能书","礼包","投诉","精力值","活跃度","五行","蝶恋花","天工开物","师徒","收徒","拜师","出师","师德值","游戏","任务","私聊","离线挂机","升级","活动","银两","元宝","宠物","神农架","副本","国家","转职","人物","红名","组队","坐骑","装备"];
//		
		public function SearchView()
		{
			super();
			initUI();
			initData();
		}
		
		private function initData():void
		{
			// TODO Auto Generated method stub
			result = new Array();
		}
		
		private function initUI():void
		{
			// TODO Auto Generated method stub背景
			var bgBorder:UIComponent = new UIComponent();
//			Style.setBorderSkin(bgBorder);
			Style.setNewBorderBgSkin(bgBorder);
			bgBorder.x = 3;
			bgBorder.y = 3;
			bgBorder.width = 525;
			bgBorder.height = 315;//320
			bgBorder.mouseChildren = false;
			bgBorder.mouseEnabled = false;
			addChild(bgBorder);
			
			searchText = new TextInput();
			searchText.x = 7;
			searchText.y = 20;
			searchText.width = 110;
			addChild(searchText);
			var searchBTN:Button = new Button();
			searchBTN.width = 60;
			searchBTN.height = searchText.height;
			searchBTN.label = "查询";
			searchBTN.x = searchText.x + searchText.width + 10;
			searchBTN.y = searchText.y;
			searchBTN.addEventListener(MouseEvent.CLICK, onClickHandle);
			addChild(searchBTN);
			
			//左右背景
//			var left:Sprite = Style.getBlackSprite(200, 320, 3);
//			var right:Sprite = Style.getBlackSprite(320, 320, 3);
			var left:UIComponent=new UIComponent();
			left.width=200;
			left.height=320;
			var right:UIComponent=new UIComponent();
			right.width=320;
			right.height=320;
			right.x = left.x + left.width + 1;
			bgBorder.addChild(left);
			bgBorder.addChild(right);
			
			searchList = new List();
			searchList.itemRenderer = ListItem;
			searchList.x = searchText.x+3;
			searchList.y = searchText.y + searchText.height + 10;
			searchList.verticalScrollPolicy=ScrollPolicy.AUTO;
			searchList.width = 185;
			searchList.height = 260;
			searchList.addEventListener(ItemEvent.ITEM_CLICK, onMouseHandle);
			addChild(searchList);
			
			infoView = new InfoView();
			infoView.verticalScrollPolicy = ScrollPolicy.AUTO;
			infoView.x = right.x;
			infoView.y = right.y;
			addChild(infoView);
		}
		
		protected function onMouseHandle(event:ItemEvent):void
		{
			// TODO Auto-generated method stub
			var select:SearchResult = event.selectItem as SearchResult;
			infoView.otherData = select;
		}
		
		
		//记录上一次搜索的信息
		private var last_search:String = null;
		protected function onClickHandle(event:MouseEvent):void
		{
			// TODO Auto-generated method stub
			if(searchText.text != null && searchText.text != ""){
				//判断，不给重复搜索相同的字
				if(last_search == null || last_search != searchText.text){
					last_search = searchText.text;
					searchData(searchText.text);
				}
			}
		}
		
		/**
		 * 查询
		 * @param searchText
		 * 
		 */		
		public function searchData(searchText:String):void
		{
			if(result.length != 0){
				result.length = 0;
			}
			// TODO Auto Generated method stub
			var xml:XML = CommonLocator.getXML(CommonLocator.HELP);
			var category_length:int = xml.category.length();
			for(var i:int=0; i<category_length; i++){
				//子对象
				var subject_length:int = xml.category[i].subject.length();
				for(var j:int=0; j<subject_length; j++){
					var data:XML = xml.category[i].subject[j];
					addColor(data,searchText);
				}
			}
			
			//赋值给list
			searchList.dataProvider = result;
		}
		
		/**
		 * 
		 * @param search
		 * 查询的另一种形式,放在聊天处的
		 */		
		public function searchOtherWay(search:String):String{
			//查看发送的字符里有没有疑问句
			var hasDoubt:Boolean = checkHasDoubt(search);
			if( hasDoubt == true ){
				//有疑问句
				var keyWord:String = checkHasKey(search);
				if(keyWord != null){
					search += "\n&nbsp;&nbsp;&nbsp;&nbsp;<font color='#d3c888'><font color='#FF0000'>！</font><font color='#FF9000'><a href ='event:checkout'><u>点击查看</u></a></font>与"+keyWord+"有关的内容</font>";
				}
			}
			return search;
		}
		
		//查看有没有符合关键字
		private function checkHasKey(search:String):String{
			var returnWord:String=null;
			var objectArray_length:int=objectArray.length;
			for(var i:int=0; i<objectArray_length; i++){
				var keyWord:String = objectArray[i];
				//这样处理，是怕遇到多个关键字，可以一直全部处理
				if(search.indexOf(keyWord) != -1){
					returnWord="<font color='#40DEF9'>\""+keyWord+"\"</font>";
					break;
				}
			}
			return returnWord;
		}
		
		//查看发送的字符里有没有疑问句
		private function checkHasDoubt(search:String):Boolean{
			var flag:Boolean=false;
			var doubtArray_length:int=doubtArray.length;
			for(var i:int=0;i<doubtArray_length;i++){
				var doubtWord:String = doubtArray[i];
				if(search.indexOf(doubtWord) != -1){
					flag = true;
					break;
				}
			}
			return flag;
		}
			
		
		/**
		 * 为搜索的内容加上颜色
		 * @param data
		 * @param search
		 * 
		 */		
		private function addColor(data:XML,search:String):void{
			//是否搜索到
			var isTrue:Boolean = false;
			//vo
			var searchVO:SearchResult = new SearchResult();
			//正则表达式
			var myPattern:RegExp = new RegExp(search,"g"); 
			//问题
			var question:String = data.@question;
			if(question.indexOf(search) != -1){
				isTrue = true;
				var replace_question:String = question.replace(myPattern,"<font color='#FFFF00'>"+search+"</font>");
				//赋值给vo
				searchVO.question = replace_question;
			}
			//答案
			var answer:String = data.@answer;
			if( answer.indexOf(search) != -1){
				isTrue = true;
				var replace_answer:String = answer.replace(myPattern,"<font color='#FFFF00'>"+search+"</font>");
				//复制给vo
				searchVO.answer = replace_answer;
			}
			if(isTrue == true){
				//这里的判断是为了防止上面一个搜索到，一个没有搜索到，
				if(searchVO.answer == null){
					searchVO.answer = answer;
				}
				if(searchVO.question == null){
					searchVO.question = question;
				}
				result.push(searchVO);
			}
		}
		
	}
}