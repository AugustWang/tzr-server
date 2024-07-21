package modules.family.views.items
{
	import com.globals.GameConfig;
	import com.ming.core.IDataRenderer;
	import com.ming.ui.controls.Button;
	import com.utils.ComponentUtil;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import modules.family.FamilyItemEvent;
	import modules.family.FamilyModule;
	
	import proto.common.p_family_request;
	
	public class ApplicationItem extends Sprite implements IDataRenderer
	{
		public static const tf:TextFormat = new TextFormat("Arail",12,0xffffff,null,null,null,null,null,"center");
		private var playerText:TextField;
		private var level:TextField;
		private var action:Sprite;
		public function ApplicationItem()
		{
			
			playerText = ComponentUtil.createTextField("",0,2,tf,100,25,this);
			level = ComponentUtil.createTextField("",100,2,tf,100,25,this);
			action = new Sprite()
			action.x = 200;
			action.y = 3;
			addChild(action);
			
			var pz:Button = new Button();
			pz.width = 35;
			pz.height = 18;
			pz.x = 40;
			pz.label = "批准";
			pz.bgSkin = Style.getButtonSkin("yellow","yellowOver","yellowDown",null,GameConfig.T1_UI,new Rectangle(3,3,9,9));
			pz.addEventListener(MouseEvent.CLICK,onPZHandler);
			action.addChild(pz);
			
			var jj:Button = new Button();
			jj.width = 35;
			jj.height = 18;
			jj.x = 100;
			jj.label = "拒绝";
			jj.bgSkin = Style.getButtonSkin("yellow","yellowOver","yellowDown",null,GameConfig.T1_UI,new Rectangle(3,3,9,9));
			action.addChild(jj);
			jj.addEventListener(MouseEvent.CLICK,onJJHandler);
		}
		
		private var _data:Object;
		public function set data(value:Object):void{
			this._data = value;
			if(_data){
				wrapperContent();
			}
		}
		
		public function get data():Object{
			return _data;
		}
		
		private function wrapperContent():void{
			var info:p_family_request = data as p_family_request;
			if(info){
				playerText.text = info.role_name;
				level.text = info.level.toString();
			}
		}	
				
		private function onPZHandler(event:MouseEvent):void{
			var info:p_family_request = data as p_family_request;
			FamilyModule.getInstance().agreeJoinFamily(info.role_id);
			dispatchEvent(new FamilyItemEvent(info,FamilyItemEvent.REMOVE_ITEM));
		}
		
		private function onJJHandler(event:MouseEvent):void{
			var info:p_family_request = data as p_family_request;
			FamilyModule.getInstance().refuseJoinFamily(info.role_id);
			dispatchEvent(new FamilyItemEvent(info,FamilyItemEvent.REMOVE_ITEM));	
		}

	}
}