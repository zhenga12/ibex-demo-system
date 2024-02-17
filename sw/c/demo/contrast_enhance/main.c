#include "demo_system.h"
#include "timer.h"

//#include "image.h" //only top third of the image gets properly produced
#include "image_47x63.h" //no issues with lower resolution

#define MASK_DIM    3
#define OFFSET      1 //offset due to 3x3 mask used for enhancement
#define DUMP_PIXELS 1

/*
*dumps out pixel data of the image into the log file
*Inputs:
*  grey_image: 2D array containing pixel values of a grayscale image
*              array dimensions defined in image.h
*Returns: Success (0), should only have output in the log file (if enabled)
*         might be possible to adapt to be able to dump to display
*/
int dump_img_data(uint32_t grey_image[GREYSCALE_HEIGHT][GREYSCALE_WIDTH])
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
    //for some reason not being detected when used as a global
    int ENHANCEMENT_MASK[MASK_DIM][MASK_DIM] =
                                                {{0,-1,0},
                                                {-1,5,-1},
                                                {0,-1,0},};
    puts("started\n");
    uint32_t enhanced_img[GREYSCALE_HEIGHT][GREYSCALE_WIDTH] = {{0}};
    for (uint32_t index_row=OFFSET; index_row<GREYSCALE_HEIGHT-1; index_row++)
    {
        for (uint32_t index_col=OFFSET; index_col<GREYSCALE_WIDTH-1; index_col++)
        {
            int new_pixel = 0;
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

            if (new_pixel < 0)
                new_pixel = 0;
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

        }
    }
    //puts("complete\n");
    if (DUMP_PIXELS)
        dump_img_data(enhanced_img);
    return 0;
}