package com.components.alert
{
	import com.managers.LayerManager;
	import com.managers.MusicManager;
	import com.managers.WindowManager;
	import com.ming.events.CloseEvent;
	
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.utils.Dictionary;

	public class Alert
	{
		private static var ALERT_ID:int = 0;
		private static var alerts:Array = new Array();
		private static var dic:Dictionary = new Dictionary();
		public static function show(msg:String,title:String="", yesHandler:Function=null, 
							 noHandler:Function=null,leftLabel:String = "确定",rightLabel:String = "取消",
							 params:Array = null,showRightBtn:Boolean = true, showCloseBtn:Boolean = false,
							 position:Point = null,linkHandler:Function=null,hasBg:Boolean = true):String{
			var dialog:BaseDialog;
			if(alerts.length > 0){
				dialog = alerts.shift() as BaseDialog;
			}else{
				dialog = new BaseDialog();
				dialog.showHelpButton=false;//不显示帮助按钮
			}
			dialog.linkHandler = linkHandler;
			dialog.show(msg,title,yesHandler,noHandler,leftLabel,rightLabel,params,showRightBtn,showCloseBtn,position);
			dialog.addEventListener(CloseEvent.CLOSE,onCloseHandler);
			WindowManager.getInstance().openDialog(dialog,hasBg);
			MusicManager.playSound(MusicManager.ALERT);
			dialog.id = "alert"+(++ALERT_ID);
			dic[dialog.id] = dialog;
			return dialog.id;
		}
				
		private static function onCloseHandler(event:CloseEvent):void{
			var dialog:BaseDialog = event.currentTarget as BaseDialog;
			closeAlert(dialog);
		}
		
		private static function closeAlert(dialog:BaseDialog):void{
			if(dialog && dialog.parent){
				WindowManager.getInstance().closeDialog(dialog);
				alerts.push(dialog);
				delete dic[dialog.id];
			}
		}
		
		public static function removeAlert(key:String):void{
			var dialog:BaseDialog = dic[key] as BaseDialog;
			if(dialog){
				closeAlert(dialog);
			}
		}
		
		public static function isPopUp(key:String):Boolean{
			return dic[key] != null;
		}
	}
}