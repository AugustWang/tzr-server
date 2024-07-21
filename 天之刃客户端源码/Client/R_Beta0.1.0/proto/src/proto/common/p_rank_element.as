package proto.common {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_rank_element extends Message
	{
		public var element_name:int = 0;
		public var element_index:int = 0;
		public var element_color:int = 0;
		public function p_rank_element() {
			super();

			flash.net.registerClassAlias("copy.proto.common.p_rank_element", p_rank_element);
		}
		public override function getMethodName():String {
			return 'rank_ele';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.element_name);
			output.writeInt(this.element_index);
			output.writeInt(this.element_color);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.element_name = input.readInt();
			this.element_index = input.readInt();
			this.element_color = input.readInt();
		}
	}
}
