package com.components
{
	public class DataGridColumn
	{
		public var headerText:String; //头部标题
		public var label:String; //改列的字段域名称
		public var width:Number = 0; //宽度
		public var sortable:Boolean; //是否可以排序
		public var sortOptions:*; //排序参数
		public var sortCompareFunc:Function; //自定义排序函数
		public function DataGridColumn(labelName:String,width:Number)
		{
			this.label = labelName;
			this.width = width;
		}
	}
}