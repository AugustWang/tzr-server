package modules.duplicate.views.items
{

	import com.common.GlobalObjectManager;
	import com.events.ParamEvent;
	import com.ming.core.IDataRenderer;
	import com.utils.ComponentUtil;
	
	import flash.display.Sprite;
	import flash.events.TextEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import modules.duplicate.DuplicateConstant;
	import modules.duplicate.views.vo.DuplicateLeaderVO;
	import modules.mypackage.managers.ItemLocator;
	
	public class DuplicateLeaderItem extends Sprite implements IDataRenderer
	{
		private var indexText:TextField;
		private var roleNameText:TextField;
		private var itemText:TextField;
		private var posText:TextField;
		private var statusText:TextField;
		private var commondText:TextField;
		public function DuplicateLeaderItem(){
			var centerTmf:TextFormat =Style.textFormat;
			centerTmf.align=TextFormatAlign.CENTER;
			indexText = ComponentUtil.createTextField("",1,2,centerTmf,31,22,this);
			roleNameText = ComponentUtil.createTextField("",32,2,centerTmf,104,22,this);
			itemText = ComponentUtil.createTextField("",136,2,centerTmf,80,22,this);
			posText = ComponentUtil.createTextField("",216,2,centerTmf,52,22,this);
			posText.mouseEnabled = true;
			posText.addEventListener(TextEvent.LINK,onLinkEvent);
			statusText = ComponentUtil.createTextField("",268,2,centerTmf,52,22,this);
			commondText = ComponentUtil.createTextField("",320,2,centerTmf,52,22,this);
			commondText.mouseEnabled = true;
			commondText.addEventListener(TextEvent.LINK,onLinkEvent);
		}
		private var _data:Object;
		public function get data():Object{
			return _data;
		}
		
		public function set data(value:Object):void{
			_data = value;
			var vo:DuplicateLeaderVO = _data as DuplicateLeaderVO;
			var item:Object =  ItemLocator.getInstance().getGeneral(vo.item_id);
			indexText.text = vo.index.toString();
			roleNameText.text = vo.role_name;
			itemText.text = "【".concat(item.name).concat("】");
			if(vo.role_id != vo.cur_use_role_id){
				posText.htmlText = "<font color=\"#8D8D8D\">[" + vo.use_tx.toString()+"," + vo.use_ty.toString() +"]</font>";
				if(GlobalObjectManager.getInstance().user.base.role_id == vo.role_id){
					commondText.htmlText = "<font color=\"#8D8D8D\">队长召唤</font>";
				}else{
					commondText.htmlText = "<font color=\"#8D8D8D\">提醒队员</font>";
				}
			}else{
				posText.htmlText = "<a href=\"event:goto\"><font color=\"#3BE450\"><u>[" + vo.use_tx.toString()+"," + vo.use_ty.toString() +"]</u></font></a>";
				if(GlobalObjectManager.getInstance().user.base.role_id == vo.role_id){
					commondText.htmlText = "<a href=\"event:leader_commond\"><font color=\"#3BE450\"><u>队长召唤</u></font></a>";
				}else{
					commondText.htmlText = "<a href=\"event:leader_commond\"><font color=\"#3BE450\"><u>提醒队员</u></font></a>";
				}
			}
			
			statusText.text = vo.view_status;
			
		}
		private function onLinkEvent(event:TextEvent):void{
			if(event.text == "goto"){
				dispatchEvent(new ParamEvent(DuplicateConstant.LEADER_EVENT,{type:DuplicateConstant.GO_TO,data:_data},true));
			}
			if(event.text == "leader_commond"){
				dispatchEvent(new ParamEvent(DuplicateConstant.LEADER_EVENT,{type:DuplicateConstant.LEADER_EVENT_NOTICE,data:_data},true));
			}
		}
	}
}