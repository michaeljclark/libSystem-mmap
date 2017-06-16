# libSystem-mmap

memory map interposition for libsystem_malloc.dylib on macOS

This project contains an example of memory map interposition
to give finer grained control over the address space layout
when linking with libSystem.dylib on macOS.

The following libSystem functions are interposed:

* mmap
* vm_map
* vm_allocate
* mach_vm_map
* mach_vm_allocate.

libSystem on macOS normally allocates the bottom 4GiB of
address space as a large zero page. This project provides
an examples of how to free up this address space, along
with mitigations that prevent the libSystem memory allocator
from colliding with the low 4GiB. This is achieved by
overring the default address hint in the memory map
functions used by the libSystem memory allocator.

Linking with `mmap-himem.dylib` and using the link options
in the `Makefile` allow a program to reserve from `0x1000 - 
0x7ffe00000000` (128TiB - 8GiB) which is especially useful
for user mode CPU simulators.

To build and run the example:

```
$ make test
cc -Wall -Wpedantic -c -o obj/mmap-himem.o mmap-himem.c
cc -dynamiclib \
	-install_name @rpath/mmap-himem.dylib \
	-image_base 0x7ffe80000000 \
	-o lib/mmap-himem.dylib obj/mmap-himem.o
cc -Wall -Wpedantic -c -o obj/mmap-test.o mmap-test.c
cc -o bin/mmap-test-vanilla obj/mmap-test.o
cc -Wl,-no_pie -Wl,-pagezero_size,0x1000 \
	-image_base 0x7ffe00000000 \
	-o bin/mmap-test-collision obj/mmap-test.o
cc -Wl,-no_pie -Wl,-pagezero_size,0x1000 \
	-image_base 0x7ffe00000000 \
	-rpath lib lib/mmap-himem.dylib \
	-o bin/mmap-test-himem obj/mmap-test.o

== mmap-test-vanilla ==
stak=0x7fff5053c7c8
text=0x10f6c4040
heap=0x10f6f9000
map1=0xffffffffffffffff
map2=0x7ff000000000
map3=0x10f71a000
map4=0x10f71b000

== mmap-test-collision ==
stak=0x7fff5fbff7c8
text=0x7ffe00001040
heap=0x34000
map1=0x1000
map2=0x7ff000000000
map3=0x55000
map4=0x56000

== mmap-test-himem ==
stak=0x7fff5fbff7d0
text=0x7ffe00001040
heap=0x7fff01002000
map1=0x1000
map2=0x7ff000000000
map3=0x7fff01026000
map4=0x7fff01028000
```
