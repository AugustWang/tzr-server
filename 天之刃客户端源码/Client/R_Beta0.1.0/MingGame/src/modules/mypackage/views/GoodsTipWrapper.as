package modules.mypackage.views
{
	import com.common.GlobalObjectManager;
	import com.utils.HtmlUtil;
	
	import modules.mypackage.ItemConstant;
	import modules.mypackage.vo.BaseItemVO;
	import modules.mypackage.vo.EquipVO;

	public class GoodsTipWrapper
	{
		private static var instance:GoodsTipWrapper;
		public function GoodsTipWrapper(){
			
		}
		
		private static function getInstance():GoodsTipWrapper{
			if(instance == null){
				instance = new GoodsTipWrapper();
			}
			return instance;
		}
		
		public static function wrapperItem(itemVo:BaseItemVO):String{
			return getInstance().parseNormalItem(itemVo);
		}
		
		public function parseNormalItem(itemVo:BaseItemVO):String{
			var htmlText:String = "";
			try{
				var color:String = ItemConstant.COLOR_VALUES[itemVo.color];
				var equipVo:EquipVO = itemVo as EquipVO;
				
				var _bindStr:String = '';
				if(itemVo.show_bind == true){
					_bindStr = (itemVo.bind ? '<font color="#2e6723">不绑定</font>\n' : '<font color="#2e6723">绑定</font>\n' );
				}
				htmlText = getName(itemVo.name,color)+"\n"+_bindStr;
				if(equipVo){
					if(equipVo.signature && equipVo.signature != ""){
						htmlText += wapper("",equipVo.signature);
					}
					htmlText += wapper("装备类型",ItemConstant.getEquipKindName(equipVo.putWhere,equipVo.kind));
					if(equipVo.sex != 0 && GlobalObjectManager.getInstance().user.base.sex != equipVo.sex){
						var sexColor:String = "#ff0000";
						htmlText += wapper("性别要求",ItemConstant.SEX_NAMES[equipVo.sex],sexColor,sexColor);
					}
					
					
//					if(equipVo.minlvl > 1){
//						var levelColor:String = "#ffaca";
//						if(GlobalObjectManager.getInstance().user.attr.level < equipVo.minlvl){
//							levelColor = "#ff0000";
//						}
//						htmlText += wapper("等级要求",equipVo.minlvl,levelColor,levelColor);
//					}
//					if(equipVo.maxlvl < 160){
//						htmlText += wapper("最高等级",equipVo.maxlvl,"#ffaca","#ffaca");
//					}
					//等级要求修改
					var levelColor:String="#ffaca";
					if(equipVo.maxlvl>=200)
					{
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
					
					
					
					
					

				}
				if(itemVo.desc != ""){
					var desc:String = itemVo.desc.split("\\n").join("\n");
					htmlText += wapper("",desc,color,color);
				}
			}catch(e:Error){
				//MonsterDebugger.trace(this,"普通提示解析出错"+e.toString());
			}
			return htmlText;
		}
		
		private function getName(name:String,color:String):String{	
			return HtmlUtil.font(HtmlUtil.bold(name),color,15);
		}
		
		private function wapperText(name:String,value:int,endFix:String="",nameColor:String="#0099ff",textColor:String="#0099ff"):String{
			if(value==0)return"";
			var str:String = value.toString();
			str = str + endFix;
			return HtmlUtil.font(name,nameColor)+HtmlUtil.fontBr("     +"+str,textColor);
		}
		
		private function wapper(name:String,data:Object,nameColor:String="#ffffff",textColor:String="#ffffff"):String{
			if(name == ""){
				return HtmlUtil.fontBr(data.toString(),textColor)
			}
			return HtmlUtil.font(name,nameColor)+HtmlUtil.fontBr("      "+data.toString(),textColor);
		}		
	}
}