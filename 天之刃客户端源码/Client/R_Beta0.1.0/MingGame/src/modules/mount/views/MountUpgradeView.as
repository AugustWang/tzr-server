package modules.mount.views {
	import com.common.GlobalObjectManager;
	import com.globals.GameConfig;
	import com.ming.events.ItemEvent;
	import com.ming.ui.containers.List;
	import com.ming.ui.controls.Image;
	import com.ming.ui.controls.core.UIComponent;
	import com.scene.sceneUnit.baseUnit.things.avatar.AvatarBMC;
	import com.scene.sceneUnit.baseUnit.things.avatar.AvatarConstant;
	import com.scene.sceneUnit.baseUnit.things.heartbeat.ThingFrameFrequency;
	import com.scene.sceneUnit.baseUnit.things.resource.SourceManager;
	import com.utils.ComponentUtil;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.DataEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import modules.mount.render.MountListRender;
	import modules.mypackage.ItemConstant;
	import modules.mypackage.managers.ItemLocator;
	import modules.mypackage.managers.PackManager;
	import modules.mypackage.vo.BaseItemVO;
	import modules.mypackage.vo.EquipVO;
	
	import proto.common.p_goods;

	public class MountUpgradeView extends Sprite {
		//背景
		private var bg:UIComponent;
		//表头
		private var title:Sprite;
		//坐骑列表
		private var mountList:List;
//		//提速牌列表
//		private var upgrateList:List;
		//播放马的系列帧动画的
		private var avatar:AvatarBMC;
		//存放全部的坐骑
		private var allMountArray:Array;
		//当前坐骑的地址
		private var mountsURL:String;
		//信息栏
		public var messagePanel:MessagePanel;
		//购买栏
		public var updatePanel:UpgradePanel;
		//当前select的那个index
		public var index:int=0;
		//是否有正在使用的坐骑
		public var flag:Boolean=false;

		public function MountUpgradeView() {
			initUI();
			initData();
		}

		private function initUI():void {
			//title
			var titleContent:TextField=new TextField();
			titleContent.x=15;
			titleContent.y=8;
			titleContent.htmlText="<font color='#51EAEF'>坐骑不同，行走的初始速度也不同，你可以使用【坐骑提速牌】提升坐骑速度</font>";
			titleContent.width=510;
			titleContent.height=23;
			addChild(titleContent);
			
			bg = ComponentUtil.createUIComponent(16,25,282,200);
			Style.setBorderSkin(bg);
			
			var img:Image=new Image();
			img.width = 273;
			img.height = 152;
			img.mouseChildren = img.mouseEnabled = false;
			img.source=GameConfig.getBackImage("petInfoBg");
			img.x = bg.width - img.width >> 1;
			img.y = bg.height - img.height >> 1;
			bg.addChild(img);
			
			var topBG:Image=new Image();
			topBG.source=GameConfig.ROOT_URL + "com/assets/mount/topBg.png";
			topBG.x=47;
			topBG.y=72;
			bg.addChild(topBG);
			
			avatar=new AvatarBMC();
			avatar.x=170;
			avatar.y=153;
			bg.addChild(avatar);
			
			addChild(bg);

			
			var tf:TextFormat=new TextFormat(null, null, 0x00ff00, null);

			//坐骑列表
			var listParent:UIComponent= ComponentUtil.createUIComponent(bg.x+bg.width+4,25,172,184);
			Style.setBorderSkin(listParent);
			var listTitle:Bitmap=Style.getBitmap(GameConfig.T1_VIEWUI,"titleBar");
			//listTitle.x = listTitle.y = 1;
			listTitle.width = 172;
			listParent.addChild(listTitle);
			
			
			var listTitleContent:TextField=ComponentUtil.createTextField("坐骑列表", 4, 0, Style.centerTextFormat, 172, 22, listParent);
			mountList=new List;
			mountList.bgSkin = null;
			mountList.width=170;
			mountList.selectedIndex=0;
			mountList.itemSkinLeft = 40;
			mountList.itemRenderer=MountListRender;
			mountList.itemHeight=42;
			mountList.height=162;
			mountList.y=22;
			mountList.x = 1;
			mountList.addEventListener(ItemEvent.ITEM_CLICK, onItemClick);
			listParent.addChild(mountList);
			addChild(listParent);

			//提速牌
			var listParent2:UIComponent= ComponentUtil.createUIComponent(listParent.x,215,172,132);
			Style.setBorderSkin(listParent2);
			var listTitle2:Bitmap=Style.getBitmap(GameConfig.T1_VIEWUI,"titleBar");
			listTitle2.width = 170;
			//listTitle2.x = listTitle2.y = 1;
			listParent2.addChild(listTitle2);
			
			var listTitleContent2:TextField=ComponentUtil.createTextField("提速牌", 10, 0, Style.centerTextFormat, 172, 22,
				listParent2);
			updatePanel=new UpgradePanel();
			updatePanel.y=20;
			updatePanel.x=5;
			listParent2.addChild(updatePanel);
			addChild(listParent2);

			//目前使用马的信息
			messagePanel=new MessagePanel();
			messagePanel.y=242;
			messagePanel.x = 0;
			addChild(messagePanel);
		}

		private function initData():void {
			if (allMountArray == null) {
				allMountArray=new Array();
			} else if (allMountArray.length != 0) {
				allMountArray.length=0;
			}
			var length:int=GlobalObjectManager.getInstance().user.attr.equips.length;
			for (var i:int=0; i < length; i++) {
				if (GlobalObjectManager.getInstance().user.attr.equips[i].loadposition == 15) {
					//当前正在使用的坐骑
					var currentMount:p_goods=GlobalObjectManager.getInstance().user.attr.equips[i];
					var equipVO:EquipVO=new EquipVO();
					equipVO.copy(currentMount);
					allMountArray.push(equipVO);

					flag=true;
				}
			}

			var equipArray:Array=PackManager.getInstance().getItemByKind(ItemConstant.KIND_EQUIP_MOUNT);
			var length_equipArray:int=equipArray.length;
			if (length_equipArray > 0) {
				for (var j:int=0; j < length_equipArray; j++) {
					var newEquipVO:EquipVO=equipArray[j];
					allMountArray.push(newEquipVO);
				}
			}

			if (allMountArray.length > 0) {
				//获取马的系列帧动画
				getMountData(allMountArray[0]);
				//显示信息
				messagePanel.dataProvider=allMountArray[0];
				//赋值给mountList
				mountList.dataProvider=allMountArray;
			}
			else
			{
				if(avatar != null)
				{
					avatar.stop();
					avatar.visible = false;
				}
				mountList.dataProvider = null;
				messagePanel.dataProvider = null;
			}
		}

		//更新数据
		public function update(date:BaseItemVO):void {
//			var length:int=allMountArray.length;
//			if (length > 0) {
//				var baseItemVO:BaseItemVO=allMountArray[index];
//				if (baseItemVO.roleId == date.roleId) {
//					allMountArray[index]=date;
//					//显示信息
//					messagePanel.dataProvider=date;
//					var selectChild:MountListRender=mountList.getChildAt(index) as MountListRender;
//					selectChild.data=date;
//				}
//			}
			
			var baseItemVO:BaseItemVO = mountList.selectedItem as BaseItemVO;
			var length:int=allMountArray.length;
			for(var i:int=0; i<length;i++)
			{
				var select:BaseItemVO = allMountArray[i];
				if(select.oid == date.oid)
				{
					allMountArray[i] = date;
					//显示信息
					messagePanel.dataProvider=date;
					var selectChild:MountListRender = mountList.selectedChild as MountListRender;
					selectChild.data = date;
				}
			}
		}

		//获取马的序列帧动画
		private function getMountData(data:EquipVO):void {
			var _mountData:Object=ItemLocator.getInstance().getEquip(data.typeId);
			mountsURL=GameConfig.MOUNT_PATH + _mountData.form + '.swf';
			if (SourceManager.getInstance().has(mountsURL)) {
				if (SourceManager.getInstance().hasComplete(mountsURL)) {
					avatar.play(mountsURL, AvatarConstant.ACTION_STAND, AvatarConstant.DIR_RIGHT, ThingFrameFrequency.
						STAND, true);
					avatar.visible=true;
				} else {
					SourceManager.getInstance().addEventListener(SourceManager.CREATE_COMPLETE, sourceCreateComplete);
				}
			} else {
				SourceManager.getInstance().addEventListener(SourceManager.CREATE_COMPLETE, sourceCreateComplete);
				SourceManager.getInstance().load(mountsURL);
			}
		}

		private function sourceCreateComplete(event:DataEvent):void {
			if (mountsURL == event.data) {
				SourceManager.getInstance().removeEventListener(SourceManager.CREATE_COMPLETE, sourceCreateComplete);
				avatar.play(mountsURL, AvatarConstant.ACTION_STAND, AvatarConstant.DIR_RIGHT, ThingFrameFrequency.
					STAND, true);
				avatar.visible=true;
			}
		}

		//点击list的回调函数
		private function onItemClick(Evt:ItemEvent):void {
			//index=mountList.selectedIndex;
			//var data:EquipVO=allMountArray[index];
			var data:EquipVO = mountList.selectedItem as EquipVO;
			messagePanel.dataProvider=data;
			//马的序列帧动画
			getMountData(data);
		}

		//打开窗口时自动调用
		public function resetData():void {
			initData();
		}

		//关闭窗口时自动调用
		public function destoryData():void {
			allMountArray.length=0;
			if (flag == true) {
				flag=false;
			}
			if (avatar != null) {
				avatar.stop();
			}
		}
	}
}
import com.globals.GameConfig;
import com.loaders.CommonLocator;
import com.ming.ui.controls.Button;
import com.ming.ui.controls.Image;
import com.utils.ComponentUtil;
import com.utils.DateFormatUtil;
import com.utils.HtmlUtil;

import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.text.TextField;
import flash.text.TextFormat;

import modules.mypackage.ItemConstant;
import modules.mypackage.PackageModule;
import modules.mypackage.managers.ItemLocator;
import modules.mypackage.managers.PackManager;
import modules.mypackage.vo.BaseItemVO;
import modules.shop.ShopModule;

class MessagePanel extends Sprite {
	//当前速度的描述
	private var currentDescTemp:TextField;
	//下一个可以升级速度的描述
	private var lastDescTemp:TextField;
	//提速按钮
	private var upgradeBtn:Button;
	//该马的名称
	private var nameDescTemp:TextField;
	//数据
	private var data:Object;
	//马的配置文件的读取内容
	private var xml:XML;
	//有效期
	private var canUseTimer:TextField;
	//是否可以提交按钮
	private var flag:Boolean;
	//提速按钮的cd时间
	private var isClick:Boolean=true;

	function MessagePanel() {
		initUI();
		initListener();
	}

	private function initData():void {
		if (xml == null) {
			xml=CommonLocator.getXML(CommonLocator.MOUNT_UPGRADE);
		}

		//有可能出现该马已经是最高级了，同时又有提速符,所以有必要这样判断
		//===================================================================

		//如果背包里的没有提速牌，按钮就不能点击
		if (PackManager.getInstance().getGooodsCountByEffectType(ItemConstant.EFFECT_MOUNT_UPGRADE) ==
			0) {
			flag=false;
		} else {
			flag=true;
		}
		
		if(data != null)
		{
			nameDescTemp.htmlText=HtmlUtil.font(data.name,ItemConstant.COLOR_VALUES[data.color],14);
			currentDescTemp.htmlText="<font color='#AFE1EC'>当前速度：</font><font color='#CEE444'>+" + data.
				add_property.move_speed + "</font>";
			if (data.color == ItemConstant.COLOR_ORANGE) {
				lastDescTemp.htmlText="<font color='#ff0000'>该坐骑为最高等级，无法提升。</font>";
				flag=false;
			} else {
				flag=true;
				var speed:String=xml.item.(@id == data.typeId).level[data.color].@data;
				lastDescTemp.htmlText="<font color='#AFE1EC'>下一级速度：</font><font color='#00FF7F'>+" + speed +
					"</font>";
			}
			
			if (data.timeoutData == 0) {
				canUseTimer.htmlText="<font color='#CDE643'>永久使用!!!</font>";
			} else {
				var timer:String=DateFormatUtil.secToDateCn(data.timeoutData);
				canUseTimer.htmlText="<font color='#AFE1EC'>" + timer + "</font>";
			}
			
			updataBTN(flag);
		}
		else
		{
			nameDescTemp.text="";
			currentDescTemp.htmlText="<font color='#AFE1EC'>当前速度：</font>";
			lastDescTemp.htmlText = "<font color='#AFE1EC'>下一级速度：</font>";
			flag=false;
			canUseTimer.htmlText = "";
			upgradeBtn.enabled = flag;
		}
	}
	
	private function initListener():void {
		upgradeBtn.addEventListener(MouseEvent.CLICK, onUpgradeBtnClick);
	}

	private function initUI():void {
		nameDescTemp=ComponentUtil.createTextField("名称", 25, 7, null, 190, 22, this);

		currentDescTemp=ComponentUtil.createTextField("", 60, 41, null, 190, 22, this);

		lastDescTemp=ComponentUtil.createTextField("", 60, 61, null, 190, 22, this);

		upgradeBtn=ComponentUtil.createButton("提速", 230, 100, 60, 25, this);

		var label:TextField=ComponentUtil.createTextField("有效期至:", 60, 83, null, 62, 22, this);

		canUseTimer=ComponentUtil.createTextField("", 115, 83, null, 100, 22, this);
	}

	private function onUpgradeBtnClick(event:MouseEvent):void {
		if (isClick == true && data != null) {
			isClick=false;
			upgradeBtn.enabled=PackageModule.getInstance().useTSP(data.oid);
		}
	}

	//点击提速，后台已经返回
	public function canClick():void {
		if (isClick != true) {
			isClick=true;
		}
	}

	public function updataBTN(flag:Boolean):void {
		//只要当前的马不是最高级就可以执行下面的代码
		if (data.color != ItemConstant.COLOR_ORANGE) {
			upgradeBtn.enabled=flag;
		}
		canClick();
	}

	public function set dataProvider(data:Object):void {
		this.data=data;
		initData();
	}
}

class UpgradePanel extends Sprite {
	//坐骑提速牌
	public static const MOUNT_UPGRADE_CARD:int=11600006;
	//提速的图片
	private var image:Image;
	//提速名称
	private var upgradeName:TextField;
	//提速个数
	private var num:TextField;
	//购买按钮
	private var bug:TextField;

//	//数据保存
//	private var data:Object;

	function UpgradePanel() {
		initUI();
	}

	private function initUI():void {
		//获取提速牌的图片
		var bg:Bitmap = Style.getBitmap(GameConfig.T1_VIEWUI,"packItemBg");
		bg.y = 4;
		addChild(bg);
		var data:BaseItemVO=ItemLocator.getInstance().getObject(11600006) as BaseItemVO;
		image=new Image();
		image.x=3;
		image.y=7;
		image.source=data.path;
		addChild(image);

		upgradeName=ComponentUtil.createTextField("坐骑提速牌", 38, 6, null, 100, 22, this);

		num=ComponentUtil.createTextField("", 38, 20, null, 80, 23, this);

		updateNum(PackManager.getInstance().getGoodsNumByTypeId(11600006));

		bug=ComponentUtil.createTextField("", 120, 20, null, 30, 23, this);
		bug.htmlText="<font color='#00FF00' ><a href='event:buy'><u>购买</u></a></font>";
		bug.mouseEnabled=true;
		bug.addEventListener(MouseEvent.CLICK, onBuyBtnClick);
	}

	private function updateNum(number:int):void {
		if (number == 0) {
			num.htmlText="x <font color='#DC143C'>" + number + "</font>";
		} else {
			num.text="x " + number;
		}
	}

	//更新提速牌的个数
	public function updateUI():void {
		updateNum(PackManager.getInstance().getGoodsNumByTypeId(11600006));
	}

	private function onBuyBtnClick(evt:MouseEvent):void {
		//坐骑商店
		ShopModule.getInstance().requestShopItem(20116, MOUNT_UPGRADE_CARD, new Point(stage.mouseX-178, stage.mouseY-90));
	}
}






