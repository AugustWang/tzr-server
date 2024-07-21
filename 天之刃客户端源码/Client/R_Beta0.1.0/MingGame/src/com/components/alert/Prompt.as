package com.components.alert
{
	import com.managers.LayerManager;
	import com.managers.MusicManager;
	import com.managers.WindowManager;
	import com.ming.events.CloseEvent;
	
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.utils.Dictionary;

	public class Prompt
	{
		private static var PROMPT_ID:int = 0;
		public static var prompts:Array = new Array();
		private static var dic:Dictionary = new Dictionary();
		public static function show(msg:String,title:String="", yesHandler:Function=null, 
									noHandler:Function=null,leftLabel:String = "确定",rightLabel:String = "取消",
									params:Array = null,showRightBtn:Boolean = true, showCloseBtn:Boolean = false,
									position:Point = null):String{
			var dialog:BaseDialog;
			if(prompts.length > 0){
				dialog = prompts.shift() as BaseDialog;
			}else{
				dialog = new BaseDialog();
				dialog.autoFocus = false;
				dialog.showHelpButton=false;//不显示帮助按钮
			}
			dialog.show(msg,title,yesHandler,noHandler,leftLabel,rightLabel,params,showRightBtn,showCloseBtn,position);
			dialog.addEventListener(CloseEvent.CLOSE,onCloseHandler);
			WindowManager.getInstance().openDialog(dialog,false);
			MusicManager.playSound(MusicManager.ALERT);
			dialog.id = "prompt"+(++PROMPT_ID);
			dic[dialog.id] = dialog;
			return dialog.id;
		}
		
		private static function onCloseHandler(event:CloseEvent):void{
			var dialog:BaseDialog = event.currentTarget as BaseDialog;
			closePrompt(dialog);
		}
		
		private static function closePrompt(dialog:BaseDialog):void{
			if(dialog && dialog.parent){
				WindowManager.getInstance().closeDialog(dialog);
				prompts.push(dialog);
				delete dic[dialog.id];
			}
		}
		
		public static function removePromptItem(key:String):void{
			var dialog:BaseDialog = dic[key] as BaseDialog;
			if(dialog){
				closePrompt(dialog);
			}
		}
		
		public static function isPopUp(key:String):Boolean{
			return dic[key] != null;
		}
	}
}