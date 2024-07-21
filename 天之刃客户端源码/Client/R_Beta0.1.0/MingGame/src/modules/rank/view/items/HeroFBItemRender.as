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
	
	import modules.heroFB.HeroFBDataManager;
	import modules.heroFB.HeroFBModule;
	import modules.rank.RankModule;
	
	import proto.common.p_hero_fb_rank;
	
	public class HeroFBItemRender extends UIComponent
	{
		private var rankTxt:TextField;
		private var playerNameTxt:TextField;
		private var factionTxt:TextField;
		private var barrierTxt:TextField;
		private var timeUsedTxt:TextField;
		
		public function HeroFBItemRender()
		{
			this.width = 439;
			this.height = 25;
			var textFormat:TextFormat = new TextFormat("Tahoma",12,0xffffff,null,null,null,null,null,TextFormatAlign.CENTER);
			rankTxt = ComponentUtil.createTextField("",2,2,textFormat,50,25,this);
			playerNameTxt = ComponentUtil.createTextField("",rankTxt.x + rankTxt.width,rankTxt.y,textFormat,100,25,this);
			playerNameTxt.addEventListener(TextEvent.LINK,onMouseClickHandler);
			playerNameTxt.addEventListener(MouseEvent.ROLL_OVER,onMouseRollOverHandler);
			playerNameTxt.addEventListener(MouseEvent.ROLL_OUT,onMouseRollOutHandler);
			playerNameTxt.mouseEnabled = true;
			playerNameTxt.name = "playerNameTxt";
			
			factionTxt = ComponentUtil.createTextField("",playerNameTxt.x + playerNameTxt.width,playerNameTxt.y,textFormat,50,25,this);
			barrierTxt = ComponentUtil.createTextField("",factionTxt.x + factionTxt.width,factionTxt.y,textFormat,90,25,this);
			timeUsedTxt = ComponentUtil.createTextField("",barrierTxt.x + barrierTxt.width,barrierTxt.y,textFormat,128,25,this);
		}
		
		private function onMouseClickHandler(evt:TextEvent):void{
			if(evt.text == "playerName"){
				RankModule.getInstance().requestPlayerRankData(heroFBVo.role_id);
			}
		}
		private function onMouseRollOverHandler(evt:MouseEvent):void{
			playerNameTxt.textColor = 0x00ff00;
		}
		private function onMouseRollOutHandler(evt:MouseEvent):void{
			if(GlobalObjectManager.getInstance().user.base.role_id == heroFBVo.role_id){
				playerNameTxt.textColor = 0xffcc00;
			}else{
				playerNameTxt.textColor = 0xffffff;
			}
		}
		
		private function setValue(rank:int,playerName:String,faction:int,barrier:String, timeUsed:int):void{
			rankTxt.text = rank.toString();
			playerNameTxt.htmlText ="<a href='event:playerName'>"+ playerName+"</a>";
			factionTxt.text = GameConstant.getNation(faction);
			barrierTxt.text = barrier;
			timeUsedTxt.text = String(timeUsed);
		}
		
		override public function get data():Object{
			return super.data;
		}
		
		private var heroFBVo:p_hero_fb_rank;
		override public function set data(value:Object):void{
			super.data = value;
			heroFBVo = value as p_hero_fb_rank;
			var barrierInfo:XML = HeroFBDataManager.getInstance().getBarrierInfo(heroFBVo.barrier_id);
			setValue(heroFBVo.ranking, heroFBVo.role_name, heroFBVo.faction_id, barrierInfo.@barrierStr, heroFBVo.score);
			
			if(GlobalObjectManager.getInstance().user.base.role_id == heroFBVo.role_id){
				rankTxt.textColor = 0xffcc00;
				playerNameTxt.textColor = 0xffcc00;
				factionTxt.textColor = 0xffcc00;
				barrierTxt.textColor = 0xffcc00;
				timeUsedTxt.textColor = 0xffcc00;
			}else{
				rankTxt.textColor = 0xffffff;
				playerNameTxt.textColor = 0xffffff;
				factionTxt.textColor = 0xffffff;
				barrierTxt.textColor = 0xffffff;
				timeUsedTxt.textColor = 0xffffff;
			}
		}
	}
}