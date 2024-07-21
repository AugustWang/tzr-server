package modules.mount.views
{
	import com.common.FilterCommon;
	import com.common.GlobalObjectManager;
	import com.components.BasePanel;
	import com.components.DataGrid;
	import com.components.alert.Alert;
	import com.events.ParamEvent;
	import com.globals.GameConfig;
	import com.managers.WindowManager;
	import com.ming.ui.constants.ScrollPolicy;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.core.UIComponent;
	import com.utils.ComponentUtil;
	import com.utils.DateFormatUtil;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import modules.broadcast.views.Tips;
	import modules.mypackage.ItemConstant;
	import modules.mypackage.PackageModule;
	import modules.mypackage.views.GoodsImage;
	import modules.mypackage.views.ItemToolTip;
	import modules.mypackage.vo.BaseItemVO;
	import modules.mypackage.vo.EquipVO;
	import modules.shop.ShopModule;
	import modules.smallMap.SmallMapModule;
	import modules.system.SystemConfig;
	
	import proto.common.p_equip_mount_renewal;
	import proto.line.m_equip_mount_renewal_toc;

	/**
	 * 坐骑续期界面
	 * @author caochuncheng@mingchao.com
	 * 
	 */	
	public class MountRenewalPanel extends BasePanel{
		
		public static const MOUNT_RENEWAL_SELECT_EVENT:String = "mountRenewalSelectEvent";//选择
		
		
		private var headerText:TextField;
		
		private var renewalBtn:Button;
		private var mountShopBtn:Button;
		private var dataGrid:DataGrid;
		private var _dataProvier:Object;
		private var rewardBox:UIComponent;
		private var mountGoodsImage:GoodsImage;
		private var payText:TextField;
		public function MountRenewalPanel(){
			super();
			this.initView();
		}
		
		private static var _panel:MountRenewalPanel;
		public static function getInstance():MountRenewalPanel{
			if(_panel == null)
				_panel = new MountRenewalPanel();
			return _panel;
		}
		public function openPanel(renewalVo:m_equip_mount_renewal_toc):void{
			if(_panel == null){
				_panel = new MountRenewalPanel();
			}
			_panel.dataProvider = renewalVo;
			if(!WindowManager.getInstance().isPopUp(_panel)){
				WindowManager.getInstance().popUpWindow(_panel);
				WindowManager.getInstance().centerWindow(_panel);
			}
			
		}
		public function closePanel():void{
			if(_panel != null){
				if(_panel.parent){
					WindowManager.getInstance().removeWindow(_panel);
				}
				_panel.dispose();
				_panel = null;
			}
		}
		
		/**
		 * 初始化显示界面
		 */		
		private function initView():void{
			title = "坐骑续期";
			width = 280;
			height =255;
			
			addContentBG(30);
			
			var tf:TextFormat = Style.textFormat;
			tf.align=TextFormatAlign.LEFT;
			var tc:TextFormat = Style.textFormat;
			tc.align=TextFormatAlign.CENTER;
			headerText = ComponentUtil.createTextField("",68,15,tf,width-87,25,this);
			
			var cSprite:Sprite = new Sprite();
			rewardBox = new UIComponent();
			cSprite.addChild(rewardBox);
			rewardBox.width = rewardBox.height = 36;
			rewardBox.x = 10;
			rewardBox.y =  8;
			rewardBox.addEventListener(MouseEvent.ROLL_OVER,onRollOverHandler);
			rewardBox.addEventListener(MouseEvent.ROLL_OUT,onRollOutHandler);
			var box:Sprite = Style.getSpriteBitmap(GameConfig.T1_VIEWUI,"packItemBg");;
			rewardBox.addChild(box);
			box.mouseEnabled = false;
			mountGoodsImage = new GoodsImage();
			box.addChild(mountGoodsImage);
			mountGoodsImage.x = 2;
			mountGoodsImage.y = 2;
			addChild(cSprite);
			
			dataGrid = new DataGrid();
			Style.setBorderSkin(dataGrid);
			dataGrid.pageCount = 5;
			dataGrid.itemRenderer = MountRenewalItem;
			dataGrid.x = 10;
			dataGrid.y = 45;
			dataGrid.width = width-2*10;
			dataGrid.height = 137;
			dataGrid.addColumn("选择",50);
			dataGrid.addColumn("续期:天",120);
			dataGrid.addColumn("费用:元宝",110);
			dataGrid.itemHeight = 22;
			dataGrid.verticalScrollPolicy = ScrollPolicy.OFF;
			addChild(dataGrid);
			dataGrid.addEventListener(MountRenewalPanel.MOUNT_RENEWAL_SELECT_EVENT,onSelectEvent);
			
			
			mountShopBtn = ComponentUtil.createButton("坐骑商店",20,184,65,25,this);
			mountShopBtn.addEventListener(MouseEvent.CLICK,onMountShop);
			payText = ComponentUtil.createTextField("",97,188,tc,75,25,this);
			payText.mouseEnabled = true;
			payText.htmlText = "<a href='event:pay'><font color=\"#3be450\"><u>点击充值</u></font></a>";
			payText.filters = FilterCommon.FONT_BLACK_FILTERS;
			payText.addEventListener(TextEvent.LINK,onClickLinkHandler);
			
			renewalBtn = ComponentUtil.createButton("确认续期",188,184,65,25,this);
			renewalBtn.addEventListener(MouseEvent.CLICK,onRenewalMount);
			
		}
		
		private var selectItem:Object = null;
		private function onSelectEvent(event:ParamEvent):void{
			if(event.data.data.selected){//选中
				if(selectItem != null){//取消之前选中的项
					selectItem.renewalCheckBox.selected = false;
				}
				selectItem = event.data;
				this.renewalBtn.enabled = true;
			}else{//取消选中
				selectItem = null;
				this.renewalBtn.enabled = false;
			}
		}
		public function set dataProvider(value:Object):void{
			_dataProvier = value;
			var renewalVo:m_equip_mount_renewal_toc = _dataProvier as m_equip_mount_renewal_toc;
			if(renewalVo.mount.end_time == 0){//坐骑有效期为：永久
				this.payText.visible = false;
				this.renewalBtn.enabled = false;
				selectItem = null;
				headerText.htmlText = "有效期：<font color=\"#f53f3c\">永久</font>，不需要续期!";
				dataGrid.dataProvider = [];
			}else{
				renewalVo.renewal_confs.sortOn("renewal_type",Array.NUMERIC);
				var itemDataArray:Array = [];
				for each(var renewalItemVo:p_equip_mount_renewal in renewalVo.renewal_confs){
					var itemObj:Object = {renewal_config:renewalItemVo,selected:false,gold:renewalVo.all_gold};
					itemDataArray.push(itemObj);
				}
				dataGrid.dataProvider = itemDataArray;
				selectItem = null;
				this.renewalBtn.enabled = false;
				// TODO 当前已经过期即设置为红色
				if (SystemConfig.serverTime > renewalVo.end_time){
					headerText.htmlText = "有效期：<font color=\"#f53f3c\">" + DateFormatUtil.format(renewalVo.end_time) + "</font>";
				}else{
					headerText.htmlText = "有效期：<font color=\"#ffff00\">" + DateFormatUtil.format(renewalVo.end_time) + "</font>";
				}
				if(renewalVo.renewal_confs != null && renewalVo.renewal_confs.length > 0 ){
					if(p_equip_mount_renewal(renewalVo.renewal_confs[0]).renewal_fee > renewalVo.all_gold){
						this.payText.visible = true;
					}else{
						this.payText.visible = false;
					}
				}else{
					headerText.htmlText = "<font color=\"#f53f3c\">此坐骑不可以续期！</font>";
					this.renewalBtn.enabled = false;
				}
			}
			var baseItemVo:BaseItemVO = ItemConstant.wrapperItemVO(renewalVo.mount);
			rewardBox.data = baseItemVo;
			mountGoodsImage.setImageContent(baseItemVo, baseItemVo.path);
		}
		/**
		 * 玩家元宝变化时，并且打开了续期界面，需要刷新界面 
		 * 
		 */		
		public function updateMoney():void{
			if(_panel != null
				&& WindowManager.getInstance().isPopUp(_panel)){
				var allGold:int = GlobalObjectManager.getInstance().user.attr.gold +  GlobalObjectManager.getInstance().user.attr.gold_bind;
				var renewalVo:m_equip_mount_renewal_toc = _dataProvier as m_equip_mount_renewal_toc;
				if(renewalVo.mount.end_time != 0){
					renewalVo.renewal_confs.sortOn("renewal_type",Array.NUMERIC);
					var itemDataArray:Array = [];
					for each(var renewalItemVo:p_equip_mount_renewal in renewalVo.renewal_confs){
						var itemObj:Object = {renewal_config:renewalItemVo,selected:false,gold:allGold};
						itemDataArray.push(itemObj);
					}
					dataGrid.dataProvider = itemDataArray;
					selectItem = null;
					this.renewalBtn.enabled = false;
					if(renewalVo.renewal_confs != null && renewalVo.renewal_confs.length > 0 ){
						if(p_equip_mount_renewal(renewalVo.renewal_confs[0]).renewal_fee > allGold){
							this.payText.visible = true;
						}else{
							this.payText.visible = false;
						}
					}
				}
			}
		}
		private function onRollOverHandler(evt:MouseEvent):void{
			var cur_ui:UIComponent = evt.currentTarget as UIComponent;
			var baseItemVo:BaseItemVO = cur_ui.data as BaseItemVO;
			if(baseItemVo){
				var p:Point = new Point(x+width,y);
				p = parent.localToGlobal(p);
				ItemToolTip.show(baseItemVo,p.x,p.y,false);
			}
		}
		private function onRollOutHandler(evt:MouseEvent):void{
			ItemToolTip.hide();
		}
		
		private function onRenewalMount(event:MouseEvent):void{
			if(this.selectItem == null || this._dataProvier == null ){
				Tips.getInstance().addTipsMsg("请选择续期的天数，再操作!");
				return ;
			}
			var selectVo:p_equip_mount_renewal = this.selectItem.data.renewal_config;
			var renewalVo:m_equip_mount_renewal_toc = _dataProvier as m_equip_mount_renewal_toc;
			var allGold:int = GlobalObjectManager.getInstance().user.attr.gold +  GlobalObjectManager.getInstance().user.attr.gold_bind;
			if(selectVo.renewal_fee > allGold){
				Tips.getInstance().addTipsMsg("你的元宝不足此次续期费用，请及时充值！");
				this.payText.visible = true;
				return ;
			}
			if (selectVo.renewal_type == 9){
				Alert.show("你是否确定对【" + renewalVo.mount.name +"】续期为<font color=\"#3be450\">永久</font>，" +
					"需要费用：<font color=\"#3be450\">" + selectVo.renewal_fee+"</font>元宝！",
					"续期提示",onConfirmYesEvent,null,"续期","取消");
			}else{
				Alert.show("你是否确定对【" + renewalVo.mount.name +"】" +
					"续期<font color=\"#3be450\">" + selectVo.renewal_days+ "</font>天，" +
					"需要费用：<font color=\"#3be450\">" + selectVo.renewal_fee+"</font>元宝！",
					"续期提示",onConfirmYesEvent,null,"续期","取消");
			}
			
		}
		private function onConfirmYesEvent():void{
			if(this.selectItem == null || this._dataProvier == null ){
				Tips.getInstance().addTipsMsg("请选择续期的天数，再操作!");
				return ;
			}
			var selectVo:p_equip_mount_renewal = this.selectItem.data.renewal_config;
			var renewalVo:m_equip_mount_renewal_toc = _dataProvier as m_equip_mount_renewal_toc;
			var allGold:int = GlobalObjectManager.getInstance().user.attr.gold +  GlobalObjectManager.getInstance().user.attr.gold_bind;
			if(selectVo.renewal_fee > allGold){
				Tips.getInstance().addTipsMsg("你的元宝不足此次续期费用，请及时充值！");
				this.payText.visible = true;
				return ;
			}
			var baseItemVo:BaseItemVO = ItemConstant.wrapperItemVO(renewalVo.mount);
			PackageModule.getInstance().doMountRenewalTos(baseItemVo as EquipVO,2,selectVo.renewal_type,renewalVo.mount_pos);
		}
		private function onMountShop(event:MouseEvent):void{
			ShopModule.getInstance().openFashionShop();
		}
		/**
		 * 点击充值 
		 * @param evt
		 * 
		 */
		private function onClickLinkHandler(evt:TextEvent):void{
			if(evt.text == "pay"){
                SmallMapModule.getInstance().openPayHandler();
			}
		}
	}
}