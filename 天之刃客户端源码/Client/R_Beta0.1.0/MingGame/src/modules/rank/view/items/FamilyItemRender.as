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
	import modules.roleStateG.PlayerConstant;
	
	import proto.common.p_family_active_rank;
	
	public class FamilyItemRender extends UIComponent
	{
		private var rankTxt:TextField;
		private var familyNameTxt:TextField;
		private var familyLvlTxt:TextField;
		private var familyBossTxt:TextField;//门派长
		private var familyFlourishTxt:TextField;//繁荣
		private var stateTxt:TextField;
		public function FamilyItemRender()
		{
			this.width = 439;
			this.height = 25;
			var textFormat:TextFormat = new TextFormat("Tahoma",12,0xffffff,null,null,null,null,null,TextFormatAlign.CENTER);
			rankTxt = ComponentUtil.createTextField("",2,2,textFormat,50,25,this);
			familyNameTxt = ComponentUtil.createTextField("",rankTxt.x + rankTxt.width,rankTxt.y,textFormat,90,25,this);
			familyNameTxt.mouseEnabled = true;
			familyNameTxt.addEventListener(TextEvent.LINK,onLinkHandler);
			familyNameTxt.addEventListener(MouseEvent.ROLL_OVER,onRollOverHandler);
			familyNameTxt.addEventListener(MouseEvent.ROLL_OUT,onRollOutHandler);
			familyLvlTxt = ComponentUtil.createTextField("",familyNameTxt.x + familyNameTxt.width,familyNameTxt.y,textFormat,70,25,this);
			familyBossTxt = ComponentUtil.createTextField("",familyLvlTxt.x + familyLvlTxt.width,familyLvlTxt.y,textFormat,90,25,this);
			familyFlourishTxt = ComponentUtil.createTextField("",familyBossTxt.x + familyBossTxt.width,familyBossTxt.y,textFormat,70,25,this);
			stateTxt = ComponentUtil.createTextField("",familyFlourishTxt.x + familyFlourishTxt.width,familyFlourishTxt.y,textFormat,51,25,this);
		}
		
		private function onLinkHandler(evt:TextEvent):void{
			if(evt.text == "family"){
				FamilyModule.getInstance().getFamilyInfoById(familyVo.family_id);
			}
		}
		private function onRollOverHandler(evt:MouseEvent):void{
			familyNameTxt.textColor = 0x00ff00;
		}
		private function onRollOutHandler(evt:MouseEvent):void{
			if(GlobalObjectManager.getInstance().user.base.family_id == familyVo.family_id){
				familyNameTxt.textColor = 0xffcc00;
			}else{
				familyNameTxt.textColor = 0xffffff;
			}
		}
		
		private function setValue(rank:int,familyName:String,familyLvl:int,familyBoss:String,familyFlourish:int,state:String):void{
			rankTxt.text = rank.toString();
			stateTxt.text = state;
			if(familyName.length != 0){
				familyNameTxt.htmlText = "<a href='event:family'>"+familyName+"</a>";
				familyLvlTxt.text = familyLvl.toString();
				familyBossTxt.text = familyBoss;
				familyFlourishTxt.text = familyFlourish.toString();
			}else{
				familyNameTxt.text = "无";
				familyLvlTxt.text = "无";
				familyBossTxt.text = "无";
				familyFlourishTxt.text = "无";
			}
			
		}
		
		override public function get data():Object{
			return super.data;
		}
		
		private var familyVo:p_family_active_rank;
		override public function set data(value:Object):void{
			super.data = value;
			familyVo = value as p_family_active_rank;
			setValue(familyVo.ranking,familyVo.family_name,familyVo.level,familyVo.owner_role_name,familyVo.active,GameConstant.getNation(familyVo.faction_id));
			if(GlobalObjectManager.getInstance().user.base.family_id == familyVo.family_id){
				rankTxt.textColor = 0xffcc00;
				familyNameTxt.textColor = 0xffcc00;
				familyLvlTxt.textColor = 0xffcc00;
				familyBossTxt.textColor = 0xffcc00;
				familyFlourishTxt.textColor = 0xffcc00;
				stateTxt.textColor = 0xffcc00;
				//				this.bgAlpha = 0.5;
				//				this.bgColor = 0x828558;
			}else{
				rankTxt.textColor = 0xffffff;
				familyNameTxt.textColor = 0xffffff;
				familyLvlTxt.textColor = 0xffffff;
				familyBossTxt.textColor = 0xffffff;
				familyFlourishTxt.textColor = 0xffffff;
				stateTxt.textColor = 0xffffff;
			}
		}
	}
}