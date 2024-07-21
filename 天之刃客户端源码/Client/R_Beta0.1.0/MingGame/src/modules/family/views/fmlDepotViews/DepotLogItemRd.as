package modules.family.views.fmlDepotViews {
	import com.ming.ui.controls.core.UIComponent;
	import com.utils.ComponentUtil;
	import com.utils.DateFormatUtil;

	import flash.text.TextField;

	import modules.family.FamilyDepotModule;
	import modules.mypackage.ItemConstant;
	import modules.mypackage.managers.ItemLocator;
	import modules.mypackage.vo.BaseItemVO;

	import proto.common.p_fmldepot_log;

	public class DepotLogItemRd extends UIComponent {
		private var descTxt:TextField;

		public function DepotLogItemRd() {
			super();
			this.width = 405;
			this.height = 25;
			initView();

		}

		private function initView():void {

		}

		override public function set data( value:Object ):void {
			if ( !value ) {
//				descTxt.htmlText = "";
				return;
			}
			if ( descTxt ) {
				descTxt.htmlText = "";
				this.removeChild( descTxt );
				descTxt = null;
			}

			descTxt = ComponentUtil.createTextField( "", 6, 3, Style.textFormat, 438, 22, this );
			descTxt.selectable = descTxt.mouseEnabled = true;


			var lg:p_fmldepot_log = value as p_fmldepot_log;
			//			lg.log_time

			var str:String = DateFormatUtil.format( lg.log_time ); //DateFormatUtil.formatPassDate(lg.log_time);
			descTxt.htmlText = "<font color='#F6F5CD' size='12'>" + str + "</font>      "; //6

			//			[一朵梨花压海棠]贡献了【精良的疾风刀】*1。

			createDesc( lg.role_name, lg.item_type_id, lg.item_num, lg.item_color );

		}

		private function createDesc( roleName:String, typeId:int, num:int, item_color:int ):void {
			var obj:BaseItemVO = ItemLocator.getInstance().getObject( typeId );
			if ( !obj )
				return;
			var typeStr:String = "";
			if ( FamilyDepotModule.getInstance().logType == 1 ) {
				typeStr = "贡献了";
			} else {
				typeStr = "取出了";
			}
			descTxt.htmlText += "<font color='#F6F5CD' size='12'>" + "<font color ='#ffff00'>[" + roleName + "]</font>" +
				typeStr + "<font color ='" + ItemConstant.COLOR_VALUES[ item_color ] + "'> 【" + obj.name + "】</font>×" +
				num + "</font>";

		}
	}
}