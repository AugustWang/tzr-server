package proto.common {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_scene_war_fb_role_info extends Message
	{
		public var roleid:int = 0;
		public var name:String = "";
		public var level:int = 0;
		public function p_scene_war_fb_role_info() {
			super();

			flash.net.registerClassAlias("copy.proto.common.p_scene_war_fb_role_info", p_scene_war_fb_role_info);
		}
		public override function getMethodName():String {
			return 'scene_war_fb_role_';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.roleid);
			if (this.name != null) {				output.writeUTF(this.name.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.level);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.roleid = input.readInt();
			this.name = input.readUTF();
			this.level = input.readInt();
		}
	}
}
