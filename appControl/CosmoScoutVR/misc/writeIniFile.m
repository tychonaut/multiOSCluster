function Result = writeIniFile(fileName, iniStructure)

  Result = -1;

  fid = fopen (fileName, "w");

  for [categoryVariable, categoryName] = iniStructure

    fprintf(fid, "[%s]\n", categoryName);

    for [value, key] = categoryVariable
      fprintf(fid, "%s = %s\n", key, value);
    endfor
    
  endfor

  fflush(fid);
  fclose (fid);
  
  Result = 0;
  
endfunction
