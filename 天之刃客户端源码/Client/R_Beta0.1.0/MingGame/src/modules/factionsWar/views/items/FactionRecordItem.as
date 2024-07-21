package modules.factionsWar.views.items
{
	import com.ming.core.IDataRenderer;
	import com.ming.managers.ToolTipManager;
	import com.ming.ui.layout.LayoutUtil;
	import com.utils.ComponentUtil;
	import com.utils.DateFormatUtil;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import proto.common.p_waroffaction_record;
	
	public class FactionRecordItem extends Sprite implements IDataRenderer
	{
		private var theTime:TextField;
		private var theEvent:TextField;
		private var vo:p_waroffaction_record;
		
		public function FactionRecordItem()
		{
			super();
			var tf:TextFormat=Style.textFormat;
			tf.align="center";
			theTime=ComponentUtil.createTextField("", 0, 0, tf, 130, 22, this);
			theEvent=ComponentUtil.createTextField("", 0, 0, tf, 390, 22, this);
			theEvent.mouseEnabled=true;
			theEvent.addEventListener(MouseEvent.ROLL_OVER, showTip);
			theEvent.addEventListener(MouseEvent.ROLL_OUT, hideTip);
			LayoutUtil.layoutHorizontal(this);
		}
		
		private function showTip(e:MouseEvent):void
		{
			ToolTipManager.getInstance().show(vo.content);
		}
		
		private function hideTip(e:MouseEvent):void
		{
			ToolTipManager.getInstance().hide();
		}
		
		public function set data(value:Object):void
		{
			vo=value as p_waroffaction_record;
			theTime.text=DateFormatUtil.format(vo.tick);
			theEvent.htmlText=vo.content;
		}
		
		public function get data():Object
		{
			return vo;
		}
		
	}
}