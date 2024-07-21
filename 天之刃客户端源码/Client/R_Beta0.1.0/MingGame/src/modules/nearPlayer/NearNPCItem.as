package modules.nearPlayer
{
	import com.ming.core.IDataRenderer;
	import com.scene.sceneData.NPCVo;
	import com.utils.ComponentUtil;
	
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;

	public class NearNPCItem extends Sprite implements IDataRenderer
	{
		private var npc_name:TextField;
		private var guanzhi:TextField;
		private var pvo:NPCVo;

		public function NearNPCItem()
		{
			super();
			var tf:TextFormat=Style.textFormat;
			tf.align = "center";
			npc_name=ComponentUtil.createTextField("", 0, 2, tf, 150, 22, this);
			guanzhi=ComponentUtil.createTextField("", 151, 2, tf, 168, 22, this);
		}

		public function set data(obj:Object):void
		{
			if(obj){
				var vo:NPCVo=NPCVo(obj);
				npc_name.text=vo.name;
				guanzhi.text=vo.job;
				pvo=vo;
			}else{
				pvo=null;
			}
		}

		public function get data():Object
		{
			return pvo;
		}
	}
}