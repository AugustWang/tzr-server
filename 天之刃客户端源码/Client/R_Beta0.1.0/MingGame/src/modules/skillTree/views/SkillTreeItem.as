package modules.skillTree.views
{
	import com.globals.GameConfig;
	import com.ming.ui.controls.core.UIComponent;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	
	import modules.skill.vo.SkillVO;
	import modules.skillTree.views.items.SkillItem;

	public class SkillTreeItem extends UIComponent
	{
		public var hasTree:Boolean = false;
		/**
		 *
		 * 技能组件池 
		 */		
		private var skillItems:Array = [];
		
		private var bg:Bitmap;
		/**
		 *
		 * 构造函数 
		 * 
		 */
		public function SkillTreeItem()
		{
			this.y = 2;
			this.x = 2;
			this.width = 320;
			this.height = 312;
			
		}
		
		public function createBg($url:String):void{
			bg = Style.getBitmap(GameConfig.SKILL_UI,$url);
			bg.y =20;
			bg.x =2;
			addChild(bg);
		}
		
		/**
		 *
		 * 创建技能树 
		 * @param skillArray
		 * @param skillPosition
		 * 
		 */		
		public function createTree(skillArray:Array):void{
			if(skillArray == null)return;
			for(var i:int=0;i<skillArray.length;i++){
				var skillItemVO:SkillVO = skillArray[i] as SkillVO;
				var skillItem:SkillItem = createSkillItem(skillItemVO);
				skillItem.x = skillItemVO.tree_x+2;
				skillItem.y = skillItemVO.tree_y+21;
				skillItems.push(skillItem);
				addChild(skillItem);
			}
			hasTree = true;
		}
		/**
		 *
		 * 生成技能组件 
		 * @param $skillVO
		 * @return 
		 * 
		 */		
		private function createSkillItem($skillVO:SkillVO):SkillItem{
			var skillItem:SkillItem = new SkillItem();
			skillItem.skillVO = $skillVO;
			return skillItem;
		}
		
		public function check():void{
			for(var i:int = 0; i < skillItems.length; i++){
				skillItems[i].check();
				skillItems[i].updata();
			}
		}
	}
}