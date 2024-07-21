package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_role2_newbuffs_toc extends Message
	{
		public var roleid:int = 0;
		public var type:int = 0;
		public var remain_time:int = 0;
		public var value:int = 0;
		public function m_role2_newbuffs_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_role2_newbuffs_toc", m_role2_newbuffs_toc);
		}
		public override function getMethodName():String {
			return 'role2_newbuffs';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.roleid);
			output.writeInt(this.type);
			output.writeInt(this.remain_time);
			output.writeInt(this.value);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.roleid = input.readInt();
			this.type = input.readInt();
			this.remain_time = input.readInt();
			this.value = input.readInt();
		}
	}
}
