/**
 * Example of using the Digilent display drivers for Zybo VGA output, with animation
 * Russell Joyce, 14/03/2017
 */

#include <stdio.h>
#include "xil_types.h"
#include "xil_cache.h"
#include "xparameters.h"
#include "zybo_vga/display_ctrl.h"


#define DISPLAY_IMAGE 1 //set to 0 for animation of square going around

#if DISPLAY_IMAGE
//for contrast enhancement
//#include "contrast_enhance/image_137x183.h"
#include "contrast_enhance/image_helpers.h"
#endif //DISPLAY_IMAGE


// Frame size (based on 1440x900 resolution, 32 bits per pixel)
//changed to 640*480
#define MAX_FRAME (640*480) // 16/10 for porch
#define FRAME_STRIDE (640*4)

DisplayCtrl dispCtrl; // Display driver struct
u32 frameBuf[DISPLAY_NUM_FRAMES][MAX_FRAME]; // Frame buffers for video data
void *pFrames[DISPLAY_NUM_FRAMES]; // Array of pointers to the frame buffers

int main(void) {
	// Initialise an array of pointers to the 2 frame buffers
	int i;
	for (i = 0; i < DISPLAY_NUM_FRAMES; i++)
		pFrames[i] = frameBuf[i];

	// Initialise the display controller
	DisplayInitialize(&dispCtrl, XPAR_AXIVDMA_0_DEVICE_ID, XPAR_VTC_0_DEVICE_ID, XPAR_VGA_AXI_DYNCLK_0_S_AXI_LITE_BASEADDR, pFrames, FRAME_STRIDE);

	// Start with the first frame buffer (of two)
	DisplayChangeFrame(&dispCtrl, 0);

	// Set the display resolution
	DisplaySetMode(&dispCtrl, &VMODE_640x480);

	// Enable video output
	DisplayStart(&dispCtrl);

	// Get parameters from display controller struct
	u32 *frame;
	u32 stride = dispCtrl.stride / 4;
	int x, y = 0;
#if !DISPLAY_IMAGE
	u32 width = dispCtrl.vMode.width;
	u32 height = dispCtrl.vMode.height;

	int right = 1;
	int down = 1;
#endif //!DISPLAY_IMAGE
	int xpos = 0;
	int ypos = 0;
	u32 buff = dispCtrl.curFrame;

	while (1) {
			// Switch the frame we're modifying to be back buffer (1 to 0, or 0 to 1)
			buff = !buff;
			frame = dispCtrl.framePtr[buff];

			// Clear the frame to white
			memset(frame, 0xFF, MAX_FRAME*4);
#if DISPLAY_IMAGE //for contrast enhancement
			add_image_to_frame((int *)frame, (unsigned char *)greyscale, xpos, ypos, stride);

#else //DISPLAY_IMAGE
			// Adjust the position of the square
			if (right) {
				xpos++;
				if (xpos == width-64)
					right = 0;
			}
			else {
				xpos--;
				if (xpos == 0)
					right = 1;
			}
			if (down) {
				ypos++;
				if (ypos == height-64) {
					down = 0;
				}
			}
			else {
				ypos--;
				if (ypos == 0) {
					down = 1;
				}
			}

			// Draw black square on the screen
			int val = 0;
			for (x = xpos; x < xpos+64; x++) {
				for (y = ypos; y < ypos+64; y++) {
					frame[y*stride + x] = (val << BIT_DISPLAY_RED) | (val << BIT_DISPLAY_BLUE) | (val << BIT_DISPLAY_GREEN);
					val++;
				}
			}

			//for (y = ypos; y < ypos+64; y++) {
			//		memset(&frame[y*stride + x + 16], 0, 64*4);
			//}

#endif //DISPLAY_IMAGE

			// Flush everything out to DDR
			Xil_DCacheFlush();

			// Switch active frame to the back buffer
			DisplayChangeFrame(&dispCtrl, buff);

			// Wait for the frame to switch (after active frame is drawn) before continuing
			DisplayWaitForSync(&dispCtrl);
	}

	return 0;
}


