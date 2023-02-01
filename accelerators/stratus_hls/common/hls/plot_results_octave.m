#!/usr/bin/octave -qf
% Copyright (c) 2011-2023 Columbia University, System Level Design Group
% SPDX-License-Identifier: Apache-2.0
pkg load io


arg_list = argv ();
csvfile = arg_list{1};

x=csv2cell(csvfile);

r=size(x,1);
hold on;
for i = 2:r
   id = x(i,1){1};
   uarch = x(i,4){1};
   latency = x(i,6){1};
   area = x(i,5){1};

   xlabel('effective latency');
   ylabel('area');

   plot(latency, area,'marker',"*",'color','r','markersize',10);
   text (latency, area, uarch, 'VerticalAlignment','bottom', 'HorizontalAlignment','center')
end
pause()
