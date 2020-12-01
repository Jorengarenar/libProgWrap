# vim: fdm=marker

# Init {{{1

BUILD    := build
OBJDIR   := $(BUILD)/obj
SRCDIR   := .

LIBNAME     := wrapper_exec
LIBFILENAME := lib$(LIBNAME).a

ifndef INCLUDEDIR
	override INCLUDEDIR = $(XDG_INCLUDE_DIR)
endif

ifndef LIBDIR
	override LIBDIR = $(XDG_LIB_DIR)
endif

CFLAGS = -std=gnu99 -O2

SOURCES := $(wildcard $(SRCDIR)/*.c)
TARGETS := $(patsubst $(SRCDIR)/%.c, $(OBJDIR)/%.o, $(SOURCES))

.PHONY: all dirs C clean install install-C install-Shell uninstall

# Build {{{1

all: C


C: dirs $(BUILD)/$(LIBFILENAME)

dirs:
	@mkdir -p $(OBJDIR) $(BUILD)

$(BUILD)/$(LIBFILENAME): $(TARGETS)
	ar rcs $(BUILD)/$(LIBFILENAME) $(TARGETS)

$(OBJDIR)/%.o: $(SRCDIR)/%.c
	$(CC) $(CFLAGS) -o $@ -c $<

# Install {{{1

install: all install-C install-Shell

install-C:
	@mkdir -p $(LIBDIR)/c $(INCLUDEDIR)/c
	install $(BUILD)/$(LIBFILENAME) $(LIBDIR)/c/$(LIBFILENAME)
	cp $(LIBNAME).h $(INCLUDEDIR)/c/$(LIBNAME).h

install-Shell:
	install $(LIBNAME).sh $(LIBDIR)/shell/$(LIBNAME).sh

# Clean {{{1

uninstall:
	rm $(LIBDIR)/c/$(LIBFILENAME)
	rm $(INCLUDEDIR)/c/$(LIBNAME).h
	rm $(LIBDIR)/shell/$(LIBNAME).sh

clean:
	rm -rf build
