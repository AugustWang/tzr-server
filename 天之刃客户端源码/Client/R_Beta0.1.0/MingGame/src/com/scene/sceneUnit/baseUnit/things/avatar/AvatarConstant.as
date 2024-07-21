package com.scene.sceneUnit.baseUnit.things.avatar
{
	
	public class AvatarConstant
	{
		public static const ACTION_DEFULT:String = 'defult';
		public static const ACTION_STAND:String = 'stand';
		public static const ACTION_WALK:String = 'walk';
		public static const ACTION_ATTACK:String = 'attack';
		public static const ACTION_ATTACK_ARROW:String = "attack_arrow";
		public static const ACTION_ATTACK_CASTING:String = "magic";
		public static const ACTION_HURT:String = 'hurt';
		public static const ACTION_DIE:String = 'die';
		public static const ACTION_SIT:String = 'sit';
		public static const THING_STATE_PATH:String = 'defult_d0_';
		
		public static const DIR_UP:int = 0;
		public static const DIR_RIGHT_UP:int = 1;
		public static const DIR_RIGHT:int = 2;
		public static const DIR_RIGHT_DOWN:int = 3;
		public static const DIR_DOWN:int = 4;
		public static const DIR_LEFT_DOWN:int = 5;
		public static const DIR_LEFT:int = 6;
		public static const DIR_LEFT_UP:int = 7;
		
		//人物资源分类加载
		/**
		 * 主体包含: 待机 跑动 坐下 攻击 
		 */		
		public static const TYPE_MAIN:int = 0;
		/**
		 * 施法 
		 */		
		public static const TYPE_MAGIC:int = 1;
		/**
		 * 受击 
		 */		
		public static const TYPE_HURT:int = 2;
		/**
		 * 死亡 
		 */		
		public static const TYPE_DIE:int = 3;
		
	}
}