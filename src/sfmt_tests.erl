%% @author Kenji Rikitake <kenji.rikitake@acm.org>
%% @author Mutsuo Saito
%% @author Makoto Matsumoto
%% @author Dan Gudmundsson
%% @doc SIMD-oriented Fast Mersenne Twister (SFMT) EUnit testing functions.
%% The module provides EUnit testing functions for the sfmt module functions.
%% (for period ((2^19937) - 1))
%% @reference <a href="http://github.com/jj1bdx/sfmt-erlang">GitHub page
%% for sfmt-erlang</a>
%% @copyright 2010-2014 Kenji Rikitake and Kyoto University.
%% Copyright (c) 2006, 2007 Mutsuo Saito, Makoto Matsumoto and
%% Hiroshima University.

%% Copyright (c) 2010-2014 Kenji Rikitake and Kyoto University. All rights
%% reserved.
%%
%% Copyright (c) 2006,2007 Mutsuo Saito, Makoto Matsumoto and Hiroshima
%% University. All rights reserved.
%%
%% Redistribution and use in source and binary forms, with or without
%% modification, are permitted provided that the following conditions are
%% met:
%%
%%     * Redistributions of source code must retain the above copyright
%%       notice, this list of conditions and the following disclaimer.
%%     * Redistributions in binary form must reproduce the above
%%       copyright notice, this list of conditions and the following
%%       disclaimer in the documentation and/or other materials provided
%%       with the distribution.
%%     * Neither the names of the Hiroshima University and the Kyoto
%%       University nor the names of its contributors may be used to
%%       endorse or promote products derived from this software without
%%       specific prior written permission.
%%
%% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
%% "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
%% LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
%% A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
%% OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
%% SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
%% LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
%% DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
%% THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
%% (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
%% OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

-module(sfmt_tests).

-export([
	 test_speed/0,
	 test_short_speed/0
	 ]).

test_speed_rand_rec1(0, _, _) ->
    ok;
test_speed_rand_rec1(X, Q, I) ->
    {_, I2} = sfmt:gen_rand_list32(Q, I),
    test_speed_rand_rec1(X - 1, Q, I2).

test_speed_rand(P, Q) ->
    _ = statistics(runtime),
    I = sfmt:init_gen_rand(1234),
    ok = test_speed_rand_rec1(P, Q, I),
    {_, T} = statistics(runtime),
    T.

test_speed_sfmt_uniform_rec1(Acc, 0, _, _, _) ->
    _ = lists:reverse(Acc),
    ok;
test_speed_sfmt_uniform_rec1(Acc, X, 0, R, I) ->
    _ = lists:reverse(Acc),
    test_speed_sfmt_uniform_rec1([], X - 1, R, R, I);
test_speed_sfmt_uniform_rec1(Acc, X, Q, R, I) ->
    {F, I2} = sfmt:uniform_s(I),
    test_speed_sfmt_uniform_rec1([F|Acc], X, Q - 1, R, I2).

test_speed_sfmt_uniform(P, Q) ->
    _ = statistics(runtime),
    I = sfmt:seed(),
    ok = test_speed_sfmt_uniform_rec1([], P, Q, Q, I),
    {_, T} = statistics(runtime),
    T.

test_speed_orig_uniform_rec1(Acc, 0, _, _, _) ->
    _ = lists:reverse(Acc),
    ok;
test_speed_orig_uniform_rec1(Acc, X, 0, R, I) ->
    _ = lists:reverse(Acc),
    test_speed_orig_uniform_rec1([], X - 1, R, R, I);
test_speed_orig_uniform_rec1(Acc, X, Q, R, I) ->
    {F, I2} = random:uniform_s(I),
    test_speed_orig_uniform_rec1([F|Acc], X, Q - 1, R, I2).

test_speed_orig_uniform(P, Q) ->
    _ = statistics(runtime),
    I = random:seed(),
    ok = test_speed_orig_uniform_rec1([], P, Q, Q, I),
    {_, T} = statistics(runtime),
    T.

test_speed_rand_max_rec1(Acc, 0, _, _, _) ->
    _ = lists:reverse(Acc),
    ok;
test_speed_rand_max_rec1(Acc, X, 0, R, I) ->
    _ = lists:reverse(Acc),
    test_speed_rand_max_rec1([], X - 1, R, R, I);
test_speed_rand_max_rec1(Acc, X, Q, R, I) ->
    {F, I2} = sfmt:gen_rand32_max(10000, I),
    test_speed_rand_max_rec1([F|Acc], X, Q - 1, R, I2).

test_speed_rand_max(P, Q) ->
    _ = statistics(runtime),
    I = sfmt:init_gen_rand(1234),
    ok = test_speed_rand_max_rec1([], P, Q, Q, I),
    {_, T} = statistics(runtime),
    T.

test_speed_orig_uniform_n_rec1(Acc, 0, _, _, _) ->
    _ = lists:reverse(Acc),
    ok;
test_speed_orig_uniform_n_rec1(Acc, X, 0, R, I) ->
    _ = lists:reverse(Acc),
    test_speed_orig_uniform_n_rec1([], X - 1, R, R, I);
test_speed_orig_uniform_n_rec1(Acc, X, Q, R, I) ->
    {F, I2} = random:uniform_s(10000, I),
    test_speed_orig_uniform_n_rec1([F|Acc], X, Q - 1, R, I2).

test_speed_orig_uniform_n(P, Q) ->
    _ = statistics(runtime),
    I = random:seed(),
    ok = test_speed_orig_uniform_n_rec1([], P, Q, Q, I),
    {_, T} = statistics(runtime),
    T.

%% @doc running speed test for 100 times of
%% 100000 calls for sfmt:gen_rand32/1, sfmt:uniform_s/1,
%% random:uniform_s/1, sfmt:gen_rand32_max/2, and random:uniform_s/2.

-spec test_speed() -> ok.

test_speed() ->
    io:format("{rand, sfmt_uniform, orig_uniform, rand_max, orig_uniform_n}~n~p~n",
	    [{test_speed_rand(100, 100000),
		test_speed_sfmt_uniform(100, 100000),
		test_speed_orig_uniform(100, 100000),
	    test_speed_rand_max(100, 100000),
        test_speed_orig_uniform_n(100, 100000)}
	    ]).

%% @doc running speed test for 10 times of
%% 10000 calls for sfmt:gen_rand32/1, sfmt:uniform_s/1,
%% random:uniform_s/1, sfmt:gen_rand32_max/2, and random:uniform_s/2.

-spec test_short_speed() -> ok.

test_short_speed() ->
    io:format("{rand, sfmt_uniform, orig_uniform, rand_max, orig_uniform_n}~n~p~n",
	    [{test_speed_rand(10, 10000),
		test_speed_sfmt_uniform(10, 10000),
		test_speed_orig_uniform(10, 10000),
	    test_speed_rand_max(10, 10000),
        test_speed_orig_uniform_n(10, 10000)}
	    ]).
