package modules.system.views {
	import com.common.GlobalObjectManager;
	import com.common.dragManager.DragConstant;
	import com.common.dragManager.DragItem;
	import com.common.dragManager.IDragItem;
	import com.globals.GameConfig;
	import com.ming.ui.controls.Image;
	
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.display.Sprite;
	
	import modules.skill.SkillConstant;
	import modules.skill.vo.SkillVO;

	public class AutoSkillItem extends Sprite implements IDragItem {
		public function AutoSkillItem() {
			super();
			addChild(Style.getBitmap(GameConfig.T1_VIEWUI,"packItemBg"));
			this.mouseChildren=false;
		}

		private var _data:Object;
		private var img:Image;

		private function createContent():void {
			if (img == null) {
				img=new Image();
				img.x=img.y=4;
				addChild(img);
			}
			img.source=data.path;
		}

		public function allowAccept(itemVO:Object, name:String):Boolean {
			if ((itemVO is SkillVO || name == DragConstant.SKILL_ITEM) && SkillVO(itemVO).category != SkillConstant.CATEGORY_FAMILY && SkillVO(itemVO).
				category != SkillConstant.CATEGORY_LIFE && SkillVO(itemVO).category != SkillConstant.CATEGORY_PET1 && SkillVO(itemVO).
				category != SkillConstant.CATEGORY_PET2) {
				return true;
			}
			return false;
		}

		public function set data(value:Object):void {
			disposeContent();
			this._data=value;
			if (value) {
				//GlobalObjectManager.instance.skills.push(value);
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
			//GlobalObjectManager.instance.skills.splice(GlobalObjectManager.instance.skills.indexOf(_data));
			if (img && contains(img)) {
				removeChild(img);
			}
			img=null;
			_data=null;
		}

		public function dragDrop(dragData:Object, dragTarget:DisplayObject, itemName:String):void {
			if (itemName == DragConstant.SETTINGSKILL_ITEM) {
				var skillItem:AutoSkillItem=AutoSkillItem(dragTarget.parent);
				skillItem.disposeContent();
				var tempData:Object=data;
				var tempTarget:DisplayObject=img;
				if (tempData && tempTarget) {
					skillItem.setContent(tempTarget, tempData);
				}
				setContent(dragTarget, dragData);
			} else {
				data=dragData;
			}
		}
	}
}