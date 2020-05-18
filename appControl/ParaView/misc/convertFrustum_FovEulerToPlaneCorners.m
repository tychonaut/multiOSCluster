# Script to parse view frustum data from an xml file
# (an SGCT config file used in OpenSpace, to pe precise.),
# converts them vom FOV+EulerAngles(YawPitchRoll/YXZ) representation
# to "3 corners of the projection plane" representation.
# The result is written into another xml file
# (a ParaView .pvx file).
#
# Input is assumed to be in the order: arenamaster, arenart1 .. arenart5.
# Input Output can have any order, but is assumed to contain 
# Elements of type <Machine Name="arenart<n>" > Elements, n in 1..5

#-------------------------------------------------------------------------------
pkg load matgeom
#pkg load linear-algebra


javaaddpath ("D:/devel/xerces_java/xerces-2_12_1/xercesImpl.jar")
javaaddpath ("D:/devel/xerces_java/xerces-2_12_1/xml-apis.jar")

# directory of this script
file_path = fileparts(mfilename('fullpath'))


filename_in = strcat( file_path, "/frusta_FOVEulerAngles_in.xml")
## These three lines are equivalent to xDoc_in = xmlread(filename_in) in Matlab
parser_in = javaObject("org.apache.xerces.parsers.DOMParser");
parser_in.parse(filename_in);
xDoc_in = parser_in.getDocument();

numFrusta_in = xDoc_in.getElementsByTagName("PlanarProjection").getLength();

frusta_FOV_Euler = [] ;

# skip index 0, as we are not interested in the master node
for frustumIndex = 1 : (numFrusta_in-1)
  
  planarProjElem = xDoc_in.getElementsByTagName("PlanarProjection").item(frustumIndex);
 
  childNodes = planarProjElem.getChildNodes();

  
   fov = struct ( "up", 10, "down", 20, "left", 30, "right", 40 ) ;
   eulerAngles = struct ( "yaw", 0, "pitch", 0 , "roll", 0) ;
  
  for childIndex = 0 : (childNodes.getLength() - 1)
      
    childNode = childNodes.item(childIndex);
      
    if(strcmp(childNode.getNodeName(), "FOV"))
      
      fovAttribs = childNode.getAttributes();
      
      fov = struct ( 
        "up",     fovAttribs.getNamedItem("up").getNodeValue(),
        "down",   fovAttribs.getNamedItem("down").getNodeValue(),
        "left",   fovAttribs.getNamedItem("left").getNodeValue(),
        "right",  fovAttribs.getNamedItem("right").getNodeValue()
      )
      
    endif
    
    if(strcmp(childNode.getNodeName(), "Orientation"))
    
      dirAttribs = childNode.getAttributes();
      
      eulerAngles = struct (
        "yaw",    dirAttribs.getNamedItem("heading").getNodeValue(),
        "pitch",  dirAttribs.getNamedItem("pitch").getNodeValue(),
        "roll",   dirAttribs.getNamedItem("roll").getNodeValue()
      )
      
    endif
    
  endfor

  frustum_FOV_Euler = struct("fov", fov, "eulerAngles", eulerAngles);
  
  frusta_FOV_Euler = [frusta_FOV_Euler, frustum_FOV_Euler];
  
endfor

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------

# do the conversions :


frusta_planeCorners = [];
for frustumIndex_in = 1 : numel(frusta_FOV_Euler)
 
  printf("frustum #: %d\n", frustumIndex_in)
 
  fovU = deg2rad(str2double(frusta_FOV_Euler(frustumIndex_in).fov.up));
  fovD = deg2rad(str2double(frusta_FOV_Euler(frustumIndex_in).fov.down));
  fovL = deg2rad(str2double(frusta_FOV_Euler(frustumIndex_in).fov.left));
  fovR = deg2rad(str2double(frusta_FOV_Euler(frustumIndex_in).fov.right));

  ll = [ -tan(fovL), -tan(fovD), -1.0]' ;
  lr = [  tan(fovR), -tan(fovD), -1.0]' ;
  ur = [  tan(fovR),  tan(fovU), -1.0]' ;
  
  #yaw pitch roll -> rotate about y,x,z
  yaw =   deg2rad(str2double(frusta_FOV_Euler(frustumIndex_in).eulerAngles.yaw));
  pitch = deg2rad(str2double(frusta_FOV_Euler(frustumIndex_in).eulerAngles.pitch));
  roll =  deg2rad(str2double(frusta_FOV_Euler(frustumIndex_in).eulerAngles.roll));
  
  yawMat   = createRotationOy( yaw );
  pitchMat = createRotationOx( pitch );
  rollMat  = createRotationOz( roll );
  
  rotationMat = rollMat * pitchMat * yawMat;
  rotationMat = rotationMat(1:3,1:3) 
  
  planeCorners = struct(
    "LowerLeft",  rotationMat * ll,
    "LowerRight", rotationMat * lr,
    "UpperRight", rotationMat * ur
  )
  
  frusta_planeCorners = [frusta_planeCorners, planeCorners];
  
endfor


#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------

#create XML string by loading a Paraview .pvx file, and modify the relevant values:

filename_toMod = strcat( file_path, "/frusta_PlaneCorners_CAVE_template.pvx");
## These three lines are equivalent to xDoc_in = xmlread(filename_in) in Matlab
parser_out = javaObject("org.apache.xerces.parsers.DOMParser");
parser_out.parse(filename_toMod);
xDoc_out = parser_out.getDocument();


numFrusta_out = xDoc_out.getElementsByTagName("Machine").getLength();

if(numel(frusta_FOV_Euler) != numFrusta_out)
 error("in/out frustum count do not match!")
endif

for frustumIndex_out = 0 : (numFrusta_out -1 )
  
  machineElem = xDoc_out.getElementsByTagName("Machine").item(frustumIndex_out);
  
  hostname = machineElem.getAttributes().getNamedItem("Name").getNodeValue()
  # As be cannot rely on the order of the data thx .pvx file,
  # and as machine names are only available as attributes,
  # we have to extract the index: "arenart" are 7 digits.
  hostIndex= str2num( hostname(8))
  
  planeCorners =  frusta_planeCorners(hostIndex);
  LowerLeft_string  = num2str( planeCorners.LowerLeft' )
  LowerRight_string = num2str( planeCorners.LowerRight' )
  UpperRight_string = num2str( planeCorners.UpperRight' )
  
  #TODO
  
  #LowerLeft_out = machineElem.getAttributes().getNamedItem("LowerLeft").getNodeValue()
  #LowerRight_out = machineElem.getAttributes().getNamedItem("LowerRight").getNodeValue()
  #UpperRight_out = machineElem.getAttributes().getNamedItem("UpperRight").getNodeValue()
  
  machineElem.getAttributes().getNamedItem("LowerLeft").setNodeValue(LowerLeft_string);
  machineElem.getAttributes().getNamedItem("LowerRight").setNodeValue(LowerRight_string);
  machineElem.getAttributes().getNamedItem("UpperRight").setNodeValue(UpperRight_string);
  
  #LowerLeft_out = machineElem.getAttributes().getNamedItem("LowerLeft").getNodeValue()
  #LowerRight_out = machineElem.getAttributes().getNamedItem("LowerRight").getNodeValue()
  #UpperRight_out = machineElem.getAttributes().getNamedItem("UpperRight").getNodeValue()
  #hostname = strcat("arenart", int2str(frustumIndex_in));
    
endfor 

serializer = javaObject("org.apache.xml.serialize.XMLSerializer");
strWriter  = javaObject("java.io.StringWriter");
serializer.setOutputCharStream(strWriter);
serializer.serialize(xDoc_out);
xmlString_out = strWriter.toString();

#-------------------------------------------------------------------------------
# write the XML string to file:

filename_out = strcat( file_path, "/frusta_PlaneCorners_dome_out.pvx");

fid = fopen (filename_out, "w");
if (fid == -1)
  error ("Unable to open file ", filename_out,"  Aborting...\n");
endif
fprintf(fid, "%s\n", xmlString_out);
fflush(fid);
fclose (fid);

#-------------------------------------------------------------------------------