package modules.finery.views.item
{
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.utils.getTimer;
	
	import modules.mypackage.ItemConstant;
	import modules.mypackage.vo.BaseItemVO;
	import modules.mypackage.vo.EquipVO;
	import modules.mypackage.vo.StoneVO;

	/**
	 *孔和石头 
	 */	
	public class StoneBox extends Sprite
	{
		private var _data:EquipVO;
		
		public function StoneBox()
		{
			//initUI();
		}
		
		public function initUI(parent:Bitmap):void{
			var bg:StoneItem;
			for(var i:int = 0; i < 6; i++){
				bg = new StoneItem();
				addChild(bg);
			}
			getChildAt(0).x = -bg.width - 10;
			getChildAt(1).x = -bg.width - 10;
			getChildAt(1).y = bg.height + 10;
			getChildAt(2).x = -5;
			getChildAt(2).y = 2*bg.height+8;
			getChildAt(3).x = parent.width+5-bg.width;
			getChildAt(3).y = 2*bg.height+8;
			getChildAt(4).x = parent.width+10;
			getChildAt(4).y = bg.height + 10;
			getChildAt(5).x = parent.width+10;
		}
		
		public function set data(value:*):void{
			_data = value as EquipVO;
			if(_data == null){
				this.visible = false;
			}else{
				for(var i:int = 0; i < 6; i++){
					StoneItem(getChildAt(i)).clean();
				}
				for(i=0; i < _data.punch_num; i++){
					StoneItem(getChildAt(i)).isOpen(true);
				}
				if(_data.stones){
					for(i=0; i < _data.stones.length; i++){
						var stoneVo:StoneVO = ItemConstant.wrapperItemVO(_data.stones[i]) as StoneVO;
						StoneItem(getChildAt(i)).setContent(stoneVo);
					}
				}
				this.visible = true;
			}
		}
	}
}
import com.globals.GameConfig;

import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.Point;

import modules.mypackage.views.GoodsImage;
import modules.mypackage.views.ItemToolTip;
import modules.mypackage.vo.BaseItemVO;
import modules.mypackage.vo.StoneVO;

class StoneItem extends Sprite{
	private var openBG:Bitmap;
	private var closeBG:Bitmap;
	private var content:GoodsImage;
	private var data:StoneVO;
	public function StoneItem():void{
		isOpen();
	}
	
	public function clean():void{
		isOpen(false);
		setContent(null);
	}
	
	public function setContent(vo:StoneVO):void{
		data = vo;
		if(vo){
			if(!content){
				content = new GoodsImage();
				addChild(content);
				content.x = 4;
				content.y = 4;
				content.addEventListener(MouseEvent.ROLL_OVER,onRollOverHandler);
				content.addEventListener(MouseEvent.ROLL_OUT,onRollOutHandler);
			}
			content.setImageContent(vo,vo.path);
			content.visible = true;
		}else{
			if(content){
				content.visible = false;
			}	
		}
	}
	
	private function onRollOverHandler(evt:MouseEvent):void{
		if(data){
			var point:Point = new Point(content.x+content.width+2,content.y);
			point = this.localToGlobal(point);
			ItemToolTip.show(BaseItemVO(data),point.x,point.y,false);
		}
	}
	
	private function onRollOutHandler(evt:MouseEvent):void{
		ItemToolTip.hide();
	}
	
	public function isOpen(flag:Boolean = false):void{
		if(flag){
			if(closeBG)closeBG.visible = false;
			if(!openBG){
				openBG = Style.getBitmap(GameConfig.T1_VIEWUI,"stoneOpenBG");
				addChild(openBG);
			}
			openBG.visible = true;
		}else{
			if(openBG)openBG.visible = false;
			if(!closeBG){
				closeBG = Style.getBitmap(GameConfig.T1_VIEWUI,"stoneCloseBG");
				addChild(closeBG);
			}
			closeBG.visible = true;
		}
	}
}