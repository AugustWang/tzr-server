package proto.common {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_actor_buf extends Message
	{
		public var buff_id:int = 0;
		public var remain_time:int = 0;
		public var actor_id:int = 0;
		public var actor_type:int = 0;
		public var from_actor_id:int = 0;
		public var from_actor_type:int = 0;
		public var start_time:int = 0;
		public var end_time:int = 0;
		public var buff_type:int = 0;
		public var value:int = 0;
		public function p_actor_buf() {
			super();

			flash.net.registerClassAlias("copy.proto.common.p_actor_buf", p_actor_buf);
		}
		public override function getMethodName():String {
			return 'actor';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.buff_id);
			output.writeInt(this.remain_time);
			output.writeInt(this.actor_id);
			output.writeInt(this.actor_type);
			output.writeInt(this.from_actor_id);
			output.writeInt(this.from_actor_type);
			output.writeInt(this.start_time);
			output.writeInt(this.end_time);
			output.writeInt(this.buff_type);
			output.writeInt(this.value);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.buff_id = input.readInt();
			this.remain_time = input.readInt();
			this.actor_id = input.readInt();
			this.actor_type = input.readInt();
			this.from_actor_id = input.readInt();
			this.from_actor_type = input.readInt();
			this.start_time = input.readInt();
			this.end_time = input.readInt();
			this.buff_type = input.readInt();
			this.value = input.readInt();
		}
	}
}
