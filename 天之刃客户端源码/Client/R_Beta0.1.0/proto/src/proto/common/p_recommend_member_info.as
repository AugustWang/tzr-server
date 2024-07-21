package proto.common {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_recommend_member_info extends Message
	{
		public var role_id:int = 0;
		public var role_name:String = "";
		public var level:int = 0;
		public var sex:int = 0;
		public var category:int = 0;
		public function p_recommend_member_info() {
			super();

			flash.net.registerClassAlias("copy.proto.common.p_recommend_member_info", p_recommend_member_info);
		}
		public override function getMethodName():String {
			return 'recommend_member_';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.role_id);
			if (this.role_name != null) {				output.writeUTF(this.role_name.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.level);
			output.writeInt(this.sex);
			output.writeInt(this.category);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.role_id = input.readInt();
			this.role_name = input.readUTF();
			this.level = input.readInt();
			this.sex = input.readInt();
			this.category = input.readInt();
		}
	}
}
