package modules.rank.view.items
{
	import com.common.GameColors;
	import com.common.GameConstant;
	import com.common.GlobalObjectManager;
	import com.ming.ui.controls.core.UIComponent;
	import com.net.connection.Connection;
	import com.utils.ComponentUtil;
	
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import modules.pet.PetModule;
	import modules.rank.RankModule;
	import modules.rank.view.RankWindow;
	import modules.roleStateG.PlayerConstant;
	
	import proto.common.p_role_pet_rank;
	import proto.line.m_pet_info_tos;
	
	public class PetItemRender extends UIComponent
	{
		private var rankTxt:TextField;
		private var petIdTxt:TextField;
		private var petTypeNameTxt:TextField;
		private var playerNameTxt:TextField;
		private var stateTxt:TextField;
		private var numberTxt:TextField; //宠物评分
		
		public function PetItemRender()
		{
			this.width=439;
			this.height=25;
			var textFormat:TextFormat=new TextFormat("Tahoma", 12, 0xffffff, null, null, null, null, null, TextFormatAlign.CENTER);
			rankTxt=ComponentUtil.createTextField("", 2, 2, textFormat, 50, 25, this);
			petIdTxt=ComponentUtil.createTextField("", rankTxt.x + rankTxt.width, rankTxt.y, textFormat, 70, 25, this);
			petIdTxt.addEventListener(TextEvent.LINK, onMouseClickHandler);
			petIdTxt.addEventListener(MouseEvent.ROLL_OVER, onMouseRollOverHandler);
			petIdTxt.addEventListener(MouseEvent.ROLL_OUT, onMouseRollOutHandler);
			petIdTxt.mouseEnabled=true;
			petIdTxt.name="petIdTxt";
			
			playerNameTxt=ComponentUtil.createTextField("", petIdTxt.x + petIdTxt.width, petIdTxt.y, textFormat, 100, 25, this);
			playerNameTxt.addEventListener(TextEvent.LINK, onMouseClickHandler);
			playerNameTxt.addEventListener(MouseEvent.ROLL_OVER, onMouseRollOverHandler);
			playerNameTxt.addEventListener(MouseEvent.ROLL_OUT, onMouseRollOutHandler);
			playerNameTxt.mouseEnabled=true;
			playerNameTxt.name="playerNameTxt";
			stateTxt=ComponentUtil.createTextField("", playerNameTxt.x + playerNameTxt.width, playerNameTxt.y, textFormat, 50, 25, this);
			petTypeNameTxt=ComponentUtil.createTextField("", stateTxt.x + stateTxt.width, stateTxt.y, textFormat, 100, 25, this);
			numberTxt=ComponentUtil.createTextField("", petTypeNameTxt.x + petTypeNameTxt.width, petTypeNameTxt.y, textFormat, 48, 25, this);
		}
		
		private function onMouseClickHandler(evt:TextEvent):void
		{
			var txt:String=evt.text;
			if (txt == "petId")
			{
				var vo:m_pet_info_tos=new m_pet_info_tos;
				vo.pet_id=petVO.pet_id;
				vo.role_id=GlobalObjectManager.getInstance().user.base.role_id;
				Connection.getInstance().sendMessage(vo);
			}
			else if (txt == "playerName")
			{
				RankModule.getInstance().requestPlayerRankData(petVO.role_id);
			}
			
		}
		
		private function onMouseRollOverHandler(evt:MouseEvent):void
		{
			if (evt.currentTarget.name == "petIdTxt")
			{
				petIdTxt.textColor=0x00ff00;
				//RankEquipToolTip.getInstance().playerName = equipVo.role_name;
			}
			else if (evt.currentTarget.name == "playerNameTxt")
			{
				playerNameTxt.textColor=0x00ff00;
			}
			
		}
		
		private function onMouseRollOutHandler(evt:MouseEvent):void
		{
			if (evt.currentTarget.name == "petIdTxt")
			{
				if (GlobalObjectManager.getInstance().user.base.role_id == petVO.role_id)
				{
					petIdTxt.textColor=0xffcc00;
				}
				else
				{
					petIdTxt.textColor=0xffffff;
				}
			}
			else if (evt.currentTarget.name == "playerNameTxt")
			{
				if (GlobalObjectManager.getInstance().user.base.role_id == petVO.role_id)
				{
					playerNameTxt.textColor=0xffcc00;
				}
				else
				{
					playerNameTxt.textColor=0xffffff;
				}
			}
		}
		
		private function setValue(rank:int, petId:int, playerName:String, state:String, petTypeName:String, number:int):void
		{
			rankTxt.text=rank.toString();
			if (petId != 0)
			{
				petIdTxt.htmlText="<a href='event:petId'><u>" + petId + "</u></a>";
			}
			else
			{
				petIdTxt.text="无";
			}
			playerNameTxt.htmlText="<a href='event:playerName'>" + playerName + "</a>";
			stateTxt.text=state;
			petTypeNameTxt.text=petTypeName;
			numberTxt.text=number.toString();
		}
		
		override public function get data():Object
		{
			return super.data;
		}
		
		private var petVO:p_role_pet_rank;
		private var color:uint;
		
		override public function set data(value:Object):void
		{
			super.data=value;
			petVO=value as p_role_pet_rank;
			
			if (RankWindow.selectIndex == 0)
			{ //总排行榜
				setValue(petVO.ranking, petVO.pet_id, petVO.role_name, GameConstant.getNation(petVO.faction_id), petVO.pet_type_name, petVO.score);
			}
			petTypeNameTxt.textColor=GameColors.getColorByIndex(petVO.color);
			if (GlobalObjectManager.getInstance().user.base.role_id == petVO.role_id)
			{
				rankTxt.textColor=0xffcc00;
				playerNameTxt.textColor=0xffcc00;
				petIdTxt.textColor=0xffcc00;
				stateTxt.textColor=0xffcc00;
				numberTxt.textColor=0xffcc00;
				
				//				this.bgAlpha = 0.5;
				//				this.bgColor = 0x828558;
			}
			else
			{
				rankTxt.textColor=0xffffff;
				playerNameTxt.textColor=0xffffff;
				stateTxt.textColor=0xffffff;
				numberTxt.textColor=0xffffff;
				petIdTxt.textColor=0xffffff;
			}
		}
	}
}