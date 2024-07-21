package modules.market.view
{
	import com.common.GlobalObjectManager;
	import com.components.BasePanel;
	import com.globals.GameConfig;
	import com.globals.GameParameters;
	import com.loaders.SourceLoader;
	import com.managers.WindowManager;
	import com.ming.events.ItemEvent;
	import com.ming.events.PageEvent;
	import com.ming.ui.constants.ScrollPolicy;
	import com.ming.ui.containers.List;
	import com.ming.ui.containers.treeList.Tree;
	import com.ming.ui.containers.treeList.TreeNode;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.ComboBox;
	import com.ming.ui.controls.PageBar;
	import com.ming.ui.controls.TextInput;
	import com.ming.ui.controls.ToggleButton;
	import com.ming.ui.skins.ButtonSkin;
	import com.ming.ui.skins.Skin;
	import com.utils.ComponentUtil;
	import com.utils.JSUtil;
	import com.utils.MoneyTransformUtil;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.ui.Keyboard;
	import flash.utils.Timer;
	
	import modules.broadcast.views.Tips;
	import modules.market.MarketConstant;
	import modules.market.MarketModule;
	import modules.market.item.TreeItem;
	import modules.market.vo.ColorType;
	import modules.market.vo.LevelType;
	import modules.market.vo.ParemType;
	import modules.market.vo.SortType;
	import modules.mypackage.PackageModule;
	import modules.mypackage.managers.ItemLocator;
	
	import proto.common.p_role_attr;
	import proto.line.m_stall_list_toc;
	
	public class MarketWindow extends BasePanel
	{
		
		private var loader:SourceLoader;
		//我的摊位按钮
		private var my_stall_btn:Button;
		//快速充值
		private var charge_btn:Button;
		//绑定元宝
		private var b_boss:TextField;
		//不绑定元宝
		private var un_b_boss:TextField;
		//绑定银子
		private var b_silver:TextField;
		//不绑定银子
		private var un_b_silver:TextField;
		//搜索物品
		private var search_input:TextInput;
		//搜索按钮
		private var search_btn:Button;
		//数据列表
		private var dataList:List;
		//数量排序按钮
		private var numSortBTN:MarketToggBTN;
		//价格
		private var priceSortBTN:MarketToggBTN;
		//等级
		private var levelSortBTN:MarketToggBTN;
		//分页栏
		//private var letterPage:LetterColumn;
		private var page:MarketPageBar;
		
		private var datagrid:Sprite;
		
		//元宝排序还是其他排序
		private var sortCombox:ComboBox;
		//等级排序
		private var levelCombox:ComboBox;
		//颜色排序
		private var colorCombox:ComboBox;
		//属性排序
		private var paremCombox:ComboBox;
		//树
		private var tree:Tree;
		
		public function MarketWindow(loader:SourceLoader)
		{
			super();
			this.loader = loader;
			initUI();
			initListener();
		}
		
		private function initUI():void
		{
			this.width = 710;
			this.height = 470;
			
			var exText:TextField = new TextField();
			exText.x = 5;
			exText.y = 6;
			exText.width = 500;
			exText.htmlText = "<font color='#b3d5e6'>说明:在京城摆摊区摆摊后,摊位中的商品信息将会发送到市场内。</font>";
			addChild(exText);
			
			//市场字体
			var name:Sprite = this.loader.getMovieClip("sc");
			name.x = 330;
			name.y = -23;
			this.addChild(name);
			
			//左边的list背景
			var list:Sprite =  this.loader.getMovieClip("sc_bg3");
			list.x = 9;
			list.y = 54;
			list.height = 352;
			this.addChild(list);
			
			tree = new Tree();
			tree.y = 5;
			tree.width = 100;
			tree.height = 360;
			tree.cellRenderer = TreeItem;
			tree.verticalScrollPolicy = ScrollPolicy.AUTO;
			tree.addEventListener(ItemEvent.ITEM_CHANGE, onItemChanged);
			tree.dataProvider = MarketModule.getInstance().marketManager.treeData;
			list.addChild(tree);
			
			//右边的datagrid背景
			datagrid = this.loader.getMovieClip("sc_bg2");
			datagrid.x = 113;
			datagrid.y = 54;
			this.addChild(datagrid);
			
			//左边下面那个显示元宝的背景
			var left_yuanbao_bg:Sprite = this.loader.getMovieClip("yuanbao_bg1");
			left_yuanbao_bg.x = 7;
			left_yuanbao_bg.y = 410;
			this.addChild(left_yuanbao_bg);
			
			b_boss = new TextField();
			b_boss.htmlText = "<font color='#FFFFFF'>元宝:99999999999</font>";
			b_boss.x = 160;
			b_boss.y = 1;
			b_boss.height = 18;
			b_boss.width = 150;
			left_yuanbao_bg.addChild(b_boss);
			
			un_b_boss = new TextField();
			un_b_boss.htmlText = "<font color='#FFFFFF'>绑定元宝:99999999999</font>";
			un_b_boss.x = 12;
			un_b_boss.y = 1;
			un_b_boss.height = 18;
			un_b_boss.width = 150;
			left_yuanbao_bg.addChild(un_b_boss);
			
			//右边下面那个显示元宝的背景
			var right_yuanbao_bg:Sprite = this.loader.getMovieClip("yuanbao_bg2");
			right_yuanbao_bg.x = 287;
			right_yuanbao_bg.y = 410;
			this.addChild(right_yuanbao_bg);
			
			b_silver = new TextField();
			b_silver.x = 180;
			b_silver.height = 18;
			b_silver.y = 1;
			b_silver.htmlText = "<font color='#FFFFFF'>银子:9999錠99两99文</font>";
			b_silver.width = 150;
			right_yuanbao_bg.addChild(b_silver);
			
			un_b_silver = new TextField();
			un_b_silver.x = 12;
			un_b_silver.y = 1;
			un_b_silver.height=18;
			un_b_silver.width = 150;
			un_b_silver.htmlText = "<font color='#FFFFFF'>绑定银子:9999錠99两99文</font>";
			right_yuanbao_bg.addChild(un_b_silver);
			
			my_stall_btn = new Button();
			my_stall_btn.label = "我的摊位";
			my_stall_btn.x = 460;
			my_stall_btn.y = 4;
			my_stall_btn.width = 88;
			my_stall_btn.height = 24;
			var bgSkin:ButtonSkin = new ButtonSkin();
			bgSkin.skin = this.loader.getBitmapData("sc_btm03_up");
			bgSkin.overSkin = this.loader.getBitmapData("sc_btm03_over");
			my_stall_btn.bgSkin = bgSkin;
			this.addChild(my_stall_btn);
			
			charge_btn = new Button();
			charge_btn.label = "快速充值";
			charge_btn.textColor = 0xffff00;
			Style.setRedButtonStyle(charge_btn);
			timer = new Timer(400);
			timer.start();
			charge_btn.x = 570;
			charge_btn.y = 4;
			charge_btn.width = 88;
			charge_btn.height = 24;
			var bgSkin2:ButtonSkin = new ButtonSkin();
			bgSkin2.skin = this.loader.getBitmapData("sc_btn02_up");
			bgSkin2.overSkin = this.loader.getBitmapData("sc_btn02_over");
			charge_btn.bgSkin = bgSkin2;
			this.addChild(charge_btn);
			
			var yellowTf:TextFormat=Style.themeTextFormat;
			
			search_input = new TextInput();
			search_input.textField.defaultTextFormat = yellowTf;
			search_input.addEventListener(KeyboardEvent.KEY_DOWN,onSearch);
			search_input.x = 9;
			search_input.y = 30;
			search_input.text = "请输入搜索物品";
			this.addChild(search_input);
			
			search_btn = new Button();
			search_btn.label = "搜索";
			search_btn.width = 80;
			search_btn.height = 22;
			search_btn.x = search_input.x + search_input.width + 5;
			search_btn.y = search_input.y;
			this.addChild(search_btn);
			
			levelCombox = new ComboBox();
			levelCombox.name = "level";
			levelCombox.addEventListener(ItemEvent.ITEM_CLICK,onChanged);
			levelCombox.textFormat=yellowTf;
			levelCombox.height=22;
			levelCombox.width=85;
			levelCombox.labelField="label";
			levelCombox.x=search_btn.x + search_btn.width + 48;
			levelCombox.y=search_input.y;
			levelCombox.selectedIndex=0;
			levelCombox.dataProvider=MarketModule.getInstance().marketManager.levelVector;
			addChild(levelCombox);
			
			colorCombox = new ComboBox();
			colorCombox.name = "color";
			colorCombox.addEventListener(ItemEvent.ITEM_CLICK,onChanged);
			colorCombox.textFormat=yellowTf;
			colorCombox.height=22;
			colorCombox.width=85;
			colorCombox.labelField="label";
			colorCombox.x=levelCombox.x + levelCombox.width + 5;
			colorCombox.y=search_input.y;
			colorCombox.selectedIndex=0;
			colorCombox.dataProvider=MarketModule.getInstance().marketManager.colorVector;
			addChild(colorCombox);
			
			paremCombox = new ComboBox();
			paremCombox.name = "parem";
			paremCombox.addEventListener(ItemEvent.ITEM_CLICK,onChanged);
			paremCombox.textFormat=yellowTf;
			paremCombox.height=22;
			paremCombox.width=85;
			paremCombox.labelField="label";
			paremCombox.x=colorCombox.x + colorCombox.width + 5;
			paremCombox.y=search_input.y;
			paremCombox.selectedIndex=0;
			paremCombox.dataProvider=MarketModule.getInstance().marketManager.paremVector;
			addChild(paremCombox);
			
			sortCombox = new ComboBox();
			sortCombox.name = "money";
			sortCombox.addEventListener(ItemEvent.ITEM_CLICK,onChanged);
			sortCombox.textFormat=yellowTf;
			sortCombox.height=22;
			sortCombox.width=85;
			sortCombox.labelField="label";
			sortCombox.x=paremCombox.x + paremCombox.width + 5;
			sortCombox.y=search_input.y;
			sortCombox.selectedIndex=0;
			sortCombox.dataProvider=MarketModule.getInstance().marketManager.sortVector;
			this.addChild(sortCombox);
			
			var market_BTN_1:MarketToggBTN = new MarketToggBTN("物品名",145,false);
			market_BTN_1.x = 8;
			market_BTN_1.y = 3;
			datagrid.addChild(market_BTN_1);
			
			var shu:BitmapData = this.loader.getBitmapData("sc__bg4_xian");
			var shu1:Bitmap = new Bitmap(shu);
			shu1.x = market_BTN_1.x + market_BTN_1.width+1;
			shu1.y = market_BTN_1.y;
			datagrid.addChild(shu1);
			
			priceSortBTN = new MarketToggBTN("单价",100,true);
			priceSortBTN.x = shu1.x + shu1.width + 1;
			priceSortBTN.y = market_BTN_1.y;
			datagrid.addChild(priceSortBTN);
			var shu2:Bitmap = new Bitmap(shu);
			shu2.x = priceSortBTN.x + priceSortBTN.width +1;
			shu2.y = market_BTN_1.y;
			datagrid.addChild(shu2);
			
			numSortBTN = new MarketToggBTN("数量",100,true);
			numSortBTN.x = shu2.x + shu2.width + 1;
			numSortBTN.y = market_BTN_1.y;
			datagrid.addChild(numSortBTN);
			var shu3:Bitmap = new Bitmap(shu);
			shu3.x = numSortBTN.x + numSortBTN.width +1;
			shu3.y = market_BTN_1.y;
			datagrid.addChild(shu3);
			
			levelSortBTN = new MarketToggBTN("等级",100,true);
			levelSortBTN.x = shu3.x + shu3.width + 1;
			levelSortBTN.y = market_BTN_1.y;
			datagrid.addChild(levelSortBTN);
			var shu4:Bitmap = new Bitmap(shu);
			shu4.x = levelSortBTN.x + levelSortBTN.width +1;
			shu4.y = market_BTN_1.y;
			datagrid.addChild(shu4); 
			
			var market_BTN_5:MarketToggBTN = new MarketToggBTN("操作",110,false);
			market_BTN_5.x = shu4.x + shu4.width + 1;
			market_BTN_5.y = market_BTN_1.y;
			datagrid.addChild(market_BTN_5);
			var shu5:Bitmap = new Bitmap(shu);
			shu5.x = market_BTN_5.x + market_BTN_5.width +1;
			shu5.y = market_BTN_1.y;
			datagrid.addChild(shu3); 
			
			//var tiao:Bitmap = new Bitmap(Style.getUIBitmapData(GameConfig.T1_UI, "tiao_dark"));
			var tiao:Bitmap = Style.getBitmap(GameConfig.T1_VIEWUI,"hightLightLine");
			tiao.x = 0;
			tiao.y = market_BTN_1.y+market_BTN_1.height+3;
			tiao.width = 590;
			datagrid.addChild(tiao);
			
			dataList = new List();
			dataList.scrollRow = true;
			dataList.bgSkin = null;
			var overSkin:Skin = new Skin(this.loader.getBitmapData("sc_jingguo"));
			overSkin.height = 18;
			dataList.setOverItemSkin(overSkin);
			var seletedSkin:Skin = new Skin(this.loader.getBitmapData("sc_jingguo"));
			dataList.setSelectItemSkin(seletedSkin);
			dataList.itemRenderer = MarketListItemRenderer;
			dataList.itemHeight = 30;
			dataList.x = 8;
			dataList.y = tiao.y + 2;
			dataList.width = 570;
			dataList.height = 300;
			dataList.verticalScrollPolicy = ScrollPolicy.OFF;
			datagrid.addChild(dataList);
			
//			letterPage = new LetterColumn();
//			datagrid.addChild(letterPage);
//			letterPage.x = 8;
//			letterPage.y = 337;
			page = new MarketPageBar();
			page.x = 8;
			page.y = 337;
			page.size = 10;
			datagrid.addChild(page);
			
			moneyChange();
		}
		
		protected function onSearch(event:KeyboardEvent):void
		{
			// TODO Auto-generated method stub
			if(event.keyCode == Keyboard.ENTER)
			{
				searchGoods();
			}
		}
		
		protected function onItemChanged(event:ItemEvent):void
		{
			//市场中重新选择左边的分类时，自动将“等级，颜色，属性，元宝优先”这四个选择恢复成初始状态
			levelCombox.selectedIndex = 0; 
			colorCombox.selectedIndex = 0; 
			paremCombox.selectedIndex = 0;
			sortCombox.selectedIndex = 0;
			var node:TreeNode = event.selectItem as TreeNode;
			var id:int;
			if (node.nodeType == TreeNode.LEAF_NODE) {
				id = int(node.data.@id);
				searchArr.length = 0;
//				MarketModule.getInstance().sendData(id,1,searchArr,
//					MarketModule.getInstance().marketManager.infoViewData.sort_type,
//					MarketModule.getInstance().marketManager.infoViewData.is_reverse,
//					MarketModule.getInstance().marketManager.infoViewData.is_gold_first,
//					MarketModule.getInstance().marketManager.infoViewData.min_level,
//					MarketModule.getInstance().marketManager.infoViewData.max_level,
//					MarketModule.getInstance().marketManager.infoViewData.color,
//					MarketModule.getInstance().marketManager.infoViewData.pro);
				MarketModule.getInstance().sendData(id,1,searchArr,
					MarketModule.getInstance().marketManager.infoViewData.sort_type,
					MarketModule.getInstance().marketManager.infoViewData.is_reverse,
					MarketModule.getInstance().marketManager.infoViewData.is_gold_first,
					0,
					0,
					0,
					0);
			}else if(node.nodeType == TreeNode.BRANCH_NODE){
				id = node.data.id;
				searchArr.length = 0;
				MarketModule.getInstance().sendData(id,1,searchArr,
					MarketModule.getInstance().marketManager.infoViewData.sort_type,
					MarketModule.getInstance().marketManager.infoViewData.is_reverse,
					MarketModule.getInstance().marketManager.infoViewData.is_gold_first,
					0,
					0,
					0,
					0);
			}
		}
		
		override public function closeWindow(save:Boolean=false):void
		{
			// TODO Auto Generated method stub
			super.closeWindow(save);
		}
		
		private function onChanged(e:ItemEvent):void{
			var selected:ComboBox = e.currentTarget as ComboBox;
			switch(selected.name){
				case "money":
					var moneyData:SortType = selected.selectedItem as SortType;
					MarketModule.getInstance().sendData(
						MarketModule.getInstance().marketManager.infoViewData.type,
						1,
						searchArr,
						MarketConstant.PRICE_SORT,
						MarketModule.getInstance().marketManager.infoViewData.is_reverse,
						moneyData.value,
						MarketModule.getInstance().marketManager.infoViewData.min_level,
						MarketModule.getInstance().marketManager.infoViewData.max_level,
						MarketModule.getInstance().marketManager.infoViewData.color,
						MarketModule.getInstance().marketManager.infoViewData.pro);
					break;
				case "parem":
					var paremData:ParemType = selected.selectedItem as ParemType;
					MarketModule.getInstance().sendData(
						MarketModule.getInstance().marketManager.infoViewData.type,
						1,
						searchArr,
						MarketModule.getInstance().marketManager.infoViewData.sort_type,
						MarketModule.getInstance().marketManager.infoViewData.is_reverse,
						MarketModule.getInstance().marketManager.infoViewData.is_gold_first,
						MarketModule.getInstance().marketManager.infoViewData.min_level,
						MarketModule.getInstance().marketManager.infoViewData.max_level,
						MarketModule.getInstance().marketManager.infoViewData.color,
						paremData.value);
					break;
				case "level":
					var levelData:LevelType = selected.selectedItem as LevelType;
					MarketModule.getInstance().sendData(
						MarketModule.getInstance().marketManager.infoViewData.type,
						1,
						searchArr,
						MarketModule.getInstance().marketManager.infoViewData.sort_type,
						MarketModule.getInstance().marketManager.infoViewData.is_reverse,
						MarketModule.getInstance().marketManager.infoViewData.is_gold_first,
						levelData.min,
						levelData.max,
						MarketModule.getInstance().marketManager.infoViewData.color,
						MarketModule.getInstance().marketManager.infoViewData.pro);
					break;
				case "color":
					var colorData:ColorType = selected.selectedItem as ColorType;
					MarketModule.getInstance().sendData(
						MarketModule.getInstance().marketManager.infoViewData.type,
						1,
						searchArr,
						MarketModule.getInstance().marketManager.infoViewData.sort_type,
						MarketModule.getInstance().marketManager.infoViewData.is_reverse,
						MarketModule.getInstance().marketManager.infoViewData.is_gold_first,
						MarketModule.getInstance().marketManager.infoViewData.min_level,
						MarketModule.getInstance().marketManager.infoViewData.max_level,
						colorData.value,
						MarketModule.getInstance().marketManager.infoViewData.pro);
					break;
			}
		}
		
		public function moneyChange():void
		{
			var user:p_role_attr = GlobalObjectManager.getInstance().user.attr;
			un_b_boss.htmlText = "<font color='#FFFFFF'>元宝:"+user.gold.toString()+"</font>";
			b_boss.htmlText = "<font color='#FFFFFF'>绑定元宝:"+user.gold_bind.toString()+"</font>";
			un_b_silver.htmlText = "<font color='#FFFFFF'>银子:"+MoneyTransformUtil.silverToOtherString(user.silver)+"</font>";
			b_silver.htmlText = "<font color='#FFFFFF'>绑定银子:"+MoneyTransformUtil.silverToOtherString(user.silver_bind)+"</font>";
		}
		
		private var timer:Timer;
		
		private function initListener():void
		{
			search_input.addEventListener(FocusEvent.FOCUS_IN, onFocusInHandler);
			search_input.addEventListener(FocusEvent.FOCUS_OUT, onFocusOutHandler);
			search_btn.addEventListener(MouseEvent.CLICK, onSearchGoods);
//			letterPage.addEventListener("DATA_CHAGE",onOtherPage);
			page.addEventListener(PageEvent.CHANGED,onPageChanged);
			my_stall_btn.addEventListener(MouseEvent.CLICK, onOpenStall);
			charge_btn.addEventListener(MouseEvent.CLICK, onFastPay);
			numSortBTN.addEventListener(MouseEvent.CLICK, onNumSort);
			levelSortBTN.addEventListener(MouseEvent.CLICK, onLevelSort);
			priceSortBTN.addEventListener(MouseEvent.CLICK,onPriceSort);
			timer.addEventListener(TimerEvent.TIMER, upFillBut);
		}
		
		private function upFillBut(e:TimerEvent):void{
			var count:int = timer.currentCount;
			if(count%2==0)
			{
				charge_btn.textColor = 0xFFFF00;
			}else{
				
				charge_btn.textColor = 0xFF9600; 
			}
		}
		
		
		private function onLevelSort(e:MouseEvent):void{
			MarketModule.getInstance().sendData(MarketModule.getInstance().marketManager.infoViewData.type,1,searchArr,MarketConstant.LEVEL_SORT,
				!levelSortBTN.type,
				MarketModule.getInstance().marketManager.infoViewData.is_gold_first,
				MarketModule.getInstance().marketManager.infoViewData.min_level,
				MarketModule.getInstance().marketManager.infoViewData.max_level,
				MarketModule.getInstance().marketManager.infoViewData.color,
				MarketModule.getInstance().marketManager.infoViewData.pro);
		}
		private function onPriceSort(e:MouseEvent):void{
			MarketModule.getInstance().sendData(MarketModule.getInstance().marketManager.infoViewData.type,
				1,
				searchArr,
				MarketConstant.PRICE_SORT,
				!priceSortBTN.type,
				MarketModule.getInstance().marketManager.infoViewData.is_gold_first,
				MarketModule.getInstance().marketManager.infoViewData.min_level,
				MarketModule.getInstance().marketManager.infoViewData.max_level,
				MarketModule.getInstance().marketManager.infoViewData.color,
				MarketModule.getInstance().marketManager.infoViewData.pro);
		}
		private function onNumSort(e:MouseEvent):void{
			MarketModule.getInstance().sendData(MarketModule.getInstance().marketManager.infoViewData.type,1,searchArr,MarketConstant.NUM_SORT,
				!numSortBTN.type,
				MarketModule.getInstance().marketManager.infoViewData.is_gold_first,
				MarketModule.getInstance().marketManager.infoViewData.min_level,
				MarketModule.getInstance().marketManager.infoViewData.max_level,
				MarketModule.getInstance().marketManager.infoViewData.color,
				MarketModule.getInstance().marketManager.infoViewData.pro);
		}
		
		//快速充值
		private function onFastPay(e:MouseEvent):void
		{
			JSUtil.openPaySite();
		}
		
		
		//打开自己的摊位
		private function onOpenStall(e:MouseEvent):void
		{
			PackageModule.getInstance().openStallPanel(1);
		}
		
		private function onPageChanged(event:PageEvent):void{
			MarketModule.getInstance().sendData(MarketModule.getInstance().marketManager.infoViewData.type,
				event.pageNumber,
				searchArr,
				MarketModule.getInstance().marketManager.infoViewData.sort_type,
				MarketModule.getInstance().marketManager.infoViewData.is_reverse,
				MarketModule.getInstance().marketManager.infoViewData.is_gold_first,
				MarketModule.getInstance().marketManager.infoViewData.min_level,
				MarketModule.getInstance().marketManager.infoViewData.max_level,
				MarketModule.getInstance().marketManager.infoViewData.color,
				MarketModule.getInstance().marketManager.infoViewData.pro);
		}
				
		public function openWindow(vo:m_stall_list_toc):void
		{
			dataList.dataProvider = vo.goods_list;
			page.setTotalPageCount(vo.page,vo.max_page);
			//居中
			page.x = (datagrid.width - page.width)/2;
			if(vo.type == 301 && vo.goods_list.length > 0){
				MarketModule.getInstance().marketManager.firstBranchNode.openNode();
			}
			
			if(WindowManager.getInstance().isPopUp(this) != true)
			{
				WindowManager.getInstance().popUpWindow(this);
				WindowManager.getInstance().centerWindow(this);
			}
		}
		
		public function updateData(goodList:Array):void{
			dataList.dataProvider = goodList;
		}
		
		private function onSearchGoods(e:MouseEvent):void
		{
			if(search_input.text == "" || search_input.text == null){
				Tips.getInstance().addTipsMsg("请输入要搜索的物品名字");
			}else{
				searchGoods();
			}
		}
		
		//搜索到的商品
		private var searchArr:Array = [];
		
		private function searchGoods():void{
			searchArr.length = 0;
			
			var tempStr:String;
			var searchStr:String = this.search_input.text;
			if(searchStr == "" || searchStr == "输入搜索物品") return;
			var itemxml:XML = ItemLocator.getInstance().itemsXML;
			for each(var item:XML in itemxml.item){
				tempStr = item.@name;
				if(tempStr.indexOf(searchStr)>=0){
					searchArr.push( int(item.@id));
				}
			}
			
			var equipxml:XML = ItemLocator.getInstance().equipsXML;
			for each(var equipitem:XML in equipxml.equip){
				tempStr = equipitem.@name;
				if(tempStr.indexOf(searchStr)>=0){
					searchArr.push(int(equipitem.@id));
				}
			}
			
			var stonexml:XML = ItemLocator.getInstance().stonesXML;	
			for each(var stoneitem:XML in stonexml.stone){
				tempStr = stoneitem.@name;
				if(tempStr.indexOf(searchStr)>=0){
					searchArr.push( int(stoneitem.@id));
				}
			}
			if(searchArr.length < 1)
			{
				Tips.getInstance().addTipsMsg("没有找到你要搜索的物品");
			}
			else{
				MarketModule.getInstance().sendData(MarketModule.getInstance().marketManager.infoViewData.type,1,searchArr,
					MarketModule.getInstance().marketManager.infoViewData.sort_type,
					MarketModule.getInstance().marketManager.infoViewData.is_reverse,
					MarketModule.getInstance().marketManager.infoViewData.is_gold_first,
					MarketModule.getInstance().marketManager.infoViewData.min_level,
					MarketModule.getInstance().marketManager.infoViewData.max_level,
					MarketModule.getInstance().marketManager.infoViewData.color,
					MarketModule.getInstance().marketManager.infoViewData.pro);
			}
		}
		
		private function onFocusInHandler(evt:FocusEvent):void {
			search_input.text="";
		}
		
		private function onFocusOutHandler(evt:FocusEvent):void {
			//txtInput.text="请输入激活码";
			if(search_input.text == ""){
				search_input.text = "请输入搜索物品";
			}
		}
	}
}