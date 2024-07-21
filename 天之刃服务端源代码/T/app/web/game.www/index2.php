<?php
switch($_SERVER['SERVER_NAME']) {
	case 'www.ming2game-local.com':
		header("Location:/user/test_local.php");
		break;
	case 'www.ming2game-debug.com':
		header("Location:/user/test.php");
		break;
	case 'www.ming2game-release.com':
		header("Location:/user/test.php");
		break;
	default:
		die('Access Denied.');
	break;
}
