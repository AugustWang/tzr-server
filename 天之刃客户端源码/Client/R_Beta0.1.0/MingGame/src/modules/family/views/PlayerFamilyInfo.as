package modules.family.views
{
	import com.common.GlobalObjectManager;
	import com.components.BasePanel;
	import com.globals.GameConfig;
	import com.ming.events.CloseEvent;
	import com.ming.ui.constants.ScrollDirection;
	import com.ming.ui.containers.VScrollText;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.core.UIComponent;
	import com.utils.ComponentUtil;
	import com.utils.MoneyTransformUtil;
	
	import flash.display.Bitmap;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import modules.family.FamilyConstants;
	import modules.family.FamilyModule;
	import modules.letter.LetterModule;
	
	import proto.common.p_family_info;
	
	public class PlayerFamilyInfo extends BasePanel
	{
		public var call:Function;
		public var familyInfo:p_family_info;
		
		private var tfCreator:TextField;
		private var tfFamilyHeader:TextField;
		private var tfFamilyNumber:TextField;
		
		private var tfFamilyGrade:TextField;
		private var tfFamilyProsperity:TextField;
		private var tfFamilyMoney:TextField;
		
		private var titleText:TextField;
		private var placard:VScrollText;
		
		private var nameTF:TextFormat;
		private var contentTF:TextFormat;
		
		private var applicationBtn:Button;
		private var letterBtn:Button;
		private var bg2:UIComponent ;
		public function PlayerFamilyInfo()
		{
			super();
			width = 560;
			height = 350;
			var bg1:UIComponent = ComponentUtil.createUIComponent(12,5,536,75);
			Style.setPopUpSkin(bg1);
			bg1.x = 12;
			bg1.y = 5;
			addChild(bg1);
		
			nameTF = Style.textFormat;
			nameTF.color = 0xE4CE6B;
			
			contentTF = Style.textFormat;
			contentTF.color = 0xF7F5AB;
			
			var lb:TextField = ComponentUtil.createTextField("创始人：",11,12,nameTF,60,25,bg1);
			tfCreator = createText(59,12,125,bg1);
			
			lb = ComponentUtil.createTextField("掌门：",187,12,nameTF,60,25,bg1);
			tfFamilyHeader = createText(222,12,115,bg1);
			
			lb = ComponentUtil.createTextField("门派人数：",344,12,nameTF,60,25,bg1);
			tfFamilyNumber = createText(402,12,123,bg1);
			
			lb = ComponentUtil.createTextField("门派等级：",11,47,nameTF,70,25,bg1);
			tfFamilyGrade = createText(68,47,112,bg1);
			
			lb = ComponentUtil.createTextField("门派繁荣度：",187,47,nameTF,70,25,bg1);
			tfFamilyProsperity = createText(257,47,81,bg1);

			lb = ComponentUtil.createTextField("门派资金：",344,47,nameTF,60,25,bg1);
			tfFamilyMoney = createText(402,47,123,bg1);
			
			bg2 = ComponentUtil.createUIComponent(12,87,536,217);
			Style.setPopUpSkin(bg2);
			addChild(bg2);
			
			var tf:TextFormat = Style.textFormat;
			tf.align = "center";
			tf.bold = true;
			tf.color = 0x00ff00;
			titleText = ComponentUtil.buildTextField("门派对外公告",tf,534,25,bg2);
			titleText.y = 2;
			
			placard = new VScrollText();
			placard.y = 28;
			placard.width = 536;
			placard.height = 165;
			placard.textField.textColor = 0xF6F5CD;
			placard.verticalScrollPolicy = "auto";
			placard.direction = ScrollDirection.RIGHT;
			bg2.addChild(placard);
			
			letterBtn = ComponentUtil.createButton("给掌门写信",320,188,100,25,bg2);
			letterBtn.addEventListener(MouseEvent.CLICK,onLetterHandler);
		}
		
		private function createText(x:Number,y:Number,w:Number,container:DisplayObjectContainer):TextField{
			return ComponentUtil.createTextField("",x,y,contentTF,w,21,container);
		}
		
		public function setFamilyInfo(info:p_family_info):void{
			this.familyInfo = info;
			this.title = familyInfo.family_name + " 门派详情";
			tfCreator.text = familyInfo.create_role_name;
			tfFamilyHeader.text = familyInfo.owner_role_name;
			var totalCount:int = FamilyConstants.counts[info.level];
			tfFamilyNumber.text = familyInfo.cur_members+"/"+totalCount;
			tfFamilyGrade.text = familyInfo.level.toString();
			tfFamilyProsperity.text = familyInfo.active_points.toString();
			tfFamilyMoney.text = MoneyTransformUtil.silverToOtherString(familyInfo.money);
		
			placard.text = familyInfo.public_notice;
			
			var family_factionId:int = info.faction_id;
			var role_factionId:int = GlobalObjectManager.getInstance().user.base.faction_id;
			var hasFamily:Boolean = GlobalObjectManager.getInstance().user.base.family_id != 0;
			var hasLevel:Boolean = GlobalObjectManager.getInstance().user.attr.level >= 10;
			if(family_factionId == role_factionId && familyInfo.cur_members < totalCount && !hasFamily && hasLevel){
				letterBtn.x = 320;
				if(applicationBtn == null){
					applicationBtn = ComponentUtil.createButton("申请加入",430,192,100,25,bg2);
					applicationBtn.addEventListener(MouseEvent.CLICK,onApplicationHandler);
				}
			}else{
				if(applicationBtn){
					applicationBtn.dispose();
					applicationBtn == null;
				}
				letterBtn.x = 430;
			}
		}
		
		private function onApplicationHandler(event:MouseEvent):void{
			FamilyModule.getInstance().joinFamilyRequest(familyInfo.family_id);
		}
		
		private function onLetterHandler(event:MouseEvent):void{
			LetterModule.getInstance().openLetter(familyInfo.owner_role_name);//写信
		}
		
		override protected function closeHandler(event:CloseEvent=null):void{
			super.closeHandler(event);
			if(call != null){
				call.apply(null,[familyInfo.family_id]);
			}
		}
	}
}