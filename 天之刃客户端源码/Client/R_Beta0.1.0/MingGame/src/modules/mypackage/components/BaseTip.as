package modules.mypackage.components
{
	import com.utils.DateFormatUtil;
	import com.utils.HtmlUtil;
	import com.utils.MoneyTransformUtil;
	
	import flash.display.Sprite;
	
	import modules.deal.DealConstant;
	import modules.mypackage.ItemConstant;
	import modules.mypackage.vo.BaseItemVO;
	import modules.mypackage.vo.EquipVO;
	
	public class BaseTip extends Sprite
	{
		public static const CHAT_TOOLTIP:String = "chatToolTip";
		public static const ITEM_TOOLTIP:String = "itemToolTip";
		public static const NORMAL_TOOLTIP:String = "normalToolTip";
		public var type:String = ITEM_TOOLTIP;
		
		public var roleName:String;
		public var sex:int;
		public function BaseTip()
		{
			super();
			mouseEnabled = false;
		}
		
		public function createItemTip(itemVo:BaseItemVO):void{
			
		}
		
		protected function clearTip():void{
		
		}
		
		protected function getName(name:String,color:String):String{	
			return HtmlUtil.fontBr(HtmlUtil.bold(name),color,14);
		}
		
		protected function getBindable(bind:Boolean,use_bind:int):String{
			if (bind){
				return HtmlUtil.fontBr("绑定","#2e6723");
			}else if(use_bind == 1){
				return HtmlUtil.fontBr("装备后绑定","#2e6723");
			}
			return "";
		}
		
		protected function getUnitPrice(price:int, priceType:int):String // 单价。。。 用‘文’为单位　再来转成　锭　两　文
		{
			var price_str:String = HtmlUtil.font("单价：",'#0099ff');
			if (priceType == DealConstant.STALL_PRICE_TYPE_SILVER) {
				var arr:Array = DealConstant.silverToOther(price);
				if(arr[0]>0){
					price_str  += HtmlUtil.font(arr[0],'#ff0000') + HtmlUtil.font("锭","#0099ff") ;
				}
				if(arr[1]>0){
					price_str += HtmlUtil.font(arr[1],'#ff0000') + HtmlUtil.font("两","#0099ff") ;
				}
				if(arr[2]>0){	
					price_str += HtmlUtil.font(arr[2],'#ff0000') + HtmlUtil.font("文","#0099ff") ;
				}
			} else {
				price_str += HtmlUtil.font(price.toString(), "#ff0000") + HtmlUtil.font("元宝", "#0099ff");
			}
			price_str += "\n";
			return price_str;
		}
		
		protected function getMoneyDesc(sellType:int,sellPrice:Number):String{
			var msg:String="";
			if(sellType == 0){
				msg = "不能卖给系统"
			}else if(sellType == 1){
				msg = "出售给商店价格："+MoneyTransformUtil.silverToOtherString(sellPrice);
			}else if(sellType == 2){
				msg = "出售给商店价格："+sellPrice+"元宝";
			}
			return HtmlUtil.fontBr(msg,"#0099ff");
		}
		
		protected function getItemStatus(itemVO:BaseItemVO):String{
			var status:int = itemVO.getItemStatus();
			var str:String;
			if(status == BaseItemVO.UN_STARTUP){
				str = DateFormatUtil.formatPassDate(itemVO.timeoutData);
				return wapper("启用时间：",str,"#ffffff","#3be450","");
			}else if(status == BaseItemVO.PASS_DATE){
				return wapper("已过期无法使用","","#f53f3c");
			}else if(itemVO.timeoutData != 0){
				str = DateFormatUtil.formatPassDate(itemVO.timeoutData);
				return wapper("过期时间：",str,"#ffffff","#3be450","");
			}
			var equip:EquipVO = itemVO as EquipVO;
			if(equip)
			{
				var equipName:String = ItemConstant.getEquipKindName(equip.putWhere,equip.kind);
				if(equipName =="时装" ||equipName =="坐骑" )
				{
					return wapper("有效期：","永久","#ffffff","#3BE450","");
				}
			}
			return "";
		}
		
		protected function wapperText(name:String,value:int,endFix:String="",nameColor:String="#0099ff",textColor:String="#0099ff"):String{
			if(value==0)return"";
			var str:String = value.toString();
			str = str + endFix;
			return HtmlUtil.font(name,nameColor)+HtmlUtil.fontBr("    +"+str,textColor);
		}
		
		protected function wapper(name:String,data:Object,nameColor:String="#ffffff",textColor:String="#ffffff",space:String="    "):String{
			if(data == null)return "";
			if(name == "" && data == "")return "";
			if(name == ""){
				return HtmlUtil.fontBr(data.toString(),textColor)
			}
			return HtmlUtil.font(name,nameColor)+HtmlUtil.fontBr(space+data.toString(),textColor);
		}
		
	}
}