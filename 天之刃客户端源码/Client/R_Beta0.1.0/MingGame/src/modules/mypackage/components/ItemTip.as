package modules.mypackage.components
{
	import com.common.GlobalObjectManager;
	import com.globals.GameConfig;
	import com.ming.ui.controls.Image;
	import com.utils.ComponentUtil;
	
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import modules.mypackage.ItemConstant;
	import modules.mypackage.vo.BaseItemVO;
	import modules.mypackage.vo.GeneralVO;
	
	public class ItemTip extends BaseTip
	{

		private var startY:Number = 8;
		
		private var itemName:TextField; //名称描述 和 打造描述
		private var border:Image;
		private var icon:Image; //装备图像
		private var itemBaseDesc:TextField; //装备基本描述  bind 数量
		private var itemDesc:TextField; //绑定情况描述
	
		public function ItemTip()
		{
			super();
			var tf:TextFormat = Style.textFormat;
			tf.leading = 4;
			itemName = ComponentUtil.createTextField("",8,0,tf,190,NaN,this,wrapperHandler);
			border = new Image();
			border.width = 65;
			border.height =  66;
			border.source = GameConfig.getBackImage("shopItemBg");
			border.x = 10;
			addChild(border);
			icon = new Image();
			icon.width = icon.height = 55;
			icon.x = icon.y = 4;
			border.addChild(icon);
			itemBaseDesc = ComponentUtil.createTextField("",80,0,tf,200,NaN,this,wrapperHandler);
			itemDesc = ComponentUtil.createTextField("",8,0,tf,200,NaN,this,wrapperHandler);
		}

		private function wrapperHandler(text:TextField):void{
			text.wordWrap = true;
		}
		
		override public function createItemTip(itemVo:BaseItemVO):void{
			clearTip();
			if(itemVo == null)return;
			startY = 8;
			var htmlText:String = "";
			var color:String = ItemConstant.COLOR_VALUES[itemVo.color];
			htmlText = getName(itemVo.name,color);
			
			if(type != ITEM_TOOLTIP){
				var sexStr:String = ""; 
				if (sex != 0) {
					sex == 1 ? sexStr="<font color='#00ccff' size='14'><b>♂</b></font>":sexStr="<font color='#ff37e0' size='14'><b>♀</b></font>"
					htmlText += sexStr + wapper(""," "+roleName);
				}
			}
			
			htmlText += getBindable(itemVo.bind,itemVo.use_bind);
			
			itemName.htmlText = htmlText;
			itemName.y = startY;
			
			startY  = startY + itemName.textHeight + 5;
			htmlText = "";
			
			icon.source = itemVo.path;
			
			border.y = startY + 3;
			
			if(type != CHAT_TOOLTIP){
				htmlText += wapper("数量",itemVo.num);
			}
			itemBaseDesc.htmlText = htmlText;
			itemBaseDesc.y = startY;
			itemBaseDesc.height = itemBaseDesc.textHeight + 5;
			
			startY  = startY + 70;
			htmlText = "";
			var superVO:GeneralVO = itemVo as GeneralVO;
	
			if(type != CHAT_TOOLTIP){
				if(superVO && (superVO.effectType == ItemConstant.EFFECT_SUPER_HP || superVO.effectType == ItemConstant.EFFECT_SUPER_MP)){
					htmlText += wapper("使用情况",superVO.currentValue+"/"+superVO.maxValue);
				}
			}
	
//			if(superVO && superVO.minlvl > 1){
//				var levelColor:String = "#ffaca";
//				if(GlobalObjectManager.getInstance().user.attr.level < superVO.minlvl){
//					levelColor = "#ff0000";
//				}
//				htmlText += wapper("等级要求：",superVO.minlvl,levelColor,levelColor);
//			}
			
			//等级要求修改
				var levelColor:String="#ffaca";
				if(superVO && superVO.maxlvl>=200)
				{
					if(superVO.minlvl<=1)
					{
						htmlText+="";
					}
					if(superVO.minlvl>1)
					{
						if((GlobalObjectManager.getInstance().user.attr.level<1)&&(GlobalObjectManager.getInstance().user.attr.level<200))
						{
							levelColor = "#ff0000";
						}
						htmlText += wapper("等级要求：",superVO.minlvl.toString(),levelColor,levelColor);
					}
				}
				if(superVO&&superVO.maxlvl<200)
				{
					if(GlobalObjectManager.getInstance().user.attr.level>200)
					{
						levelColor = "#ff0000";
					}
					htmlText += wapper("等级要求：",(superVO.minlvl.toString()+"-"+superVO.maxlvl.toString()),levelColor,levelColor);
				}
				
				
			
			
			if(itemVo.desc != ""){
				var descColor:String = color;
				if(itemVo is GeneralVO){
					if(GeneralVO(itemVo).effectType == ItemConstant.EFFECT_LIBAO && GlobalObjectManager.getInstance().user.attr.level < GeneralVO(itemVo).minlvl){
						descColor = "#ff0000";
					}
				}
				var desc:String = itemVo.desc.split("\\n").join("\n");
				htmlText += wapper("",desc,descColor,descColor);
			}
			if(type != CHAT_TOOLTIP && itemVo.unit_price > 0){
				htmlText += getUnitPrice(itemVo.unit_price, itemVo.price_type);//*itemVo.num 显示单价的
			}
			if(type != CHAT_TOOLTIP){ 
				htmlText += getMoneyDesc(itemVo.sellType,itemVo.sellPrice);
				htmlText += getItemStatus(itemVo);
				if(itemVo.num > 1){
					htmlText += wapper("","Shift+单击：可进行拆分");
				}else{
					htmlText += wapper("","Ctrl+单击：发送到聊天");
				}
			}
			htmlText = htmlText.split("\\n").join("\n");
			itemDesc.htmlText = htmlText;
			itemDesc.y = startY;
			itemDesc.height = itemDesc.textHeight + 5;
			
			startY = startY + itemDesc.textHeight + 5;
			
		}
		
		override protected function clearTip():void{
		   	itemName.htmlText = "";
			itemBaseDesc.htmlText = "";
			itemDesc.htmlText = "";
		}
		
		override public function get height():Number{
			return startY + 5;
		}
		
		override public function get width():Number{
			return 210;
		}
	}
}