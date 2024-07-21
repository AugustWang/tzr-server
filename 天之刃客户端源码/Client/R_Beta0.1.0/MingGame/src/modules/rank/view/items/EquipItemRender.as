package modules.rank.view.items
{
	import com.common.GameConstant;
	import com.common.GlobalObjectManager;
	import com.ming.managers.ToolTipManager;
	import com.ming.ui.controls.core.UIComponent;
	import com.utils.ComponentUtil;
	
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import modules.mypackage.ItemConstant;
	import modules.mypackage.PackageModule;
	import modules.mypackage.managers.ItemLocator;
	import modules.mypackage.views.ChatItemToolTip;
	import modules.mypackage.vo.BaseItemVO;
	import modules.mypackage.vo.EquipVO;
	import modules.rank.RankModule;
	import modules.rank.view.PlayerRankView;
	import modules.rank.view.RankEquipToolTip;
	import modules.rank.view.RankWindow;
	import modules.roleStateG.PlayerConstant;
	
	import proto.common.p_equip_rank;
	
	public class EquipItemRender extends UIComponent
	{
		private var rankTxt:TextField;
		private var equipNameTxt:TextField;
		private var playerNameTxt:TextField;
		private var stateTxt:TextField;
		private var numberTxt:TextField;//系数
		public function EquipItemRender()
		{
			this.width = 439;
			this.height = 25;
			var textFormat:TextFormat = new TextFormat("Tahoma",12,0xffffff,null,null,null,null,null,TextFormatAlign.CENTER);
			rankTxt = ComponentUtil.createTextField("",2,2,textFormat,50,25,this);
			equipNameTxt = ComponentUtil.createTextField("",rankTxt.x + rankTxt.width,rankTxt.y,textFormat,150,25,this);
			equipNameTxt.addEventListener(TextEvent.LINK,onMouseClickHandler);
			equipNameTxt.addEventListener(MouseEvent.ROLL_OVER,onMouseRollOverHandler);
			equipNameTxt.addEventListener(MouseEvent.ROLL_OUT,onMouseRollOutHandler);
			equipNameTxt.mouseEnabled = true;
			equipNameTxt.name = "equipNameTxt";
			
			playerNameTxt = ComponentUtil.createTextField("",equipNameTxt.x + equipNameTxt.width,equipNameTxt.y,textFormat,100,25,this);
			playerNameTxt.addEventListener(TextEvent.LINK,onMouseClickHandler);
			playerNameTxt.addEventListener(MouseEvent.ROLL_OVER,onMouseRollOverHandler);
			playerNameTxt.addEventListener(MouseEvent.ROLL_OUT,onMouseRollOutHandler);
			playerNameTxt.mouseEnabled = true;
			playerNameTxt.name = "playerNameTxt";
			stateTxt = ComponentUtil.createTextField("",playerNameTxt.x + playerNameTxt.width,playerNameTxt.y,textFormat,58,25,this);
			numberTxt = ComponentUtil.createTextField("",stateTxt.x + stateTxt.width,stateTxt.y,textFormat,64,25,this);
		}
		
		private function onMouseClickHandler(evt:TextEvent):void{
			var txt:String = evt.text;
			if(txt == "equip"){
				PackageModule.getInstance().getGoodsInfo(equipVo.goods_id,equipVo.role_id,1);
				RankEquipToolTip.getInstance().point(this.stage.mouseX,this.stage.mouseY,this);
				
			}else if(txt == "playerName"){
				RankModule.getInstance().requestPlayerRankData(equipVo.role_id);
			}

		}
		
		private function onMouseRollOverHandler(evt:MouseEvent):void{
			if(evt.currentTarget.name == "equipNameTxt"){
				equipNameTxt.textColor = 0x00ff00;
				RankEquipToolTip.getInstance().playerName = equipVo.role_name;
			}else if(evt.currentTarget.name == "playerNameTxt"){
				playerNameTxt.textColor = 0x00ff00;
			}
			
		}
		
		private function onMouseRollOutHandler(evt:MouseEvent):void{
			if(evt.currentTarget.name == "equipNameTxt"){
				equipNameTxt.textColor = color;
			}else if(evt.currentTarget.name == "playerNameTxt"){
				if(GlobalObjectManager.getInstance().user.base.role_id == equipVo.role_id){
					playerNameTxt.textColor = 0xffcc00;
				}else{
					playerNameTxt.textColor = 0xffffff;
				}
				
			}
		}
		
		private function setValue(rank:int,equipName:String,playerName:String,state:String,number:int):void{
			rankTxt.text = rank.toString();
			if(equipName.length != 0){
				equipNameTxt.htmlText ="<a href='event:equip'>"+ equipName+"</a>";
			}else{
				equipNameTxt.text = "无";
			}
			playerNameTxt.htmlText ="<a href='event:playerName'>"+ playerName+"</a>";
			stateTxt.text = state;
			numberTxt.text = number.toString();
		}
		
		override public function get data():Object{
			return super.data;
		}
		private var equipVo:p_equip_rank;
		private var vo:EquipVO;
		private var color:uint;
		override public function set data(value:Object):void{
			super.data = value;
			equipVo = value as p_equip_rank;
			vo = new EquipVO();
			vo.typeId = equipVo.type_id;
			var qulityArr:Array = ItemConstant.ITEM_QUALITY;
			var name:String =qulityArr[equipVo.colour] + vo.name;
			var colorArr:Array = ItemConstant.COLOR_VALUES2;
			color = colorArr[equipVo.colour];
			equipNameTxt.textColor = color;
			if(RankWindow.selectIndex == 0){//总排行榜
				setValue(equipVo.ranking,name,equipVo.role_name,GameConstant.getNation(equipVo.faction_id),equipVo.refining_score);
			}else if(RankWindow.selectIndex == 1){//强化排行榜
				setValue(equipVo.ranking,name,equipVo.role_name,GameConstant.getNation(equipVo.faction_id),equipVo.reinforce_score);
			}else if(RankWindow.selectIndex == 2){//镶嵌排行榜
				setValue(equipVo.ranking,name,equipVo.role_name,GameConstant.getNation(equipVo.faction_id),equipVo.stone_score);
			}
			
			if(GlobalObjectManager.getInstance().user.base.role_id == equipVo.role_id){
				rankTxt.textColor = 0xffcc00;
				playerNameTxt.textColor = 0xffcc00;
				stateTxt.textColor = 0xffcc00;
				numberTxt.textColor = 0xffcc00;
				
//				this.bgAlpha = 0.5;
//				this.bgColor = 0x828558;
			}else{
				rankTxt.textColor = 0xffffff;
				playerNameTxt.textColor = 0xffffff;
				stateTxt.textColor = 0xffffff;
				numberTxt.textColor = 0xffffff;
			}
		}
	}
}