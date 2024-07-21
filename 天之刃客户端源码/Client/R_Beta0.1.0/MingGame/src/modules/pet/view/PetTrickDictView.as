package modules.pet.view {
	import com.components.BasePanel;
	import com.ming.events.ItemEvent;
	import com.ming.ui.constants.ScrollDirection;
	import com.ming.ui.containers.List;
	import com.ming.ui.containers.VScrollText;
	import com.scene.sceneUnit.Pet;
	import com.utils.ComponentUtil;
	import com.utils.HtmlUtil;

	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;

	import modules.pet.config.PetConfig;

	public class PetTrickDictView extends BasePanel {
		private var list:List;
		private var txt:VScrollText;
		private var itemTitle:TextField;
		private var contentTxt:TextField;

		public function PetTrickDictView(key:String=null) {
			super(key);
			title="神技介绍";
		}

		override protected function init():void {
			this.width=560;
			this.height=355;
			var bg1:Sprite=Style.getBlackSprite(182, 312);
			bg1.x=10;
			bg1.y=4;
			list=new List;
			list.bgSkin=null;
			list.x=list.y=1;
			list.width=180;
			list.height=310;
			list.itemHeight=34;
			list.itemRenderer=PetTrickDictItem;
			list.addEventListener(ItemEvent.ITEM_CHANGE, onItemChange);
			bg1.addChild(list);
			var bg2:Sprite=Style.getBlackSprite(356, 312);
			bg2.x=bg1.x + bg1.width + 1;
			bg2.y=4;
			var tf:TextFormat=new TextFormat(null, 14, 0xF6F5CD, null, null, null, null, null, "left");
			var tf2:TextFormat=new TextFormat(null, 12, 0xF6F5CD, null, null, null, null, null, "left");
			txt=new VScrollText;
			txt.direction=ScrollDirection.RIGHT;
			txt.x=4;
			txt.y=1;
			txt.width=349;
			txt.height=308;
			bg2.addChild(txt);
//			itemTitle=ComponentUtil.createTextField("", 0, 4, tf, 330, 24, bg2);
//			contentTxt=ComponentUtil.createTextField("", 0, 40, tf2, 330, 24, bg2);
			addChild(bg1);
			addChild(bg2);
			updateList();
		}

		private function updateList():void {
			var arr30:Array=PetConfig.getTrickSkillByLevel(30);
			var arr50:Array=PetConfig.getTrickSkillByLevel(50);
			var arr75:Array=PetConfig.getTrickSkillByLevel(75);
			var arr100:Array=PetConfig.getTrickSkillByLevel(100);
			var all:Array=arr30.concat(arr50).concat(arr75).concat(arr100);
			list.dataProvider=all;
			list.selectedIndex=0;
		}

		private function onItemChange(e:ItemEvent):void {
			var obj:Object=e.selectItem;
			var skillName:String=obj.name;
			var content:String=HtmlUtil.font(HtmlUtil.bold(skillName), "#AFE1EC", 14) + "\n";
			for (var i:int=1; i <= 10; i++) {
				content+="\n" + HtmlUtil.font("等级" + i + ":", "#F6F5CD") + "\n" + HtmlUtil.font(obj[i], "#F6F5CD") + "\n";
			}
//			content=obj[1] + obj[2] + obj[3] + obj[4] + obj[5] + obj[6] + obj[7] + obj[8] + obj[9] + obj[10];
			txt.htmlText=content;
		}
	}
}