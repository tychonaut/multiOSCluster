
javaaddpath ("D:/devel/xerces_java/xerces-2_12_1/xercesImpl.jar")
javaaddpath ("D:/devel/xerces_java/xerces-2_12_1/xml-apis.jar")

file_path = fileparts(mfilename('fullpath'))

filename = strcat( file_path, "/openspace_sgct_config.xml")


## These three lines are equivalent to xDoc = xmlread(filename) in Matlab
parser = javaObject("org.apache.xerces.parsers.DOMParser");
parser.parse(filename);
xDoc = parser.getDocument();

numFrusta = xDoc.getElementsByTagName("PlanarProjection").getLength();

frusta_FoVEuler = [] ;

# skip index 0, as we are not interested in the master node
for frustumIndex = 1 : (numFrusta-1)
  
  planarProjElem = xDoc.getElementsByTagName("PlanarProjection").item(frustumIndex) ;
 
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

  frustum_FoVEuler = struct("fov", fov, "eulerAngles", eulerAngles)
  
  frusta_FoVEuler = [frusta_FoVEuler, frustum_FoVEuler]
  
endfor





#theta_degrees = 90 
#phi_degrees = 0 

#point_1 = sph2cart(theta_degrees/180*pi, phi_degrees/180*pi, 1)