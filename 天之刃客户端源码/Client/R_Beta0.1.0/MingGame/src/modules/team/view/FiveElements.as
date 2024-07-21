package modules.team.view
{
	import com.common.GlobalObjectManager;
	import com.ming.managers.ToolTipManager;
	import com.utils.HtmlUtil;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;

	public class FiveElements extends Sprite
	{
		private var _type:int;
		private var _txt:TextField;
		private var five:DisplayObject;
		private var colorBg:Sprite;
		private var addAttck:Boolean;
		private var addHpmp:Boolean;

		private var neiAtt:int;
		private var waiAtt:int;
		private var hpLim:int;
		private var mpLim:int;
		private var attackTip:String;
		private var hpmpTip:String;
		
		public function FiveElements()
		{
			super();
			init();
		}

		public function init():void
		{
			five=Style.getViewBg("factionBg");
			five.x=-five.width / 2 ;
			five.y=-five.height / 2;
			colorBg=new Sprite;
			colorBg.x=five.x;
			colorBg.y=five.y;
			_txt=new TextField;
			_txt.mouseEnabled=false;
			_txt.autoSize=TextFieldAutoSize.CENTER;
			_txt.filters=[new GlowFilter(0x000000, 1, 2, 2, 200)];
			_txt.textColor=0xc;
			addChild(five);
			addChild(colorBg);
			addChild(_txt);
			reFresh(0,0,0,0);
			this.addEventListener(MouseEvent.MOUSE_OVER, showTip);
			this.addEventListener(MouseEvent.MOUSE_OUT, hideTip);
		}

		public function setup():void
		{
			_type=GlobalObjectManager.getInstance().user.attr.five_ele_attr;
			this.visible=true;
			switch (_type)
			{
				case 1:
					_txt.text="金"
					break;
				case 2:
					_txt.text="木"
					break;
				case 3:
					_txt.text="水"
					break;
				case 4:
					_txt.text="火"
					break;
				case 5:
					_txt.text="土"
					break;
				default:
					_txt.text="";
					this.visible=false;
					break;
			}
			_txt.autoSize=TextFieldAutoSize.CENTER;
			_txt.filters=[new GlowFilter(0xfff799, 1, 2, 2, 200)];
			_txt.x=-_txt.width / 2;
			_txt.y=-_txt.height / 2;
			_txt.autoSize=TextFieldAutoSize.CENTER;
			_txt.filters=[new GlowFilter(0xfff799, 1, 2, 2, 200)];
			reFresh(0, 0, 0, 0);
//			this.x=10;
//			this.y=-10;
		}

		/**
		 *
		 * @param hp 加红
		 * @param mp 加蓝
		 * @param ft 外功
		 * @param mt 内功
		 *
		 */
		public function reFresh(hp:int, mp:int, ft:int, mt:int):void
		{
			colorBg.graphics.clear();
			if (hp > 0)
			{
				colorBg.graphics.beginFill(0xfff799);
				colorBg.graphics.drawRoundRect(2, 9, 17, 9,1);
				colorBg.graphics.endFill();
				addHpmp=true;
			}else{
				addHpmp=false;
			}
			if (ft > 0)
			{
				colorBg.graphics.beginFill(0xfff799);
				colorBg.graphics.drawRoundRect(2, 2, 17, 9,1);
				colorBg.graphics.endFill();
				addAttck=true;
			}else{
				addAttck=false;
			}
				

		}

		private function showTip(e:MouseEvent):void
		{
			makeTip();
			if(addAttck){
				attackTip=HtmlUtil.font(attackTip, "#ffffff");
			}else{
				attackTip=HtmlUtil.font(attackTip,"#999999");
			}
			if(addHpmp){
				hpmpTip=HtmlUtil.font(hpmpTip,"#ffffff");
			}else{
				hpmpTip=HtmlUtil.font(hpmpTip,"#999999");
			}
			ToolTipManager.getInstance().show(attackTip+hpmpTip);
		}

		private function hideTip(e:MouseEvent):void
		{
			ToolTipManager.getInstance().hide();
		}
		private function makeAddPoints():void{
			var level:int=GlobalObjectManager.getInstance().user.attr.level;
			if(level>=16&&level<=49){
		 	    neiAtt=30;
			    waiAtt=30;
			    mpLim=50;
			    hpLim=500;
			}else if(level>=50&&level<=79){
				neiAtt=50;
				waiAtt=50;
				mpLim=100;
				hpLim=1000;
			}else if(level>=80&&level<=99){
				neiAtt=100;
				waiAtt=100;
				mpLim=120;
				hpLim=1500;
			}else if(level>=100&&level<=160){
				neiAtt=150;
				waiAtt=150;
				mpLim=150;
				hpLim=3000;
			}
		}
		private function makeTip():void{
			makeAddPoints();
			var tip:String;
			var five:int=GlobalObjectManager.getInstance().user.attr.five_ele_attr;
			switch(five){
				case 1:
					attackTip="队员火属性，可提升内力攻击"+neiAtt+"、外力攻击"+waiAtt;
					hpmpTip="\n队员土属性，可提升内力值上限"+mpLim+"、生命值上限"+hpLim;
					break;
				case 2:
					attackTip="队员金属性，可提升内力攻击"+neiAtt+"、外力攻击"+waiAtt;
					hpmpTip="\n队员水属性，可提升内力值上限"+mpLim+"、生命值上限"+hpLim;
					break;
				case 3:
					attackTip="队员土属性，可提升内力攻击"+neiAtt+"、外力攻击"+waiAtt;
					hpmpTip="\n队员金属性，可提升内力值上限"+mpLim+"、生命值上限"+hpLim;
					break;
				case 4:
					attackTip="队员水属性，可提升内力攻击"+neiAtt+"、外力攻击"+waiAtt;
					hpmpTip="\n队员木属性，可提升内力值上限"+mpLim+"、生命值上限"+hpLim;
					break;
				case 5:
					attackTip="队员木属性，可提升内力攻击"+neiAtt+"、外力攻击"+waiAtt;
					hpmpTip="\n队员火属性，可提升内力值上限"+mpLim+"、生命值上限"+hpLim;
					break;
			}
		}
	}
}