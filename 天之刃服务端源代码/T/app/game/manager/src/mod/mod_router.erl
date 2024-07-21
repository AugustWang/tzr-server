-module(mod_router).
-include("manager.hrl").

-export([router/2]).
    
router(Other, State) ->
    ?DEV("~ts:~w", ["收到未定义的数据，路由信息为", Other]),
    State.