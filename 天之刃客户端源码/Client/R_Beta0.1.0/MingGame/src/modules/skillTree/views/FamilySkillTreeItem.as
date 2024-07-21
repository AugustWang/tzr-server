package modules.skillTree.views {
	import com.ming.ui.containers.Canvas;
	import com.ming.ui.layout.LayoutUtil;
	
	import flash.display.Sprite;
	import flash.events.DataEvent;
	import flash.events.Event;
	
	import modules.family.views.items.FamilySkillItem;
	import modules.skill.SkillConstant;
	import modules.skill.SkillDataManager;

	public class FamilySkillTreeItem extends Canvas {
		public static const ITEM_CLICK:String="ITEM_CLICK";
		private var skillItems:Array;
		public var hasTree:Boolean=false;

		public function FamilySkillTreeItem() {
			this.width=400;
			this.height=298;
			this.x=-4;
			this.y=5;
		}

		public function createTree(array:Array):void {
			var sp:Sprite=new Sprite();
			array=SkillDataManager.getCategory(SkillConstant.CATEGORY_FAMILY);
			for (var i:int=0; i < array.length; i++) {
				var item:FamilySkillItem=new FamilySkillItem();
				item.addEventListener(FamilySkillItem.CLICK_EVENT, itemClickHandler);
				item.initView(FamilySkillItem.TREE);
				item.data=array[i];
				sp.addChild(item);
				SkillPanel.items[item.data.sid] = item;
			}
			LayoutUtil.layoutGrid(sp, 2, 135, 8);
			sp.x=35;
			sp.y=20;
			addChild(sp);
			hasTree=true;
		}
		
		private function itemClickHandler(event:Event):void {
		}

		public function check():void {
//			for (var i:int=0; i < skillItems.length; i++) {
//				skillItems[i].check();
//				skillItems[i].updata();
//			}
		}
	}
}