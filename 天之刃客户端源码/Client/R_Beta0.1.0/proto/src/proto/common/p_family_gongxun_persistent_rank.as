package proto.common {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_family_gongxun_persistent_rank extends Message
	{
		public var key:int = 0;
		public var family_id:int = 0;
		public var total_gongxun:int = 0;
		public var ranking:int = 0;
		public var date:int = 0;
		public function p_family_gongxun_persistent_rank() {
			super();

			flash.net.registerClassAlias("copy.proto.common.p_family_gongxun_persistent_rank", p_family_gongxun_persistent_rank);
		}
		public override function getMethodName():String {
			return 'family_gongxun_persistent_';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.key);
			output.writeInt(this.family_id);
			output.writeInt(this.total_gongxun);
			output.writeInt(this.ranking);
			output.writeInt(this.date);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.key = input.readInt();
			this.family_id = input.readInt();
			this.total_gongxun = input.readInt();
			this.ranking = input.readInt();
			this.date = input.readInt();
		}
	}
}
