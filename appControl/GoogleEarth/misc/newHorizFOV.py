import math


def deg2rad(angle_deg):
    return angle_deg * math.pi / 180


def rad2deg(angle_rad):
    return angle_rad * 180 / math.pi


# print(deg2rad(360))
# print(rad2deg(2*math.pi))


x_projector = 2560
y_projector = 1600

# height of annoying bar in pixels

#h_bar = 51
h_bar = 75

# problem: with this counted and minimal bar size, the current VIOSO frustum FOVs result in some x resolutions
# greater then projector x resolution. Hence, wie have to make the "virtual bar" even bigger!
# new x resolutions for Google Earth with h_bar=51 :
#   [2609.738702389307, 2433.309098639339, 2638.0498419671394, 2594.612109738178, 2299.784763756598]




# new y-resolution of Google Earth window:
y_GE = y_projector - 2 * h_bar
print("new y resolution for Google Earth: ", y_GE)

# per - projector vertical and horizontal FOV:
alphas_VIO = [61.0, 61.0, 53.0, 60.0, 56.0]
betas_VIO  = [46.0, 48.0, 37.0, 45.0, 44.0]


aspect_ratios_VIO = []
for i in range(0, 5):
    aspect_ratios_VIO.append(math.tan(deg2rad(alphas_VIO[i])) / math.tan(deg2rad(betas_VIO[i])))
print("aspect_ratios_VIO: ", aspect_ratios_VIO)

xs_GE = []
for i in range(0, 5):
    xs_GE.append(y_GE * aspect_ratios_VIO[i] )
print("new x resolutions for Google Earth: ", xs_GE)

fovHs_GE = []
for i in range(0, 5):
    tan_alpha = math.tan(deg2rad(alphas_VIO[i]))
    tan_beta = math.tan(deg2rad(betas_VIO[i]))
    fovH_GE = 2 * rad2deg(math.atan( y_GE / x_projector * tan_alpha * tan_alpha / tan_beta ))
    fovHs_GE.append(fovH_GE)
print("new horizontal FOV angles for Google Earth: ", fovHs_GE)


from PIL import Image, ImageDraw

im = Image.new('RGB', (x_projector, y_projector), (128, 128, 128))
draw = ImageDraw.Draw(im)

red = (255, 0, 0)
green = (0, 255, 0)
blue = (0, 64, 255)
yellow = (255, 255, 0)
magenta = (255, 0, 255)
cyan = (0, 255, 255)
colors = [red, green, blue, yellow, magenta]

draw.rectangle((0,0,1,1), outline=cyan)
draw.rectangle((1,1,1,1), outline=magenta)

for i in range(0, 5):
    top_left_x = (x_projector - xs_GE[i]) / 2
    top_left_y = (y_projector - y_GE)     / 2

    bottom_right_x = top_left_x + xs_GE[i]
    bottom_right_y = top_left_y + y_GE

    draw.rectangle(
        (
            round(top_left_x),
            round(top_left_y),
            round(bottom_right_x),
            round(bottom_right_y)
        ),
        outline=colors[i]
    )


    '''
    draw.rectangle((round((x_projector - xs_GE[i]) / 2),
                    round((y_projector - y_GE) / 2),
                    round(xs_GE[i]),
                    round(y_GE)),
                   outline=colors[i])
    '''


    # fill=(0, round((i+1) * 255/5), 0),
    # round(h_bar),

im.save('GoogleEarthAlignment.png', quality=95)

'''
fovHs_VIO = [122, 122, 106, 120, 112]
fovVs_VIO = [92, 96, 74, 90, 88]

alphas_VIO = []
betas_VIO = []
for i in range(0, 5):
    alphas_VIO.append(fovHs_VIO[i] / 2)
    betas_VIO.append(fovVs_VIO[i] / 2)

print(alphas_VIO)
print(betas_VIO)
'''



'''
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

'''