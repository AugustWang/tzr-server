package modules.bank.views
{
	import com.ming.core.IDataRenderer;
	import com.ming.ui.controls.LinkButton;
	import com.ming.ui.controls.core.UIComponent;
	import com.utils.MoneyTransformUtil;
	
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import modules.bank.BankConstant;
	
	import proto.line.p_bank_sheet;
	import proto.line.p_bank_simple_sheet;
	
	public class BankItemRender extends UIComponent implements IDataRenderer
	{
		/**
		 * 上面的 listItem 
		 * 
		 */		
		public function BankItemRender()
		{
			setupUI();
		}
		
		private var _idTF:TextField;
		private var _perYBTF:TextField;
		private var _YBNumTF:TextField;
		private var _operatingBtn:LinkButton;
		private function setupUI():void
		{
			var textFormat:TextFormat = new TextFormat("Tahoma",12,0xece8bb,false,null,null,null,null,"center");//0xFFF799
			_idTF = BankConstant.createTextField("求购价1",0,0,65,22,textFormat,this);//new TextFormat(null,12,0x007100,true)
			_perYBTF = BankConstant.createTextField("1锭30两",_idTF.x + _idTF.width+5,0,65,22,textFormat,this);
			_YBNumTF = BankConstant.createTextField("50",_perYBTF.x + _perYBTF.width+5,0,65,22,textFormat,this);
			_operatingBtn = new LinkButton();
			_operatingBtn.buttonMode = true;
			_operatingBtn.useHandCursor = true;
			_operatingBtn.width = 60;//96;
			_operatingBtn.x = 186;// 188;//177//195;
			_operatingBtn.y = -3;
			_operatingBtn.textFormat(new TextFormat(null,12,0xcde644));//0xDEC38C
			_operatingBtn.label = "<u>撤单</u>";
			addChild(_operatingBtn);
		}

		private var _data:Object;
		override public function get data():Object
		{
			return _data;
		}
		
		override public function set data(value:Object):void
		{
			_data = value;
			_idTF.text = value.name+" ";
			itemID = value.id;
			_operatingBtn.label = value.operate
			_operatingBtn.addEventListener(MouseEvent.CLICK,value.callBackHandler);
			if(value.sheet is p_bank_sheet)
			{
				var vo1:p_bank_sheet = value.sheet as p_bank_sheet;
				sheetID = vo1.sheet_id;
				_perYBTF.text = MoneyTransformUtil.silverToOtherString(vo1.price);
				unitPrice = vo1.price;
				_YBNumTF.text = vo1.num.toString();
				YBNum = vo1.num;
			}else
			{
				var vo2:p_bank_simple_sheet = value.sheet as p_bank_simple_sheet;
				_perYBTF.text =  MoneyTransformUtil.silverToOtherString(vo2.price);
				unitPrice = vo2.price;
				_YBNumTF.text = vo2.num.toString();
				YBNum = vo2.num;
			}
		} 
		
		private var _sheetID:int
		public function set sheetID(value:int):void
		{
			_sheetID = value
		}
		
		public function get sheetID():int
		{
			return _sheetID;
		}
		
		private var _unitPrice:int;
		public function set unitPrice(value:int):void
		{
			_unitPrice = value;
		}
		
		public function get unitPrice():int
		{
			return _unitPrice;
		}
		
		private var _YBNum:int
		public function set YBNum(value:int):void
		{
			_YBNum = value;
		}
		
		public function get YBNum():int
		{
			return _YBNum;
		}
		
		private var _itemID:int;
		public function set itemID(value:int):void
		{
			_itemID = value
		}
		
		public function get itemID():int
		{
			return _itemID;
		}
	}
}