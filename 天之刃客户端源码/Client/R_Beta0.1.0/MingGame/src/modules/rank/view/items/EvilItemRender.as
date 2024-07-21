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
	import modules.rank.view.RankWindow;
	import modules.roleStateG.PlayerConstant;
	
	import proto.common.p_role_pkpoint_rank;
	
	public class EvilItemRender extends UIComponent
	{
		private var rankTxt:TextField;
		private var stateOrFamilyTxt:TextField;
		private var playerNameTxt:TextField;
		private var levelTxt:TextField;
		private var pkValueTxt:TextField;
		private var titleTxt:TextField;
		public function EvilItemRender()
		{
			this.width = 439;
			this.height = 25;
			var textFormat:TextFormat = new TextFormat("Tahoma",12,0xffffff,null,null,null,null,null,TextFormatAlign.CENTER);
			rankTxt = ComponentUtil.createTextField("",2,2,textFormat,50,25,this);
			playerNameTxt = ComponentUtil.createTextField("",rankTxt.x + rankTxt.width,rankTxt.y,textFormat,94,25,this);
			playerNameTxt.addEventListener(TextEvent.LINK,onMouseClickHandler);
			playerNameTxt.addEventListener(MouseEvent.ROLL_OVER,onMouseRollOverHandler);
			playerNameTxt.addEventListener(MouseEvent.ROLL_OUT,onMouseRollOutHandler);
			playerNameTxt.mouseEnabled = true;
			playerNameTxt.name = "playerNameTxt";
			
			stateOrFamilyTxt = ComponentUtil.createTextField("",playerNameTxt.x + playerNameTxt.width,playerNameTxt.y,textFormat,94,25,this);
			pkValueTxt = ComponentUtil.createTextField("",stateOrFamilyTxt.x + stateOrFamilyTxt.width,stateOrFamilyTxt.y,textFormat,94,25,this);
			titleTxt = ComponentUtil.createTextField("",pkValueTxt.x + pkValueTxt.width,pkValueTxt.y,textFormat,90,25,this);
		}
		
		private function onMouseClickHandler(evt:TextEvent):void{
			if(evt.text == "playerName"){
				RankModule.getInstance().requestPlayerRankData(evilVo.role_id);
			}
		}
		private function onMouseRollOverHandler(evt:MouseEvent):void{
			playerNameTxt.textColor = 0x00ff00;
		}
		private function onMouseRollOutHandler(evt:MouseEvent):void{
			if(GlobalObjectManager.getInstance().user.base.role_id == evilVo.role_id){
				playerNameTxt.textColor = 0xffcc00;
			}else{
				playerNameTxt.textColor = 0xffffff;
			}
		}
		
		private function setValue(rank:int,playerName:String,stateOrFamily:String,pkValue:int,title:String):void{
			rankTxt.text = rank.toString();
			if(stateOrFamily.length != 0){
				stateOrFamilyTxt.text = stateOrFamily;
			}else{
				stateOrFamilyTxt.text = "无";
			}
			playerNameTxt.htmlText ="<a href='event:playerName'>"+ playerName+"</a>";
			pkValueTxt.text = pkValue.toString();
			if(title.length != 0){
				titleTxt.text = title;
			}else{
				titleTxt.text = "无";
			}
		}
		
		override public function get data():Object{
			return super.data;
		}
		
		private var evilVo:p_role_pkpoint_rank;
		override public function set data(value:Object):void{
			super.data = value;
			evilVo = value as p_role_pkpoint_rank;
			if(RankWindow.evilIndex == 0){
				setValue(evilVo.ranking,evilVo.role_name,GameConstant.getNation(evilVo.faction_id),evilVo.pk_points,evilVo.title);
			}else{
				setValue(evilVo.ranking,evilVo.role_name,evilVo.family_name,evilVo.pk_points,evilVo.title);
			}
			
			if(GlobalObjectManager.getInstance().user.base.role_id == evilVo.role_id){
				rankTxt.textColor = 0xffcc00;
				stateOrFamilyTxt.textColor = 0xffcc00;
				playerNameTxt.textColor = 0xffcc00;
				pkValueTxt.textColor = 0xffcc00;
				titleTxt.textColor = 0xffcc00;
				
				//				this.bgAlpha = 0.5;
				//				this.bgColor = 0x828558;
			}else{
				rankTxt.textColor = 0xffffff;
				stateOrFamilyTxt.textColor = 0xffffff;
				playerNameTxt.textColor = 0xffffff;
				pkValueTxt.textColor = 0xffffff;
				titleTxt.textColor = 0xffffff;
			}
		}
	}
}