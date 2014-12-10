%% -*- erlang-indent-level: 4;indent-tabs-mode: nil; fill-column: 92 -*-
%% ex: ts=4 sw=4 et
%% @author Mark Anderson <mark@opscode.com>
%% @version 0.0.1
%% @end
%% Copyright 2011-2012 Opscode, Inc. All Rights Reserved.
%%
%% This file is provided to you under the Apache License,
%% Version 2.0 (the "License"); you may not use this file
%% except in compliance with the License.  You may obtain
%% a copy of the License at
%%
%%   http://www.apache.org/licenses/LICENSE-2.0
%%
%% Unless required by applicable law or agreed to in writing,
%% software distributed under the License is distributed on an
%% "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
%% KIND, either express or implied.  See the License for the
%% specific language governing permissions and limitations
%% under the License.
%%

-module(test_utils).

-export([test_setup/0,
         make_id/1,
         make_az_id/1,
         actor_id/0,
         the_org_id/0,
         other_org_id/0
        ]).

-include_lib("eunit/include/eunit.hrl").

%% a fake URL for setting up the connection pool. We rely on an implementation detail that
%% no connection is attempted until a request is made and we mock out that part of things in
%% the tests.
-define(pool_opts, [{root_url, "http://oc_chef_authz.localhost:5121"},
                    {max_count, 1},
                    {init_count, 1}]).

test_setup() ->
    application:set_env(oc_chef_authz, http_pool, [{oc_chef_authz_test_pool, ?pool_opts}]),
    Server = {context,<<"test-req-id">>,{server,"localhost",5984,[],[]}},
    Superuser = <<"cb4dcaabd91a87675a14ec4f4a00050d">>,
    {Server, Superuser}.

make_id(Prefix) when is_binary(Prefix) ->
    case size(Prefix) of
        Size when Size > 32 ->
            error(prefix_too_long_for_id);
        Size when Size =:= 32 ->
              Prefix;
          Size ->
            iolist_to_binary([Prefix, lists:duplicate(32 - Size, $0)])
    end;
make_id(Prefix) when is_list(Prefix) ->
    make_id(list_to_binary(Prefix)).


make_az_id(Prefix) when is_list(Prefix) ->
    make_az_id(list_to_binary(Prefix));

make_az_id(Prefix) ->
    make_id(<<"a11", Prefix/binary>>).

actor_id() ->
    make_az_id(<<"ffff">>).

the_org_id() ->
    make_id(<<"aa1">>).

other_org_id() ->
    make_id(<<"bb2">>).
