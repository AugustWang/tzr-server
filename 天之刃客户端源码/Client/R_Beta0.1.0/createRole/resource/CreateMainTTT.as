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
		private var iconPos:Array=[[800,130],[800,200],[800,270.5],[800,340.5],[897,130],[897,200],[897,270.5],[897,340.5]];
		private var centerArr:Array=[[185,230],[200,220],[160,230],[165,230],[185,225],[180,210],[190,235],[225,240]];//6个人物重心位置
		private var jobPos:Array=[113,186,251,322];
		private var maleIcons:Array;
		private var femalIcons:Array;
		private var icons:Array=[];
		private var bodys:Array=[];
		private var bodyIndex:int=0;
		private var urlld:URLLoader=new URLLoader  ;
		private var nameLoader:URLLoader=new URLLoader  ;
		private var req:URLRequest;
		private var game_path:String="user/game.php";//进入游戏地址
		private var changeName_path:String="user/gene_name.php";//获取默认名字
		private var api_path:String="user/create_user.php ";//后台验证地址
		private var man_name:String;
		private var women_name:String;
		private var _sessionId:String;//从网页获取的参数
		private var _web_homeurl:String;//网站地址
		private var _web_resourUrl:String;//网站静态资源地址
		private var bgmusic:String="createRole.mp3";
		private var regEx:RegExp = /([^\u4e00-\u9fa5a-zA-Z0-9])+/;
		private var _dfFaction:int=3;//默认国家
		private var seletedFaction:int=1;//所选国家
		private var selectedSex:int=1;//所选性别
		private var _headIndex:int=1;//所选头像
		private var manName:String;//默认男名
		private var womanName:String;//默认女名
		private var category:int;//1234刀弓扇杖
		private var reqTimer:Timer=new Timer(1000);
		/////////////////
		private var tipShowTime:Number=3;//错误提示显示时间


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
				_web_homeurl=loaderInfo.parameters.WEB_SITEURL;
				_web_resourUrl=loaderInfo.parameters.RESOURCE_HOST;
				api_path=_web_homeurl+api_path;
				changeName_path=_web_homeurl+changeName_path;
				trace(api_path);
				if (loaderInfo.parameters.faction) {
					seletedFaction=loaderInfo.parameters.faction;
				}
				if (loaderInfo.parameters.sex) {
					selectedSex=loaderInfo.parameters.sex;
				} else {
					//Math.random()>0.3?_sex="1":_sex="0";
					selectedSex=1;
				}
			}
			manName=loaderInfo.parameters.manName;
			womanName=loaderInfo.parameters.womanName;
			if (manName==null) {
				manName="";
			}
			if (womanName==null) {
				womanName="";
			}
			var musicPath:String=_web_resourUrl?_web_resourUrl+"/com/sounds/"+bgmusic:bgmusic;
			//bgm=new Bgm(musicPath,6);
			maleIcons=[m1_mc,m2_mc,m3_mc,m4_mc];
			femalIcons=[f1_mc,f2_mc,f3_mc,f4_mc];
			bodys=[body1_mc,body2_mc,body3_mc,body4_mc,body5_mc,body6_mc,body7_mc,body8_mc];
			_sessionId="1b81be5d10718de0f9155c9ce2aa2e1a";
			req=new URLRequest(api_path);
			req.method=URLRequestMethod.POST;
			req_mc.visible=false;
			txtTip_mc.alpha=0;

			music_mc.buttonMode=true;

			hw_mc.addEventListener(MouseEvent.CLICK,onClickHW);
			yl_mc.addEventListener(MouseEvent.CLICK,onClickYL);
			wl_mc.addEventListener(MouseEvent.CLICK,onClickWL);
			txtTip_mc.addEventListener(Event.ENTER_FRAME,txtTipEf);
			urlld.addEventListener(Event.COMPLETE,completeHandler);
			urlld.addEventListener(HTTPStatusEvent.HTTP_STATUS,httpStatusHandler);
			urlld.addEventListener(IOErrorEvent.IO_ERROR,ioErrorHandler);
			nameLoader.addEventListener(Event.COMPLETE,onNameBack);
			name_txt.addEventListener(Event.CHANGE,onTextChange);
			name_txt.addEventListener(KeyboardEvent.KEY_DOWN,onNameKeyDown);
			name_txt.addEventListener(FocusEvent.FOCUS_IN,onFocusInName);
			name_txt.addEventListener(FocusEvent.FOCUS_OUT,onFocusOutName);
			name_txt.addEventListener(MouseEvent.MOUSE_DOWN,onClickName);
			agreemen_mc.addEventListener(MouseEvent.CLICK,onClickAgreemen);
			submit_btn.addEventListener(MouseEvent.CLICK,doLogin);
			music_mc.addEventListener(MouseEvent.CLICK,doMusic);
			var css:StyleSheet=new StyleSheet  ;
			css.parseCSS("font {color: #eeeeee} a {color: #eeeeee} a:hover {color: #ff0000}");
			agreement_txt.styleSheet=css;
			agreement_txt.htmlText="<a href='event:myEvent'><u>已阅读并同意《用户协议》</u></a>";
			agreement_txt.mouseEnabled=true;
			agreement_txt.addEventListener(TextEvent.LINK,onLick);
			var css2:StyleSheet=new StyleSheet  ;
			css2.parseCSS("font {color: #FFFF00} a {color: #FFFF00} a:hover {color: #ff0000}");
			changeName_txt.styleSheet=css2;
			changeName_txt.htmlText="<a href='event:changeNameEvent'><u>自动取名</u></a>";
			changeName_txt.mouseEnabled=true;
			//changeName_txt.visible = false;
			changeName_txt.addEventListener(TextEvent.LINK,onChangeName);
			shaizi_btn.addEventListener(MouseEvent.CLICK,onChangeName);
			makeDefaule();
			for (var i:int=0; i<icons.length; i++) {
				icons[i].addEventListener(MouseEvent.CLICK,onClickIcon);
				icons[i].buttonMode=true;
			}
			txtTip_mc.txt.text="以默认角色名进入游戏";
			txtTip_mc.alpha=120;
			setTipPos("mid");
			flashTip();
		}
		private function setTipPos(pos:String="up"):void {
			switch (pos) {
				case "up" :
					txtTip_mc.x=598;
					txtTip_mc.y=442;
					break;
				case "mid" :
					txtTip_mc.x=612;
					txtTip_mc.y=520;
					break;
				case "down" :
					txtTip_mc.x=597;
					txtTip_mc.y=550;
					break;
				default :
					txtTip_mc.x=596;
					txtTip_mc.y=530;
					break;
			}
		}
		private var tid:int=0;
		private var falshTime:int=0;
		private function flashTip():void {
			if (falshTime%2==0) {
				txtTip_mc.filters=[new GlowFilter(0xfff799,0.8,8,8)];
			} else {
				txtTip_mc.filters=[new GlowFilter(0x222222,1,0,0)];
			}
			falshTime++;
			clearTimeout(tid);
			if (falshTime<6) {
				tid=setTimeout(flashTip,300);
			}
		}
		private function makeDefaule():void {
			makeIconForShow();
			for (var i:int=0; i<icons.length; i++) {
				icons[i].x=iconPos[i][0];
				icons[i].y=iconPos[i][1];
			}
			//处理默认国家
			switch (seletedFaction) {
				case 1 :
					hw_mc.gotoAndStop(2);
					hw_mc.mouseEnabled=false;
					break;
				case 2 :
					yl_mc.gotoAndStop(2);
					yl_mc.mouseEnabled=false;
					break;
				case 3 :
					wl_mc.gotoAndStop(2);
					wl_mc.mouseEnabled=false;
					break;
				default :
					wl_mc.gotoAndStop(2);
					wl_mc.mouseEnabled=false;
					break;
			}
			//处理默认头像
			var romIcon:int=int(Math.random()*8);
			icons[romIcon].gotoAndStop(2);
			category=romIcon%4+1;
			job_mc.y=jobPos[category-1];
			explain_mc.gotoAndStop(category);
			_headIndex=int(icons[romIcon].name.substr(1,1));
			//处理默认身体是男是女
			selectedSex=icons[romIcon].name.substr(0,1)=="m"?1:2;
			trace("性别："+selectedSex);
			trace(bodys[romIcon].name+"身体");
			bodyIndex=romIcon;
			bodys[romIcon].alpha=1;
			curRole=bodys[romIcon];
			tarRole=curRole;
			onChangeName();
			//统计
			d_sex=selectedSex;
			d_category=category;
			d_faction=seletedFaction;
		}

		private function makeIconForShow():void {
			icons=[m1_mc,m2_mc,m3_mc,m4_mc,f1_mc,f2_mc,f3_mc,f4_mc];
			/*var index:int;
			while (maleIcons.length>2) {
			index=int(Math.random()*6);
			if (maleIcons.length>index) {
			var t:Array=maleIcons.splice(index,1);
			icons.push(t[0]);
			}
			}
			while (femalIcons.length>1) {
			index=int(Math.random()*6);
			if (femalIcons.length>index) {
			var tt:Array=femalIcons.splice(index,1);
			icons.push(tt[0]);
			}
			}*/
		}

		private function onClickIcon(e:MouseEvent):void {
			var _mc:MovieClip=e.currentTarget as MovieClip;
			if (icons.indexOf(_mc)==bodyIndex) {
				return;
			}
			if (_mc.currentFrame==1) {
				for (var i:int=0; i<icons.length; i++) {
					icons[i].gotoAndStop(1);
				}
				_mc.gotoAndStop(2);
				var temSex:int=selectedSex;
				var temCategory:int=category;
				selectedSex=icons.indexOf(_mc)<=3?1:2;
				trace("selectedSex="+selectedSex);
				if (selectedSex!=temSex) {
					onChangeName();
				}
				var iconIndex:int=int(_mc.name.substr(1,1));
				//trace("iconIndex="+iconIndex);

				_headIndex=iconIndex;
				///////////////////////////////////////////////
				bodyIndex=icons.indexOf(_mc);//第几个头像
				category=bodyIndex%4+1;//职业
				job_mc.y=jobPos[category-1];
				explain_mc.gotoAndStop(category);
				trace("bodyIndex="+bodyIndex);
				var body:MovieClip=bodys[bodyIndex];//拿身体
				//for (i=0; i<bodys.length; i++) {
					//trace(bodys[i].name);
				//}
				//trace("当前人："+curRole.name);
				//trace("切换到："+body.name);
				curRole=tarRole;
				tarRole=body;
				startRippler();
				//统计是否改过性别和职业
				if (selectedSex!=temSex) {
					c_sex=1;
				}
				if (category!=temCategory) {
					c_category=1;
				}
			}
		}

		private function onClickHW(e:MouseEvent):void {
			hw_mc.gotoAndStop(2);
			yl_mc.gotoAndStop(1);
			wl_mc.gotoAndStop(1);
			seletedFaction=1;
			c_faction=1;
		}
		private function onClickYL(e:MouseEvent):void {
			hw_mc.gotoAndStop(1);
			yl_mc.gotoAndStop(2);
			wl_mc.gotoAndStop(1);
			seletedFaction=2;
			c_faction=1;
		}
		private function onClickWL(e:MouseEvent):void {
			hw_mc.gotoAndStop(1);
			yl_mc.gotoAndStop(1);
			wl_mc.gotoAndStop(2);
			seletedFaction=3;
			c_faction=1;
		}
		private function startRippler():void {
			killRip();
			tarRip=new Rippler(tarRole,40,6);
			curRip=new Rippler(curRole,40,6);
			tarRip.drawRipple(centerArr[bodyIndex][0],centerArr[bodyIndex][1],20,1);
			curRip.drawRipple(centerArr[bodyIndex][0],centerArr[bodyIndex][1],20,1);
			if (this.hasEventListener(Event.ENTER_FRAME)==false) {
				this.addEventListener(Event.ENTER_FRAME,doRippling);
			} else {
				curRole.alpha>0.75?alphaFlag=true:alphaFlag=false;
				reAlpha();
			}
		}
		private function doRippling(e:Event):void {
			if (tarRole) {
				if (curRole.alpha>-1) {
					curRole.alpha-=speed;
				}
				if (alphaFlag) {
					tarRole.alpha=1-curRole.alpha-0.25;
				} else {
					if (tarRole.alpha<1) {
						tarRole.alpha+=speed;
					}
				}
				for (var i:int=0; i < bodys.length; i++) {
					if (bodys[i]!=tarRole&&bodys[i]!=curRole) {
						bodys[i].alpha-=speed*2;
						if (bodys[i].alpha<0) {
							bodys[i].alpha=0;
						}
					}
				}
			}
		}
		//清除旧效果
		private function killRip():void {
			if (tarRip!=null&&curRip!=null) {
				tarRip.destroy();
				curRip.destroy();
				for (var i:int=0; i < bodys.length; i++) {
					if (bodys[i]!=tarRole&&bodys[i]!=curRole) {
						bodys[i].filters=null;
					}
				}
			}
		}
		//重置透明度
		private function reAlpha():void {
			if (tarRole.alpha<0) {
				tarRole.alpha=0;
			}
			if (tarRole.alpha>1) {
				tarRole.alpha=1;
			}
			if (curRole.alpha>1) {
				curRole.alpha=1;
			}
			if (curRole.alpha<0) {
				curRole.alpha=0;
			}
		}
		private function txtTipEf(e:Event):void {
			if (txtTip_mc.alpha>0) {
				txtTip_mc.alpha-=speed;
			}
		}
		//文本框焦点处理
		private function onFocusInName(e:FocusEvent):void {
			trace(txtSelete);
			txtTip_mc.x=596;
			txtTip_mc.y=325;
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
			txtTip_mc.alpha=0;
		}
		private function onClickName(e:MouseEvent):void {
			if (name_txt.text=="请输入角色名") {
				name_txt.text="";
				name_txt.textColor=0xffffff;
			} else {
				if (isFirstFocusNameTxt==true) {
					trace("name_txt.text.length:"+name_txt.text.length);
					name_txt.setSelection(0,name_txt.text.length);
					isFirstFocusNameTxt=false;
				}
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
				setTipPos("up");
			} else {
				if (name_txt.text.length>=2&&name_txt.text.length<=7) {
					submit_btn.filters=[new GlowFilter(0xfff799,1,20,20)];
				}
			}
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
				setTipPos("up");
				return;
			}
			if (name_txt.text.length<2||name_txt.text.length>7) {
				txtTip_mc.txt.text="   角色名长度为2-7个字符。";
				txtTip_mc.alpha=tipShowTime;
				setTipPos("up");
				return;
			}
			if (name_txt.text=="请输入角色名") {
				stage.focus=name_txt;
				setTipPos("up");
				return;
			}
			if (agreemen_mc.currentFrame!=1) {
				txtTip_mc.txt.text="   必须先同意用户协议。";
				txtTip_mc.alpha=tipShowTime;
				setTipPos("down");
				return;
			}
			req_mc.visible=true;//设置按钮不能按
			var temHead:int;
			if (selectedSex==1) {
				temHead=2*_headIndex-1;
			} else {
				temHead=2*_headIndex;
			}
			temHead+=12;//加12是为了不与以前12个头像重复
			trace("头像index:"+_headIndex);
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
					navigateToURL(new URLRequest(_web_homeurl+game_path),"_self");
				} else {
					if (arr[0]=="error") {
						var type:String=arr[1] as String;
						switch (type) {
							case "hack_attemp" :
								navigateToURL(new URLRequest("www.mingchao.com"),"_self");//直接跳官网
								break;
							case "already_login" :
								navigateToURL(new URLRequest(_web_homeurl+game_path),"_self");//直接跳转到游戏内
								break;
							case "already_has_role" :
								navigateToURL(new URLRequest(_web_homeurl+game_path),"_self");//直接跳转到游戏内
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
		private function onClickAgreemen(e:MouseEvent):void {
			if (agreemen_mc.currentFrame==1) {
				agreemen_mc.gotoAndStop(2);
			} else {
				agreemen_mc.gotoAndStop(1);
			}
		}
		private function onClickAgreemenTxt(e:MouseEvent):void {
			if (agreemen_mc.currentFrame==1) {
				agreemen_mc.gotoAndStop(2);
			} else {
				agreemen_mc.gotoAndStop(1);
			}
		}
		private function onLick(e:TextEvent):void {
			navigateToURL(new URLRequest(_web_homeurl+"user/mccq_license.html"),"_blank");
		}

		private function doMusic(e:MouseEvent):void {
			if (bgm!=null) {
				if (music_mc.currentFrame==1) {
					bgm.setVolume(0);
					music_mc.gotoAndStop(2);
				} else {
					bgm.reVolume();
					music_mc.gotoAndStop(1);
				}
			}
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
					onTextChange();
				} else {
					name_txt.text="";
					onTextChange();
				}
			}
		}
	}
}