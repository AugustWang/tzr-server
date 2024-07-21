package proto.common {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_skin extends Message
	{
		public var skinid:int = 0;
		public var hair_type:int = 1;
		public var hair_color:String = "";
		public var weapon:int = 0;
		public var clothes:int = 0;
		public var mounts:int = 0;
		public var assis_weapon:int = 0;
		public var fashion:int = 0;
		public function p_skin() {
			super();

			flash.net.registerClassAlias("copy.proto.common.p_skin", p_skin);
		}
		public override function getMethodName():String {
			return '';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.skinid);
			output.writeInt(this.hair_type);
			if (this.hair_color != null) {				output.writeUTF(this.hair_color.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.weapon);
			output.writeInt(this.clothes);
			output.writeInt(this.mounts);
			output.writeInt(this.assis_weapon);
			output.writeInt(this.fashion);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.skinid = input.readInt();
			this.hair_type = input.readInt();
			this.hair_color = input.readUTF();
			this.weapon = input.readInt();
			this.clothes = input.readInt();
			this.mounts = input.readInt();
			this.assis_weapon = input.readInt();
			this.fashion = input.readInt();
		}
	}
}
