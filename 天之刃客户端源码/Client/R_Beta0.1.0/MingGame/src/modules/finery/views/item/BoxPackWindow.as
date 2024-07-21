package modules.finery.views.item {
	import com.components.BasePanel;
	import com.events.ParamEvent;
	import com.ming.events.TabNavigationEvent;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.CheckBox;
	import com.ming.ui.controls.TabBar;
	import com.ming.ui.controls.TimerButton;
	import com.ming.ui.controls.core.UIComponent;
	import com.ming.ui.style.StyleManager;
	import com.utils.ComponentUtil;

	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;

	import modules.mypackage.ItemConstant;
	import modules.mypackage.PackageModule;
	import modules.mypackage.managers.PackManager;
	import modules.mypackage.views.IPack;
	import modules.mypackage.views.PackTile;
	import modules.mypackage.views.PackageItem;
	import modules.mypackage.vo.BaseItemVO;
	import modules.finery.StoveConstant;

	import proto.common.p_goods;

	/**
	 * 额外背包窗口
	 */
	public class BoxPackWindow extends BasePanel implements IPack {
		public static var SELECT_INDEX:int=0;
		public static const ALL:int=0;
		public static const EQUIP:int=1;
		public static const STONE:int=2;
		public static const MATERIAL:int=3;
		public static const NORMAL:int=4;

		public var rows:int=42;
		public var columns:int=7;
		public static const HPADDING:int=0;
		public static const VPADDING:int=0;
		private var tile:BoxPackTile;
		private var goods:Array;
		private var getBtn:TimerButton;
		private var clearBtn:TimerButton;
		private var tabBar:TabBar;

		public function BoxPackWindow(index:int, rows:int, columns:int) {
			this.rows=rows;
			this.columns=columns;
			super("BoxPackWindow");
		}

		override protected function init():void {
			title="临时仓库";
			width=40 * columns+20;
			height=40 * rows + 110;
			addContentBG(28,5,35);
			
			var bgBorder:UIComponent=ComponentUtil.createUIComponent(7, 37, this.width - 14, this.height - 108);
			bgBorder.mouseEnabled=bgBorder.mouseChildren=false;
			Style.setBorderSkin(bgBorder);
			addChild(bgBorder);

			tabBar=new TabBar();
			addChild(tabBar);
			tabBar.x=20;
			tabBar.y = 5;
			tabBar.addItem("全部", 60, 30);
			tabBar.addItem("装备", 60, 30);
			tabBar.addItem("灵石", 60, 30);
			tabBar.addItem("材料", 60, 30);
			tabBar.addItem("普通", 60, 30);
			tabBar.addEventListener(TabNavigationEvent.SELECT_TAB_CHANGED, onSelectTabChanged);

			tile=new BoxPackTile(0, rows, columns);
			tile.owner=this;
			tile.x=2;
			bgBorder.addChild(tile);

			getBtn=new TimerButton();
			this.addChild(getBtn);
			getBtn.label="全部拾取";
			getBtn.x=this.width - 185;
			getBtn.y=this.height - 68;
			getBtn.width=80;
			getBtn.height=24;
			getBtn.repeatCount=5;
			getBtn.addEventListener(MouseEvent.CLICK, onGetBtnClick);
			//getBtn.enabled = false;

			clearBtn=new TimerButton();
			this.addChild(clearBtn);
			clearBtn.label="整理仓库";
			clearBtn.x=this.width - 95;
			clearBtn.y=getBtn.y;
			clearBtn.width=80;
			clearBtn.height=25;
			clearBtn.repeatCount=5;
			clearBtn.addEventListener(MouseEvent.CLICK, onClearBtnClick);

			var tipFormat:TextFormat=new TextFormat("Tahoma", 12, 0x00ff00, true, null, null, null, null, TextFormatAlign.
				LEFT);
			var tip:TextField=ComponentUtil.createTextField("提示：双击物品可拾取到背包", 10, getBtn.y + 3, tipFormat, 200, NaN, this);
			tip.filters=Style.textBlackFilter;
			tip.mouseEnabled = false;

			getGoods();
		}

		/**
		 *-define(BOX_PAGE_TYPE_0,0).%%全部
		   -define(BOX_PAGE_TYPE_1,1).%%普通
		   -define(BOX_PAGE_TYPE_2,2).%%灵石
		   -define(BOX_PAGE_TYPE_3,3).%%装备
		   -define(BOX_PAGE_TYPE_4,4).%%材料
		 */
		private var key:Array=[0, 3, 2, 4, 1];

		private function onSelectTabChanged(event:TabNavigationEvent):void {
			if (!isClear) { //整理需要index重置 特殊处理index改变
				addDataLoading();
				var e:ParamEvent=new ParamEvent(StoveConstant.BOX_CLASS_CLICK);
				e.data={type: key[event.index]};
				dispatchEvent(e);
			} else {
				isClear=false;
			}
			SELECT_INDEX=event.index;
		}

		public var isAll:Boolean=false;

		private function onGetBtnClick(event:MouseEvent):void {
			addDataLoading();
			var e:ParamEvent=new ParamEvent(StoveConstant.BOX_ALL_GET_CLICK);
			var items:Array=tile.getTileItems();
			var baseItemVO:BaseItemVO;
			var good_ids:Array=[];
			for (var i:int=0; i < items.length; i++) {
				baseItemVO=items[i].data;
				if (baseItemVO) {
					good_ids.push(baseItemVO.oid);
				}
			}
			e.data={ids: good_ids};
			dispatchEvent(e);
			isAll=true;
		}

		public function removeAllGetEffect():void {
			removeDataLoading();
			isAll=false;
		}

		private var isClear:Boolean=false;

		private function onClearBtnClick(event:MouseEvent):void {
			isClear=true;
			tabBar.selectIndex=0;
			addDataLoading();
			var e:ParamEvent=new ParamEvent(StoveConstant.BOX_MERGE_CLICK);
			dispatchEvent(e);
		}

		private function getGoods():void {
			addDataLoading();
			//PackageModule.getInstance().getGoods(packId);
		}

		public function setGoods(items:Array):void {
			removeDataLoading();
			var p:p_goods;
			var baseItemVO:BaseItemVO;
			var itemVOs:Array=[];
			for (var i:int=0; i < items.length; i++) {
				p=items[i] as p_goods;

				baseItemVO=PackageModule.getInstance().getBaseItemVO(p);
				itemVOs.push(baseItemVO);
			}
			tile.setGoods(itemVOs);
		}

		public function checkType(p:p_goods):Boolean {
			if (SELECT_INDEX == ALL) {
				return true;
			}
			switch (p.type) {
				case ItemConstant.TYPE_GENERAL:
					var baseitem:BaseItemVO=PackageModule.getInstance().getBaseItemVO(p);
					if (SELECT_INDEX == NORMAL && baseitem.kind != 4) {
						return true;
					}
					if (SELECT_INDEX == MATERIAL && baseitem.kind == 4) {
						return true;
					}
					break;
				case ItemConstant.TYPE_EQUIP:
					if (SELECT_INDEX == EQUIP) {
						return true;
					}
					break;
				case ItemConstant.TYPE_STONE:
					if (SELECT_INDEX == STONE) {
						return true;
					}
					break;
			}
			return false;
		}

		public function removeGoods(oid:int):void {
			var items:Array=tile.getTileItems();
			var baseItemVO:BaseItemVO;
			for (var i:int=0; i < items.length; i++) {
				baseItemVO=items[i].data;
				if (baseItemVO && baseItemVO.oid == oid) {
					tile.updateGoods(i, null);
					return;
				}
			}
		}

		public function addGoods(item:p_goods):void {
			if (!checkType(item)) {
				return;
			}
			var baseItemVO:BaseItemVO;
			var packItem:PackageItem;
			for (var i:int=0; i < tile.getTileItems().length; i++) {
				packItem=tile.getTileItems()[i]
				if (packItem.data == null) {
					baseItemVO=PackageModule.getInstance().getBaseItemVO(item);
					tile.updateGoods(i, baseItemVO);
					return;
				}
			}
		}

		public function updateGoods(pos:int, itemvo:BaseItemVO):void {
			tile.updateGoods(pos, itemvo);
		}

		public function setLock(pos:int, lock:Boolean):void {
			tile.setLock(pos, lock);
		}

		override public function dispose():void {
			tile.dispose();
		}
	}
}