package modules.present.views
{
	import com.common.GlobalObjectManager;
	import com.components.components.DragUIComponent;
	import com.globals.GameConfig;
	import com.loaders.SourceLoader;
	import com.managers.WindowManager;
	import com.ming.ui.controls.Button;
	import com.ming.ui.skins.Skin;
	import com.utils.ComponentUtil;
	import com.utils.PathUtil;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.text.TextField;
	
	import modules.broadcast.views.BroadcastSelf;
	
	import proto.common.p_present_info;

	public class PresentWindow extends DragUIComponent
	{
		private var config:XML;
		private var content:TextField;
		private var lvTxt:TextField;
		private var getRewardBtn:Button;
		private var source:SourceLoader;
		
		public function PresentWindow()
		{
			initData();
		}
		
		private function initData():void{
			//config = CommonLocator.getXML(CommonLocator.PRESENT);
		}
		
		public function initView( s:SourceLoader ):void{
			this.width = 410;
			this.height = 255;
			this.x = (1002 - this.width)/2;
			this.y = (GlobalObjectManager.GAME_HEIGHT  - this.height)/2;
			this.bgSkin = new Skin();
			
			
			this.source = s;
			//装载整个背景
			var backUI:Sprite = new Sprite();
			this.addChild(backUI);
			backUI.mouseChildren = backUI.mouseEnabled = false;
			
			//背景的头部
			var head_sprite:Sprite = this.source.getMovieClip("giftBorder") as Sprite;
			backUI.addChild(head_sprite);
			head_sprite.height = head_sprite.height - 3;
			head_sprite.mouseChildren = head_sprite.mouseEnabled = false;
			
			//关闭按钮
			var closeBtn:Button = new Button();
			this.addChild(closeBtn);
			closeBtn.x = head_sprite.width - 40;
			closeBtn.y = 40;
			closeBtn.width = closeBtn.height = 18;
			closeBtn.bgSkin = Style.getButtonSkin("close_1skin","close_2skin","close_3skin",null,GameConfig.T1_UI);
			closeBtn.addEventListener(MouseEvent.CLICK,onCloseBtnHandler);
			
			//背景的身体
			var backGround_sprite:Sprite = this.source.getMovieClip("giftContainer") as Sprite;
			backUI.addChild(backGround_sprite);
			backGround_sprite.x = 50;
			backGround_sprite.y = 38;
			backGround_sprite.mouseChildren = backGround_sprite.mouseEnabled = false;
			
			//显示等级
			lvTxt = ComponentUtil.createTextField("",114,10,null,75,30,backGround_sprite);
			
			//领取奖励的按钮
			getRewardBtn = ComponentUtil.createButton("前往领取",(410 - 70)/2,255 - 25*2,70,25,this);
			getRewardBtn.addEventListener(MouseEvent.CLICK,onMouseClickHandler);
			
			content = ComponentUtil.createTextField("",65,110,null,280,60,this);
			content.addEventListener(TextEvent.LINK,onLink);
			content.mouseEnabled = true;
			content.wordWrap = true;
			addChild(content);
		}
		
		private function onMouseClickHandler(event:MouseEvent):void{
			PathUtil.findNPC(_info.npc_id.toString());
			closeWin();
		}
		
		private function onCloseBtnHandler(event:MouseEvent):void{
			closeWin();
		}
		
		private var _info:p_present_info;
		public function updata(info:p_present_info):void{
			_info = info;
			lvTxt.htmlText = "<font size='16' color='#000000'><b>时装礼包</b></font>";
			content.htmlText = "<font size='14'>佛靠金装，人靠衣装，打扮是很要紧的！“纯真年代”最美的新手时装，《天之刃》免费赠送给你，请前往<font color='#33CC00'><u><a href='event:gotoNPC'>京城-艾美丽</a></u></font>领取！</font>";
		}
		
		public function onLink(event:TextEvent):void{
			PathUtil.findNPC(_info.npc_id.toString());
			closeWin();
		}
		
		public function closeWin():void{
			WindowManager.getInstance().removeWindow(this);
			BroadcastSelf.logger("请到<font color='#00ff00'><u><a href='event:gotoNPC#"+ _info.npc_id +"'>京城-艾美丽</a></u></font>处领取时装！");
		}
		
		public function gotoNPC():void{
			
		}
	}
}