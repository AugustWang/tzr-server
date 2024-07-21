package com.globals {

	dynamic public class GameParameters {
		public var hasRole:Boolean;
		public var web_config:String;
		public var sessionid:String;
		public var account:String;
		public var role_id:String;
		public var level:String;
		public var map_id:String="11000";
		public var shareURL:String;
		public var linePort:String;
		public var lineKey:String;
		public var serviceHost:String;
		public var resourceHost:String;
		public var serviceVersion:String;

		public var gm_link_1:String;
		public var gm_link_2:String;
		public var gm_link_3:String;
		public var content_1:String;
		public var content_2:String;
		public var content_3:String;

		public var loginPage:String;
		public var loginError:String;
		public var fcmApiUrl:String;
		public var pkTip:String;
		public var recharge:String;
		public var bbs:String;
		public var officeSite:String; //官网
		public var debug:String;
		public var localDebug:String = "false";
		public var activateCodeUrl:String;
		public var to_game_url:String;
		// 网关列表
		public var gatewayArr:Array;
		/**
		 * 创角页参数
		 */
		public var faction:int;
		public var sex:int;
		public var manName:String;
		public var womanName:String;
		public var web_homeUrl:String="http://www.tzrgame-debug.com/";
		public var web_resoureUrl:String="http://www.tzrgame-debug.com/";
		public var dev:String;
		//bgp参数
		public var bgp_host:String='';
		public var bgp_port:String='';
		public var directly_use_bgp:String;
		//是否抛出异常
		public var showException:String;
		public var proxyName:String;
		
		public static const PROXY_NAME_BAIDU:String = "baidu";
		public static const PROXY_NAME_360:String = "360";

		public function GameParameters() {

		}

		private static var instance:GameParameters;

		public static function getInstance():GameParameters {
			if (instance == null) {
				instance=new GameParameters();
			}
			return instance;
		}

		public function isDebug():Boolean {
			return this.debug == "true";
		}

		public function isShowException():Boolean {
			return this.showException == "true";
		}

		public var init:Boolean=false;

		public function initParameters(parameters:Object):void {
			if (init == false && parameters) {
				var gameParameters:GameParameters=getInstance();
				for (var property:String in parameters) {
					gameParameters[property]=parameters[property];
				}
				GameConfig.ROOT_URL=gameParameters.resourceHost;
				GameConfig.wrapperURL();
				// 解析网关列表
				var gatewayStr:String=parameters.gatewayStr;
				var arr:Array=gatewayStr.split('|');
				var gatewayArrTmp:Array=new Array;
				var i:int=0;
				for each (var info:String in arr) {
					var arrHost:Array=info.split(",");
					gatewayArrTmp[i]={'host': arrHost[0], 'port': arrHost[1], 'key': arrHost[2]};
					i++;
				}
				gameParameters.hasRole=int(gameParameters.role_id) > 0;
				gameParameters.gatewayArr=gatewayArrTmp;
				init=true;
			}
		}

		/**
		 * 获取网关的域名
		 *
		 */
		public function getGatewayHost():String {
			if (gatewayArr.length > 0) {
				return gatewayArr[0].host;
			}
			return "";
		}
	}
}