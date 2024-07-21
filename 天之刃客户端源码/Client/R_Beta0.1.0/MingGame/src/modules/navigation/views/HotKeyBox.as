package modules.navigation.views {
	import com.common.GlobalObjectManager;
	import com.common.dragManager.DragConstant;
	import com.common.dragManager.DragItemEvent;
	import com.common.dragManager.DragItemManager;
	import com.globals.GameConfig;
	import com.managers.Dispatch;
	import com.ming.managers.ToolTipManager;
	import com.utils.KeyUtil;
	
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	
	import modules.ModuleCommand;
	import modules.broadcast.views.BroadcastSelf;
	import modules.equiponekey.EquipOneKeyModule;
	import modules.equiponekey.views.items.ClothingItemVO;
	import modules.mypackage.PackageModule;
	import modules.mypackage.managers.PackManager;
	import modules.mypackage.vo.BaseItemVO;
	import modules.navigation.NavigationModule;
	import modules.pet.PetDataManager;
	import modules.roleStateG.RoleStateDateManager;
	import modules.skill.SkillConstant;
	import modules.skill.SkillDataManager;
	import modules.skill.SkillMethods;
	import modules.skill.SkillModule;
	import modules.skill.vo.SkillLevelVO;
	import modules.skill.vo.SkillVO;
	
	import proto.line.p_shortcut;

	/**
	 * 物品栏目
	 */
	public class HotKeyBox extends Sprite {
		//物品数据
		public static const HOT_KEY_COUNT:int = 9;
		private var num:Bitmap;
		private var _dataProvider:Array;

		public function HotKeyBox() {
			super();
			init();
			addEventListener(DragItemEvent.DRAG_THREW, dragDropHandler);
			KeyUtil.getInstance().addKeyHandler(onKeyDown);
		}

		public function showNumber(value:Boolean):void {
			if (value == false && contains(num)) {
				KeyUtil.getInstance().removeKeyHandler(onKeyDown);
				removeChild(num);
				num=null;
			} else {
				KeyUtil.getInstance().addKeyHandler(onKeyDown);
				addChild(num);
			}
		}

		public function setBg(bg:DisplayObject):void {
			bg.y=-4;
			bg.x=-4;
			addChildAt(bg, 0);
		}

		private function onKeyDown(event:KeyboardEvent):void {
			if (event.altKey || event.ctrlKey)
				return;
			if (event.shiftKey) {
				if (event.keyCode <= 55 && event.keyCode >= 49 && GlobalObjectManager.getInstance().user.attr.level >= 20) {
					var index:int=event.keyCode - 48;
					useClothingEquips(index);
				}
				return;
			}
			if (event.keyCode <= 57 && event.keyCode >= 48) {
				index=event.keyCode - 49;
				if (event.keyCode == 48) {
					index=9;
				}
				var item:HotKeyItem=items[index] as HotKeyItem;
				useItem(item);
			}
		}

		private function dragDropHandler(event:DragItemEvent):void {
			var item:HotKeyItem=event.dragTarget.parent as HotKeyItem;
			if (item.data is SkillVO) {
			}
			item.disposeContent();
			NavigationModule.getInstance().updateHotBar();
		}

		public function set dataProvider(value:Array):void {
			_dataProvider=value;
		}

		public function get dataProvider():Array {
			return this._dataProvider;
		}

		private var items:Array;

		private function init():void {
			items=[];
			for (var i:int=0; i < HOT_KEY_COUNT; i++) {
				var item:HotKeyItem=new HotKeyItem();
				item.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
				item.addEventListener(MouseEvent.CLICK, onUseItemHandler);
				item.addEventListener(MouseEvent.ROLL_OVER, mouseOverHandler);
				item.addEventListener(MouseEvent.ROLL_OUT, mouseOutHandler);
				item.y=0;
				item.x=i * 39;
				addChild(item);
				items.push(item);
			}
			num=Style.getBitmap(GameConfig.T1_VIEWUI,"hotkeyNumber");
			num.x=25;
			num.y = 3;
			addChild(num);
		}

		private function mouseDownHandler(event:MouseEvent):void {
			var item:HotKeyItem=event.currentTarget as HotKeyItem;
			if (item.data) {
				DragItemManager.instance.startDragItem(this, item.getContent(), DragConstant.TOOLBAR_ITEM, item.data, DragItemManager.CLONE);
			}
		}

		private function onUseItemHandler(event:MouseEvent):void {
			var item:HotKeyItem=event.currentTarget as HotKeyItem;
			useItem(item, 'mouse');
		}

		private function mouseOverHandler(event:MouseEvent):void {
			var item:HotKeyItem=event.currentTarget as HotKeyItem;
			if (item.data is SkillVO) {
				ToolTipManager.getInstance().show(SkillMethods.createHotKeytip(item.data as SkillVO), 50, 0, 0, "goodsToolTip");
			} else if (item.data is BaseItemVO) {
				ToolTipManager.getInstance().show(item.data, 50, 0, 0, "goodsToolTip");
			} else if (item.data is ClothingItemVO) {
				ToolTipManager.getInstance().show(item.data.name + "(Shift+" + item.data.suitId + ")", 50, 0, 0);
			}
		}

		private function mouseOutHandler(event:MouseEvent):void {
			ToolTipManager.getInstance().hide();
		}

		public function updateGoods(type:int):void {
			for each (var item:HotKeyItem in items) {
				var baseItemVo:BaseItemVO=item.data as BaseItemVO;
				if (baseItemVo && baseItemVo.typeId == type) {
					item.updateGoods();
				}
			}
		}

		/**
		 *清除技能ITEM
		 */
		public function removeAllSkillItem():void {
			for each (var item:HotKeyItem in items) {
				if (item.data is SkillVO) {
					item.disposeContent();
				}
			}
		}

		public function removeSkill($category:int=0, $skillid:int=0):void {
			var item:HotKeyItem
			if ($category != 0) {
				for each (item in items) {
					if (item.data is SkillVO) {
						if (item.data.category == $category) {
							item.disposeContent();
						}
					}
				}
			}
			if ($skillid != 0) {
				for each (item in items) {
					if (item.data is SkillVO) {
						if (item.data.sid == $skillid) {
							item.disposeContent();
						}
					}
				}
			}
		}

		private function useItem(item:HotKeyItem, type:String='key'):void {
			if (item.data) {
				if (item.data is BaseItemVO) {
					var itemVO:BaseItemVO=item.data as BaseItemVO;
					var baseItemVO:BaseItemVO=PackManager.getInstance().getGoodsVOByType(itemVO.typeId);
					if (baseItemVO) {
						PackageModule.getInstance().useGoods(baseItemVO);
					} else {
						BroadcastSelf.logger("背包中不存在该物品");
					}
				} else if (item.data is SkillVO) {
					SkillModule.getInstance().useSkillFormNavbar(item.data.sid, type);
				} else if (item.data is ClothingItemVO) {
					useClothingEquips(ClothingItemVO(item.data).suitId);
				}
			}
		}

		public function useClothingEquips(suitId:int):void {
			EquipOneKeyModule.getInstance().loadEquips(suitId);
		}

		public function updataSkillAutoStatus():void {
			for (var i:int=0; i < items.length; i++) {
				items[i].checkIsAutoSkill();
			}
		}

		public function getItems():Array {
			var datas:Array=[];
			for each (var item:HotKeyItem in items) {
				var vo:p_shortcut=new p_shortcut();
				if (item.data) {
					vo=new p_shortcut();
					if (item.data is SkillVO) {
						vo.type=NavigationModule.SKILL_TYPE;
						vo.id=SkillVO(item.data).sid;
					} else if (item.data is BaseItemVO) {
						vo.type=NavigationModule.ITEM_TYPE;
						vo.id=BaseItemVO(item.data).typeId;
					} else if (item.data is ClothingItemVO) {
						vo.type=NavigationModule.CLOTHING_TYPE;
						vo.id=ClothingItemVO(item.data).suitId;
						vo.name=ClothingItemVO(item.data).name;
					}
				}
				datas.push(vo);
			}
			return datas;
		}

		public function getDatas():Array {
			var datas:Array=[];
			for each (var item:HotKeyItem in items) {
				datas.push(item.data);
			}
			return datas;
		}

		public function setItems(datas:Array):void {
			for (var i:int=0; i < HOT_KEY_COUNT; i++) {
				var data:Object=datas[i];
				if (data == null) {
					continue;
				}
				if (data is SkillVO) {
					var skill:SkillVO=data as SkillVO;
					if (skill.category == PetDataManager.petTroopIn || skill.category == PetDataManager.petTroopOut)
						continue;
				}
				setItemAt(data, i)
			}
		}
		
		public function getItem(index:int):HotKeyItem{
			return items[index];
		}
		
		public function setItemAt(data:Object, index:int):void {
			var item:HotKeyItem=items[index];
			if (data is SkillVO) {
				item.data=data;
			} else if (data is ClothingItemVO) {
				item.data=data;
			} else {
				item.setItemVO(data);
			}
		}

		public function clearContent(index:int):void {
			var item:HotKeyItem=items[index];
			if (item) {
				item.disposeContent();
			}
		}
	}
}