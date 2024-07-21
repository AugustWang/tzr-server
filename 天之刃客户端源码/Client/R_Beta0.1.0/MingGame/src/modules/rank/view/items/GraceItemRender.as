package modules.rank.view.items
{
	import com.common.GlobalObjectManager;
	import com.globals.GameConfig;
	import com.ming.ui.controls.core.UIComponent;
	import com.utils.ComponentUtil;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import proto.common.p_family_gongxun_rank;
	
	public class GraceItemRender extends UIComponent
	{
		private var thisWeekRankTxt:TextField;
		private var familyNameTxt:TextField;
		private var thisWeekGraceTxt:TextField;
		private var preRankTxt:TextField;
		private var preGraceTxt:TextField;
		private var icon:Sprite;
		
		public function GraceItemRender()
		{
			var textFormat:TextFormat = new TextFormat("Tahoma",12,0xffffff,null,null,null,null,null,TextFormatAlign.CENTER);
			thisWeekRankTxt = ComponentUtil.createTextField("",2,2,textFormat,70,25,this);
			familyNameTxt = ComponentUtil.createTextField("",thisWeekRankTxt.x + thisWeekRankTxt.width,thisWeekRankTxt.y,textFormat,90,25,this);
			thisWeekGraceTxt = ComponentUtil.createTextField("",familyNameTxt.x + familyNameTxt.width,familyNameTxt.y,textFormat,96,25,this);
			preRankTxt = ComponentUtil.createTextField("",thisWeekGraceTxt.x + thisWeekGraceTxt.width,thisWeekGraceTxt.y,textFormat,70,25,this);
			preGraceTxt = ComponentUtil.createTextField("",preRankTxt.x + preRankTxt.width,preRankTxt.y,textFormat,96,25,this);
			
			icon = new Sprite();
			icon.mouseChildren = icon.mouseEnabled = false;
			icon.x  = thisWeekRankTxt.x + thisWeekRankTxt.width -15;
			icon.y = thisWeekRankTxt.y + thisWeekRankTxt.height/4;
			this.addChild(icon);
		}
		
		private function setValue(thisWeekRank:int,familyName:String,thisWeekGrace:int,preRank:int,preGrace:int):void{
			thisWeekRankTxt.text = thisWeekRank.toString();
			familyNameTxt.text = familyName;
			thisWeekGraceTxt.text = thisWeekGrace.toString();
			if(preRank == 0){
				preRankTxt.text = "未上榜";
			}else{
				preRankTxt.text = preRank.toString();
			}
			preGraceTxt.text = preGrace.toString();
		}
		
		override public function get data():Object{
			return super.data;
		}
		
		override public function set data(value:Object):void{
			super.data = value;
			var graceVo:p_family_gongxun_rank = value as p_family_gongxun_rank;
			setValue(graceVo.ranking,graceVo.family_name,graceVo.gongxun,graceVo.lastweek_ranking,graceVo.lastweek_gongxun);
			var bg:Bitmap;
			//o1:↓，o2:↑,o3:-
			if(graceVo.ranking > graceVo.lastweek_ranking){//排名下降了
				if(graceVo.lastweek_ranking == 0){//如果上一周没上榜，本周上榜了，那就是排名上升了
					bg = Style.getBitmap(GameConfig.T1_VIEWUI,"o2");
				}else{
					bg = Style.getBitmap(GameConfig.T1_VIEWUI,"o1");
				}
			}else if(graceVo.ranking < graceVo.lastweek_ranking){//排名上升了
				bg = Style.getBitmap(GameConfig.T1_VIEWUI,"o2");
			}else if(graceVo.ranking == graceVo.lastweek_ranking){
				bg = Style.getBitmap(GameConfig.T1_VIEWUI,"o3");
			}while(icon.numChildren){
				icon.removeChildAt(0);
			}
			icon.addChild(bg);
			
			if(GlobalObjectManager.getInstance().user.base.family_id == graceVo.family_id){
				thisWeekRankTxt.textColor = 0xffcc00;
				familyNameTxt.textColor = 0xffcc00;
				thisWeekGraceTxt.textColor = 0xffcc00;
				preRankTxt.textColor = 0xffcc00;
				preGraceTxt.textColor = 0xffcc00;
			}else{
				thisWeekRankTxt.textColor = 0xffffff;
				familyNameTxt.textColor = 0xffffff;
				thisWeekGraceTxt.textColor = 0xffffff;
				preRankTxt.textColor = 0xffffff;
				preGraceTxt.textColor = 0xffffff;
			}
		}
	}
}