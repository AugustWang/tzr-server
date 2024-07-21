package modules.shop.views
{
	import com.common.GlobalObjectManager;
	import com.globals.GameConfig;
	import com.ming.ui.controls.Image;
	import com.utils.ComponentUtil;
	import com.utils.HtmlUtil;
	
	import flash.display.Sprite;
	import flash.sampler.getInvocationCount;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import modules.mypackage.ItemConstant;
	import modules.mypackage.managers.ItemLocator;
	import modules.mypackage.vo.EquipVO;
	import modules.mypackage.vo.GeneralVO;
	import modules.shop.ShopConstant;
	import modules.shop.ShopItem;
	import modules.trading.tradingManager.TradingManager;
	import modules.trading.vo.TradingGoodVo;
	import modules.vip.VipModule;
	
	import proto.common.p_property_add;

	public class ShopTipView extends Sprite
	{
		private var startY:Number=8;

		private var itemName:TextField; //名称描述 和 打造描述
		private var border:Sprite;
		private var borderBg:Image;
		private var icon:Image; //装备图像
		private var itemDesc:TextField; //商品描述

		public function ShopTipView(){
			super();
			var tf:TextFormat=Style.textFormat;
			tf.leading=4;
			itemDesc=ComponentUtil.createTextField("", 8, 0, tf, 144, NaN, this, wrapperHandler);
		}

		private function wrapperHandler(text:TextField):void
		{
			text.wordWrap=true;
		}

		public function createItemTip(item:ShopItem):void
		{
			clearTip();

			if (item == null)
				return;

			startY=5;
			if (item.preViewPath == ""){
				if (borderBg && borderBg.parent){
					removeChild(borderBg);
					//					icon.parent.removeChild(icon);
				}
			}else{
				if (!borderBg){
					borderBg=new Image();
					borderBg.x=8;
					borderBg.y=6;

					icon=new Image();
					icon.x=6;
					icon.y=-2;
				}

				borderBg.source=GameConfig.ROOT_URL + 'com/assets/fashionImg/fashionBg.png';
				icon.source= item.preViewPath;
				
				if (!borderBg.parent){
					addChild(borderBg);
					if (icon && !icon.parent)
						borderBg.addChild(icon);
					startY+=118;
				}
			}


			var htmlText:String="";

			htmlText=wrapperHTML(item);
			itemDesc.y=startY;
			itemDesc.htmlText=htmlText;
			itemDesc.height=itemDesc.textHeight + 5;

			startY=startY + itemDesc.height;

		}

		private function wrapperHTML(item:ShopItem):String
		{
			var color:String=item.colour;
			var htmlText:String=getName(item.name, color);
			
			

//			htmlText += "\n";

			if (item.type == ItemConstant.TYPE_EQUIP)
			{
				var equipVo:EquipVO = new EquipVO;
				equipVo.typeId = item.id;
				
				htmlText+=getBindable(item.bind);
				htmlText+=wapper("装备类型：", ItemConstant.getEquipKindName(item.putWhere, item.kind));

				if (equipVo.sex != 0 && GlobalObjectManager.getInstance().user.base.sex != equipVo.sex)
				{
					var sexColor:String="#ff0000";
					htmlText+=wapper("性别要求：", ItemConstant.SEX_NAMES[equipVo.sex], sexColor, sexColor);
				}
				
				
//				if (equipVo.minlvl > 1)
//				{
//					var levelColor:String="#ffaca";
//					if (GlobalObjectManager.getInstance().user.attr.level < equipVo.minlvl)
//					{
//						levelColor="#ff0000";
//					}
//
//					htmlText+=wapper("等级要求：", equipVo.minlvl+" - "+equipVo.maxlvl, levelColor, levelColor); //"#ffaca","#ffaca");
//				}
				//等级要求修改
				var levelColor:String="#ffaca";
				if(equipVo.maxlvl>=200)
				{
					if(GlobalObjectManager.getInstance().user.attr.level<equipVo.minlvl)//不够等级显红色
					{
						levelColor = "#ff0000";
					}
					if(equipVo.minlvl<=1)
					{
						htmlText+="";
					}
					if(equipVo.minlvl>1)
					{
						if((GlobalObjectManager.getInstance().user.attr.level<1)&&(GlobalObjectManager.getInstance().user.attr.level<200))
						{
							levelColor = "#ff0000";
						}
						htmlText += wapper("等级要求：",equipVo.minlvl.toString(),levelColor,levelColor);
					}
				}
				if(equipVo.maxlvl<200)
				{
					if(GlobalObjectManager.getInstance().user.attr.level>200)
					{
						levelColor = "#ff0000";
					}
					htmlText += wapper("等级要求：",(equipVo.minlvl.toString()+"-"+equipVo.maxlvl.toString()),levelColor,levelColor);
				}
				
				
				
				

				//				htmlText += wapper("耐久度",equipVo.current_endurance); //xml 里面没有

				var propertys:p_property_add= item.property; //             没 有 各项属性！
				if (!propertys)
					return htmlText;

				if (propertys.min_physic_att != 0 || propertys.max_physic_att != 0) //
					htmlText+=wapper("外攻  + ", propertys.min_physic_att + " — " + propertys.max_physic_att, "#ffffff", "#0099ff"); //
				if (propertys.min_magic_att != 0 || propertys.max_magic_att != 0)
					htmlText+=wapper("内攻  + ", propertys.min_magic_att + " — " + propertys.max_magic_att, "#ffffff", "#0099ff"); //
				htmlText+=wapperText("力量", propertys.power); //
				htmlText+=wapperText("敏捷", propertys.agile); //
				htmlText+=wapperText("智力", propertys.brain); //
				htmlText+=wapperText("体质", propertys.vitality); //
				htmlText+=wapperText("精神", propertys.spirit); //
				htmlText+=wapperText("外防", propertys.physic_def); // 
				htmlText+=wapperText("内防", propertys.magic_def); //
				htmlText+=wapperText("生命值", propertys.blood); //
				htmlText+=wapperText("内力值", propertys.magic); //
				htmlText+=wapperText("外攻百分比", propertys.physic_att_rate); //
				htmlText+=wapperText("内攻百分比", propertys.magic_att_rate); //
				htmlText+=wapperText("外防百分比", propertys.physic_def_rate); //
				htmlText+=wapperText("内防百分比", propertys.magic_def_rate); //
				htmlText+=wapperText("生命值百分比", propertys.blood_rate); //
				htmlText+=wapperText("内力值百分比", propertys.magic_rate); //
				htmlText+=wapperText("生命恢复速度", propertys.blood_resume_speed); //
				htmlText+=wapperText("内力恢复速度", propertys.magic_resume_speed); //
				htmlText+=wapperText("重击", propertys.dead_attack); //
				htmlText+=wapperText("幸运", propertys.lucky); //
				htmlText+=wapperText("移动速度", propertys.move_speed); //
				htmlText+=wapperText("攻击速度", propertys.attack_speed); //
				htmlText+=wapperText("闪避", propertys.dodge); //
				htmlText+=wapperText("破甲", propertys.no_defence); //
				
			}
			else
			{
				if (item.type == ItemConstant.TYPE_GENERAL)
				{
					var general:GeneralVO = ItemLocator.getInstance().getGeneral(item.id) as GeneralVO;
					var lvColor:String="#ffaca";
					if (general)
					{
						if (GlobalObjectManager.getInstance().user.attr.level < general.minlvl)
						{
							lvColor="#ff0000";
						}
						if (general.minlvl > 1)
						{
							htmlText+=wapper("等级要求：", general.minlvl, lvColor, lvColor);
						}
					}
				}
			}
			
			htmlText += getBindable(item.bind);
			
			var desc:String = item.desc.split("\\n").join("\n");
			if(desc!="")
				htmlText += wapper("",desc,color,color);//描述
			
			if(item.discountType !=0 && item.discountType !=1){
				htmlText += getPrice(item.discPrice);
			}else if(VipModule.getInstance().isVip() && item.priceVip && item.discountType !=0){
				htmlText += getPrice(item.priceVip);
			}else if(item.price){
				htmlText += getPrice(item.price);
			}
			
			htmlText+=item.sellTime;
			
			return htmlText;
		}
		
		private function getPrice(price:String):String // 单价。。。 用‘文’为单位　再来转成　锭　两　文
		{
			
			var price_str:String = HtmlUtil.font("单价：",'#0099ff');
			
			price_str += HtmlUtil.font(price,"#0099ff");
			
			price_str += "\n";
			return price_str;
			
		}

		private function clearTip():void
		{
//			itemName.htmlText = "";
			itemDesc.htmlText="";
		}

		private function getName(name:String, color:String):String
		{
			return HtmlUtil.fontBr(HtmlUtil.bold(name), color, 14);
		}

		private function getBindable(bind:Boolean):String
		{
			if (bind)
				return HtmlUtil.fontBr("绑定", "#2e6723");
			return "";
		}

		private function wapperText(name:String, value:int, nameColor:String="#0099ff", textColor:String="#0099ff"):String
		{
			if (value == 0)
				return "";
			var str:String=value.toString();
			if (name == "闪避" || name == "破甲" || name == "重击" || name == "物理伤害减免" || name == "内力伤害减免")
			{
				str=value + "%";
			}
			return HtmlUtil.font(name, nameColor) + HtmlUtil.fontBr("     +" + str, textColor);
		}

		protected function wapper(name:String, data:Object, nameColor:String="#ffffff", textColor:String="#ffffff", space:String="    "):String
		{
			if (data == null)
				return "";
			if (name == "" && data == "")
				return "";
			if (name == "")
			{
				return HtmlUtil.fontBr(data.toString(), textColor)
			}
			return HtmlUtil.font(name, nameColor) + HtmlUtil.fontBr(space + data.toString(), textColor);
		}

		override public function get height():Number
		{
			return startY + 5;
		}

		override public function get width():Number
		{
			return 158;
		}

	}
}