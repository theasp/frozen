PROF ?= -fprofile-arcs -ftest-coverage -O0
CFLAGS ?= -W -Wall -pedantic -O2 -std=c99 -g $(CFLAGS_EXTRA)
CXXFLAGS ?= -W -Wall -pedantic -O2 $(CXXFLAGS_EXTRA)
CLFLAGS ?= /DWIN32_LEAN_AND_MEAN /MD /O2 /TC /W2 /WX

RD = docker run --rm -v $(CURDIR):$(CURDIR) -w $(CURDIR)
GCC_DOCKER = library/gcc:latest
AR = $(RD) $(GCC_DOCKER) ar
CC = $(RD) $(GCC_DOCKER) cc
CXX = $(RD) $(GCC_DOCKER) c++
GCOV = $(RD) $(GCC_DOCKER) gcov

.PHONY: clean all vc98 vc2017 c c++ test c-test c++-test

all: frozen.a

test: ci-test

ci-test: c-test c++-test vc98 vc2017

%c.o:
	$(CC) -o $@ -c $^

frozen.a: frozen.o
	$(AR) rcs $@ $^

c-test: clean
	$(CC) unit_test.c -o unit_test $(CFLAGS) $(PROF) && ./unit_test
	$(GCOV) -a unit_test.c

c++-test: clean
	$(CXX) unit_test.c -o unit_test $(CXXFLAGS) $(PROF) && ./unit_test
	$(GCOV) -a unit_test.c

vc98 vc2017:
	$(RD) docker.cesanta.com/$@ wine cl unit_test.c $(CLFLAGS) /Fe$@.exe
	$(RD) docker.cesanta.com/$@ wine $@.exe

clean:
	rm -rf *.gc* *.dSYM unit_test *.exe *.obj _CL_* *.o *.a
