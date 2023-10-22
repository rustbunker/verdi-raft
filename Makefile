PYTHON=python2.7

include Makefile.ml-files

default: Makefile.coq
	$(MAKE) -f Makefile.coq

quick: Makefile.coq
	$(MAKE) -f Makefile.coq quick

vos: Makefile.coq
	$(MAKE) -f Makefile.coq vos

checkproofs: quick
	$(MAKE) -f Makefile.coq checkproofs

install: Makefile.coq
	$(MAKE) -f Makefile.coq install

proofalytics:
	$(MAKE) -C proofalytics clean
	$(MAKE) -C proofalytics
	$(MAKE) -C proofalytics publish

STDBUF=$(shell [ -x "$$(which gstdbuf)" ] && echo "gstdbuf" || echo "stdbuf")
BUILDTIMER=$(PWD)/proofalytics/build-timer.sh $(STDBUF) -i0 -o0

proofalytics-aux: Makefile.coq
	$(MAKE) -f Makefile.coq TIMECMD="$(BUILDTIMER)"

Makefile.coq: _CoqProject
	coq_makefile -f _CoqProject -o Makefile.coq

theories/Raft/RaftState.v: theories/Raft/RaftState.v.rec
	$(PYTHON) script/extract_record_notation.py theories/Raft/RaftState.v.rec raft_data > theories/Raft/RaftState.v

clean: Makefile.coq
	$(MAKE) -f Makefile.coq cleanall
	rm -f Makefile.coq Makefile.coq.conf
	find . -name '*.buildtime' -delete
	$(MAKE) -C proofalytics clean
	$(MAKE) -C extraction/vard clean
	$(MAKE) -C extraction/vard-serialized clean
	$(MAKE) -C extraction/vard-log clean
	$(MAKE) -C extraction/vard-serialized-log clean
	$(MAKE) -C extraction/vard-debug clean

assumptions: Makefile.coq
	$(MAKE) -f Makefile.coq script/assumptions.vo

$(VARDML) $(VARDSERML) $(VARDLOGML) $(VARDSERLOGML) $(VARDDEBUGML): Makefile.coq
	$(MAKE) -f Makefile.coq $@

vard:
	+$(MAKE) -C extraction/vard

vard-test:
	+$(MAKE) -C extraction/vard test

vard-serialized:
	+$(MAKE) -C extraction/vard-serialized

vard-serialized-test:
	+$(MAKE) -C extraction/vard-serialized test

vard-log:
	+$(MAKE) -C extraction/vard-log

vard-log-test:
	+$(MAKE) -C extraction/vard-log test

vard-serialized-log:
	+$(MAKE) -C extraction/vard-serialized-log

vard-serialized-log-test:
	+$(MAKE) -C extraction/vard-serialized-log test

vard-debug:
	+$(MAKE) -C extraction/vard-debug

vard-debug-test:
	+$(MAKE) -C extraction/vard-debug test

lint:
	@echo "Possible use of hypothesis names:"
	find . -name '*.v' -exec grep -Hn 'H[0-9][0-9]*' {} \;

distclean: clean
	rm -f _CoqProject

.PHONY: default quick install clean lint proofalytics distclean checkproofs assumptions vos
.PHONY: vard vard-test vard-serialized vard-serialized-test vard-log vard-log-test vard-serialized-log vard-serialized-log-test vard-debug vard-debug-test
.PHONY: $(VARDML) $(VARDSERML) $(VARDLOGML) $(VARDSERLOGML) $(VARDDEBUGML)

.NOTPARALLEL: $(VARDML)
.NOTPARALLEL: $(VARDSERML)
.NOTPARALLEL: $(VARDLOGML)
.NOTPARALLEL: $(VARDSERLOGML)
.NOTPARALLEL: $(VARDDEBUGML)
