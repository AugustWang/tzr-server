package com.scene.sceneData {

	public class BinaryMath {
		private static var exist:int=1;
		private static var alpha:int=2;
		private static var run:int=4;
		private static var safe:int=8;
		private static var allSafe:int=16;
		private static var sell:int=32;
		private static var arena:int=64;
		private static var yuliu:int=128;
		////////////////////////////////////
		private static var unExist:int=254;
		private static var unAlpha:int=253;
		private static var unRun:int=251;
		private static var unSafe:int=247;
		private static var unAllSafe:int=239;
		private static var unSell:int=223;
		private static var unArena:int=191;
		private static var unYuliu:int=127;

		public static function setCell(value:int, isExist:Boolean, isAlpha:Boolean, isRun:Boolean, isSafe:Boolean, isAllSafe:Boolean, isSell:Boolean, isArena:Boolean):int {
			value=setExist(value, isExist);
			value=setAlpha(value, isAlpha);
			value=setRun(value, isRun);
			value=setSafe(value, isSafe);
			value=setAllSafe(value, isAllSafe);
			value=setSell(value, isSell);
			value=setArena(value, isArena);
			return value;
		}

		public static function setExist(value:int, isExist:Boolean):int {
			if (isExist) {
				return value | exist;
			}
			return value & unExist;
		}

		public static function setAlpha(value:int, isAlpha:Boolean):int {
			if (isAlpha) {
				return value | alpha;
			}
			return value & unAlpha;
		}

		public static function setRun(value:int, isRun:Boolean):int {
			if (isRun) {
				return value | run;
			}
			return value & unRun;
		}

		public static function setSafe(value:int, isSafe:Boolean):int {
			if (isSafe) {
				return value | safe;
			}
			return value & unSafe;
		}

		public static function setAllSafe(value:int, isAllSafe:Boolean):int {
			if (isAllSafe) {
				return value | allSafe;
			}
			return value & unAllSafe;
		}

		public static function setSell(value:int, isSell:Boolean):int {
			if (isSell) {
				return value | sell;
			}
			return value & unSell;
		}

		public static function setArena(value:int, isArena:Boolean):int {
			if (isArena) {
				return value | arena;
			}
			return value & unArena;
		}

		///////////////////////////////////////////
		public static function isExist(value:int):Boolean {
			return (value & exist) == exist;
		}

		public static function isAlpha(value:int):Boolean {
			return (value & alpha) == alpha;
		}

		public static function isRun(value:int):Boolean {
			return (value & run) == run;
		}

		public static function isSafe(value:int):Boolean {
			return (value & safe) == safe;
		}

		public static function isAllSafe(value:int):Boolean {
			return (value & allSafe) == allSafe;
		}

		public static function isSell(value:int):Boolean {
			return (value & sell) == sell;
		}

		public static function isArena(value:int):Boolean {
			return (value & arena) == arena;
		}
	}
}