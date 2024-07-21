package modules.mount.views
{
	import com.events.ParamEvent;
	import com.ming.core.IDataRenderer;
	import com.ming.ui.controls.CheckBox;
	import com.utils.ComponentUtil;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import proto.common.p_equip_mount_renewal;

	/**
	 * 坐骑续期子项
	 * @author caochuncheng
	 * 
	 */	
	public class MountRenewalItem extends Sprite implements IDataRenderer{
		
		public var renewalCheckBox:CheckBox;
		private var descText:TextField;
		private var feeText:TextField;
		public function MountRenewalItem(){
			var centerTmf:TextFormat =Style.textFormat;
			centerTmf.align=TextFormatAlign.CENTER;
			renewalCheckBox=ComponentUtil.createCheckBox("", 1, 1, this);
			renewalCheckBox.selected = false;
			renewalCheckBox.addEventListener(Event.CHANGE, onSelectChanged);
			descText = ComponentUtil.createTextField("",50,1,centerTmf,120,22,this);
			feeText = ComponentUtil.createTextField("",170,1,centerTmf,110,22,this);
			
		}
		
		
		private var _data:Object;
		public function get data():Object{
			return null;
		}
		public function set data(value:Object):void{
			this._data = value;
			var vo:p_equip_mount_renewal = this._data.renewal_config as p_equip_mount_renewal;
			if(vo.renewal_type == 9){
				descText.htmlText = "<font color=\"#3be450\">永久</font>";
			}else{
				descText.htmlText = "<font color=\"#3be450\">" + vo.renewal_days.toString() + "</font>";
			}
			if(vo.renewal_fee > this._data.gold){
				renewalCheckBox.enable = false;
				feeText.htmlText = "<font color=\"#f53f3c\">" + vo.renewal_fee.toString() + "</font>";
			}else{
				renewalCheckBox.enable = true;
				feeText.htmlText = "<font color=\"#3be450\">" + vo.renewal_fee.toString() + "</font>";
			}
			renewalCheckBox.selected = this._data.selected;
		}
		/**
		 * 点击单选框事件 
		 * @param evt
		 * 
		 */		
		private function onSelectChanged(evt:Event):void{
			this._data.selected = this.renewalCheckBox.selected;
			dispatchEvent(new ParamEvent(MountRenewalPanel.MOUNT_RENEWAL_SELECT_EVENT,{data:this._data,renewalCheckBox:this.renewalCheckBox},true));
		}
	}
}