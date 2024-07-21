package modules.roleStateG.views.details {
	import com.common.FilterCommon;
	import com.common.GlobalObjectManager;
	import com.common.dragManager.DragConstant;
	import com.common.dragManager.DragItemEvent;
	import com.common.dragManager.DragItemManager;
	import com.components.BasePanel;
	import com.globals.GameConfig;
	import com.loaders.CommonLocator;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.Image;
	import com.ming.ui.controls.core.UIComponent;
	import com.ming.ui.layout.LayoutUtil;
	import com.ming.ui.skins.Skin;
	import com.scene.sceneUnit.baseUnit.things.avatar.Avatar;
	import com.scene.sceneUnit.baseUnit.things.avatar.AvatarBMC;
	import com.scene.sceneUnit.baseUnit.things.avatar.AvatarConstant;
	import com.scene.sceneUnit.baseUnit.things.heartbeat.ThingFrameFrequency;
	import com.scene.sceneUnit.baseUnit.things.resource.SourceManager;
	import com.utils.ComponentUtil;
	import com.utils.DateFormatUtil;
	import com.utils.HtmlUtil;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.DataEvent;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import modules.broadcast.views.Tips;
	import modules.chat.ChatModule;
	import modules.mount.mountModule;
	import modules.mypackage.ItemConstant;
	import modules.mypackage.PackageModule;
	import modules.mypackage.managers.ItemLocator;
	import modules.mypackage.vo.BaseItemVO;
	import modules.mypackage.vo.EquipVO;
	import modules.roleStateG.views.EquipItem;
	import modules.system.SystemConfig;
	
	import proto.common.p_goods;

	public class RoleMyMountView extends Sprite {
		public static const MOUNT_POS:int=15;

		private var avatar:Avatar;
//		private var itemBg:Sprite;
		private var str:String;
		private var item:EquipItem;
		private var speedTxt:TextField;
		private var descTF:TextField;
		private var _mountData:Object;

		private var glm:GlobalObjectManager=GlobalObjectManager.getInstance();
		private var _mounts:AvatarBMC;
		private var _mountsURL:String
		private var renewalBtn:Button;
		private var upgradeBtn:Button
		//马的名称
		private var mouseName:TextField;
		//有效期
		private var timeOut:TextField;
		private var border:UIComponent;
		//new
		private var mountBg:UIComponent;
		private var callUpBtn:Button;
		private var mountCount:TextField;
		
		public function RoleMyMountView() {
			setupUI();
			super();
		}

		private function setupUI():void {
			mountBg=ComponentUtil.createUIComponent(9, 7, 454, 174);
			Style.setBorderSkin(mountBg);
			addChild(mountBg);
			
			mouseName = ComponentUtil.createTextField("",9,7,null,150,25,mountBg);
			mouseName.htmlText = HtmlUtil.font("神马 1级","#51EAEF");
			
			var topBG:Image=new Image();
			topBG.source=GameConfig.ROOT_URL + "com/assets/mount/topBg.png";
			topBG.x=138;
			topBG.y=52;
			mountBg.addChild(topBG);
			
			_mounts=new AvatarBMC();
			_mounts.x=250;
			_mounts.y=135;
			mountBg.addChild(_mounts);
			
			var leftBtn:UIComponent = ComponentUtil.createUIComponent(142,132,21,28);
			leftBtn.bgSkin = Style.getSkin("right",GameConfig.T1_VIEWUI);
			leftBtn.buttonMode = leftBtn.useHandCursor = true;
			leftBtn.addEventListener(MouseEvent.CLICK,leftHandler);
			mountBg.addChild(leftBtn);
			
			var rightBtn:UIComponent = ComponentUtil.createUIComponent(266,132,21,28);
			rightBtn.bgSkin = Style.getSkin("left",GameConfig.T1_VIEWUI);
			rightBtn.buttonMode = leftBtn.useHandCursor = true;
			rightBtn.addEventListener(MouseEvent.CLICK,rightHandler);
			mountBg.addChild(rightBtn);
			
			callUpBtn=ComponentUtil.createButton("召唤",197,144,62,24,mountBg);
			
			mountCount=ComponentUtil.createTextField("",20,182,null,150,25,this);
			mountCount.htmlText=HtmlUtil.font("总数：12个","#51EAEF");
			
			border=ComponentUtil.createUIComponent(25,205,200,150);
			addChild(border);
			for(var i:int=0; i<12;i++){
				item=new EquipItem();
				item.name=MOUNT_POS.toString();
				item.position=MOUNT_POS;
				item.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
				item.doubleClickEnabled=true;
				item.addEventListener(MouseEvent.DOUBLE_CLICK, onItemDoubleClick);
				border.addChild(item);
			}
			LayoutUtil.layoutGrid(border,4,10,10);
			
			var menuTF:TextField = ComponentUtil.createTextField("",25,342,null,200,25,this);
			menuTF.htmlText = HtmlUtil.font("首页 上一页 1 下一页 末页 共1页","#51EAEF");
			
			var tiao:Bitmap=Style.getBitmap(GameConfig.T1_VIEWUI, "hightLightLine");
			tiao.width=150;
			tiao.x = 238;
			tiao.y = 205;
			tiao.rotation = 90;
			addChild(tiao);
			
			var dtf:TextFormat = new TextFormat("Tahoma", 12, 0xF6F5CD);
			dtf.leading = 6;
			descTF = ComponentUtil.createTextField("",268,182,dtf,200,160,this);
			descTF.filters = Style.textBlackFilter;
			descTF.htmlText=HtmlUtil.fontBr(HtmlUtil.bold(HtmlUtil.font("神马","#FFFF66",14)),"#FFFF66")+HtmlUtil.fontBr("使用期：永久使用!","#51EAEF")+HtmlUtil.fontBr("等级：1级","#51EAEF")+HtmlUtil.fontBr("经验：0/200","#51EAEF")+HtmlUtil.fontBr("年龄：2岁","#51EAEF")+HtmlUtil.fontBr("速度：34","#51EAEF")+HtmlUtil.fontBr("按T能召唤坐骑","#FFFF66");
			
			renewalBtn = ComponentUtil.createButton("续期",300,336,62,24,this);
			renewalBtn.addEventListener(MouseEvent.CLICK, onRenewalMount);
			upgradeBtn = ComponentUtil.createButton("提速",377,336,62,24,this);
			upgradeBtn.addEventListener(MouseEvent.CLICK, onUpGradeBtnClick);

			DragItemManager.instance.addEventListener(DragItemEvent.START_DRAG, onStartDrag);
			DragItemManager.instance.addEventListener(DragItemEvent.STOP_DRAG, onStopDrag);


		}
		
		private var direct:int = 2;
		private function leftHandler(event:MouseEvent):void{
			var curMountGoods:p_goods=this.getMount();
			if (curMountGoods) {
				if(direct == 7){
					direct = 0;
				}
				direct++;
				_mounts.play(_mountsURL, AvatarConstant.ACTION_STAND, direct, ThingFrameFrequency.STAND, true);
			}
		}
		
		private function rightHandler(event:MouseEvent):void{
			var curMountGoods:p_goods=this.getMount();
			if (curMountGoods) {
				if(direct == 0){
					direct = 7;
				}
				direct--;
				_mounts.play(_mountsURL, AvatarConstant.ACTION_STAND, direct, ThingFrameFrequency.STAND, true);
			}
		}
		
		private function onUpGradeBtnClick(event:MouseEvent):void {
			//查找坐骑的信息 
			var length:int=GlobalObjectManager.getInstance().user.attr.equips.length;
			for (var i:int=0; i < length; i++) {
				if (GlobalObjectManager.getInstance().user.attr.equips[i].loadposition == 15) {
					//当前正在使用的坐骑
					var currentMount:p_goods=GlobalObjectManager.getInstance().user.attr.equips[i];
					//坐骑过期
					if (SystemConfig.serverTime >= currentMount.end_time && currentMount.end_time != 0) {
						mountModule.getInstance().openTipView(currentMount);
						return;
					}
				}
			}
			mountModule.getInstance().openMountUpGradePanel();
		}

		/**
		 * 坐骑续期
		 * @param event
		 *
		 */
		private function onRenewalMount(event:MouseEvent):void {
			var curMountGoods:p_goods=this.getMount();
			if (curMountGoods == null) {
				Tips.getInstance().addTipsMsg("当前没有装备坐骑，不需要续期！");
				return;
			}
			var baseItemVo:BaseItemVO=ItemConstant.wrapperItemVO(curMountGoods);
			if (baseItemVo is EquipVO) {
				PackageModule.getInstance().doMountRenewalTos(baseItemVo as EquipVO, 1, 0, 2);
			} else {
				Tips.getInstance().addTipsMsg("坐骑物品类型出错，打开续期界面失败！");
				return;
			}
		}

		private function sourceCreateComplete(event:DataEvent):void {
			if (_mountsURL == event.data) {
				SourceManager.getInstance().removeEventListener(SourceManager.CREATE_COMPLETE, sourceCreateComplete);
				_mounts.play(_mountsURL, AvatarConstant.ACTION_STAND, AvatarConstant.DIR_RIGHT, ThingFrameFrequency.STAND, true);
				_mounts.visible=true;
				centerMount();
			}
		}

		private function getMount():p_goods {
			var l:int=glm.user.attr.equips.length;
			for (var i:int=0; i < l; i++) {
				if (glm.user.attr.equips[i].loadposition == MOUNT_POS)
					return glm.user.attr.equips[i];
			}
			return null;
		}

		public function update():void {
			var good:p_goods=getMount();
			this.renewalBtn.enabled=false;
			this.renewalBtn.visible=false;
			if (!good) {
				_mountData=null;
				removeAllEquips();
				mouseName.htmlText="<font color='#FFFFFF'>你目前还没有坐骑</font>";
				_mounts.stop();
				_mounts.visible=false;
				this.upgradeBtn.visible = false;
				updateDesc(null,null);
				return;
			}
			if (good.end_time != 0) {
				this.renewalBtn.enabled=true;
				this.renewalBtn.visible=true;
			}
			_mountData=ItemLocator.getInstance().getEquip(good.typeid);
			if (_mountData == null) {
				return;
			}
			updateDesc(_mountData,good);
			if (_mountData.color == ItemConstant.COLOR_ORANGE) {
				upgradeBtn.visible = false;
			} else {
				upgradeBtn.visible = true;
			}
			
			//更新坐骑形象
			_mountsURL=GameConfig.MOUNT_PATH + _mountData.form + '.swf';
			if (SourceManager.getInstance().has(_mountsURL)) {
				if (SourceManager.getInstance().hasComplete(_mountsURL)) {
					_mounts.play(_mountsURL, AvatarConstant.ACTION_STAND, AvatarConstant.DIR_RIGHT, ThingFrameFrequency.STAND, true);
					_mounts.visible=true;
					centerMount();
				} else {
					SourceManager.getInstance().addEventListener(SourceManager.CREATE_COMPLETE, sourceCreateComplete);
				}
			} else {
				SourceManager.getInstance().addEventListener(SourceManager.CREATE_COMPLETE, sourceCreateComplete);
				SourceManager.getInstance().load(_mountsURL);
			}

			removeAllEquips();
			var equips:Array=GlobalObjectManager.getInstance().user.attr.equips;
			for (var i:int=0; i < equips.length; i++) {
				var equip:EquipVO=ItemConstant.wrapperItemVO(equips[i]) as EquipVO;
				if (equip && equip.loadposition == MOUNT_POS) {
					if (item){
						direct = 2;
						item.updateContent(equip);
					}
				}
			}
		}
		
		private function updateDesc(vo:Object,good:p_goods):void{
			if(vo){
				mouseName.htmlText = HtmlUtil.font(vo.name + " "+good.current_colour+"级","#51EAEF");
				var descHtml:String = HtmlUtil.bold(HtmlUtil.fontBr(vo.name,ItemConstant.COLOR_VALUES[vo.color],14));
				if(good.end_time == 0){
					descHtml+=HtmlUtil.fontBr("使用期：永久使用","#51EAEF");
				}else{
					var timer:String=DateFormatUtil.secToDateCn(good.end_time);
					descHtml+=HtmlUtil.fontBr("使用期："+timer,"#51EAEF");
				}
				descHtml+=HtmlUtil.fontBr("等级："+good.current_colour+"级","#51EAEF");
				descHtml+=HtmlUtil.fontBr("经验：","#51EAEF");
				descHtml+=HtmlUtil.fontBr("年龄：","#51EAEF");
				descHtml+=HtmlUtil.fontBr("速度："+good.add_property.move_speed,"#51EAEF");
				descHtml+=HtmlUtil.fontBr("按T能召唤坐骑","#FFFF66");
				descTF.htmlText = descHtml;
			}else{
				mouseName.htmlText = HtmlUtil.font("你目前还没有坐骑","#FFFFFF");
				var nullHtml:String = HtmlUtil.fontBr("你目前还没有坐骑","#FFFFFF",14);
				nullHtml+=HtmlUtil.fontBr("使用期：","#51EAEF");
				nullHtml+=HtmlUtil.fontBr("等级：","#51EAEF");
				nullHtml+=HtmlUtil.fontBr("经验：","#51EAEF");
				nullHtml+=HtmlUtil.fontBr("年龄：","#51EAEF");
				nullHtml+=HtmlUtil.fontBr("速度：","#51EAEF");
				descTF.htmlText = nullHtml;
			}
		}

		private function removeAllEquips():void {
			if (item) {
				item.updateContent(null);
			}
		}
		
		private function centerMount():void{
			_mounts.x = (452 - _mounts.width >> 1)-_mounts.offsetX;
		}
		
		private function mouseDownHandler(event:MouseEvent):void {
			var equipItem:EquipItem=event.currentTarget as EquipItem;
			if (event.ctrlKey && equipItem.data) {
				ChatModule.getInstance().showGoods(equipItem.data.oid);
			} else if (equipItem.data && !DragItemManager.isDragging()) {
				DragItemManager.instance.startDragItem(this, equipItem.getContent(), DragConstant.EQUIP_ITEM, equipItem.data);
			}
		}

		private function onItemDoubleClick(event:MouseEvent):void {
			var equipItem:EquipItem=event.currentTarget as EquipItem;
			if (equipItem.data && !DragItemManager.isDragging()) {
				PackageModule.getInstance().unLoadEquip(equipItem.data.oid);
			}
		}

		private function onStartDrag(event:DragItemEvent):void {
			var equipVO:EquipVO=event.dragData as EquipVO;
			if (equipVO) {
				setFilter([new GlowFilter(0xffffff, 1, 6, 6, 4)], equipVO);
			}
		}

		private function onStopDrag(event:DragItemEvent):void {
			var equipVO:EquipVO=event.dragData as EquipVO;
			if (equipVO) {
				setFilter([], equipVO);
			}
		}

		public function setFilter(filters:Array, equipVO:EquipVO):void {
			var pos:Array=ItemConstant.getPostionByPutWhere(equipVO.putWhere);
			for each (var position:int in pos) {
				var equipItem:EquipItem=getChildByName((position + 1).toString()) as EquipItem;
				if (equipItem) {
					equipItem.filters=filters;
				}
			}
		}
	}
}