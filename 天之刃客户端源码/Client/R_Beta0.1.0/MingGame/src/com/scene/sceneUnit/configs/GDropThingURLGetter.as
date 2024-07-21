package 
{
	import com.globals.GameConfig;
	
	import modules.mypackage.ItemConstant;
	import modules.mypackage.managers.ItemLocator;
	import modules.mypackage.vo.BaseItemVO;
	import modules.mypackage.vo.EquipVO;
	import modules.mypackage.vo.GeneralVO;
	import modules.mypackage.vo.StoneVO;
	
	import proto.common.p_map_dropthing;
	
	public class GDropThingURLGetter
	{
		
		public static function getDropThingURL(vo:p_map_dropthing):String
		{
			var url:String=GameConfig.DROP_ITEM_ICON;
			if (vo.ismoney == true)
			{
				url+='yinzi.swf';
			}
			else
			{
				var itemvo:BaseItemVO=ItemLocator.getInstance().getObject(vo.goodstypeid);
				if (itemvo is EquipVO)
				{
					var putWhere:int=EquipVO(itemvo).putWhere;
					if (putWhere == 1)
					{
						switch (EquipVO(itemvo).kind)
						{
							case 101:
								url+="dao.swf"
								break;
							case 102:
								url+="gong.swf"
								break;
							case 103:
								url+="zhan.swf"
								break;
							case 104:
								url+="shan.swf"
								break;
							default:
								url+="zawu.swf"
								break;
						}
					}
					else
					{
						switch (EquipVO(itemvo).putWhere)
						{
							case 2:
								url+="xianglian.swf";
								break;
							case 3:
								url+="jiezhi.swf";
								break;
							case 4:
								url+="toukui.swf";
								break;
							case 5:
								if (EquipVO(itemvo).sex == 1)
								{
									url+="nanhujia.swf";
								}
								else
								{
									url+="nvhujia.swf";
								}
								break;
							case 6:
								url+="yaodai.swf";
								break;
							case 7:
								url+="huwan.swf";
								break;
							case 8:
								url+="xuezi.swf";
								break;
							case 9:
								url+="dunpai.swf"; //副手武器
								break;
							case 10:
								url+="zawu.swf"; //挂饰
								break;
							case 11:
								url+="zawu.swf"; //时装
								break;
						}
					}
				}
				else if (itemvo is GeneralVO)
				{
					if (GeneralVO(itemvo).effectType == ItemConstant.EFFECT_HP)
					{
						url+="hongyao.swf";
					}
					else if (GeneralVO(itemvo).effectType == ItemConstant.EFFECT_MP)
					{
						url+="lanyao.swf";
					}
					else if (GeneralVO(itemvo).effectType == ItemConstant.EFFECT_SUPER_HP)
					{
						url+="chaojihongyao.swf";
					}
					else if (GeneralVO(itemvo).effectType == ItemConstant.EFFECT_YP)
					{
						url+="yinpiao.swf";
					}
					else if (GeneralVO(itemvo).effectType == 10)
					{
						url+="yuanxiaoshicai.swf";
					}
					else if (GeneralVO(itemvo).kind == ItemConstant.KIND_GIFT_BAG)
					{
						url+="libao.swf";
					}
					else if (GeneralVO(itemvo).kind == ItemConstant.KIND_BOOK)
					{
						url+="shuji.swf";
					}
					else if (GeneralVO(itemvo).kind == ItemConstant.KIND_MATERIAL)
					{
						url+="cailiao.swf";
					}
					else if (GeneralVO(itemvo).kind == ItemConstant.KIND_PACK)
					{
						url+="baoguo.swf";
					}
					else if (GeneralVO(itemvo).kind == ItemConstant.KIND_HIEROGRAM)
					{
						url+="lingfu.swf";
					}
					else if (GeneralVO(itemvo).kind == ItemConstant.KIND_GIFT_BAG)
					{
						url+="libao.swf";
					}
					
				}
				else if (itemvo is StoneVO)
				{
					url+="lingshi.swf";
				}
				else
				{
					url+="zawu.swf";
				}
			}
			return url;
		}
	}
}