package modules.scene.other {
	import com.components.BasePanel;
	import com.events.ParamEvent;
	import com.globals.GameConfig;
	import com.ming.events.CloseEvent;
	import com.ming.ui.controls.Image;
	import com.utils.ComponentUtil;

	import flash.display.Sprite;
	import flash.events.TextEvent;
	import flash.text.StyleSheet;
	import flash.text.TextField;

	public class ServerNPC_Panel extends BasePanel {
		public static const EVENT_ENTER_TAOFA:String="EVENT_ENTER_TAOFA";
		private var txt:TextField;
		private var lookDetail:TextField;
		private var detail:TextField;
		private var img2:Image;
		private var _npc_id:int;
		private var _type_id:int;

		public function ServerNPC_Panel(key:String=null) {
			super(key);
			this.title="讨伐敌营";
			this.width=266;
			this.height=330;
			initView();
		}

		private function initView():void {
			var blackBorder:Sprite=new Sprite();
			blackBorder.x=6;
			addChild(blackBorder);
			var bgtxt:TextField=ComponentUtil.createTextField("", 30, 15, null, 200, 50, this);
			bgtxt.multiline=true;
			bgtxt.wordWrap=true;
			bgtxt.text="敌军欲与我等争夺天下，请各位义士速速前往讨伐敌营！";
			var css:StyleSheet=new StyleSheet();
			css.parseCSS("font {color: #00ff00} a {color: #00ff00} a:hover {color: #ff0000}");
			txt=ComponentUtil.createTextField("", 30, 82, null, 220, 22, this);
			txt.mouseEnabled=true;
			txt.styleSheet=css;
			txt.htmlText="<a href='event:myEvent'><u>讨伐敌营</u></a>";
			txt.addEventListener(TextEvent.LINK, onLink);
			addChild(txt);
			var img:Image=new Image;
			img.source=GameConfig.ROOT_URL + "assets/gongneng.png";
			img.x=20;
			img.y=86;
			img.width=12;
			img.height=12;
			addChild(img);
			img2=new Image;
			img2.source=GameConfig.ROOT_URL + "assets/gongneng.png";
			img2.x=20;
			img2.y=108;
			img2.width=12;
			img2.height=12;
			addChild(img2);
			lookDetail=ComponentUtil.createTextField("", 30, 104, null, 200, 50, this);
			lookDetail.mouseEnabled=true;
			lookDetail.styleSheet=css;
			lookDetail.htmlText="<a href='event:myEvent'><u>副本介绍</u></a>";
			lookDetail.addEventListener(TextEvent.LINK, onLookDetail);
			detail=ComponentUtil.createTextField("", 30, 104, null, 210, 94, this);
			detail.multiline=true;
			detail.wordWrap=true;
			detail.text="副本介绍：\n      副本定时开启，25级以上的豪杰，组成3人以上队伍即可进入。\n      完成副本可获得大量经验、材料、宝石奖励。";
			detail.visible=false;
			this.addEventListener(CloseEvent.CLOSE, onClose);
		}

		public function setup(npc_id:int, type_id:int):void {
			_npc_id=npc_id;
			_type_id=type_id;
		}

		private function onLookDetail(e:TextEvent):void {
			lookDetail.visible=false;
			detail.visible=true;
			img2.visible=false;
		}

		private function onLink(e:TextEvent):void {
			var uie:ParamEvent=new ParamEvent(EVENT_ENTER_TAOFA, [_npc_id, _type_id]);
			this.dispatchEvent(uie);
		}

		public function onClose(e:CloseEvent=null):void {
			if (this.parent != null) {
				this.parent.removeChild(this);
				lookDetail.visible=true;
				detail.visible=false;
				img2.visible=true;
			}
		}
	}
}