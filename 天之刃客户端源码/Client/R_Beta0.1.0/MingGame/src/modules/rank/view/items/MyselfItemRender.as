package modules.rank.view.items
{
	import com.common.GlobalObjectManager;
	import com.ming.ui.controls.core.UIComponent;
	
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import com.utils.ComponentUtil;
	import modules.rank.view.PlayerRankView;
	
	import proto.common.p_role_all_rank;
	
	public class MyselfItemRender extends UIComponent
	{
		private var numberTxt:flash.text.TextField;
		private var rankNameTxt:TextField;
		private var keyValueTxt:TextField;
		private var rankTxt:TextField;
		public function MyselfItemRender()
		{
			var textFormat:TextFormat = new TextFormat("Tahoma",12,0xffffff,null,null,null,null,null,TextFormatAlign.CENTER);
			numberTxt = ComponentUtil.createTextField("",2,2,textFormat,50,25,this);
			rankNameTxt = ComponentUtil.createTextField("",numberTxt.x + numberTxt.width,numberTxt.y,textFormat,80,25,this); 
			keyValueTxt = ComponentUtil.createTextField("",rankNameTxt.x + rankNameTxt.width,rankNameTxt.y,textFormat,250,25,this);
			rankTxt = ComponentUtil.createTextField("",keyValueTxt.x + keyValueTxt.width,keyValueTxt.y ,textFormat,50,25,this);
		}
		
		private function setValue(num:int,rankName:String,keyValue:String,ranking:int):void{
			numberTxt.text = num.toString();
			rankNameTxt.text = rankName;
			keyValueTxt.text = keyValue;
			rankTxt.text = ranking.toString();
		}
		
		override public function get data():Object{
			return super.data;
		}
		
		override public function set data(value:Object):void{
			super.data = value;
			setValue(value.number,value.rank_name,value.key_name+":"+value.key_value,value.ranking);
		}
	}
}