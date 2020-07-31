import math
from PIL import Image, ImageDraw


def deg2rad(angle_deg):
    return angle_deg * math.pi / 180


def rad2deg(angle_rad):
    return angle_rad * 180 / math.pi


def tan_degree(angle_deg):
    return math.tan(deg2rad(angle_deg))


def atan_degree(tan_of_angle):
    return rad2deg(math.atan(tan_of_angle))


def draw_alignment_rectangles(resolution_projector_x, resolution_projector_y, resolutions_GE_x, resolutions_GE_y):
    im = Image.new('RGB', (resolution_projector_x, resolution_projector_y), (128, 128, 128))
    draw = ImageDraw.Draw(im)

    # RT1 is red
    red = (255, 0, 0)
    # RT2 is green
    green = (0, 255, 0)
    # RT3 is blue
    blue = (0, 64, 255)
    # RT4 is yellow
    yellow = (255, 255, 0)
    # RT5 is magenta
    magenta = (255, 0, 255)
    #cyan = (0, 255, 255)
    colors = [red, green, blue, yellow, magenta]

    for idx in range(0, 5):
        top_left_x = (resolution_projector_x - resolutions_GE_x[idx]) / 2
        top_left_y = (resolution_projector_y - resolutions_GE_y[idx]) / 2

        bottom_right_x = top_left_x + resolutions_GE_x[idx]
        bottom_right_y = top_left_y + resolutions_GE_y[idx]

        draw.rectangle(
            (
                round(top_left_x),
                round(top_left_y),
                round(bottom_right_x),
                round(bottom_right_y)
            ),
            outline=colors[idx]
        )

    im.save('GoogleEarthAlignment2.png', quality=95)


# ----------------------------------------------------------------------------------------------------------------------
x_projector = 2560
y_projector = 1600

num_projectors = 5

print("per - projector vertical and horizontal FOV from VIOSO calibration (half angles in degrees!):")
alphas_VIO_deg = [61.0, 61.0, 53.0, 60.0, 56.0]
betas_VIO_deg  = [46.0, 48.0, 37.0, 45.0, 44.0]
print("horiz.: ", alphas_VIO_deg)
print("vert.: ", betas_VIO_deg)

# ----------------------------------------------------------------------------------------------------------------------
# constant to be found by trial & error to fit the final rendering into the projector resolutions
# respecting the VIOSO aspect ratio and Google Earth's 51 pixels of fulllscren+non-fullscreen-menu-bars
# 130 is found to yield the  max. y resolution is of 1600-2*51=1498 pixels
c_x = 130

x_GE = x_projector - (2 * c_x)
x_GEs = [x_GE, x_GE, x_GE, x_GE, x_GE]
print("new x resolutions of GE renderings: ", x_GEs)

# ----------------------------------------------------------------------------------------------------------------------
# new horizontal FoVs in degrees:
alphas_GE_rad = []
alphas_GE_deg = []
fovHs_GE_deg = []
for i in range(0, num_projectors):
    alpha_GE_rad = math.atan(x_GEs[i] * tan_degree(alphas_VIO_deg[i]) / x_projector)
    alphas_GE_rad.append(alpha_GE_rad)
    alphas_GE_deg.append(rad2deg(alpha_GE_rad))
    fovHs_GE_deg.append(2 * alphas_GE_deg[i])
print("alphas_GE in radians: ", alpha_GE_rad)
print("alphas_GE in degrees: ", alphas_GE_deg)
print("new horizontal FoVs in degrees: PUT THIS INTO drivers.ini -> ViewSync/horizFov !")
print(fovHs_GE_deg)



# ----------------------------------------------------------------------------------------------------------------------
# # new vertical FoVs in degrees  respecting the aspect ratio conditions:
# # aspectRatio_angles_VIO = aspectRatio_angles_GE
betas_GE_deg = []
for i in range(0, num_projectors):
    tan_beta_GE_deg = tan_degree(alphas_GE_deg[i]) * tan_degree(betas_VIO_deg[i]) / tan_degree(alphas_VIO_deg[i])
    beta_GE_deg = atan_degree(tan_beta_GE_deg)
    betas_GE_deg.append(beta_GE_deg)
print("new horizontal FoVs (half angles) in degrees: ", betas_GE_deg)

# ----------------------------------------------------------------------------------------------------------------------
# sanity checks: aspect ratios
# derived from VIOSO angles:
aspectRatio_angles_VIO = []
for i in range(0, num_projectors):
    aspectRatio_angles_VIO.append(tan_degree(alphas_VIO_deg[i]) / tan_degree(betas_VIO_deg[i]))
print("aspect ratio of FoV angles from VIOSO calibration: ")
print(aspectRatio_angles_VIO)
# from calculated GE angles:
aspectRatio_angles_GE = []
for i in range(0, num_projectors):
    aspectRatio_angles_GE.append(tan_degree(alphas_GE_deg[i]) / tan_degree(betas_GE_deg[i]))
print("new aspect ratio of FoV angles, must be equal to those of VIOSO  calibration: ")
print(aspectRatio_angles_GE)



# ----------------------------------------------------------------------------------------------------------------------
# y resolutions respecting the aspect ratio conditions:
# aspectRatio_angles_VIO =  aspectRatio_angles_GE
y_GEs = []
for i in range(0, num_projectors):
    y_GE = x_projector / tan_degree(alphas_VIO_deg[i]) * tan_degree(betas_GE_deg[i])
    y_GEs.append(y_GE)
print("new y resolutions of GE renderings: ", y_GEs)


# ----------------------------------------------------------------------------------------------------------------------
aspectRatio_res_GE = []
for i in range(0, num_projectors):
    aspectRatio_res_GE.append(x_GEs[i] / y_GEs[i])
print("new aspect ratio of resolutions angles:")
print(aspectRatio_res_GE)


draw_alignment_rectangles(x_projector, y_projector, x_GEs, y_GEs)

exit(0)


#-----------------------------------------------------------------------------------
# #stuff that didns have the desired effect:

# height of annoying bar in pixels
#h_bar = 51
h_bar = 75

# problem: with this counted and minimal bar size, the current VIOSO frustum FOVs result in some x resolutions
# greater then projector x resolution. Hence, wie have to make the "virtual bar" even bigger!
# new x resolutions for Google Earth with h_bar=51 :
#   [2609.738702389307, 2433.309098639339, 2638.0498419671394, 2594.612109738178, 2299.784763756598]


# new y-resolution of Google Earth window:
y_GE = y_projector - 2 * h_bar
ys_GE = [y_GE, y_GE, y_GE, y_GE, y_GE]
print("new y resolution for Google Earth: ", y_GE)


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
    fovH_GE = 2 * rad2deg(math.atan(y_GE / x_projector * tan_alpha * tan_alpha / tan_beta))
    fovHs_GE.append(fovH_GE)
print("new horizontal FOV angles for Google Earth: ", fovHs_GE)

draw_alignment_rectangles(x_projector, y_projector, xs_GE, ys_GE)













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