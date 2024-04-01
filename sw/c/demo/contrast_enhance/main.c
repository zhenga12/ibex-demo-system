#include "demo_system.h"
#include "timer.h"

//#include "image.h"
#include "image_47x63.h"
//#include "image_137x183.h"

#define MASK_DIM    3
#define OFFSET      1 //offset due to 3x3 mask used for enhancement
#define DUMP_PIXELS 1
#define MEASURE_TIME 0
#define MAX_PIXEL_VAL ((1 << 8) - 1)
#define PRINT_DEBUG 0

//use vector instructions that got implemented
#define USE_RTL 1
#define LOG_REG_VALS 0 //to log values being encoded for vdot

#define WIDTH 400
#define HEIGHT 600

#define SET_REG1(x)  ( ((x[4]&0xFF) << 0) | ((x[1]&0xFF) << 8) | ((x[5]&0xFF) << 16) | ((x[7]&0xFF) << 24) )
#define SET_REG2(x)  ( ((x[3]&0xFF) << 0) )
/*
*dumps out pixel data of the image into the log file
*Inputs:
*  grey_image: 2D array containing pixel values of a grayscale image
*              array dimensions defined in image.h
*Returns: Success (0), should only have output in the log file (if enabled)
*         might be possible to adapt to be able to dump to display
*/
int dump_img_data(char* grey_image, int num_rows, int num_cols)
{
    //puts("dumping image data: \n");
    for (uint32_t index_row=0; index_row<num_rows; index_row++)
    {
        for (uint32_t index_col=0; index_col<num_cols; index_col++)
        {
            puthex(grey_image[index_row*num_cols + index_col]);
            puts(" ");
        }
        puts("\n");
    }
    puts("\n");
    return 0;
}

//get window of image that matches the size of the kernel
//assumes square window
//stores result in window being passed in (1D)
uint8_t get_image_window(uint8_t* image, uint8_t* window, uint32_t window_length, uint32_t row, uint32_t col)
{
    for(uint32_t mask_row=0; mask_row<window_length; mask_row++)
    {
        //puts("gettings row values for mask: ");
        for(uint32_t mask_col=0; mask_col<window_length; mask_col++)
        {
            window[mask_row*window_length + mask_col]
                = image[(row+mask_row)*GREYSCALE_WIDTH+(col+mask_col)];
        }
    }
    return 0;
}

//apply mask
//dimensions of mask should match dimensions of window
// intended mask is one for contrast enhancement
// 0  -1  0
// -1  5  -1
// 0  -1  0
int apply_mask(int* mask, uint8_t* window, int mask_dim)
{
    int val = 0;
    //to match order that is to be done in hardware later
    val += mask[4]*window[4];
    val += mask[1]*window[1];
    val += mask[5]*window[5];
    val += mask[7]*window[7];
    val += mask[3]*window[3];
    return val;
}

int log_vdot_values(uint32_t reg1, uint32_t reg2)
{
#if LOG_REG_VALS
    puts("reg1: ");
    puthex(reg1);
    puts("\nreg2: ");
    puthex(reg2);
    puts("\n");
#endif //LOG_REG_VALS
    return 0;
}

//assembly instruction for vdot
uint32_t vdot(uint32_t a, uint32_t b) {
  uint32_t result;

  asm (".insn r CUSTOM_0, 1, 0, %0, %1, %2" :
       "=r"(result) :
       "r"(a), "r"(b));

  return result;
}

//process data to pass in as a vector for vdot
//hardcoded for now
uint8_t hardware_vdot(uint8_t* window)
{
    uint32_t reg1 = SET_REG1(window);
    uint32_t reg2 = SET_REG2(window);
    log_vdot_values(reg1, reg2);
    uint32_t res = vdot(reg1, reg2);
    return res;
}

int main(void)
{
    //puts("started\n");
    //char frame[WIDTH*HEIGHT] = {0};

    //test code to confirm functionality
    //char test_arr[MASK_DIM*MASK_DIM] = {1,2,3,4,5,6,7,8,9};
    //dump_img_data(test_arr, MASK_DIM, MASK_DIM);
    //log_vdot_values(SET_REG1(test_arr), SET_REG2(test_arr));
    //return 0;

    uint64_t start_time, end_time = 0;
    //for some reason not being detected when used as a global
    //ibex core has no heap, cannot be stored
    int ENHANCEMENT_MASK[MASK_DIM*MASK_DIM] =
                                                {0,-1,0,
                                                -1,5,-1,
                                                 0,-1,0};
    char enhanced_img[GREYSCALE_HEIGHT*GREYSCALE_WIDTH] = {0};
    timer_init();
    timer_enable(50000000); //clock speed (50MHz?? based on values in clk_rst_if)
    start_time = timer_read();
    for (uint32_t index_row=OFFSET; index_row<GREYSCALE_HEIGHT-1; index_row++)
    {
        for (uint32_t index_col=OFFSET; index_col<GREYSCALE_WIDTH-1; index_col++)
        {
            int new_pixel = 0;
            uint8_t image_window[MASK_DIM*MASK_DIM] = {0};
            get_image_window(greyscale, image_window, MASK_DIM, index_row-OFFSET, index_col-OFFSET);
            //dump_img_data(image_window, MASK_DIM, MASK_DIM);
#if USE_RTL
            new_pixel = (int) hardware_vdot(image_window);
#else //USE_RTL
            new_pixel = apply_mask(ENHANCEMENT_MASK, image_window, MASK_DIM);

            //handle underflow/overflow when storing value with 8 bits
            if (new_pixel < 0)
                new_pixel = 0;
            else if (new_pixel > MAX_PIXEL_VAL)
                new_pixel = MAX_PIXEL_VAL;
#endif
            enhanced_img[index_row*GREYSCALE_WIDTH + index_col] = new_pixel;

#if PRINT_DEBUG
            puts("done calculating pixel value: ");
            puthex(enhanced_img[index_row*GREYSCALE_WIDTH + index_col]);
            //puthex(new_pixel);
            //puthex(ENHANCEMENT_MASK[0][1]);
            puts(" (");
            puthex(index_row);
            puts(", ");
            puthex(index_col);
            puts(")\n\t");

            puts("rows done: ");
            puthex(index_row);
            puts("/");
            puthex(GREYSCALE_WIDTH);
            puts("\t cols done: ");
            puthex(index_col);
            puts("/");
            puthex(GREYSCALE_HEIGHT);
            puts("\n");
#endif //PRINT_DEBUG
        }
    }
    end_time = timer_read();

    if (MEASURE_TIME)
    {
        puts("elapsed time (hex): \n\t");
        puthex(end_time-start_time);
        puts("\n");
    }
    if (DUMP_PIXELS)
        dump_img_data(enhanced_img, GREYSCALE_HEIGHT, GREYSCALE_WIDTH);
    //puts("complete\n");

    return 0;
}