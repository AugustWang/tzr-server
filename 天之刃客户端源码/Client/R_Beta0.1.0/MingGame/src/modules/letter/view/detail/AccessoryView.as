package modules.letter.view.detail
{
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.core.UIComponent;
	import com.ming.ui.skins.Skin;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	import com.utils.ComponentUtil;
	import modules.mypackage.managers.PackManager;
	import modules.mypackage.vo.BaseItemVO;
	
	import proto.common.p_goods;
	
	public class AccessoryView extends UIComponent
	{
		private var getComponent:UIComponent;
		private var text:TextField;
		private var item:AccessoryItem;
		private var type:int;
		
		private var addAttachBtn:Button;
		public var getAttachBtn:Button;
		public static const LETTER_DETAIL:int = 1;
		public static const LETTER_WRITE:int = 2;
		
		public function AccessoryView(id:int)
		{
			super();
			
			this.type = id;
			this.width = 275;
			this.height = 33;
			this.y = 273;
			
			setType(id);
		}
		
		private function setType(value:int):void{
			if(value == LETTER_DETAIL){
				item = new DetailAccessoryItem();//信件详情面板 的附件
				item.x = 20;
				item.y = -10;
				getAttachBtn = ComponentUtil.createButton("领取",item.x + item.width + 10,item.y + item.height/4,50,25,this);
				getAttachBtn.name = "getAttachBtn";
				addChild(item);
			}else{
				item = new WriteAccessoryItem();//写信面板的附件
				item.x = 20;
				item.y = -10;
				addChild(item);
				
				addAttachBtn = ComponentUtil.createButton("添加附件",item.x + item.width + 10,item.y + item.height/4,70,25,this);
				addAttachBtn.name = "addAttachBtn";
			}
		}
		/**
		 *点击添加的附件 
		 * @param func
		 * 
		 */		
		public function setClickFun(func:Function,name:String):void{
			
			if(func != null){
				if(name == "addAttachBtn"){//添加附件
					addAttachBtn.addEventListener(MouseEvent.CLICK,func);
				}else{//领取
					getAttachBtn.addEventListener(MouseEvent.CLICK,func);
				}
			}
		}
		
		/**
		 * 当在信件详情面板中，设置数据函数
		 * @param data
		 * 
		 */		
		public function setData(data:Object, isSelfSend:Boolean):void{
			DetailAccessoryItem(item).setParam(data[0] as p_goods, isSelfSend);
		}
		public function getDetailData():p_goods{
			return DetailAccessoryItem(item).param;
		}
		public function unlock(bool:Boolean):void{
			DetailAccessoryItem(item).unlock(bool);
		}
		
		public function getAccessory():p_goods{
			return DetailAccessoryItem(item).param;
		}
		
		/**
		 * 在写信面板中，设置数据函数
		 * @param data
		 * 
		 */		
		public function getData():BaseItemVO{
			return WriteAccessoryItem(item).param;
		}
		
		public function reset():void{
			WriteAccessoryItem(item).reset();
		}
		
		public function returnData():void{
			WriteAccessoryItem(item).returnCurrentData();
		}
		
	}
}