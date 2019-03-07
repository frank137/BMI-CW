f = figure;
max_k = 96;
k = 1;

PSTHoverall(trial,50,1,k)
while k<96
k = set(f,'WindowKeyPressFcn',@keyPressCallback);
 PSTHoverall(trial,50,1,k)
 
  
end

 function k = keyPressCallback(source,eventdata)
      % determine the key that was pressed
      keyPressed = eventdata.Key;
      if strcmpi(keyPressed,'rightarrow')
          k = k+1;
      elseif strcmpi(keyPressed,'leftarrow')
          k = k-1;
          
          
      end
  end