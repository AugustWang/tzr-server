package proto.common {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_conlogin_reward extends Message
	{
		public var id:int = 0;
		public var type:int = 0;
		public var type_id:int = 0;
		public var min_level:int = 0;
		public var max_level:int = 0;
		public var need_payed:Boolean = true;
		public var num:int = 0;
		public var silver:int = 0;
		public var gold:int = 0;
		public var bind:Boolean = true;
		public var need_vip_level:int = 0;
		public function p_conlogin_reward() {
			super();

			flash.net.registerClassAlias("copy.proto.common.p_conlogin_reward", p_conlogin_reward);
		}
		public override function getMethodName():String {
			return 'conlogin_re';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.id);
			output.writeInt(this.type);
			output.writeInt(this.type_id);
			output.writeInt(this.min_level);
			output.writeInt(this.max_level);
			output.writeBoolean(this.need_payed);
			output.writeInt(this.num);
			output.writeInt(this.silver);
			output.writeInt(this.gold);
			output.writeBoolean(this.bind);
			output.writeInt(this.need_vip_level);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.id = input.readInt();
			this.type = input.readInt();
			this.type_id = input.readInt();
			this.min_level = input.readInt();
			this.max_level = input.readInt();
			this.need_payed = input.readBoolean();
			this.num = input.readInt();
			this.silver = input.readInt();
			this.gold = input.readInt();
			this.bind = input.readBoolean();
			this.need_vip_level = input.readInt();
		}
	}
}
