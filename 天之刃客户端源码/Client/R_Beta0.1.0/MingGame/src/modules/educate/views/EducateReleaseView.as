package modules.educate.views
{
	import com.components.components.DragUIComponent;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.TextInput;
	import com.utils.ComponentUtil;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import modules.educate.EducateModule;
	
	public class EducateReleaseView extends DragUIComponent
	{
		private var txfTitle:TextField;
		private var line:Sprite;
		private var txfMsgTip:TextField;
		private var txiMsg:TextInput;
		private var txfTip:TextField;
		private var butRel:Button;
		private var butCnl:Button;
		
		private var relType:int;
		
		public function EducateReleaseView()
		{
			super();
			init();
		}
		
		private function init():void{
			this.width = 384;
			this.height = 185;
			
			txfTitle = ComponentUtil.createTextField("",int((width-122)/2),0,new TextFormat("Tahoma",20,0xffffff),122,25,this);
			txfTitle.htmlText = "发布";
			
			txfMsgTip = ComponentUtil.createTextField("",int((width-314)/2),44,null,314,25,this);
			txfMsgTip.filters = [new GlowFilter(0x000000, 1, 2, 2, 20)];
			txfMsgTip.htmlText = "请输入你的留言，也可以直接点击确认，成功后会加入名单";
			
			txiMsg = ComponentUtil.createTextInput(int((width-286)/2),74,286,25,this);
			txiMsg.maxChars = 20;
			
			txfTip = ComponentUtil.createTextField("",int((width-242)/2),107,null,242,25,this);
			txfTip.filters = [new GlowFilter(0x000000, 1, 2, 2, 20)];
			txfTip.htmlText = "(有徒弟后可获得师德值，快速清洗红名惩罚)";
			
			butRel = ComponentUtil.createButton("发布",int(width/2)-63-80,137,80,25,this);
			butRel.addEventListener(MouseEvent.CLICK, onRelease);
			
			butCnl = ComponentUtil.createButton("取消",int(width/2)+63,137,80,25,this);
			butCnl.addEventListener(MouseEvent.CLICK, onClose);
		}
		
		private function refView():void{
			txiMsg.text = "";
			switch(relType){
				case 1: //发布收徒
					txfTitle.htmlText = "申请成为师傅";
					break;
				case 2: //发布拜师
					txfTitle.htmlText = "申请成为徒弟";
					break;
				default:
					break;
			}	
		}
		
		private function onRelease(e:MouseEvent):void{
			switch(relType){
				case 1: //发布收徒
					if (txiMsg.text == ""){
						EducateModule.getInstance().releaseAdm("找徒弟");	
					}else{
						EducateModule.getInstance().releaseAdm(txiMsg.text);	
					}
					break;
				case 2: //发布拜师
					if (txiMsg.text == ""){
						EducateModule.getInstance().releaseApp("找师傅");
					}else{
						EducateModule.getInstance().releaseApp(txiMsg.text);
					}
					break;
				default:
					break;
			}	
			onClose(e);
		}
		
		private function onClose(e:MouseEvent):void{
			if(this.parent){
				this.parent.removeChild(this);
			}
		}
		
		override public function set data(vo:Object):void{
			relType = vo as int;	
			refView();
		}
	}
}