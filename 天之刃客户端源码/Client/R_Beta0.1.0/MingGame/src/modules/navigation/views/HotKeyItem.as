package modules.navigation.views {
	import com.common.dragManager.DragConstant;
	import com.common.dragManager.IDragItem;
	import com.components.cooling.CoolingManager;
	import com.components.cooling.ICooling;
	import com.globals.GameConfig;
	import com.ming.ui.controls.Image;
	import com.ming.ui.style.StyleManager;
	import com.scene.sceneUnit.baseUnit.things.thing.Thing;
	import com.utils.GraphicsUtil;
	
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.filters.ColorMatrixFilter;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import modules.mypackage.managers.PackManager;
	import modules.mypackage.vo.BaseItemVO;
	import modules.mypackage.vo.GeneralVO;
	import modules.navigation.NavigationModule;
	import modules.skill.vo.SkillVO;

	public class HotKeyItem extends Sprite implements IDragItem, ICooling {
		private var count:TextField;

		public function HotKeyItem() {
			super();
			GraphicsUtil.drawRoundRect(graphics,0,0,36,36,0,0xff,0,0);
			count=new TextField();
			count.width=34;
			count.height=20;
			count.y=20;
			count.autoSize="right";
			count.mouseEnabled=false;
			count.selectable=false;
			var tf:TextFormat=StyleManager.textFormat;
			tf.size=11;
			count.defaultTextFormat=tf;
			count.filters=[new GlowFilter(0x00000)]
			count.textColor=0xffffff;
			CoolingManager.getInstance().registerObserver(this);
			this.mouseChildren=false;
		}

		private var _data:Object;
		private var img:Image;

		private function createContent():void {
			if (img == null) {
				img=new Image();
				img.x = 2;
				img.y = 3;
				addChild(img);
			}
			img.source=data.path;
			count.text="";
			filters=[];
			addChild(count);
			CoolingManager.getInstance().stopByCoolingID(coolingID);
			CoolingManager.getInstance().updateCooling(this);
		}

		public function checkIsAutoSkill():void {
			if (data is SkillVO) {
				if (data.isSelectAuto) {
					if (!getChildByName("skillAuto")) {
						var effect:Thing=new Thing();
						effect.name="skillAuto";
						effect.load(GameConfig.ROOT_URL + 'com/ui/other/skillAuto.swf');
						effect.play(6, true);
						effect.x=-1;
						effect.y=-2;
						addChild(effect);
						return;
					}
					return;
				}
			}
			if (getChildByName("skillAuto")) {
				effect=getChildByName("skillAuto") as Thing;
				effect.unload();
			}
		}

		public function set data(value:Object):void {
			this._data=value;
			if (value) {
				createContent();
			}

		}

		public function get data():Object {
			return this._data;
		}

		/**
		 * 设置内容
		 */
		public function setContent(_content:*, _data:*):void {
			img=_content;
			this._data=_data;
			addChild(_content);
			addChild(count);
			filters=[];
			CoolingManager.getInstance().stopByCoolingID(coolingID);
			CoolingManager.getInstance().updateCooling(this);
			checkIsAutoSkill();
		}

		/**
		 * 获取项目内容
		 */
		public function getContent():* {
			return img;
		}

		/**
		 * 销毁项目内容( 例如：容器里面的装备图片)
		 */
		public function disposeContent():void {
			removeChild(img);
			removeChild(count);
			if (getChildByName("skillAuto")) {
				var effect:Thing=getChildByName("skillAuto") as Thing;
				effect.unload();
			}
			img=null;
			_data=null;
			filters=[];
			CoolingManager.getInstance().stopByCoolingID(coolingID);
		}

		public function allowAccept(data:Object, name:String):Boolean {
			if (name == DragConstant.SPLIT_ITEM || name == DragConstant.PACKAGE_ITEM || name == DragConstant.CLOTHING_ITEM ||
				name == DragConstant.SKILL_ITEM || name == DragConstant.EQUIP_ITEM || name == DragConstant.TOOLBAR_ITEM) {
				return true;
			}
			return false;
		}

		public function getName():String {
			var generalVO:GeneralVO=data as GeneralVO;
			if (generalVO && generalVO.effectType != 0) {
				return generalVO.effectType.toString();
			} else if (generalVO) {
				return "";
			}
			return data ? data.typeId.toString() : "";
		}

		private var _coolingID:int;

		public function get coolingID():int {
			return _coolingID;
		}

		public function set coolingID(value:int):void {
			this._coolingID=value;
		}

		private var _count:int;

		public function setCount(num:int):void {
			_count=num;
			if (num == 0 && data is BaseItemVO) {
				filters=[new ColorMatrixFilter([1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0])];
			} else {
				filters=[];
			}
			count.text=num > 1 ? num.toString() : "";

		}

		public function getCount():int {
			return _count;
		}

		public var goods:Array;

		public function updateGoods():void {
			goods=PackManager.getInstance().getGoodsByType(data.typeId);
			var totalCount:int=0;
			for each (var baseItemVO:BaseItemVO in goods) {
				totalCount+=baseItemVO.num;
			}
			setCount(totalCount);
		}

		public function setItemVO(itemVO:Object):void {
			data=itemVO;
			updateGoods();
		}

		public function dragDrop(dragData:Object, dragTarget:DisplayObject, itemName:String):void {
			var tempData:Object=dragData;
			if (itemName == DragConstant.PACKAGE_ITEM) {
				PackManager.getInstance().updateGoods(tempData.bagid, tempData.position, tempData as BaseItemVO);
				setItemVO(tempData);
				NavigationModule.getInstance().updateHotBar();
			} else if (itemName == DragConstant.SPLIT_ITEM) {
				var itemVO:BaseItemVO=PackManager.getInstance().getItemById(tempData.oid);
				PackManager.getInstance().updateGoods(itemVO.bagid, itemVO.position, itemVO);
				setItemVO(itemVO);
				NavigationModule.getInstance().updateHotBar();
			} else if (itemName == DragConstant.TOOLBAR_ITEM) {
				var item:HotKeyItem=dragTarget.parent as HotKeyItem;
				tempData=item.data;
				var tempContent:*=item.getContent();
				var tempCount:int=item.getCount();
				var tempGoods:Array=item.goods;
				item.disposeContent();
				if (data) {
					item.setContent(getContent(), data);
					item.goods=goods;
					item.setCount(getCount());
				}
				goods=tempGoods;
				setContent(tempContent, tempData);
				setCount(tempCount);
				NavigationModule.getInstance().updateHotBar();
			} else if (itemName == DragConstant.SKILL_ITEM) {
				var skillVo:SkillVO=dragData as SkillVO;
				data=skillVo;
				NavigationModule.getInstance().updateHotBar();
				setCount(0)
			} else if (itemName == DragConstant.CLOTHING_ITEM) {
				data=dragData;
				NavigationModule.getInstance().updateHotBar();
				setCount(0)
			}
		}
	}
}