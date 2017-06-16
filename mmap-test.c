#include <stdio.h>
#include <stdlib.h>
#include <sys/mman.h>
#include <mach/vm_map.h>
#include <mach/mach_init.h>

static void* text __asm("__mh_execute_header");

int main(int argc, char **argv)
{
	void *heap = malloc(1024*128);
	free(heap);
	void *map1 = mmap((void*)0x1000, 4096, PROT_READ|PROT_WRITE, MAP_FIXED|MAP_ANON|MAP_SHARED, -1, 0);
	void *map2 = mmap((void*)0x7ff000000000UL, 4096, PROT_READ|PROT_WRITE, MAP_FIXED|MAP_ANON|MAP_SHARED, -1, 0);
	void *map3 = mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_ANON|MAP_SHARED, -1, 0);
	void *map4 = 0;
	vm_allocate(mach_task_self(), (vm_address_t*)&map4, 4096, VM_FLAGS_ANYWHERE | VM_MAKE_TAG(VM_MEMORY_MALLOC));

	printf("stak=%p\n", (void*)argv);
	printf("text=%p\n", (void*)&text);
	printf("heap=%p\n", heap);
	printf("map1=%p\n", map1);
	printf("map2=%p\n", map2);
	printf("map3=%p\n", map3);
	printf("map4=%p\n", map4);
}
