'''
Generates greyscale image and performs contrast enhancement
'''
import cv2 as cv
import numpy

IMAGE_PATH = "roof-balloons.jpg"
numpy.set_printoptions(threshold=numpy.inf)
#now fine at 20 //nvm cutoff at some point, 25 - 22 is good
SCALE_FACTOR = 22 #no issues on simulation when set to 64
ENHANCEMENT_MASK = [[0, -1, 0],
                    [-1, 5, -1],
                    [0, -1, 0]]
WRITE_TO_FILE = 1

def to_text(img, filename="default_name.txt", format=None):
    txt_file = open(filename, 'w')

    #for copying to header file
    txt_file.write(f"#define GREYSCALE_WIDTH  {base_height}\n")
    txt_file.write(f"#define GREYSCALE_HEIGHT {base_width}\n")
    txt_file.write("unsigned char greyscale[GREYSCALE_HEIGHT][GREYSCALE_WIDTH] = \n")

    txt_file.write("{")
    #row = img.shape[0]
    #col = img.shape[1]
    
    for row in range(img.shape[0]):
        txt_file.write("{")
        for col in range(img.shape[1]):
            if format == "hex":
                txt_file.write(str(hex(img[row][col]))+", ")
            else:
                txt_file.write(str(img[row][col])+", ")
        txt_file.write("},")
        txt_file.write("\n")
    txt_file.write("};")
    #txt_file.write(numpy.array2string(img))
    txt_file.close()

base_img = cv.imread(IMAGE_PATH)
greyscale = cv.cvtColor(base_img, cv.COLOR_BGR2GRAY)
base_width = greyscale.shape[0]
base_height = greyscale.shape[1]
new_dim = (int(base_height/SCALE_FACTOR), int(base_width/SCALE_FACTOR))
#print(f"{base_width} x {base_height}")
greyscale = cv.resize(greyscale, new_dim)
base_width = greyscale.shape[0]
base_height = greyscale.shape[1]
print(f"{base_width} x {base_height}")

cv.imwrite("greyscale_image.png", greyscale)
print(numpy.max(greyscale))
enhanced = numpy.zeros((base_width, base_height),dtype=(numpy.int32))
#enhanced = numpy.zeros((base_width, base_height))

for row in range(1,base_width-1):
    for col in range(1,base_height-1):
        new_val = numpy.vdot(greyscale[row-1:row+2,col-1:col+2], 
                             ENHANCEMENT_MASK)
        if new_val < 0: new_val = 0
        enhanced[row][col] = new_val

cv.imwrite("greyscale_enhance.png", enhanced)

if WRITE_TO_FILE:
    to_text(greyscale, "greyscale.txt")
    to_text(enhanced, "greyscale_enhanced.txt")
    to_text(enhanced, "greyscale_enhanced_hex.txt", "hex")

