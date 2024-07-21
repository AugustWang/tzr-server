package modules.forgeshop.views
{
	import com.common.GlobalObjectManager;
	import com.components.BasePanel;
	import com.components.alert.Alert;
	import com.ming.events.CloseEvent;
	import com.ming.events.TabNavigationEvent;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.TabNavigation;
	import com.ming.ui.controls.core.UIComponent;
	import com.net.SocketCommand;
	import com.utils.ComponentUtil;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	import modules.broadcast.views.BroadcastSelf;
	import modules.broadcast.views.Tips;
	import modules.deal.DealConstant;
	import modules.forgeshop.ForgeshopModule;
	import modules.mypackage.ItemConstant;
	import modules.mypackage.managers.PackManager;
	import modules.mypackage.vo.BaseItemVO;
	import modules.mypackage.vo.EquipVO;
	import modules.mypackage.vo.GeneralVO;
	import modules.mypackage.vo.StoneVO;
	
	import proto.line.m_equip_build_build_toc;
	import proto.line.m_equip_build_build_tos;
	import proto.line.m_equip_build_decompose_toc;
	import proto.line.m_equip_build_decompose_tos;
	import proto.line.m_equip_build_fiveele_goods_toc;
	import proto.line.m_equip_build_fiveele_toc;
	import proto.line.m_equip_build_fiveele_tos;
	import proto.line.m_equip_build_goods_toc;
	import proto.line.m_equip_build_quality_goods_toc;
	import proto.line.m_equip_build_quality_toc;
	import proto.line.m_equip_build_quality_tos;
	import proto.line.m_equip_build_signature_toc;
	import proto.line.m_equip_build_signature_tos;
	import proto.line.m_equip_build_upgrade_goods_toc;
	import proto.line.m_equip_build_upgrade_link_toc;
	import proto.line.m_equip_build_upgrade_toc;
	import proto.line.m_equip_build_upgrade_tos;
	
	public class ForgeshopWindows  extends BasePanel
	{
		private var defaultX:Number = 300;
		private var defaultY:Number = 90;
		private var defaultH:Number = 385;
		private var defaultW:Number = 560;
		
		private var tabNavigation:TabNavigation;	
		private var btSubmit:Button;
		private var currentIndex:String;
		
		private var equipCreateCanvas:EquipCreateCanvas;
		private var equipResolveCanvas:EquipResolveCanvas;
		private var equipUpgradeCanvas:EquipUpgradeCanvas;
		private var supLeftCanvas:SupLeftCanvas;
		private var subPingzhiCanvas:SubPingzhiCanvas;
		private var subWuxinggCanvas:SubWuxinggCanvas;
		private var subJianmingCanvas:SubJianmingCanvas;
		//,"改造收费："
		public static const MONEY_ARRAY:Array = ["打造收费：","改造收费：","改名收费：","升级收费：","分解收费：","五行收费："];
		//,WUXING:"五行改造"
		public static const TABNAME_ARRAY:Object= {CREATE:"装备打造",PINGZHI:"品质改造",JIANMING:"更改签名",UPGRADE:"装备升级",RESOLVE:"装备分解",WUXING:"五行改造"};
		public static const EUQIP_CREATE:String = "请选择你要打造的装备的等级段";
		public static const EUQIP_CHANGE:String = "请放入想要品质改造的装备";
		public static const CHANGE_NAME:String = "请放入想要更改名字的装备";
		public static const EQUIP_UPDATE:String = "请放入想要升级的装备";
		public static const EQUIP_REMOVE:String = "请放入想要分解的装备";
		public static const WUXING_CHANGE:String = "请放入想要五行改造的装备";
		private var left_desc_txt:TextField;
		private var money_txt:TextField;
		private var money_desc_txt:TextField;
		public var navigationSelectIndex:int;//导航条索引
		public function ForgeshopWindows()
		{
			super("ForgeshopWindows");
			this.width = 560;
			this.height = 385;
			this.x = (1000 - this.width)/6;
			this.y = (GlobalObjectManager.GAME_HEIGHT - this.height)/2;
			this.addEventListener(CloseEvent.CLOSE,onCloseHandler);
		}
		/**
		 *关闭界面，需要把装备移回到背包 
		 * @param evt
		 * 
		 */		
		public static var isOpen:Boolean = false;
		public function onCloseHandler(evt:CloseEvent = null):void{
			swapGoods();
			disposeEquipData();
			disposeQulityData();
			disposeEquipCreateData();
			disposeSignNameData();
			disposeEquipRemoveData();
			disposeWuXingData();
			
			isOpen = true;
		}
		
		public function swapGoods():void{
			if(supLeftCanvas && supLeftCanvas.equipItem.data){
				var equipVo:EquipVO = supLeftCanvas.equipItem.data as EquipVO;
				PackManager.getInstance().lockGoods(equipVo,false);
				PackManager.getInstance().updateGoods(equipVo.bagid,equipVo.position,equipVo);
				supLeftCanvas.equipItem.disposeContent();
			}
			if(isUpdateBoxHasData()){
				equipUpgradeCanvas.updateItem.disposeContent();
			}
		}
		/**
		 *清空右边的数据 (升级)
		 * 
		 */		
		public function disposeEquipData():void{
			if(equipUpgradeCanvas){
				equipUpgradeCanvas.cleanAttach();
				equipUpgradeCanvas.cleanMaterial();
			}
		}
		
		/**
		 *清空右边的数据 
		 * @param state
		 * 
		 */	
		public function disposeQulityData():void{
			if(subPingzhiCanvas){
				subPingzhiCanvas.cleanAttach();
			}
		}
		
		/**
		 *清空右边的数据(打造) 
		 * @param state
		 * 
		 */		
		public function disposeEquipCreateData():void{
			if(equipCreateCanvas){
				equipCreateCanvas.cleanEquipCreateMaterial();
			}
		}
		
		/**
		 *清除(签名) 
		 * @param state
		 * 
		 */	
		public function disposeSignNameData():void{
			if(subJianmingCanvas){
				subJianmingCanvas.cleanSignNameData();
			}
		}
		
		/**
		 *清除(分解) 
		 * @param state
		 * 
		 */	
		public function disposeEquipRemoveData():void{
			if(equipResolveCanvas){
				equipResolveCanvas.cleanRemoveData();
			}
		}
		
		/**
		 *清除（五行） 
		 * 
		 */		
		public function disposeWuXingData():void{
			if(subWuxinggCanvas){
				subWuxinggCanvas.cleanData();
			}
		}
		
		override protected function init():void{
			this.width = 560;
			this.height = 385;
			
			title = "铁匠铺";
			this.x = 300 ;
			this.y = 90 ;
			
			//深绿色背景
			var purpleUI:Sprite = Style.getBlackSprite(271,25,2);
			this.addChild(purpleUI);
			purpleUI.x = 10;
			purpleUI.y = 29;
			
			var tabBG:UIComponent = new UIComponent();
			addChild(tabBG);
			tabBG.x = 4;
			tabBG.y = 24;
			tabBG.width = 551;
			tabBG.height = 326;
			Style.setBorderSkin(tabBG);
			
			//深绿色背景上的文本
			left_desc_txt = ComponentUtil.createTextField(EUQIP_CREATE,purpleUI.x+7,purpleUI.y+3,null,160,30,this);
			left_desc_txt.textColor = 0xffcc00;
			
			//右边的背景
			var rightBackUI:Sprite = Style.getBlackSprite(266,252,2);
			this.addChild(rightBackUI);
			rightBackUI.x = purpleUI.x + purpleUI.width+2;
			rightBackUI.y = purpleUI.y;
			
			//左边的背景
			supLeftCanvas = new SupLeftCanvas();
			supLeftCanvas.x = 10;
			supLeftCanvas.y = purpleUI.y + purpleUI.height;
			this.addChild(supLeftCanvas);
			supLeftCanvas.visible = false;
			
			//导航条
			tabNavigation = new TabNavigation();
			tabNavigation.x = 10;
			tabNavigation.y = 2;
			tabNavigation.width = defaultW;
			tabNavigation.height = 25;
			tabNavigation.tabContainerSkin=null;
			addChild(tabNavigation);
			
			//装备打造	
			equipCreateCanvas = new EquipCreateCanvas();
			//品质打造
			subPingzhiCanvas = new SubPingzhiCanvas();
			subPingzhiCanvas.x = rightBackUI.x - 10;
			subPingzhiCanvas.y = rightBackUI.y - 27;
			//更改签名
			subJianmingCanvas = new SubJianmingCanvas();
			subJianmingCanvas.x = rightBackUI.x - 9;
			subJianmingCanvas.y = rightBackUI.y - 25;
			//装备升级
			equipUpgradeCanvas = new EquipUpgradeCanvas();
			equipUpgradeCanvas.x = rightBackUI.x - 9;
			equipUpgradeCanvas.y = rightBackUI.y - 25;
			//装备分解
			equipResolveCanvas = new EquipResolveCanvas();	
			equipResolveCanvas.x = rightBackUI.x - 9;
			equipResolveCanvas.y = rightBackUI.y - 25;
			//五行改造
			subWuxinggCanvas = new SubWuxinggCanvas();
			subWuxinggCanvas.x = rightBackUI.x - 9;
			subWuxinggCanvas.y = rightBackUI.y - 25;
			
			tabNavigation.addItem(TABNAME_ARRAY.CREATE,equipCreateCanvas,70,25);//0
			tabNavigation.addItem(TABNAME_ARRAY.PINGZHI,subPingzhiCanvas,70,25);//1
			tabNavigation.addItem(TABNAME_ARRAY.JIANMING,subJianmingCanvas,70,25);//2
			tabNavigation.addItem(TABNAME_ARRAY.UPGRADE,equipUpgradeCanvas,70,25);//3
			tabNavigation.addItem(TABNAME_ARRAY.RESOLVE,equipResolveCanvas,70,25);//4
			//			tabNavigation.addItem(TABNAME_ARRAY.WUXING,subWuxinggCanvas,70,25);//5(该功能未开放)
			tabNavigation.addEventListener(TabNavigationEvent.SELECT_TAB_CHANGED, onSelectChange);
			
			
			
			//默认装备打造
			currentIndex = TABNAME_ARRAY.CREATE;
			btSubmit =	ComponentUtil.createButton(currentIndex,245,315,70,25,this,Style.setRedBtnStyle);
			btSubmit.addEventListener(MouseEvent.CLICK,onClickHandler);
			
			//打造银子的背景
			var createSilverUI:Sprite = Style.getBlackSprite(266,27,2);
			this.addChild(createSilverUI);
			createSilverUI.x = rightBackUI.x;
			createSilverUI.y = rightBackUI.y + rightBackUI.height+2;
			money_desc_txt = ComponentUtil.createTextField(MONEY_ARRAY[0],createSilverUI.x + 2,createSilverUI.y + 3,null,60,30,this);
			money_txt = ComponentUtil.createTextField("",money_desc_txt.x + money_desc_txt.width,createSilverUI.y + 3,null,120,30,this);
		}
		
		//导航按钮事件
		private function onSelectChange(evt:TabNavigationEvent):void{
			navigationSelectIndex = tabNavigation.selectedIndex;
			btSubmit.mouseEnabled = true;
			btSubmit.visible = true;
			money_desc_txt.visible = true;
			money_txt.visible = true;
			switch(tabNavigation.selectedIndex){
				case 0:	//装备打造
					currentIndex = TABNAME_ARRAY.CREATE;
					btSubmit.label = currentIndex;
					supLeftCanvas.visible = false;
					left_desc_txt.text = EUQIP_CREATE;
					ForgeshopModule.getInstance().requestCurrentMaterialList(0);
					
					disposeEquipData();
					disposeQulityData();
					disposeEquipCreateData();
					disposeSignNameData();
					disposeEquipRemoveData();
					disposeWuXingData();
					break;
				case 1:	//品质	
					currentIndex = TABNAME_ARRAY.PINGZHI;
					btSubmit.label = currentIndex;
					supLeftCanvas.visible = true;
					left_desc_txt.text = EUQIP_CHANGE;
					if(supLeftCanvas.equipItem.data){//框框里是否已经装备
						ForgeshopModule.getInstance().requestEquipChangeMaterial(0);
					}else{
						money_txt.text = DealConstant.silverToOtherString(0);
						disposeEquipData();
						disposeQulityData();
						disposeEquipCreateData();
						disposeSignNameData();
						disposeEquipRemoveData();
						disposeWuXingData();
					}
					
					break;
				
				case 2:	//签名
					currentIndex = TABNAME_ARRAY.JIANMING;
					btSubmit.label = currentIndex;
					supLeftCanvas.visible = true;
					left_desc_txt.text = CHANGE_NAME;
					if(supLeftCanvas.equipItem.data){
						getChangeNameInfo(supLeftCanvas.equipItem.data as EquipVO);
					}else{
						money_txt.text = DealConstant.silverToOtherString(0);
						disposeEquipData();
						disposeQulityData();
						disposeEquipCreateData();
						disposeSignNameData();
						disposeEquipRemoveData();
						disposeWuXingData();
					}
					
					
					break;
				case 3://升级
					currentIndex = TABNAME_ARRAY.UPGRADE;
					btSubmit.label = currentIndex;
					supLeftCanvas.visible = true;
					btSubmit.mouseEnabled = false;
					btSubmit.visible = false;
					money_desc_txt.visible = false;
					money_txt.visible = false;
					left_desc_txt.text = EQUIP_UPDATE;
					if(isHasData()){
						ForgeshopModule.getInstance().requestEquipUpdateMaterial(0);
					}else{
						money_txt.text = DealConstant.silverToOtherString(0);
						disposeEquipData();
						disposeQulityData();
						disposeEquipCreateData();
						disposeSignNameData();
						disposeEquipRemoveData();
						disposeWuXingData();
					}			
					break;
				case 4://分解
					currentIndex = TABNAME_ARRAY.RESOLVE;
					btSubmit.label = currentIndex;
					supLeftCanvas.visible = true;
					left_desc_txt.text = EQUIP_REMOVE;
					if(supLeftCanvas.equipItem.data){
						getEquipDestroyInfo(supLeftCanvas.equipItem.data as EquipVO);
					}else{
						money_txt.text = DealConstant.silverToOtherString(0);
						disposeEquipData();
						disposeQulityData();
						disposeEquipCreateData();
						disposeSignNameData();
						disposeEquipRemoveData();
						disposeWuXingData();
					}
					
					
					break;
				case 5:	//五行
					currentIndex = TABNAME_ARRAY.WUXING;
					btSubmit.label = currentIndex;
					supLeftCanvas.visible = true;
					left_desc_txt.text = WUXING_CHANGE;
					if(supLeftCanvas.equipItem.data){
						ForgeshopModule.getInstance().requestWuXingMaterial(0);
					}else{
						money_txt.text = DealConstant.silverToOtherString(0);
						disposeEquipData();
						disposeQulityData();
						disposeEquipCreateData();
						disposeSignNameData();
						disposeEquipRemoveData();
						disposeWuXingData();
					}
					break;
			}
			
			
			money_desc_txt.text = MONEY_ARRAY[tabNavigation.selectedIndex];
			if(tabNavigation.selectedIndex != 0 ){
				left_desc_txt.x = (270 - left_desc_txt.textWidth)/2;
			}else{
				left_desc_txt.x = 17;
			}
		}
		
		/**
		 *更改签名数据的获取 
		 * @return 
		 * 
		 */		
		public function getChangeNameInfo(equipVo:EquipVO):void{
			subJianmingCanvas.setData(equipVo,money_txt);
		}
		
		/**
		 *装备分解数据获取 
		 * @param e
		 * 
		 */
		public function getEquipDestroyInfo(equipVo:EquipVO):void{
			equipResolveCanvas.setData(equipVo,money_txt);
		}
		
		/**
		 *清除物品 
		 * 
		 */		
		public function cleanGoods():void{
			supLeftCanvas.equipItem.disposeContent();
		}
		/**
		 * 判断框框里是否有装备
		 * @return 
		 * 
		 */		
		public function isHasData():Boolean{
			if(supLeftCanvas && supLeftCanvas.equipItem.data){
				return true;
			}
			return false;	
		}
		
		/**
		 * 判断升级框里是否有装备
		 * @param e
		 * 
		 */
		public function isUpdateBoxHasData():Boolean{
			if(equipUpgradeCanvas && equipUpgradeCanvas.updateItem.data){
				return true;
			}
			return false;
		}
		/**
		 *清除升级框的物品 
		 * 
		 */		
		public function cleanUpdateGoods():void{
			equipUpgradeCanvas.updateItem.disposeContent();
		}
		
		/**
		 *点击按钮提交数据事件 
		 * @param e
		 * 
		 */	
		private var currentBtn:Button;
		private function onClickHandler(e:MouseEvent):void{
			currentBtn = e.currentTarget as Button;
			currentBtn.enabled = false;
			switch(tabNavigation.selectedIndex){
				case 0://打造		
					var vo : m_equip_build_build_tos = equipCreateCanvas.getEquipBuildInfo();
					if(vo){
						ForgeshopModule.getInstance().requestBuildEquip(vo);  //请求装备打造
					}else{
						currentBtn.enabled = true;
					}
					break;
				case 1:	//品质	
					var equipChangeVo:m_equip_build_quality_tos = subPingzhiCanvas.getEquipChangeInfo();
					var attach_bool:Boolean = false;
					if(equipChangeVo){
						var array_base:Array = PackManager.getInstance().getGoodsByType(equipChangeVo.add_type_id);
						for(var i:int = 0;i<array_base.length;i++){
							if(BaseItemVO(array_base[i]).bind){
								attach_bool = true;
								break;
							}
						}
						
						if(attach_bool && !EquipVO(supLeftCanvas.equipItem.data).bind){
							Alert.show("由于您使用的材料是“绑定”的，本操作将会绑定装备，是否继续？","提示",function okHandler():void{
								ForgeshopModule.getInstance().requestEquipChange(equipChangeVo);
							},function noHandler():void{
								subPingzhiCanvas.checkBoxState(true);
								currentBtn.enabled = true;
							});
						}else{
							ForgeshopModule.getInstance().requestEquipChange(equipChangeVo);
						}
					}else{
						currentBtn.enabled = true;
					}
					break;
				
				case 2:	//签名
					var changeNameVO:m_equip_build_signature_tos = subJianmingCanvas.equipChangeNameInfo();
					if(changeNameVO){
						var name:String = EquipVO(supLeftCanvas.equipItem.data).name;
						Alert.show("你确定要更改装备<font color='#ffcc00'>"+name+"</font>的名称吗？","",function sureHandler():void{
							ForgeshopModule.getInstance().requestEquipChangeName(changeNameVO);
						},function noHandler():void{
							currentBtn.enabled = true;
						});
					}else{
						currentBtn.enabled = true;
					}
					
					break;	
				case 3://升级
					var updateEquipVo:m_equip_build_upgrade_tos = equipUpgradeCanvas.getEquipUpdateInfo();
					var base_arr:Array;
					var base_bool:Boolean = false;
					if(updateEquipVo){//保证该装备一定可以升级
						base_arr = PackManager.getInstance().getGoodsByType(updateEquipVo.base_type_id);
						var arr:Array = [equipUpgradeCanvas.isQ,equipUpgradeCanvas.isS,equipUpgradeCanvas.isB,equipUpgradeCanvas.isW];
						var cnt:int = 0;
						for each(var boo:Boolean in arr){
							if(boo == true){
								cnt++;
							}
						}
						
						if(cnt >= 2){//至少有两个以上需要保留
							var arr_value:Array = [updateEquipVo.quality_type_id,updateEquipVo.reinforce_type_id,updateEquipVo.bind_attr_type_id,updateEquipVo.five_ele_type_id];
							var arr_selected:Array = [equipUpgradeCanvas.isSelect_Q,equipUpgradeCanvas.isSelect_S,equipUpgradeCanvas.isSelect_B,equipUpgradeCanvas.isSelect_W];
							var v:int = 0;
							var se:int = 0;
							for each(var value:int in arr_value){
								if(value !=0){
									v++;
								}
							}
							
							for each(var select:Boolean in arr_selected){
								if(select == true){
									se++;
								}
							}
							if(se != v){
								Alert.show("有需要保留的属性未勾选，装备升级后会有相关属性丢失，是否继续？","警告",function okHandler():void{
									ForgeshopModule.getInstance().requestEquipUpdate(updateEquipVo);
								},function noHandler():void{
									currentBtn.enabled = true;
								});
							}else{
								if(cnt == se){//全部勾选上
									ForgeshopModule.getInstance().requestEquipUpdate(updateEquipVo);
								}else{//全部没勾选
									Alert.show("有需要保留的属性未勾选，装备升级后会有相关属性丢失，是否继续？","警告",function okHandler():void{
										ForgeshopModule.getInstance().requestEquipUpdate(updateEquipVo);
									},function noHandler():void{
										currentBtn.enabled = true;
									});
								}
							}
						}else if(cnt == 0){//没有需要保留的属性
							//if(EquipVO(supLeftCanvas.equipItem.data).bind == false){
								//								base_arr = PackManager.getInstance().getGoodsByType(updateEquipVo.base_type_id);
								for(var ba:int = 0;ba<base_arr.length;ba++){
									if(GeneralVO(base_arr[ba]).bind){//如果基础材料是绑定的
										base_bool = true;
										break;
									}
								}
								
								if(base_bool){//如果基础材料为绑定就不考虑附加材料是否存在绑定的情况
									Alert.show("由于您使用的材料是“绑定”的，本操作将会绑定装备，是否继续？","提示",function okHandler():void{
										ForgeshopModule.getInstance().requestEquipUpdate(updateEquipVo);
									},function onHandler():void{
										currentBtn.enabled = true;
									});
								}else{
									ForgeshopModule.getInstance().requestEquipUpdate(updateEquipVo);
								}
							//}
							//							ForgeshopModel.getInstance().requestEquipUpdate(updateEquipVo);
						}else if(cnt == 1){//有一项需要保留的属性
							if(arr[0] == true){
								//该装备只有品质需要保留
								if(updateEquipVo.quality_type_id ==0){
									Alert.show("不保留装备品质，该项装备品质将会降低","警告",function okHandler():void{
										ForgeshopModule.getInstance().requestEquipUpdate(updateEquipVo);
									},function noHandler():void{
										currentBtn.enabled = true;
									});
								}else{
									ForgeshopModule.getInstance().requestEquipUpdate(updateEquipVo);
								}
							}else if(arr[1] == true){
								//该装备只有强化需要保留
								if(updateEquipVo.reinforce_type_id == 0){
									Alert.show("不保留装备强化值，该项装备星级将会降低","警告",function okHandler():void{
										ForgeshopModule.getInstance().requestEquipUpdate(updateEquipVo);
									},function noHandler():void{
										currentBtn.enabled = true;
									});
								}else{
									ForgeshopModule.getInstance().requestEquipUpdate(updateEquipVo);
								}
							}else if(arr[2] == true){
								//该装备只有绑定需要保留
								if(EquipVO(supLeftCanvas.equipItem.data).bind){//如果这个装备是绑定的
									if(updateEquipVo.bind_attr_type_id == 0){
										Alert.show("不保留装备固定绑定属性，该项装备绑定属性将会被重新刷新","警告",function okHandler():void{
											ForgeshopModule.getInstance().requestEquipUpdate(updateEquipVo);
										},function noHandler():void{
											currentBtn.enabled = true;
										});
									}else{
										ForgeshopModule.getInstance().requestEquipUpdate(updateEquipVo);
									}
								}
							}else if(arr[3] == true){
								//该装备只有五行需要保留
								if(updateEquipVo.five_ele_type_id == 0){
									Alert.show("不保留装备五行属性，该项装备五行属性将会丢失","警告",function okHandler():void{
										ForgeshopModule.getInstance().requestEquipUpdate(updateEquipVo);
									},function noHandler():void{
										currentBtn.enabled = true;
									});
								}else{
									ForgeshopModule.getInstance().requestEquipUpdate(updateEquipVo);
								}
							}
						}
						
					}else{
						currentBtn.enabled = true;
					}
					break;
				case 4://分解
					var destroyVo:m_equip_build_decompose_tos = equipResolveCanvas.equipDestroyInfo();
					if(destroyVo){
						ForgeshopModule.getInstance().requestEquipDestroy(destroyVo);
					}else{
						currentBtn.enabled = true;
					}
					break;
				case 5:	//五行
					var fiveVo: m_equip_build_fiveele_tos = subWuxinggCanvas.getEquipWuXingInfo();
					if(fiveVo){
						var fiveMaterial_arr:Array = PackManager.getInstance().getGoodsByType(fiveVo.good_type_id);
						var five_bool:Boolean = false;
						for(var f:int=0;f<fiveMaterial_arr.length;f++){
							if(fiveVo.good_type_id == 23200001){
								if(StoneVO(fiveMaterial_arr[f]).bind){
									five_bool = true;
									break;
								}
							}else{
								if(GeneralVO(fiveMaterial_arr[f]).bind){
									five_bool = true;
									break;
								}
							}
						}
						if(five_bool && !EquipVO(supLeftCanvas.equipItem.data).bind){
							Alert.show("由于您使用的材料是“绑定”的，本操作将会绑定装备，是否继续？","提示",function okHandler():void{
								ForgeshopModule.getInstance().requestWuXingChange(fiveVo);
							},function noHandler():void{
								subWuxinggCanvas.checkBoxState(true);
								currentBtn.enabled = true;
							});
						}else{
							ForgeshopModule.getInstance().requestWuXingChange(fiveVo);
						}
					}else{
						currentBtn.enabled = true;
					}
					break;
			}
			
			
		}
		
		/**服务器返回响应
		 * 
		 * @param data
		 * 
		 */		
		public function responseResult(data:Object,serviceMethod:String):void{
			switch(tabNavigation.selectedIndex){
				case 0:	//打造
					if(SocketCommand.EQUIP_BUILD_LIST == serviceMethod){       //打造装备列表
						equipCreateCanvas.setBuildEquipList(data,money_txt);
					}else  if(SocketCommand.EQUIP_BUILD_GOODS == serviceMethod){  //拥有的材料列表						  
						var currentMaterial :m_equip_build_goods_toc = data as m_equip_build_goods_toc;	
						if(currentMaterial != null){
							equipCreateCanvas.setCurrentMaterialList(currentMaterial.base_list,currentMaterial.add_list);
						}
						
					}else if(SocketCommand.EQUIP_BUILD_BUILD == serviceMethod){//打造
						var build :m_equip_build_build_toc = data as m_equip_build_build_toc;	
						currentBtn.enabled = true;
						if(build.succ){
							Tips.getInstance().addTipsMsg("打造"+ build.new_equip.name +"成功！");
							equipCreateCanvas.cleanEquipCreateMaterial();
							equipCreateCanvas.setCurrentMaterialList(build.base_list,build.add_list);							
							
						}else{
							Tips.getInstance().addTipsMsg(build.reason);
						}
						
					}
					
					break;
				case 1:	//品质	
					if(SocketCommand.EQUIP_BUILD_QUALITY_GOODS == serviceMethod){
						var material:m_equip_build_quality_goods_toc = data as m_equip_build_quality_goods_toc;
						if(material && supLeftCanvas.equipItem.data){
							subPingzhiCanvas.setListData(material.add_list,supLeftCanvas.equipItem.data as EquipVO,money_txt);
						}
					}else if(SocketCommand.EQUIP_BUILD_QUALITY == serviceMethod){
						var equipChangeVo:m_equip_build_quality_toc = data as m_equip_build_quality_toc;
						currentBtn.enabled = true;
						if(equipChangeVo.succ){
							var q:int = EquipVO(supLeftCanvas.equipItem.data).quality_rate;
							if(q == equipChangeVo.equip.quality_rate){//品质不变
								Tips.getInstance().addTipsMsg("装备"+equipChangeVo.equip.name+"品质改造失败，品质加成保持不变！");
							}else if(q >= equipChangeVo.equip.quality_rate){//品质降低
								Tips.getInstance().addTipsMsg("装备"+equipChangeVo.equip.name+"品质改造失败，品质加成降为" + String(equipChangeVo.equip.quality_rate) + "%。");
							}else if(q < equipChangeVo.equip.quality_rate){//品质升高
								Tips.getInstance().addTipsMsg("装备"+equipChangeVo.equip.name+"品质改造成功，品质加成为" + String(equipChangeVo.equip.quality_rate) + "%！");
							}
							supLeftCanvas.equipItem.disposeContent();
							supLeftCanvas.equipItem.data = ItemConstant.wrapperItemVO(equipChangeVo.equip) as EquipVO;
							subPingzhiCanvas.setListData(equipChangeVo.add_list,supLeftCanvas.equipItem.data as EquipVO,money_txt);
						}else{
							Tips.getInstance().addTipsMsg(equipChangeVo.reason);
							subPingzhiCanvas.checkBoxState(true);
						}
					}
					break;
				
				case 2:	//签名
					if(SocketCommand.EQUIP_BUILD_SIGNATURE == serviceMethod){
						var changeNameVo:m_equip_build_signature_toc = data as m_equip_build_signature_toc;
						currentBtn.enabled = true;
						if(changeNameVo.succ){
							Tips.getInstance().addTipsMsg("装备更改签名成功！");
							supLeftCanvas.equipItem.disposeContent();
							supLeftCanvas.equipItem.data = ItemConstant.wrapperItemVO(changeNameVo.equip) as EquipVO;
							subJianmingCanvas.setData(supLeftCanvas.equipItem.data as EquipVO,money_txt);
						}else{
							Tips.getInstance().addTipsMsg(changeNameVo.reason);
						}
					}
					break;
				case 3://升级
					if(SocketCommand.EQUIP_BUILD_UPGRADE_GOODS == serviceMethod){
						var updataMaterialVo:m_equip_build_upgrade_goods_toc = data as m_equip_build_upgrade_goods_toc;
						if(updataMaterialVo.succ){
							equipUpgradeCanvas.setData(supLeftCanvas.equipItem.data as EquipVO,updataMaterialVo.base_list,updataMaterialVo.add_list,updataMaterialVo.reinforce,updataMaterialVo.quality_list);
							ForgeshopModule.getInstance().requestNextLvlEquip(EquipVO(supLeftCanvas.equipItem.data).oid,false,false,false,false);
						}
					}
					if(SocketCommand.EQUIP_BUILD_UPGRADE_LINK == serviceMethod){
						var nextEquipVo:m_equip_build_upgrade_link_toc = data as m_equip_build_upgrade_link_toc;
						if(nextEquipVo.succ){
							equipUpgradeCanvas.updateItem.disposeContent();
							equipUpgradeCanvas.setNewEquipData(ItemConstant.wrapperItemVO(nextEquipVo.new_equip) as EquipVO,money_txt);
						}else{
							Tips.getInstance().addTipsMsg(nextEquipVo.reason);
							equipUpgradeCanvas.heigthestLvl();
						}
					}
					if(SocketCommand.EQUIP_BUILD_UPGRADE == serviceMethod){
						var equipVo:m_equip_build_upgrade_toc = data as m_equip_build_upgrade_toc;
						currentBtn.enabled = true;
						if(equipVo.succ){
							Tips.getInstance().addTipsMsg("装备升级成功,请到背包查看新的装备！");
							supLeftCanvas.equipItem.disposeContent();
							equipUpgradeCanvas.updateItem.disposeContent();
							equipUpgradeCanvas.cleanAttach();
							equipUpgradeCanvas.cleanMaterial();
						}else{
							Tips.getInstance().addTipsMsg(equipVo.reason);
						}
					}
					break;
				case 4://分解
					var equipRemoveVo:m_equip_build_decompose_toc = data as m_equip_build_decompose_toc;
					currentBtn.enabled = true;
					if(equipRemoveVo.succ){
						Tips.getInstance().addTipsMsg(equipRemoveVo.reason)//"装备分解成功！";
						supLeftCanvas.equipItem.disposeContent();
						equipResolveCanvas.cleanRemoveData();
						//基础材料的名称和数量
						var baseName:String = equipRemoveVo.base_goods.name;
						var baseNum:int = equipRemoveVo.base_goods.current_num;
						//附加材料的名称和数量
						var attachName:String = equipRemoveVo.add_goods.name;
						var attachNum:int = equipRemoveVo.add_goods.current_num;
						if(equipRemoveVo.base_goods && equipRemoveVo.add_goods){
							if(baseNum != 0 && attachNum != 0){
								BroadcastSelf.logger("装备分解获得：\n<font color='#00ff00'>"+baseName+"   ×"+baseNum+"\n"+attachName+"   ×"+attachNum+"</font>");
							}if(baseNum == 0 && attachNum != 0){
								BroadcastSelf.logger("装备分解获得：\n<font color='#00ff00'>"+attachName+"   ×"+attachNum+"</font>");
							}if(baseNum != 0 && attachNum == 0){
								BroadcastSelf.logger("装备分解获得：\n<font color='#00ff00'>"+baseName+"   ×"+baseNum+"</font>");
							}if(baseNum == 0 && attachNum == 0){
								BroadcastSelf.logger("<font color='#00ff00'>你没有获得任何分解材料</font>");
							}
						}
					}else{
						Tips.getInstance().addTipsMsg(equipRemoveVo.reason);
					}
					break;
				case 5:	//五行
					if(SocketCommand.EQUIP_BUILD_FIVEELE_GOODS == serviceMethod){
						var fiveGoodsVo:m_equip_build_fiveele_goods_toc = data as m_equip_build_fiveele_goods_toc;
						if(fiveGoodsVo.succ){
							subWuxinggCanvas.setData(EquipVO(supLeftCanvas.equipItem.data),fiveGoodsVo.add_list,fiveGoodsVo.five_good,money_txt);
						}else{
							Tips.getInstance().addTipsMsg(fiveGoodsVo.reason);
						}
					}else if(SocketCommand.EQUIP_BUILD_FIVEELE == serviceMethod){
						var fiveVo:m_equip_build_fiveele_toc = data as m_equip_build_fiveele_toc;
						currentBtn.enabled = true;
						if(fiveVo.succ){
							Tips.getInstance().addTipsMsg("装备五行改造成功");
							supLeftCanvas.equipItem.disposeContent();
							subWuxinggCanvas.cleanData();
							supLeftCanvas.equipItem.data = ItemConstant.wrapperItemVO(fiveVo.equip) as EquipVO;
							if(supLeftCanvas.equipItem.data){
								ForgeshopModule.getInstance().requestWuXingMaterial(0);
							}
						}else{
							Tips.getInstance().addTipsMsg(fiveVo.reason);
						}
					}
					
					break;
			}
			
		}
	}
}