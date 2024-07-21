package modules.friend.views.part
{
	import com.ming.ui.layout.LayoutUtil;
	import com.scene.tile.Hash;
	
	import flash.display.Sprite;
	
	public class ChatWindowBar extends Sprite
	{
		public static const PRIVATE:String = "private";
		public static const GROUP:String = "group";
		private var items:Hash;
		public function ChatWindowBar()
		{
			super();
			items = new Hash();
		}
		
		public function addWindowItem(chatInfo:Object,type:String=PRIVATE):ChatIconItem{
			var id:String = type == PRIVATE ? chatInfo.roleid : chatInfo.id;
			var item:ChatIconItem = items.take(id) as ChatIconItem;
			if(item == null){
				item = new ChatIconItem();	
				item.type = type;
				item.chatInfo = chatInfo;
				addChild(item);
				items.put(item,id);
				LayoutUtil.layoutHorizontal(this,5);
			}
			return item;
		}
		
		public function removeWindowItem(id:Object):void{
			var item:ChatIconItem = items.take(id.toString()) as ChatIconItem;
			if(item){
				item.dispose();
				items.remove(id.toString());
			}
		}
		
		public function getChatIconItem(id:Object):ChatIconItem{
			var item:ChatIconItem = items.take(id.toString()) as ChatIconItem;
			if(item){
				return item;
			}
			return null;
		}
		
		public function setSmall(value:Boolean,id:Object):void{
			var item:ChatIconItem = items.take(id.toString()) as ChatIconItem;
			if(item){
				item.small = value;
			}
		}
		
		public function getPosition(id:Object):Array{
			var item:ChatIconItem = items.take(id.toString()) as ChatIconItem;
			if(item){
				return [x+item.x+item.width/2,y+item.y+item.height/2];
			}
			return [0,0];
		}
	}
}