package proto.common {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_buf extends Message
	{
		public var buff_id:int = 0;
		public var level:int = 0;
		public var absolute_or_rate:int = 0;
		public var value:int = 0;
		public var last_type:int = 0;
		public var last_value:int = 0;
		public var last_interval:int = 0;
		public var can_remove:Boolean = true;
		public var kind:int = 0;
		public var buff_type:int = 0;
		public var send_to_client:Boolean = false;
		public var is_debuff:Boolean = false;
		public function p_buf() {
			super();

			flash.net.registerClassAlias("copy.proto.common.p_buf", p_buf);
		}
		public override function getMethodName():String {
			return '';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.buff_id);
			output.writeInt(this.level);
			output.writeInt(this.absolute_or_rate);
			output.writeInt(this.value);
			output.writeInt(this.last_type);
			output.writeInt(this.last_value);
			output.writeInt(this.last_interval);
			output.writeBoolean(this.can_remove);
			output.writeInt(this.kind);
			output.writeInt(this.buff_type);
			output.writeBoolean(this.send_to_client);
			output.writeBoolean(this.is_debuff);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.buff_id = input.readInt();
			this.level = input.readInt();
			this.absolute_or_rate = input.readInt();
			this.value = input.readInt();
			this.last_type = input.readInt();
			this.last_value = input.readInt();
			this.last_interval = input.readInt();
			this.can_remove = input.readBoolean();
			this.kind = input.readInt();
			this.buff_type = input.readInt();
			this.send_to_client = input.readBoolean();
			this.is_debuff = input.readBoolean();
		}
	}
}
