package proto.line {
	import proto.common.p_role_goal_item;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_goal_update_toc extends Message
	{
		public var goal_item:p_role_goal_item = null;
		public function m_goal_update_toc() {
			super();
			this.goal_item = new p_role_goal_item;

			flash.net.registerClassAlias("copy.proto.line.m_goal_update_toc", m_goal_update_toc);
		}
		public override function getMethodName():String {
			return 'goal_update';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			var tmp_goal_item:ByteArray = new ByteArray;
			this.goal_item.writeToDataOutput(tmp_goal_item);
			var size_tmp_goal_item:int = tmp_goal_item.length;
			output.writeInt(size_tmp_goal_item);
			output.writeBytes(tmp_goal_item);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			var byte_goal_item_size:int = input.readInt();
			if (byte_goal_item_size > 0) {				this.goal_item = new p_role_goal_item;
				var byte_goal_item:ByteArray = new ByteArray;
				input.readBytes(byte_goal_item, 0, byte_goal_item_size);
				this.goal_item.readFromDataOutput(byte_goal_item);
			}
		}
	}
}
