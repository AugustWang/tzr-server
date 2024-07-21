%%%-------------------------------------------------------------------
%%% @author  <>
%%% @copyright (C) 2010, 
%%% Description: 二维坐标由里向外顺时针搜索
%%% Created : 11 Nov 2010 by  <>
%%%-------------------------------------------------------------------
-module(mod_spiral_search).

-export([get_walkable_pos/3]).

-include("mgeem.hrl").

get_walkable_pos(X, Y, N) ->
    spiral_search(X, Y, X, Y, N, 1, 0).

spiral_search(X, Y, CX, CY, N, CN, Dir) ->
    case N =:= CN orelse CX =< 0 orelse CY =< 0 of
        true ->
            {error, not_found};
        _ ->
            case if_walkable(CX, CY) of
                true ->
                    {CX, CY};
                _ ->
                    if
                        Dir =:= 0 ->
                            dir_right(X, Y, CX, CY, N, CN, Dir);
                        Dir =:= 1 ->
                            dir_down(X, Y, CX, CY, N, CN, Dir);
                        Dir =:= 2 ->
                            dir_left(X, Y, CX, CY, N, CN, Dir);
                        true ->
                            dir_up(X, Y, CX, CY, N, CN, Dir)
                    end
            end
    end.

dir_right(X, Y, CX, CY, N, CN, Dir) ->
    NX = CX + 1,

    case NX > X + CN of
        true ->
            dir_down(X, Y, CX, CY, N, CN, 1);
        _ ->
            spiral_search(X, Y, NX, CY, N, CN, Dir)
    end.

dir_down(X, Y, CX, CY, N, CN, Dir) ->
    NY = CY - 1,

    case NY < Y - CN of
        true ->
            dir_left(X, Y, CX, CY, N, CN, 2);
        _ ->
            case CX =:= X + CN andalso NY =:= Y of
                true ->
                    spiral_search(X, Y, CX, NY, N, CN+1, 0);
                _ ->
                    spiral_search(X, Y, CX, NY, N, CN, Dir)
            end
    end.

dir_left(X, Y, CX, CY, N, CN, Dir) ->
    NX = CX - 1,

    case NX < X - CN of
        true ->
            dir_up(X, Y, CX, CY, N, CN, 3);
        _ ->
            spiral_search(X, Y, NX, CY, N, CN, Dir)
    end.

dir_up(X, Y, CX, CY, N, CN, Dir) ->
    NY = CY + 1,

    case NY > Y + CN of
        true ->
            dir_right(X, Y, CX, CY, N, CN, 0);
        _ ->
            spiral_search(X, Y, CX, NY, N, CN, Dir)
    end.

if_walkable(TX, TY) ->
    case get({TX, TY}) of
        undefined ->
            false;
        _ ->
            case get({ref, TX, TY}) of
                [] ->
                    true;
                _ ->
                    false
            end
    end.
