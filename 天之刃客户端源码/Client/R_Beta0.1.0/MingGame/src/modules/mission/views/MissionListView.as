package modules.mission.views {
	import com.globals.GameConfig;
	import com.ming.events.ItemEvent;
	import com.ming.ui.constants.ScrollPolicy;
	import com.ming.ui.containers.treeList.BranchNode;
	import com.ming.ui.containers.treeList.LeafNode;
	import com.ming.ui.containers.treeList.Tree;
	import com.ming.ui.containers.treeList.TreeDataProvider;
	import com.ming.ui.containers.treeList.TreeNode;
	import com.ming.ui.skins.Skin;
	
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	
	import modules.mission.MissionConstant;
	import modules.mission.views.items.MissionNodeItem;

	public class MissionListView extends Sprite {
		private var tree:Tree;
		private var missionDetail:MissionDetailView;

		private var mainNode:BranchNode;
		private var branchNode:BranchNode;
		private var circleNode:BranchNode;
		private var _treeDataProvider:TreeDataProvider;
		public var selectedItem:Object;

		public function MissionListView() {
			super();
			
			var left:Skin = Style.getSkin("contentBg", GameConfig.T1_VIEWUI, new Rectangle(10, 10, 120, 104));
			left.setSize(225,339);
			addChild(left);
			
			tree = new Tree();
			tree.cellRenderer = MissionNodeItem;
			tree.overSkin.bgSkin = Style.getSkin("listItemOver",GameConfig.T1_UI,new Rectangle(4,4,154,10));
			tree.selectedSkin.bgSkin = Style.getSkin("listItemOver",GameConfig.T1_UI,new Rectangle(4,4,154,10));
			tree.width = 217;
			tree.height = 372;
			tree.y = 3;
			tree.x = 5;
			tree.verticalScrollPolicy = ScrollPolicy.AUTO;
			tree.addEventListener(ItemEvent.ITEM_CHANGE, onItemChanged);
			addChild(tree);
	
			var right:Skin = Style.getSkin("contentBg", GameConfig.T1_VIEWUI, new Rectangle(10, 10, 120, 104));
			right.x = 228;
			right.setSize(300,339);
			addChild(right);
			
			missionDetail = new MissionDetailView();
			missionDetail.x = 230;
			missionDetail.y = tree.y;
			addChild(missionDetail);
			_treeDataProvider = createTreeDataProvider();
			tree.dataProvider = _treeDataProvider;
		}

		/**
		 * 获取任务节点数据
		 * @return
		 */
		public function get treeDataProvider():TreeDataProvider {
			return _treeDataProvider;
		}

		/**
		 * 更新任务数据
		 */
		private var _dataProvdier:Object;

		public function set dataProvdier(value:Object):void {
			_dataProvdier = value;
			startRender();
			if(!this.selectOneMission()){
				missionDetail.data = null;
			}
		}

		public function get dataProvdier():Object {
			return _dataProvdier;
		}

		/**
		 * 开始渲染界面
		 */
		private function startRender():void {
			removeChildren(mainNode);
			removeChildren(branchNode);
			removeChildren(circleNode);
			if (_dataProvdier) {
				for each (var mission:Object in _dataProvdier) {
					addMission(mission);
				}
			}
		}

		/**
		 * 选择节点发送改变事件
		 * @param event
		 *
		 */
		private function onItemChanged(event:ItemEvent):void {
			var node:TreeNode = event.selectItem as TreeNode;
			if (node.nodeType == TreeNode.LEAF_NODE) {
				selectedItem = node.data;
				missionDetail.data = selectedItem;
			}
		}

		/**
		 * 添加任务到对应界面
		 * @param mission
		 */
		private function addMission(mission:Object):void {
			if (mission.type == MissionConstant.TYPE_MAIN) {
				createLeafNode(_treeDataProvider, mission, mainNode);
			} else if (mission.type == MissionConstant.MISSION_TYPE_BRANCH) {
				createLeafNode(_treeDataProvider, mission, branchNode);
			} else if (mission.type == MissionConstant.TYPE_CIRCLE) {
				createLeafNode(_treeDataProvider, mission, circleNode);
			}
		}

		/**
		 * 删除支节点下的所有子节点，并关闭当前节点
		 * @param node
		 *
		 */
		private function removeChildren(node:BranchNode):void {
			node.closeNode();
			while(node.children.length > 0){
				var treeNode:TreeNode = node.children[0];
				treeNode.removeNode();
			}
		}

		/**
		 * 构建树状任务数据
		 * @return
		 *
		 */
		private function createTreeDataProvider():TreeDataProvider {
			var treeDataProvider:TreeDataProvider = new TreeDataProvider();
			mainNode = createBranchNode(treeDataProvider, "主线任务");
			branchNode = createBranchNode(treeDataProvider, "支线任务");
			circleNode = createBranchNode(treeDataProvider, "循环任务");
			treeDataProvider.addItems([mainNode, branchNode, circleNode]);
			return treeDataProvider;
		}

		/**
		 * 创建支节点
		 */
		private function createBranchNode(_dataProvider:TreeDataProvider, data:Object = null, parent:BranchNode = null):BranchNode {
			var branchNode:BranchNode = new BranchNode(_dataProvider);
			if (parent) {
				parent.addChildNode(branchNode);
			}
			branchNode.data = data;
			return branchNode;
		}

		/**
		 * 创建叶节点
		 */
		private function createLeafNode(_dataProvider:TreeDataProvider, data:Object = null, parent:BranchNode = null):LeafNode {
			var leafNode:LeafNode = new LeafNode(_dataProvider);
			if (parent) {
				parent.addChildNode(leafNode);
				parent.data = parent.data;
			}
			leafNode.data = data;
			return leafNode;
		}

		/**
		 * 随便打开某个节点 主支循
		 */
		private function selectOneMission():Boolean {
			//默认打开所有的树形结构
			var hasChilden:Boolean = false;
			if (circleNode.children.length > 0) {
				this.doSelectOneMission(circleNode, 3);
				hasChilden = true;
			}
			if (branchNode.children.length > 0) {
				this.doSelectOneMission(branchNode, 2);
				hasChilden = true;
			}
			if (mainNode.children.length > 0) {
				this.doSelectOneMission(mainNode, 1);
				hasChilden = true;
			}
			

			return hasChilden;
		}
		
		/**
		 * 选择一个任务
		 */
		private function doSelectOneMission(branchNode:BranchNode, index:int):void{
			branchNode.openNode();
			selectedItem = branchNode.children[0].data;
			missionDetail.data = selectedItem;
			tree.selectedItem = branchNode.children[0];
			tree.selectedIndex = index;
			tree.invalidateList();
		}
		
	}
}