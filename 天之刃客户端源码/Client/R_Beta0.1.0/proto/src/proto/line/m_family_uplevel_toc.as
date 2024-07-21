package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_family_uplevel_toc extends Message
	{
		public var succ:Boolean = true;
		public var reason:String = "";
		public var return_self:Boolean = true;
		public var new_level:int = 0;
		public var money:int = 0;
		public var active_points:int = 0;
		public function m_family_uplevel_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_family_uplevel_toc", m_family_uplevel_toc);
		}
		public override function getMethodName():String {
			return 'family_uplevel';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			output.writeBoolean(this.return_self);
			output.writeInt(this.new_level);
			output.writeInt(this.money);
			output.writeInt(this.active_points);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.reason = input.readUTF();
			this.return_self = input.readBoolean();
			this.new_level = input.readInt();
			this.money = input.readInt();
			this.active_points = input.readInt();
		}
	}
}
