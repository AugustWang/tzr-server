package modules.Activity.view.itemRender {
	import com.common.FilterCommon;
	import com.common.GlobalObjectManager;
	import com.components.alert.Alert;
	import com.ming.ui.controls.core.UIComponent;
	import com.utils.ComponentUtil;
	
	import flash.events.TextEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.Dictionary;
	
	import modules.Activity.ActivityModule;
	import modules.Activity.activityManager.ActAwardLocator;
	import modules.heroFB.newViews.items.StarItem;
	import modules.mypackage.managers.PackManager;
	
	import proto.common.p_activity_info;

	public class EveryDayItem extends UIComponent {
		public static var ID:String="";

		private var actNameTxt:TextField;
		private var rewardTxt:TextField;
		private var minLevelTxt:TextField;
		private var actTimeTxt:TextField;
		private var actAddTxt:TextField;
		private var actCountTxt:TextField;
		private var xmlDict:Dictionary;

		public function EveryDayItem() {
			super();
			this.width=355;
			this.height=26;

			var tf2:TextFormat=new TextFormat("Tahoma", 12, 0xF6F5CD, null, null, null, null, null, "left");
			var tf:TextFormat=new TextFormat("Tahoma", 12, 0xF6F5CD, null, null, null, null, null, "center");
			
			actNameTxt=ComponentUtil.createTextField("", 10, 2, tf2, 120, 22, this,wrapperHandler);
			
			rewardTxt=ComponentUtil.createTextField("经验：", actNameTxt.x + actNameTxt.width, 2, tf2, 100,
				22, this,wrapperHandler);
			
			starItem = new StarItem();
			addChild(starItem);
			starItem.x = actNameTxt.x + actNameTxt.width + 30;
			starItem.y = -10;
			
			minLevelTxt=ComponentUtil.createTextField("", rewardTxt.x + rewardTxt.width, 2, tf, 50,
				22, this,wrapperHandler);
			
			actCountTxt=ComponentUtil.createTextField("", minLevelTxt.x + minLevelTxt.width, 2,
				tf, 70, 22, this,wrapperHandler);
			
			actTimeTxt=ComponentUtil.createTextField("", minLevelTxt.x + minLevelTxt.width, 2, tf, 70,
				22, this,wrapperHandler);
			
			actAddTxt=ComponentUtil.createTextField("", actTimeTxt.x + actTimeTxt.width, 2, tf, 78, 22,
				this,wrapperHandler);
			
			actCountTxt.mouseEnabled=true;
			actAddTxt.mouseEnabled=true;
			actAddTxt.addEventListener(TextEvent.LINK, onLinkHandler);

			xmlDict=new Dictionary();
		}
		
		private function wrapperHandler(txt:TextField):void{
			//txt.filters = FilterCommon.FONT_BLACK_FILTERS;	
		}
		
		private var voxml:Object;
		private var starItem:StarItem;

		override public function set data(value:Object):void {
			super.data=value;
			var vo:p_activity_info=value as p_activity_info;

			if (!vo) {
				return;
			}

			if (xmlDict[vo.id]) {
				voxml=xmlDict[vo.id];
			} else {
				voxml=ActAwardLocator.getInstance().getTodayObjById(vo.id);
				xmlDict[vo.id]=voxml;
			}


			if (voxml) {
				//级数不到的，全部变灰
				if(GlobalObjectManager.getInstance().user.attr.level < cutString(voxml.minLvl)){
					actNameTxt.htmlText="<font color='#6d7d70'>"+voxml.name+"</font>";
					minLevelTxt.htmlText="<font color='#6d7d70'>"+voxml.minLvl+"</font>";
					actTimeTxt.htmlText="<font color='#6d7d70'>"+voxml.time_segment+"</font>";
					actAddTxt.htmlText="";
					actCountTxt.htmlText = "";
					rewardTxt.htmlText="";
					starItem.visible=false;
					//级数不到，它不可能做过，所以不用判断
					//actCountTxt.htmlText="<font color='#6d7d70'>"+vo.done_times + "/" + vo.total_times+"</font>";
				}else{
					if(voxml.exp_stars != 0){
						rewardTxt.htmlText="经验：";
						starItem.visible=true;
						starItem.update(voxml.exp_stars,voxml.exp_stars);
					}
					actNameTxt.text=voxml.name;
					if (voxml.minLvl != 0) {
						minLevelTxt.text=voxml.minLvl;
					} else {
						minLevelTxt.text="-";
					}
					actTimeTxt.text="";
					if (voxml.npc_id && voxml.npc_id.length > 0 && voxml.link_name && voxml.link_name.length >
						0) {
						actAddTxt.htmlText="<font color='#01f701'><a href ='event:goto'><u> 前往</u></a> " +
							" <a href ='event:sendto'><u>传送 </u></a></font>";
					} else {
						actAddTxt.htmlText="";
					}
					
					if (vo.total_times > 0 && vo.done_times >= vo.total_times) {
						actCountTxt.htmlText="<font color='#00ff00'>(完成)</font>";
					} else {
						if (vo.total_times == 0) {
							actCountTxt.text="";
							actTimeTxt.text=voxml.time_segment;
						} else {
							actCountTxt.text=vo.done_times + "/" + vo.total_times;
						}
					}
				}
			}
		}
		
		/**
		 * 
		 * @param level
		 * @return 
		 * 把“10级”cut得到“10”的工具类
		 */		
		private function cutString(level:String):int{
			var length:int = level.length;
			var sub:String = level.substr(0,length-1);
			return int(sub);
		}

		private function onLinkHandler(evt:TextEvent):void {
			var fation:int=GlobalObjectManager.getInstance().user.base.faction_id;
			if (evt.text == "goto") {
//				ID = this.name;
				ActivityModule.getInstance().goto(this.voxml.npc_id[fation]);
			} else if (evt.text == "sendto") {
				ActivityModule.getInstance().sendtoNpc(this.voxml.npc_id[fation]);
			}
		}


	}
}