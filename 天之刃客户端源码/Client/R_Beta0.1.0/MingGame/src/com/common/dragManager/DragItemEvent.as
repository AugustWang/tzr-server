package  com.common.dragManager
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	
	public class DragItemEvent extends Event
	{
		/**
		 * 当TimerHandler到达事件基点之后将会触发改事件，开始拖拽(由DragItemManager分发) 
		 */		
		public static const START_DRAG:String = "startDrag"; 
		/**
		 * 当目标对象，已经被结束拖拽时触发，触发方式(由DragItemManager分发) 
		 * 1，当目标到达IDragItem的接口实现对象上，
		 * 2，当目标到达UILayer上
		 * 3，手动stop
		 */ 
		public static const STOP_DRAG:String = "stopDrag"; 
		/**
		 * 当目标对象接触UILayer时，并导致dragSource分发该事件
		 */ 
		public static const DRAG_THREW:String = "dragThrew"; 
		/**
		 * 当拖拽将要完成时会触发这个事件，如果是粘附拖拽，那么就会每次单击都会造成prepareDrop
		 * 如果时直接拖拽，那么每次鼠标UP事件都会导致此事件，这个事件只是代表将要完成，并不是表示将会一定完成拖拽操作。
		 * 此事件由dragSource分发，所以dragSource监听到此事件时，可以手动停止拖拽操作
		 */ 		
		public static const DRAG_DROP:String = "dragDrop"; 
		/**
		 *   当目标对象，接触到目的地时，却发现到达的目的地不符合任何条件，将会触发改事件
		 *   例如，我们装备要装备在人物身上，当是用户是单击在人物的窗口上，所以目的地不符合以下两个条件
		 *   1，实现IDragItem接口，2是UILayer,所以不会导致dragDrop事件的发生，但是我们想将装备智能的装备在人物身上，所以
		 *   监听此事件，你将可以做到任何操作。
		 */ 		
		public static const DRAG_ENTER:String = "dragEnter";
		/**
		 *  同上dragEnter的理解一样不过此事件时由DragSource感知,就是告诉DragSource当前的拖拽操作没有找到任何符合
		 *  （1，实现IDragItem接口，2是UILayer）的目标， 
		 */		
		public static const NOT_FIND_TARGET:String = "notFindTarget";
		
		public var dragData:Object;
		public var dragTarget:DisplayObject;
		public var itemName:String;
		public var toTarget:DisplayObject;
		public function DragItemEvent(type:String,dragData:Object,dragTarget:DisplayObject,itemName:String,bubbles:Boolean=false,cancelable:Boolean=false)
		{
			this.dragData = dragData;
			this.dragTarget = dragTarget;
			this.itemName = itemName;
			super(type,bubbles,cancelable);
		}
	}
}