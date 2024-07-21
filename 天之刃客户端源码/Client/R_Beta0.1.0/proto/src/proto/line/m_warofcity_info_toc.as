package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_warofcity_info_toc extends Message
	{
		public var is_begin:Boolean = true;
		public var remain_begin_time:int = 0;
		public var remain_time:int = 0;
		public var map_id:int = 0;
		public function m_warofcity_info_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_warofcity_info_toc", m_warofcity_info_toc);
		}
		public override function getMethodName():String {
			return 'warofcity_info';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.is_begin);
			output.writeInt(this.remain_begin_time);
			output.writeInt(this.remain_time);
			output.writeInt(this.map_id);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.is_begin = input.readBoolean();
			this.remain_begin_time = input.readInt();
			this.remain_time = input.readInt();
			this.map_id = input.readInt();
		}
	}
}
