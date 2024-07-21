package modules.pet.view {
	import com.common.GlobalObjectManager;
	import com.globals.GameConfig;
	import com.ming.managers.ToolTipManager;
	import com.ming.ui.controls.Image;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import modules.pet.PetSkillVO;
	import modules.skill.vo.SkillLevelVO;

	public class PetSkillLearnItem extends Sprite {
		private var _vo:PetSkillVO;
		public var img:Image;
		private var closeBG:Bitmap;

		public function PetSkillLearnItem() {
			super();
			addChild(Style.getBitmap(GameConfig.T1_VIEWUI,"packItemBg"));
			this.mouseChildren=false;
		}


		private function createImage():void {
			if (img == null) {
				img=new Image();
				img.x=img.y=4;
				img.width=img.height=32;
				addChild(img);
				this.addEventListener(MouseEvent.ROLL_OVER, showSkillTip);
				this.addEventListener(MouseEvent.ROLL_OUT, hideTip);
			}
		}

		public function cover(b:Boolean):void {
			if (b) {
				if (closeBG == null) {
					closeBG=Style.getBitmap(GameConfig.T1_VIEWUI,"closeSkill");
					closeBG.x=closeBG.y=4;
				}
				addChild(closeBG);
			} else {
				if (closeBG && closeBG.parent) {
					closeBG.parent.removeChild(closeBG);
				}
			}
		}

		private function showSkillTip(e:MouseEvent):void {
			var item:PetSkillLearnItem=e.currentTarget as PetSkillLearnItem;
			if (item.data != null) {
				var p:Point=new Point(this.x + this.width, this.y);
				p=parent.localToGlobal(p);
				ToolTipManager.getInstance().show(item.createHtml(), 200, p.x, p.y, "SkillTreeTip");
			}
		}

		private function hideTip(e:MouseEvent):void {
			ToolTipManager.getInstance().hide();
		}

		public function set data(value:PetSkillVO):void {
			_vo=value;
			if (value != null) {
				createImage();
				img.source=GameConfig.ROOT_URL + "com/assets/skills/" + _vo.skill.sid + ".png";
			} else {
				disposeImage();
			}
		}

		public function get data():PetSkillVO {
			return _vo;
		}

		public function disposeImage():void {
			if (img && contains(img)) {
				removeChild(img);
			}
			img=null;
			_vo=null;
			this.removeEventListener(MouseEvent.ROLL_OVER, showSkillTip);
			this.removeEventListener(MouseEvent.ROLL_OUT, hideTip);
		}

		public function createHtml():String {
			var s:String='';
			if (_vo != null) {
				var sl:SkillLevelVO=_vo.skill.levels[0];
				s=s.concat("<font color='#FFFFFF'size='14'><b>" + _vo.skill.name + "</b></font>\n");
				s=s.concat("<font color='#FFFFFF'>冷却时间:" + sl.cooldown * 0.001 + "秒</font>\n");
				s=s.concat("<font color='#f2c802'>" + sl.discription + "</font>");
			}
			return s;
		}
	}
}