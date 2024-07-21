package proto.common {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_skill_item_consume extends Message
	{
		public var item_typeid:int = 0;
		public var number:int = 0;
		public function p_skill_item_consume() {
			super();

			flash.net.registerClassAlias("copy.proto.common.p_skill_item_consume", p_skill_item_consume);
		}
		public override function getMethodName():String {
			return 'skill_item_con';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.item_typeid);
			output.writeInt(this.number);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.item_typeid = input.readInt();
			this.number = input.readInt();
		}
	}
}
