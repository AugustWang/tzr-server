package modules.prestige.views
{
	import com.common.GlobalObjectManager;
	import com.components.BasePanel;
	import com.components.ButtonPageBar;
	import com.globals.GameConfig;
	import com.ming.events.ItemEvent;
	import com.ming.events.PageEvent;
	import com.ming.ui.controls.Accordion;
	import com.ming.ui.controls.CheckBox;
	import com.ming.ui.controls.TextInput;
	import com.ming.ui.controls.accordion.AccordionNode;
	import com.ming.ui.controls.core.UIComponent;
	import com.ming.ui.skins.AccordionSkin;
	import com.ming.ui.skins.ButtonSkin;
	import com.ming.ui.skins.Skin;
	import com.utils.ComponentUtil;
	
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	
	import modules.prestige.PrestigeModule;
	import modules.prestige.PrestigedConstant;
	import modules.prestige.views.item.PrestigeExchangeItem;
	
	import proto.common.p_prestige_item;
	
	public class PrestigeExChangePanel extends BasePanel
	{
		public static const PAGE_COUNT:int = 9;
		private var _dataProvider:Array;
		private var goodAtMeDatas:Array;
		
		private var currentCredit:TextInput;
		private var goodAtMeChk:CheckBox;
		private var accordion:Accordion;
		private var itemsCanvas:UIComponent;
		private var pageBar:ButtonPageBar;
		private var items:Array;
		public function PrestigeExChangePanel(key:String=null)
		{
			super();
			initView();
		}
		
		private function initView():void{
			title = "声望兑换";
			width = 640;
			height = 400;
			addTitleBG(446);
			addImageTitle("title_credit");
			addContentBG(5,8);
			
			var creditText:TextField = ComponentUtil.createTextField("当前声望值：",14,10,Style.themeTextFormat,75,20,this);
			currentCredit = ComponentUtil.createTextInput(creditText.x+creditText.width+10,creditText.y,120,25,this);
			currentCredit.enabled = false;
			updatePrestige();
			
			goodAtMeChk = ComponentUtil.createCheckBox("适合我的道具",width-120,currentCredit.y,this);
			goodAtMeChk.textFormat = Style.themeTextFormat;
			goodAtMeChk.setSelected(true);
			goodAtMeChk.addEventListener(Event.CHANGE,goodAtMeChanged);
			
			accordion = new Accordion();
			accordion.accordionSkin = accordionSkin;
			accordion.containerHeight = 187;
			accordion.x = 12;
			accordion.y = 35;
			accordion.dataProvider = getMenuDatas();
			accordion.addEventListener(ItemEvent.ITEM_CHANGE,itemChangeHandler);
			addChild(accordion);
			
			itemsCanvas = new UIComponent();
//			Style.setBorderSkin(itemsCanvas);
			itemsCanvas.x = accordion.x+accordion.width+5;
			itemsCanvas.y = accordion.y;
			itemsCanvas.width = width-130;
			itemsCanvas.height = 290;
			addChild(itemsCanvas);
			createCreditItems();
			
			pageBar = new ButtonPageBar();
			pageBar.y = 325;
			pageBar.x = 200;
			pageBar.addEventListener(PageEvent.CHANGED,pageChangedHandler);
			addChild(pageBar); 
		}
		
		private function getMenuDatas():Array{
			var datas:Array = new Array();
			var equipNode:AccordionNode = AccordionNode.createNode("武器",PrestigedConstant.GROUP_WQ);
			var fanjuNode:AccordionNode = AccordionNode.createNode("防具",PrestigedConstant.GROUP_FJ);
			var shipingNode:AccordionNode = AccordionNode.createNode("饰品",PrestigedConstant.GROUP_SP);
			var otherNode:AccordionNode = AccordionNode.createNode("其它",PrestigedConstant.GROUP_QT);
			
			AccordionNode.createNode("战士",PrestigedConstant.CLASS_WQ_ZS,equipNode);
			AccordionNode.createNode("剑仙",PrestigedConstant.CLASS_WQ_SS,equipNode);
			AccordionNode.createNode("天师",PrestigedConstant.CLASS_WQ_XK,equipNode);
			AccordionNode.createNode("医圣",PrestigedConstant.CLASS_WQ_YX,equipNode);
			
			AccordionNode.createNode("头盔",PrestigedConstant.CLASS_FJ_TK,fanjuNode);
			AccordionNode.createNode("护甲",PrestigedConstant.CLASS_FJ_HJ,fanjuNode);
			AccordionNode.createNode("靴子",PrestigedConstant.CLASS_FJ_XZ,fanjuNode);
			AccordionNode.createNode("腰带",PrestigedConstant.CLASS_FJ_YD,fanjuNode);
			AccordionNode.createNode("护腕",PrestigedConstant.CLASS_FJ_HW,fanjuNode);
			
			AccordionNode.createNode("项链",PrestigedConstant.CLASS_SP_XL,shipingNode);
			AccordionNode.createNode("戒指",PrestigedConstant.CLASS_SP_JZ,shipingNode);
			
			datas.push(equipNode,fanjuNode,shipingNode,otherNode); 
			accordion.selectNode = equipNode;
			return datas;
		}
		
		private function createCreditItems():void{
			var columnCount:int = 3;
			items = [];
			for(var i:int = 0;i<9;i++){
				var item:PrestigeExchangeItem = new PrestigeExchangeItem();
				var row:int= i / columnCount;
				var column:int= i % columnCount;
				item.x=2 + column * item.width+ column * 2+3;
				item.y=3 + row * item.height + row * 2+4;
				items.push(item);
				itemsCanvas.addChild(item);
			}
		}

		private function itemChangeHandler(event:ItemEvent):void{
			var node:AccordionNode = event.selectItem as AccordionNode;
			var group_id:int = 0;
			var class_id:int = 0;
			if(node.type == AccordionNode.BRANCH){
				group_id = int(node.data);
			}else{
				group_id = int(node.parent.data);
				class_id = int(node.data);
			}
			addDataLoading();
			PrestigeModule.getInstance().queryPrestige(group_id,class_id);
		}
		
		public function set dataProviders(values:Array):void{
			removeDataLoading();
			_dataProvider = values;
			if(_dataProvider){
				filterDatas();
				changePage(1);
			}
		}
		
		private function goodAtMeChanged(event:Event):void{
			filterDatas();
			changePage(1);
		}
		
		private function filterDatas():void{
			goodAtMeDatas = [];
			if(_dataProvider){
				if(!goodAtMeChk.selected){
					goodAtMeDatas = _dataProvider.concat();
				}else{
					var level:int = GlobalObjectManager.getInstance().user.attr.level;
					for each(var vo:p_prestige_item in _dataProvider){
						if(vo.min_level <= level && level <= vo.max_level){
							goodAtMeDatas.push(vo);
						}
					}
				}
			}
		}
		
		private function changePage(pageNumber:int=1):void{
			if(goodAtMeDatas){
				var size:int = goodAtMeDatas.length;
				var count:int = size%PAGE_COUNT == 0 ? size/PAGE_COUNT : size/PAGE_COUNT+1;
				pageBar.totalPageCount = count;
				pageBar.currentPage = pageNumber;
			}
		}
		
		private function pageChangedHandler(event:PageEvent):void{
			var start:int = (event.pageNumber-1)*PAGE_COUNT;
			var end:int = Math.min(start+PAGE_COUNT,_dataProvider.length);
			var pageDatas:Array = goodAtMeDatas.slice(start,end);
			for each(var item:PrestigeExchangeItem in items){
				var data:Object = pageDatas.shift();
				item.data = data;
			}
		}
		
		public function updatePrestige():void{
			currentCredit.text = GlobalObjectManager.getInstance().user.attr.cur_prestige.toString();
		}
		
		private function get accordionSkin():AccordionSkin{
			var skin:AccordionSkin = new AccordionSkin();
			skin.branchFunc = getBigTypeSkin;
			skin.leafFunc = getSmallTypeSkin;
			return skin;
		}
		
		private function getBigTypeSkin():Skin{
			var selectedSkin:ButtonSkin = Style.getButtonSkin("bigType_1skin","bigType_2skin","bigType_3skin","",GameConfig.CREDIT_UI,new Rectangle(35,10,64,6));
			selectedSkin.selectedSkin = Style.getUIBitmapData(GameConfig.CREDIT_UI, "bigType_3skin");
			return selectedSkin;
		}
		
		private function getSmallTypeSkin():Skin{
			var selectedSkin:ButtonSkin = Style.getButtonSkin("smallType_1skin","smallType_2skin","smallType_3skin","",GameConfig.CREDIT_UI,new Rectangle(10,10,64,6));
			selectedSkin.selectedSkin = Style.getUIBitmapData(GameConfig.CREDIT_UI, "smallType_3skin");
			selectedSkin.color = 0xffff00;
			return selectedSkin;
		}
	}
}