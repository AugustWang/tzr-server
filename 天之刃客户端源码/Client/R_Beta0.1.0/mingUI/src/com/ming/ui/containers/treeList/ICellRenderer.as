package com.ming.ui.containers.treeList
{
	public interface ICellRenderer
	{
		function setSize(w:Number, h:Number) : void;
	
		function get data() : Object;
		
		function set data(param1:Object) : void;
		
		function set selected(value:Boolean) : void;
		
		function get selected() : Boolean;
	}
}