package modules.pet.newView {
	import com.components.BasePanel;
	import com.globals.GameConfig;
	import com.managers.Dispatch;
	import com.managers.WindowManager;
	import com.ming.ui.controls.ProgressBar;
	import com.ming.ui.controls.core.UIComponent;
	import com.ming.ui.layout.LayoutUtil;
	import com.utils.ComponentUtil;
	import com.utils.HtmlUtil;
	
	import flash.display.Bitmap;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.TextEvent;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import modules.ModuleCommand;
	import modules.pet.PetModule;
	import modules.pet.PetSkillVO;
	import modules.pet.config.PetConfig;
	import modules.pet.newView.items.PetSkillLearnItem;
	import modules.skill.SkillDataManager;
	import modules.skill.vo.SkillVO;
	
	import proto.common.p_pet;
	import proto.common.p_pet_skill;

	public class PetAptitudePanel extends BasePanel {
		private var ziZhiPro:Array=["", "+50", "+100", "+150", "+250", "+350", "+450", "+600", "+750", "+900", "+1050", "+1200", "+1400", "+1600", "+1800", "+2000"];
		private var wuxingTF:TextField;
		private var waigongBar:ProgressBar;
		private var neigongBar:ProgressBar;
		private var waifangBar:ProgressBar;
		private var neifangBar:ProgressBar;
		private var zhongjiBar:ProgressBar;
		private var shengmingBar:ProgressBar;

		private var skillContainer:Sprite;
		private var superSkillContainer:Sprite;
		private var skillItems:Array = [];
		private var pet:p_pet;
		public function PetAptitudePanel() {
			initView();
		}

		private function initView():void {
			width=246;
			height=448;
			
			allowDrag = false;
			addImageTitle("title_petInfo");
			addContentBG(6, 8, 18);

			var bg:UIComponent=ComponentUtil.createUIComponent(17, 28, 212, 366);
			Style.setBorderSkin(bg);
			addChild(bg);

			var headBg:Bitmap=Style.getBitmap(GameConfig.T1_VIEWUI, "titleBar");
			headBg.width=bg.width - 1;
			headBg.height=19;
			bg.addChild(headBg);
			var titleFormat:TextFormat=new TextFormat("Tahoma", 12, 0xFFFFFF);
			titleFormat.align=TextFormatAlign.CENTER;
			ComponentUtil.createTextField("宠物资质", 0, 2, titleFormat, headBg.width, 20, bg).filters=Style.textBlackFilter;;

			var startX:int=10;
			var startY:int=20;
			var landing:int=18;

			var nameTextFormat:TextFormat=new TextFormat("Tahoma", 12, 0xfffd4b);
			wuxingTF=ComponentUtil.createTextField("悟    性：", startX, startY, nameTextFormat, 70, 25, bg);
			wuxingTF.filters=Style.textBlackFilter;
			var tiwuLink:TextField=ComponentUtil.createTextField("", wuxingTF.x + 158, wuxingTF.y, null, 100, 25, bg);
			tiwuLink.addEventListener(TextEvent.LINK, onTiwuLink);
			tiwuLink.mouseEnabled = true;
			tiwuLink.htmlText=HtmlUtil.font(HtmlUtil.link("提悟","",true), "#00ff00");

			ComponentUtil.createTextField("外功资质：", startX, startY + landing, nameTextFormat, 70, 25, bg).filters=Style.textBlackFilter;
			ComponentUtil.createTextField("内功资质：", startX, startY + landing * 2, nameTextFormat, 70, 25, bg).filters=Style.textBlackFilter;
			ComponentUtil.createTextField("外防资质：", startX, startY + landing * 3, nameTextFormat, 70, 25, bg).filters=Style.textBlackFilter;
			ComponentUtil.createTextField("内防资质：", startX, startY + landing * 4, nameTextFormat, 70, 25, bg).filters=Style.textBlackFilter;
			ComponentUtil.createTextField("重击资质：", startX, startY + landing * 5, nameTextFormat, 70, 25, bg).filters=Style.textBlackFilter;
			ComponentUtil.createTextField("生命资质：", startX, startY + landing * 6, nameTextFormat, 70, 25, bg).filters=Style.textBlackFilter;

			startX+=62;
			waigongBar=createBar(startX, startY + landing + 3, 130, 14, bg);
			neigongBar=createBar(startX, startY + landing * 2 + 3, 130, 14, bg);
			waifangBar=createBar(startX, startY + landing * 3 + 3, 130, 14, bg);
			neifangBar=createBar(startX, startY + landing * 4 + 3, 130, 14, bg);
			zhongjiBar=createBar(startX, startY + landing * 5 + 3, 130, 14, bg);
			shengmingBar=createBar(startX, startY + landing * 6 + 3, 130, 12, bg);

			var headBg2:Bitmap=Style.getBitmap(GameConfig.T1_VIEWUI, "titleBar");
			headBg2.width=bg.width - 1;
			headBg2.height=19;
			headBg2.y=150;
			bg.addChild(headBg2);
			ComponentUtil.createTextField("技能", 0, headBg2.y + 2, titleFormat, headBg.width, 20, bg).filters=Style.textBlackFilter;

			skillContainer = new Sprite();
			skillContainer.x = 12;
			skillContainer.y = headBg2.y + 24;
			bg.addChild(skillContainer);
			
			var headBg3:Bitmap=Style.getBitmap(GameConfig.T1_VIEWUI, "titleBar");
			headBg3.width=bg.width - 1;
			headBg3.height=19;
			headBg3.y=300;
			bg.addChild(headBg3);
			ComponentUtil.createTextField("神技", 0, headBg3.y + 2, titleFormat, headBg.width, 20, bg).filters=Style.textBlackFilter;
			
			superSkillContainer = new Sprite();
			superSkillContainer.x = 12;
			superSkillContainer.y = headBg3.y + 24;
			bg.addChild(superSkillContainer);
			
			Dispatch.register(ModuleCommand.PET_SKILLS_UPDATE,onPetSkillUpdate);
		}

		private function createBar(x:int, y:int, w:int, h:int, $parent:DisplayObjectContainer):ProgressBar {
			var expBar:ProgressBar=new ProgressBar();
			expBar.bgSkin=Style.getSkin("expBarBg", GameConfig.T1_UI, new Rectangle(5, 5, 108, 4));
			expBar.bar=Style.getBitmap(GameConfig.T1_UI, "expBar");
			expBar.padding=3;
			expBar.x=x;
			expBar.y=y;
			expBar.width=w;
			expBar.height=h;
			expBar.value=0;
			expBar.htmlText="0%";
			$parent.addChild(expBar);
			return expBar
		}

		private function onTiwuLink(event:TextEvent):void {
			PetModule.getInstance().mediator.openPanel(3,WindowManager.UNREMOVE);
		}

		public function update(vo:p_pet):void {
			if(!vo){
				return;
			}
			this.pet = vo;
			wuxingTF.text =  "悟    性："+vo.understanding;
			
			var proZZ:String=ziZhiPro[vo.understanding];
			var maxZZ:int=PetConfig.getMaxAptitude(vo.type_id);
			
			var ziZhiColor:String=vo.phy_attack_aptitude >= maxZZ ? "#00ff00" : "#ECE8BB";
			waigongBar.value = vo.phy_attack_aptitude/maxZZ;
			waigongBar.htmlText=HtmlUtil.font(String(vo.phy_attack_aptitude),ziZhiColor) + HtmlUtil.font(proZZ, "#00ff00");
			ziZhiColor=vo.magic_attack_aptitude >= maxZZ ? "00ff00" : "ECE8BB";
			neigongBar.value = vo.magic_attack_aptitude/maxZZ;
			neigongBar.htmlText=HtmlUtil.font(String(vo.magic_attack_aptitude),ziZhiColor) + HtmlUtil.font(proZZ, "#00ff00");
			ziZhiColor=vo.phy_defence_aptitude >= maxZZ ? "00ff00" : "ECE8BB";
			waifangBar.value = vo.phy_defence_aptitude/maxZZ;
			waifangBar.htmlText=HtmlUtil.font(String(vo.phy_defence_aptitude),ziZhiColor) + HtmlUtil.font(proZZ, "#00ff00");
			ziZhiColor=vo.magic_defence_aptitude >= maxZZ ? "00ff00" : "ECE8BB";
			neifangBar.value = vo.magic_defence_aptitude/maxZZ;
			neifangBar.htmlText=HtmlUtil.font(String(vo.magic_defence_aptitude),ziZhiColor) + HtmlUtil.font(proZZ, "#00ff00");
			ziZhiColor=vo.max_hp_aptitude >= maxZZ ? "00ff00" : "ECE8BB";
			shengmingBar.value = vo.max_hp_aptitude/maxZZ;
			shengmingBar.htmlText=HtmlUtil.font(String(vo.max_hp_aptitude),ziZhiColor) + HtmlUtil.font(proZZ, "#00ff00");
			ziZhiColor=vo.double_attack_aptitude >= maxZZ ? "00ff00" : "ECE8BB";
			zhongjiBar.value = vo.double_attack_aptitude/maxZZ;
			zhongjiBar.htmlText=HtmlUtil.font(String(vo.double_attack_aptitude),ziZhiColor) + HtmlUtil.font(proZZ, "#00ff00");
			updateSkills();
		}

		private function onPetSkillUpdate(petVO:p_pet):void{
			if(pet && petVO.pet_id == pet.pet_id){
				updateSkills();
			}
		}
		
		private function updateSkills():void{
			while(skillContainer.numChildren > 0){
				skillItems.push(skillContainer.removeChildAt(0));
			}
			while(superSkillContainer.numChildren > 0){
				skillItems.push(superSkillContainer.removeChildAt(0));
			}
			for (var i:int=0; i < pet.skills.length; i++) {
				var skillItem:PetSkillLearnItem = skillItems.shift();
				if(skillItem == null){
					skillItem = new PetSkillLearnItem();
					skillItem.enabled = false;
				}
				var ps:p_pet_skill=pet.skills[i];
				var skill:SkillVO=SkillDataManager.getSkill(ps.skill_id);
				var petSkill:PetSkillVO=new PetSkillVO(skill, ps.skill_type);
				skillItem.data=petSkill;
				skillContainer.addChild(skillItem);
			}
			LayoutUtil.layoutGrid(skillContainer,4,8,0);
		}
		
		
		override public function closeWindow(save:Boolean=false):void {
			this.parent.removeChild(this);
		}
	}
}