package modules.deal.views.stallViews
{
	import com.ming.events.PaginationEvent;
	import com.ming.ui.containers.Panel;
	import com.ming.ui.containers.VBox;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.TextInput;
	import com.ming.ui.controls.ToggleButton;
	import com.ming.ui.controls.core.UIComponent;
	import com.utils.ComponentUtil;
	
	import flash.display.Sprite;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import proto.line.m_stall_list_toc;
	
	public class SearchPanel extends Panel
	{
		
		private var searchInput:TextInput; 
		private var searchBtn:Button;
		
		private var vBox:VBox; 
		private var simpleBtn:ToggleButton; //
		private var equipBtn:ToggleButton;
		private var stoneBtn:ToggleButton;
		private var searchResultBtn:ToggleButton;
		
		private var nearlist:NearList;
		
		private var titleUI:UIComponent;
		
		private var pageBarTxt:PageBar;//TextField;
		
		private var currentPage:int = 1;
		
		private var totalPage:int = 1;
		
		
		private var btn_arr:Array = ["普  通","装  备","灵  石","搜索结果"];
		
		public function SearchPanel()
		{
			super();
			this.width = 568;
			this.height = 400;
			
			this.title = "搜索附近的摊位";
			
			init();
		}
		
		
		private function init():void
		{
			searchInput = new TextInput();
			searchInput.x = 8;
			searchInput.y = 20;
			searchInput.width = 160;
			searchInput.height = 22;
			searchInput.textField.setTextFormat(new TextFormat("Tahoma",12,0xacacac,true,null,null,null,"center"));
//			searchInput.setStyle("textFormat", new TextFormat("Arial",12,0xacacac,true,null,null,null,"center"));
			searchInput.text = "输入道具名称关键字";
			addChild(searchInput);
			searchInput.addEventListener(FocusEvent.FOCUS_IN, onFocusIn);
			searchInput.addEventListener(FocusEvent.FOCUS_OUT, onFocusOut);
			
			searchBtn = ComponentUtil.createButton("搜索",166,20,58,23,this); // new Button();
			
			
			titleUI = ComponentUtil.createUIComponent(8,50,556,30); // new UIComponent();
			
			addChild(titleUI);
			initTitleUI();
			
			vBox = new VBox();
			vBox.x = 8;
			vBox.y = 88;//83;
			vBox.width = 84;
			vBox.height = 220; //265;
			addChild(vBox);
			initVBox();
			
			nearlist = new NearList();
			nearlist.x = 98;
			nearlist.y = 80;
			nearlist.bgAlpha = 0;
			nearlist.bgSkin = null;
			addChild(nearlist);
			
			test();
			
			
			
			pageBarTxt = new PageBar(); // new TextField();
			pageBarTxt.x = 10;
			pageBarTxt.y = 308;
			pageBarTxt.width = 528;
			pageBarTxt.height = 30;
			pageBarTxt.bgColor = 0x4A4AFF;
			pageBarTxt.bgAlpha = 0.4;
//			pageBarTxt.htmlText = "上一页 1 2 3 4 5 6 7 8 9 下一页　　共 9 页";
			
//			var  css:StyleSheet = new StyleSheet();
//			css.parseCSS("a {color: #ffffff;}a:hover { color: #ff0000;} ");//a:active {color: #ffff00;}
//			pageBarTxt.styleSheet = css;
			
			addChild(pageBarTxt);
			pageBarTxt.addEventListener(PaginationEvent.PAGINATION, changePageHandler);
			initPageBar(9);
			
		}
		
		private function initPageBar(pages:int=1):void // 页数
		{
			totalPage = pages;
			
			pageBarTxt.totalPage = pages;
//			setSelectedPage(1);
		}
		
		
		private function changePageHandler(evt:PaginationEvent):void
		{
			//  trace(evt.pageNum);
			//  trace();
			//  trace();
			
			
		}
		
		
		public function setDatas(vo:m_stall_list_toc):void
		{
//			if(!vo)
//				return;
//			
//			initPageBar(vo.pages);
		}
		
		
		
		private function test():void
		{
			var arr:Array = new Array();
			for(var i:int = 0; i<7;i++)
			{
				var obj:Object = new Object();
				obj.goods_name = "七杀戒";
				obj.goods_num = 1;
				obj.stall_name = "极品装备专卖店";
				obj.owner = "阿猫的挂店小号";
				arr.push(obj);
			}
			initNearlist(arr);
		}
		private function initNearlist(arr:Array):void
		{
			
			nearlist.initData(arr);
		}
		
		private function initVBox():void
		{
//			for(var i:int = 0; i<btn_arr.length; i++)
//			{
//				createBtn();
//			}
			vBox.bgColor = 0Xacacac;
			vBox.bgAlpha = 0.5;
			
			
			simpleBtn = ComponentUtil.createToggleButton(btn_arr[0],0,0,83,25,vBox); // createBtn(btn_arr[0]);
			simpleBtn.selected = true;
			simpleBtn.addEventListener(MouseEvent.CLICK, onSimpleClick);
			
			equipBtn = ComponentUtil.createToggleButton(btn_arr[1],0,0,83,25,vBox); 
			
			equipBtn.addEventListener(MouseEvent.CLICK, onEquipClick);
			
			stoneBtn = ComponentUtil.createToggleButton(btn_arr[2],0,0,83,25,vBox); 
			
			stoneBtn.addEventListener(MouseEvent.CLICK, onStoneClick);
			
			searchResultBtn = ComponentUtil.createToggleButton(btn_arr[3],0,0,83,25,vBox); 
			
			searchResultBtn.addEventListener(MouseEvent.CLICK, onSearchClick);
			
			
		}
		
		private function onSimpleClick(evt:MouseEvent):void
		{
			if(simpleBtn.selected != true)
			{
				simpleBtn.selected = true;
				equipBtn.selected = false;
				stoneBtn.selected = false;
				searchResultBtn.selected = false;
			}
			
		}
		private function onEquipClick(evt:MouseEvent):void
		{
			if(equipBtn.selected != true)
			{
				equipBtn.selected = true;
				simpleBtn.selected = false;
				stoneBtn.selected = false;
				searchResultBtn.selected = false;
			}
		}
		private function onStoneClick(evt:MouseEvent):void
		{
			if(stoneBtn.selected != true)
			{
				stoneBtn.selected = true;
				equipBtn.selected = false;
				simpleBtn.selected = false;
				searchResultBtn.selected = false;
			}
		}
		
		private function onSearchClick(evt:MouseEvent):void
		{
			if(simpleBtn.selected != true)
			{
				simpleBtn.selected = true;
				equipBtn.selected = false;
				stoneBtn.selected = false;
				searchResultBtn.selected = false;
			}
		}
		
		
		private function initTitleUI():void
		{
			var sp:Sprite = new Sprite();
			titleUI.addChild(sp);
			sp.graphics.beginFill(0xacacac, 0.5);
			sp.graphics.drawRect(0,0,titleUI.width, titleUI.height);
			sp.graphics.endFill();
			
			addTitleText(0,"分　　类");
			addTitleText(100,"物品");
			addTitleText(190,"数量");
			//addTitleText(278,"单价");
			addTitleText(300,"摊位名");
			addTitleText(436,"摊主");
			
		}
		
		private function addTitleText(x:Number, str:String):void
		{
			var text:TextField = new TextField();
			text.text = str;//"分　　类";
			text.x = x;
			text.y = 5
			text.height = 25;
			text.setTextFormat(new TextFormat("Arial",14,0xffffff,null,null,null,null,null,"center"));
			titleUI.addChild(text);
		}
		
		private function onFocusIn(evt:FocusEvent):void
		{
			searchInput.text = "";
			searchInput.textField.setTextFormat(new TextFormat("Arial",12,0x000000,true,null,null,null,"center"));
//			searchInput.setStyle("textFormat", new TextFormat("Arial",12,0x000000,true,null,null,null,"center"));
			
		}
		
		private function onFocusOut(evt:FocusEvent):void
		{
			
		}
		
	}
	
}
import com.ming.ui.controls.core.UIComponent;

import flash.text.TextField;

class TextUi extends UIComponent
{
	private var preText:TextField = new TextField();
	private var pageText:TextField = new TextField(); //  1 2 3 4 5 6 7 8 9
	private var nextText:TextField = new TextField();
	
	
	public function TextUi()
	{
		this.width = 528;
		this.height = 32;
		this.bgColor = 0x333333;
		this.bgAlpha = 0.4;
		
		init();
	}
	
	private function init():void
	{
		
	}
}



