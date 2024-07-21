package com.components
{
	import com.globals.GameConfig;
	import com.ming.managers.ToolTipManager;
	import com.ming.ui.style.StyleManager;
	import com.utils.ComponentUtil;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import modules.mypackage.views.GoodsImage;
	import modules.mypackage.views.ItemToolTip;
	import modules.mypackage.vo.BaseItemVO;
	import modules.mypackage.vo.EquipVO;
	
	public class GoodsBox extends Sprite
	{
		public static const FULL_INFO:String = "FULL_INFO";
		public static const BASE_INFO:String = "BASE_INFO"
		public var tipType:String = BASE_INFO;
		private var content:GoodsImage;
		private var countlb:TextField;
		public function GoodsBox(){
			addChild(Style.getBitmap(GameConfig.T1_VIEWUI,"packItemBg"));
			addEventListener(MouseEvent.ROLL_OVER,rollOverHandler);
			addEventListener(MouseEvent.ROLL_OUT,rollOutHandler);
			mouseChildren = false;
			content = new GoodsImage();
			content.x = content.y = 4;
			addChild(content);
		}
		
		private var _baseItemVO:BaseItemVO;
		public function set baseItemVO(vo:BaseItemVO):void{
			_baseItemVO = vo;
			if(_baseItemVO){
				updateContent();
			}
		}
		
		public function get baseItemVO():BaseItemVO{
			return _baseItemVO;
		}
		
		protected function rollOverHandler(event:MouseEvent):void{
			if(_baseItemVO){
				var p:Point = new Point(x+width,y);
				p = parent.localToGlobal(p);
				if(tipType == FULL_INFO){
					ItemToolTip.show(_baseItemVO,p.x,p.y,false);
				}else{
					ToolTipManager.getInstance().show(_baseItemVO,0,p.x,p.y,"goodsToolTip");
				}
			}
		}
		
		protected function rollOutHandler(event:MouseEvent):void{
			if(tipType == FULL_INFO){
				ItemToolTip.hide();
			}else{
				ToolTipManager.getInstance().hide();
			}
		}
		
		public function updateContent():void{
			content.setImageContent(_baseItemVO,_baseItemVO.path);
			if(countlb == null && !(_baseItemVO is EquipVO)){
				createCountLabel(_baseItemVO.num);	
			}else if(countlb && !(_baseItemVO is EquipVO)){
				updateCount(_baseItemVO.num);
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