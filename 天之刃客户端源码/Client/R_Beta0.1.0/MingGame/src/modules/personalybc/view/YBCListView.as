package modules.personalybc.view
{
	import com.components.BasePanel;
	import com.ming.events.CloseEvent;
	import com.utils.ComponentUtil;
	import com.utils.HtmlUtil;
	
	import flash.display.Sprite;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	public class YBCListView extends BasePanel
	{
		private var txt1:TextField;
		private var txt2:TextField;
		private var txt3:TextField;
		private var txt4:TextField;
		
		public function YBCListView()
		{
			super();
			this.title = "镖车奖励"
			this.width = 350;
			this.height = 170;
			
			var ui:Sprite=new Sprite();
			ui.x=0;
			ui.width=300;
			ui.height=135;
			this.addChild(ui);
			
			var form:TextFormat=new TextFormat;
			txt1=ComponentUtil.createTextField("", 15, 10, form, this.width,300, this);
			txt1.filters=[new GlowFilter(0,1,2,2,2)];
			
			txt2=ComponentUtil.createTextField("", 80, 10, form, this.width,300, this);
			txt2.filters=[new GlowFilter(0,1,2,2,2)];
			
			txt3=ComponentUtil.createTextField("", 130, 10, form, this.width,300, this);
			txt3.filters=[new GlowFilter(0,1,2,2,2)];
			
			txt4=ComponentUtil.createTextField("", 220, 10, form, this.width,300, this);
			txt4.filters=[new GlowFilter(0,1,2,2,2)];
			
			
		}
		override protected function closeHandler(event:CloseEvent = null):void
		{
			if(this.parent){
				this.parent.removeChild(this)
			}
		}
		
		public function  updata(array:Array):void
		{			
			var txtHtml1:String = '<FONT COLOR="#FFFFFF"><B>镖车颜色</B></FONT>\n';
			var txtHtml2:String = '<FONT COLOR="#FFFFFF"><B>经验</B></FONT>\n';
			var txtHtml3:String = '<FONT COLOR="#FFFFFF"><B>绑定银子</B></FONT>\n';
			var txtHtml4:String = '<FONT COLOR="#FFFFFF"><B>不绑定银子</B></FONT>\n';
			var bcNames:Array = ["    白色    ","    绿色     ","    蓝色    ","    紫色    ","    橙色    "];
			var bcColors:Array = ["#ffffff","#10ff04","#00c6ff","#ff00c6","#FF6c00"];
			var html:String = "";
			for(var i:int=0;i<array.length;i++){
				var bcDesc:Object = array[i];
				var bcHtml:String = "";
				txtHtml1 += HtmlUtil.font(bcNames[i], bcColors[i])+'\n';
				txtHtml2 += HtmlUtil.font(bcDesc.jy, bcColors[i])+'\n';
				txtHtml3 += HtmlUtil.font(bcDesc.bdyz, bcColors[i])+'\n';
				txtHtml4 += HtmlUtil.font((bcDesc.yz ? bcDesc.yz : '        无        '), bcColors[i])+'\n';
			}
			txt1.htmlText = txtHtml1;
			txt2.htmlText = txtHtml2;
			txt3.htmlText = txtHtml3;
			txt4.htmlText = txtHtml4;
			
		}
		private function txtColor(color:String, txt:String):String
		{
			var str:String="<font color='"+color+"'>" + txt + "<font>";
			return str;
		}
	}
}