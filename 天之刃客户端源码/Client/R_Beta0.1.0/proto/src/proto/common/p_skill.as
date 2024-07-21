package proto.common {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_skill extends Message
	{
		public var id:int = 0;
		public var name:String = "";
		public var kind:int = 0;
		public var effect_type:int = 0;
		public var distance:int = 0;
		public var attack_type:int = 0;
		public var target_type:int = 0;
		public var max_level:int = 0;
		public var contain_common_attack:Boolean = true;
		public var category:int = 0;
		public var target_area:int = 0;
		public function p_skill() {
			super();

			flash.net.registerClassAlias("copy.proto.common.p_skill", p_skill);
		}
		public override function getMethodName():String {
			return 's';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.id);
			if (this.name != null) {				output.writeUTF(this.name.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.kind);
			output.writeInt(this.effect_type);
			output.writeInt(this.distance);
			output.writeInt(this.attack_type);
			output.writeInt(this.target_type);
			output.writeInt(this.max_level);
			output.writeBoolean(this.contain_common_attack);
			output.writeInt(this.category);
			output.writeInt(this.target_area);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.id = input.readInt();
			this.name = input.readUTF();
			this.kind = input.readInt();
			this.effect_type = input.readInt();
			this.distance = input.readInt();
			this.attack_type = input.readInt();
			this.target_type = input.readInt();
			this.max_level = input.readInt();
			this.contain_common_attack = input.readBoolean();
			this.category = input.readInt();
			this.target_area = input.readInt();
		}
	}
}
