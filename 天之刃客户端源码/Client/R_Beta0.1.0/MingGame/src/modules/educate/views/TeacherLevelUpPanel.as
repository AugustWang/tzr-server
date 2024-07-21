package modules.educate.views
{
	import com.common.GlobalObjectManager;
	import com.components.BasePanel;
	import com.ming.ui.layout.LayoutUtil;
	import com.utils.ComponentUtil;
	import com.utils.HtmlUtil;
	
	import flash.display.Sprite;
	import flash.events.TextEvent;
	import flash.text.StyleSheet;
	import flash.text.TextField;
	
	import modules.educate.EducateConstant;
	import modules.educate.EducateModule;
	
	public class TeacherLevelUpPanel extends BasePanel
	{
		public var levels:Array = [0,25,50,60,70];
		private var titleText:TextField;
		private var textFields:Array;
		private var css:StyleSheet;
		private var backBg:Sprite;
		public function TeacherLevelUpPanel()
		{
			super("");
			initView();
		}
		
		private function initView():void{
			width = 355;
			height = 270;
			this.title = "升级导师称号"
				
			backBg=Style.getBlackSprite(328,230);
			backBg.x = 13;
			backBg.mouseEnabled = false;
			addChild(backBg);
				
			css = new StyleSheet();
			css.parseCSS("a {color: #ffff00;} a:hover {color: #ffffff;}");
		
			titleText = ComponentUtil.createTextField("",12,5,null,320,20,backBg);
			titleText.multiline = true;
			titleText.wordWrap = true;
			
			textFields = [];
			for(var i:int=1;i<=4;i++){
				var  txt:TextField = ComponentUtil.createTextField("",12,0,null,320,45,backBg);
//				var  txt:TextField = ComponentUtil.createTextField("",0,0,null,320,45,backBg);
				txt.mouseEnabled = true;
				txt.styleSheet = css;
				textFields.push(txt);
			}
		}
		
		private function updateText():void{
			for(var i:int=1;i<=4;i++){
				updateLevelUpText(i,textFields[i-1]);
			}
		}
		
		private function updateLevelUpText(title:int,text:TextField):void{
			var html:String = EducateConstant.TITLE_NAMES[title];
			html += "(需要"+levels[title]+"级";
			if(title > 1){
				html += "，需要累计师德值"+EducateConstant.CONDITIONS[title]+"点";
			}
			html += ")";
			html = HtmlUtil.font(html,"#00ffff");
			if(currentTitle == 4 && title == 4){
				html += HtmlUtil.font("[最高等级]","#FFFF00");
			}else if((currentTitle + 1) == title){
				html += "<a href='event:"+title+"'><u>[获得导师称号]</u></a>";
			}
			html += "\n可收"+EducateConstant.STUDENT_COUNTS[title]+"名徒弟，最多可累计师德值"+EducateConstant.TOL_VALUES[title]+"点";
			text.htmlText = html;
			text.addEventListener(TextEvent.LINK,onTextLink);
//			addChild(text);
//			backBg.addChild(text);
		}
		
		private function onTextLink(event:TextEvent):void{
			EducateModule.getInstance().upGrade();
		}
		
		private var _currentTitle:int;
		public function set currentTitle(value:int):void{
			_currentTitle = value;
			var roleName:String = GlobalObjectManager.getInstance().user.attr.role_name;
			var values:int = EducateModule.getInstance().educateInfo.moral_values;
			titleText.htmlText = HtmlUtil.font(roleName,"#00ff00")+"，你当前已累计师德值"+values+"点，升级导师不用扣除师德值。";
			titleText.height = titleText.textHeight + 15;
			updateText();	
			LayoutUtil.layoutVectical(backBg,2,2);
//			LayoutUtil.layoutVectical(backBg,2,2);
		}
		
		public function get currentTitle():int{
			return _currentTitle;
		}
		
		public var closeFunc:Function;
		override public function closeWindow(save:Boolean=false):void{
			super.closeWindow(save);
			if(closeFunc != null){
				closeFunc.apply(null);
			}
		}
	}
}