package proto.common {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_family_collect_role_prize_info extends Message
	{
		public var role_id:int = 0;
		public var color:int = 1;
		public var base_exp:int = 0;
		public var total_score:int = 0;
		public function p_family_collect_role_prize_info() {
			super();

			flash.net.registerClassAlias("copy.proto.common.p_family_collect_role_prize_info", p_family_collect_role_prize_info);
		}
		public override function getMethodName():String {
			return 'family_collect_role_prize_';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.role_id);
			output.writeInt(this.color);
			output.writeInt(this.base_exp);
			output.writeInt(this.total_score);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.role_id = input.readInt();
			this.color = input.readInt();
			this.base_exp = input.readInt();
			this.total_score = input.readInt();
		}
	}
}
