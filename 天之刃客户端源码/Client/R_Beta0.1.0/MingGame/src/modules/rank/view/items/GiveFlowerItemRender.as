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
	
	import modules.rank.RankModule;
	import modules.rank.view.PlayerRankView;
	import modules.roleStateG.PlayerConstant;
	
	import proto.common.p_role_give_flowers_last_week_rank;
	import proto.common.p_role_give_flowers_rank;
	import proto.common.p_role_give_flowers_today_rank;
	import proto.common.p_role_give_flowers_yesterday_rank;
	
	public class GiveFlowerItemRender extends UIComponent
	{
		private var rankTxt:TextField;
		private var playTxt:TextField;
		private var scoreTxt:TextField;
		private var familyTxt:TextField;
		private var stateTxt:TextField;
		private var titleTxt:TextField;
		public function GiveFlowerItemRender()
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
			scoreTxt = ComponentUtil.createTextField("",playTxt.x + playTxt.width,playTxt.y,textFormat,60,25,this);
			familyTxt = ComponentUtil.createTextField("",scoreTxt.x + scoreTxt.width,scoreTxt.y,textFormat,92,25,this);
			stateTxt = ComponentUtil.createTextField("",familyTxt.x + familyTxt.width,familyTxt.y,textFormat,50,25,this);
			titleTxt = ComponentUtil.createTextField("",stateTxt.x + stateTxt.width,stateTxt.y,textFormat,78,25,this);
		}
		
		
		private function onMouseClickHandler(evt:TextEvent):void{
			if(evt.text == "playerName"){
				RankModule.getInstance().requestPlayerRankData(this.data.role_id);
			}
		}
		private function onMouseRollOverHandler(evt:MouseEvent):void{
			playTxt.textColor = 0x00ff00;
		}
		private function onMouseRollOutHandler(evt:MouseEvent):void{
				if(GlobalObjectManager.getInstance().user.base.role_id == this.data.role_id){
					playTxt.textColor = 0xffcc00;
				}else{
					playTxt.textColor = 0xffffff;
				}
		}
		
		//赋值
		private function setValue(rank:int,player:String,score:int,family:String,state:String,title:String):void{
			rankTxt.text = rank.toString();
			playTxt.htmlText ="<a href='event:playerName'>"+ player+"</a>";
			scoreTxt.text = score.toString();
			if(family.length == 0){
				familyTxt.text = "无";
			}else{
				familyTxt.text = family;
			}
			stateTxt.text = state;
			if(title.length == 0){
				titleTxt.text = "无";
			}else{
				titleTxt.text = title;
			}
		}
		
		override public function get data():Object{
			return super.data;
		}
		
		override public function set data(value:Object):void{
			super.data = value;
			if(value == null)return;
			if(value is p_role_give_flowers_rank){
				var vo1:p_role_give_flowers_rank = value as p_role_give_flowers_rank;
				setValue(vo1.ranking,vo1.role_name,vo1.score,vo1.family_name,GameConstant.getNation(vo1.faction_id),vo1.title);
			}else if(value is p_role_give_flowers_yesterday_rank){
				var vo2:p_role_give_flowers_yesterday_rank = value as p_role_give_flowers_yesterday_rank;
				setValue(vo2.ranking,vo2.role_name,vo2.score,vo2.family_name,GameConstant.getNation(vo2.faction_id),vo2.title);
			}else if(value is p_role_give_flowers_today_rank){
				var vo3:p_role_give_flowers_today_rank = value as p_role_give_flowers_today_rank;
				setValue(vo3.ranking,vo3.role_name,vo3.score,vo3.family_name,GameConstant.getNation(vo3.faction_id),vo3.title);
			}else if(value is p_role_give_flowers_last_week_rank){
				var vo4:p_role_give_flowers_last_week_rank = value as p_role_give_flowers_last_week_rank;
				setValue(vo4.ranking,vo4.role_name,vo4.score,vo4.family_name,GameConstant.getNation(vo4.faction_id),vo4.title);
			}
			
			if(GlobalObjectManager.getInstance().user.base.role_id == value.role_id){
				rankTxt.textColor = 0xffcc00;
				playTxt.textColor = 0xffcc00;
				scoreTxt.textColor = 0xffcc00;
				stateTxt.textColor = 0xffcc00;
				familyTxt.textColor = 0xffcc00;
				titleTxt.textColor = 0xffcc00;
				//				this.bgAlpha = 0.5;
				//				this.bgColor = 0x828558;
			}else{
				rankTxt.textColor = 0xffffff;
				playTxt.textColor = 0xffffff;
				scoreTxt.textColor = 0xffffff;
				stateTxt.textColor = 0xffffff;
				familyTxt.textColor = 0xffffff;
				titleTxt.textColor = 0xffffff;
			}
		}
	}
}