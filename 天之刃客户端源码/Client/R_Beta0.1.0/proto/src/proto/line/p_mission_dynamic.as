package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_mission_dynamic extends Message
	{
		public var key:String = "";
		public var type:int = 0;
		public var id:int = 0;
		public var name:String = "";
		public var num:int = 0;
		public var need_num:int = 0;
		public function p_mission_dynamic() {
			super();

			flash.net.registerClassAlias("copy.proto.line.p_mission_dynamic", p_mission_dynamic);
		}
		public override function getMethodName():String {
			return 'mission_dyn';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			if (this.key != null) {				output.writeUTF(this.key.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.type);
			output.writeInt(this.id);
			if (this.name != null) {				output.writeUTF(this.name.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.num);
			output.writeInt(this.need_num);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.key = input.readUTF();
			this.type = input.readInt();
			this.id = input.readInt();
			this.name = input.readUTF();
			this.num = input.readInt();
			this.need_num = input.readInt();
		}
	}
}
