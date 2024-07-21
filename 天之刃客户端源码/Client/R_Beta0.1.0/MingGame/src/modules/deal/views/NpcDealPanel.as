package modules.deal.views {
	import com.components.BasePanel;
	import com.ming.ui.constants.ScrollPolicy;
	import com.ming.ui.containers.Canvas;
	import com.ming.ui.controls.ToggleButton;
	import com.utils.ComponentUtil;
	import com.utils.HtmlUtil;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.utils.Dictionary;
	
	import modules.deal.NpcDealModule;
	import modules.mypackage.vo.BaseItemVO;
	
	import proto.line.m_family_collect_get_role_info_toc;
	
	

	/**
	 * NPC 兑换面版
	 * @author caochuncheng2002@gmail.com
	 *
	 */
	public class NpcDealPanel extends BasePanel {
		public function NpcDealPanel() {
			super();
			initView();

		}
		private var canvas:Canvas;
		private var tabArr:Array;
		private var tabs:Vector.<ToggleButton>;
		private var leftContainer:Sprite;
        private var bottomContainer:Sprite;//用以放置除恶令牌，破损腰牌，普通腰牌，厚实腰牌，门派贡献度，采集积分
		private var viewsPool:Dictionary;
        
	
		private var contributeNum:TextField;//门派贡献度
		private var collectScore:TextField;//采集积分
		
		private var txtallArr:Array;
		private var chuEArr:Array;
		private var yaopaiArr:Array;
		private var contrArr:Array;
		private var collArr:Array;
		
		private var currentrefgoods:String="";
		private var currentID:int=0;
		private var bottomArray:Array = null;
		private var viewArray:Array=null;
		/**
		 * 初始化左边按钮列表
		 */
		private function initLeftButton():void
		{
			leftContainer = Style.getBlackSprite(106,308,3);//338改为308-298
			leftContainer.x = 10;
			leftContainer.y = 5;
			var toggleButton:ToggleButton;
			tabs = new Vector.<ToggleButton>;
			for (var i:int = 0;i < this.tabArr.length;i++) {
				var yNumber:Number = (26 + 1) * i + 5;
				toggleButton = ComponentUtil.createToggleButton(tabArr[i].name,3,yNumber,100,26,leftContainer);
				toggleButton.addEventListener(MouseEvent.CLICK,onChangeView);
				toggleButton.name = tabArr[i].id;
				tabs.push(toggleButton);
			}
			this.addChild(leftContainer);			
		}
		
		private function getGoodslist(dealId:int):void
		{
			for (var i:int = 0;i < this.tabArr.length;i++) 
			{
				if(tabArr[i].id==dealId)
					currentrefgoods = tabArr[i].refgoodsid;
			}
		}
		//格式为key：value
		private function refbottom(numDict:Array):void
		{

			while(bottomContainer.numChildren > 0){
				bottomContainer.removeChildAt(0);
			}
			var textXpos:int=495;
			for each(var item:String in numDict)
			{		
				var tempMsg:Array = item.split("|");
				var onetext:TextField = ComponentUtil.createTextField("",textXpos,1,null,145,30,bottomContainer);				
				onetext.htmlText = tempMsg[0].toString()+"×"+tempMsg[1].toString();
				textXpos-=100;
			}
			var yaopaiTxt:TextField=ComponentUtil.createTextField("",textXpos,1,null,60,30,bottomContainer);
			yaopaiTxt.htmlText=HtmlUtil.bold("现有:");
			for each(var viewItem:NpcDealItem in viewArray)
			{
				viewItem.haveItemInfo = numDict;
			}
			
		}
			
		/**
		 * 初始化界面
		 */
		private function initView():void {
			this.width = 650;
			this.height = 385;
			this.title = "兑换物品";
			this.titleAlign = 2;

			this.tabArr = NpcDealModule.getInstance().findDealGroupArr();
			initLeftButton();
			//右边容器
			canvas = new Canvas();
			this.addChild(canvas);
			canvas.visible = true;
			canvas.x = leftContainer.x + leftContainer.width + 3;
			canvas.y = leftContainer.y;
			canvas.width = this.width - (leftContainer.x + leftContainer.width + 15);
			canvas.height = 308;
			canvas.verticalScrollPolicy = ScrollPolicy.ON;            
			viewsPool = new Dictionary;
           
			var bwidth:Number=this.width-15;
			//下容器 
			txtallArr=[];
			chuEArr=[];
			yaopaiArr=[];
			contrArr=[];
			collArr=[];
			bottomContainer=Style.getBlackSprite(630,35);
			bottomContainer.x=10;
			bottomContainer.y=leftContainer.y+leftContainer.height+3;
			addChild(bottomContainer);

			if(tabs.length > 0 ){
				changeView(tabs[0]);
			}
		}

		/**
		 * 点击左边菜单事件
		 * @param event
		 *
		 */
		private function onChangeView(event:MouseEvent):void {
			var toggleButton:ToggleButton = event.currentTarget as ToggleButton;
			changeView(toggleButton);
		}
		private var currentView:Sprite;
        /**
         * 选择兑换组界面变化 
         * @param toggleButton
         * 
         */        
		private function changeView(toggleButton:ToggleButton):void {
			
			if (toggleButton) {
				for each (var t:ToggleButton in tabs) {
					t.selected = false;
				}
				toggleButton.selected = true;
				var dealId:int = int(toggleButton.name);
				var view:Sprite = viewsPool[dealId];
				if (view == null) {
					//根据兑换的详细信息处理生成界面
					var dealObj:Object = NpcDealModule.getInstance().findDealObj(dealId);
                    if(dealObj == null){
                        view = currentView;
                    }else{
					    view = initCanvasView(dealObj);
                    }
				}
				if (view != currentView && view) {
					if (currentView) {
						canvas.removeChild(currentView);
					}					
                    currentView = view;
					canvas.addChild(view);
					canvas.updateSize();
					updateBottom(dealId);
				}
			}
		}
		private function updateBottom(dealId:int):void{
			currentID = dealId;
			refviewBottom();
		}
		
		
		public function refviewBottom():void
		{
			getGoodslist(currentID);
			refreshbottom();			
		}
        /**
         * 初始化右边界面 
         * @param dealObj
         * 
         */        
        private function initCanvasView(dealObj:Object):Sprite{
            var length:int = dealObj.dealItemArr.length;
            var col:int = 3;
            var row:int = length/col;
            if(length % col > 0){
                row = row + 1;
            }
            var height:int = 308;
            if(row * (85 + 3) < height){
                height = 308;
            }else{
                height = row * (85 + 3);
            }
			viewArray = new Array();
            var view:Sprite = Style.getBlackSprite(col * (165 + 3),height,3);
            var xNumber:int = 0;
            var yNumber:int = 0;
            for(var i:int = 0; i < row; i ++){
                xNumber = 0;
                yNumber = 1 + i * (NpcDealItem.DEAL_ITEM_HEIGHT + 3);
                for(var j:int = 0; j < col; j++){
                    var index:int = i * col + j;
                    if(index < length){
                        xNumber = 1 + j * (NpcDealItem.DEAL_ITEM_WIDTH + 3);
                        var dealItemObj:Object = dealObj.dealItemArr[index];
                        var npcDealItem:NpcDealItem = new NpcDealItem();
                        npcDealItem.dealItemData = dealItemObj;
                        npcDealItem.x = xNumber;
                        npcDealItem.y = yNumber;
                        view.addChild(npcDealItem);
						viewArray.push(npcDealItem);
                    }
                }
            }
            return view;
        }
		
		
		public function refreshbottom():void
		{
			bottomArray = new Array();
			if(currentrefgoods.length>0)
			{
				var goodlist:Array = currentrefgoods.split("|");
				for each(var temp:String in goodlist)
				{
					var goods:Array = temp.split(":");
					var goodID:int = goods[0].toString();
					var goodName:String = goods[1].toString();
					var typeID:int = goods[2].toString();
					var ceNum:int=0;
					switch(typeID)
					{
						case 1:
							ceNum=NpcDealModule.getInstance().getPackItemById(goodID);
							bottomArray.push(goodName+"|"+ceNum.toString()+"|"+goodID.toString());
							refbottom(bottomArray);							
							break;
						case 2:
							NpcDealModule.getInstance().getattrvaluebyID(goodID,refattrvalue,goodName);
							break;
					}					
				}				
			}
		}
		
		public function refattrvalue(vo:m_family_collect_get_role_info_toc,key:String):void
		{
			bottomArray.push(key+"|"+vo.value.toString()+"|"+vo.type_id.toString());
			refbottom(bottomArray);
		}
		
		public function getNumByName(name:String):int
		{
			for each(var item:String in bottomArray)
			{		
				var tempMsg:Array = item.split("|");
				if(name == tempMsg[0].toString())
					return tempMsg[1];
			}
			return 0;
		}
	}
}