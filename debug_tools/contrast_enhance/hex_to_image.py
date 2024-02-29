'''
read hex values dumped by simulation log
can use to compare simulated values with values produced the python script
'''
import numpy
import cv2

DEBUG = 1
#adjust dimensions based on dimensions of image
#can see issues when 94x126 image used
if DEBUG:
    WIDTH  = 137
    HEIGHT = 183
else:
    WIDTH  = 47
    HEIGHT = 63
input_file = open("fpga_output.txt", "r")

image = [];
text_data = input_file.read().splitlines()
#print(type(text_data[0:10].splitlines()))

for line in text_data:
    #print(str(text_data[127]))
    
    #thing = line.strip()
    #print(line.split(" "))
    for val in line.split(" "):
        #print(val)
        #int(val.strip(),16)
        if val == '':
            continue
        image.append(int(val.strip(),16))

input_file.close()

image = numpy.array(image)

image = image.reshape((HEIGHT, WIDTH))
#print(image[0])
cv2.imwrite("recreated_img_grey.png", image)
