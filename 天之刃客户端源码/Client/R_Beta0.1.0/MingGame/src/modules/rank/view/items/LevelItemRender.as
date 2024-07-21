package modules.rank.view.items
{
	import com.common.GameConstant;
	import com.common.GlobalObjectManager;
	import com.ming.ui.controls.core.UIComponent;
	import com.utils.ComponentUtil;
	
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import modules.family.FamilyModule;
	import modules.rank.RankModule;
	import modules.rank.view.PlayerRankView;
	import modules.roleStateG.PlayerConstant;
	
	import proto.common.p_role_level_rank;
	
	public class LevelItemRender extends UIComponent
	{
		private var rankTxt:TextField;
		private var playTxt:TextField;
		private var stateTxt:TextField;
		private var familyTxt:TextField;
		private var levelTxt:TextField;
		private var nameTxt:TextField;
		public function LevelItemRender()
		{
			this.width = 439;
			this.height = 25;
			var textFormat:TextFormat = new TextFormat("Tahoma",12,0xffffff,null,null,null,null,null,TextFormatAlign.CENTER);
			rankTxt = ComponentUtil.createTextField("",2,2,textFormat,50,25,this);
			playTxt = ComponentUtil.createTextField("",rankTxt.x + rankTxt.width,rankTxt.y,textFormat,92,25,this);
			playTxt.addEventListener(TextEvent.LINK,onMouseClickHandler);
			playTxt.addEventListener(MouseEvent.ROLL_OVER,onMouseRollOverHandler);
			playTxt.addEventListener(MouseEvent.ROLL_OUT,onMouseRollOutHandler);
			playTxt.mouseEnabled = true;
			playTxt.name = "playerNameTxt";
			stateTxt = ComponentUtil.createTextField("",playTxt.x + playTxt.width,playTxt.y,textFormat,50,25,this);
			familyTxt = ComponentUtil.createTextField("",stateTxt.x + stateTxt.width,stateTxt.y,textFormat,92,25,this);
//			familyTxt.mouseEnabled = true;
			familyTxt.addEventListener(TextEvent.LINK,onLinkHandler);
			familyTxt.addEventListener(MouseEvent.ROLL_OVER,onRollOverHandler);
			familyTxt.addEventListener(MouseEvent.ROLL_OUT,onRollOutHandler);
			levelTxt = ComponentUtil.createTextField("",familyTxt.x + familyTxt.width,familyTxt.y,textFormat,50,25,this);
			nameTxt = ComponentUtil.createTextField("",levelTxt.x + levelTxt.width,levelTxt.y,textFormat,88,25,this);
		}
		
		private function onLinkHandler(evt:TextEvent):void{
			if(evt.text == "family"){
//				FamilyModel.getInstance().getFamilyInfoById(levelRankVo.);
			}
		}
		private function onRollOverHandler(evt:MouseEvent):void{
			familyTxt.textColor = 0x00ff00;
		}
		private function onRollOutHandler(evt:MouseEvent):void{
			if(GlobalObjectManager.getInstance().user.base.role_id == levelRankVo.role_id){
				familyTxt.textColor = 0xffcc00;
			}else{
				familyTxt.textColor = 0xffffff;
			}
		}
		
		
		private function onMouseClickHandler(evt:TextEvent):void{
			if(evt.text == "playerName"){
				RankModule.getInstance().requestPlayerRankData(levelRankVo.role_id);
			}
		}
		private function onMouseRollOverHandler(evt:MouseEvent):void{
			playTxt.textColor = 0x00ff00;
		}
		private function onMouseRollOutHandler(evt:MouseEvent):void{
			if(GlobalObjectManager.getInstance().user.base.role_id == levelRankVo.role_id){
				playTxt.textColor = 0xffcc00;
			}else{
				playTxt.textColor = 0xffffff;
			}
		}
		
		//赋值
		private function setValue(rank:int,player:String,state:String,family:String,level:int,name:String):void{
			rankTxt.text = rank.toString();
			playTxt.htmlText ="<a href='event:playerName'>"+ player+"</a>";
			stateTxt.text = state;
			if(family.length == 0){
				familyTxt.text = "无";
			}else{
				familyTxt.htmlText ="<a href='event:family'>"+ family+"</a>";
			}
			levelTxt.text = level.toString();
			if(name.length == 0){
				nameTxt.text = "无";
			}else{
				nameTxt.text = name;
			}
		}
		
		override public function get data():Object{
			return super.data;
		}
		
		private var levelRankVo:p_role_level_rank;
		override public function set data(value:Object):void{
			super.data = value;
			levelRankVo = value as p_role_level_rank;
			setValue(levelRankVo.ranking,levelRankVo.role_name,GameConstant.getNation(levelRankVo.faction_id),levelRankVo.family_name,levelRankVo.level,levelRankVo.title)
		
			if(GlobalObjectManager.getInstance().user.base.role_id == levelRankVo.role_id){
				rankTxt.textColor = 0xffcc00;
				playTxt.textColor = 0xffcc00;
				stateTxt.textColor = 0xffcc00;
				familyTxt.textColor = 0xffcc00;
				levelTxt.textColor = 0xffcc00;
				nameTxt.textColor = 0xffcc00;
				//				this.bgAlpha = 0.5;
				//				this.bgColor = 0x828558;
			}else{
				rankTxt.textColor = 0xffffff;
				playTxt.textColor = 0xffffff;
				stateTxt.textColor = 0xffffff;
				familyTxt.textColor = 0xffffff;
				levelTxt.textColor = 0xffffff;
				nameTxt.textColor = 0xffffff;
			}
		}
	}
}