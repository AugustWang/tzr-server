package modules.pet.view {
	import com.components.alert.Alert;
	import com.globals.GameConfig;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.Image;
	import com.net.connection.Connection;
	import com.utils.ComponentUtil;
	import com.utils.HtmlUtil;

	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;

	import modules.pet.config.PetConfig;
	import modules.pet.config.PetType;

	import proto.line.m_pet_egg_adopt_tos;

	public class PetHatchItem extends Sprite {
		private var img:Image;
		private var nameTxt:TextField;
		private var attackTypeTxt:TextField;
		private var takeTxt:TextField;
		private var zzTxt:TextField;
		public var opBtn:Button;

		private var _data:Object;
		private var _type:int;

		public function PetHatchItem() {
			super();
			img=new Image;
			img.width=img.height=64;
			addChild(img);
			var tf:TextFormat=new TextFormat(null, null, 0xAFE0EE, null, null, null, null, null, "center");
			nameTxt=ComponentUtil.createTextField("", 65, 26, tf, 86, 22, this);
			attackTypeTxt=ComponentUtil.createTextField("", 160, 26, tf, 70, 22, this);
			takeTxt=ComponentUtil.createTextField("", 230, 26, tf, 90, 22, this);
			zzTxt=ComponentUtil.createTextField("", 320, 26, tf, 100, 22, this);
			opBtn=ComponentUtil.createButton("领养", 430, 24, 60, 30, this);
			opBtn.addEventListener(MouseEvent.CLICK, onClick);
		}

		private function onClick(e:MouseEvent):void {
			var pet:PetType=PetConfig.getPetConfig(int(_data));
			if(pet.maxAptitude < 2500)
			{
				Alert.show("确认领养" + pet.msg + "（最高资质" + pet.maxAptitude + "）?\n最强神宠资质2500，资质影响宠物战斗属性", "领养宠物", confirmAdopt, null, "确认领养", "继续刷新");
			}
			else
			{
				confirmAdopt();
			}
		}

		private function confirmAdopt():void {
			var vo:m_pet_egg_adopt_tos=new m_pet_egg_adopt_tos;
			vo.type_id=int(_data);
			vo.goods_id=PetHatchPanel.eggID;
			Connection.getInstance().sendMessage(vo);
		}

		public function set data(value:Object):void {
			_data=value;
			var vo:PetType=PetConfig.getPetConfig(int(_data));
			if (vo) {
				img.source=GameConfig.ROOT_URL + "com/assets/pet/body/" + vo.skinId + ".png";
				nameTxt.htmlText=vo.msg;
				if (vo.maxAptitude == 2500) {
//					nameTxt.htmlText=HtmlUtil.font(vo.msg, "#00ff00");
					attackTypeTxt.htmlText=vo.attackType == "in" ? HtmlUtil.font("内攻", "#00ff00") : HtmlUtil.font("外攻", "#00ff00");
					takeTxt.htmlText=HtmlUtil.font((vo.takeLevel + "级可带"), "#00ff00");
					zzTxt.htmlText=HtmlUtil.font(vo.maxAptitude.toString(), "#00ff00");
				} else {
					attackTypeTxt.htmlText=vo.attackType == "in" ? "内攻" : "外攻";
					takeTxt.htmlText=vo.takeLevel + "级可带";
					zzTxt.htmlText=vo.maxAptitude.toString();
				}
			}
		}

		public function get data():Object {
			return _data;
		}

	}
}