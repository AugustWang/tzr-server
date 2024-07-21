package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_personal_fb_info extends Message
	{
		public var fb_id:int = 0;
		public var fb_name:String = "";
		public var state:int = 0;
		public var best_time:int = 0;
		public var winner_id:int = 0;
		public var winner_name:String = "";
		public var winner_faction_id:int = 0;
		public var best_self:int = 0;
		public function p_personal_fb_info() {
			super();

			flash.net.registerClassAlias("copy.proto.line.p_personal_fb_info", p_personal_fb_info);
		}
		public override function getMethodName():String {
			return 'personal_fb_';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.fb_id);
			if (this.fb_name != null) {				output.writeUTF(this.fb_name.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.state);
			output.writeInt(this.best_time);
			output.writeInt(this.winner_id);
			if (this.winner_name != null) {				output.writeUTF(this.winner_name.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.winner_faction_id);
			output.writeInt(this.best_self);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.fb_id = input.readInt();
			this.fb_name = input.readUTF();
			this.state = input.readInt();
			this.best_time = input.readInt();
			this.winner_id = input.readInt();
			this.winner_name = input.readUTF();
			this.winner_faction_id = input.readInt();
			this.best_self = input.readInt();
		}
	}
}
