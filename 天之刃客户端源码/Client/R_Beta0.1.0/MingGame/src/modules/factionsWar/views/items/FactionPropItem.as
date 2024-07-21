package modules.factionsWar.views.items
{
	import com.events.ParamEvent;
	import com.ming.core.IDataRenderer;
	import com.ming.ui.controls.Button;
	import com.ming.ui.layout.LayoutUtil;
	import com.utils.ComponentUtil;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import modules.factionsWar.FactionWarDataManager;
	import modules.factionsWar.views.FactionsWarView;
	
	public class FactionPropItem extends Sprite implements IDataRenderer
	{
		private var prop:TextField; //道具名
		private var state:TextField; //状态
		private var cost:TextField; //消耗国银价格
		private var handlerBtn:Button;
		private var typeid:int; //消耗国银价格
		private var vo:Object; 
		public function FactionPropItem()
		{
			super();
			var tf:TextFormat=Style.textFormat;
			tf.align="center";
			prop=ComponentUtil.createTextField("", 0, 0, tf, 120, 22, this);
			state=ComponentUtil.createTextField("", 0, 0, tf, 120, 22, this);
			cost=ComponentUtil.createTextField("", 0, 0, tf, 120, 22, this);
			LayoutUtil.layoutHorizontal(this);
			
			handlerBtn = ComponentUtil.createButton("",cost.x+cost.width+15,0,50,23,this);
			handlerBtn.addEventListener(MouseEvent.CLICK,clickHandler);
		}
		
		private function clickHandler(event:MouseEvent):void{
			var typeId:int;
			if(handlerBtn.label == "招募"){
				typeid=FactionWarDataManager.getGuardTypeid(true, vo.pvo.max_guarder_level);
			}else{
				typeid=FactionWarDataManager.getRoadBlock();
			}
			var ee:ParamEvent=new ParamEvent(FactionsWarView.BUYGUARDER_EVENT,typeid,true);
			this.dispatchEvent(ee);
		}
		
		public function set data(obj:Object):void{
			prop.text=obj.name;
			state.text=obj.state;
			cost.text=obj.cost;
			if(obj.name == "拒马"){
				handlerBtn.label = "放置";
			}else{
				handlerBtn.label = "招募";
			}
			handlerBtn.enabled = obj.enabled;
			typeid=obj.typeid;
			vo=obj;
		}
		
		
		public function get data():Object
		{
			return vo;
		}
	}
}