package modules.pet.newView.items {
	import com.common.FilterCommon;
	import com.components.alert.Alert;
	import com.globals.GameConfig;
	import com.ming.core.IDataRenderer;
	import com.ming.managers.ToolTipManager;
	import com.ming.ui.controls.Image;
	import com.net.connection.Connection;
	import com.utils.ComponentUtil;
	import com.utils.HtmlUtil;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	
	import modules.broadcast.views.Tips;
	import modules.pet.PetDataManager;
	import modules.pet.PetSkillVO;
	import modules.skill.vo.SkillLevelVO;
	
	import proto.line.m_pet_add_skill_grid_tos;

	public class PetSkillLearnItem extends Sprite implements IDataRenderer{
		private static const openSkillMoney:Array=[0, 0, 0, 0, 0, 5, 9, 14, 20, 29, 39, 49, 59];
		private var vo:PetSkillVO;
		private var closeBG:Bitmap;
		private var skillImage:Image;
		private var openText:TextField;
		public function PetSkillLearnItem() {
			super();
			addChild(Style.getBitmap(GameConfig.T1_VIEWUI,"packItemBg"));
			mouseChildren=false;
			enabled = true;
		}

		private function createImage():void {
			if (skillImage == null) {
				skillImage=new Image();
				skillImage.x=skillImage.y=4;
				skillImage.width=skillImage.height=32;
				addChild(skillImage);
				addEventListener(MouseEvent.ROLL_OVER, showSkillTip);
				addEventListener(MouseEvent.ROLL_OUT, hideTip);
			}
		}
		
		public function set enabled(value:Boolean):void{
			if(value == false){
				removeEventListener(MouseEvent.CLICK, onClick);
			}else{
				addEventListener(MouseEvent.CLICK, onClick);
			}
		}
		
		private function onClick(event:MouseEvent):void{
			if(isClose){
				openSkill();
			}
		}
		
		private var isClose:Boolean = false;
		public function closeSkill(b:Boolean):void {
			if (b) {
				if (closeBG == null) {
					closeBG=Style.getBitmap(GameConfig.T1_VIEWUI,"closeSkill");
					closeBG.x=closeBG.y=3;
				}
				addChild(closeBG);
				addOpenText();
			} else {
				removeOpenText();
				if (closeBG && closeBG.parent) {
					closeBG.parent.removeChild(closeBG);
				}
			}
			isClose = b;
		}

		public function addOpenText():void{
			if(openText == null){
				openText = ComponentUtil.createTextField("",5,8,null,30,20,this);
				openText.htmlText = HtmlUtil.link(HtmlUtil.font("开启","#00ff00"),"",true);
				openText.mouseEnabled = true;
				openText.filters = FilterCommon.FONT_BLACK_FILTERS;
			}
			mouseChildren=true;
			addChild(openText);
			addEventListener(MouseEvent.ROLL_OVER, showOpenSkill);
			addEventListener(MouseEvent.ROLL_OUT, hideOpenSkill);
		}
		
		private function removeOpenText():void{
			mouseChildren=false;
			removeEventListener(MouseEvent.ROLL_OVER, showOpenSkill);
			removeEventListener(MouseEvent.ROLL_OUT, hideOpenSkill);
			if(openText && openText.parent){
				removeChild(openText);
			}
		}
		
		private function showOpenSkill(event:MouseEvent):void{
			ToolTipManager.getInstance().show("开启技能槽",0);
		}
		
		private function hideOpenSkill(event:MouseEvent):void{
			ToolTipManager.getInstance().hide();
		}
		
		
		private function showSkillTip(e:MouseEvent):void {
			if (data != null) {
				var p:Point=new Point(this.x + this.width, this.y);
				p = parent.localToGlobal(p);
				ToolTipManager.getInstance().show(createHtml(), 200, p.x, p.y, "SkillTreeTip");
			}
		}

		private function hideTip(e:MouseEvent):void {
			ToolTipManager.getInstance().hide();
		}

		public function set data(value:Object):void {
			vo=value as PetSkillVO;
			if (value != null) {
				createImage();
				skillImage.source=GameConfig.ROOT_URL + "com/assets/skills/" + vo.skill.sid + ".png";
			} else {
				disposeImage();
			}
		}

		public function get data():Object {
			return vo;
		}

		public function disposeImage():void {
			if (skillImage && contains(skillImage)) {
				removeChild(skillImage);
			}
			skillImage=null;
			vo=null;
			this.removeEventListener(MouseEvent.ROLL_OVER, showSkillTip);
			this.removeEventListener(MouseEvent.ROLL_OUT, hideTip);
		}

		public function createHtml():String {
			var s:String='';
			if (vo != null) {
				var sl:SkillLevelVO=vo.skill.levels[0];
				s=s.concat("<font color='#FFFFFF'size='14'><b>" + vo.skill.name + "</b></font>\n");
				s=s.concat("<font color='#FFFFFF'>冷却时间:" + sl.cooldown * 0.001 + "秒</font>\n");
				s=s.concat("<font color='#f2c802'>" + sl.discription + "</font>");
			}
			return s;
		}
		
		private function openSkill():void {
			if (!PetDataManager.currentPetInfo) {
				Tips.getInstance().addTipsMsg("请先选择要扩展技能栏的宠物");
				return;
			}
			if (PetDataManager.currentPetInfo.max_skill_grid < openSkillMoney.length - 1 && PetDataManager.currentPetInfo.max_skill_grid > 0) {
				Alert.show("扩展技能栏需要" + openSkillMoney[PetDataManager.currentPetInfo.max_skill_grid + 1] + "元宝，确定扩展吗？", "消费提示", yesOpenSkill);
			} else {
				Tips.getInstance().addTipsMsg("技能栏已经达到最大数");
			}
		}
		
		private function yesOpenSkill():void{
			var vo:m_pet_add_skill_grid_tos=new m_pet_add_skill_grid_tos;
			vo.pet_id=PetDataManager.currentPetInfo.pet_id;
			Connection.getInstance().sendMessage(vo);
		}
	}
}