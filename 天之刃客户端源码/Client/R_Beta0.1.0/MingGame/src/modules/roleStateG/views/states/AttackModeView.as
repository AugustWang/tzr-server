package modules.roleStateG.views.states
{
	import com.common.GlobalObjectManager;
	import com.components.menuItems.MenuBar;
	import com.components.menuItems.MenuItemData;
	import com.events.ParamEvent;
	import com.globals.GameConfig;
	import com.ming.events.ItemEvent;
	import com.ming.managers.ToolTipManager;
	import com.ming.ui.controls.Button;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import modules.roleStateG.RoleItemConstant;
	import modules.scene.SceneDataManager;
	
	import proto.common.p_role;
	import proto.line.m_role2_pkmodemodify_toc;
	
	public class AttackModeView extends Sprite
	{
		public static const EVENT_CHANGE_ATTACK_MODE:String="EVENT_CHANGE_ATTACK_MODE";
		
		public static const AttackModes:Array=["和\n平", "全\n体", "队\n伍", "宗\n族", "国\n家", "善\n恶"];
		public static const AttackModeLabels:Array=["和平", "全体", "队伍", "门派", "国家", "善恶"];
		//		private var menu:RoleAttackModeMenu;
		private var menu:MenuBar;
//		private var bgView:Sprite;
//		private var pkModelBtn:TextField;
		private var isPopUp:Boolean;
		private var newMode:int;
		
		private var pkModelBtn:Button;
		
		public function AttackModeView()
		{
			super();
			initView();
		}
		
		private function initView():void
		{
			this.buttonMode=true;
			this.useHandCursor=true;
			pkModelBtn = new Button();
			pkModelBtn.textBold = true;
			pkModelBtn.leftPadding = -1;
			pkModelBtn.topPadding = -1;
			pkModelBtn.textColor = 0xAFE1EC;
			pkModelBtn.width = 20;
			pkModelBtn.height = 37;
			pkModelBtn.bgSkin = Style.getButtonSkin("sell_1skin","sell_2skin","sell_3skin","",GameConfig.T1_UI);
			addChild(pkModelBtn);
			
			var user:p_role=GlobalObjectManager.getInstance().user;
			pkModelBtn.label=AttackModes[user.base.pk_mode];
			pkModelBtn.addEventListener(MouseEvent.CLICK, showMemberBox)
			pkModelBtn.addEventListener(MouseEvent.ROLL_OVER, showToolTip);
			pkModelBtn.addEventListener(MouseEvent.ROLL_OUT, hideToolTip);
			menu=new MenuBar();
			menu.itemWidth=80;
			menu.itemHeight = 26;
			menu.labelField="label";
			menu.addEventListener(ItemEvent.ITEM_CLICK, onChangeMode);
			var data:Vector.<MenuItemData>=new Vector.<MenuItemData>;
			for (var i:int=0; i < AttackModes.length; i++)
			{
				var item:MenuItemData=new MenuItemData();
				item.label=AttackModeLabels[i];
				item.index=i;
				item.toolTip=RoleItemConstant.attackTips[i];
				data.push(item);
			}
			menu.dataProvider=data;
		}
		
		
		private function showToolTip(evt:MouseEvent):void
		{
			if (GlobalObjectManager.getInstance().user.attr.level >= 20 || SceneDataManager.isProtectMap == false)
			{
				ToolTipManager.getInstance().show("攻击模式");
			} 
			else
			{
				ToolTipManager.getInstance().show("未到20级在新手区（太平村、横涧山、鄱阳湖），不能切换攻击模式");
			}
		}
		
		private function hideToolTip(evt:MouseEvent):void
		{
			ToolTipManager.getInstance().hide();
		}
		private function onChangeMode(e:ItemEvent):void
		{
			newMode=int(e.selectItem.index)
			var evt:ParamEvent=new ParamEvent(AttackModeView.EVENT_CHANGE_ATTACK_MODE, newMode, true);
			this.dispatchEvent(evt);
		}
		//外部调用这个函数
		public function toChangeMode(mode:int):void{
			newMode=mode;
			var evt:ParamEvent=new ParamEvent(AttackModeView.EVENT_CHANGE_ATTACK_MODE, newMode, true);
			this.dispatchEvent(evt);
		}
		public function reset():void
		{
			pkModelBtn.label=AttackModes[GlobalObjectManager.getInstance().user.base.pk_mode];
			GlobalObjectManager.getInstance().attackMode=GlobalObjectManager.getInstance().user.base.pk_mode;
		}
		
		public function update(vo:m_role2_pkmodemodify_toc):void
		{
			if (vo.succ)
			{
				pkModelBtn.label=AttackModes[vo.pk_mode];
				GlobalObjectManager.getInstance().user.base.pk_mode=vo.pk_mode;
				GlobalObjectManager.getInstance().attackMode=vo.pk_mode;
			}
			else
			{
				
			}
		}
		
		private function showMemberBox(evt:MouseEvent):void
		{
			//			if (isPopUp == false)
			//			{
			if (GlobalObjectManager.getInstance().user.attr.level >= 20 
				|| SceneDataManager.isProtectMap == false)
			{
				menu.show(this.x + 30, this.y);
				//					isPopUp=true;
			}
			//			}
			//			else
			//			{
			//				isPopUp=false;
			//				//_memberBox.remove();已经remove了,不用写这句
			//			}
		}
	}
}