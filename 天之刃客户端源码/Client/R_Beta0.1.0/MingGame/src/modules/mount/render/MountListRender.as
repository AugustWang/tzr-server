package modules.mount.render {
	import com.common.GlobalObjectManager;
	import com.globals.GameConfig;
	import com.ming.ui.controls.Image;
	import com.ming.ui.controls.core.UIComponent;
	import com.ming.ui.skins.Skin;
	import com.ming.ui.style.StyleManager;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import modules.mypackage.views.GoodsImage;
	import modules.mypackage.vo.EquipVO;
	
	import proto.common.p_goods;

	public class MountListRender extends UIComponent {
		//图片
		private var bgImage:GoodsImage;
		//名称
		private var nameTxt:TextField;
		//当前正在使用
		private var currentUseNameTxt:TextField;
		//下划线
		private var line:Bitmap;

		public function MountListRender() {
			initUI();
		}

		private function initUI():void {
			var bg:Bitmap = Style.getBitmap(GameConfig.T1_VIEWUI,"packItemBg");
			bg.x=4;
			addChild(bg);
			bgImage=new GoodsImage();
			bgImage.x = 7;
			bgImage.y = 3;
			addChild(bgImage);

			var tf:TextFormat=StyleManager.textFormat;
			var skin:Skin=StyleManager.listItemSkin;
			if (skin) {
				bgSkin=skin;
			}
			nameTxt=new TextField();
			nameTxt.selectable = false;
			nameTxt.defaultTextFormat=tf;
			nameTxt.x=41;
			nameTxt.y=8;
			addChild(nameTxt);

			addEventListener(Event.ADDED, onAdded);

		}

		private function onAdded(event:Event):void {
			width=170;
			height=40;
			if (line == null) {
				line=Style.getBitmap(GameConfig.T1_VIEWUI,"hightLightLine");
				line.y=40;
				line.width=170;
				addChild(line);
			}
		}

		public override function set data(value:Object):void {
			var equipVO:EquipVO=value as EquipVO;
			super.data=equipVO;
			nameTxt.text=equipVO.name;
			bgImage.setImageContent(equipVO, equipVO.path);
			nameTxt.defaultTextFormat.color=equipVO.color;

			updateUI();
		}

		private function inPacketage():Boolean {
			//查看当前的坐骑是不是正在使用的坐骑
			var length:int=GlobalObjectManager.getInstance().user.attr.equips.length;
			for (var i:int=0; i < length; i++) {
				if (GlobalObjectManager.getInstance().user.attr.equips[i].loadposition == 15) {
					//当前正在使用的坐骑
					var currentMount:p_goods=GlobalObjectManager.getInstance().user.attr.equips[i];
					var equipVO:EquipVO=new EquipVO();
					equipVO.copy(currentMount);
					if (equipVO.oid == super.data.oid) {
						return true;
					}
				}
			}
			return false;
		}

		private function updateUI():void {
			var flag:Boolean=inPacketage();
			if (flag == true) {
				if (currentUseNameTxt == null) {
					currentUseNameTxt=new TextField();
					currentUseNameTxt.selectable = false;
					currentUseNameTxt.x=105;
					currentUseNameTxt.y=8;
					addChild(currentUseNameTxt);
				}
				currentUseNameTxt.htmlText="<font color='#FFFFFF'>(当前使用)</font>";
			} else {
				if (currentUseNameTxt != null) {
					currentUseNameTxt.text="";
				}
			}
		}
	}
}