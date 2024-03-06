#include "demo_system.h"
#include "timer.h"

//#include "image.h"
//#include "image_47x63.h" //no issues with lower resolution
#include "image_137x183.h"

#define MASK_DIM    3
#define OFFSET      1 //offset due to 3x3 mask used for enhancement
#define DUMP_PIXELS 0
#define USE_VECT_INST 0
#define MAX_PIXEL_VAL ((1 << 8) - 1)

//pass in the 2 vectors
static inline int vect_multiply(char* vect1, char* vect2)
{
    int result = 0;
    //double check syntax to properly send instruction
    //.inst r-type (op code bits), (func3 bits), (func7 bits), %destination, %src1, %src2
    //currently instructions from lab4 (adding complex instructions)
    asm(".insn r CUSTOM_0 , 1, 0, %0, %1, %2" :
       "=r"(result) :
       "r"(vect1), "r"(vect2));
    return result;
}
#if USE_VECT_INST
static inline int test_asm(int a, int b)
{
    int res = 0;
    int count = 0;
//doesnt loop. need to figure out? or just bypass through sw?
    loop:
    asm(
         "add %[src], %[op1], %[op2] \n\t"
         //"add %[src], %[src], 1 \n\t"
         "add %[src], %[src], %[cnt] \n\t"
         "bnez %[cnt] loop"
            : [src]"=r"(res) //outputs
            : [op1]"r"(a), [op2]"r"(b), [cnt]"r"(count) //inputs 
            : "cc"
            : "loop"
            );
    //do 10(a+b)
    /*
    temp_name:
    asm goto("add %[src], %[op1], %[op2] \n\t"
        "sub %[cnt], %[cnt], 1 \n\t"
        "bnez %[cnt] \n\t"
        : [src]"=r"(res) //outputs
        : [op1]"r"(a), [op1]"r"(b), [cnt]"r"(count) //inputs
        : "" //clobber instructions
        : temp_name //goto label
        );
    */
    /*
    temp_name:
    asm goto("add %0, %1, %2 \n\t" 
        "sub %3, %3, 1 \n\t"
        "bnez %3 \n\t" :
        : "=r"(res) //outputs
        : "r"(a), "r"(b), "r"(count) //inputs
        : "" //clobber instructions
        : temp_name //goto label
        );
    */
    return res;
}
#endif //USE_VECT_INST
/*
*dumps out pixel data of the image into the log file
*Inputs:
*  grey_image: 2D array containing pixel values of a grayscale image
*              array dimensions defined in image.h
*Returns: Success (0), should only have output in the log file (if enabled)
*         might be possible to adapt to be able to dump to display
*/
int dump_img_data(char grey_image[GREYSCALE_HEIGHT][GREYSCALE_WIDTH])
{
    //puts("dumping image data: \n");
    for (uint32_t index_row=0; index_row<GREYSCALE_HEIGHT; index_row++)
    {
        for (uint32_t index_col=0; index_col<GREYSCALE_WIDTH; index_col++)
        {
            puthex(grey_image[index_row][index_col]);
            puts(" ");
        }
        puts("\n");
    }
    return 0;
}

int main(void)
{
    uint64_t start_time, end_time, elapsed = 0;
    //for some reason not being detected when used as a global
    int ENHANCEMENT_MASK[MASK_DIM][MASK_DIM] =
                                                {{0,-1,0},
                                                {-1,5,-1},
                                                {0,-1,0},};
    //puts("started\n");
    char enhanced_img[GREYSCALE_HEIGHT][GREYSCALE_WIDTH] = {{0}};

    timer_init();
    timer_enable(50000000); //clock speed (50MHz?? based on values in clk_rst_if)
    start_time = timer_read();

    for (uint32_t index_row=OFFSET; index_row<GREYSCALE_HEIGHT-1; index_row++)
    {
        for (uint32_t index_col=OFFSET; index_col<GREYSCALE_WIDTH-1; index_col++)
        {
            int new_pixel = 0;
#if USE_VECT_INST
            puthex(test_asm(7,8));
            puts("\n");
            break;
#else
            for(uint32_t mask_row=0; mask_row<MASK_DIM; mask_row++)
            {
                //puts("gettings row values for mask: ");
                for(uint32_t mask_col=0; mask_col<MASK_DIM; mask_col++)
                {
                //puthex(greyscale[index_row-OFFSET+mask_row][index_col-OFFSET+mask_col]);
                int val = greyscale[index_row-OFFSET+mask_row][index_col-OFFSET+mask_col]*ENHANCEMENT_MASK[mask_row][mask_col];
                //puthex(val);
                new_pixel += val;
                //puts(" ");
                }
                //puts("\n");
            }
            //handle underflow/overflow when storing value with 8 bits
            if (new_pixel < 0)
                new_pixel = 0;
            else if (new_pixel > MAX_PIXEL_VAL)
                new_pixel = MAX_PIXEL_VAL;
            enhanced_img[index_row][index_col] = new_pixel;
            /*
            puts("done calculating pixel value: ");
            puthex(enhanced_img[index_row][index_col]);
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
            */
#endif //USE_VECT_INST
        }
    }
    end_time = timer_read();
    elapsed = end_time-start_time;

    puts("elapsed time (hex, microseconds?): \n\t");
    puthex(elapsed >> (8*4));
    puthex(elapsed & (0xFFFFFFFF));
    puts("\n");
    //puts("complete\n");
    if (DUMP_PIXELS)
        dump_img_data(enhanced_img);
    return 0;
}