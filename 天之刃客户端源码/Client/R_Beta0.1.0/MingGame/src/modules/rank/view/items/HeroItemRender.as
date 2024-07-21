package modules.rank.view.items
{
	import com.common.GlobalObjectManager;
	import com.ming.ui.controls.core.UIComponent;
	
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import com.utils.ComponentUtil;
	import modules.family.FamilyModule;
	import modules.rank.RankModule;
	
	import proto.common.p_role_gongxun_rank;
	
	public class HeroItemRender extends UIComponent
	{
		private var rankTxt:flash.text.TextField;
		private var familyTxt:TextField;
		private var playNameTxt:TextField;
		private var levelTxt:TextField;
		private var heroValueTxt:TextField;
		private var titleTxt:TextField;
		public function HeroItemRender()
		{
			this.width = 439;
			this.height = 25;
			var textFormat:TextFormat = new TextFormat("Tahoma",12,0xffffff,null,null,null,null,null,TextFormatAlign.CENTER);
			rankTxt = ComponentUtil.createTextField("",2,2,textFormat,50,25,this);
			playNameTxt = ComponentUtil.createTextField("",rankTxt.x + rankTxt.width,rankTxt.y,textFormat,85,25,this);
			playNameTxt.addEventListener(TextEvent.LINK,onMouseClickHandler);
			playNameTxt.addEventListener(MouseEvent.ROLL_OVER,onMouseRollOverHandler);
			playNameTxt.addEventListener(MouseEvent.ROLL_OUT,onMouseRollOutHandler);
			playNameTxt.mouseEnabled = true;
			playNameTxt.name = "playerNameTxt";
			familyTxt = ComponentUtil.createTextField("",playNameTxt.x + playNameTxt.width,playNameTxt.y,textFormat,85,25,this);
			familyTxt.addEventListener(TextEvent.LINK,onMouseClickHandler);
			familyTxt.addEventListener(MouseEvent.ROLL_OVER,onMouseRollOverHandler);
			familyTxt.addEventListener(MouseEvent.ROLL_OUT,onMouseRollOutHandler);
//			familyTxt.mouseEnabled = true;
			familyTxt.name = "familyTxt";
			levelTxt = ComponentUtil.createTextField("",familyTxt.x + familyTxt.width,familyTxt.y,textFormat,50,25,this);
			heroValueTxt = ComponentUtil.createTextField("",levelTxt.x + levelTxt.width,levelTxt.y,textFormat,66,25,this);
			titleTxt = ComponentUtil.createTextField("",heroValueTxt.x + heroValueTxt.width,heroValueTxt.y,textFormat,85,25,this);
		}
		
		private function onMouseClickHandler(evt:TextEvent):void{
			if(evt.text == "playerName"){
				RankModule.getInstance().requestPlayerRankData(heroVo.role_id);
			}else if(evt.text == "familyTxt"){
//				FamilyModel.getInstance().getFamilyInfoById(familyID);
			}
		}
		private function onMouseRollOverHandler(evt:MouseEvent):void{
			if(evt.currentTarget.name == "playerNameTxt"){
				playNameTxt.textColor = 0x00ff00;
			}else if(evt.currentTarget.name == "familyTxt"){
				familyTxt.textColor = 0x00ff00;
			}
		}
		private function onMouseRollOutHandler(evt:MouseEvent):void{
			if(evt.currentTarget.name == "playerNameTxt"){
				if(GlobalObjectManager.getInstance().user.base.role_id == heroVo.role_id){
					playNameTxt.textColor = 0xffcc00;
				}else{
					playNameTxt.textColor = 0xffffff;
				}
			}else if(evt.currentTarget.name == "familyTxt"){
				if(GlobalObjectManager.getInstance().user.base.role_id == heroVo.role_id){
					familyTxt.textColor = 0xffcc00;
				}else{
					familyTxt.textColor = 0xffffff;
				}
			}
		}
		
		private function setValue(rank:int,playName:String,family:String,level:int,heroVaue:int,title:String):void{
			rankTxt.text = rank.toString();
			if(family.length != 0){
				familyTxt.htmlText = "<a href='event:family'>"+family+"</a>";
			}else{
				familyTxt.text = "无";
			}
			playNameTxt.htmlText ="<a href='event:playerName'>"+ playName+"</a>";
			levelTxt.text = level.toString();
			heroValueTxt.text = heroVaue.toString();
			if(title.length != 0){
				titleTxt.text = title;
			}else{
				titleTxt.text = "无";
			}
		}
		
		override public function get data():Object{
			return super.data;
		}
		
		private var heroVo:p_role_gongxun_rank;
		override public function set data(value:Object):void{
			super.data = value;
			heroVo = value as p_role_gongxun_rank;
			setValue(heroVo.ranking,heroVo.role_name,heroVo.family_name,heroVo.level,heroVo.gongxun,heroVo.title);
			if(GlobalObjectManager.getInstance().user.base.role_id == heroVo.role_id){
				rankTxt.textColor = 0xffcc00;
				familyTxt.textColor = 0xffcc00;
				playNameTxt.textColor = 0xffcc00;
				levelTxt.textColor = 0xffcc00;
				heroValueTxt.textColor = 0xffcc00;
				titleTxt.textColor = 0xffcc00;
				
				//				this.bgAlpha = 0.5;
				//				this.bgColor = 0x828558;
			}else{
				rankTxt.textColor = 0xffffff;
				familyTxt.textColor = 0xffffff;
				playNameTxt.textColor = 0xffffff;
				levelTxt.textColor = 0xffffff;
				heroValueTxt.textColor = 0xffffff;
				titleTxt.textColor = 0xffffff;
			}
		}
	}
}