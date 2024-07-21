package modules.family.views
{
	import com.components.BasePanel;
	import com.components.DataGrid;
	import com.components.alert.Alert;
	import com.ming.events.ComponentEvent;
	import com.ming.events.ItemEvent;
	import com.ming.ui.constants.ScrollPolicy;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.TextInput;
	import com.ming.utils.StringUtil;
	import com.utils.ComponentUtil;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	import modules.family.FamilyModule;
	import modules.family.views.items.RecruitItem;
	
	import proto.common.p_role_base;
	
	public class RecruitPanel extends BasePanel
	{
		private var list:DataGrid;
		private var nameInput:TextInput;
		private var okBtn:Button;
		private var cancelBtn:Button;
		private var roles:Array;
		public function RecruitPanel(key:String=null)
		{
			super(key);
			initView();
		}
	
		private function initView():void{
			title = "招收帮众";
			
			width = 444;
			height = 320;
			
			var backBg:Sprite = Style.getBlackSprite(424,250);
			backBg.x = 10;
			backBg.mouseEnabled = false;
			addChild(backBg);
			
			list = new DataGrid();
			Style.setBorderSkin(list);
			list = new DataGrid();
			list.itemRenderer = RecruitItem;
			list.x = 2;
			list.y = 2;
			list.width = 420;
			list.height = 247;
			list.addColumn("性别",50);
			list.addColumn("角色名",100);
			list.addColumn("等级",50);
			list.addColumn("职业",60);
			list.addColumn("操作",160);
			list.itemHeight = 25;
			list.pageCount = 9;
			list.list.itemDoubleClickEnabled = true;
			list.list.addEventListener(ItemEvent.ITEM_DOUBLE_CLICK,onItemDoubleClick);
			list.verticalScrollPolicy = ScrollPolicy.ON;
			backBg.addChild(list);
			
			ComponentUtil.createTextField("玩家名字：",40,256,null,60,25,this);
			nameInput = new TextInput();
			nameInput.maxChars = 7;
			nameInput.restrict = "[0-9a-zA-Z][\u4E00-\u9FA5]";
			nameInput.width = 100;
			nameInput.x = 105;
			nameInput.y = 256;
			nameInput.addEventListener(ComponentEvent.ENTER,onEnterHandler);
			addChild(nameInput);
			
			okBtn = ComponentUtil.createButton("邀请加入",220,254,80,25,this);
			okBtn.addEventListener(MouseEvent.CLICK,onOkHandler);
			
			cancelBtn = ComponentUtil.createButton("取消",333,254,60,25,this);
			cancelBtn.addEventListener(MouseEvent.CLICK,onCloseHandler);
		}
		
		private function onItemDoubleClick(event:ItemEvent):void{
			var item:Object = list.list.selectedItem;
			if(item){
				var info:p_role_base = item as p_role_base;
				nameInput.text = info.role_name;
			}
		}
		
		private function onEnterHandler(event:ComponentEvent):void{
			onOkHandler(null);
		}
		
		public function getRecruits():void{
			addDataLoading();
			FamilyModule.getInstance().getRecruits();	
		}
		
		public function setRecruits(list:Array):void{
			removeDataLoading();
			this.roles = list;
			this.list.dataProvider = roles;
		}
		
		private function onOkHandler(event:MouseEvent):void{
			var text:String = StringUtil.trim(nameInput.text);
			if(text == ""){
				Alert.show("玩家名称不能为空!","警告",null,null,"确定","",null,false);return;
			}
			FamilyModule.getInstance().inviteJoinFamily(text);
		}
		
		private function onCloseHandler(event:MouseEvent):void{
			closeWindow();
		}
	}
}