package modules.roleStateG.views.details
{
	import com.common.GameConstant;
	import com.common.GlobalObjectManager;
	import com.events.ParamEvent;
	import com.globals.GameConfig;
	import com.managers.Dispatch;
	import com.ming.ui.controls.ComboBox;
	import com.ming.ui.controls.TextInput;
	import com.ming.ui.controls.core.UIComponent;
	import com.utils.ComponentUtil;
	import com.utils.HtmlUtil;
	
	import flash.display.Bitmap;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TextEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import modules.ModuleCommand;
	import modules.friend.views.part.BottomBtns;
	import modules.roleStateG.RoleStateDateManager;
	
	import proto.common.p_role;
	import proto.common.p_title;
	import proto.line.m_title_get_role_titles_toc;

	public class RoleMyInfoView extends Sprite
	{
		public static const EVENT_DO_LEVEL_UP:String="EVENT_DO_LEVEL_UP";
		public static const EVENT_ADD_PROPERY:String="EVENT_ADD_PROPERY";
		public static const EVENT_CHANGE_TITLE:String="EVENT_CHANGE_TITLE";
		public static const EVENT_OPEN_ADD_ENERGY:String="EVENT_OPEN_ADD_ENERGY";
		private var titleColor:uint=0x70dfe1;
		private var topBg:UIComponent;
		private var guojiInput:TextInput;
		private var jiazuInput:TextInput;
		private var guanzhiInput:TextInput;
		private var dengjiInput:TextInput;
		private var chCombox:ComboBox;
		private var bottomBg:UIComponent;
		private var itf:TextFormat;
		private var shengwangBg:Bitmap;
		private var jingliBg:Bitmap;
		private var zhanggongBg:Bitmap;
		private var PKBg:Bitmap;
		private var meiliBg:Bitmap;
		private var shengwangCHInput:TextInput;
		private var shengwangPointInput:TextInput;
		private var jingliCHInput:TextInput;
		private var jingliPointInput:TextInput;
		private var zhanggongCHInput:TextInput;
		private var zhanggongPointInput:TextInput;
		private var pkCHInput:TextInput;
		private var pkPointInput:TextInput;
		private var meiliCHInput:TextInput;
		private var meiliPointInput:TextInput;
		private var mengpaiInput:TextInput;

		public function RoleMyInfoView()
		{
			super();
			setupUI();
		}

		public function setupUI():void
		{
			topBg=ComponentUtil.createUIComponent(9, 7, 454, 98);
			Style.setBorderSkin(topBg);
			addChild(topBg);

			bottomBg=ComponentUtil.createUIComponent(topBg.x, topBg.y + topBg.height + 3, 454, 250);
			Style.setBorderSkin(bottomBg);
			addChild(bottomBg);

			var ttf:TextFormat=new TextFormat("Tahoma", 12, 0x70dfe1);
			itf=new TextFormat("Tahoma", 12, 0xfffd4b);
			var guojiTF:TextField=ComponentUtil.createTextField("国籍：", 12, 14, ttf, 45, 25, topBg);
			guojiInput=createTextInput(guojiTF.x + 42, guojiTF.y - 2, 138, 24, topBg);
			var jiazuTF:TextField=ComponentUtil.createTextField("门派：", 12, 42, ttf, 45, 25, topBg);
			jiazuInput=createTextInput(jiazuTF.x + 42, jiazuTF.y - 2, 138, 24, topBg);
			var guanzhiTF:TextField=ComponentUtil.createTextField("官职：", 12, 70, ttf, 45, 25, topBg);
			guanzhiInput=createTextInput(guanzhiTF.x + 42, guanzhiTF.y - 2, 138, 24, topBg);
			var chenghaoTF:TextField=ComponentUtil.createTextField("称号：", 240, 14, ttf, 45, 25, topBg);
			chCombox=new ComboBox();
			chCombox.labelField="name";
			chCombox.width=138;
			chCombox.height=24;
			chCombox.x=chenghaoTF.x + 72;
			chCombox.y=chenghaoTF.y + 6;
			chCombox.paddingLeft=8;
			chCombox.maxListHeight=200;
			chCombox.addEventListener(Event.CHANGE, onChangeName);
			addChild(chCombox);
			var dengjiTF:TextField=ComponentUtil.createTextField("等级排名：", 240, 42, ttf, 100, 25, topBg);
			dengjiInput=createTextInput(dengjiTF.x + 63, dengjiTF.y - 2, 138, 24, topBg);

			var tiao:Bitmap=Style.getBitmap(GameConfig.T1_VIEWUI, "hightLightLine");
			tiao.width=80;
			tiao.x=226;
			tiao.y=15;
			tiao.rotation=90;
			addChild(tiao);

			shengwangBg=createIconBg(10, 10, bottomBg);
			jingliBg=createIconBg(10, 58, bottomBg);
			zhanggongBg=createIconBg(10, 106, bottomBg);
			PKBg=createIconBg(10, 154, bottomBg);
			meiliBg=createIconBg(10, 202, bottomBg);

			ComponentUtil.createTextField("声望值：", shengwangBg.x + 50, shengwangBg.y + 9, ttf, 60, 25, bottomBg);
			ComponentUtil.createTextField("精力值：", jingliBg.x + 50, jingliBg.y + 9, ttf, 60, 25, bottomBg);
			ComponentUtil.createTextField("战功值：", zhanggongBg.x + 50, zhanggongBg.y + 9, ttf, 60, 25, bottomBg);
			ComponentUtil.createTextField("PK值：", PKBg.x + 50, PKBg.y + 9, ttf, 60, 25, bottomBg);
			ComponentUtil.createTextField("魅力值：", meiliBg.x + 50, meiliBg.y + 9, ttf, 60, 25, bottomBg);

			shengwangCHInput=createTextInput(shengwangBg.x + 105, shengwangBg.y + 7, 138, 24, bottomBg);
			shengwangPointInput=createTextInput(shengwangBg.x + 255, shengwangBg.y + 7, 138, 24, bottomBg);
			jingliCHInput=createTextInput(jingliBg.x + 105, jingliBg.y + 7, 138, 24, bottomBg);
			jingliPointInput=createTextInput(jingliBg.x + 255, jingliBg.y + 7, 138, 24, bottomBg);
			zhanggongCHInput=createTextInput(zhanggongBg.x + 105, zhanggongBg.y + 7, 138, 24, bottomBg);
			zhanggongPointInput=createTextInput(zhanggongBg.x + 255, zhanggongBg.y + 7, 138, 24, bottomBg);
			pkCHInput=createTextInput(PKBg.x + 105, PKBg.y + 7, 138, 24, bottomBg);
			pkPointInput=createTextInput(PKBg.x + 255, PKBg.y + 7, 138, 24, bottomBg);
			meiliCHInput=createTextInput(meiliBg.x + 105, meiliBg.y + 7, 138, 24, bottomBg);
			meiliPointInput=createTextInput(meiliBg.x + 255, meiliBg.y + 7, 138, 24, bottomBg);

			var exchangeLink:TextField=ComponentUtil.createTextField("", shengwangPointInput.x + 146, shengwangPointInput.y + 2, null, 100, 25, bottomBg);
			exchangeLink.htmlText=HtmlUtil.link(HtmlUtil.font("兑换", "#00ff00"), "exchange", true);
			exchangeLink.addEventListener(TextEvent.LINK, onExchangeLinkHandler);
			exchangeLink.mouseEnabled=true;

			var addEnergyLink:TextField=ComponentUtil.createTextField("", jingliPointInput.x + 146, jingliPointInput.y + 2, null, 100, 25, bottomBg);
			addEnergyLink.htmlText=HtmlUtil.link(HtmlUtil.font("补充", "#00ff00"), "addEnergy", true);
			addEnergyLink.addEventListener(TextEvent.LINK, onAddEnergyLinkHandler);
			addEnergyLink.mouseEnabled=true;

			if (RoleStateDateManager.myTitles != null)
			{
				chCombox.dataProvider=RoleStateDateManager.myTitles;
				chCombox.labelField="name";
				chCombox.selectedIndex=0;
			}
		}

		private function createTextInput(x:int, y:int, w:int, h:int, $parent:DisplayObjectContainer):TextInput
		{
			var textInput:TextInput=ComponentUtil.createTextInput(x, y, w, h, topBg);
			textInput.textField.defaultTextFormat=itf;
			textInput.leftPadding=8;
			textInput.enabled=false;
			$parent.addChild(textInput);
			return textInput;
		}

		private function createIconBg(x:int, y:int, $parent:DisplayObjectContainer):Bitmap
		{
			var bg:Bitmap=Style.getBitmap(GameConfig.T1_VIEWUI, "packItemBg");
			bg.x=x;
			bg.y=y;
			$parent.addChild(bg);
			return bg;
		}

		private function onChangeName(e:Event):void {
			var p:p_title=chCombox.selectedItem as p_title;
			var evt:ParamEvent=new ParamEvent(EVENT_CHANGE_TITLE, p, true);
			this.dispatchEvent(evt);
		}

		public function update():void
		{
			var roleVO:p_role=GlobalObjectManager.getInstance().user;
			guojiInput.text=GameConstant.getNation(roleVO.base.faction_id);
			jiazuInput.text=roleVO.base.family_name;
			guanzhiInput.text=roleVO.attr.office_name;

			shengwangPointInput.text=String(roleVO.attr.cur_prestige); //当前声望
			jingliPointInput.text=String(roleVO.fight.energy); //精力
			zhanggongPointInput.text=String(roleVO.attr.gongxun); //战功
			pkPointInput.text=String(roleVO.base.pk_points); //PK
			meiliPointInput.text=String(roleVO.attr.charm); //魅力

			var rankTitle:String=RoleStateDateManager.getLevelTitle();
			if (rankTitle == "")
			{
				var lv:int=roleVO.attr.level;
				if (lv < 50)
				{
					rankTitle="初入江湖";
				}
				else if (lv >= 50 && lv < 80)
				{
					rankTitle="江湖小虾";
				}
				else if (lv >= 80 && lv < 100)
				{
					rankTitle="武林新秀";
				}
				else if (lv >= 100)
				{
					rankTitle="江湖豪杰";
				}
			}
			dengjiInput.text=rankTitle;
		}

		private function onExchangeLinkHandler(event:TextEvent):void
		{
			Dispatch.dispatch(ModuleCommand.OPEN_PRESTIGE_PANEL)
		}

		private function onAddEnergyLinkHandler(event:TextEvent):void
		{
			this.dispatchEvent(new ParamEvent(EVENT_OPEN_ADD_ENERGY, null, true));
		}

		public function updatePrestige():void
		{

		}

		public function updateMyTitles(vo:m_title_get_role_titles_toc):void
		{
			RoleStateDateManager.myTitles=vo.titles;
			var curName:String;
			if (chCombox.selectedItem != null)
			{
				curName=chCombox.selectedItem.name;
			}
			else
			{
				curName="天之刃";
			}
			chCombox.dataProvider=vo.titles;
			for (var i:int=0; i < vo.titles.length; i++)
			{
				var p:p_title=vo.titles[i];
				if (p.name == curName)
				{
					chCombox.selectedItem=p;
					break;
				}
			}
		}

		public function upDatePKTime(minite:int):void
		{
//			var p:int=int(pkText.text);
//			if (p > 0) {
//				_pkTime=(p - 1) * 10 + minute;
//			}
		}

		public function showPropertyBorder():void
		{

		}
	}
}