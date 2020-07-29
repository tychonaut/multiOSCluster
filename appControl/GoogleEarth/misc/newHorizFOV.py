import math


fovHs_VIO= [ 122, 122, 106, 120, 112 ]
#fovVs_VIO= [ 46, 48, 37, 45, 44 ]
fovVs_VIO= [ 92, 96, 74, 90, 88 ]

a = 2560

# height of the annoying toolbar in pixels
barSize = 51
#double the bar size because of the awful virtual aspect ratio of RT5:
# only then the new aspect ratio can be implemented respecting the quad bars
#(double top, double down), i.e. y resoultio is < 1600-2*51=1498 pixel
#barSize *= 2 <-- no hope, as GE can no custom aspect ratio :@

fovHs_new = []
resolutionYaxes_VIO = []

resolutionXaxes_new = []
resolutionYaxes_new = []

rectangleStarts = []

#for fovH_VIO in fovHs_VIO:
for i in range(0,5):
    
    fovH_VIO_2 = fovHs_VIO[i] / 2
    fovV_VIO_2 = fovVs_VIO[i] / 2

    #b = 1600
    b = a * math.tan(fovV_VIO_2/180*math.pi) / math.tan(fovH_VIO_2/180*math.pi) 
    print("vertical pixel count: ", b)
    resolutionYaxes_VIO.append(b)

    aspectRatio= a/b
    print("aspect ratio expected by VIOSO: ", aspectRatio)
       

    
    d = barSize*aspectRatio


    
    fovH_new = 2 *  math.atan( (1- 2*d/a) * math.tan(fovH_VIO_2/180*math.pi) ) * 180/math.pi
    print("fovH_new: ", fovH_new )

    print()
    fovHs_new.append(fovH_new)

    newXRes = (a - 2*d)
    resolutionXaxes_new.append(newXRes)

    newYRes = newXRes / aspectRatio
    resolutionYaxes_new.append(newYRes)

print("new horizontal FOVs:")
print(fovHs_new)
print("new horizontal resolutions:")
print(resolutionXaxes_new)
print("new vertical resolutions:")
print(resolutionYaxes_new)

