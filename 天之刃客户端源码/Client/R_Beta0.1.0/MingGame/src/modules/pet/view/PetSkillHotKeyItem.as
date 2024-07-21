package modules.pet.view {
	import com.common.dragManager.DragConstant;
	
	import modules.navigation.views.HotKeyItem;
	import modules.skill.vo.SkillVO;

	public class PetSkillHotKeyItem extends HotKeyItem {
		public function PetSkillHotKeyItem() {
			super();
		}

		override public function allowAccept(data:Object, name:String):Boolean {
			if (name == DragConstant.SKILL_ITEM && (data is SkillVO) && (SkillVO(data).category == 8 || SkillVO(data).category == 9)) {
				return true;
			}
			return false;
		}
	}
}