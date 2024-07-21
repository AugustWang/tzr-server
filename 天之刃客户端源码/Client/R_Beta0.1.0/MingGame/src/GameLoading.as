package {
	import com.globals.GameConfig;
	import com.globals.GameParameters;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObjectContainer;
	import flash.display.Loader;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.TextEvent;
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.filters.GlowFilter;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.utils.Timer;
	import flash.utils.setTimeout;

	[SWF(width="1000", height="545", backgroundColor="0x0", frameRate="30")]
	public class GameLoading extends Sprite {
		private var tips:Array=["打怪时，按Z或者右上角的“挂”可以使用自动挂机功能。", "等级≥20级且加入门派后，可接拉镖任务，获得海量银子。", "等级≥25级，找师徒管理员李梦阳领取导师称号，即可收徒。", "按E即可打开天工炉界面。", "16级后完成五行任务即可获得五行属性。", "按O打开社会界面，拜师、收徒、加好友、进门派。", "想要充满个性的称号吗？加入门派吧！", "没时间上线？太平村的武林宗师张三丰可以帮你离线挂机。", "邀请你的朋友，一起来玩《天之刃》。"];
		private var offsetX:int;
		private var offsetY:int;
		private var bgLayer:Sprite;
		private var welcome:Bitmap;
		private var bar:Shape;
		private var barAll:Shape;
		private var itemText:TextField; // 单个项目的进度
		private var itemPercentText:TextField; // 总得进度
		private var barBitmapData:BitmapData;
		private var totalText:TextField;
		//////////////
		private var warnTxt:TextField;
		private var freshText:TextField;
		private var tipTxt:TextField;
		private var f8:TextField;
		/////////////////
		private var itemValue:Number=0;
		private var itemTotal:Number=10;
		private var totalValue:Number=0;
		private var totalTotal:Number=10;
		/////////倒计时//////////
		private var time:int=24;
		private var leftTimeText:TextField;
		private var leftTimer:Timer;

		private var bar_bg1:Bitmap;
		private var bar_bg2:Bitmap;
		private var f8BMP:Bitmap;

		public function GameLoading() {
			super();
			this.addEventListener(Event.ADDED_TO_STAGE, onAddStage);
		}

		[Embed(source="assets/bar.png")]
		private var barImage:Class;

		[Embed(source="assets/bar_bg.png")]
		private var barBgImage:Class;

//		[Embed(source="assets/f8.png")]
//		private var f8Image:Class;

		private static var instance:GameLoading;

		public static function getInstance():GameLoading {
			if (instance == null) {
				instance=new GameLoading();
			}
			return instance;
		}

		private function onStageResize(e:Event):void {
			if (stage) {
				bar_bg1.x=(stage.stageWidth - bar_bg1.width) >> 1;
				bar_bg2.x=bar_bg1.x;
				bar.x=bar_bg1.x + 32;
				barAll.x=bar_bg1.x + 31;
				itemText.x=bar.x;
				totalText.x=bar.x;
				leftTimeText.x=bar_bg1.x + 392;
				if (welcome) {
					welcome.x=(stage.stageWidth - welcome.width) >> 1 + offsetX;
				}
				if (warnTxt && freshText && tipTxt) {
					warnTxt.x=(stage.stageWidth - warnTxt.width) >> 1;
					warnTxt.y=stage.stageHeight - 24;
					freshText.x=(stage.stageWidth - freshText.width) >> 1;
					freshText.y=warnTxt.y - 22;
					tipTxt.x=(stage.stageWidth - tipTxt.width) >> 1;
					tipTxt.y=freshText.y - 22;
//					f8.x=(stage.stageWidth - f8.width) >> 1;
//					f8.y=tipTxt.y - 30;
//					f8BMP.x=f8.x + 20;
//					f8BMP.y=f8.y - 8;
				}
			}
		}

		private function onRemove(e:Event):void {
			this.removeEventListener(Event.RESIZE, onStageResize);
		}

		private function onAddStage(e:Event):void {
			this.removeEventListener(Event.ADDED_TO_STAGE, onAddStage);
			this.addEventListener(Event.REMOVED_FROM_STAGE, onRemove);
			this.stage.addEventListener(Event.RESIZE, onStageResize);
			bgLayer=new Sprite;
			addChild(bgLayer);
			bar=new Shape;
			bar.y=434;
			barAll=new Shape;
			barAll.y=458;
			addChild(bar);
			addChild(barAll);
			var tf:TextFormat=new TextFormat(null, 12, 0xffffff, null, null, null, null, null, "left");
			itemText=createTextField("", 326, 414, 300, 20, tf, this);
			itemText.filters=[new GlowFilter(0x000000, 1, 2, 2, 20)];
			totalText=createTextField("", 326, 474, 300, 20, tf, this);
			leftTimeText=createTextField("剩余时间：20秒", 600, 474, 150, 20, tf, this);

			var barBmp:Bitmap=new barImage;
			barBitmapData=barBmp.bitmapData;

			var barBg:Bitmap=new barBgImage;
			var data:BitmapData=barBg.bitmapData;
			bar_bg1=new Bitmap;
			bar_bg2=new Bitmap;
			bar_bg1.bitmapData=data;
			bar_bg2.bitmapData=data;
			bar_bg1.x=(stage.stageWidth - bar_bg1.width) >> 1;
			bar_bg1.y=428;
			bar_bg2.x=bar_bg1.x;
			bar_bg2.y=452;
			bgLayer.addChild(bar_bg1);
			bgLayer.addChild(bar_bg2);
			bar.x=bar_bg1.x + 21;
			barAll.x=bar_bg1.x + 21;
			itemText.x=totalText.x=bar.x;
			leftTimeText.x=totalText.x + 350;
			setTimeout(doTxts, 60);
			leftTimer=new Timer(1000);
			leftTimer.addEventListener(TimerEvent.TIMER, onTimer);
			leftTimer.start();

			(this.parent as Main).loadCreateAndGame();
		}

		public function loadWelcomeBG():void {
			var proxyName:String=GameParameters.getInstance().proxyName;
			var url:String;
			if (proxyName == "baidu") {
				url=GameConfig.ROOT_URL + "assets/loading/daMingBg.jpg";
			} else {
				url=GameConfig.ROOT_URL + "assets/loading/bg.jpg";
			}
			var welcome:Loader=new Loader(); //背景图
			welcome.contentLoaderInfo.addEventListener(Event.COMPLETE, welcomeOK);
			welcome.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			welcome.load(new URLRequest(url));
		}

		private function onTimer(e:TimerEvent):void {
			if (time > 5) {
				time--;
				leftTimeText.text="剩余时间：" + time + "秒";
			} else {
				leftTimer.stop();
				leftTimer.removeEventListener(TimerEvent.TIMER, onTimer);
				leftTimer=null;
			}
		}

		private function doTxts():void {
			var tf2:TextFormat=new TextFormat(null, 12, 0xffffff, null, null, null, null, null, "center");
			var warn:String='<p align="center"><FONT COLOR="#ffffff">抵制不良游戏  拒绝盗版游戏  注意自我保护  谨防受骗上当  适度游戏益脑  沉迷游戏伤身  合理安排时间  享受健康生活</FONT></p>';
			warnTxt=createTextField(warn, 0, stage.stageHeight - 24, stage.stageWidth, 20, tf2, this);
			warnTxt.autoSize=TextFieldAutoSize.CENTER;
			var str:String='<p><FONT COLOR="#ffff66">如果你是第一次来到天之刃，加载文件会比较大，如果加载不成功，</FONT><A href="event:reload"><FONT COLOR="#0099CC"><u>请点此重新加载</u></FONT></A></p>';
			freshText=createTextField(str, 0, warnTxt.y - 22, stage.stageWidth, 20, tf2, this);
			freshText.autoSize=TextFieldAutoSize.CENTER;
			var tip:String=tips[Math.floor(Math.random() * tips.length)];
			tipTxt=createTextField(tip, 0, freshText.y - 22, stage.stageWidth, 20, tf2, this);
			tipTxt.autoSize=TextFieldAutoSize.CENTER;
			freshText.addEventListener(TextEvent.LINK, onLinkHandler);
//			var tf3:TextFormat=new TextFormat(null, 12, 0xffff00, true, null, null, null, null, "center");
//			f8=createTextField("进入游戏后按                开启网页游戏客户端时代！！", 0, tipTxt.y - 30, stage.stageWidth, 20, tf3, this);
//			f8.autoSize=TextFieldAutoSize.CENTER;
//			f8BMP=new f8Image;
//			f8BMP.x=f8.x + 86;
//			f8BMP.y=f8.y - 8;
//			addChild(f8BMP);
		}

		private function createTextField(txt:String, px:Number, py:Number, tw:Number, th:Number, tf:TextFormat, parent:DisplayObjectContainer):TextField {
			var t:TextField=new TextField;
			t.defaultTextFormat=tf;
			t.selectable=false;
			t.width=tw;
			t.height=th;
			t.x=px;
			t.y=py;
			t.htmlText=txt;
			parent.addChild(t);
			return t;
		}

		private var maskLogo:Shape;

		private function welcomeOK(e:Event):void {
			welcome=e.target.content;
			welcome.x=(stage.stageWidth - welcome.width) >> 1 + offsetX; //170;
			welcome.y=40; //(stage.height - b.height) >> 1 + offsetY; //40;
			bgLayer.addChildAt(welcome, 0);
			var proxyName:String=GameParameters.getInstance().proxyName;
			if (proxyName == "baidu") {
				maskLogo=new Shape;
				maskLogo.x=welcome.x;
				maskLogo.y=welcome.y;
				maskLogo.graphics.beginFill(0);
				maskLogo.graphics.drawRect(0, 0, 278, 158);
				maskLogo.graphics.endFill();
				setTimeout(doMaskLogo, 1000);
			}
		}

		private function doMaskLogo():void {
			if (welcome && welcome.parent) {
				welcome.parent.addChild(maskLogo);
			}
		}

		private function barControl(theBar:Shape, percent:Number):void {
			theBar.graphics.clear();
			theBar.graphics.beginBitmapFill(barBitmapData);
			theBar.graphics.drawRect(0, 0, int(percent * barBitmapData.width), 10);
			theBar.graphics.endFill();
		}

		private function onIOError(event:IOErrorEvent):void {
			trace("加载游戏出错请重试：" + event.text);
		}

		public function setItemPercent(str:String, value:Number, total:Number):void {
			itemValue=value;
			itemTotal=total;
			var percent:Number=value / total;
			barControl(bar, percent);
			itemText.text=str + int(percent * 100) + "%";
		}

		public function setTotalPercent(value:Number, total:Number):void {
			totalValue=value;
			totalTotal=total;
			var percent:Number=value / total;
			barControl(barAll, value / total);
			totalText.text="总进度：" + int(percent * 100) + "%";
		}

		public function set itemLabel(value:String):void {
			itemText.text=value;
		}

		private function set totalLabel(value:String):void {
			totalText.text=value;
		}

		private function onLinkHandler(event:TextEvent):void {
			ExternalInterface.call('reloadPage');
		}

		public function dispose():void {
			if (parent) {
				parent.removeChild(this);
			}
			if (leftTimer) {
				leftTimer.stop();
				leftTimer.removeEventListener(TimerEvent.TIMER, onTimer);
				leftTimer=null;
			}
			instance=null;
		}
	}
}