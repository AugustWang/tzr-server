package modules.greenHand.view
{
	import com.common.GlobalObjectManager;
	import com.ming.events.ItemEvent;
	import com.ming.ui.containers.List;
	import com.ming.ui.skins.Skin;
	import com.utils.ComponentUtil;
	import com.utils.PathUtil;
	
	import flash.display.Sprite;
	import flash.events.TextEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import modules.greenHand.LoaderActivityXML;
	import modules.greenHand.view.item.DiretoryItemRender;
	
	public class DirectoryView extends Sprite
	{
		public function DirectoryView()
		{
			super();
			skin = new Skin();
			init();
		}
		
		private var list:List;
		private var skin:Skin;
		private var questionTxt:TextField;
		private var anwserTxt:TextField;
		private function init():void{
			//左边的背景
			var leftBackUI:Sprite = Style.getBlackSprite(180,303,2);
			this.addChild(leftBackUI);
			leftBackUI.x = 8;
			leftBackUI.y = 5;
			
			list = new List();
			this.addChild(list);
			list.x = 10;
			list.y = 8;
			list.width = 178;
			list.height = 300;
			list.itemRenderer = DiretoryItemRender;
			list.itemHeight = 23;
			list.selectedIndex = 0;
			list.dataProvider = LoaderActivityXML.getInstance().treasuryData;
			list.addEventListener(ItemEvent.ITEM_CLICK,onItemClickHandler);
			list.bgSkin = skin;
			
			//右边的背景
			var rightBackUI:Sprite = Style.getBlackSprite(330,303,2);
			this.addChild(rightBackUI);
			rightBackUI.x = leftBackUI.x + leftBackUI.width + 5;
			rightBackUI.y = leftBackUI.y;
			
			questionTxt = ComponentUtil.createTextField("",rightBackUI.x + 10,rightBackUI.y + 8,new TextFormat("Tahoma",14,0xF6F5CD),200,30,this);
			questionTxt.htmlText = LoaderActivityXML.getInstance().treasuryData[0].question;
			anwserTxt = ComponentUtil.createTextField("",questionTxt.x + 10,questionTxt.y + questionTxt.height + 10,null,280,200,this);
			anwserTxt.mouseEnabled = true;
			anwserTxt.addEventListener(TextEvent.LINK,onTextLinkHandler);
			anwserTxt.htmlText = LoaderActivityXML.getInstance().treasuryData[0].anwser;
			anwserTxt.multiline = true;
			anwserTxt.wordWrap = true;
		}
		
		private function onTextLinkHandler(evt:TextEvent):void{
			var arr:Array = evt.text.split("|");
			if(arr.indexOf("treasury") != -1){
				if(arr.length >2){
					switch(GlobalObjectManager.getInstance().user.base.faction_id){
						case 1:PathUtil.findNPC(arr[1]);break;//云州
						case 2:PathUtil.findNPC(arr[2]);break;//沧州
						case 3:PathUtil.findNPC(arr[3]);break;//幽州
					}
				}else{
					PathUtil.findNPC(arr[0]);
				}
			}
		}
		
		private function onItemClickHandler(evt:ItemEvent):void{
			var obj:Object = LoaderActivityXML.getInstance().treasuryData[List(evt.currentTarget).selectedIndex];
			questionTxt.htmlText = "<font color='#AFE1EC'>"+String(obj.question)+"</font>";
			anwserTxt.htmlText = obj.anwser;
		}
	}
}