package com.common
{
	import flash.utils.Dictionary;

    public class InputKey 
    {
        public static const BACKSPACE:int =  8 ;
        public static const TAB:int =  9 ;
        public static const ENTER:int =  13 ;
        public static const COMMAND:int =  15 ;
        public static const SHIFT:int =  16 ;
        public static const CONTROL:int =  17 ;
        public static const ALT:int =  18 ;
        public static const PAUSE:int =  19 ;
        public static const CAPS_LOCK:int =  20 ;
        public static const ESCAPE:int =  27 ;

        public static const SPACE:int =  32 ;
        public static const PAGE_UP:int =  33 ;
        public static const PAGE_DOWN:int =  34 ;
        public static const END:int =  35 ;
        public static const HOME:int =  36 ;
        public static const LEFT:int =  37 ;
        public static const UP:int =  38 ;
        public static const RIGHT:int =  39 ;
        public static const DOWN:int =  40 ;

        public static const INSERT:int =  45 ;
        public static const DELETE:int =  46 ;

        public static const ZERO:int =  48 ;
        public static const ONE:int =  49 ;
        public static const TWO:int =  50 ;
        public static const THREE:int =  51 ;
        public static const FOUR:int =  52 ;
        public static const FIVE:int =  53 ;
        public static const SIX:int =  54 ;
        public static const SEVEN:int =  55 ;
        public static const EIGHT:int =  56 ;
        public static const NINE:int =  57 ;

        public static const A:int =  65 ;
        public static const B:int =  66 ;
        public static const C:int =  67 ;
        public static const D:int =  68 ;
        public static const E:int =  69 ;
        public static const F:int =  70 ;
        public static const G:int =  71 ;
        public static const H:int =  72 ;
        public static const I:int =  73 ;
        public static const J:int =  74 ;
        public static const K:int =  75 ;
        public static const L:int =  76 ;
        public static const M:int =  77 ;
        public static const N:int =  78 ;
        public static const O:int =  79 ;
        public static const P:int =  80 ;
        public static const Q:int =  81 ;
        public static const R:int =  82 ;
        public static const S:int =  83 ;
        public static const T:int =  84 ;
        public static const U:int =  85 ;
        public static const V:int =  86 ;
        public static const W:int =  87 ;
        public static const X:int =  88 ;
        public static const Y:int =  89 ;
        public static const Z:int =  90 ;

        public static const NUM0:int =  96 ;
        public static const NUM1:int =  97 ;
        public static const NUM2:int =  98 ;
        public static const NUM3:int =  99 ;
        public static const NUM4:int =  100 ;
        public static const NUM5:int =  101 ;
        public static const NUM6:int =  102 ;
        public static const NUM7:int =  103 ;
        public static const NUM8:int =  104 ;
        public static const NUM9:int =  105 ;

        public static const MULTIPLY:int =  106 ;
        public static const ADD:int =  107 ;
        public static const NUMENTER:int =  108 ;
        public static const SUBTRACT:int =  109 ;
        public static const DECIMAL:int =  110 ;
        public static const DIVIDE:int =  111 ;

        public static const F1:int =  112 ;
        public static const F2:int =  113 ;
        public static const F3:int =  114 ;
        public static const F4:int =  115 ;
        public static const F5:int =  116 ;
        public static const F6:int =  117 ;
        public static const F7:int =  118 ;
        public static const F8:int =  119 ;
        public static const F9:int =  120 ;
        // F10 is considered 'reserved' by Flash
        public static const F11:int =  122 ;
        public static const F12:int =  123 ;

        public static const NUM_LOCK:int =  144 ;
        public static const SCROLL_LOCK:int =  145 ;

        public static const COLON:int =  186 ;
        public static const PLUS:int =  187 ;
        public static const COMMA:int =  188 ;
        public static const MINUS:int =  189 ;
        public static const PERIOD:int =  190 ;
        public static const BACKSLASH:int =  191 ;
        public static const TILDE:int =  192 ;

        public static const LEFT_BRACKET:int =  219 ;
        public static const SLASH:int =  220 ;
        public static const RIGHT_BRACKET:int =  221 ;
        public static const QUOTE:int =  222 ;

        public static const MOUSE_BUTTON:int =  253 ;
        public static const MOUSE_X:int =  254 ;
        public static const MOUSE_Y:int =  255 ;
        public static const MOUSE_WHEEL:int =  256 ;
        public static const MOUSE_HOVER:int =  257 ;
		
		
		public static var inited:Boolean = init();
		private static var keyCodes:Dictionary;
		
		private static function init():Boolean{
			keyCodes = new Dictionary();
			
			keyCodes[TAB] = 1;;
			keyCodes[ENTER] = 1;
			
			keyCodes[SHIFT] = 1;
			keyCodes[CONTROL] = 1;
			keyCodes[ALT] = 1;
			keyCodes[ESCAPE] = 1;
			keyCodes[SPACE] = 1;
			keyCodes[TILDE] = 1;
			
			
			keyCodes[ZERO] = 1;
			keyCodes[ONE] = 1;
			keyCodes[TWO] = 1;
			keyCodes[THREE] = 1;
			keyCodes[FOUR] = 1;
			keyCodes[FIVE] = 1;
			keyCodes[SIX] = 1;
			keyCodes[SEVEN] = 1;
			keyCodes[EIGHT] = 1;
			keyCodes[NINE] = 1;
			
			keyCodes[A] = 1;
			keyCodes[B] = 1;
			keyCodes[C] = 1;
			keyCodes[D] = 1;
			keyCodes[E] = 1;
			keyCodes[F] = 1;
			keyCodes[G] = 1;
			keyCodes[H] = 1;
			keyCodes[I] = 1;
			keyCodes[J] = 1;
			keyCodes[K] = 1;
			keyCodes[L] = 1;
			keyCodes[M] = 1;
			keyCodes[N] = 1;
			keyCodes[O] = 1;
			keyCodes[P] = 1;
			keyCodes[Q] = 1;
			keyCodes[R] = 1;
			keyCodes[S] = 1;
			keyCodes[T] = 1;
			keyCodes[U] = 1;
			keyCodes[V] = 1;
			keyCodes[W] = 1;
			keyCodes[X] = 1;
			keyCodes[Y] = 1;
			keyCodes[Z] = 1;
			
			keyCodes[F1] = 1;
			keyCodes[F2] = 1;
			keyCodes[F3] = 1;
			keyCodes[F4] = 1;
			keyCodes[F5] = 1;
			keyCodes[F6] = 1;
			keyCodes[F7] = 1;
			keyCodes[F8] = 1;
			keyCodes[F9] = 1;
			keyCodes[F11] = 1;
			keyCodes[F12] = 1;
			return true;
		}
		
		public static function isValidCode(key:int):Boolean{
			return keyCodes[key] == 1;
		}
    }
}

