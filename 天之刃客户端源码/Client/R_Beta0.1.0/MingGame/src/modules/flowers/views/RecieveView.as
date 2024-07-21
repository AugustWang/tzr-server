package modules.flowers.views
{
	import com.common.GlobalObjectManager;
	import com.loaders.SourceLoader;
	import com.managers.WindowManager;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.Image;
	import com.ming.ui.controls.core.UIComponent;
	import com.ming.ui.skins.ButtonSkin;
	import com.utils.ComponentUtil;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.Timer;
	
	import modules.flowers.FlowerModule;
	import modules.flowers.FlowersTypes;
	
	import proto.line.p_flowers_give_info;
	
	public class RecieveView extends Sprite
	{
		public static var flowerBg_URL:String = "com/assets/flowers/flowers.swf"; 
		
		private var desc:TextField;
		private var closeBtn:UIComponent ;       // 关闭按钮；
		private var privChatBtn:Button;    //联系
		private var thxBtn:Button;         //谢谢
		private var kissBtn:Button;        // 回吻 
		
		private var img:Image;
		
		private var tos_id:int;
		private var sendername:String;
		private var senderSex:int;
		
		private var timer:Timer;
		private var star1:BitmapData;
		private var star2:BitmapData;
		private var star3:BitmapData;
		
		private var starArr:Array = [];
		
		// 40 75 ; 15, 100 ; 263,10 ;319 ,26 ; 303,55 ; 111 ,279  ;300,186
		private var pointArr:Array = [{x:43,y:72},{x:19,y:103},{x:266,y:15},
			{x:323,y:31},{x:303,y:55},{x:106,y:276},{x:306,y:186}];
		private var playObjArr:Array = [];
		private var sprit:Sprite;
		
		public function RecieveView()
		{
			super();
			this.mouseEnabled=false;
		}
		
		public function initView(loader:SourceLoader):void
		{
			var bmdt:BitmapData = loader.getBitmapData("flowerBg");
			var bg:Bitmap = new Bitmap(bmdt);
		
			addChildAt(bg,0);
			
			var closeBtn:UIComponent = new UIComponent();
			closeBtn.x = 293;
			closeBtn.y = 92;
			closeBtn.bgSkin = getButtonSkin("closeSkin","closeOverSkin","closeDownSkin", loader);
			closeBtn.useHandCursor = closeBtn.buttonMode = true;
			closeBtn.addEventListener(MouseEvent.CLICK,closeHandler);
			addChild(closeBtn);
			
			var tf:TextFormat = new TextFormat("宋体",14,0xFFFF00,true,null,null,null,null,"center");
			tf.leading = 8;
			
			// [xxx]被你的魅力所倾倒，送上了1（9、99、999）朵红玫瑰/蓝色妖姬，无比幸福的你要怎么感谢他呢？
			desc = ComponentUtil.createTextField("",100,138,tf,242,77,this);
			desc.wordWrap = true;
			desc.multiline = true;
			desc.selectable =false;
			
			
			//108  173
			privChatBtn = ComponentUtil.createButton("联系",133,214,71,30,this);
			privChatBtn.bgSkin = getButtonSkin("flowerSkin","flowerOverSkin","flowerDownSkin",loader);
			privChatBtn.addEventListener(MouseEvent.CLICK, onPrivatChat);
			
			thxBtn = ComponentUtil.createButton("谢谢",231,214,71,30,this);
			thxBtn.bgSkin = getButtonSkin("flowerSkin","flowerOverSkin","flowerDownSkin",loader);
			thxBtn.addEventListener(MouseEvent.CLICK, onThx);
			
			
			kissBtn = ComponentUtil.createButton("回吻",176,251,71,30,this);
			kissBtn.bgSkin = getButtonSkin("flowerSkin","flowerOverSkin","flowerDownSkin",loader);
			kissBtn.addEventListener(MouseEvent.CLICK, onKiss);
			
			sprit = new Sprite();
			sprit.mouseChildren = sprit.mouseEnabled = false;
			addChild(sprit);
			
			star1 = loader.getBitmapData("star_1");
			star2 = loader.getBitmapData("star_2");
			star3 = loader.getBitmapData("star_3");
			starArr.push(star1);
			starArr.push(star2);
			starArr.push(star3);
			
			onSetStarData();
			
			
			
		}
		
		private function onSetStarData():void
		{
			for(var i:int=0;i<pointArr.length;i++)
			{
				var star:Star = new Star();
				if(i%3==0)
				{
					star.beginIndex = -3;
					
				}else if(i%3==1)
				{
					star.beginIndex = -2;
				}
				star.x = pointArr[i].x;
				star.y = pointArr[i].y;
				star.setbitmapData(starArr);
				playObjArr.push(star);
			}
			
			timer = new Timer(350);
			timer.addEventListener(TimerEvent.TIMER,ontimer);
			timer.start();
		}
		
		private var drawId:int=0;
		private function ontimer(e:TimerEvent):void
		{
			sprit.graphics.clear();
			for(var i:int=0;i<playObjArr.length;i++)
			{
				var star:Star = playObjArr[i];
				star.draw(sprit.graphics);
				
			}
			
		}
		
		private var num:int;
		public function setData(info:p_flowers_give_info):void
		{
			tos_id = info.id;
			sendername = info.giver;
			senderSex = info.giver_sex;
			num= FlowersTypes.getNumByType(info.flowers_type);
			
			set_desc();
		}
		private function set_desc():void{
			
			if(sendername == GlobalObjectManager.getInstance().user.base.role_name)
			{
				desc.htmlText = "你被自己的魅力所倾倒，送上了"  + num +
					"朵红玫瑰，魅力值又增加了！";
				privChatBtn.visible = thxBtn.visible =kissBtn.visible = false;

			}else{
			
				desc.htmlText = "["+ sendername + "]被你的魅力所倾倒，送上了" + num + "朵红玫瑰，" +
					"无比幸福的你要怎么感谢" + withinSex() +
					"呢？";
				privChatBtn.visible = thxBtn.visible =kissBtn.visible = true;
			}
		}
		private function withinSex():String
		{
			var str:String = "他";
			if(senderSex == 2)
			{
				str = "她";
			}
			return str;
		}
		
		private function getButtonSkin(skin:String,overSkin:String,downSkin:String,loader:SourceLoader):ButtonSkin
		{
			var btnSkin:ButtonSkin = new ButtonSkin();
			btnSkin.skin = loader.getBitmapData(skin);
			btnSkin.overSkin = loader.getBitmapData(overSkin);
			btnSkin.downSkin = loader.getBitmapData(downSkin);
			
			return btnSkin;
		}
		
		/*(1)联系：自动默认与送花者私聊；
		(2)谢谢，自动回复私聊：很感谢你送的鲜花哦，希望还有机会能再次收到你送的花！^_^ 
			(3)回吻
			你的提示：你对[XXX]嘟起小嘴儿，狠狠地啵了一个，说: 谢谢你的鲜花哦，亲亲！
		对方收到提示：[XXX]嘟起小嘴儿，狠狠地啵了你一个，说: 谢谢你的鲜花哦，亲亲！
		*/

		private function onPrivatChat(e:MouseEvent):void
		{
			FlowerModule.getInstance().accept_tos(tos_id,sendername,1);
			closeHandler();
		}
		private function onThx(e:MouseEvent):void
		{
			FlowerModule.getInstance().accept_tos(tos_id,sendername,2);
			closeHandler();
		}
		private function onKiss(e:MouseEvent):void
		{
			FlowerModule.getInstance().accept_tos(tos_id,sendername,3);
			closeHandler();
		}
		
		
		private function closeHandler(e:MouseEvent=null):void
		{
			if(e)
			{
				FlowerModule.getInstance().accept_tos(tos_id,sendername,4);
			}
			if(timer)
			{
				timer.stop();
				timer.removeEventListener(TimerEvent.TIMER,ontimer);
				timer = null;
			}
			while(starArr.length>0)
			{
				var bitmpdt:BitmapData = starArr.shift() as BitmapData;
				bitmpdt = null;
			}
			
			for(var i:int=0;i<playObjArr.length;i++)
			{
				var star:Star = playObjArr[i] as Star;
				star.unload();
				star = null;
			}
			
			WindowManager.getInstance().removeWindow(this);
		}
	}
}


