package modules.forgeshop.views
{
	import com.common.Constant;
	import com.common.GlobalObjectManager;
	import com.globals.GameConfig;
	import com.ming.ui.controls.core.UIComponent;
	import com.utils.ComponentUtil;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import modules.broadcast.views.Tips;
	import modules.deal.DealConstant;
	import modules.forgeshop.ForgeshopModule;
	import modules.mypackage.vo.EquipVO;
	
	import proto.line.m_equip_build_signature_tos;
	
	public class SubJianmingCanvas extends UIComponent
	{
		public function SubJianmingCanvas()
		{
			super();
			init();
		}
		private var signatureTextField:TextField;
		private function init():void{
			var curr_equip_sign_txt:TextField = ComponentUtil.createTextField("当前装备签名：",8,3,Constant.TEXTFORMAT_COLOR_GRAYYELLOW,100,30,this);
			signatureTextField = ComponentUtil.createTextField("",curr_equip_sign_txt.x + curr_equip_sign_txt.textWidth,curr_equip_sign_txt.y,new TextFormat("Tahoma",12,0xffcc00),130,30,this);
			signatureTextField.defaultTextFormat = new TextFormat("Tahoma",12,0xffcc00);
			//线条
			var lineSprite:Bitmap = Style.getBitmap(GameConfig.T1_VIEWUI,"hightLightLine");
			this.addChild(lineSprite);
			lineSprite.x = curr_equip_sign_txt.x - 1;
			lineSprite.y = curr_equip_sign_txt.y + curr_equip_sign_txt.textHeight + 10;
			lineSprite.width = 260;
			
			var textExplain:TextField = ComponentUtil.createTextField("\t同一套装中，所有组件都必须是同样签名才能激活套装属性。",lineSprite.x,lineSprite.y + 10,new TextFormat("Tahoma",12,0xffcc00),260,50,this);
			textExplain.wordWrap = true;
			textExplain.visible = false;
		}
		
		private var equipLvl:int;//费用 ==装备的等级
		private var euquipId:int = -1;
		private var sign_role_id:int;//已经签名的角色名
		public function setData(equipVo:EquipVO,costText:TextField):void{
			equipLvl = equipVo.equipLvl;
			euquipId = equipVo.oid;
			sign_role_id = equipVo.sign_role_id;
			signatureTextField.text = equipVo.signature;
			
			if(ForgeshopModule.getInstance().isHasData()){
				costText.text = DealConstant.silverToOtherString(equipLvl*50);
			}else{
				costText.text = DealConstant.silverToOtherString(0);
			}
		}
		
		/**
		 *向服务端提交请求数据 
		 */		
		public function equipChangeNameInfo():m_equip_build_signature_tos{
			var changeNameVo:m_equip_build_signature_tos = new m_equip_build_signature_tos();
			if(!ForgeshopModule.getInstance().isHasData()){
				Tips.getInstance().addTipsMsg("请在装备框里放上你要更改签名的装备");
//				Alert.show("请在装备框里放上你要更改签名的装备","提示",null,null,"确定","取消",null,false);
				return changeNameVo = null;
			}
			if(sign_role_id == GlobalObjectManager.getInstance().user.base.role_id){
				Tips.getInstance().addTipsMsg("该装备已经签名");
				changeNameVo = null;
			}else if(euquipId == -1){
				changeNameVo = null;
			}else{
				changeNameVo.equip_id = euquipId;
			}
			return changeNameVo;
		}
		
		/**
		 *清除数据 
		 * 
		 */		
		public function cleanSignNameData():void{
			signatureTextField.text = "";
		}
	}
}