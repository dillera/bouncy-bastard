#include <stdint.h>
#include <apple2.h>

void pause(uint8_t count)
{
	/* Simple delay loop - approximately 50ms per count */
	uint16_t i, j;
	for (i = 0; i < count; i++)
		for (j = 0; j < 1000; j++)
			;
};
