package modules.pet.view
{
	import com.common.dragManager.DragConstant;
	import com.common.dragManager.IDragItem;
	import com.globals.GameConfig;
	import com.ming.ui.controls.Image;
	import com.ming.ui.style.StyleManager;
	import com.utils.ComponentUtil;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import modules.mypackage.managers.PackManager;
	import modules.mypackage.vo.GeneralVO;
	import modules.skill.vo.SkillVO;
	
	public class PetSkillItem extends Sprite implements IDragItem
	{
		public static const SKILL_EVENT:String="SKILL_EVENT";
		
		public function PetSkillItem()
		{
			super();
			addChild(Style.getBitmap(GameConfig.T1_VIEWUI,"borderItemBg")); //packItemBg
			this.mouseChildren=false;
		}
		
		private var _data:Object;
		private var img:Image;
		private var numTxt:TextField;
		
		private function createContent():void
		{
			if (img == null)
			{
				img=new Image();
				img.x=img.y=15;
				addChild(img);
			}
			img.source=data.path;
			if (numTxt == null)
			{
				var tf:TextFormat=StyleManager.textFormat;
				tf.size=11;
				numTxt=ComponentUtil.createTextField("", 0, 33, tf, 46, NaN, this);
				numTxt.filters=[new GlowFilter(0x000000)];
				numTxt.selectable=false;
				numTxt.autoSize="right";
			}
			updateNum();
		}
		
		public function allowAccept(itemVO:Object, name:String):Boolean
		{
			if (name == DragConstant.PACKAGE_ITEM)
			{
				return true;
			}
			if (itemVO is SkillVO)
			{
				return true;
			}
			return false;
		}
		
		public function set data(value:Object):void
		{
			this._data=value;
			if (value)
			{
				createContent();
			}
			else
			{
				if (img && contains(img))
				{
					removeChild(img);
					img=null;
				}
				if (numTxt && contains(numTxt))
				{
					removeChild(numTxt);
					numTxt=null;
				}
			}
			this.dispatchEvent(new Event(SKILL_EVENT));
		}
		
		public function get data():Object
		{
			return this._data;
		}
		
		public function updateNum():void
		{
			if (data != null)
			{
				var num:int=PackManager.getInstance().getGoodsNumByTypeId(GeneralVO(data).typeId);
				if (num > 0)
				{
					numTxt.text=num + "";
				}
				else
				{
					data=null;
				}
			}
		}
		
		/**
		 * 设置内容
		 */
		public function setContent(_content:*, _data:*):void
		{
			img=_content;
			this._data=_data;
			addChild(_content);
		}
		
		/**
		 * 获取项目内容
		 */
		public function getContent():*
		{
			return img;
		}
		
		/**
		 * 销毁项目内容( 例如：容器里面的装备图片)
		 */
		public function disposeContent():void
		{
			//GlobalObjectManager.instance.skills.splice(GlobalObjectManager.instance.skills.indexOf(_data));
			if (img && contains(img))
			{
				removeChild(img);
			}
			img=null;
			_data=null;
		}
		
		public function dragDrop(dragData:Object, dragTarget:DisplayObject, itemName:String):void
		{
			data=dragData;
		}
	}
}