package modules.Activity.view.itemRender
{
	import com.common.FilterCommon;
	import com.common.GlobalObjectManager;
	import com.ming.core.IDataRenderer;
	import com.ming.ui.controls.Button;
	import com.ming.ui.layout.LayoutUtil;
	import com.scene.tile.Pt;
	import com.utils.ComponentUtil;
	import com.utils.PathUtil;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import modules.Activity.ActivityModule;
	import modules.Activity.activityManager.BossGroupManager;
	import modules.Activity.vo.BossGroupVO;
	import modules.broadcast.views.Tips;
	
	public class BossGroupItem extends Sprite implements IDataRenderer
	{
		private var bossName:TextField;
		private var level:TextField;
		private var state:TextField;
		private var position:TextField;
		private var attention:Button;
		private var carry:Button;
		public function BossGroupItem()
		{
			super();
			var centerTf:TextFormat = Style.textFormat;
			centerTf.align = "center";
			bossName = ComponentUtil.createTextField("",0,4,centerTf,120,20,this);
			bossName.filters = FilterCommon.FONT_BLACK_FILTERS;
			
			level = ComponentUtil.createTextField("",0,4,centerTf,43,20,this);
			level.filters = FilterCommon.FONT_BLACK_FILTERS;
			
			state = ComponentUtil.createTextField("",0,4,centerTf,72,20,this);
			state.filters = FilterCommon.FONT_BLACK_FILTERS;
			
			position = ComponentUtil.createTextField("",0,4,centerTf,78,20,this);
			position.filters = FilterCommon.FONT_BLACK_FILTERS;
			position.mouseEnabled = true;
			position.addEventListener(TextEvent.LINK,positionLinkHandler);
			
			LayoutUtil.layoutHorizontal(this);
			
			attention = ComponentUtil.createButton("关注",position.x+position.width+2,2,40,24,this);
			carry = ComponentUtil.createButton("传送",attention.x+attention.width+2,2,40,24,this);
			attention.addEventListener(MouseEvent.CLICK,attentionHandler);
			carry.addEventListener(MouseEvent.CLICK,carryHandler);
		}
		
		private function attentionHandler(event:MouseEvent):void{
			if(attention.label == "关注"){
				_bossGroupVO.attention = true;
				attention.textColor = 0xffff00;
				attention.label = "取消";
			}else{
				_bossGroupVO.attention = false;
				attention.textColor = 0xffffff;
				attention.label = "关注";
			}
		}
		
		private function carryHandler(event:MouseEvent):void{
			if(_bossGroupVO.state != BossGroupVO.START){
				Tips.getInstance().addTipsMsg("Boss还未出现，无需前往击杀");
				return;
			}
			if(GlobalObjectManager.getInstance().user.attr.level < _bossGroupVO.level){
				Tips.getInstance().addTipsMsg("未到到"+_bossGroupVO.level+"级，不能前往该地图");
				return;
			}
			ActivityModule.getInstance().requestBossGroupTransfer(_bossGroupVO.id);
		}
		
		private function positionLinkHandler(event:TextEvent):void{
			PathUtil.goto(_bossGroupVO.mapId,new Pt(_bossGroupVO.tx,0,_bossGroupVO.ty));
		}
		
		private function timeTickHandler():void{
			state.htmlText = _bossGroupVO.stateDesc;
			position.htmlText = _bossGroupVO.positionHtml;
		}
		
		private var _bossGroupVO:BossGroupVO;
		public function set data(value:Object):void
		{
			_bossGroupVO = value as BossGroupVO;
			if(_bossGroupVO){
				bossName.text = _bossGroupVO.name;
				level.text = _bossGroupVO.level.toString();
				_bossGroupVO.callBack = timeTickHandler;
				if(BossGroupManager.getInstance().hasAttention(_bossGroupVO.id)){
					attention.textColor = 0xffff00;
					attention.label = "取消";
				}else{
					attention.textColor = 0xffffff;
					attention.label = "关注";
				}
			}
		}
		
		public function get data():Object
		{
			return _bossGroupVO;
		}
	}
}