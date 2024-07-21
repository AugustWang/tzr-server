package modules.warOfCity.view
{
	import com.ming.ui.containers.List;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.Image;
	import com.ming.ui.controls.core.UIComponent;
	
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import com.components.BasePanel;
	import com.utils.ComponentUtil;
	
	import proto.line.m_warofcity_panel_manage_toc;
	
	public class WarCityDetailView extends BasePanel
	{
		private var msg:TextField;
		private var joinBattle:TextField;
		private var list:List;
		private var awardTxt:TextField;
		private var awardImage:Image;
		private var getAward:Button;
		private var money:TextField;
		private var applyBtn:Button;
		private var quitBtn:Button;
		
		public function WarCityDetailView(key:String=null)
		{
			super(key);
			title="本图战况";
			width=390;
			height=410;
		}
		
		override protected function init():void
		{
			var backBg:UIComponent=ComponentUtil.createUIComponent(6, 4, 376, 370);
			Style.setBorderSkin(backBg);
			backBg.mouseEnabled=false;
			addChild(backBg);
			var tf:TextFormat=new TextFormat(null,null,0xfff799,true);
			msg=ComponentUtil.createTextField("本地图归属 XXX门派，连续占领XX天", 20, 20, null, 200, 22, this);
			joinBattle=ComponentUtil.createTextField("当前有以下门派申请本地图争夺：", 20, 60, tf, 360, 22, this);
			list=new List;
			list.x=20;
			list.y=82;
			list.width=345;
			list.height=120;
			addChild(list);
			awardTxt=ComponentUtil.createTextField("连续占领Y天，即可领取", 20, 244, null, 300, 22, this);
			awardImage=new Image;
			awardImage.x=200;
			awardImage.y=224;
			addChild(awardImage);
			getAward=ComponentUtil.createButton("点击领取", 260, 244, 60, 24, this);
			money=ComponentUtil.createTextField("申请挑战需门派资金：xx锭xx两xx文", 20, 300, null, 300, 22, this);
			applyBtn=ComponentUtil.createButton("申请挑战",188,324,80,24,this);
			quitBtn=ComponentUtil.createButton("放弃占领",288,324,80,24,this);
		}
		
		public function update(vo:m_warofcity_panel_manage_toc):void
		{
			if (vo.succ == true)
			{
				if (vo.city.family_id > 0)
				{
					msg.text="本地图被门派:" + vo.city.family_name + "占领\n占领天数:" + vo.city.last_day + "天。";
				}
				else
				{
					msg.text="本地图尚未被占领。"
				}
			}
		}
	}
}