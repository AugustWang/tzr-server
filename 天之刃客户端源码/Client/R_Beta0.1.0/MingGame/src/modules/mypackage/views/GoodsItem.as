package modules.mypackage.views
{	
	import com.ming.ui.controls.Image;
	import com.ming.ui.style.StyleManager;
	
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import modules.broadcast.BroadcastModule;
	import modules.broadcast.views.BroadcastView;
	import com.utils.ComponentUtil;
	import modules.mypackage.managers.ItemLocator;
	import modules.mypackage.vo.BaseItemVO;
	import modules.mypackage.vo.EquipVO;

	/**
	 * 物品项，包括物品和数字
	 */ 
	public class GoodsItem extends Sprite
	{
		public var itemVO:BaseItemVO;
		private var content:GoodsImage;
		private var countlb:TextField;
		public function GoodsItem(itemVO:BaseItemVO)
		{
			this.itemVO = itemVO;
			content = new GoodsImage();
			addChildAt(content,0);
			if(itemVO){
				content.setImageContent(itemVO,itemVO.path);
				if(!(itemVO is EquipVO)){
					createCountLabel(itemVO.num);	
				}
			}
			mouseEnabled = false;
			mouseChildren = false;
		}
		
		public function updateContent(item:BaseItemVO):void{
			this.itemVO = item;
			content.setImageContent(item,item.path);
			if(countlb == null && !(itemVO is EquipVO)){
				createCountLabel(itemVO.num);	
			}else if(countlb && !(itemVO is EquipVO)){
				updateCount(itemVO.num);
			}else if(countlb && contains(countlb)){
				removeChild(countlb);
				countlb = null;
			}
		}
		
		private function createCountLabel(num:int):void{
			var tf:TextFormat = StyleManager.textFormat;
			tf.size = 11;
			countlb = ComponentUtil.createTextField("",0,18,tf,33,NaN,this);
			countlb.filters = [new GlowFilter(0x000000)];
			updateCount(num);
			countlb.selectable = false;		
			countlb.autoSize = "right";	
		}
		
		public function updateCount(count:int):void{
			if(countlb){
				if(count > 1){
					countlb.text = count.toString();
				}else{
					countlb.text = "";
				}
			}	
		}
	}		
}