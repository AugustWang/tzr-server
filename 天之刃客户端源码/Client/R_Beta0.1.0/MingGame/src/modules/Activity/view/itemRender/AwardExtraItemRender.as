package modules.Activity.view.itemRender {
	import com.common.GlobalObjectManager;
	import com.globals.GameConfig;
	import com.ming.ui.controls.core.UIComponent;
	import com.utils.ComponentUtil;
	import com.utils.HtmlUtil;
	
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.filters.ColorMatrixFilter;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import modules.Activity.vo.AwardVo;

	public class AwardExtraItemRender extends UIComponent {
		private var rewardTxt:TextField;
		private var imgArr:Array; //=[];

		public function AwardExtraItemRender() {
			super();
			initView();
		}

		private function initView():void {
			drawLine();

			var tf:TextFormat=new TextFormat("Tahoma", 12, 0xACDC90);
			rewardTxt=ComponentUtil.createTextField("", 5, 0, tf, 247, 44, this); /*今日活跃度≥3，可领取：角色经验：XXXX*/
			rewardTxt.multiline=rewardTxt.wordWrap=true;
			rewardTxt.filters = Style.textBlackFilter;

			this.validateNow();
		}

		override public function set data(value:Object):void {
			//drawLine();

			super.data=value;
			var vo:AwardVo=value as AwardVo;


//			if (vo.isMatch && !vo.isRewarded) {
				rewardTxt.htmlText=HtmlUtil.fontBr("完成"+vo.id+"个","#65E035",12)+ HtmlUtil.fontBr(+ getExp(vo.expAdd, vo.expMult) + "经验","#fffd4b");

//			} else {
//				rewardTxt.htmlText="<font color='#8D8D8D'>完成 " + vo.id + " 个\n额外奖励：" + getExp(vo.expAdd, vo.expMult) + "经验</font>";
//			}

			while (items && items.length > 0) {
				var displayobj:DisplayObject=items.shift() as DisplayObject;
				removeChild(displayobj);
			}

			this.validateNow();
			showItemImg(vo); //vo.itemArr
		}

		private var line:Bitmap;
		private function drawLine():void {
			line = Style.getBitmap(GameConfig.T1_VIEWUI,"hightLightLine");
			line.width = 140;
			line.x=5;
			line.y = 73;
			addChild(line);
		}

		private function getExp(add:int, mult:int):int {
			var exp:int=0;
			var lv:int=GlobalObjectManager.getInstance().user.attr.level;
			exp=add + lv * mult;
			return exp;
		}
		
		private var items:Array;
		private function showItemImg(vo:AwardVo):void {
			var arr:Array=vo.itemArr;
			if (!arr || arr.length == 0)
				return;
			items = [];
			for (var i:int=0; i < arr.length; i++) {
				var obj:XML=arr[i];

				var itemImg:ActGoodsItem=new ActGoodsItem(int(obj.@itemId), int(obj.@num));
				itemImg.x=5 + 40 * i;
				itemImg.y=31;
				items.push(addChild(itemImg));
//				if (!vo.isMatch) { // 0.212671   0.715160    0.072169
//					itemImg.filters=[new ColorMatrixFilter([0.212671, 0.715160, 0.072169, 0, 0, 0.212671, 0.715160, 0.072169,
//						0, 0, 0.212671, 0.715160, 0.072169, 0, 0, 0, 0, 0, 1, 0])];
//						//new ColorMatrixFilter([0.2225 ,7169 ,0606,0,0, 0.2225 ,7169 ,0606,0,0, 0.2225 ,7169 ,0606,0,0, 0,0,0,1,0] ) 变白了。
//
//				} else {
//					itemImg.filters=[];
//				}
			}

		}

		override public function dispose():void {
			super.dispose();
			while (this.numChildren > 0) {
				var displayobj:DisplayObject=this.getChildAt(0);
				removeChild(displayobj);
				displayobj=null;
			}

		}
	}
}


