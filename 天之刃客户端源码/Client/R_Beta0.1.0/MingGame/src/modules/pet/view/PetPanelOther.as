package modules.pet.view {
	import com.common.GameColors;
	import com.components.BasePanel;
	import com.globals.GameConfig;
	import com.ming.ui.containers.List;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.ComboBox;
	import com.ming.ui.controls.Image;
	import com.ming.ui.controls.Text;
	import com.ming.ui.controls.TextInput;
	import com.ming.ui.controls.core.UIComponent;
	import com.ming.ui.skins.Skin;
	import com.scene.sceneUnit.baseUnit.things.avatar.Avatar;
	import com.scene.sceneUnit.baseUnit.things.avatar.AvatarConstant;
	import com.utils.ComponentUtil;
	import com.utils.HtmlUtil;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import modules.pet.PetDataManager;
	import modules.pet.PetSkillVO;
	import modules.pet.config.PetConfig;
	import modules.skill.SkillDataManager;
	import modules.skill.vo.SkillVO;
	
	import mx.utils.NameUtil;
	
	import org.osmf.net.StreamingURLResource;
	
	import proto.common.p_pet;
	import proto.common.p_pet_attr_assign;
	import proto.common.p_pet_skill;
	import proto.common.p_skin;
	import proto.line.m_pet_attr_assign_tos;
	import proto.line.m_pet_info_toc;

	public class PetPanelOther extends BasePanel {
		public static const CALL_BACK_EVENT:String="CALL_BACK_EVENT";
		public static const SUMMON_EVENT:String="SUMMON_EVENT";
		public static const THROW_EVENT:String="THROW_EVENT";
		public static const PET_STORE_EVENT:String="PET_STORE_EVENT";
		public static const PROPERTY_EVENT:String="PROPERTY_EVENT";
		private var pvo:p_pet;
		private var colors:Array=["白", "绿", "蓝", "紫", "橙", "金"];
		private var ziZhiPro:Array=["", "+50", "+100", "+150", "+250", "+350", "+450", "+600", "+750", "+900", "+1050", "+1200", "+1400", "+1600", "+1800", "+2000"];
		private var avatar:Avatar;
		private var skills:Array=[];
		private var skin:p_skin;
		private var takeLevel:TextField;
		private var sex:TextField;
		private var color:TextField;
		private var bang:TextField;
		private var typeName:TextField;
		private var attackType:TextField;
		private var petName:TextField;
		private var petLevel:TextField;
		private var petID:TextField;
		private var petCouple:TextField;
		private var petHp:TextField;
		private var petLife:TextField;
		private var petExp:TextField;
		private var masterName:TextField;
		private var wuxing:TextField;
		private var liliang:TextField;
		private var zhili:TextField;
		private var tizhi:TextField;
		private var jingshen:TextField;
		private var minjie:TextField;
		private var remainPoint:TextField;
		private var outAttackZZ:TextField;
		private var inAttackZZ:TextField;
		private var outDefZZ:TextField;
		private var inDefZZ:TextField;
		private var zhongjiZZ:TextField;
		private var shengmingZZ:TextField;
		private var outAttack:TextField;
		private var inAttack:TextField;
		private var outDef:TextField;
		private var inDef:TextField;
		private var zhongji:TextField;

		public function PetPanelOther() {
			super("PetPanel");
		}

		override protected function init():void {
			width=442;
			height=475;
			
			addContentBG(5,5);
			
			var part1:UIComponent = ComponentUtil.createUIComponent(8,7,295,164);
			Style.setBorderSkin(part1);
			var img:Image = new Image();
			img.width = 273;
			img.height = 152;
			img.mouseChildren = img.mouseEnabled = false;
			img.source = GameConfig.getBackImage("petInfoBg");
			img.x = part1.width - img.width >> 1;
			img.y = part1.height - img.height >> 1;
			part1.addChild(img);
			
			var avatarBg:Image = new Image();
			avatarBg.width = 213;
			avatarBg.height = 153;
			avatarBg.x = part1.width - avatarBg.width >> 1;
			avatarBg.y = part1.height - avatarBg.height >> 1;
			avatarBg.mouseChildren = avatarBg.mouseEnabled = false;
			avatarBg.source = GameConfig.getBackImage("petAvatarBg");
			part1.addChild(avatarBg);
			
			avatar=new Avatar;
			avatar.x=140;
			avatar.y=136;
			part1.addChild(avatar);
			
			var tf:TextFormat=new TextFormat(null, null, 0xcccccc, null);
			var tfb:TextFormat=new TextFormat(null, null, 0xAFE0EE, null);
			takeLevel=ComponentUtil.createTextField("等级要求：", 4, 2, tf, 160, 22, part1);
			typeName=ComponentUtil.createTextField("类型：", 4, 20, tfb, 160, 22, part1);
			bang=ComponentUtil.createTextField("绑定", 4, 38, tf, 160, 22, part1);

			color=ComponentUtil.createTextField("颜色：", 220, 2, tf, 160, 22, part1);
			sex=ComponentUtil.createTextField("性别：", 220, 20, tf, 160, 22, part1);
			attackType=ComponentUtil.createTextField("内外攻：", 220, 38, tf, 160, 22, part1);

			//////////////////////
			var part2:Sprite = new Sprite();
			part2.x=10;
			part2.y=170;
			var titleBar:Bitmap = Style.getBitmap("titleBar", GameConfig.T1_VIEWUI);
			titleBar.width = 292;
			part2.addChild(titleBar);
			
			ComponentUtil.createTextField("宠物技能：", 4, 2, tf, 160, 22, part2);
			for (var i:int=0; i < 16; i++) {
				var psi:PetSkillLearnItem=new PetSkillLearnItem;
				psi.x=2 + (i % 8) * 36;
				psi.y=26 + int(i / 8) * 36;
				skills.push(psi);
				part2.addChild(psi);
			}
			////////////////////////////////
			var part3:UIComponent = ComponentUtil.createUIComponent(10,274,295,154);
			Style.setBorderSkin(part3);
			petName=ComponentUtil.createTextField("宠物名称：", 4, 2, tf, 160, 22, part3);
			petLevel=ComponentUtil.createTextField("宠物等级：", 4, 20, tf, 160, 22, part3);
			masterName=ComponentUtil.createTextField("主人名称：", 4, 38, tf, 160, 22, part3);
			petID=ComponentUtil.createTextField("宠物ID：", 4, 56, tf, 160, 22, part3);
			petCouple=ComponentUtil.createTextField("宠物融合度：", 4, 74, tf, 160, 22, part3);
			petHp=ComponentUtil.createTextField("生命值：", 4, 92, tf, 160, 22, part3);
			petLife=ComponentUtil.createTextField("寿命：", 4, 110, tf, 160, 22, part3);
			petExp=ComponentUtil.createTextField("经验：", 4, 128, tf, 160, 22, part3);
			////////////////////
			var part5:UIComponent = ComponentUtil.createUIComponent(310,7,124,168);
			Style.setBorderSkin(part5);
			var nameBar:Bitmap = Style.getBitmap("titleBar", GameConfig.T1_VIEWUI);
			nameBar.width = 124;
			part5.addChild(nameBar);
			ComponentUtil.createTextField("属性", 4, 2, tf, 160, 22, part5);
			wuxing=ComponentUtil.createTextField("悟性：", 4, 22, tf, 160, 22, part5);
			liliang=ComponentUtil.createTextField("力量：", 4, 42, tf, 160, 22, part5);
			zhili=ComponentUtil.createTextField("智力：", 4, 62, tf, 160, 22, part5);
			minjie=ComponentUtil.createTextField("敏捷：", 4, 82, tf, 160, 22, part5);
			jingshen=ComponentUtil.createTextField("精神：", 4, 102, tf, 160, 22, part5);
			tizhi=ComponentUtil.createTextField("体质：", 4, 122, tf, 160, 22, part5);
			remainPoint=ComponentUtil.createTextField("潜能：", 4, 142, tf, 160, 22, part5);
			/////////////////////////////
			var part6:UIComponent = ComponentUtil.createUIComponent(310,174,124,128);
			Style.setBorderSkin(part6);
			outAttackZZ=ComponentUtil.createTextField("外攻资质：", 4, 2, tf, 160, 22, part6);
			inAttackZZ=ComponentUtil.createTextField("内攻资质：", 4, 22, tf, 160, 22, part6);
			outDefZZ=ComponentUtil.createTextField("外防资质：", 4, 42, tf, 160, 22, part6);
			inDefZZ=ComponentUtil.createTextField("内防资质：", 4, 62, tf, 160, 22, part6);
			zhongjiZZ=ComponentUtil.createTextField("重击资质：", 4, 82, tf, 160, 22, part6);
			shengmingZZ=ComponentUtil.createTextField("生命资质：", 4, 102, tf, 160, 22, part6);
			///////////////////
			var part7:UIComponent = ComponentUtil.createUIComponent(310,302,124,124);
			Style.setBorderSkin(part7);
			outAttack=ComponentUtil.createTextField("外攻攻击：", 4, 2, tf, 160, 22, part7);
			inAttack=ComponentUtil.createTextField("内攻攻击：", 4, 22, tf, 160, 22, part7);
			outDef=ComponentUtil.createTextField("外攻防御：", 4, 42, tf, 160, 22, part7);
			inDef=ComponentUtil.createTextField("内攻防御：", 4, 62, tf, 160, 22, part7);
			zhongji=ComponentUtil.createTextField("重击：", 4, 82, tf, 160, 22, part7);
			this.addChild(part1);
			this.addChild(part2);
			this.addChild(part3);
			this.addChild(part5);
			this.addChild(part6);
			this.addChild(part7);
		}

		public function update(vo:p_pet):void {
			if (this.pvo == null || this.pvo.type_id != vo.type_id) {
				title=vo.role_name+"的宠物";
				skin=new p_skin;
				skin.skinid=PetConfig.getPetSkin(vo.type_id);
				if (avatar.skinData == null) {
					avatar.initSkin(skin);
				} else {
					avatar._bodyLayer.y=0;
					avatar.updataSkin(skin);
				}
				var skinid:int=PetConfig.getPetSkin(vo.type_id);
				avatar.play(AvatarConstant.ACTION_STAND, 6, PetDataManager.getStandSpeed(skinid));
				avatar.visible=true;
				if (skinid == 10086 || skinid == 10089 || skinid == 10090 || skinid == 10092 || skinid == 10108) {
					skinid == 10108 ? avatar._bodyLayer.y=66 : avatar._bodyLayer.y=40;
				}
			}
			this.pvo=vo;
			for (var i:int=0; i < 12; i++) {
				skills[i].data=null;
			}
			for (i=0; i < vo.skills.length; i++) {
				var ps:p_pet_skill=vo.skills[i];
				var skill:SkillVO=SkillDataManager.getSkill(ps.skill_id);
				var petSkill:PetSkillVO=new PetSkillVO(skill, ps.skill_type);
				skills[i].data=petSkill;
			}
			takeLevel.htmlText=coloring("等级要求：", PetConfig.getPetTakeLevel(pvo.type_id));
			sex.htmlText=coloring2("性别：", vo.sex == 1 ? "雄" : "雌");
			color.htmlText=HtmlUtil.font("颜色：", "#AFE0EE") + HtmlUtil.font2(colors[vo.color - 1], GameColors.COLOR_VALUES[vo.color]);
			bang.text=vo.bind == true ? "绑定" : "不绑定";
			typeName.htmlText="类型：<font color='#FFF799'>" + PetConfig.getPetMsg(pvo.type_id) + "</font>";
			attackType.htmlText=HtmlUtil.font(vo.attack_type == 1 ? "外攻" : "内攻", "#fff799");
			petName.htmlText=coloring2("宠物名称：", vo.pet_name);
			petLevel.htmlText=coloring("宠物等级：", vo.level);
			masterName.htmlText=coloring2("主人名称：", vo.role_name);
			petID.htmlText=coloring("宠物ID：", vo.pet_id);
			petCouple.htmlText=coloring("宠物融合度：", vo.mate_id);
			var pet_max_hp:int=vo.max_hp - vo.max_hp_grow_add;
			petHp.htmlText=coloring2("生命值：", vo.hp + "/" + pet_max_hp);
			petLife.htmlText=coloring("寿命：", vo.life);
			petExp.htmlText=coloring("经验：", vo.exp);
			wuxing.htmlText=coloring("悟性：", vo.understanding);
			liliang.htmlText=coloring("力量：", vo.str); //力量
			zhili.htmlText=coloring("智力：", vo.int2);
			tizhi.htmlText=coloring("体质：", vo.con);
			jingshen.htmlText=coloring("精神：", vo.men);
			minjie.htmlText=coloring("敏捷：", vo.dex);
			remainPoint.htmlText=coloring("潜能：", vo.remain_attr_points);
			var proZZ:String=ziZhiPro[vo.understanding];
			var maxZZ:int=PetConfig.getMaxAptitude(pvo.type_id) - 200;
			var ziZhiColor:uint=vo.phy_attack_aptitude >= maxZZ ? 0x00ff00 : 0xECE8BB;
			outAttackZZ.htmlText=coloring("外攻资质：", vo.phy_attack_aptitude, ziZhiColor) + HtmlUtil.font(proZZ, "#00ff00");
			ziZhiColor=vo.magic_attack_aptitude >= maxZZ ? 0x00ff00 : 0xECE8BB;
			inAttackZZ.htmlText=coloring("内攻资质：", vo.magic_attack_aptitude, ziZhiColor) + HtmlUtil.font(proZZ, "#00ff00");
			ziZhiColor=vo.phy_defence_aptitude >= maxZZ ? 0x00ff00 : 0xECE8BB;
			outDefZZ.htmlText=coloring("外防资质：", vo.phy_defence_aptitude, ziZhiColor) + HtmlUtil.font(proZZ, "#00ff00");
			ziZhiColor=vo.magic_defence_aptitude >= maxZZ ? 0x00ff00 : 0xECE8BB;
			inDefZZ.htmlText=coloring("内防资质：", vo.magic_defence_aptitude, ziZhiColor) + HtmlUtil.font(proZZ, "#00ff00");
			ziZhiColor=vo.max_hp_aptitude >= maxZZ ? 0x00ff00 : 0xECE8BB;
			shengmingZZ.htmlText=coloring("生命资质：", vo.max_hp_aptitude, ziZhiColor) + HtmlUtil.font(proZZ, "#00ff00");
			ziZhiColor=vo.double_attack_aptitude >= maxZZ ? 0x00ff00 : 0xECE8BB;
			zhongjiZZ.htmlText=coloring("重击资质：", vo.double_attack_aptitude, ziZhiColor) + HtmlUtil.font(proZZ, "#00ff00");
			outAttack.htmlText=coloring("外攻攻击：", vo.phy_attack - vo.phy_attack_grow_add);
			inAttack.htmlText=coloring("内攻攻击：", vo.magic_attack - vo.magic_attack_grow_add);
			outDef.htmlText=coloring("外攻防御：", vo.phy_defence - vo.phy_defence_grow_add);
			inDef.htmlText=coloring("内攻防御：", vo.magic_defence - vo.magic_defence_grow_add);
			zhongji.htmlText=coloring("重击：", Math.floor(vo.double_attack / 100)) + "%"
		}


		//制造颜色
		private function coloring(s1:String, s2:int, color2:uint=0xECE8BB):String {
			var str:String=HtmlUtil.font(s1, "#AFE0EE") + HtmlUtil.font2(s2 + "", color2);
			return str;
		}

		//制造颜色
		private function coloring2(s1:String, s2:String):String {
			var str:String=HtmlUtil.font(s1, "#AFE0EE") + HtmlUtil.font(s2, "#ECE8BB");
			return str;
		}

	}
}