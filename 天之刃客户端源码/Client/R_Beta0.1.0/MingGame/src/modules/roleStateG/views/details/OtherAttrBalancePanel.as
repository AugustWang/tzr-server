package modules.roleStateG.views.details {
	import com.common.GlobalObjectManager;
	import com.components.BasePanel;
	import com.globals.GameConfig;
	import com.ming.ui.controls.core.UIComponent;
	import com.utils.ComponentUtil;
	import com.utils.HtmlUtil;
	
	import flash.display.Bitmap;
	import flash.text.TextField;
	
	import proto.common.p_role;
	import proto.line.m_role2_getroleattr_toc;
	import proto.line.p_other_role_info;

	public class OtherAttrBalancePanel extends BasePanel {
		private var attrBg:UIComponent;
		private var shengmingTF:TextField;
		private var faliTF:TextField;
		private var wugongTF:TextField;
		private var wufangTF:TextField;
		private var fagongTF:TextField;
		private var fafangTF:TextField;
		private var zhongjiTF:TextField;
		private var sanbiTF:TextField;
		private var mingzhongTF:TextField;
		private var pojiaTF:TextField;
		private var xingyunzhiTF:TextField;
		private var liliangTF:TextField;
		private var zhiliTF:TextField;
		private var shengfaTF:TextField;
		private var dingliTF:TextField;
		private var tizhiTF:TextField;

		public function OtherAttrBalancePanel() {
			super();
			//showCloseButton=false;
			initView();
		}

		private function initView():void {
			attrBg=ComponentUtil.createUIComponent(8, -10, 175, 350);
			Style.setBorderSkin(attrBg);
			addChild(attrBg);

			shengmingTF=ComponentUtil.createTextField("", 8, 12, null, 150, 25, attrBg);
			faliTF=ComponentUtil.createTextField("", 8, 28, null, 150, 25, attrBg);

			var attrTiao1:Bitmap=Style.getBitmap(GameConfig.T1_VIEWUI, "hightLightLine");
			attrTiao1.width=162;
			attrTiao1.y=56;
			attrTiao1.x=5;
			attrBg.addChild(attrTiao1);

			var startY:int=66;
			var linding:int=16;

			wugongTF=ComponentUtil.createTextField("", 8, startY, null, 150, 20, attrBg);
			wufangTF=ComponentUtil.createTextField("", 8, startY + linding, null, 150, 20, attrBg);
			fagongTF=ComponentUtil.createTextField("", 8, startY + linding * 2, null, 150, 20, attrBg);
			fafangTF=ComponentUtil.createTextField("", 8, startY + linding * 3, null, 150, 20, attrBg);

			var attrTiao3:Bitmap=Style.getBitmap(GameConfig.T1_VIEWUI, "hightLightLine");
			attrTiao3.width=162;
			attrTiao3.y=startY + linding * 4 + 10;
			attrTiao3.x=5;
			attrBg.addChild(attrTiao3);

			startY=startY + linding * 5 + 5;

			zhongjiTF=ComponentUtil.createTextField("", 8, startY, null, 150, 25, attrBg);
			sanbiTF=ComponentUtil.createTextField("", 8, startY + linding, null, 150, 25, attrBg);
			mingzhongTF=ComponentUtil.createTextField("", 8, startY + linding * 2, null, 150, 25, attrBg);
			pojiaTF=ComponentUtil.createTextField("", 8, startY + linding * 3, null, 150, 25, attrBg);
			xingyunzhiTF=ComponentUtil.createTextField("", 8, startY + linding * 4, null, 150, 25, attrBg);

			var attrTiao2:Bitmap=Style.getBitmap(GameConfig.T1_VIEWUI, "hightLightLine");
			attrTiao2.width=162;
			attrTiao2.y=243;
			attrTiao2.x=5;
			attrBg.addChild(attrTiao2);

			startY=255;

			liliangTF=ComponentUtil.createTextField("", 8, startY, null, 150, 25, attrBg);
			zhiliTF=ComponentUtil.createTextField("", 8, startY + linding, null, 150, 25, attrBg);
			shengfaTF=ComponentUtil.createTextField("", 8, startY + linding * 2, null, 150, 25, attrBg);
			dingliTF=ComponentUtil.createTextField("", 8, startY + linding * 3, null, 150, 25, attrBg);
			tizhiTF=ComponentUtil.createTextField("", 8, startY + linding * 4, null, 150, 25, attrBg);
		}

		public function update(vo:m_role2_getroleattr_toc):void {
			var roleVO:p_role=GlobalObjectManager.getInstance().user;
			var otherVO:p_other_role_info=vo.role_info;
			title=roleVO.base.role_name;

			var minPhyAttack:String=balanceAttr(roleVO.base.min_phy_attack, otherVO.min_phy_attack);
			var maxPhyAttack:String=balanceAttr(roleVO.base.max_phy_attack, otherVO.max_phy_attack);
			if (minPhyAttack != "" || maxPhyAttack != "") {
				wugongTF.htmlText=HtmlUtil.wapper("物攻：", roleVO.base.min_phy_attack + " - " + roleVO.base.max_phy_attack + minPhyAttack != "" ? minPhyAttack : "0" + "-" + maxPhyAttack != "" ? maxPhyAttack : "0", "#FFFF66", "#E992F1");
			} else {
				wugongTF.htmlText=HtmlUtil.wapper("物攻：", roleVO.base.min_phy_attack + " - " + roleVO.base.max_phy_attack, "#FFFF66", "#E992F1");
			}
			wufangTF.htmlText=HtmlUtil.wapper("物防：", roleVO.base.phy_defence + balanceAttr(roleVO.base.phy_defence, otherVO.phy_defence), "#FFFF66", "#E992F1");
			var minMagicAttack:String=balanceAttr(roleVO.base.min_magic_attack, otherVO.min_magic_attack);
			var maxMagicAttack:String=balanceAttr(roleVO.base.max_magic_attack, otherVO.max_magic_attack);
			if (minMagicAttack != "" || maxMagicAttack != "") {
				fagongTF.htmlText=HtmlUtil.wapper("法攻：", roleVO.base.min_magic_attack + " - " + roleVO.base.max_magic_attack + minMagicAttack != "" ? minMagicAttack : "0" + "-" + maxMagicAttack != "" ? maxMagicAttack : "0", "#FFFF66", "#E992F1");
			} else {
				fagongTF.htmlText=HtmlUtil.wapper("法攻：", roleVO.base.min_magic_attack + " - " + roleVO.base.max_magic_attack, "#FFFF66", "#E992F1");
			}
			fafangTF.htmlText=HtmlUtil.wapper("法防：", roleVO.base.magic_defence + balanceAttr(roleVO.base.magic_defence, otherVO.magic_defence), "#FFFF66", "#E992F1");


			shengmingTF.htmlText=HtmlUtil.wapper("生命上限：", roleVO.base.max_hp + balanceAttr(roleVO.base.max_hp, otherVO.max_hp), "#63C6D0", "#E992F1");
			faliTF.htmlText=HtmlUtil.wapper("法力上限：", roleVO.base.max_mp + balanceAttr(roleVO.base.max_mp, otherVO.max_mp), "#63C6D0", "#E992F1");

			zhongjiTF.htmlText=HtmlUtil.wapper("重击：", roleVO.base.double_attack / 100 + "%" + balance((roleVO.base.double_attack - otherVO.double_attack) / 100, "%"), "#63C6D0", "#E992F1");
			sanbiTF.htmlText=HtmlUtil.wapper("闪避：", roleVO.base.miss / 100 + "%" + balance((roleVO.base.miss - otherVO.miss) / 100, "%"), "#63C6D0", "#E992F1");
			mingzhongTF.htmlText=HtmlUtil.wapper("命中：", roleVO.base.hit_rate + balance((roleVO.base.hit_rate - otherVO.hit_rate) ), "#63C6D0", "#E992F1");
			pojiaTF.htmlText=HtmlUtil.wapper("破甲：", roleVO.base.no_defence + balance((roleVO.base.no_defence - otherVO.no_defence) ), "#63C6D0", "#E992F1");
			xingyunzhiTF.htmlText=HtmlUtil.wapper("幸运值：", roleVO.base.luck + balance((roleVO.base.luck - otherVO.luck) ), "#63C6D0", "#E992F1");

			liliangTF.htmlText=HtmlUtil.wapper("力量：", roleVO.base.str + balanceAttr(roleVO.base.str, otherVO.str), "#1FC54C", "#E992F1");
			zhiliTF.htmlText=HtmlUtil.wapper("智力：", roleVO.base.int2 + balanceAttr(roleVO.base.int2, otherVO.int2), "#1FC54C", "#E992F1");
			shengfaTF.htmlText=HtmlUtil.wapper("身法：", roleVO.base.dex + balanceAttr(roleVO.base.dex, otherVO.dex), "#1FC54C", "#E992F1");
			dingliTF.htmlText=HtmlUtil.wapper("定力：", roleVO.base.men + balanceAttr(roleVO.base.men, otherVO.men), "#1FC54C", "#E992F1");
			tizhiTF.htmlText=HtmlUtil.wapper("体质：", roleVO.base.con + balanceAttr(roleVO.base.con, otherVO.con), "#1FC54C", "#E992F1");
		}

		private function balanceAttr(valueA:int, valueB:int):String {
			var key:int=valueA - valueB;
			if (key > 0) {
				return HtmlUtil.font(" ↑" + key, "#00ff00");
			} else if (key < 0) {
				return HtmlUtil.font(" ↓" + Math.abs(key), "#ff0000");
			}
			return "";
		}

		private function balance(value:Number, key:String=""):String {
			if (value > 0) {
				return HtmlUtil.font(" ↑" + value + key, "#00ff00");
			} else if (value < 0) {
				return HtmlUtil.font(" ↓" + Math.abs(value) + key, "#ff0000");
			}
			return "";
		}
		
		override public function closeWindow(save:Boolean=false):void{
			this.parent.removeChild(this);
		}
	}
}