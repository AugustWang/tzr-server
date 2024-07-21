package {
	import flash.display.MovieClip;
	import flash.filters.GlowFilter;
	import flash.filters.BitmapFilterQuality;
	import flash.display.SimpleButton;
	import flash.display.MovieClip;
	import flash.text.TextField;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.HTTPStatusEvent;
	import flash.events.KeyboardEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	import flash.net.navigateToURL;
	import flash.system.Security;
	import flash.events.ProgressEvent;
	import flash.net.URLRequestMethod;
	import flash.events.FocusEvent;
	import flash.events.TimerEvent;
	import flash.text.StyleSheet;
	import flash.events.TextEvent;
	import flash.utils.Timer;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	import Rippler;
	public class CreateMain extends MovieClip {
		private var bodyIndex:int=0;
		private var urlld:URLLoader=new URLLoader  ;
		private var nameLoader:URLLoader=new URLLoader  ;
		private var req:URLRequest;
		private var game_path:String="user/main.php";//进入游戏地址
		private var changeName_path:String="gene_name.php";//获取默认名字
		private var api_path:String="create_user.php ";//后台验证地址
		private var man_name:String;
		private var women_name:String;
		private var _sessionId:String;//从网页获取的参数
		private var _web_homeurl:String="";//网站地址
		private var _web_resourUrl:String="";//网站静态资源地址
		private var bgmusic:String="createRole.mp3";
		private var regEx:RegExp = /([^\u4e00-\u9fa5a-zA-Z0-9])+/;
		private var _dfFaction:int=3;//默认国家
		private var seletedFaction:int=1;//所选国家
		private var selectedSex:int=1;//所选性别
		private var _headIndex:int=1;//所选头像
		private var manName:String="nnnnn";//默认男名
		private var womanName:String="nvnvnvn";//默认女名
		private var category:int;//1234刀弓扇杖
		private var reqTimer:Timer=new Timer(1000);
		/////////////////
		private var tipShowTime:Number=120;//错误提示显示时间


		private var ready:Boolean=true;
		private var txtSelete:Boolean=false;//角色名文本框是否被选中

		private var tarRole:MovieClip;//目标人物
		private var curRole:MovieClip;//当前人物
		private var tarRip:Rippler;//目标水波
		private var curRip:Rippler;//当前水波
		private var speed:Number=0.04;//透明度变化速度
		private var alphaFlag:Boolean=true;
		private var nameStr:String;//默认名
		private var isFirstFocusNameTxt:Boolean=true;//角色名文本第一次获得焦点
		private var bgm:Bgm;//背景音乐
		//////////以下几个给后台统计用的
		var d_sex:int=0;//默认性别
		var c_sex:int=0;//是否更改过性别
		var d_category:int=0;//默认职业
		var c_category:int=0;//是否换过职业
		var d_faction:int=0;//默认国家
		var c_faction:int=0;//是否换过国家
		var c_name:int=0;//是否改过名字
		var autoChangeName:Boolean=true;//点性别是否自动改名
		public function CreateMain():void {
			this.stop();
			//loading进度
			loaderInfo.addEventListener(ProgressEvent.PROGRESS,progressHandler);
			loaderInfo.addEventListener(Event.COMPLETE,loadedHandler);
			addEventListener(Event.ENTER_FRAME,EFHandler);
		}
		//加载进度
		private function progressHandler(e:ProgressEvent):void {
			_mask_mc.scaleX=e.bytesLoaded/e.bytesTotal;
			per_txt.text=int(e.bytesLoaded/e.bytesTotal*100)+"%";
		}
		//加载完毕
		private function loadedHandler(e:Event):void {
			gotoAndPlay(2);
			loaderInfo.removeEventListener(ProgressEvent.PROGRESS,progressHandler);
			loaderInfo.removeEventListener(Event.COMPLETE,loadedHandler);
		}
		//跳到第三帧，初始化
		private function EFHandler(e:Event):void {

			if (currentFrame==3) {
				stop();
				removeEventListener(Event.ENTER_FRAME,EFHandler);
				Security.allowDomain(Security.LOCAL_WITH_NETWORK);
				//trace(loaderInfo.parameters.accname);
				//creat_mc.buttonMode=true;
				txtTip_mc.filters=[new GlowFilter(0x222222,1,0,0)];
				//req_mc.visible=false;
				init();
			}
		}
		//初始化角色选择
		private function init():void {
			if (loaderInfo.parameters) {
				_sessionId=loaderInfo.parameters.sessionid;
				_web_homeurl=loaderInfo.parameters.serviceHost;
				_web_resourUrl=loaderInfo.parameters.resourceHost;
				api_path=_web_homeurl+api_path;
				changeName_path=_web_homeurl+changeName_path;
				trace(api_path);
				if (loaderInfo.parameters.faction) {
					seletedFaction=loaderInfo.parameters.faction;
				}
				if (loaderInfo.parameters.sex) {
					selectedSex=loaderInfo.parameters.sex;
				} else {
					Math.random()>0.5?selectedSex=1:selectedSex=2;
					//selectedSex=1;
				}
			}
			manName=loaderInfo.parameters.manName;
			womanName=loaderInfo.parameters.womenName;
			if (manName==null) {
				manName="";
			}
			if (womanName==null) {
				womanName="";
			}

			req=new URLRequest(api_path);
			req.method=URLRequestMethod.POST;
			req_mc.visible=false;
			txtTip_mc.alpha=0;

			for (var i:int=1; i<=3; i++) {
				var faction_mc:MovieClip=this["f"+i+"_mc"];
				faction_mc.faction=i;
				faction_mc.useHandCursor=faction_mc.buttonMode=true;
				faction_mc.addEventListener(MouseEvent.CLICK,onClickFaction);
			}

			job1_btn.addEventListener(MouseEvent.CLICK,onClickJob);
			job2_btn.addEventListener(MouseEvent.CLICK,onClickJob);
			job3_btn.addEventListener(MouseEvent.CLICK,onClickJob);
			job4_btn.addEventListener(MouseEvent.CLICK,onClickJob);

			sex1_btn.addEventListener(MouseEvent.CLICK,onClickSex);
			sex2_btn.addEventListener(MouseEvent.CLICK,onClickSex);
			txtTip_mc.addEventListener(Event.ENTER_FRAME,txtTipEf);
			urlld.addEventListener(Event.COMPLETE,completeHandler);
			urlld.addEventListener(HTTPStatusEvent.HTTP_STATUS,httpStatusHandler);
			urlld.addEventListener(IOErrorEvent.IO_ERROR,ioErrorHandler);
			nameLoader.addEventListener(Event.COMPLETE,onNameBack);
			name_txt.addEventListener(Event.CHANGE,onTextChange);
			name_txt.addEventListener(TextEvent.TEXT_INPUT,onInput);
			name_txt.addEventListener(KeyboardEvent.KEY_DOWN,onNameKeyDown);
			name_txt.addEventListener(FocusEvent.FOCUS_IN,onFocusInName);
			name_txt.addEventListener(FocusEvent.FOCUS_OUT,onFocusOutName);
			name_txt.addEventListener(MouseEvent.MOUSE_DOWN,onClickName);
			submit_btn.addEventListener(MouseEvent.CLICK,doLogin);
			shaizi_btn.addEventListener(MouseEvent.CLICK,onChangeName);
			makeDefaule();
			txtTip_mc.txt.text="                                                 以默认角色名进入游戏";
			txtTip_mc.alpha=120;
			setTipPos("button");
			//flashTip();
		}
		private function setTipPos(pos:String="textInput"):void {
			switch (pos) {
				case "textInput" :
					txtTip_mc.x=146;
					txtTip_mc.y=350;
					break;
				case "button" :
					txtTip_mc.x=215;
					txtTip_mc.y=400;
					break;
				default :
					txtTip_mc.x=274;
					txtTip_mc.y=325;
					break;
			}
		}
		private var tid:int=0;
		private var falshTime:int=0;
		private function flashTip():void {
			if (falshTime%2==0) {
				submit_btn.filters=[new GlowFilter(0x222222,1,0,0)];
			} else {
				submit_btn.filters=[new GlowFilter(0xfff799,0.8,8,8)];
			}
			falshTime++;
			clearTimeout(tid);
			if (falshTime<1000) {
				tid=setTimeout(flashTip,400);
			}
		}
		private function makeDefaule():void {
			//处理默认国家
			this["f"+seletedFaction+"_mc"].filters=[new GlowFilter(0xffff00,1,8,8,3)];
			//处理默认职业
			category=int(Math.random()*4)+1;
			trace("默认职业:"+category);
			changeJob();
			//处理默认身体是男是女
			trace("性别："+selectedSex);
			changeSex();
			name_txt.text=selectedSex==1?manName:womanName;
			//统计
			d_sex=selectedSex;
			d_category=category;
			d_faction=seletedFaction;
		}
         
		private function changeJob():void{
			for(var i:int=1;i<=4;i++){
				if(category == i){
					this["job"+i+"_mc"].gotoAndStop(2);
				}else{
					this["job"+i+"_mc"].gotoAndStop(1);
				}
			}
		}
		
		private function changeSex():void{
			if(selectedSex == 1){
				man_mc.gotoAndStop(2);
				woman_mc.gotoAndStop(1);
			}else{
				man_mc.gotoAndStop(1);
				woman_mc.gotoAndStop(2);
			}
		}
		
		private function onClickFaction(e:MouseEvent):void {
			f1_mc.filters=null;
			f2_mc.filters=null;
			f3_mc.filters=null;
			var _mc:MovieClip=e.currentTarget as MovieClip;
			_mc.filters=[new GlowFilter(0xffff00,1,8,8,3)];
			seletedFaction=int(_mc.name.substr(1,1));
			c_faction=1;
		}

		private function onClickJob(e:MouseEvent):void {
			var target:SimpleButton=e.currentTarget as SimpleButton;
			switch (target) {
				case job1_btn :
					category=1;
					break;
				case job2_btn :
					category=2;
					break;
				case job3_btn :
					category=3;
					break;
				case job4_btn :
					category=4;
					break;
				default :
					category=1;
					break;
			}
			changeJob();
			c_category=1;//是否换过职业
		}

		private function onClickSex(e:MouseEvent):void {
			var target:SimpleButton=e.currentTarget as SimpleButton;
			switch (target) {
				case sex1_btn :
					selectedSex=1;
					break;
				case sex2_btn :
					selectedSex=2;
					break;
				default :
					selectedSex=1;
					break;
			}
            changeSex();
			if (autoChangeName==true) {
				name_txt.text=selectedSex==1?manName:womanName;
				txtTip_mc.txt.htmlText="以角色名：\n<font color='#ff0000'>"+name_txt.text+"</font>\n进入游戏";
				txtTip_mc.alpha=tipShowTime;
				setTipPos("button");
			}

			c_sex=1;//是否更改过性别
		}


		private function txtTipEf(e:Event):void {
			if (txtTip_mc.alpha>0) {
				txtTip_mc.alpha-=speed;
			}
		}
		//用户手动输入的
		private function onInput(e:TextEvent):void {
			autoChangeName=false;
		}
		//文本框焦点处理
		private function onFocusInName(e:FocusEvent):void {
			trace(txtSelete);
			c_name=1;//改过名
			if (name_txt.text=="请输入角色名") {
				if (txtSelete==false) {
					name_txt.text="";
				} else {
					name_txt.setSelection(0,name_txt.length);
					txtSelete=false;
				}
				name_txt.textColor=0xffffff;
			}
			//if (autoChangeName==true) {//这个名字是系统生成的，就选中全部
				name_txt.setSelection(0,name_txt.length);
			//}
			//txtTip_mc.alpha=0;
		}
		private function onClickName(e:MouseEvent):void {
			if (name_txt.text=="请输入角色名") {
				name_txt.text="";
				name_txt.textColor=0xffffff;
			} else {
				/*if (isFirstFocusNameTxt==true) {
					trace("name_txt.text.length:"+name_txt.text.length);
					name_txt.setSelection(0,name_txt.text.length);
					isFirstFocusNameTxt=false;
				}*/
				name_txt.setSelection(0,name_txt.text.length);
			}
		}
		//文本框焦点处理
		private function onFocusOutName(e:FocusEvent):void {
			if (name_txt.text=="") {
				if (stage.focus is SimpleButton==false) {
					name_txt.text="请输入角色名";
					name_txt.textColor=0xffffff;
				}
			}
			if (name_txt.text=="请输入角色名") {
				name_txt.textColor=0xffffff;
			}
		}
		private function onTextChange(e:Event=null):void {
			nameStr=name_txt.text;
			submit_btn.filters=null;
			if (regEx.test(name_txt.text)) {
				txtTip_mc.alpha=tipShowTime;
				txtTip_mc.txt.text="   角色名必须是中英文数字的组成。";
				setTipPos();
			} else {
				if (name_txt.text.length>=2&&name_txt.text.length<=7) {
					//submit_btn.filters=[new GlowFilter(0xfff799,0.8,8,8)];
				}
			}
			if (regEx.test(name_txt.text)) {
				txtTip_mc.alpha=tipShowTime;
				txtTip_mc.txt.text="  角色名必须是中英文数字的组成。";
				setTipPos();
				return;
			}
			if (name_txt.text.length<2||name_txt.text.length>7) {
				txtTip_mc.txt.text="   角色名长度为2-7个字符。";
				txtTip_mc.alpha=tipShowTime;
				setTipPos();
				return;
			}
			txtTip_mc.txt.htmlText="以角色名：\n<font color='#ff0000'>"+name_txt.text+"</font>\n进入游戏";
			txtTip_mc.alpha=tipShowTime;
			setTipPos("button");
		}

		private function onNameKeyDown(e:KeyboardEvent):void {
			if (e.keyCode==13) {
				if (name_txt.text==nameStr) {
					doLogin();
				}
			}
		}
		//发送角色名
		private function doLogin(e:Event=null):void {
			trace("login");
			if (regEx.test(name_txt.text)) {
				txtTip_mc.alpha=tipShowTime;
				txtTip_mc.txt.text="  角色名必须是中英文数字的组成。";
				setTipPos();
				return;
			}
			if (name_txt.text.length<2||name_txt.text.length>7) {
				txtTip_mc.txt.text="   角色名长度为2-7个字符。";
				txtTip_mc.alpha=tipShowTime;
				setTipPos();
				return;
			}
			if (name_txt.text=="请输入角色名") {
				stage.focus=name_txt;
				setTipPos();
				return;
			}

			req_mc.visible=true;//设置按钮不能按
			var temHead:int;
			if (selectedSex==1) {
				temHead=2*category-1;
			} else {
				temHead=2*category;
			}
			temHead+=12;//加12是为了不与以前12个头像重复
			trace("国家:"+seletedFaction);
			trace("性别:"+selectedSex);
			trace("头像:"+temHead);

			var urlVar:URLVariables=new URLVariables  ;
			urlVar.faction_id=seletedFaction;
			urlVar.sex=selectedSex;
			urlVar.hair_type=1;
			urlVar.hair_color="000000";
			urlVar.action="create";
			urlVar.category=category;
			urlVar.head=temHead;
			//urlVar.account = "huyongbo001";
			trace(urlVar.head);
			urlVar.username=name_txt.text;
			//统计数据
			urlVar.d_sex=d_sex;//默认性别
			urlVar.c_sex=c_sex;//是否更改过性别
			urlVar.d_category=d_category;//默认职业
			urlVar.c_category=c_category;//是否换过职业
			urlVar.d_faction=d_faction;//默认国家
			urlVar.c_faction=c_faction;//是否换过国家
			urlVar.c_name=c_name;//是否改过名
			req.data=urlVar;
			trace("d_sex:"+d_sex);
			trace("c_sex:"+c_sex);
			trace("d_category:"+d_category);
			trace("c_category:"+c_category);
			trace("d_faction:"+d_faction);
			trace("c_faction:"+c_faction);
			trace("c_name:"+c_name);
			urlld.load(req);
			reqTimer.addEventListener(TimerEvent.TIMER,countHandler);
			reqTimer.start();
		}
		//请求返回结果
		private function completeHandler(event:Event):void {
			req_mc.visible=false;
			trace(event.target.data);
			var str:String=event.target.data;
			var arr:Array=str.split("#");
			//var succed:int=0;
			var msg:String;
			if (arr[0]) {
				if (arr[0]=="ok") {
					dispatchEvent(new Event("createRoleFinish"));
					//navigateToURL(new URLRequest(_web_homeurl+game_path),"_self");
				} else {
					if (arr[0]=="error") {
						var type:String=arr[1] as String;
						switch (type) {
							case "hack_attemp" :
								navigateToURL(new URLRequest("www.mingchao.com"),"_self");//直接跳官网
								break;
							case "already_login" :
								dispatchEvent(new Event("createRoleFinish"));
								break;
							case "already_has_role" :
								dispatchEvent(new Event("createRoleFinish"));
								break;
							default :
								txtTip_mc.alpha=tipShowTime;
								txtTip_mc.txt.text="   "+type;
								setTipPos("up");
								break;
						}
					} else {
						txtTip_mc.alpha=tipShowTime;
						txtTip_mc.txt.text="   "+type;
						setTipPos("up");
					}
				}
			}
			reqTimer.stop();
			reqTimer.removeEventListener(TimerEvent.TIMER,countHandler);
		}
		//请求出错
		private function httpStatusHandler(event:HTTPStatusEvent):void {
			trace("httpStatusHandler: "+event);
		}
		//请求出错
		private function ioErrorHandler(event:IOErrorEvent):void {
			trace("ioErrorHandler: "+event);
		}


		private function onLick(e:TextEvent):void {
			navigateToURL(new URLRequest(_web_homeurl+"user/mccq_license.html"),"_blank");
		}


		private function countHandler(e:TimerEvent):void {
			trace(reqTimer.currentCount);
			if (reqTimer.currentCount>4) {
				trace(req.data);
				urlld.load(req);
				reqTimer.reset();
				reqTimer.start();
			}
		}

		private function onChangeName(e:Event=null):void {
			c_name=1;
			autoChangeName=true;
			var urlVar:URLVariables=new URLVariables  ;
			urlVar.sex=selectedSex;
			var nameReq:URLRequest=new URLRequest(changeName_path);
			nameReq.data=urlVar;
			trace("nameReq="+urlVar);
			nameLoader.load(nameReq);
		}
		private function onNameBack(e:Event):void {
			var str:String=e.target.data;
			var arr:Array=str.split("#");
			trace(str);
			var msg:String;
			if (arr[0]) {
				if (arr[0]=="ok") {
					name_txt.text=arr[1];
					selectedSex==1?manName=name_txt.text:womanName=name_txt.text;
					onTextChange();
				} else {
					name_txt.text="";
					onTextChange();
				}
			}
		}
	}
}