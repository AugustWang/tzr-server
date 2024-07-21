package modules.market
{
	import com.globals.GameConfig;
	import com.ming.ui.containers.treeList.BranchNode;
	import com.ming.ui.containers.treeList.LeafNode;
	import com.ming.ui.containers.treeList.TreeDataProvider;
	import com.ming.ui.containers.treeList.TreeNode;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	
	import modules.market.item.TreeItem;
	import modules.market.vo.ColorType;
	import modules.market.vo.LevelType;
	import modules.market.vo.ParemType;
	import modules.market.vo.SortType;
	
	import proto.line.m_stall_buy_toc;
	import proto.line.m_stall_list_tos;
	import proto.line.p_stall_list_item;

	public class MarketDataManager
	{
		public var firstBranchNode:BranchNode;
		public var firstLeafNode:LeafNode;
		
		private var loader:URLLoader;
		private var isLoading:Boolean=false;
		//等级
		public var levelVector:Array;
		//颜色
		public var colorVector:Array;
		//排序
		public var sortVector:Array;
		//内外攻
		public var paremVector:Array;
		//树的数据源
		public var treeData:TreeDataProvider;
		//目前显示的内容
		public var infoViewData:m_stall_list_tos;
		
		public function MarketDataManager(){
			initData();
		}
		
		private function initData():void{
			infoViewData = new m_stall_list_tos();
			
			levelVector = [];
			colorVector = [];
			sortVector = [];
			paremVector = [];
			
			loader = new URLLoader();
			loader.dataFormat = URLLoaderDataFormat.TEXT;
			loader.addEventListener(Event.COMPLETE,onComplete);
			loader.addEventListener(IOErrorEvent.IO_ERROR,onIOErrorHandler);
			var url:String = GameConfig.ROOT_URL+"com/data/market.xml";
			loader.load(new URLRequest(url));
		}
		
		private function onComplete(event:Event):void{
			var market:XML = new XML(loader.data);
			loader.removeEventListener(Event.COMPLETE,onComplete);
			loader.removeEventListener(IOErrorEvent.IO_ERROR,onIOErrorHandler);
			isLoading = true;
			
			var levels_length:int = market.levels.level.length();
			for(var i:int=0; i<levels_length; i++){
				var level:LevelType = new LevelType();
				level.label = market.levels.level[i].@label.toString();
				level.min = int(market.levels.level[i].@min.toString());
				level.max = int(market.levels.level[i].@max.toString());
				levelVector.push(level);
			}
			
			var colors_length:int = market.colors.color.length();
			for(var j:int=0;j<colors_length;j++){
				var color:ColorType = new ColorType();
				color.label = market.colors.color[j].@label.toString();
				color.value = int(market.colors.color[j].@value.toString());
				colorVector.push(color);
			}
			
			var sorts_length:int = market.sorts.sort.length();
			for(var k:int=0;k<sorts_length;k++){
				var sort:SortType = new SortType();
				sort.label = market.sorts.sort[k].@label.toString();
				if(market.sorts.sort[k].@value.toString() == "true"){
					sort.value = true;
				}else {
					sort.value = false;
				}
				sortVector.push(sort);
			}
			
			var parems_length:int = market.parems.parem.length();
			for(var l:int=0;l<parems_length;l++){
				var parem:ParemType = new ParemType();
				parem.label = market.parems.parem[l].@label.toString();
				parem.value = int(market.parems.parem[l].@value.toString());
				paremVector.push(parem);
			}
			
			setTreeData(market.types);
		}
		
		//创建叶子数据
		private function setTreeData(data:XMLList):void{
			treeData = new TreeDataProvider();
			var parentData:Object;
			var data_length:int = data[0].type.length();
			for(var i:int=0;i<data_length;i++){
				var parentName:String = data[0].type[i].@name;
				var parentId:int = int(data[0].type[i].@id);
				parentData={};
				parentData.name = parentName;
				parentData.id = parentId;
				var parent:BranchNode = createBranchNode(treeData,parentData);
				if(i == 0){
					firstBranchNode = parent;
				}
				treeData.addItem(parent);
				//插入子对象
				var sub_length:int = data[0].type[i].sub.length();
				for(var j:int=0;j<sub_length;j++){
					var info:XML = data[0].type[i].sub[j];
					var child:LeafNode = createLeafNode(treeData,info,parent);
					if(j == 0){
						firstLeafNode = child;
					}
				}
			}
		}
		
		/**
		 * 创建支节点
		 */		
		private function createBranchNode(_dataProvider:TreeDataProvider,data:Object=null,parent:BranchNode=null):BranchNode{
			var branchNode:BranchNode = new BranchNode(_dataProvider);
			if(parent){
				parent.addChildNode(branchNode);
			}
			branchNode.data = data;
			return branchNode;
		}
		/**
		 * 创建叶节点
		 */	
		private function createLeafNode(_dataProvider:TreeDataProvider,data:XML=null,parent:BranchNode=null):LeafNode{
			var leafNode:LeafNode = new LeafNode(_dataProvider);
			if(parent){
				parent.addChildNode(leafNode);
				parent.data = parent.data;
				invalidateItem(parent);
			}
			leafNode.data = data;
			return leafNode;
		}
		
		/**
		 *更新
		 */		
		private function invalidateItem(node:TreeNode):void{
			if(node){
				treeData.invalidateItem(node);
			}
		}
		
		private function onIOErrorHandler(event:IOErrorEvent):void{
			isLoading = false;
		}
		
		
		//目前显示对象的list
		public var goods_list:Array = [];
		//重新更新展现的数据
		public function resetGoodsList(lists:Array):void{
			if(goods_list.length > 0){
				goods_list.length = 0;
			}
			var lists_length:int = lists.length;
			for(var i:int=0;i<lists_length; i++){
				var data:p_stall_list_item = lists[i];
				goods_list.push(data);
			}
		}
		
		//删除购买的数据
		public function deteleBugGood(msg:m_stall_buy_toc):Array{
			var lists_length:int = goods_list.length;
			for(var i:int=0;i<lists_length; i++){
				var data:p_stall_list_item = goods_list[i];
				if(data.role_id == msg.role_id && data.goods_detail.id == msg.goods_id){
					if(data.goods_detail.current_num - msg.num == 0){
						goods_list.splice(i,1);
						if(goods_list.length == 0){
							MarketModule.getInstance().sendData(infoViewData.type,
																1,
																infoViewData.typeid,
																infoViewData.sort_type,
																infoViewData.is_reverse,
																infoViewData.is_gold_first,
																infoViewData.min_level,
																infoViewData.max_level,
																infoViewData.color,
																infoViewData.pro);
						}
					}else {
						data.goods_detail.current_num -= msg.num;
					}
					break;
				}
			}
			return goods_list;
		}
	}
}