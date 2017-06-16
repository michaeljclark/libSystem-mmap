LIBRARIES = \
	lib/mmap-himem.dylib

PROGRAMS = \
	bin/mmap-test-vanilla \
	bin/mmap-test-collision \
	bin/mmap-test-himem

all: $(LIBRARIES) $(PROGRAMS)

test: all
	@echo '\n'== mmap-test-vanilla   == ; bin/mmap-test-vanilla
	@echo '\n'== mmap-test-collision == ; bin/mmap-test-collision
	@echo '\n'== mmap-test-himem     == ; bin/mmap-test-himem

clean: ; rm -fr bin obj lib

bin/mmap-test-vanilla: obj/mmap-test.o
	@mkdir -p bin
	cc -o $@ $^

bin/mmap-test-collision: obj/mmap-test.o
	@mkdir -p bin
	cc -Wl,-no_pie -Wl,-pagezero_size,0x1000 \
	-image_base 0x7ffe00000000 \
	-o $@ $^

bin/mmap-test-himem: obj/mmap-test.o
	@mkdir -p bin
	cc -Wl,-no_pie -Wl,-pagezero_size,0x1000 \
	-image_base 0x7ffe00000000 \
	-rpath lib lib/mmap-himem.dylib \
	-o $@ $^

lib/mmap-himem.dylib: obj/mmap-himem.o
	@mkdir -p lib
	cc -dynamiclib \
	-install_name @rpath/mmap-himem.dylib \
	-image_base 0x7ffe80000000 \
	-o $@ $^

obj/%.o: %.c
	@mkdir -p obj
	cc -Wall -Wpedantic -c -o $@ $<
