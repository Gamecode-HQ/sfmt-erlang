# for both BSD/GNU Make

.PHONY: compile clean c_doc doc eunit speed

REBAR=@`sh -c "PATH='$(PATH)':support which rebar\
       ||support/getrebar||echo false"`

compile:
	$(REBAR) compile

clean:
	$(REBAR) clean

c_doc:
	doxygen

doc: 
	$(REBAR) doc

eunit:
	$(REBAR) eunit

# N: 607, 4253, 19937, 86243, 216091
# for periods (2^N - 1)

speed:
	erl -pa ./ebin -noshell -s sfmt607_tests test_speed -s init stop
	erl -pa ./ebin -noshell -s sfmt4253_tests test_speed -s init stop
	erl -pa ./ebin -noshell -s sfmt_tests test_speed -s init stop
	erl -pa ./ebin -noshell -s sfmt86243_tests test_speed -s init stop
	erl -pa ./ebin -noshell -s sfmt216091_tests test_speed -s init stop
	erl -pa ./ebin -noshell -s sfmt607_tests test_speed -s init stop
	erl -pa ./ebin -noshell -s sfmt_pure_tests test_speed -s init stop
