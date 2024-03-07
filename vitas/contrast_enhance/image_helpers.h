//contain helper functions for contrast enhancement stuffs
#include "../zybo_vga/display_ctrl.h"
//#include "image_137x183.h"
#include "greyscale.h"

int add_image_to_frame(int* pframe, unsigned char* image, int x_start, int y_start, uint32_t stride)
{
	//copy pixel values row by row
	for(int row_index=0; row_index < GREYSCALE_HEIGHT; row_index++)
	{
		for(int col_index=0; col_index < GREYSCALE_WIDTH; col_index++)
		{
			unsigned char val = image[row_index*GREYSCALE_WIDTH+col_index];
			pframe[(row_index+y_start)*stride+x_start+col_index] = //val;
														(val << BIT_DISPLAY_RED) |
														(val << BIT_DISPLAY_BLUE) |
														(val << BIT_DISPLAY_GREEN);
		}
		//pframce[row]
		/*
		memcpy(&pframe[(row_index+y_start)*stride+x_start],
				&greyscale[row_index],
				GREYSCALE_WIDTH);
				*/
	}
	return 0;
}
