package proto.common {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_educate_fb_item extends Message
	{
		public var item_id:int = 0;
		public var use_tx:int = 0;
		public var use_ty:int = 0;
		public var role_id:int = 0;
		public var role_name:String = "";
		public var status:int = 0;
		public function p_educate_fb_item() {
			super();

			flash.net.registerClassAlias("copy.proto.common.p_educate_fb_item", p_educate_fb_item);
		}
		public override function getMethodName():String {
			return 'educate_fb_';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.item_id);
			output.writeInt(this.use_tx);
			output.writeInt(this.use_ty);
			output.writeInt(this.role_id);
			if (this.role_name != null) {				output.writeUTF(this.role_name.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.status);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.item_id = input.readInt();
			this.use_tx = input.readInt();
			this.use_ty = input.readInt();
			this.role_id = input.readInt();
			this.role_name = input.readUTF();
			this.status = input.readInt();
		}
	}
}
