package modules.educate.views
{
	import com.common.FilterCommon;
	import com.common.GlobalObjectManager;
	import com.components.DataGrid;
	import com.components.LoadingSprite;
	import com.managers.Dispatch;
	import com.ming.events.ItemEvent;
	import com.ming.ui.constants.ScrollPolicy;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.core.UIComponent;
	import com.utils.ComponentUtil;
	import com.utils.HtmlUtil;
	import com.utils.PathUtil;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import modules.ModuleCommand;
	import modules.educate.EducateModule;
	import modules.educate.items.CommendStudentItem;
	import modules.family.views.AboutFamily;
	
	import proto.line.m_educate_release_tos;
	import proto.line.p_educate_role_info;
	import proto.line.p_friend_info;
	
	public class CommendStudent extends LoadingSprite implements ILoadData
	{
		private static const NO_TITLE:String = "25级可到"+HtmlUtil.link(HtmlUtil.font("京城—师徒管理员","#3be450"),"",true)+"处，获取导师资格，就可以挑选徒弟了！";
		private static const NO_DATA:String = "在列表中选择一名徒弟，或点击“一键找徒弟”";
		private var list:DataGrid;
		private var text:TextField;
		
		private var butRel:Button;
		private var butUnRel:Button;
		private var butRef:Button;
		
		private var attrBack:UIComponent;
		private var attr:Sprite;
		private var opt:Sprite;
		
		private var txtName:TextField;
		private var txtSex:TextField;
		private var txtLevel:TextField;
		private var txtMoralVal:TextField;
		private var txtMsg:TextField;
		private var butChat:Button;
		private var butTeam:Button;
		
		private var relView:EducateReleaseView;
		
		private var item:p_educate_role_info;
		
		public function CommendStudent()
		{
			var backBg:UIComponent = ComponentUtil.createUIComponent(3,3,456,172);
			Style.setBorderSkin(backBg);
			backBg.mouseEnabled = false;
			addChild(backBg);
			
			list = new DataGrid();
			list.x = 1;
			list.y = 1;
			list.itemRenderer = CommendStudentItem;
			list.width = 454;
			list.height = 170;
			list.addColumn("名字",110);
			list.addColumn("性别",50);
			list.addColumn("等级",50);
			list.addColumn("留言",244);;
			list.itemHeight = 25;
			list.pageCount = 6;
			list.verticalScrollPolicy = ScrollPolicy.ON;
			list.list.addEventListener(ItemEvent.ITEM_CLICK, onSelectItem);
			backBg.addChild(list);
			
			attrBack = ComponentUtil.createUIComponent(3,205,456,72);
			Style.setBorderSkin(attrBack);
			attrBack.mouseEnabled = false;
			addChild(attrBack);
			
			attr = new Sprite();
			attr.x = 3;
			attr.y = 3;
			attr.mouseEnabled = false;
			txtName = ComponentUtil.createTextField("姓名：",10,10,null,73.5,NaN,attr);
			txtSex = ComponentUtil.createTextField("性别：",99,10,null,73.5,NaN,attr);
			txtLevel = ComponentUtil.createTextField("等级：",189,10,null,73.5,NaN,attr);
			txtMoralVal = ComponentUtil.createTextField("师德：",277,10,null,73.5,NaN,attr);
			txtMsg = ComponentUtil.createTextField("留言：",10,43,null,435,NaN,attr);
			butChat = ComponentUtil.createButton("窗口聊天" ,368,10,57,23,attr);
			butTeam = ComponentUtil.createButton("收徒组队" ,368,43,57,23,attr);
			butChat.addEventListener(MouseEvent.CLICK, onChat);
			butTeam.addEventListener(MouseEvent.CLICK, onTeam);
			attrBack.addChild(attr);
			
			
			
			opt = new Sprite();
			opt.x = 3;
			opt.y = 176;
			butRef = ComponentUtil.createButton("刷新列表" ,10,1,100,25,opt);
			butRel = ComponentUtil.createButton("一键找徒弟" ,236,1,100,25,opt);
			butUnRel = ComponentUtil.createButton("取消找徒弟" ,344.5,1,100,25,opt);
			butRef.addEventListener(MouseEvent.CLICK, onRefList);
			butRel.addEventListener(MouseEvent.CLICK, onRelease);
			butUnRel.addEventListener(MouseEvent.CLICK, onUnRelease);
			addChild(opt);
			
			var text:TextField = ComponentUtil.createTextField("",5,277,null,455,40,this);
			text.filters = FilterCommon.FONT_BLACK_FILTERS;
			text.wordWrap = true;
			text.multiline = true;
			text.htmlText = HtmlUtil.font("温馨提示：","#ffff00")+HtmlUtil.font("本次只推荐最多20名在线可作为徒弟的名单。需要与对方组队到京城的师徒管理员结成师徒关系。      ","#f6f5cd")+HtmlUtil.link(HtmlUtil.font("京城－师徒管理员","#00ff00"),"goto",true);;
			text.mouseEnabled = true;
			text.addEventListener(TextEvent.LINK,onLinkHandler);
			
			relView = new EducateReleaseView();
			relView.data = 1;
		}
		
		public function load():void{
			EducateModule.getInstance().getCommendStudents();
			addDataLoading();
			butRel.enabled = (!EducateModule.getInstance().hasReleaseAdmissions() && 
							   EducateModule.getInstance().isCanBecomeTeacher()) || !EducateModule.getInstance().isFullStudentNum();
			butUnRel.enabled = EducateModule.getInstance().hasReleaseAdmissions();
		}
		
		public function refresh():void{
			butRel.enabled = (!EducateModule.getInstance().hasReleaseAdmissions() && 
							   EducateModule.getInstance().isCanBecomeTeacher()) || !EducateModule.getInstance().isFullStudentNum();
			butUnRel.enabled = EducateModule.getInstance().hasReleaseAdmissions();
		}
		
		private function onChat(event:MouseEvent):void{
			if(item != null){
				var friendInfo:p_friend_info = new p_friend_info();
				friendInfo.roleid = item.roleid;
				friendInfo.rolename = item.name;
				friendInfo.head = item.sex;
				friendInfo.sex = item.sex;
				Dispatch.dispatch(ModuleCommand.OPEN_FRIEND_PRIVATE,friendInfo);
			}
		}
		
		private function onTeam(evnet:MouseEvent):void{	
			if(item != null){
				Dispatch.dispatch(ModuleCommand.START_TEAM, {"role_id":item.roleid, "type_id":1});
			}
		}
		
		private function onLinkHandler(event:TextEvent):void{
			onTextLink(event);
		}
		
		public function setStudents(students:Array):void{
			removeText();
			removeAttr();				
			removeDataLoading();
			list.dataProvider = students;
			list.validateNow();
			if(students && students.length == 0){
				addDefaultText(NO_DATA);
			}else{
				list.list.selectedIndex = 0;
				item = students[0] as p_educate_role_info;
				setItem(item);
				attrBack.addChild(attr);
			}
		}
		
		public function addDefaultText(title:String):void{
			if(text == null){
				var tf:TextFormat = Style.textFormat;
				tf.align = "center";
				text = ComponentUtil.createTextField("",0,224,tf,438,25);
				text.filters = FilterCommon.FONT_BLACK_FILTERS;
				text.mouseEnabled = true;
				text.textColor = 0xffff00;
				text.addEventListener(TextEvent.LINK,onTextLink);
			}
			text.htmlText = title;
			addChild(text);
		}
		
		private function removeText():void{
			if(text && text.parent){
				text.parent.removeChild(text);
			}
		}
		
		private function removeAttr():void{
			if(attr && attr.parent){
				attr.parent.removeChild(attr);
			}
		}
		
		private function onTextLink(event:TextEvent):void{
			var factionId:int = GlobalObjectManager.getInstance().user.base.faction_id;
			var npcId:String = "1"+factionId+"100121";
			PathUtil.findNPC(npcId);
		}
		
		private function onRefList(evt:MouseEvent):void{
			EducateModule.getInstance().getCommendStudents();
		}
		
		private function onRelease(evt:MouseEvent):void{
			addChild(relView);
		}
		
		private function onUnRelease(evt:MouseEvent):void{
			EducateModule.getInstance().unReleaseAdmissions();
		}
		
		private function onSelectItem(evt:ItemEvent):void{
			item = evt.selectItem as p_educate_role_info;
			setItem(item);
		}
		
		private function setItem(item:p_educate_role_info):void{
			txtName.htmlText = "姓名："+item.name;
			switch(item.sex){case 1: txtSex.htmlText="性别：男";break; case 2: txtSex.htmlText="性别：女";break;}
			txtLevel.htmlText = "等级："+String(item.level);
			txtMoralVal.htmlText = "师德："+String(item.moral_values);
			txtMsg.htmlText = "留言："+item.rel_app_msg;
		}
	}
}