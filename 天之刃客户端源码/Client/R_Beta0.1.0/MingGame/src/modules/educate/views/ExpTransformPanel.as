package modules.educate.views
{
	import com.components.BasePanel;
	import com.ming.ui.controls.TextInput;
	import com.utils.ComponentUtil;
	import com.utils.HtmlUtil;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextField;
	
	import modules.educate.EducateConstant;
	
	import proto.line.p_educate_role_info;
	
	public class ExpTransformPanel extends BasePanel
	{
		private var text:TextField;
		private var textInput:TextInput;
		private var backBg:Sprite;
		
		public function ExpTransformPanel()
		{
			super("");
			width = 280;
			height = 225;
			this.title = "师德值换经验";
			
			backBg=Style.getBlackSprite(256,190);
			backBg.x = 9;
			backBg.mouseEnabled = false;
			addChild(backBg);

		}
		
		private var info:p_educate_role_info;
		public function setEducateInfo(info:p_educate_role_info):void{
			this.info = info;
			initView();
		}
		
		private var view1:View1;
		private var view2:View2;
		private function initView():void{
			var html:String = "     ";
			if(info.title > 0){
				if(view2 && view2.parent){
					view2.parent.removeChild(view2);
				}
				if(view1 == null){
					view1 = new View1();
					view1.x = 7;
					view1.call = closeWindow;
				}
				view1.setEducateInfo(info);
				addChild(view1);
			}else{
				if(view1 && view1.parent){
					view1.parent.removeChild(view1);
				}
				if(view2 == null){
					view2 = new View2;
					view2.x = 7;
					view2.call = closeWindow;
				}
				view2.setEducateInfo(info);
				addChild(view2);
			}
		}
		
		public var closeFunc:Function;
		override public function closeWindow(save:Boolean=false):void{
			super.closeWindow(save);
			if(closeFunc != null){
				closeFunc.apply(null);
			}
		}
	}
}
import com.ming.ui.controls.Button;
import com.ming.ui.controls.TextInput;
import com.ming.utils.StringUtil;
import com.utils.ComponentUtil;
import com.utils.HtmlUtil;

import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.text.TextField;

import modules.educate.EducateConstant;
import modules.educate.EducateModule;

import proto.line.p_educate_role_info;

class View1 extends Sprite{
	private var text:TextField;
	private var textInput:TextInput;
	private var transButton:Button;
	private var cancelButton:Button;
	private var expText:TextField;
	public var call:Function;
	public function View1(){
		text = ComponentUtil.createTextField("",5,5,null,260,NaN,this);
		text.wordWrap = true;
		text.multiline = true;
		ComponentUtil.createTextField("请输入师德值",30,105,null,NaN,NaN,this);
		textInput = new TextInput();
		textInput.x = 115;
		textInput.y = 105;
		textInput.width = 80;
		textInput.restrict  = "[0-9]";
		textInput.addEventListener(Event.CHANGE,onTextChanged);
		addChild(textInput);
		
		expText = ComponentUtil.createTextField("",30,130,null,200,NaN,this);
		transButton = ComponentUtil.createButton("换取经验",100,155,65,26,this);
		cancelButton =ComponentUtil.createButton("取消",190,155,65,26,this);
		transButton.addEventListener(MouseEvent.CLICK,onTransExpHandler);
		cancelButton.addEventListener(MouseEvent.CLICK,onCancelHandler);
	}
	
	private var info:p_educate_role_info;
	public function setEducateInfo(info:p_educate_role_info):void{
		this.info = info;
		initView();
	}
	
	private function initView():void{
		var html:String = "     ";
		html += HtmlUtil.font(info.name,"#ffff00")+"，你已累积师德值" +
			"("+info.moral_values+"/"+EducateConstant.TOL_VALUES[info.title]+")，"+
			HtmlUtil.font("1点","#00ff00")+"师德值可换取"+HtmlUtil.font("200","#00ff00")+"升级经验。";
		html += "\n\n     徒弟贡献经验："+info.exp_gifts1;
		html += "\n     徒孙贡献经验："+info.exp_grfts2;
		html += "\n     可换取总经验："+(info.exp_gifts1+info.exp_grfts2);
		if(info.moral_values >= 0){
			textInput.maxChars = (String(info.moral_values)).length;
			textInput.enabled = true;
		}else{
			textInput.enabled = false;
		}
		text.htmlText = html;	
		textInput.text = "0";
		expText.htmlText = "（可获得角色升级经验"+HtmlUtil.font("0","#ffff00")+"）"
	}
	
	private function onTextChanged(event:Event):void{
		var value:int = int(StringUtil.trim(textInput.text));
		var total:int = (info.exp_gifts1+info.exp_grfts2)/200;
		total = Math.min(info.moral_values,total);
		if(value > total){
			textInput.text = total.toString();
			value = total;
		}
		expText.htmlText = "（可获得角色升级经验"+HtmlUtil.font(String(value*200),"#ffff00")+"）";
	}
	
	private function onTransExpHandler(event:MouseEvent):void{
		var value:Number = Number(textInput.text);
		if(value > 0){
			EducateModule.getInstance().valueToExp(value);
		}
	}
	
	private function onCancelHandler(event:MouseEvent):void{
		if(call != null){
			call.apply(this);
		}
	}
}
class View2 extends Sprite{
	private var text:TextField;
	private var cancelButton:Button;
	public var call:Function;
	public function View2(){
		text = ComponentUtil.createTextField("",5,5,null,245,NaN,this);
		text.wordWrap = true;
		text.multiline = true;
		cancelButton =ComponentUtil.createButton("确定",190,155,65,26,this);
		cancelButton.addEventListener(MouseEvent.CLICK,onOkHandler);
	}
	
	private var info:p_educate_role_info;
	public function setEducateInfo(info:p_educate_role_info):void{
		this.info = info;
		initView();
	}
	
	private function initView():void{
		text.htmlText = "     "+HtmlUtil.font(info.name,"#ffff00")+"，你还没有获取导师称号，不能使用师德值换取徒弟贡献的经验，" +
			"当前已累积师德值("+info.moral_values+"/"+EducateConstant.TOL_VALUES[info.title]+"），请先升级导师称号。";
	}
	
	
	private function onOkHandler(event:MouseEvent):void{
		if(call != null){
			call.apply(this);
		}
	}
}