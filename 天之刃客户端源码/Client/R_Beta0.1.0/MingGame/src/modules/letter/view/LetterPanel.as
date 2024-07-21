package modules.letter.view {
	import com.common.FilterCommon;
	import com.common.GlobalObjectManager;
	import com.components.BasePanel;
	import com.components.DataGrid;
	import com.components.HeaderBar;
	import com.components.alert.Alert;
	import com.managers.Dispatch;
	import com.managers.WindowManager;
	import com.ming.events.TabNavigationEvent;
	import com.ming.ui.containers.List;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.CheckBox;
	import com.ming.ui.controls.TabBar;
	import com.ming.ui.controls.core.UIComponent;
	import com.utils.ComponentUtil;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import modules.ModuleCommand;
	import modules.letter.LetterType;
	import modules.letter.LetterVOs;
	import modules.letter.messageBody.DelLetterData;
	import modules.letter.messageBody.LetterDetailData;
	import modules.letter.view.detail.LetterDetail;
	import modules.letter.view.detail.LetterWrite;
	
	import proto.line.m_letter_get_toc;
	import proto.line.p_letter_simple_info;

	public class LetterPanel extends BasePanel {

		private var tabBar:TabBar;
		public var lettersList:DataGrid;
		private var currentIndex:int=0;
		private var currentList:DataGrid;
		private var allAndCancelChk:CheckBox;
		private var delBtn:Button;
		private var writeBtn:Button;
		public var letterDetail:LetterDetail;
		private var currentOpenIndex:int;
		public var letterWrite:LetterWrite;
		private var vos:LetterVOs;
		private var selectedItems:Array=[];
		private var descTxt:TextField;
		private var letterPage:LetterPage;

		public function LetterPanel(xValue:Number=NaN, yValue:Number=NaN) {
			super();
			this.width=487;
			this.height=392;

			addTitleBG(446);
			addImageTitle("title_letter");
			addContentBG(8,8,24);

			vos=new LetterVOs();

		}

		/**
		 *1、pk信件保存2天。在信件内容内加入此句话：本信件保存两天。
		 *2、玩家升级信件保存5天，在信件内容内也加入此句话：本信件保存五天。
		 *3、超过14天不登陆的账号，将收不到任何系统信件（道具赠送、批量信件）
		 *
		 */
		public function initView():void {
			tabBar=new TabBar();
			this.addChild(tabBar); //1
			tabBar.x=15;
			tabBar.addItem("全部", 70, 25);
			tabBar.addItem("系统", 70, 25);
			tabBar.addItem("私人", 70, 25);
			tabBar.addItem("发件箱", 70, 25);
			tabBar.addItem("收件箱", 70, 25);
			tabBar.addEventListener(TabNavigationEvent.SELECT_TAB_CHANGED, onSelectChange);

			//背景
			var backUI:UIComponent=new UIComponent();
			this.addChild(backUI); //2
			Style.setBorderSkin(backUI);
			backUI.width=465;
			backUI.height=260;
			backUI.x=11;
			backUI.y=27;

			//所有信件列表
			lettersList=new DataGrid();
			lettersList.itemHeight = 23;
			lettersList.pageCount = 10;
			lettersList.itemRenderer = LetterItemRenderer;
			lettersList.width=462;
			lettersList.height=260;
			lettersList.addColumn("类型", 70);
			lettersList.addColumn("标题", 230);
			lettersList.addColumn("时间", 120);
			lettersList.addColumn("剩余", 40);
			addChild(lettersList);
			lettersList.x=12;
			lettersList.y=34;
			lettersList.list.addEventListener(MouseEvent.CLICK, onItemClickHandler);

			//分页
			letterPage=new LetterPage();
			this.addChild(letterPage);
			letterPage.y=298;
			letterPage.x=70;
			letterPage.addEventListener("DATA_CHAGE", onLetterPageHandler);

			descTxt=ComponentUtil.createTextField("* 信件最长保存14天，逾期将被系统删除，包括附件物品。", 10, 322, new TextFormat("Tahoma", 12, 0x00ff00), 380, 30, this);
			descTxt.filters = FilterCommon.FONT_BLACK_FILTERS;

			allAndCancelChk=ComponentUtil.createCheckBox("全选", 15, 295,this);
			allAndCancelChk.textFilter = FilterCommon.FONT_BLACK_FILTERS;
			
			allAndCancelChk.addEventListener(Event.CHANGE,allAndCancelBtnHandler);
			delBtn=createBtn("删除", 342, 295, 65, delHandler);
			writeBtn=createBtn("写信", delBtn.x + delBtn.width, delBtn.y, 65, writeHandler);

		}

		/**
		 *导航条事件
		 * @param evt
		 *
		 */
		private function onSelectChange(evt:TabNavigationEvent):void {
			if (currentIndex == evt.index)
				return;

			currentIndex=evt.index;
			refreshData(); //每次更新数据
		}

		/**
		 *所有的信件
		 * @param vo
		 *
		 */
		public function appendData(vo:m_letter_get_toc):void {
			vos.appendData(vo); //获取所有信件
			refreshData(); //刷新数据
		}

		/**
		 *收到新的信件
		 * @param vo
		 *
		 */
		public function addLetter(vo:p_letter_simple_info):void {
			vos.addLetter(vo);
			refreshData();
		}

		/**
		 *删除 信件
		 * @param letters
		 *
		 */
		public function delLetters(letters:Array):void {
			if (selectedItems.length != 0) {
				for each (var d:p_letter_simple_info in selectedItems) {
					var item:LetterItemRenderer=lettersList.list.getItemByData(d) as LetterItemRenderer;
					item.checkBox.selected=false;
				}
			}
			vos.delData(letters);
			refreshData();
			delBtn.mouseEnabled=true;
			allAndCancelChk.text="全选";
		}

		/**
		 *点击页数的操作
		 * @param evt
		 *
		 */
		private function onLetterPageHandler(evt:Event):void {
			dealChangePage(lettersList, LetterPage.content_arr);
		}

		/**
		 *当翻页时，对不同页上选中的信件的处理
		 * @param currentList
		 *
		 */
		private function dealChangePage(currentList:DataGrid, currentArr:Array):void {
			currentList.dataProvider=currentArr;
			currentList.list.selectedIndex=-1;
			currentList.validateNow();
			if (selectedItems.length != 0 && currentArr.length != 0) {
				for each (var vo:p_letter_simple_info in currentArr) {

					for each (var v:p_letter_simple_info in selectedItems) {
						if (vo.id == v.id) {
							LetterItemRenderer(currentList.list.getItemByData(vo)).checkBox.selected=true;
						} else {
							var item:LetterItemRenderer=currentList.list.getItemByData(vo) as LetterItemRenderer;
							item.checkBox.selected=false;
						}
					}
				}
			}
		}

		/**
		 *点击上一封或下一封跳转到下一页
		 * @param list
		 * @param page_array
		 *
		 */
		public function afterPreOrNextSeal(list:DataGrid, page_array:Array):void {
			dealChangePage(list, page_array);
		}

		/**
		 *全选和取消按钮事件
		 * @param evt
		 *
		 */
		private function allAndCancelBtnHandler(evt:Event):void {
			if (lettersList != null) {
				if (lettersList.list.dataProvider.length == 0) {
					Alert.show("你当前没有信件！", "提示", null, null, "确定", "取消", null, false);
					return;
				}
			}
			if (CheckBox(evt.currentTarget).text == "全选") {
				CheckBox(evt.currentTarget).text="取消";
				select(true);
			} else {
				CheckBox(evt.currentTarget).text="全选";
				selectedItems.length=0;
				select(false);
			}
		}

		/**
		 *获取信件详情的实例
		 * @return
		 *
		 */
		public function getLetterDetail():LetterDetail {
			return letterDetail;
		}

		/**
		 *写信
		 * @param username
		 *
		 */
		public function writeLetter(username:String=null, content:String="", isFamilyLetter:Boolean=false):void {
			if (letterWrite == null) {
				letterWrite=new LetterWrite();
			}
			if (isFamilyLetter) {
				letterWrite.name_txtInput.enabled=false;
				letterWrite.accessory.visible=false;
			} else {
				letterWrite.name_txtInput.enabled=true;
				letterWrite.accessory.visible=true;
			}
			letterWrite.reset();
			if (username != null) {
				letterWrite.setReceiver(username);
			}
			letterWrite.setContent(content);
			WindowManager.getInstance().popUpWindow(letterWrite, WindowManager.UNREMOVE);
			WindowManager.getInstance().centerWindow(letterWrite);
		}

		/**
		 *刷新List列表里的信息
		 *
		 */
		private var arr:Array;

		private function refreshData():void {
			switch (tabBar.selectIndex) {
				case 0:
					arr=vos.getTypeLetters(LetterVOs.ALL).concat();
					break;
				case 1:
					arr=vos.getTypeLetters(LetterVOs.SYSTEM).concat();
					break;
				case 2:
					arr=vos.getTypeLetters(LetterVOs.PRIVATE).concat();
					break;
				case 3:
					arr=vos.getTypeLetters(LetterVOs.SEND).concat();
					break;
				case 4:
					arr=vos.getTypeLetters(LetterVOs.RECEIVE).concat();
					break;
			}
			letterPage.createPageNum(arr, 0, 0, 10);
			dealChangePage(lettersList, LetterPage.content_arr);
			selectedItems.length=0;
			allAndCancelChk.text="全选";
		}


		/**
		 *按钮的创建
		 *
		 */
		private function createBtn(label:String, xValue:Number, yValue:Number, w:Number, listener:Function=null):Button {
			var btn:Button=new Button;
			btn.label=label;
			btn.x=xValue;
			btn.y=yValue;
			btn.width=w;
			btn.height=25;
			addChild(btn);
			if (listener != null)
				btn.addEventListener(MouseEvent.CLICK, listener);
			return btn;
		}

		/**
		 * bool为true表示全选，false表示全部取消.
		 * @param bool
		 *
		 */
		private function select(bool:Boolean):void {
			if (lettersList != null) {
				var num:int=lettersList.list.numChildren;
				for (var i:int=0; i < num; i++) {
					var child:LetterItemRenderer=lettersList.list.getChildAt(i) as LetterItemRenderer;
					if (child) {
						child.selected(bool);
						if (bool == true)
							selectedItems.push(child.data);
					}
				}
			}

		}

		/**
		 *删除信件（单条或批量）
		 * @param evt
		 *
		 */
		private function delHandler(evt:Event):void {
			if (selectedItems.length == 0) {
				Alert.show("请选择您要删除的信件！", "提示", null, null, "确定", "取消", null, false);
			} else {
				if(letterDetail != null && WindowManager.getInstance().container.contains(letterDetail) == true)
				{
					var index:int = WindowManager.getInstance().container.getChildIndex(letterDetail);
					if( index != -1)
					{
						WindowManager.getInstance().removeWindow(letterDetail);
					}
				}
				var body:DelLetterData=new DelLetterData();
				body.delLetter(selectedItems);
				delBtn.mouseEnabled=false;
				allAndCancelChk.text="全选";
			}
		}

		/**
		 *写信按钮事件
		 * @param evt
		 *
		 */
		private function writeHandler(evt:Event):void {
			//获取发送了信件的数组
			var sendLetters:Array=vos.getTypeLetters(LetterVOs.SEND);
			if (sendLetters.length < 51) {
				writeLetter();
			} else {
				//当目前的长度大于50的时候，再查看是不是全部都是今天发的p_letter_simple_info
				var length:int=sendLetters.length;
				//获取今天前的微秒数
				var today:Number=getTodayTimer();
				//今天发的封数
				var todayNum:int=0;
				for (var i:int=0; i < length; i++) {
					var data:p_letter_simple_info=sendLetters[i];
					if (data.send_time * 1000 - today > 0) {
						todayNum++;
					}
				}
				if (todayNum < 51) {
					writeLetter();
				} else {
					Alert.show("每天最多只能发50封信!", "提示", null, null, "确定", "取消", null, false);
				}
			}

		}

		private function getTodayTimer():Number {
			var date:Date=new Date();
			var year:Number=date.getFullYear();
			var month:Number=date.getMonth();
			var today:Number=date.getDate();

			var todayNum:Number=date.setFullYear(year, month, today);
			return todayNum;
		}

		/**
		 *点击的事件 单一一封信件的事件
		 * @param evt
		 *
		 */
		public var currentItemRender:LetterItemRenderer;
		public var messageBody:LetterDetailData;

		private function onItemClickHandler(evt:Event):void {
			var tar:LetterItemRenderer=evt.target as LetterItemRenderer;
			if (tar != null && p_letter_simple_info(tar.data).state == LetterType.UNOPEN) {
				Dispatch.dispatch(ModuleCommand.STOP_FLASH_SOMETHING, "letter");
			}
			if (tar == null) { //如果点击的不是复选框
				checkBoxHandler(evt);
				return;
			}

			if (letterDetail == null) { //信件详情面板
				letterDetail=new LetterDetail();
			}
			letterDetail.centerOpen();

			currentItemRender=tar;
			currentOpenIndex=tabBar.selectIndex;

			//向后台请求该信件的详细信息
			messageBody=new LetterDetailData();
			messageBody.getDetail(tar, letterDetail);
		}

		/**
		 * 获取信件。pre为true标志前一封信件，false标志后一封信件.
		 * @param pre标志是前一封还是后一封
		 * @return 信件返回，没有返回null
		 * currentOpenIndex：指的是该信件属于那一类型：全部、私人、、、
		 * simpleVo：是经过处理得到上一封或下一封信件的VO
		 */
		public function getLetter(pre:Boolean):p_letter_simple_info {
			if (currentItemRender) { //这是得到前一个信件在列表里的信息(如果说渲染器为第一个或最后一个时，simpleVo会出现的空的情况)
				var simpleVo:p_letter_simple_info=vos.getLetter(currentOpenIndex, pre, currentItemRender.data as p_letter_simple_info, LetterPage.content_arr, this, letterPage);
				if (simpleVo) {
					currentItemRender=lettersList.list.getItemByData(simpleVo) as LetterItemRenderer;
					this.getLetterDetail().nextLetterItemRender=currentItemRender;
				}
				return simpleVo;
			}
			return null;
		}

		/**
		 *点击复选框的操作
		 * @param evt
		 *
		 */
		private function checkBoxHandler(evt:Event):void {
			if (evt.target is DisplayObject) {
				var item:LetterItemRenderer=List(evt.currentTarget).selectedChild as LetterItemRenderer;
				if (item != null) {
					if (item.checkBox.selected) {
						selectedItems.push(item.data);
					} else {
						for (var i:int=0; i < selectedItems.length; i++) {
							if (item.data == selectedItems[i]) {
								selectedItems.splice(i, 1);
								return;
							}
						}
					}
				}
			}
		}
	}
}