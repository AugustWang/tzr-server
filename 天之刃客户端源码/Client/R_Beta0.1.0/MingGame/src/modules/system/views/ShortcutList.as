package modules.system.views {
	import com.globals.GameConfig;
	import com.ming.ui.controls.core.UIComponent;
	import com.utils.ComponentUtil;
	import com.utils.HtmlUtil;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;

	public class ShortcutList extends Sprite {
		public function ShortcutList() {
			super();
//			var border:Sprite=Style.getBlackSprite(531, 275);
//			border.x=5;
//			border.y=3;
//			border.mouseEnabled=false;
//			addChild(border);
			
			y = 6;
			var border:UIComponent = ComponentUtil.createUIComponent(0,0,541,330);
			Style.setBorderSkin(border);
			addChild(border);
			
			var html:String="";

			var tf:TextFormat=Style.textFormat;
			tf.font="Tahoma";
			var tf2:TextFormat=new TextFormat("Tahoma", null, 0xffff00, true, null, null, null, null, "right");
			var txt1:TextField=ComponentUtil.createTextField("", 10, 5, tf, 120, 280, this);
			txt1.wordWrap=true;
			txt1.multiline=true;
			var hot1:TextField=ComponentUtil.createTextField("", 55, 5, tf2, 66, 280, this);
			hot1.wordWrap=true;
			hot1.multiline=true;

			var txt2:TextField=ComponentUtil.createTextField("", 135, 5, tf, 120, 280, this);
			txt2.wordWrap=true;
			txt2.multiline=true;
			var hot2:TextField=ComponentUtil.createTextField("", 187, 5, tf2, 66, 280, this);
			hot2.wordWrap=true;
			hot2.multiline=true;

			var txt3:TextField=ComponentUtil.createTextField("", 270, 5, tf, 120, 280, this);
			txt3.wordWrap=true;
			txt3.multiline=true;
			var hot3:TextField=ComponentUtil.createTextField("", 319, 5, tf2, 66, 280, this);
			hot3.wordWrap=true;
			hot3.multiline=true;
			var txt4:TextField=ComponentUtil.createTextField("", 400, 5, tf, 120, 280, this);
			txt4.wordWrap=true;
			txt4.multiline=true;
			var hot4:TextField=ComponentUtil.createTextField("", 451, 5, tf2, 66, 280, this);
			hot4.wordWrap=true;
			hot4.multiline=true;
			html+=wrapperLine("角色");
			html+=wrapperLine("技能");
			html+=wrapperLine("背包");
			html+=wrapperLine("宠物");
			html+=wrapperLine("好友");
			html+=wrapperLine("门派 ");
			html+=wrapperLine("天工炉 ");
			html+=wrapperLine("任务");
			html+=wrapperLine("成就");
			html+=wrapperLine("商店");
			txt1.htmlText=html;
			html="";
			html+=wrapperLine("C");
			html+=wrapperLine("V");
			html+=wrapperLine("B");
			html+=wrapperLine("X");
			html+=wrapperLine("R");
			html+=wrapperLine("O");
			html+=wrapperLine("E");
			html+=wrapperLine("Q");
			html+=wrapperLine("H");
			html+=wrapperLine("S");

//			hot1.htmlText=HtmlUtil.bold(HtmlUtil.font(html, "#ffff00"));
			hot1.htmlText=html;
			html="";
			html+=wrapperLine("地图");
			html+=wrapperLine("信件 ");
			html+=wrapperLine("观察");
			html+=wrapperLine("摆摊");
			html+=wrapperLine("打坐");
			html+=wrapperLine("坐骑");
			html+=wrapperLine("跟随");
			html+=wrapperLine("自动打怪");
			html+=wrapperLine("召唤宠物");
			html+=wrapperLine("攻击选中目标");

			txt2.htmlText=html;
			html="";
			html+=wrapperLine("M");
			html+=wrapperLine("L");
			html+=wrapperLine("J");
			html+=wrapperLine("K");
			html+=wrapperLine("D");
			html+=wrapperLine("T");
			html+=wrapperLine("G");
			html+=wrapperLine("Z");
			html+=wrapperLine("W");
			html+=wrapperLine("A");

//			hot2.htmlText=HtmlUtil.bold(HtmlUtil.font(html, "#ffff00"));
			hot2.htmlText=html;
			html="";
			html+=wrapperLine("查看附近玩家");
			html+=wrapperLine("隐藏其他玩家");
			html+=wrapperLine("选择攻击目标");
			html+=wrapperLine("拾取");
			html+=wrapperLine("自定义");
			html+=wrapperLine("系统设置");
			html+=wrapperLine("关闭界面");
			html+=wrapperLine("密聊");
			html+=wrapperLine("聊天输入");
			html+=wrapperLine("聊天频道");

			txt3.htmlText=html;
			html="";
			html+=wrapperLine("F");
			html+=wrapperLine("P");
			html+=wrapperLine("~");
			html+=wrapperLine("空格键");
			html+=wrapperLine("1~0");
			html+=wrapperLine("ESC");
			html+=wrapperLine("ESC");
			html+=wrapperLine("/+人名");
			html+=wrapperLine("Enter");
			html+=wrapperLine("← →");

//			hot3.htmlText=HtmlUtil.bold(HtmlUtil.font(html, "#ffff00"));
			hot3.htmlText=html;
			html="";
			html+=wrapperLine("聊天历史");
			txt4.htmlText=html;
			html="";
			html+=wrapperLine("↑↓");
//			hot4.htmlText=HtmlUtil.bold(HtmlUtil.font(html, "#ffff00"));
			hot4.htmlText=html;
			for (var i:int=1; i < 11; i++) {
				var line:Bitmap = Style.getBitmap(GameConfig.T1_VIEWUI,"hightLightLine");
				line.x=5;
				line.y=i * (23 + 5);
				line.width=520;
				addChild(line);
			}

			createVline(132);
			createVline(264); //308
			createVline(396); //525
			createVline(528);
		}

		private function createVline(x:Number):void {
			var v:Bitmap = Style.getBitmap(GameConfig.T1_VIEWUI,"hightLightLine");
			v.width=300;
			v.rotation=90;
			v.y=2;
			v.x=x;
			addChild(v);
		}

		private function wrapperLine(title:String):String {
			return title + "\n\n";
		}

	}
}