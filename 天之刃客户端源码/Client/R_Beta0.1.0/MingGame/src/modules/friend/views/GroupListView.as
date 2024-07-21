package modules.friend.views
{
	import com.common.GlobalObjectManager;
	import com.ming.events.ItemEvent;
	import com.ming.ui.constants.ScrollPolicy;
	import com.ming.ui.containers.treeList.BranchNode;
	import com.ming.ui.containers.treeList.LeafNode;
	import com.ming.ui.containers.treeList.Tree;
	
	import flash.display.Sprite;
	import flash.utils.setTimeout;
	
	import modules.family.FamilyLocator;
	import modules.family.FamilyModule;
	import modules.friend.FriendsModule;
	import modules.friend.GroupManager;
	import modules.friend.OpenItemsManager;
	import modules.friend.views.items.FriendCell;
	import modules.friend.views.items.GroupCell;
	import modules.friend.views.part.ChatWindowManager;
	import modules.friend.views.vo.GroupItemVO;
	import modules.friend.views.vo.GroupType;
	import modules.friend.views.vo.GroupVO;
	import modules.team.TeamModule;
	
	import proto.common.p_chat_channel_role_info;
	import proto.common.p_family_info;
	import proto.common.p_role_base;
	import proto.line.p_friend_info;
	
	public class GroupListView extends Sprite
	{
		private var tree:Tree;
		private var itemClicked:Boolean = false;
		private var itemDoubleClicked:Boolean = false;
		public function GroupListView()
		{
			super();
			init();
		}
		
		private function init():void
		{
			tree = new Tree();
			tree.allowSelectBranch = true;
			tree.width = 196;
			tree.height = 335;
			tree.rowHeight = 24;
			tree.cellRenderer = GroupCell;
			tree.addEventListener(ItemEvent.ITEM_DOUBLE_CLICK,onItemDoubleClick);
			addChild(tree);
			tree.dataProvider = GroupManager.getInstance().groupDataProvider;
		}
				
		private function onItemDoubleClick(event:ItemEvent):void{
			var branch:BranchNode = event.selectItem as BranchNode;
			if(branch){
				var groupInfo:GroupVO = branch.data as GroupVO;
				GroupManager.getInstance().initGroup(groupInfo);
				var memebers:Array = GroupManager.getInstance().getMemebers(groupInfo.id);
				ChatWindowManager.getInstance().openGroupWindow(groupInfo,memebers);
			}
		}
	}
}