package modules.official.views
{
	
	import com.common.GameConstant;
	import com.common.GlobalObjectManager;
	import com.components.DataGrid;
	import com.components.alert.Alert;
	import com.events.ParamEvent;
	import com.globals.GameConfig;
	import com.ming.managers.ToolTipManager;
	import com.ming.ui.containers.VScrollText;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.TextArea;
	import com.ming.ui.controls.core.UIComponent;
	import com.ming.utils.StringUtil;
	import com.utils.ComponentUtil;
	import com.utils.MoneyTransformUtil;
	
	import flash.display.Bitmap;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	import modules.broadcast.KeyWord;
	import modules.official.OfficialConstants;
	import modules.official.OfficialDataManager;
	import modules.official.OfficialModule;
	import modules.official.views.items.OfficialRankItem;
	
	import proto.line.p_faction;
	import proto.line.p_office_position;
	
	public class OfficiaPlacardView extends Sprite
	{
		private var roleName:TextField;
		private var roleJunTitle:TextField;
		private var roleFaction:TextField;
		private var roleFlightPoint:TextField;
		private var roleOfficialName:TextField;
		private var nationMoney:TextField;
		
		private var kingName:TextField;
		private var chengxiang:TextField;
		private var dajiangjun:TextField;
		private var jinyiwei:TextField;
		
		private var placard:VScrollText;
		private var updatePlacardBtn:Button;
		private var leftText:TextField;
		
		private var factionList:DataGrid;
		
		private var leftBG:UIComponent;
		
		public function OfficiaPlacardView()
		{
			super();
			
			leftBG = ComponentUtil.createUIComponent(4,3,225,311);
			Style.setBorderSkin(leftBG);
			addChild(leftBG);
			
			roleName = createInputField("角色：",7,5,leftBG);
			roleJunTitle = createInputField("军衔：",134,5,leftBG);
			roleFaction = createInputField("国家：",7,27,leftBG);
			roleFlightPoint = createInputField("战功：",134,27,leftBG);
			roleOfficialName = createInputField("官职：",7,49,leftBG);
			nationMoney = createInputField("国库：",7,71,leftBG);
			nationMoney.addEventListener(MouseEvent.MOUSE_OVER, showFactionMoneyToolTip);
			nationMoney.addEventListener(MouseEvent.MOUSE_OUT, hideFactionMoneyToolTip);
			nationMoney.mouseEnabled = true;
			
			roleName.text = GlobalObjectManager.getInstance().user.base.role_name;
			roleFaction.text = GameConstant.getNation(GlobalObjectManager.getInstance().user.base.faction_id);
				
			var line:Bitmap = Style.getBitmap(GameConfig.T1_VIEWUI,"hightLightLine");
			line.y = 95;
			line.width = 225;
			leftBG.addChild(line);
			
			kingName =  createInputField("国   王：",7,line.y+5,leftBG);
			dajiangjun =  createInputField("将   军：",7,line.y+27,leftBG);
			chengxiang =  createInputField("内阁大臣：",7,line.y+49,leftBG);
			jinyiwei =  createInputField("锦衣卫：",7,line.y+71,leftBG);
			
			line = Style.getBitmap(GameConfig.T1_VIEWUI,"hightLightLine");
			line.y = 193;
			line.width = 225;
			leftBG.addChild(line);
			
			ComponentUtil.createTextField("国家公告：",7,198,Style.themeTextFormat,118,25,leftBG);	
			placard = new VScrollText();
			placard.textField.textColor = 0xF6F5CD;
			placard.direction = "right";
			placard.verticalScrollPolicy = "auto";
			placard.width = 205;
			placard.height = 74;
			placard.x = 7;
			placard.y = 222;
			leftBG.addChild(placard);
		
			factionList = new DataGrid();
			Style.setBorderSkin(factionList);
			factionList.itemRenderer = OfficialRankItem;
			factionList.x = leftBG.x+leftBG.width+2;
			factionList.y = leftBG.y;
			factionList.width = 230;
			factionList.height = 271;
			factionList.itemHeight = 25;
			factionList.pageCount = 10;
			factionList.addColumn("等级",55);
			factionList.addColumn("角色名",110);
			factionList.addColumn("状态",68);			
			addChild(factionList);
			
			var appointBtn:Button = ComponentUtil.createButton("官职任命",factionList.x+5,factionList.height+10,70,25,this);
			var equipBtn:Button = ComponentUtil.createButton("官职装备",factionList.x+80,factionList.height+10,70,25,this);
			var descBtn:Button = ComponentUtil.createButton("官职说明",factionList.x+155,factionList.height+10,70,25,this);
			
			appointBtn.addEventListener(MouseEvent.CLICK,appointHandler);
			equipBtn.addEventListener(MouseEvent.CLICK,takeEquipHandler);
			descBtn.addEventListener(MouseEvent.CLICK,officialDescHandler);
			
			OfficialDataManager.getInstance().addEventListener(OfficialDataManager.FACTIOIN_INIT,factionInitHandler);
			OfficialDataManager.getInstance().addEventListener(OfficialDataManager.FACTIOIN_NOTICE_UPDATE,factionNoticeHandler);
			OfficialDataManager.getInstance().addEventListener(OfficialDataManager.FACTIOIN_RANK_UPDATE,factionRankHandler);
			addEventListener(Event.ADDED_TO_STAGE,onAddedToStage);
		}
		
		private function factionInitHandler(event:ParamEvent):void{
			init(OfficialDataManager.getInstance().faction);
		}
		
		private function onAddedToStage(event:Event):void{
			OfficialModule.getInstance().getOfficialInfo();	
			OfficialModule.getInstance().getFactionRank();
		}
		
		private function appointHandler(event:MouseEvent):void{
			OfficialModule.getInstance().openOfficePanel(null);
		}
		
		private function takeEquipHandler(event:MouseEvent):void{
			OfficialModule.getInstance().openOfficeEquipPanel();
		}
		
		private function officialDescHandler(event:MouseEvent):void{
			
		}
		
		private function factionRankHandler(event:ParamEvent):void{
			factionList.dataProvider = OfficialDataManager.getInstance().factionRanks;
		}
		
		private function createInputField(proName:String,startX:int,startY:int,parent:DisplayObjectContainer):TextField{
			var title:TextField = ComponentUtil.createTextField(proName,startX,startY,Style.themeTextFormat,NaN,20,parent);
			title.width = title.textWidth+4;
			var valueText:TextField = ComponentUtil.createTextField("",startX+title.width+5,startY,null,100,20,parent)
			return valueText;
		}
		
		private var textArea:TextArea;
		private function onUpdatePlacard(event:MouseEvent):void{
			if(updatePlacardBtn.label == "修改公告"){
				updatePlacardBtn.label = "保存公告";
				if(textArea == null){
					textArea = new TextArea();
					textArea.textField.maxChars = 200;
					textArea.width = placard.width;
					textArea.height = placard.height+5;
					textArea.textField.defaultTextFormat = Style.themeTextFormat;
					textArea.x = placard.x;
					textArea.y = placard.y;
					textArea.addEventListener(Event.CHANGE,onTextChanged);
				}
				leftBG.addChild(textArea);
				textArea.setFocus();
				textArea.text = placard.text;
				createLeftText();
			}else if(updatePlacardBtn.label == "保存公告"){
				var text:String = StringUtil.trim(textArea.text);
				var value:String = placard.text;
				if(text != value){
					if(KeyWord.instance().hasUnRegisterString(text)){
						var str:String = KeyWord.instance().takeUnRegisterString(text);	
						Alert.show(str,"警告",null,null,"确定","",null,false);
						return;
					}
				}
				updatePlacardBtn.label = "修改公告";
				removeText();
				OfficialModule.getInstance().updateNotice(text);
			}
		}

		private function removeText():void{
			if(textArea && textArea.parent){
				textArea.parent.removeChild(textArea);
				textArea.text = "";
			}
			if(leftText && leftText.parent){
				leftText.parent.removeChild(leftText);
			}
		}
		
		private function init(faction:p_faction):void{
			kingName.text =  faction.office_info.king_role_name;
			for each(var role:p_office_position in faction.office_info.offices){
				var item:TextField = getItemByOfficeId(role.office_id);
				if(item){
					item.text = role.role_name;
				}
			}
			nationMoney.text = MoneyTransformUtil.silverToOtherString(faction.silver);
			placard.text = faction.notice_content;
			if(faction.office_info.king_role_id == GlobalObjectManager.getInstance().user.attr.role_id){
				updatePlacardBtn = ComponentUtil.createButton("修改公告",147,198,70,25,leftBG);
				updatePlacardBtn.addEventListener(MouseEvent.CLICK,onUpdatePlacard);
			}else if(updatePlacardBtn){
				updatePlacardBtn.dispose();
			}
			updateMyInfo(faction);
		}
		
		private function updateMyInfo(faction:p_faction):void{
			roleJunTitle.text = "无";
			roleFlightPoint.text = GlobalObjectManager.getInstance().user.attr.jungong.toString();
			roleOfficialName.text = GlobalObjectManager.getInstance().user.attr.office_name;
			nationMoney.text=MoneyTransformUtil.silverToOtherString(faction.silver);
		}
		
		private function showFactionMoneyToolTip(e:MouseEvent):void
		{
			ToolTipManager.getInstance().show("国库最大容量120锭，每天固定获得税收20锭");
		}
		
		private function hideFactionMoneyToolTip(e:MouseEvent):void
		{
			ToolTipManager.getInstance().hide();
		}
		
		public function factionNoticeHandler(event:ParamEvent):void{
			placard.text = OfficialDataManager.getInstance().faction.notice_content;
		}
		
		private function createLeftText():void{
			if(leftText == null){
				leftText = ComponentUtil.createTextField("",65,198,null,100,25,leftBG);
				leftText.textColor = 0xffff00;
			}else{
				leftBG.addChild(leftText);
			}
			leftText.text = "还剩200字";
		}
		
		private function onTextChanged(event:Event):void{
			leftText.text = "还剩"+(200-textArea.text.length)+"字";
		}
		
		private function getItemByOfficeId(officeId:int):TextField{
			if(officeId == OfficialConstants.OFFICIAL_CHENGXIANG){
				return chengxiang;
			}else if(officeId == OfficialConstants.OFFICIAL_DAJIANGJUN){
				return dajiangjun;
			}else if(officeId == OfficialConstants.OFFICIAL_JINYIWEI){
				return jinyiwei;
			}
			return null;
		}
	}
}