package modules.Activity.view {
	import com.common.FlashObjectManager;
	import com.components.DataGrid;
	import com.components.HeaderBar;
	import com.ming.ui.constants.ScrollDirection;
	import com.ming.ui.constants.ScrollPolicy;
	import com.ming.ui.containers.Canvas;
	import com.ming.ui.containers.List;
	import com.ming.ui.containers.VScrollText;
	import com.ming.ui.controls.ToggleButton;
	import com.ming.ui.controls.core.UIComponent;
	import com.ming.ui.controls.rendererClass.ListItemRenderer;
	import com.utils.ComponentUtil;
	import com.utils.DateFormatUtil;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import modules.Activity.ActivityModule;
	import modules.Activity.view.itemRender.*;
	
	import proto.common.p_activity_condition;
	import proto.common.p_activity_prize_goods;
	import proto.line.m_special_activity_able_get_toc;
	import proto.line.m_special_activity_detail_toc;
	import proto.line.m_special_activity_get_prize_toc;
	import proto.line.m_special_activity_list_toc;
	
		
		public class SpecialActivityView extends UIComponent {
		
		public static var curSpecialActivityKey:int;
		
		public static var curSpecialActivityLimit:int;
		//活动列表
		private var listSpclAct:List;
		//活动详细信息中的条件列表
		private var listCondition:List;
		//固定文字
		private var txtIntro:TextField;
		
		private var txtActTime:TextField;
		
		private var txtRewardTime:TextField;
		//可变文字
		private var txtIntroContent:VScrollText;
		
		// 活动起始时间
		private var txtActTimeContent:TextField;
		// 领奖起始时间
		private var txtRewardTimeContent:TextField;
		// 字体样式
		private var tfTitle:TextFormat;
		
		private var tfContent:TextFormat;
		
		private static const leftWidth:int = 115;
		
		private static const allHeight:int =328;
		
		private static const rightWidth:int = 497;

		
		private var menuContainer:UIComponent;
		
		private var detailContainer:UIComponent;
		
		private var emptyContainer:UIComponent;
		
		private var txtEmptyContent:TextField;
		
		private var btnJoinActivity:ToggleButton;
		
		public function SpecialActivityView() {
			super();
			initUI();
		}
		
		private function initUI():void {
			tfTitle = new TextFormat( "Tahoma", 12, 0xFFFF00, null );
			tfContent=new TextFormat("Tahoma",12,0xF6F5CD,null,null,null,null,null,null,null,null,null,4);
			var tfEmptyContent:TextFormat =new TextFormat("Tahoma", 14, 0xFFFF00,null);
			//左边menu圆角框
			menuContainer =new UIComponent();
			menuContainer.height=allHeight;
			menuContainer.width=leftWidth;
			menuContainer.x=7;
			menuContainer.y=7;
			Style.setNewBorderBgSkin(menuContainer);
			addChild(menuContainer);
			//右边信息圆角框
			detailContainer = new UIComponent();
			detailContainer.height=allHeight;
			detailContainer.width= rightWidth;
			detailContainer.x=126;
			detailContainer.y=7;
			Style.setNewBorderBgSkin(detailContainer);
			addChild(detailContainer);
			//几个粗体字
			txtIntro = ComponentUtil.createTextField( "活动介绍:", 4, 4, tfTitle, 200, 20, detailContainer );
			
			txtActTime = ComponentUtil.createTextField( "活动时间:", 4, 130, tfTitle, 70, 20, detailContainer );

			txtRewardTime = ComponentUtil.createTextField( "领奖时间:", 4, 150, tfTitle, 70, 20, detailContainer );

			txtActTimeContent = ComponentUtil.createTextField("",70,130,tfContent,250,20,detailContainer);

			txtRewardTimeContent = ComponentUtil.createTextField("",70,150,tfContent,250,20,detailContainer);
			
			btnJoinActivity = ComponentUtil.createToggleButton("我要参与",412,140,70,23,detailContainer);
			btnJoinActivity.addEventListener(MouseEvent.CLICK,onJoinActivityClickHandler);
			btnJoinActivity.visible=false;
			
			//可变区域  内容和时间
			txtIntroContent=new VScrollText();
			txtIntroContent.direction=ScrollDirection.RIGHT;
			txtIntroContent.selectable=false;
			txtIntroContent.verticalScrollPolicy=ScrollPolicy.ON;
			txtIntroContent.x=4;
			txtIntroContent.y=20;
			txtIntroContent.width=490;
			txtIntroContent.height=110;
			txtIntroContent.textField.defaultTextFormat=tfContent;
			detailContainer.addChild(txtIntroContent);

			//左边活动列表
			listSpclAct = new List(); //List;
			listSpclAct.x = 3;
			listSpclAct.y = 3; //2
			listSpclAct.width = leftWidth - 3;
			listSpclAct.height = allHeight - 6;
			listSpclAct.itemHeight = 26;
			listSpclAct.itemRenderer = SpecialActivityListItemRender;
			listSpclAct.selected = false;
			listSpclAct.verticalScrollPolicy = ScrollPolicy.ON;
			menuContainer.addChild( listSpclAct );
			
			//右边条件列表
			var hdCondition:HeaderBar = new HeaderBar();
			hdCondition.x = 1;
			hdCondition.y = 179;
			hdCondition.width = rightWidth-2;
			hdCondition.height=25;
			hdCondition.addColumn("条件",175);
			hdCondition.addColumn("奖励",225);
			hdCondition.addColumn("操作",100);
			detailContainer.addChild(hdCondition);
			
			listCondition = new List();
			listCondition.x = 2;
			listCondition.y = 200;
			listCondition.width =rightWidth-3;
			listCondition.height = 125;
			listCondition.selected =false;
			listCondition.verticalScrollPolicy = ScrollPolicy.ON;
			listCondition.itemRenderer = ConditionListItemRender;
			listCondition.itemHeight=35;
			detailContainer.addChild(listCondition);
			
			//////////////一大块圆角框///////////////////
			emptyContainer = new UIComponent();
			emptyContainer.height=344;
			emptyContainer.width= 626;
			emptyContainer.x=8;
			emptyContainer.y=8;
			Style.setNewBorderBgSkin(emptyContainer);
			emptyContainer.visible=false;
			addChild(emptyContainer);
			
			txtEmptyContent =ComponentUtil.createTextField("近期没有特殊活动，敬请期待！",205,75,tfEmptyContent,190,30, emptyContainer);
			emptyContainer.visible=true;
			menuContainer.visible=false;
			detailContainer.visible=false;
		}
		
		public function getSpecialActivityList(vo:m_special_activity_list_toc):void{
			if(vo.key_list){
				var count:int = vo.key_list.length;
				if(count>0){
					emptyContainer.visible=false;
					menuContainer.visible=true;
					detailContainer.visible=true;
					listSpclAct.dataProvider = vo.key_list;
				}
				else{	
					emptyContainer.visible=true;
					menuContainer.visible=false;
					detailContainer.visible=false;
				}
				if ( listSpclAct.vScrollBar ) {
					listSpclAct.vScrollPosition = ( count - 1 ) * 87;
				}
				
			}
		}
		
		public function showSpecialActivityDetail(vo:m_special_activity_detail_toc):void{
			if(vo.succ){
				txtIntroContent.htmlText=vo.text;
				//排行榜类活动  活动时间区别显示
				if(vo.activity_start_time==0){
					txtActTimeContent.htmlText=DateFormatUtil.format(vo.activity_end_time);
				}
				else{
					txtActTimeContent.htmlText=DateFormatUtil.format(vo.activity_start_time)+"~"+DateFormatUtil.format(vo.activity_end_time);
				}
				txtRewardTimeContent.htmlText = DateFormatUtil.format(vo.reward_start_time)+"~"+DateFormatUtil.format(vo.reward_end_time);
				curSpecialActivityKey = vo.activity_key; 
				//特殊类活动
				if(curSpecialActivityKey>3000 && curSpecialActivityKey<4000){
					btnJoinActivity.visible=true;
				}else{
					btnJoinActivity.visible=false;
				}
				curSpecialActivityLimit = vo.limit;
				listCondition.dataProvider = vo.condition_list;
			}
		}
		
		public function onJoinActivityClickHandler(evt:MouseEvent):void{
			if(curSpecialActivityKey>=3001 && curSpecialActivityKey<=3004){
				ActivityModule.getInstance().showBagEquipList(curSpecialActivityKey);
			}else if(curSpecialActivityKey>=3005 && curSpecialActivityKey<=3007){
			
			}
				
		}

	}
	
}



