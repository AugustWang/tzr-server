package
{
	import fl.controls.Button;
	import fl.controls.ComboBox;
	import fl.controls.Label;
	import fl.controls.TextInput;
	import fl.data.DataProvider;
	import fl.events.ComponentEvent;
	import fl.managers.StyleManager;
	
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.SharedObject;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.text.TextFormat;
	

	[SWF(backgroundColor="0x0", width="1002", height="580", frameRate="30")]
	public class Login extends MovieClip
	{
		public var serviceHost:String;
		public var account:String;
		public var role_id:String;
		public var gatewayArr:Array;
		
		private var ips:Array=["119.147.160.102", "121.10.118.116",];
		private var ipNames:Array=["debug", "release",]
			
		private var view1:Sprite;
		
		private var tipName:Label;
		private var errorTip:Label;
		private var nameInput:TextInput;
		private var ipComboBox:ComboBox;
		private var ipSave:SharedObject;
		private var loader:URLLoader;
		private var urlRequest:URLRequest;
		
		public function Login()
		{
			urlRequest = new URLRequest();
			loader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, onLoginBack);
			
			ipSave = SharedObject.getLocal("MingChaoData");

			view1 = new Sprite();
			view1.x = 350;
			view1.y = 250;
			addChild(view1);
			
			StyleManager.setStyle("textFormat",new TextFormat("Arial",12,0x000000));
			tipName = new Label();
			tipName.setStyle("textFormat",new TextFormat("Arial",12,0xffffff));
			tipName.width = 150;
			tipName.text = "输入账号，然后按回车键";
			view1.addChild(tipName);
			
			nameInput = new TextInput();
			nameInput.y = 30;
			nameInput.width = 100;
			nameInput.addEventListener(ComponentEvent.ENTER,onNameEnter);
			view1.addChild(nameInput);
			
			var dataProvider:DataProvider = new DataProvider();
			var size:int = ips.length;
			for(var i:int=0;i<size;i++){
				dataProvider.addItem({label:ipNames[i],ip:ips[i]});
			}
			ipComboBox = new ComboBox();
			ipComboBox.y = 30;
			ipComboBox.x = 120;
			ipComboBox.width = 120;
			ipComboBox.dataProvider = dataProvider;
			ipComboBox.labelField = "label";
			view1.addChild(ipComboBox);
			var ipIndex:int=int(ipSave.data.loginIPIndex);
			ipComboBox.selectedIndex=ipIndex;
			
			errorTip = new Label();
			errorTip.setStyle("textFormat",new TextFormat("Arial",12,0x00ff00));
			errorTip.width = 200;
			errorTip.y = 200;
			errorTip.x = 400;
			errorTip.text = "";
			addChild(errorTip);
			
			var enterBtn:Button = new Button();
			enterBtn.label = "确定";
			enterBtn.addEventListener(MouseEvent.CLICK,onEnterClick);
			enterBtn.x = 250;
			enterBtn.y = 30;
			view1.addChild(enterBtn);
		}
		
		private function onEnterClick(event:MouseEvent):void{
			onNameEnter();
		}
		
		private function onNameEnter(event:ComponentEvent=null):void{
			account = nameInput.text;
			if(account != ""){
				if (ipComboBox.selectedIndex < 2){
					if (ipComboBox.selectedIndex == 0){
						serviceHost="http://www.tzrgame-debug.com/user/";
					}else if (ipComboBox.selectedIndex == 1){
						serviceHost="http://www.tzrgame-release.com/user/";
					}else{
						serviceHost="http://www.tzrgame-debug.com/user/";
					}
				}else{
					if (ips[ipComboBox.selectedIndex] == "192.168.4.206"){
						serviceHost= "http://www.tzrgame-local.com/user/";
					}else if (ips[ipComboBox.selectedIndex] == "192.168.4.194"){
						serviceHost= "http://www.tzrgame-local.com/user/";
					}else{
						serviceHost = "http://" + ips[ipComboBox.selectedIndex] + "/user/";
					}
				}
				urlRequest = new URLRequest(serviceHost + "/reconnect.php");
				urlRequest.method = URLRequestMethod.POST;
				var vars:URLVariables =new URLVariables;
				vars.account = account;
				urlRequest.data = vars;
				loader.load(urlRequest);
			}
		}
		
		private function onLoginBack(event:Event):void{
			var str:String=event.target.data;
			var arr:Array=str.split("#");
			var isSucc:String=arr[0];
			var msg:String;
			if (isSucc){
				if(view1.parent){
					removeChild(view1);
				}
				loader.removeEventListener(Event.COMPLETE, onLoginBack);
				if (isSucc == "failed"){
					createRole();
					saveIP();
				}else{
					if (isSucc == "succ")
					{ //进入游戏
						var loginArr:Array=(arr[1]as String).split("@@@@");
						account=loginArr[0];
						role_id=loginArr[1];
						
						var gatewayStr:String = loginArr[2];
						var arr2:Array = gatewayStr.split('|');
						var gatewayArrTmp:Array = new Array;
						var i:int = 0;
						for each (var info:String in arr2) {
							var arrHost:Array = info.split(",");
							gatewayArrTmp[i] = {'host':arrHost[0], 'port':arrHost[1], 'key':arrHost[2]};
							i++;
						}
						gatewayArr=gatewayArrTmp;
						saveIP();
						log("创角成功");
						dispatchEvent(new Event(Event.COMPLETE));
					}else{
						log(str);
					}
				}
			}
		}
		
		private function saveIP():void
		{
			ipSave.data.loginIPIndex=ipComboBox.selectedIndex;
			try
			{
				ipSave.flush(10000);
			}
			catch (error:Error)
			{
				
			}
		}
		
		private var view2:Sprite;
		private var role_name:TextInput;
		private var faction:ComboBox;
		private var sex:ComboBox;
		private var head:ComboBox;
		private var category:ComboBox;
		private var headData:Array=[{label:"头像1"}, {label:"头像2"}, {label:"头像3"}, {label:"头像4"}, {label:"头像5"}, {label:"头像6"}];
		private var factionData:Array=[{label:"云州"}, {label:"沧州"}, {label:"幽州"}];
		private var categoryData:Array=[{label:"战士"}, {label:"弓手"}, {label:"侠客"}, {label:"医仙"}];
		private var sexData:Array=[{label:"男"}, {label:"女"}];
		private function createRole():void{
			
			var view2:Sprite = new Sprite();
			view2.x = 350;
			view2.y = 250;
			addChild(view2);
			
			urlRequest=new URLRequest(serviceHost + "create_user.php");
			urlRequest.method=URLRequestMethod.POST;
			loader.addEventListener(Event.COMPLETE, completeHandler);
			createTextField("角色名：", 0, 0, 60, 24, view2);
			createTextField("国家：", 0, 24, 60, 24, view2);
			createTextField("性别：", 0, 48, 60, 24, view2);
			createTextField("头像：", 0, 72, 60, 24, view2);
			createTextField("职业：", 0, 96, 60, 24, view2);
			role_name=new TextInput();
			role_name.addEventListener(ComponentEvent.ENTER,onEnterGame);
			role_name.x=40;
			role_name.width=92;
			role_name.text=account;
			view2.addChild(role_name);
			faction=new ComboBox;
			faction.x=40;
			faction.y=24;
			faction.width=92;
			faction.height=22;
			var dataProvider:DataProvider = new DataProvider();
			for(var i:int=0;i<factionData.length;i++){
				dataProvider.addItem(factionData[i]);
			}
			faction.dataProvider = dataProvider;
			faction.selectedIndex=0;
			view2.addChild(faction);
			sex=new ComboBox;
			sex.x=40;
			sex.y=48;
			sex.width=92;
			dataProvider = new DataProvider();
			for(i=0;i<sexData.length;i++){
				dataProvider.addItem(sexData[i]);
			}
			sex.dataProvider=dataProvider;
			sex.selectedIndex=0;
			sex.height=22;
			view2.addChild(sex);
			head=new ComboBox;
			head.x=40;
			head.y=72;
			head.width=92;
			dataProvider = new DataProvider();
			for(i=0;i<headData.length;i++){
				dataProvider.addItem(headData[i]);
			}
			head.dataProvider=dataProvider;
			head.selectedIndex=0;
			head.height=22;
			view2.addChild(head);
			category = new ComboBox;
			category.x=40;
			category.y=96;
			category.width=92;
			dataProvider = new DataProvider();
			for(i=0;i<categoryData.length;i++){
				dataProvider.addItem(categoryData[i]);
			}
			category.dataProvider=dataProvider;
			category.selectedIndex=0;
			category.height=22;
			view2.addChild(category);
			var btn:Button = new Button();
			btn.label = "进入游戏";
			btn.x = 150;
			btn.width = btn.height = 120;
			view2.addChild(btn);
			btn.addEventListener(MouseEvent.CLICK, onSubmit);
		}
		
		private function createTextField(text:String,x:Number,y:Number,w:Number,h:Number,parent:DisplayObjectContainer):void{
			var label:Label = new Label();
			label.setStyle("textFormat",new TextFormat("Arial",12,0xffffff));
			label.x = x;
			label.y = y;
			label.text = text;
			label.width = w;
			label.height = h;
			parent.addChild(label);
		}
		
		private function completeHandler(event:Event):void{
			var str:String=event.target.data;
			var arr:Array=str.split("#");
			var msg:String;
			if (arr[0])
			{
				if (arr[0] == "ok")
				{
					//进入游戏
					createSucc();
				}
				else
				{
					if (arr[0] == "error")
					{
						var type:String=arr[1]as String;
						switch (type)
						{
							case "hack_attemp":
								log("非法账号！");
								break;
							case "already_login":
								log("该账号已经登录");
								break;
							case "already_has_role":
								log("该账号已经有角色了");
								break;
							default:
								log("创角失败，" + type);
								break;
						}
					}
				}
			}
		}
	
		private function createSucc():void
		{
			loader.addEventListener(Event.COMPLETE, onLoginBack);
			urlRequest=new URLRequest(serviceHost + "reconnect.php");
			urlRequest.method=URLRequestMethod.POST;
			var urlVar:URLVariables=new URLVariables;
			urlVar.account=account;
			urlRequest.data=urlVar;
			loader.load(urlRequest);
		}
	
		private function onEnterGame(event:Event):void{
			onSubmit(null);
		}
		
		private function onSubmit(event:MouseEvent):void{
			var vars:URLVariables=new URLVariables;
			vars.faction_id=faction.selectedIndex + 1;
			vars.sex=sex.selectedIndex + 1;
			var temHead:int;
			if (sex.selectedIndex == 0)
			{
				temHead=(head.selectedIndex + 1) * 2 - 1;
			}
			else
			{
				temHead=(head.selectedIndex + 1) * 2;
			}
			vars.hair_type=1;
			vars.hair_color="000000";
			vars.head=temHead;
			vars.username=role_name.text;
			vars.account=account;
			vars.category=category.selectedIndex + 1;
			vars.action="create";
			urlRequest.data=vars;
			loader.load(urlRequest);
		}
		
		private function log(tip:String):void{
			errorTip.text = tip;
		}
	}
}