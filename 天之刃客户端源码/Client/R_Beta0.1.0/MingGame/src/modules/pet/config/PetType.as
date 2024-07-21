package modules.pet.config {

	public class PetType {
		public var typeId:int;
		public var skinId:int;
		public var takeLevel:int;
		public var msg:String;
		public var maxAptitude:int;
		public var attackType:String;

		public function PetType(type:String, skin:String, level:int, message:String, aptitude:int, attack:String) {
			typeId=int(type);
			skinId=int(skin);
			takeLevel=int(level);
			msg=message;
			maxAptitude=aptitude;
			attackType=attack;
		}
	}
}
