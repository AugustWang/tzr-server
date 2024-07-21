package modules.mount.views
{
	import com.common.GlobalObjectManager;
	import com.components.BasePanel;
	import com.events.WindowEvent;
	import com.globals.GameConfig;
	import com.loaders.CommonLocator;
	import com.managers.WindowManager;
	import com.ming.ui.controls.Button;
	import com.utils.ComponentUtil;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import modules.mypackage.ItemConstant;
	import modules.mypackage.PackageModule;
	import modules.mypackage.managers.PackManager;
	import modules.mypackage.vo.BaseItemVO;
	import modules.roleStateG.views.details.RoleMyMountView;
	import modules.shop.ShopModule;
	
	import proto.line.m_equip_mount_changecolor_toc;
	
	public class MountUpgradePanel extends BasePanel
	{
		public static const MOUNT_UPGRADE_CLEAN:String = "MOUNT_UPGRADE_CLEAN";
		public static const MOUNT_UPGRADE_UPDATA:String = "MOUNT_UPGRADE_UPDATA";
		public static const MOUNT_TOKEN_CHANHE:String = "MOUNT_TOKEN_CHANHE";
		public static const MOUNT_UPGRADE_CARD:int = 11600006; //坐骑提速牌
		
		private var xml:XML;
		private var upgradeBtn:Button;
		private var count:TextField;
		private var descTxt:TextField;
		private var payText:TextField
		private var item:MountUpgradeItem;
		private var glm:GlobalObjectManager = GlobalObjectManager.getInstance();
		public function MountUpgradePanel()
		{
			super();
			setupUI();
		}
		
		private function setupUI():void{
			xml = CommonLocator.getXML(CommonLocator.MOUNT_UPGRADE);
			this.width = 280;
			this.height = 386;
			this.title = "提升坐骑速度";
			
			var ui:Sprite=new Sprite();
			ui.x=10;
			this.addChild(ui);
			ui.width = 260;
			ui.height =320;
			
			var textFormat:TextFormat = new TextFormat('宋体',12);
			textFormat.leading = 4;
			
			var note:String = "坐骑的体质不同，行使速度也不同，你可以为坐骑提升速度。请把坐骑放到格子内："
			var noteTxt:TextField = ComponentUtil.createTextField(note,30,25,null,230,64,this);
			noteTxt.defaultTextFormat = textFormat;
			noteTxt.wordWrap = true;
			
			upgradeBtn = ComponentUtil.createButton("提升速度",94,168,80,25,this);
			upgradeBtn.addEventListener(MouseEvent.CLICK,onUpgradeBtnClick);
			
			var closeBtn:Button = ComponentUtil.createButton("关闭",195,322,60,25,this);
			closeBtn.addEventListener(MouseEvent.CLICK,closeBtnHandler);
			
			count =  ComponentUtil.createTextField(note,30,15,null,230,64,this);;
			count.x = 35;
			count.y = 196;
			count.text = "坐骑提速牌:"+ PackManager.getInstance().getGooodsCountByEffectType(ItemConstant.EFFECT_MOUNT_UPGRADE) + "个";
			addChild(count);
			
			payText = ComponentUtil.createTextField("", 150, 196, null, 100, 22); 
			payText.htmlText = "<font color='#00FF00'><a href='event:buy'><u>购买坐骑提速牌</u></a></font>";
			payText.mouseEnabled = true;
			payText.addEventListener(MouseEvent.CLICK, onBuyBtnClick);
			addChild(payText);
			
			item = new MountUpgradeItem();
			item.updataCallBack = updata;
			item.x = 97;
			item.y = 82;
			item.name = RoleMyMountView.MOUNT_POS.toString();
			addChild(item);
			
			descTxt = new TextField();
			descTxt.x = 32;
			descTxt.y = 236;
			descTxt.width = 230;
			descTxt.height = 50;
			descTxt.mouseEnabled = false;
			descTxt.defaultTextFormat = textFormat;
			addChild(descTxt);
			
			var line:Bitmap = Style.getBitmap(GameConfig.T1_VIEWUI,"hightLightLine");
			line.mouseChildren = line.mouseEnabled = false;
			line.x = 14;
			line.y = 220;
			line.width = 222;
			addChild(line);
			
			addEventListener(WindowEvent.CLOSEED,onCloseed);
			
			updata();
		}
		
		

		private function onBuyBtnClick( evt:MouseEvent ):void {
			//坐骑商店
			ShopModule.getInstance().requestShopItem(20116, MOUNT_UPGRADE_CARD, new Point(stage.mouseX-178, stage.mouseY-90));
		}
		
		override public function open():void{
			super.open()
			WindowManager.getInstance().centerWindow(this);
			this.x = (GlobalObjectManager.GAME_WIDTH * 0.5 - this.width * 0.5) >> 0;
			this.y = (GlobalObjectManager.GAME_HEIGHT * 0.5 - this.height * 0.5) >> 0;
			if(PackManager.getInstance().isPopUp(PackManager.PACK_1)){
				BasePanel(PackManager.getInstance().getPackWindow(PackManager.PACK_1)).x = (this.x + this.width);
				BasePanel(PackManager.getInstance().getPackWindow(PackManager.PACK_1)).y = this.y;
			}else{
				PackageModule.getInstance().openPackWindow(new Point(this.x + this.width,this.y));
			}
			updata();
		}
		
		public function closeBtnHandler(event:MouseEvent):void{
			closeWindow();
		}
		
		private function onCloseed(event:WindowEvent):void{
			if(item.data){
				var equipVo:BaseItemVO = item.data as BaseItemVO;
				PackManager.getInstance().lockGoods(equipVo,false);
				equipVo.state = 0;
				PackManager.getInstance().updateGoods(equipVo.bagid,equipVo.position,equipVo);
			}
			item.disposeContent();
			MountUpgradeItem.mountID = 0;
			//dispose();
		}
		
		public function clean():void{
			MountUpgradeItem.mountID = 0;
			item.disposeContent();
			updata();
		}
		
		private function onUpgradeBtnClick(event:MouseEvent):void{
			upgradeBtn.enabled = PackageModule.getInstance().useTSP(item.data.oid);
		}
		
		public function updataBack(vo:m_equip_mount_changecolor_toc):void{
			upgradeBtn.enabled = true;
			if( vo.mount.id != 0 ){
				var baseItemVO:BaseItemVO=PackageModule.getInstance().getBaseItemVO(vo.mount);
				item.disposeContent();
				item.data = baseItemVO;
			}
			updata();
		}
		
		public function updata():void{
			if(count)
				count.text = "坐骑提速牌:"+ PackManager.getInstance().getGoodsNumByTypeId(11600006) + "个";
			
			var descTemp:String;
			if( !item.data ){
				upgradeBtn.enabled = false;
				descTemp = "<font color='#ff0000'>当前无坐骑</font>";
			}else{
				descTemp = "<font color='"+ ItemConstant.COLOR_VALUES[item.data.color] + "'>" + item.data.name +"：</font>";
				descTemp += "\n<font color='#AFE1EC'>当前速度：</font><font color='#CEE444'>+"+ item.data.add_property.move_speed + "</font>";
				if( item.data.color == ItemConstant.COLOR_ORANGE ){
					descTemp += "\n<font color='#ff0000'>该坐骑为最高等级，无法提升。</font>";
					upgradeBtn.enabled = false;
				}else{
					upgradeBtn.enabled = true;
					var speed:String = xml.item.(@id == item.data.typeId).level[item.data.color].@data
					descTemp += "\n<font color='#AFE1EC'>下一级速度：</font><font color='#CEE444'>+"+ speed + "</font>";
				}
			}
			descTxt.htmlText = descTemp;
		}
	}
}