package modules.roleStateG.views.changeSex
{
	
	import com.components.BasePanel;
	import com.ming.events.CloseEvent;
	import com.ming.ui.controls.Button;
	import com.utils.ComponentUtil;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import proto.line.m_role2_sex_tos;
	
	public class ChangeSexView extends BasePanel
	{
		public static const succ:String = "您花费50元宝，成功改变了性别。" +
			"请按 “确定” ，重新开始您崭新的游戏人生。";
		
		private static const desc:String = "变性操作将会改变角色的性别和头像、装备的铠甲或服饰将" +
			                                  "不能再穿着，并且会使魅力值、送花得分清零。" +
											  "你确定要使用 50 个元宝，进行变性操作吗?";
		private var txt:TextField;
		private var sureBtn:Button;
		private var cancelBtn:Button;
		
		private var fun:Function;
		
		private var bg:Sprite;
		
		private var titleTF:TextFormat = new TextFormat("宋体",14,0xFFF2BA,true);
//		
		public function ChangeSexView()
		{
			super();
			
			title = "提示";
			this.width = 350;
			this.height = 150;
			this.panelSkin = Style.getInstance().alertSkin;
			bg = new Sprite();
			bg.x = 10;
			addChild(bg);
			initView();
			addEventListener(CloseEvent.CLOSE,closeHandler);
		}
		
		private function initView():void
		{
			var tf:TextFormat = new TextFormat("Tahoma",12,0xF6F5CD);
			tf.leading = 8;
			txt = ComponentUtil.createTextField("",16,10,tf,320,80,this);
			txt.wordWrap = true;
			txt.multiline = true;
			
			txt.htmlText = desc;
			
			sureBtn = ComponentUtil.createButton("确定",86,80,66,25,this);
			sureBtn.addEventListener(MouseEvent.CLICK,onSure);
			
			cancelBtn = ComponentUtil.createButton("取消",190,80,66,25,this);
			cancelBtn.addEventListener(MouseEvent.CLICK,onCancel);
			
			
			with(bg.graphics)
			{
				clear();
				beginFill(0,0.5);
				drawRoundRect(0,0,width-20,height-40,6,6);
				endFill();
			}
			
			
		}
		
		public function set requesFun(changeSexFun:Function):void
		{
			fun = changeSexFun ;
		}
		
		private function onSure(evt:MouseEvent):void
		{
			if(fun!=null)
			{
				fun.apply(null, [new m_role2_sex_tos]);
				closeHandler();
			}
		}
		private function onCancel(evt:MouseEvent):void
		{
			closeHandler();
		}
		
//		private function closeHandler(event:CloseEvent=null):void
//		{
//			var evt:CloseEvent = new CloseEvent(CloseEvent.CLOSE);
//			this.dispatchEvent(evt);
//			closeWindow();
//		}
		
//		public function closeWindow(save:Boolean = false):void
//		{
//			WindowManager.getInstance().removeWindow(this);
//		}
		
//		override protected function closeHandler(event:CloseEvent=null):void
//		{
//			var evt:CloseEvent = new CloseEvent(CloseEvent.CLOSE);
//			this.dispatchEvent(evt);
//		}
	}
}