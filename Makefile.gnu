.PHONY : clean dist-clean all directories check check-debug

SHELL        = /bin/sh
CC           = gcc
MKDIR_P      = mkdir -p
#FLAGS        = -std=c99
FLAGS        = -std=gnu99 -ggdb
LIBCFLAGS    = -c -Wall -Werror -fPIC  $(FLAGS)
LIBLDFLAGS   = -shared
CPPFLAGS     = -DCHECK_DEBUG
CFLAGS       = -Wall -Werror $(FLAGS)
LIBCHECKLDFLAGS = -pthread -lrt -lm

LIBSRCDIR  = ./src/lib
APPSRCDIR  = ./src/app
TESTSRCDIR = ./src/tests
#LIBCHECKDIR = /usr/lib/arm-linux-gnueabihf/
LIBCHECKDIR = /usr/lib/x86_64-linux-gnu/

OBJDIR = ./obj
BINDIR = ./bin
LDLIBPATHHERE = LD_LIBRARY_PATH=.
LDLIBPATHBIN  = LD_LIBRARY_PATH=bin

LIB        = RomNumMath
APPTARGET  = RomNumCalcApp
TESTTARGET = TestRomNumCalc
TESTTARGETD = TestRomNumCalcD
LIBSRC     = $(LIB).c
APPSRC     = $(APPTARGET).c
TESTSRC    = $(TESTTARGET).c
LIBOBJ     = $(LIB).o
APPOBJ     = $(APPTARGET).o
TESTOBJ    = $(TESTTARGET).o
LIBTARGET  = lib$(LIB).so
LIBCHECK   = check

all : directories $(BINDIR) $(LIBTARGET) $(APPTARGET) $(TESTTARGET) $(TESTTARGETD)
	echo "Building all..."

clean : directories
	rm -f $(OBJDIR)/* $(BINDIR)/*

dist-clean :
	rm -rf $(OBJDIR) $(BINDIR)

directories : $(OBJDIR) $(BINDIR)

check: $(TESTTARGET)
	$(LDLIBPATHBIN) $(BINDIR)/$(TESTTARGET)

check-debug: $(TESTTARGETD)
	$(LDLIBPATHBIN) $(BINDIR)/$(TESTTARGETD)

$(OBJDIR):
	$(MKDIR_P) $(OBJDIR)

$(BINDIR):
	$(MKDIR_P) $(BINDIR)

$(LIBSRC):
ifeq (,$(wildcard $(LIBSRCDIR)/$(LIBSRC)))
	$(error $(LIBSRCDIR)/$(LIBSRC) not found!)
endif

$(LIBOBJ) : directories $(LIBSRCDIR) $(LIBSRC)
	$(CC) $(LIBCFLAGS) $(LIBSRCDIR)/$(LIBSRC) -o $(OBJDIR)/$(LIBOBJ)

$(LIBTARGET) : directories $(OBJDIR) $(LIBOBJ)
	$(CC) $(LIBLDFLAGS) -o $(BINDIR)/$(LIBTARGET) $(OBJDIR)/$(LIBOBJ)

$(APPSRC):
ifeq (,$(wildcard $(APPSRCDIR)/$(APPSRC)))
	$(error $(APPSRCDIR)/$(APPSRC) not found!)
endif

$(APPTARGET) : directories $(APPSRCDIR) $(APPSRC) $(BINDIR) $(LIBTARGET)
	$(CC) -L$(BINDIR) $(CFLAGS) $(APPSRCDIR)/$(APPSRC) -o $(BINDIR)/$(APPTARGET) -l$(LIB)

$(TESTSRC):
ifeq (,$(wildcard $(TESTSRCDIR)/$(TESTSRC)))
	$(error $(TESTSRCDIR)/$(TESTSRC) not found!)
endif

$(TESTTARGET) : directories $(TESTSRCDIR) $(TESTSRC) $(BINDIR) $(LIBTARGET)
	$(CC) -L$(BINDIR) -L$(LIBCHECKDIR) $(CFLAGS) $(TESTSRCDIR)/$(TESTSRC) -o $(BINDIR)/$(TESTTARGET) -l$(LIB) -l$(LIBCHECK) $(LIBCHECKLDFLAGS)

$(TESTTARGETD) : directories $(TESTSRCDIR) $(TESTSRC) $(BINDIR) $(LIBTARGET)
	$(CC) $(CPPFLAGS) -L$(BINDIR) -L$(LIBCHECKDIR) $(CFLAGS) $(TESTSRCDIR)/$(TESTSRC) -o $(BINDIR)/$(TESTTARGETD) -l$(LIB) -l$(LIBCHECK) $(LIBCHECKLDFLAGS)

