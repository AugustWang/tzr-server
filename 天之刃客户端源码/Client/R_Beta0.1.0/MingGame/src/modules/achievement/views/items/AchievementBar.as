package modules.achievement.views.items
{
	import com.globals.GameConfig;
	import com.ming.ui.controls.ProgressBar;
	import com.utils.ComponentUtil;
	
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import modules.achievement.vo.AchievementTypeVO;
	
	public class AchievementBar extends Sprite
	{
		private var proName:TextField;
		private var bar:ProgressBar;
		private var achievemtnValue:TextField;
		private var _typeVO:AchievementTypeVO;
		public function AchievementBar()
		{
			super();
			var tf:TextFormat = Style.themeTextFormat;
			proName = ComponentUtil.createTextField("",0,0,tf,55,20,this);
			bar = createProcessBar(proName.x+proName.width+5,proName.y+4);
			achievemtnValue = ComponentUtil.createTextField("成就点",bar.x+bar.width+5,proName.y,tf,100,20,this);
		}
				
		public function initView(vo:AchievementTypeVO):void{
			_typeVO = vo;
			proName.text = _typeVO.name;
		}
		
		public function setAchievementInfo(awardPoint:int,curStep:int,totalStep:int):void{
			achievemtnValue.text = "成就点  "+awardPoint;
			bar.htmlText = curStep+"/"+totalStep;
			bar.value = curStep/totalStep;
		}
		
		public function get typeVO():AchievementTypeVO{
			return _typeVO;
		}
		
		override public function get width():Number{
			return 240;
		}
		
		override public function get height():Number{
			return 25;
		}
		
		private function createProcessBar(x:int,y:int,w:Number = 100):ProgressBar{
			var bar:ProgressBar = new ProgressBar();
			bar.bgSkin = Style.getSkin("processBarBg",GameConfig.ACHIEVEMENT_UI,new Rectangle(10,3,101,2));
			bar.bar = Style.getBitmap(GameConfig.ACHIEVEMENT_UI,"processBar");
			bar.x = x;
			bar.y = y;
			bar.width = w;
			bar.height = 14;
			addChild(bar);
			return bar;
		}
	}
}