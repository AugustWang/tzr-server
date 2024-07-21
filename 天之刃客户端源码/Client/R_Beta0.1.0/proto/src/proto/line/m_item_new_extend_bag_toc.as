package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_item_new_extend_bag_toc extends Message
	{
		public var bagid:int = 0;
		public var rows:int = 0;
		public var columns:int = 0;
		public var typeid:int = 0;
		public var grid_number:int = 0;
		public var main_rows:int = 0;
		public var main_columns:int = 0;
		public var main_grid_number:int = 0;
		public function m_item_new_extend_bag_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_item_new_extend_bag_toc", m_item_new_extend_bag_toc);
		}
		public override function getMethodName():String {
			return 'item_new_extend_bag';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.bagid);
			output.writeInt(this.rows);
			output.writeInt(this.columns);
			output.writeInt(this.typeid);
			output.writeInt(this.grid_number);
			output.writeInt(this.main_rows);
			output.writeInt(this.main_columns);
			output.writeInt(this.main_grid_number);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.bagid = input.readInt();
			this.rows = input.readInt();
			this.columns = input.readInt();
			this.typeid = input.readInt();
			this.grid_number = input.readInt();
			this.main_rows = input.readInt();
			this.main_columns = input.readInt();
			this.main_grid_number = input.readInt();
		}
	}
}
