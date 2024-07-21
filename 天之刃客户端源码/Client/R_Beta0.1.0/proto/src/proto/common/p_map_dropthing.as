package proto.common {
	import proto.common.p_pos;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_map_dropthing extends Message
	{
		public var id:int = 0;
		public var ismoney:Boolean = false;
		public var bind:Boolean = false;
		public var num:int = 1;
		public var roles:Array = new Array;
		public var pos:p_pos = null;
		public var money:int = 0;
		public var goodsid:int = 0;
		public var colour:int = 0;
		public var goodstype:int = 0;
		public var goodstypeid:int = 0;
		public var drop_property:p_drop_property = null;
		public function p_map_dropthing() {
			super();
			this.pos = new p_pos;
			this.drop_property = new p_drop_property;

			flash.net.registerClassAlias("copy.proto.common.p_map_dropthing", p_map_dropthing);
		}
		public override function getMethodName():String {
			return 'map_dropt';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.id);
			output.writeBoolean(this.ismoney);
			output.writeBoolean(this.bind);
			output.writeInt(this.num);
			var size_roles:int = this.roles.length;
			output.writeShort(size_roles);
			var temp_repeated_byte_roles:ByteArray= new ByteArray;
			for(i=0; i<size_roles; i++) {
				temp_repeated_byte_roles.writeInt(this.roles[i]);
			}
			output.writeInt(temp_repeated_byte_roles.length);
			output.writeBytes(temp_repeated_byte_roles);
			var tmp_pos:ByteArray = new ByteArray;
			this.pos.writeToDataOutput(tmp_pos);
			var size_tmp_pos:int = tmp_pos.length;
			output.writeInt(size_tmp_pos);
			output.writeBytes(tmp_pos);
			output.writeInt(this.money);
			output.writeInt(this.goodsid);
			output.writeInt(this.colour);
			output.writeInt(this.goodstype);
			output.writeInt(this.goodstypeid);
			var tmp_drop_property:ByteArray = new ByteArray;
			this.drop_property.writeToDataOutput(tmp_drop_property);
			var size_tmp_drop_property:int = tmp_drop_property.length;
			output.writeInt(size_tmp_drop_property);
			output.writeBytes(tmp_drop_property);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.id = input.readInt();
			this.ismoney = input.readBoolean();
			this.bind = input.readBoolean();
			this.num = input.readInt();
			var size_roles:int = input.readShort();
			var length_roles:int = input.readInt();
			var byte_roles:ByteArray = new ByteArray; 
			if (size_roles > 0) {
				input.readBytes(byte_roles, 0, size_roles * 4);
				for(i=0; i<size_roles; i++) {
					var tmp_roles:int = byte_roles.readInt();
					this.roles.push(tmp_roles);
				}
			}
			var byte_pos_size:int = input.readInt();
			if (byte_pos_size > 0) {				this.pos = new p_pos;
				var byte_pos:ByteArray = new ByteArray;
				input.readBytes(byte_pos, 0, byte_pos_size);
				this.pos.readFromDataOutput(byte_pos);
			}
			this.money = input.readInt();
			this.goodsid = input.readInt();
			this.colour = input.readInt();
			this.goodstype = input.readInt();
			this.goodstypeid = input.readInt();
			var byte_drop_property_size:int = input.readInt();
			if (byte_drop_property_size > 0) {				this.drop_property = new p_drop_property;
				var byte_drop_property:ByteArray = new ByteArray;
				input.readBytes(byte_drop_property, 0, byte_drop_property_size);
				this.drop_property.readFromDataOutput(byte_drop_property);
			}
		}
	}
}
