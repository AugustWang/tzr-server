package modules.familyCollect.views
{
	import com.common.GameColors;
	import com.common.GlobalObjectManager;
	import com.components.BasePanel;
	import com.globals.GameConfig;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.core.UIComponent;
	import com.utils.ComponentUtil;
	import com.utils.HtmlUtil;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import modules.broadcast.views.Tips;
	import modules.familyCollect.FamilyCollectModule;
	
	import proto.common.p_family_collect_role_prize_info;
	import proto.line.m_family_collect_get_prize_tos;
	import proto.line.m_family_collect_refresh_prize_tos;
	
	public class FamilyCollectPrizeView extends BasePanel
	{
		 private var maxExpTxt:TextField;
		 private var curExpTxt:TextField;
		 private var noExpTxt:TextField;
		 private var refreshBtn:Button;
		 private var getPrizeBtn:Button;
		 private var color:int=1;
		 
		 
		public function FamilyCollectPrizeView(key:String=null)
		{
			super("FamilyCollectPrize");
			title="领取采集活动奖励";
			this.width=270;
			this.height=210;
			
		}
		
		override protected function init():void
		{
			var part:UIComponent = ComponentUtil.createUIComponent(6,6,256,164);
			Style.setBorderSkin(part);
			this.addChild(part);
			var tf:TextFormat=Style.textFormat;
			
			maxExpTxt=ComponentUtil.createTextField("最高可领取经验：", 10, 25, tf, 200, 22, part);
			maxExpTxt.filters = [new GlowFilter(0x0, 1, 2, 2, 20)];
			curExpTxt=ComponentUtil.createTextField("当前可领取经验：", 10, 65, tf, 200, 22, part);
			curExpTxt.filters = [new GlowFilter(0x0, 1, 2, 2, 20)];
			noExpTxt=ComponentUtil.createTextField("当前没有可以领取的采集活动奖励\n\n门派采集活动，每天14:00~14:20开放\n活动期间成功采集竹笋可增加积分\n积分影响每个参与活动人员的经验收益\n和门派资金奖励", 20, 40, tf, 220, 88, part);
		
			noExpTxt.textColor = 0xffff00;
			
			refreshBtn=ComponentUtil.createButton("5两银子刷新颜色", 145, 90, 104, 24, part);
			refreshBtn.addEventListener(MouseEvent.CLICK, toRefresh);
			Style.setRedBtnStyle(refreshBtn);
			getPrizeBtn=ComponentUtil.createButton("领取奖励", 188, 134, 60, 24, part);
			getPrizeBtn.addEventListener(MouseEvent.CLICK, onGetPrize);
		}
			
		
		public function update(vo:p_family_collect_role_prize_info=null):void
		{
			if(vo == null || vo.role_id != GlobalObjectManager.getInstance().user.attr.role_id || vo.base_exp <= 0)
			{
				maxExpTxt.visible=false;
				curExpTxt.visible=false;
				refreshBtn.visible=false;
				getPrizeBtn.visible=false;
				noExpTxt.visible=true;
			}else
			{
				maxExpTxt.visible=true;
				curExpTxt.visible=true;
				refreshBtn.visible=true;
				getPrizeBtn.visible=true;
				noExpTxt.visible=false;
				color=vo.color;
				if(color >= 5)
				{
					refreshBtn.enabled = false;
				}
				else
				{
					refreshBtn.enabled = true;
				}
				maxExpTxt.htmlText=getExpStrByColor("最高可领取经验：", vo.base_exp, 5);
				curExpTxt.htmlText=getExpStrByColor("当前可领取经验：", vo.base_exp, vo.color);
			}
		}
		
		
		private function toRefresh(e:MouseEvent=null):void
		{
			refreshBtn.enabled = false;
			if(color >= 5)
			{
				
				Tips.getInstance().addTipsMsg("当前已达到最高经验奖励，不能再提升!");
			}
			else
			{
				var vo:m_family_collect_refresh_prize_tos=new m_family_collect_refresh_prize_tos();
				FamilyCollectModule.getInstance().send(vo);
			
			}
		}
		
		private function onGetPrize(e:MouseEvent=null):void
		{
			var vo:m_family_collect_get_prize_tos=new m_family_collect_get_prize_tos();
			FamilyCollectModule.getInstance().send(vo);
		}
		
		private function getExpStrByColor(str:String, exp:int, color:int):String
		{
			var str2:String;
			switch(color)
			{
				case 1:
					str2 = exp + "(白色)";
					break;
				case 2:
					str2 = Math.floor(exp * 1.5) + "(绿色)";
					break;
				case 3:
					str2 = Math.floor(exp * 2) + "(蓝色)";
					break;
				case 4:
					str2 = Math.floor(exp * 2.5) + "(紫色)";
					break;
				case 5:
					str2 = Math.floor(exp * 3.5) + "(橙色)";
					break;
			}
			return str + HtmlUtil.font(str2, GameColors.getHtmlColorByIndex(color));
		}
		
		public function getColorCNStr(color:int):String
		{
			switch(color)
			{
				case 1:
					return "白色";
				case 2:
					return "绿色";
				case 3:
					return "蓝色";
				case 4:
					return "紫色";
				case 5:
					return "橙色";
				case 6:
					return "金色";
				default:
					return "";
			}
		}
	}
}