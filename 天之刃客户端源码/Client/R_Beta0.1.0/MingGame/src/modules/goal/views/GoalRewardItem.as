package modules.goal.views {
	import com.globals.GameConfig;
	import com.ming.managers.ToolTipManager;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import modules.mission.vo.MissionPropRewardVO;
	import modules.mission.vo.MissionRewardVO;
	import modules.mypackage.managers.ItemLocator;
	import modules.mypackage.views.GoodsItem;
	import modules.mypackage.views.ItemToolTip;
	import modules.mypackage.vo.BaseItemVO;

	public class GoalRewardItem extends Sprite {
		private var bg:Sprite;
		private var goodsItem:GoodsItem;

		public function GoalRewardItem() {
			init();
		}

		private function init():void {
			mouseChildren=false;
			useHandCursor=buttonMode=true;
			bg=Style.getSpriteBitmap(GameConfig.T1_VIEWUI,"packItemBg");;
			bg.width = 40; 
			bg.height = 40;
			goodsItem=new GoodsItem(null);
			goodsItem.x=2;
			goodsItem.y=2;
			bg.addChild(goodsItem);
			addChild(bg);
			
			addEventListener(MouseEvent.ROLL_OVER, onRollOver);
			addEventListener(MouseEvent.ROLL_OUT, onRollOut);
		}

		private function onRollOver(event:MouseEvent):void {
			var point:Point = new Point(this.x, this.y);
			var globalPoint:Point = parent.localToGlobal(point);
			ItemToolTip.show(this._baseItemVO, globalPoint.x+this.width, globalPoint.y, false);
		}

		private function onRollOut(event:MouseEvent):void {
			ItemToolTip.hide();
		}

		private var _data:Object;
		private var _baseItemVO:BaseItemVO;

		public function set data(value:Object):void {
			_data=value;
			if (_data) {
				this._baseItemVO=_data as BaseItemVO;
				goodsItem.updateContent(this._baseItemVO);
			}
		}

		public function get data():Object {
			return _data;
		}
	}
}
