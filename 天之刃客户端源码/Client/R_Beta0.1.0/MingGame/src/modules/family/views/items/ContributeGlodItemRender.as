package modules.family.views.items {
	import com.common.GlobalObjectManager;
	import com.ming.ui.controls.core.UIComponent;
	import com.utils.ComponentUtil;
	import com.utils.HtmlUtil;
	
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import proto.common.p_role_family_donate_info;

	public class ContributeGlodItemRender extends UIComponent {
		private var indexTF:TextField;
		private var nameTF:TextField;
		private var pointTF:TextField;
		public function ContributeGlodItemRender() {
			var tf:TextFormat = new TextFormat("Tahoma", 12, 0xF6F5CD);
			tf.align = TextFormatAlign.CENTER;
			indexTF = ComponentUtil.createTextField("",0,2,tf,40,24,this);
			nameTF = ComponentUtil.createTextField("",indexTF.x+indexTF.width,2,tf,100,24,this);
			pointTF = ComponentUtil.createTextField("",nameTF.x+nameTF.width,2,tf,100,24,this);
		}
		
		override public function set data(value:Object):void{
			super.data = value;
			if(!value){
				return;
			}
			var vo:p_role_family_donate_info = value.vo;
			if(vo.role_id == GlobalObjectManager.getInstance().user.attr.role_id){
				indexTF.htmlText = HtmlUtil.font(String(value.index),"#00ff00");
				nameTF.htmlText = HtmlUtil.font(vo.role_name,"#00ff00");
				pointTF.htmlText = HtmlUtil.font(String(vo.donate_amount),"#00ff00");
			}else{
				indexTF.htmlText = HtmlUtil.font(String(value.index),"#F6F5CD");
				nameTF.htmlText = HtmlUtil.font(vo.role_name,"#F6F5CD");
				pointTF.htmlText = HtmlUtil.font(String(vo.donate_amount),"#F6F5CD");
			}
		}
	}
}