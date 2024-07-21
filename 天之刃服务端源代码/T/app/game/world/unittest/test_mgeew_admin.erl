-module(test_mgeew_admin).
-include("common.hrl").
-compile([export_all]).

t_test()->
    CommonResult = common_admin_hook:hook({accept_first_task,1}),
    common_admin_hook:hook({accept_first_task,1}),
    common_admin_hook:hook({accept_first_task,1}),
    common_admin_hook:hook({accept_first_task,1}),
    WindowResult  =  common_admin_hook:hook({enter_flash_window,1}),
    common_admin_hook:hook({enter_flash_window,1}),
    common_admin_hook:hook({enter_flash_window,1}),
    common_admin_hook:hook({enter_flash_window,1}),
    {CommonResult,WindowResult}.





	
    







