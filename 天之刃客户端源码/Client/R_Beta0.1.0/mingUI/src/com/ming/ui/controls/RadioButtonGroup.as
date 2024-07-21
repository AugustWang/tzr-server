package com.ming.ui.controls
{
	import com.ming.ui.controls.core.UIComponent;
	
	import flash.events.Event;
	
	public class RadioButtonGroup extends UIComponent
	{
		public static var SELECTED_CHANGE:String = "selected change";
		
		public static var VERTICAL:String = "vertical";
		public static var HORIZONTAL:String = "horizontal"; 
		private var defaultItemWidth:Number = 80;
		private var defaultItemHeight:Number = 25;
		
		private var items:Array;
		private var _selectedItem:RadioButton;
		private var _selectedIndex:int;
		private var _space:Number = 5;
		private var _direction:String = HORIZONTAL;
		
		private var sizeChange:Boolean = false;
		public function RadioButtonGroup()
		{
			super();
			
			init();
		}
		
		private function init():void
		{
			items = new Array();
		}
		
		public function get selectedItem():RadioButton
		{
			return items[_selectedIndex];
		}
		public function set selectedItem(value:RadioButton):void
		{
			if(value == null || value.parent != this)
				return;
			
			clear(value);
		}
		
		public function get selectedIndex():int
		{
			return this._selectedIndex;
		}
		public function set selectedIndex(value:int):void
		{
			if(items.length <= value || value < 0)
				return;
			
			selectedItem = getByIndex(value);
			
		}
		
		public function addItem(item:RadioButton):void
		{
			if(item.parent == this)
				return;
			
			addChild(item);
			items.push(item);
			item.addEventListener(RadioButton.SELECTED, onChange);
			sizeChange = true;
			
			invalidateDisplayList();
		}
		
		private function onChange(evt:Event):void
		{
			var target:RadioButton = evt.target as RadioButton;
			
			if(target != null)
				clear(target);
			
			this.dispatchEvent(new Event(SELECTED_CHANGE));
		}
		
		public function set space(value:Number):void
		{
			if(_space == value)
				return;
			
			_space = value;
			sizeChange = true;
			invalidateDisplayList();
		}
		public function get space():Number
		{
			return this._space;
		}
		
		public function set direction(value:String):void
		{
			if(value != HORIZONTAL && value != VERTICAL)
				return;
			if(_direction == value)
				return;
			
			_direction = value;
			sizeChange = true;
			invalidateDisplayList();
		}
		
		public function get direction():String
		{
			return this._direction;
		}
		
		override public function set width(value:Number):void
		{
			if(super.width == value)
				return;
			
			super.width = value;
			sizeChange = true;
		}
		
		override public function set height(value:Number):void
		{
			if(super.height == value)
				return;
			
			super.height = value;
			sizeChange = true;
		}
		
		public function getByIndex(index:int):RadioButton
		{
			if(items.length <= index || index < 0)
				return null;
			
			return items[index] as RadioButton;
		}
		public function getRadioButtonNum():int
		{
			return items.length;
		}
		
		private function clear(rb:RadioButton):void
		{
			for each(var button:RadioButton in items)
			{
				if(button != rb)
					button.selected = false;
			}
			
			_selectedIndex = items.indexOf(rb);
			rb.selected = true;
		}
		
		override protected function updateDisplayList(w:Number, h:Number):void
		{
			super.updateDisplayList(w, h);
			
			checkSize();
		}
		
		private function checkSize():void
		{
			if(sizeChange)
			{
				var num:int = getRadioButtonNum();
				if(num > 0)
				{
					if(_direction == HORIZONTAL)
					{
						this.width = this.width == 0 ? getDefaultWidth(): this.width;
						this.height = this.height == 0 ? this.defaultItemHeight : this.height;
					}
					else
					{
						this.width = this.width == 0 ? this.defaultItemWidth : this.width;
						this.height = this.height == 0 ? getDefaultHeight() : this.height;
					}
					layout();
				}
			}
		}
		
		private function layout():void
		{
			var num:int = getRadioButtonNum();
			var itemWidth:Number = (this.width - (num - 1) * space) / num;
			var itemHeight:Number = (this.height - (num - 1) * space) / num;
			for(var i:int = 0; i < items.length ; i++)
			{
				var item:RadioButton = items[i] as RadioButton;
				if(_direction == HORIZONTAL)
				{
					item.x = (itemWidth + space) * i;
					item.height = this.height;
					item.y = 0;
				}
				else
				{
					item.y = (itemHeight + space) * i;
					item.x = 0;
					item.width = this.width;
				}
			}
		}
		
		private function getDefaultWidth():Number
		{
			return defaultItemWidth * getRadioButtonNum() + space * (getRadioButtonNum() - 1);
		}
		private function getDefaultHeight():Number
		{
			return defaultItemHeight * getRadioButtonNum() + space * (getRadioButtonNum() - 1);
		}
	}
}