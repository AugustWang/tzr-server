package modules.friend.views.friendsetting
{
	import com.common.GlobalObjectManager;
	import com.globals.GameConfig;
	import com.ming.ui.controls.ComboBox;
	import com.ming.ui.controls.core.UIComponent;
	import com.utils.ComponentUtil;
	
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	
	import modules.broadcast.KeyWord;
	import modules.friend.FriendsModule;
	
	import proto.common.p_role;
	import proto.common.p_role_ext;
	
	public class TabBaseInfo extends Sprite
	{
		private const SEX_DATAS:Array = ["保密","男","女"];
		private const YEAR_DATAS:Array = [" "];
		private const MONTH_DATAS:Array = [" ",1,2,3,4,5,6,7,8,9,10,11,12];
		private var DAY_DATAS:Array = [" ",1,2,3,4,5,6,7,8,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31];
		private const STAR_DATAS:Array = [" ","鼠","牛","虎","兔","龙","蛇","马","羊","猴","鸡","狗","猪"];
		private var PROVINCE_DATAS:Array ; //对于国家和身份可能要级联配置
		private var CITY_DATAS:Array; //对于国家和身份可能要级联配置
		
		private var topBg:UIComponent;
		private var textBg:UIComponent;
		private var bottomBg:UIComponent;
		
		
		private var writeName:TextField;
		private var sexComboBox:ComboBox;
		private var yearComboBox:ComboBox;
		private var monthComboBox:ComboBox;
		private var dayComboBox:ComboBox;
		private var starComboBox:ComboBox;
		private var provinceComboBox:ComboBox;
		private var cityComboBox:ComboBox;
		private var dayIndex:int;
		
		public function TabBaseInfo(){
			init();
		}
		
		public function backUI():void{
			if(topBg && this.contains(topBg)){
				this.removeChild(topBg);
				topBg = null;
			}if(bottomBg && this.contains(bottomBg)){
				this.removeChild(bottomBg);
				bottomBg = null;
			}
			
		}
		
		private function init():void{
			topBg = ComponentUtil.createUIComponent(2,2,456,118);
			Style.setBorderSkin(topBg);
			addChild(topBg);
			
			textBg = ComponentUtil.createUIComponent(10,56,420,53);
			textBg.bgSkin = Style.getInstance().textAreaSkin;
			topBg.addChild(textBg);
			
			bottomBg = ComponentUtil.createUIComponent(2,122,456,186);
			Style.setBorderSkin(bottomBg);
			addChild(bottomBg);
			
			var role:p_role = GlobalObjectManager.getInstance().user;
			var roleNameDesc:TextField = ComponentUtil.createTextField("角色名：",12,12,null,NaN,NaN,topBg);
			var roleName:TextField = ComponentUtil.createTextField(role.attr.role_name,roleNameDesc.x + roleNameDesc.textWidth,roleNameDesc.y,null,NaN,NaN,topBg);
			roleName.textColor = 0xffff02;
			
			ComponentUtil.createTextField("个性签名：",12,33,null,NaN,NaN,topBg);
			
			
			writeName = ComponentUtil.createTextField("",2,2,null,404,40,textBg);
			writeName.mouseEnabled = true;
			writeName.selectable = true;
			writeName.type = "input";
			if(role.ext.signature.length == 0){
				writeName.text = "很懒，什么都没写";
			}else{
				writeName.htmlText = role.ext.signature; 
			}
			writeName.maxChars=25;
			writeName.addEventListener(FocusEvent.FOCUS_IN,function onFocusInHandler(evt:FocusEvent):void{
				writeName.text = "";
			});
				
			
			//性别
			ComponentUtil.createTextField("性别：",10,24,null,80,30,bottomBg);
			//1:男  2:女
			var sex:int = GlobalObjectManager.getInstance().user.ext.sex;
			sexComboBox = createComboBox(51,21,SEX_DATAS[sex],bottomBg);
			sexComboBox.dataProvider = SEX_DATAS;
			
			ComponentUtil.createTextField("生日：",10,56,null,80,30,bottomBg);
			for(var i:int = 2010;1910<=i;i--){
				YEAR_DATAS.push(i);
			}
			
			var birday_arr:Array = dealBirthday();
			
			yearComboBox = createComboBox(51,56,birday_arr[0],bottomBg);
			yearComboBox.dataProvider = YEAR_DATAS;
			yearComboBox.addEventListener(Event.CHANGE,onYearOrMonthChangeHandler);
			yearComboBox.name = "year";
			ComponentUtil.createTextField("年",125,56,Style.textFormat,80,30,bottomBg);
			monthComboBox = createComboBox(145,56,birday_arr[1],bottomBg);
			monthComboBox.dataProvider = MONTH_DATAS;
			monthComboBox.addEventListener(Event.CHANGE,onYearOrMonthChangeHandler);
			monthComboBox.name = "month";
			ComponentUtil.createTextField("月",223,56,Style.textFormat,80,30,bottomBg);
			dayComboBox = createComboBox(242,56,birday_arr[2],bottomBg);
			dayIndex = birday_arr[2];
			if(birday_arr[2].toString() == "0"){
				dayComboBox.dataProvider = []//DAY_DATAS;
			}else{
				dayComboBox.dataProvider = DAY_DATAS;
			}
			ComponentUtil.createTextField("日",318,56,Style.textFormat,80,30,bottomBg);
			
			//星座
			ComponentUtil.createTextField("生肖：",10,88,Style.textFormat,80,30,bottomBg);
			if(yearComboBox.selectedItem == ""){
				starComboBox = createComboBox(51,88,-1,bottomBg);
			}else{
				starComboBox = createComboBox(51,88,STAR_DATAS[GlobalObjectManager.getInstance().user.ext.constellation],bottomBg);
			}
			starComboBox.dataProvider = STAR_DATAS;
			//国家
			
			var dressDes:TextField = ComponentUtil.createTextField("地区：",10,120,Style.textFormat,80,30,bottomBg);
			PROVINCE_DATAS = LoadPrinceAndCityData.instance.prince_arr;
			provinceComboBox = createComboBox(dressDes.x + dressDes.textWidth+5,120,PROVINCE_DATAS[GlobalObjectManager.getInstance().user.ext.province],bottomBg);
			provinceComboBox.labelField = "princeName";
			provinceComboBox.dataProvider = PROVINCE_DATAS;
			provinceComboBox.addEventListener(Event.CHANGE, onChangeHandler);
			CITY_DATAS =  LoadPrinceAndCityData.instance.city_arr[0];
			var princeDesc:TextField = ComponentUtil.createTextField("省",provinceComboBox.x+provinceComboBox.width,120,Style.textFormat,80,30,bottomBg);
			cityComboBox = createComboBox(princeDesc.x+princeDesc.textWidth+10,120,CITY_DATAS[GlobalObjectManager.getInstance().user.ext.city],bottomBg);
			cityComboBox.dataProvider = CITY_DATAS;
			cityComboBox.width = 130;
			cityComboBox.labelField = "cityName";
			var cityDesc:TextField = ComponentUtil.createTextField("市",cityComboBox.x+ cityComboBox.width,120,Style.textFormat,80,30,bottomBg);
			
		}
		
		private function onChangeHandler(evt:Event):void{
			CITY_DATAS = [];
			CITY_DATAS = LoadPrinceAndCityData.instance.city_arr[provinceComboBox.selectedIndex];
			cityComboBox.dataProvider = CITY_DATAS;
			cityComboBox.selectedItem = CITY_DATAS[0];
		}
		
		private function onYearOrMonthChangeHandler(evt:Event):void{
			if(monthComboBox.selectedIndex == 0 || monthComboBox.selectedIndex == -1){
				dayComboBox.dataProvider = [];
				dayComboBox.selectedIndex = -1;
			}else{
				var arr:Array = isLeapYear(int(yearComboBox.selectedItem),int(monthComboBox.selectedItem));
				dayComboBox.dataProvider = arr;
				dayComboBox.selectedItem = arr[dayIndex];
				dayComboBox.selectedIndex = dayIndex;
			}
			isAnimal(int(yearComboBox.selectedItem));
		}
		
		//处理生日整数
		private function dealBirthday():Array{
			//生日
			var year_item:int;
			var month_item:int;
			var day_item:int;
			var born:String = String(GlobalObjectManager.getInstance().user.ext.birthday);
			if(born.length == 1){
				if(born == "0"){
					year_item = -1;
					month_item = -1;
					day_item = -1;
				}else{
					year_item = -1;
					month_item = -1;
					day_item = int(born);
				}
			}else{
				if(born.length == 4){//没有年，只有月日
					year_item = -1;
					month_item = int(born.substr(0,2));
					day_item = int(born.substr(2,2));
				}else if(born.length == 3){
					year_item = -1;
					month_item = int(born.substr(0,1));
					day_item = int(born.substr(1,2));
				}else if(born.length == 2){
					year_item = -1;
					month_item = -1;
					day_item = int(born);
				}else{
					year_item = int(born.substr(0,4));
					month_item = int(born.substr(4,2));
					day_item = int(born.substr(6,2));
				}
			}
			var arr:Array = [year_item,month_item,day_item];
			return arr;
		}
		
		private function isLeapYear(leap:int,monthItem:int):Array{
			DAY_DATAS = [];
			if((leap%4==0&&leap%100!=0)||(leap%400==0)){//闰年
				if(monthItem == 2){//闰年二月二十九天
					for(var i:int = 1;i<30;i++){
						DAY_DATAS.push(i);
					}
				}else{//非二月
					if(monthItem == 4||monthItem == 6 || monthItem == 9 || monthItem == 11){//4.6.9.11月为三十天
						for(var j:int=1;j<31;j++){
							DAY_DATAS.push(j);
						}
					}else{//1.3.5.7.8.10.12月为三十一天
						for(var k:int=1;k<32;k++){
							DAY_DATAS.push(k);
						}
					}
				}
				
			}else{//非闰年
				if(monthItem == 2){//28天
					for(var n:int = 1;n<29;n++){
						DAY_DATAS.push(n);
					}
				}else{//非二月
					if(monthItem == 4||monthItem == 6 || monthItem == 9 || monthItem == 11){//4.6.9.11月为三十天
						for(var m:int=1;m<31;m++){
							DAY_DATAS.push(m);
						}
					}else{//1.3.5.7.8.10.12月为三十一天
						for(var g:int=1;g<32;g++){
							DAY_DATAS.push(g);
						}
					}
				}
			}
			DAY_DATAS.unshift(" ");
			return DAY_DATAS;
		}
		
		//年算生肖
		private function isAnimal(year:int):void{
			var index:int = (year - 1900)%12;
			starComboBox.selectedItem = STAR_DATAS[index + 1];
		}
		
		
		private function createComboBox(posX:int,posY:int,$selected:Object,$parent:DisplayObjectContainer,$maxHeight:int = 100):ComboBox{
			var comboBox:ComboBox = new ComboBox();
			$parent.addChild(comboBox);
			comboBox.x = posX;
			comboBox.y = posY;
			comboBox.width = 74;
			comboBox.height = 23;
			if($selected == -1){
				comboBox.selectedItem = null;
			}else{
				comboBox.selectedItem = $selected;
			}
			comboBox.maxListHeight = $maxHeight;
			return comboBox;
		}
		/*
		 * public var role_id:int = 0;
		public var signature:String = "";
		public var birthday:int = 0;
		public var constellation:int = 0;
		public var country:int = 0;
		public var province:int = 0;
		public var city:int = 0;
		public var blog:String = "";
		public var family_last_op_time:int = 0;
		public var last_login_time:int = 0;
		public var last_offline_time:int = 0;
		public var role_name:String = "";
		public var sex:int = 0;
		public var skin:p_skin = null;
		*/
		public function clickSure():p_role_ext{
			var pVo:p_role_ext = new p_role_ext();
			pVo.role_id = GlobalObjectManager.getInstance().user.base.role_id;
			if(KeyWord.instance().hasUnRegisterString(writeName.text)){
				pVo.signature = KeyWord.instance().replace(writeName.text);
			}else{
				pVo.signature = writeName.text;
			}
			var y:String;
			var m:String;
			var d:String;
			y = String(yearComboBox.selectedItem);
			
			if(monthComboBox.selectedIndex == -1 || monthComboBox.selectedIndex == 0){
				m = "00";
			}else{
				if(int(monthComboBox.selectedItem)<10){
					m = "0"+monthComboBox.selectedItem ;
				}else{
					m = monthComboBox.selectedItem.toString();
				}
			}
			
			if(dayComboBox.selectedIndex == -1 || dayComboBox.selectedIndex == 0){
				d = "00" ;
			}else{
				if(int(dayComboBox.selectedItem)<10){
					d = "0"+dayComboBox.selectedItem ;
				}else{
					d = dayComboBox.selectedItem.toString();
				}
			}
			pVo.birthday = int(y+m+d);
			pVo.constellation = starComboBox.selectedIndex;
			pVo.province = provinceComboBox.selectedIndex;
			pVo.city = cityComboBox.selectedIndex;
			pVo.sex = sexComboBox.selectedIndex;
			
			//=======以下属性现在不需要=====
			pVo.country = 0;
			pVo.blog = "";
			pVo.family_last_op_time = 0;
			pVo.last_login_time = 0;
			pVo.last_offline_time = 0;
			pVo.role_name = "";
			return pVo;
		}
		/**
		 *点击取消键，数据的恢复 
		 * 
		 */		
		public function clickCancel():void{
//			init();
			FriendsModule.getInstance().communityWindow.closeWindow();			
		}
	}
}