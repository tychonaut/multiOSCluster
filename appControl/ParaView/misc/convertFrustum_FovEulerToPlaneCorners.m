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

javaaddpath ("D:/devel/xerces_java/xerces-2_12_1/xercesImpl.jar")
javaaddpath ("D:/devel/xerces_java/xerces-2_12_1/xml-apis.jar")

# directory of this script
file_path = fileparts(mfilename('fullpath'))


filename_in = strcat( file_path, "/openspace_sgct_config.xml")
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

  frustum_FOVEuler = struct("fov", fov, "eulerAngles", eulerAngles)
  
  frusta_FOV_Euler = [frusta_FOV_Euler, frustum_FOVEuler]
  
endfor

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------

# do the conversions :



for frustumIndex_in = 0 : numFrusta_out



  
  
  

  
endfor

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------

#create XML string by loading a Paraview .pvx file, and modify the relevant values:

filename_toMod = strcat( file_path, "/dome_arena.pvx")
## These three lines are equivalent to xDoc_in = xmlread(filename_in) in Matlab
parser_out = javaObject("org.apache.xerces.parsers.DOMParser");
parser_out.parse(filename_toMod);
xDoc_out = parser_out.getDocument();


numFrusta_out = xDoc_out.getElementsByTagName("Machine").getLength()

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
  
  LowerLeft_out = machineElem.getAttributes().getNamedItem("LowerLeft").getNodeValue()
  LowerRight_out = machineElem.getAttributes().getNamedItem("LowerRight").getNodeValue()
  UpperRight_out = machineElem.getAttributes().getNamedItem("UpperRight").getNodeValue()
  
  machineElem.getAttributes().getNamedItem("LowerLeft").setNodeValue("1 2 3")
  machineElem.getAttributes().getNamedItem("LowerRight").setNodeValue("4 5 6")
  machineElem.getAttributes().getNamedItem("UpperRight").setNodeValue("7 8 9")
  
  LowerLeft_out = machineElem.getAttributes().getNamedItem("LowerLeft").getNodeValue()
  LowerRight_out = machineElem.getAttributes().getNamedItem("LowerRight").getNodeValue()
  UpperRight_out = machineElem.getAttributes().getNamedItem("UpperRight").getNodeValue()
  #hostname = strcat("arenart", int2str(frustumIndex_in));
    
endfor 

serializer = javaObject("org.apache.xml.serialize.XMLSerializer");
strWriter  = javaObject("java.io.StringWriter");
serializer.setOutputCharStream(strWriter);
serializer.serialize(xDoc_out);
xmlString_out = strWriter.toString();

#-------------------------------------------------------------------------------
# write the XML string to file:

filename_out = strcat( file_path, "/frusta_PlaneCorners.xml");

fid = fopen (filename_out, "w");
if (fid == -1)
  error ("Unable to open file ", filename_out,"  Aborting...\n");
endif
fprintf(fid, "%s\n", xmlString_out);
fflush(fid);
fclose (fid);

#-------------------------------------------------------------------------------