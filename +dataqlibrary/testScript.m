function data_table = get_dataq_data(varargin)

%C:\Users\azim\documents\visual studio 2013\Projects\dataq_library\dataq_library\
parse = inputParser;


netAssembly=which('dataq_library.dll'); %
NET.addAssembly(netAssembly)
obj=dataq_library.dataq;
obj.testsum(1,2)


%%
pn = uigetdir
ff=dir(fullfile(pn,'*.wdq'));
obj.fileName=fullfile(ff(1).folder,ff(1).name);
dat=obj.readMarkerData(2);
dat2=double(dat);
%dat2=reshape(dat2,5,[]);

plot(dat2(1:5:end,:))
