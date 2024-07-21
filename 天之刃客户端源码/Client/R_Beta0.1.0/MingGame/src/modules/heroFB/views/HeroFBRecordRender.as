package modules.heroFB.views
{
	import com.common.GameConstant;
	import com.ming.core.IDataRenderer;
	import com.utils.ComponentUtil;
	
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import flashx.textLayout.formats.TextAlign;
	
	import modules.heroFB.HeroFBModule;
	
	import proto.common.p_hero_fb_record;
	
	public class HeroFBRecordRender extends Sprite implements IDataRenderer
	{
		private var _data:p_hero_fb_record;
		private var _name:TextField;
		private var _faction:TextField;
		private var _time:TextField;
		
		public function HeroFBRecordRender()
		{
			super();
			initView();
		}
		
		private function initView():void
		{
			var tf:TextFormat = new TextFormat;
			tf.align = TextAlign.CENTER;
			tf.color = "0xf7f7ce";
				
			_name = ComponentUtil.createTextField("", 0, 3, tf, 125, 25, this);
			_faction = ComponentUtil.createTextField("", 125, 3, tf, 100, 25, this);
			_time = ComponentUtil.createTextField("", 225, 3, tf, 125, 25, this);
		}
		
		public function get data():Object
		{
			return _data;
		}
		
		public function set data(value:Object):void
		{
			_data = value as p_hero_fb_record;
			
			_name.text = _data.role_name;
			_faction.text = GameConstant.getNation(_data.faction_id);
			_time.text = HeroFBModule.getInstance().formatTime(_data.time_used);
		}
	}
}