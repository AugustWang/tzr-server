package modules.pet.view {
	import com.common.dragManager.DragConstant;
	import com.common.dragManager.DragItemEvent;
	import com.common.dragManager.DragItemManager;
	import com.globals.GameConfig;
	import com.ming.managers.ToolTipManager;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.MouseEvent;

	import modules.mypackage.vo.BaseItemVO;
	import modules.pet.PetDataManager;
	import modules.skill.SkillMethods;
	import modules.skill.vo.SkillVO;

	public class PetSkillsBar extends Sprite {
		private var items:Array;
		private var _dataProvider:Array;

		public function PetSkillsBar() {
			super();
			init();
			addEventListener(DragItemEvent.DRAG_THREW, dragDropHandler);
		}

		private function init():void {
			var bgData:BitmapData=Style.getUIBitmapData(GameConfig.T1_VIEWUI, "petSkillsBar");
			var bg:Bitmap=new Bitmap(bgData);
			addChild(bg);
			items=[];
			for (var i:int=0; i < 5; i++) {
				var item:PetSkillHotKeyItem=new PetSkillHotKeyItem();
				item.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
				item.addEventListener(MouseEvent.CLICK, onUseItemHandler);
				item.addEventListener(MouseEvent.ROLL_OVER, mouseOverHandler);
				item.addEventListener(MouseEvent.ROLL_OUT, mouseOutHandler);
				item.y=2;
				item.x=i * 35 + 2;
				addChild(item);
				items.push(item);
			}
		}

		private function dragDropHandler(event:DragItemEvent):void {
			var item:PetSkillHotKeyItem=event.dragTarget.parent as PetSkillHotKeyItem;
			if (item.data is SkillVO) {
			}
			item.disposeContent();
		}

		public function set dataProvider(value:Array):void {
			_dataProvider=value;
			removeAllSkillItem();
			for (var i:int=0; i < _dataProvider.length; i++) {
				setItemAt(_dataProvider[i], i);
			}
		}

		public function get dataProvider():Array {
			return this._dataProvider;
		}

		public function setItemAt(data:Object, index:int):void {
			var item:PetSkillHotKeyItem=items[index];
			if (data is SkillVO) {
				item.data=data;
			}
		}

		private function mouseDownHandler(event:MouseEvent):void {
			var item:PetSkillHotKeyItem=event.currentTarget as PetSkillHotKeyItem;
			if (item.data) {
				DragItemManager.instance.startDragItem(this, item.getContent(), DragConstant.TOOLBAR_ITEM, item.data, DragItemManager.CLONE);
			}
		}

		private function onUseItemHandler(event:MouseEvent):void {
			var item:PetSkillHotKeyItem=event.currentTarget as PetSkillHotKeyItem;
			if (item && item.data) {
				PetDataManager.selectedSkillID=SkillVO(item.data).sid;
			}
		}

		private function mouseOverHandler(event:MouseEvent):void {
			var item:PetSkillHotKeyItem=event.currentTarget as PetSkillHotKeyItem;
			if (item.data is SkillVO) {
				ToolTipManager.getInstance().show(SkillMethods.createHotKeytip(item.data as SkillVO), 50, 0, 0, "goodsToolTip");
			}
		}

		private function mouseOutHandler(event:MouseEvent):void {
			ToolTipManager.getInstance().hide();
		}

		public function removeAllSkillItem():void {
			for each (var item:PetSkillHotKeyItem in items) {
				if (item.data is SkillVO) {
					item.disposeContent();
				}
			}
		}

		public function clearContent(index:int):void {
			var item:PetSkillHotKeyItem=items[index];
			if (item) {
				item.disposeContent();
			}
		}
	}
}