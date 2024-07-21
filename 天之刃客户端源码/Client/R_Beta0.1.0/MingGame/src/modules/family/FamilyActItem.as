package modules.family
{
	import com.ming.ui.controls.core.UIComponent;
	import com.utils.ComponentUtil;
	
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import proto.common.p_family_task;
	
	public class FamilyActItem extends UIComponent
	{
		private var actNameTxt:TextField ;
		private var actMethodTxt:TextField;
		private var actState:TextField;
		
		public function FamilyActItem()
		{
			super();
			this.width = 355;
			this.height = 26;
			
			var tf2:TextFormat = new TextFormat("Tahoma", 12, 0xF6F5CD,null,null,null,null,null,"left");
			actNameTxt = ComponentUtil.createTextField("",2,2,tf2,135,22,this);
			var tf:TextFormat = new TextFormat("Tahoma", 12, 0xF6F5CD,null,null,null,null,null,"center");
			actMethodTxt = ComponentUtil.createTextField("",actNameTxt.x + actNameTxt.width,2,tf,124,22,this);
			actState = ComponentUtil.createTextField("",actMethodTxt.x + actMethodTxt.width,2,tf,180,22,this);

		}
		
		override public function set data(value:Object):void
		{
			super.data = value;
			var vo:p_family_task = value as p_family_task;
			var stateStr:String = "";
			switch(vo.id)
			{
				case 10001:
					actNameTxt.text = "门派拉镖(25级)";
					if(vo.status==0)
						stateStr = "未发起";
					else if(vo.status==1)
						stateStr = "已发起";
					else if(vo.status==2)
						stateStr = "进行中";
					else if(vo.status==4)
						stateStr = "已结束";
					break;
				case 10002:
					actNameTxt.text = "门派普通BOSS";
					if(vo.status==0)
						stateStr = "未发起";
					else if(vo.status==1)
						stateStr = "进行中";
					else if(vo.status==2)
						stateStr = "已结束";
					break;
				
			}
			if(vo.status==3)
			{
				stateStr = "你未加入门派";
				actState.htmlText = "<font color = '#FF0000'>"+stateStr+"</font>";
			}
			else
				actState.text = stateStr;
			actMethodTxt.text = "掌门/长老组织";
			
		}
	}
}