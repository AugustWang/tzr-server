package modules.family.views
{
	import com.components.BasePanel;
	import com.components.DataGrid;
	import com.ming.managers.ToolTipManager;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.core.UIComponent;
	import com.utils.ComponentUtil;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import modules.broadcast.views.Tips;
	import modules.family.FamilySkillModule;
	import modules.family.views.items.FamilyBuffItem;
	
	public class FamilyBuffPanel extends BasePanel
	{
		private static const describ:String = "      你每天可以在这里领取1个门派技能状态，效果持续60分钟。" +
			"门派等级越高，领取的技能状态等级也越高，领取技能状态需要消耗一定的门派贡献度。" ;
		private var descTxt:TextField;
		private var skBuffTxt:TextField;
		private var buffList:DataGrid;
		
		private var getBtn:Button;
		private var spget:Sprite;
		
		
		public function FamilyBuffPanel()
		{
			super();
			this.width = 288;
			this.height =380;
			this.title = "门派技能状态";
			
			initView();
		}
		private function initView():void
		{
			var border:UIComponent = ComponentUtil.createUIComponent(7,1,274,312);
			Style.setBorderSkin(border);
			addChild(border);
			
			var bgui:UIComponent = ComponentUtil.createUIComponent(10,2,266,305);
			Style.setBorder1Skin(bgui);
			addChild(bgui);
			
			var bgsp:Sprite = Style.getBlackSprite(264,183);
			bgsp.x =11;
			bgsp.y = 120;
			bgsp.alpha = 0.6;
			addChild(bgsp);
			
			
			var tf:TextFormat = new TextFormat("Tahoma",12,0xF6F5CD); 
			tf.leading = 6
			descTxt = ComponentUtil.createTextField("",14,6,tf,262,98,this);
			descTxt.wordWrap = descTxt.multiline =true;
			descTxt.text = describ ;
			
			var textformat:TextFormat= new TextFormat("Tahoma",13,0xCDE643,true);  
			skBuffTxt = ComponentUtil.createTextField("技能状态列表：",12,100,textformat,100,23,this);
			
			buffList = new DataGrid();
			buffList.itemRenderer = FamilyBuffItem;
			buffList.x = 12;
			buffList.y = 122;
			buffList.width = 262;//335;
			buffList.height = 182;//252;
			buffList.addColumn("门派技能状态列表",131);
			buffList.addColumn("领取条件",130);
			buffList.itemHeight = 32;//25; 
			buffList.pageCount = 5;
			//			buffList.verticalScrollPolicy = ScrollPolicy.OFF;
			addChild(buffList);
			
			
			getBtn = ComponentUtil.createButton("领取",206,316,68,25,this);
			getBtn.addEventListener(MouseEvent.CLICK,onClick);
			
			spget = new Sprite();
			spget.graphics.beginFill(0xffffff,0);
			spget.graphics.drawRect(207,311,68,24);
			spget.graphics.endFill();
			addChild(spget);
			spget.addEventListener(MouseEvent.MOUSE_OVER,onTips);
			spget.addEventListener(MouseEvent.MOUSE_OUT,hideTips);
			spget.mouseEnabled = false;
		}
		private function onTips(evt:MouseEvent):void
		{
			if(getBtn.enabled ==false )
			{
				ToolTipManager.getInstance().show("你已经领取了门派技能状态");
			}
		}
		private function hideTips(evt:MouseEvent):void
		{
			ToolTipManager.getInstance().hide();
		}
		
		
		public function fetched(flag:Boolean = true):void
		{
			if(getBtn)
			{
				getBtn.enabled = !flag;
				spget.mouseEnabled = flag;
			}
		}
		
		public function setBuffs(arr:Array):void  //p_fml_buff
		{
			if(!arr || arr.length==0)
				return;
			buffList.dataProvider = arr;
		}
		
		private function onClick(e:MouseEvent):void
		{
			var buff:Object = buffList.list.selectedItem as Object;
			if(buff){
				FamilySkillModule.getInstance().getFetchBuff(buff.id);
				//				FriendsModel.getInstance().deleteFriend(friend.roleid);
			}else{
				Tips.getInstance().addTipsMsg("请选择一个门派技能状态");
			}
		}
		
		
		
	}
}


