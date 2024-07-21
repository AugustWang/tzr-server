package modules.goal.views
{
	import com.common.Constant;
	import com.common.GlobalObjectManager;
	import com.managers.Dispatch;
	import com.ming.ui.layout.LayoutUtil;
	import com.ming.utils.StringUtil;
	import com.utils.ComponentUtil;
	import com.utils.HtmlUtil;
	import com.utils.PathUtil;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.text.StyleSheet;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import modules.goal.vo.GoalItemVO;
	import modules.goal.vo.GoalVO;
	import modules.mypackage.vo.BaseItemVO;
	
	public class GoalInfoView extends Sprite
	{
		private var conditionTxt:TextField;
		private var chooseTxt:TextField;
		private var rewardTxt:TextField;
		private var goodsContainer:Sprite;
		private var descTxt:TextField;
		private var itemselectedBg:Sprite;
		
		private var chooser:int = 0;
		public var chooseGoods:BaseItemVO;
		
		public function GoalInfoView()
		{
			super();
			var css:StyleSheet = new StyleSheet();
			css.parseCSS("a {color:#00FF00;text-decoration: underline;} a:hover {text-decoration: underline; color: #FFB43C;}");
			
			var tf:TextFormat = new TextFormat("Arial",12,Constant.COLOR_YELLOW);
			ComponentUtil.createTextField("达成目标",0,0,tf,100,25,this);
			conditionTxt = ComponentUtil.createTextField("",10,21,null,577,45,this);
			conditionTxt.wordWrap = true;
			conditionTxt.multiline = true;
			conditionTxt.mouseEnabled = true;
			conditionTxt.addEventListener(TextEvent.LINK,linkHandler);
			
			chooseTxt = ComponentUtil.createTextField("任务奖励",0,71,tf,250,25,this);
			rewardTxt = ComponentUtil.createTextField("",10,91,null,577,25,this);
			goodsContainer = new Sprite();
			goodsContainer.x = 10
			goodsContainer.y = 114;
			addChild(goodsContainer);
			
			
			ComponentUtil.createTextField("目标说明",0,160,tf,100,25,this);
			descTxt = ComponentUtil.createTextField("",10,181,null,577,45,this);
			descTxt.styleSheet = css;
			descTxt.wordWrap = true;
			descTxt.multiline = true;
			descTxt.mouseEnabled = true;
			descTxt.addEventListener(TextEvent.LINK,linkHandler);
			
		}
		
		private function initData():void{
			if(_goalItemVO != null){
				chooseGoods = null;
				if(itemselectedBg && itemselectedBg.parent == goodsContainer){
					itemselectedBg.parent.removeChild(itemselectedBg);
				}
				conditionTxt.htmlText = _goalItemVO.condition;
				var rewardHtml:String = "";
				if(_goalItemVO.rewardVO.bindGold > 0){
					rewardHtml += "绑定元宝："+_goalItemVO.rewardVO.bindGold+"     ";
				}
				if(_goalItemVO.rewardVO.gold > 0){
					rewardHtml += "元宝："+_goalItemVO.rewardVO.gold+"     ";
				}
				if(_goalItemVO.rewardVO.bindSilver > 0){
					rewardHtml += "绑定银子："+_goalItemVO.rewardVO.bindSilver+"     ";
				}
				if(_goalItemVO.rewardVO.silver > 0){
					rewardHtml += "银子："+_goalItemVO.rewardVO.silver+"    ";
				}
				if(_goalItemVO.rewardVO.exp > 0){
					rewardHtml += "经验："+_goalItemVO.rewardVO.exp+"    ";
				}
				rewardTxt.htmlText = rewardHtml;
				chooser = _goalItemVO.rewardVO.muti_choose;
				if(chooser == 1){
					chooseTxt.htmlText = "任务奖励"+HtmlUtil.font("(请选中其中一项作为奖励)","#00ff00");
				}else{
					chooseTxt.text = "任务奖励";
				}
				var child:GoalRewardItem
				while(goodsContainer.numChildren > 0){
					child = goodsContainer.removeChildAt(0) as GoalRewardItem;
					child.removeEventListener(MouseEvent.CLICK,clickGoodsHandler);
				}
				var size:int = _goalItemVO.rewardVO.goods ? _goalItemVO.rewardVO.goods.length : 0;
				var defaultChooseGoods:GoalRewardItem;
				for(var i:int = 0;i<size ; i++){
					child = new GoalRewardItem();
					child.data = _goalItemVO.rewardVO.goods[i];
					if(chooser == 1 && _goalItemVO.status == 2 && !_goalItemVO.takeReward){
						child.addEventListener(MouseEvent.CLICK,clickGoodsHandler);
						if(i == 0){
							defaultChooseGoods = child;
						}
					}
					goodsContainer.addChild(child);
				}
				LayoutUtil.layoutHorizontal(goodsContainer,2);
				if(defaultChooseGoods){
					defaultChooseGoods.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
				}
				descTxt.htmlText = _goalItemVO.desc;
			}
		}
		
		
		private var _goalItemVO:GoalItemVO;
		public function set goalItemVO(vo:GoalItemVO):void{
			_goalItemVO = vo;
			initData();
		}
		
		public function get goalItemVO():GoalItemVO{
			return _goalItemVO;
		}
		
		private function linkHandler(event:TextEvent):void{
			var results:Array = event.text.split("|");
			var commandType:String = StringUtil.trim(results[0]);
			var command:String = StringUtil.trim(results[1]);
			if(commandType == "goto"){
				command = command.replace("#",GlobalObjectManager.getInstance().user.base.faction_id);
				PathUtil.findNPC(command);
			}else if(commandType == "open"){
				Dispatch.dispatch(command);
			}
		}
		
		private function clickGoodsHandler(event:MouseEvent):void{
			var target:GoalRewardItem = event.currentTarget as GoalRewardItem;
			if(itemselectedBg == null){
				itemselectedBg = Style.getViewBg("packItemOverBg");
				itemselectedBg.mouseEnabled = false;
			}
			if(itemselectedBg.parent == null){
				goodsContainer.addChild(itemselectedBg);
			}
			itemselectedBg.x = target.x+2;
			itemselectedBg.y = target.y+2;
			chooseGoods = target.data as BaseItemVO;
		}

	}
}