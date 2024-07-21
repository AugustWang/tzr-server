package modules.bank.views
{
	import com.ming.ui.controls.core.UIComponent;
	
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import modules.bank.BankConstant;
	
	public class ListHeader extends UIComponent
	{
		public function ListHeader()
		{
			super();
			this.width = 250;//250;
			this.height = 20;
			var bankHeadBg:Sprite = Style.getViewBg("headerBar");
			bankHeadBg.scaleX = 0.5;
			bankHeadBg.y = 1;//3;
			addChild(bankHeadBg);
		}
		
		private var _typeName:String;
		private var _typeNameTF:TextField;
		private var _perYBTF:TextField;
		private var _YBNumTF:TextField;
		private var _operatingTF:TextField;
		public function setupUI(typeName:String=""):void
		{
			_typeName= typeName==""?"个人委托":"市场委托";
			var textFormat:TextFormat = new TextFormat("Tahoma",12,0xffffff);
			if(_typeName == "个人委托")
			{
				_typeNameTF = BankConstant.createTextField(_typeName,8,5,54,20,textFormat,this);
				_perYBTF = BankConstant.createTextField("元宝单价",_typeNameTF.x + _typeNameTF.width+10,5,54,20,textFormat,this);
				_YBNumTF = BankConstant.createTextField("元宝数量",_perYBTF.x + _perYBTF.width+10,5,54,20,textFormat,this);
				_operatingTF = BankConstant.createTextField("操作",_YBNumTF.x + _YBNumTF.width+10,5,35,20,textFormat,this);
			}else
			{
				_typeNameTF = BankConstant.createTextField(_typeName,8,5,54,20,textFormat,this);
				_perYBTF = BankConstant.createTextField("元宝单价",_typeNameTF.x + _typeNameTF.width+10,5,69,20,textFormat,this);
				_YBNumTF = BankConstant.createTextField("元宝数量",_perYBTF.x + _perYBTF.width+10,5,59,20,textFormat,this);
				_operatingTF =  BankConstant.createTextField("操作",_YBNumTF.x + _YBNumTF.width+10,5,35,20,textFormat,this);
			}
		}
	}
}