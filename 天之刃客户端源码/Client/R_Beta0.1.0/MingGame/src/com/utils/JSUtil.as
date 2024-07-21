package com.utils
{
	import com.globals.GameParameters;
	
	import flash.external.ExternalInterface;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.system.Capabilities;

	public class JSUtil
	{
		private static var brower:String = ExternalInterface.call("function getBrower(){return navigator.userAgent}");
		private static var regExp:RegExp = /\|/g;
		
		public function JSUtil()
		{
			
		}
		
		public static function openWebSite(url:String):void{
			url = url.replace(regExp,"&");
			var str:String = Capabilities.os;
			if(str.substr(0,3).toLowerCase() == "win"){
				if(str.indexOf("7")!=-1 && brower.indexOf("MSIE 8.0")!=-1){
					ExternalInterface.call('window.open("'+url+'","'+"_blank"+'")');
				}else{
					navigateToURL(new URLRequest(url),'_blank');
				}
			}else{
				navigateToURL(new URLRequest(url),'_blank')
			}
		}
		
		public static function openPaySite():void{
			openWebSite(GameParameters.getInstance().recharge);
		}
	}
}