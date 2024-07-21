package modules.mount.views {
	import com.components.BasePanel;
	import com.managers.WindowManager;
	import com.ming.ui.controls.Button;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	import modules.broadcast.views.Tips;
	import modules.mypackage.ItemConstant;
	import modules.mypackage.PackageModule;
	import modules.mypackage.views.GoodsImage;
	import modules.mypackage.vo.BaseItemVO;
	import modules.mypackage.vo.EquipVO;
	import modules.shop.ShopModule;
	
	import proto.common.p_goods;

	/**
	 * 坐骑过期提示
	 * @author Owner
	 * 
	 */	
	public class MountOverDateView extends BasePanel {
		
		//坐骑图片
		private var mountImage:GoodsImage;
		//坐骑提示text
		private var mountText:TextField;
		//续期按钮
		private var exBTN:Button;
		//更换坐骑
		private var reBTN:Button;
		//记录坐标
		private var pointX:int;
		private var pointY:int;
		//当前过期的坐骑信息
		private var mountData:p_goods;
		
		public function MountOverDateView() {
			super();
		}
		
		override protected function init():void {
			title = "坐骑过期提示"
			width = 400;
			height  = 200;
			
			addContentBG(5);
			
			var imageBg:Sprite = Style.getViewBg("extraPackBg");
			imageBg.x=186;
			imageBg.y=10;
			addChild(imageBg);
			mountImage = new GoodsImage();
			imageBg.addChild(mountImage);
			mountImage.x=2;
			mountImage.y=2;
			
			mountText = new TextField();
			mountText.x = 20;
			mountText.y = 60;
			mountText.width = 400;
			mountText.htmlText = "<font color='#FFFFFF'>你当前使用的坐骑【追风马】已过期，续期后才能继续使用该坐骑。</font>";
			addChild(mountText);
			
			var toopTip:TextField = new TextField();
			toopTip.x = 20;
			toopTip.y = 90;
			toopTip.width = 400;
			toopTip.htmlText = "<font color='#FF9000'>提示：收集【普通腰牌】*5,可到门派长老处兑换永久【枣红马】。</font>";
			addChild(toopTip);
			
			exBTN = new Button();
			exBTN.label = "续期";
			exBTN.x = 70;
			exBTN.height = 25;
			exBTN.width = 95;
			exBTN.y = 120;
			addChild(exBTN);
			exBTN.addEventListener(MouseEvent.CLICK,onRenewalMount);
			
			reBTN = new Button();
			reBTN.label = "更换坐骑";
			reBTN.x = 235;
			reBTN.height = 25;
			reBTN.width = 95;
			reBTN.y = 120;
			addChild(reBTN);
			reBTN.addEventListener(MouseEvent.CLICK, onOpenShop);
		}
		
		private function showData(mountData:p_goods):void
		{
			this.mountData = mountData;
			var equipVO:EquipVO = new EquipVO();
			equipVO.copy(mountData);
			mountImage.setImageContent(equipVO,equipVO.path);
			mountText.htmlText = "<font color='#FFFFFF'>你当前使用的坐骑【"+mountData.name+"】已过期，续期后才能继续使用该坐骑。</font>";
		}
		
		private function onOpenShop(event:MouseEvent):void
		{
			ShopModule.getInstance().openFashionShop();
		}
		
		/**
		 * 坐骑续期 
		 * @param event
		 * 
		 */		
		private function onRenewalMount(event:MouseEvent):void{
			if(mountData == null){
				Tips.getInstance().addTipsMsg("当前没有装备坐骑，不需要续期！");
				return;
			}
			var baseItemVo:BaseItemVO = ItemConstant.wrapperItemVO(mountData);
			if(baseItemVo is EquipVO){
				PackageModule.getInstance().doMountRenewalTos(baseItemVo as EquipVO,1,0,2);
			}else{
				Tips.getInstance().addTipsMsg("坐骑物品类型出错，打开续期界面失败！");
				return;
			}
		}		
		public function openWin(mountData:p_goods):void
		{
			super.open();
			WindowManager.getInstance().centerWindow(this);
			showData(mountData);
		}
		
	}
}