package modules.family.views
{	
	import com.components.alert.Alert;
	import com.components.components.DragUIComponent;
	import com.managers.LayerManager;
	import com.managers.WindowManager;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.RadioButton;
	import com.ming.ui.controls.RadioButtonGroup;
	import com.ming.ui.style.StyleManager;
	import com.utils.ComponentUtil;
	
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import modules.family.FamilyModule;
	
	import proto.line.m_family_combine_panel_toc;

	public class CombineFamilyPanel extends DragUIComponent
	{
		private var titleField:TextField;
		private var btn_ok:Button;
		private var btn_cancel:Button;
		private var radios:RadioButtonGroup;
		private var choice_1:RadioButton;
		private var choice_2:RadioButton;
		private var familyCombineType:Array;
		private var combine_choice:m_family_combine_panel_toc;

		public function CombineFamilyPanel()
		{
			super();
			width = 360;
			height = 134;
			
			var tf:TextFormat = StyleManager.textFormat;
			tf.bold = true;
			tf.color = 0xffff00;
			tf.size = 14;
			titleField = ComponentUtil.createTextField("请选择合并方式",130,10,tf,200,NaN,this);
			titleField.mouseEnabled = false;
			radios=new RadioButtonGroup();
			radios.direction=RadioButtonGroup.VERTICAL;
			radios.space=1;
			radios.height=36;
			radios.width=160;
			choice_1=putRadioButton(10, 30, "");
			choice_1.selected = true;
			choice_2=putRadioButton(10, 40, "");
			radios.addItem(choice_1);
			radios.addItem(choice_2);
			radios.x=30;
			radios.y=40;
			addChild(radios);
			
			btn_ok = ComponentUtil.createButton("确定",80,90,60,25,this,wrapperButton);
			btn_ok.addEventListener(MouseEvent.CLICK,onOKhandler);
			
			btn_cancel = ComponentUtil.createButton("取消",240,90,60,25,this,wrapperButton);
			btn_cancel.addEventListener(MouseEvent.CLICK,onCancelhandler);
		}
		
		public function initData(combine_choice:m_family_combine_panel_toc):void{
			this.combine_choice = combine_choice;
			var family_name1:String = " <font color='#3be450'>"+combine_choice.family_name_1+"</font> ";
			var family_name2:String = " <font color='#3be450'>"+combine_choice.family_name_2+"</font> ";
			familyCombineType = ["门派"+family_name2+"加入到门派"+family_name1,
								"门派"+family_name1+"加入到门派"+family_name2];
			choice_1.htmlText = "A. "+familyCombineType[0];
			choice_2.htmlText = "B. "+familyCombineType[1];
		}
		
		private function putRadioButton(x:Number, y:Number, title:String):RadioButton
		{
			var r:RadioButton=new RadioButton(title);
			r.textFormat=StyleManager.textFormat;
			r.x=x;
			r.y=y;
			return r;
		}
		
		private function onOKhandler(event:MouseEvent=null):void{
			Alert.show("你确定要将"+familyCombineType[radios.selectedIndex]+"吗?","警告",yesHandler,noHandler);
			function yesHandler():void{
				var target_family_id:int;
				if(choice_1.selected == true){
					target_family_id = combine_choice.family_id_1;
				}else{
					target_family_id = combine_choice.family_id_2;
				}
				FamilyModule.getInstance().combineFamilyRequest(target_family_id);
				onCancelhandler();
			}
			function noHandler():void{
				onCancelhandler();
			}
		}
		
		private function onCancelhandler(event:MouseEvent=null):void{
			WindowManager.getInstance().closeDialog(this);
		}
	}
}