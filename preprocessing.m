function varargout = preprocessing(varargin)
    % PREPROCESSING MATLAB code for preprocessing.fig
    %      PREPROCESSING, by itself, creates a new PREPROCESSING or raises the existing
    %      singleton*.
    %
    %      H = PREPROCESSING returns the handle to a new PREPROCESSING or the handle to
    %      the existing singleton*.
    %
    %      PREPROCESSING('CALLBACK',hObject,eventData,handles,...) calls the local
    %      function named CALLBACK in PREPROCESSING.M with the given input arguments.
    %
    %      PREPROCESSING('Property','Value',...) creates a new PREPROCESSING or raises the
    %      existing singleton*.  Starting from the left, property value pairs are
    %      applied to the GUI before preprocessing_OpeningFcn gets called.  An
    %      unrecognized property nameString or invalid value makes property application
    %      stop.  All inputs are passed to preprocessing_OpeningFcn via varargin.
    %
    %      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
    %      instance to run (singleton)".
    %
    % See also: GUIDE, GUIDATA, GUIHANDLES

    % Edit the above text to modify the response to help preprocessing

    % Last Modified by GUIDE v2.5 05-Nov-2019 19:30:47

    % Begin initialization code - DO NOT EDIT
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
                       'gui_Singleton',  gui_Singleton, ...
                       'gui_OpeningFcn', @preprocessing_OpeningFcn, ...
                       'gui_OutputFcn',  @preprocessing_OutputFcn, ...
                       'gui_LayoutFcn',  [] , ...
                       'gui_Callback',   []);
    if nargin && ischar(varargin{1})
        gui_State.gui_Callback = str2func(varargin{1});
    end

    if nargout
        [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
    else
        gui_mainfcn(gui_State, varargin{:});
    end
    % End initialization code - DO NOT EDIT
end

% --- Executes just before preprocessing is made visible.
function preprocessing_OpeningFcn(hObject, eventdata, handles, varargin)
    % This function has no output args, see OutputFcn.
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    % varargin   command line arguments to preprocessing (see VARARGIN)

    files = dir('data\');
    names    = {files.name};
    % Get a logical vector that tells which is a directory.
    dirFlags = [files.isdir] & ~strcmp(names, '.') & ~strcmp(names, '..');
    % Extract only those that are directories.
    subDirsNames = names(dirFlags);
    
    handles.processes = {'none','calibrate','spatial_average_3','spatial_average_5','spectral_average_3','spectral_average_5' ,'hysime'};
    % Choose default command line output for preprocessing
    handles.output = hObject;

    % Update handles structure
    set(handles.popupmenu2,'string',['Import Data' subDirsNames]);
    
    set(handles.fig3menu,'string',['Process' handles.processes]);
    set(handles.fig4menu,'string',['Process' handles.processes]);
    set(handles.fig5menu,'string',['Process' handles.processes]);
    
    bg = handles.menu1;
    set(findall(bg, '-property', 'enable'), 'enable', 'off'); % Disable options initially
    bg = handles.menu2;
    set(findall(bg, '-property', 'enable'), 'enable', 'off'); % Disable options initially
    bg = handles.menu3;
    set(findall(bg, '-property', 'enable'), 'enable', 'off'); % Disable options initially

    % UIWAIT makes preprocessing wait for user response (see UIRESUME)
    % uiwait(handles.figure1);
    guidata(hObject, handles);
end

% --- Outputs from this function are returned to the command line.
function varargout = preprocessing_OutputFcn(hObject, eventdata, handles) 
    % varargout  cell array for returning output args (see VARARGOUT);
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Get default command line output from handles structure
    varargout{1} = handles.output;
end

% --- Executes on selection change in popupmenu2.
function popupmenu2_Callback(hObject, eventdata, handles)
    % hObject    handle to popupmenu2 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Hints: contents = cellstr(get(hObject,'String')) returns popupmenu2 contents as cell array
    %        contents{get(hObject,'Value')} returns selected item from popupmenu2
    contents = cellstr(get(hObject,'String'));
    handles.current_dir = contents{get(hObject,'Value')};
    guidata(hObject,handles)
end

% --- Executes during object creation, after setting all properties.
function popupmenu2_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to popupmenu2 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    % Hint: popupmenu controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end

% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
    % hObject    handle to pushbutton1 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    try
      [DATA, dR, wR, rgbImage, nm, gtMap] = spectraExtract(handles);
      
      map = [1 1 1
          0 1 0
          1 0 0
          0 0 1
          1 1 1];
      
      handles.raw = DATA;
      handles.nm = nm;
      
      handles.dark = dR;
      
      handles.white = wR;
      
      axes(handles.axes1);
      imshow(rgbImage);
      
      axes(handles.axes6);
      imagesc(gtMap);
      colormap(map);
      caxis([0 4]);
      
      dataSize = size(DATA);
      set(handles.axes1,'UserData',{'raw',dataSize});
      set(handles.sizeString, 'String', mat2str(dataSize));
      
      set(handles.pushbutton2,'Enable','on');
      
      guidata(hObject,handles)
      
    catch ME
      errorMessage = sprintf('Error importing selected Data.\n\nError Message:\n%s', ME.message);
      fprintf(1, '%s\n', errorMessage);
      uiwait(warndlg(errorMessage));
    end
end

function [DATA,darkR,whiteR,rgbImage,nm, gtMap] = spectraExtract(handles)
    f = waitbar(0/5,'Loading Directory');
    
    directory = handles.current_dir;
    dname = ['data\' directory];
    fid  = fopen([dname '\raw.hdr'],'r','ieee-le');
    frewind(fid);
    cell = textscan(fid,'%s','delimiter','\t'); %% Reading data
    cell = vertcat(cell{:}); %% Unnesting cells

    samples = regexp(cell{3},'\d*\.?\d*$','match');
    samples = str2num(samples{:});
    lines = regexp(cell{4},'\d*\.?\d*$','match');
    lines = str2num(lines{:});
    bands = regexp(cell{5},'\d*\.?\d*$','match');
    bands = str2num(bands{:});
    rgb = regexp(cell{11},'(\d+)','match');
    
    wvstart = regexp(cell{15},'(\d+\.\d+)','match');
    wvstart = str2num(wvstart{:});
    wvend = regexp(cell{end-1},'(\d+\.\d+)','match');
    wvend = str2num(wvend{:});
    nm = [wvstart wvend];
    
    waitbar(1/5,f,'Loading Data');
    DATA = multibandread([dname '\raw'], [lines samples bands], 'uint16',0,'bil','ieee-le');
    waitbar(2/5,f,'Reading References');
    darkR = multibandread([dname '\darkReference'], [1 samples bands], 'uint16',0,'bil','ieee-le');
    whiteR = multibandread([dname '\whiteReference'], [1 samples bands], 'uint16',0,'bil','ieee-le');
    
    waitbar(3/5,f,'Extracting Image');
    rgbImage = cat(3,DATA(:,:,str2num(rgb{3})), DATA(:,:,str2num(rgb{2})), DATA(:,:,str2num(rgb{1})));
    rgbImage = uint8(rgbImage);
    
    waitbar(3/5,f,'Extracting Ground Truth');
    gtMap = multibandread([dname '\gtMap'],[lines samples 1], 'uint16',0,'bil','ieee-le');

    waitbar(5/5,f,'Completed');
    close(f)
    
end

function cdata = calibrate(raw,dark,white)
    cdata = (raw - dark)./(white - dark);
end

function w = hysimeFunc(datain)
    rdata = reshape(datain,[],size(datain,3));
    [w Rn] = estNoise(rdata');
    
end

function adata = spatial_avg(datain,row,col,len)
    average5_filter = fspecial('average',[len len]);
    adata = imfilter(datain,average5_filter);
end

function sdata = spectral_avg(datain,row,col,len)
    sdata = movmean(datain,len,3);
    sdata = sdata(:,:,[1:len:end]);
end

function selectProcess(hObject, handles, datain, func, axesnum, graphNum)
    switch func
        case 'calibrate' % Calibrate data using dark & white reference.
           cdata = calibrate(handles.current_data{graphNum},handles.dark,handles.white);
           handles.current_data{graphNum+1} = cdata;
           
           axes(axesnum);
           plot(squeeze(cdata(handles.current_col,handles.current_row,:)),'Linewidth',1)
           xend = size(datain,3);
           set(axesnum,'XLim',[0 xend],'XTick',[0 xend],'XTickLabel',{handles.nm(1),handles.nm(2)});
    
        case 'spatial_average_3' % Average window of 3x3
           adata = spatial_avg(handles.current_data{graphNum},handles.current_row,handles.current_col,3);
           handles.current_data{graphNum+1} = adata;
           row = handles.current_row;
           col = handles.current_col;
           
           axes(axesnum);
           plot(squeeze(adata(row,col,:)),'Linewidth',1)
           xend = size(adata,3);
           set(axesnum,'XLim',[0 xend],'XTick',[0 xend],'XTickLabel',{handles.nm(1),handles.nm(2)});
        
        case 'spatial_average_5' % Average window of 3x3
           adata = spatial_avg(handles.current_data{graphNum},handles.current_row,handles.current_col,5);
           handles.current_data{graphNum+1} = adata;
           row = handles.current_row;
           col = handles.current_col;
           
           axes(axesnum);
           plot(squeeze(adata(row,col,:)),'Linewidth',1)
           xend = size(adata,3);
           set(axesnum,'XLim',[0 xend],'XTick',[0 xend],'XTickLabel',{handles.nm(1),handles.nm(2)});
        
        case 'spectral_average_3'
           sdata = spectral_avg(handles.current_data{graphNum},handles.current_row,handles.current_col,3);
           handles.current_data{graphNum+1} = sdata;
           row = handles.current_row;
           col = handles.current_col;
           
           axes(axesnum);
           plot(squeeze(sdata(row,col,:)),'Linewidth',1)
           xend = size(sdata,3);
           set(axesnum,'XLim',[0 xend],'XTick',[0 xend],'XTickLabel',{handles.nm(1),handles.nm(2)});
        
        case 'spectral_average_5'
           sdata = spectral_avg(handles.current_data{graphNum},handles.current_row,handles.current_col,5);
           handles.current_data{graphNum+1} = sdata;
           row = handles.current_row;
           col = handles.current_col;
           
           axes(axesnum);
           plot(squeeze(sdata(row,col,:)),'Linewidth',1)
           xend = size(sdata,3);
           set(axesnum,'XLim',[0 xend],'XTick',[0 xend],'XTickLabel',{handles.nm(1),handles.nm(2)});
        
        case 'hysime'
            [Nx, Ny, Nb] = size(handles.current_data{graphNum});
            x = reshape(handles.current_data{graphNum}, [], Nb)';
           
            verbose = 'on';
            noise_type = 'additive';
            noise = estNoise(x,noise_type,verbose);
            hdata = x - noise;
            
            hdata = reshape(hdata, Nx, Ny, Nb); 

            handles.current_data{graphNum+1} = hdata;

            row = handles.current_row;
            col = handles.current_col;
            
            axes(axesnum);
            plot(squeeze(hdata(row,col,:)),'Linewidth',1);
            xend = size(hdata,3);
            set(axesnum,'XLim',[0 xend],'XTick',[0 xend],'XTickLabel',{handles.nm(1),handles.nm(2)});
           
        otherwise
           error('Incorrect selection');
    end
    guidata(hObject, handles);
end

% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
    % hObject    handle to pushbutton2 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    set(handles.pushbutton2,'Enable','off');
    [x,y]=ginput(1);
    row=round(x);
    col=round(y);
    disp([row col]);
    
    data = handles.raw;
    axes(handles.axes2);
    plot(squeeze(data(col,row,:)),'Linewidth',1)
    set(handles.axes2,'XLim',[0 size(data,3)],'XTick',[0 size(data,3)],'XTickLabel',{handles.nm(1),handles.nm(2)});
    
    handles.current_row = row;
    handles.current_col = col;
    
    handles.current_data{1} = data;
    
    bg = handles.menu1;
    set(findall(bg, '-property', 'enable'), 'enable', 'on');
    
    set(handles.pushbutton2,'Enable','on');
    
    guidata(hObject,handles)
end

% --- Executes on selection change in fig3menu.
function fig3menu_Callback(hObject, eventdata, handles)
% hObject    handle to fig3menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns fig3menu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from fig3menu
end

% --- Executes during object creation, after setting all properties.
function fig3menu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fig3menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

% --- Executes on button press in graph1.
function graph1_Callback(hObject, eventdata, handles)
% hObject    handle to graph1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
     
    menuContents = cellstr(get(handles.fig3menu,'String'));
    process = menuContents{get(handles.fig3menu,'Value')};
    
    selectProcess(hObject,handles,handles.raw,process,handles.axes3, 1);
    
    bg = handles.menu2;
    set(findall(bg, '-property', 'enable'), 'enable', 'on');
    
end


% --- Executes on mouse press over axes background.
function axes1_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%     userData = get(handles.axes1,'UserData');
%     handles.sizeString = mat2str(userData{2});
    disp("Axes 1 HIT");
end


% --- Executes on mouse press over axes background.
function axes2_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to axes2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
end

% --- Executes on mouse press over axes background.
function axes3_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to axes3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
end


% --- Executes on selection change in fig5menu.
function fig5menu_Callback(hObject, eventdata, handles)
% hObject    handle to fig5menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns fig5menu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from fig5menu
end

% --- Executes during object creation, after setting all properties.
function fig5menu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fig5menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

% --- Executes on button press in graph3.
function graph3_Callback(hObject, eventdata, handles)
% hObject    handle to graph3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    menuContents = cellstr(get(handles.fig5menu,'String'));
    process = menuContents{get(handles.fig5menu,'Value')};
    
    selectProcess(hObject,handles,handles.current_data,process,handles.axes5, 3);

end

% --- Executes on button press in graph2.
function graph2_Callback(hObject, eventdata, handles)
% hObject    handle to graph2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    menuContents = cellstr(get(handles.fig4menu,'String'));
    process = menuContents{get(handles.fig4menu,'Value')};
    
    selectProcess(hObject,handles,handles.current_data,process,handles.axes4, 2);
    
    bg = handles.menu3;
    set(findall(bg, '-property', 'enable'), 'enable', 'on');

end

% --- Executes on selection change in fig4menu.
function fig4menu_Callback(hObject, eventdata, handles)
% hObject    handle to fig4menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns fig4menu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from fig4menu
end

% --- Executes during object creation, after setting all properties.
function fig4menu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fig4menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


% --- Executes during object creation, after setting all properties.
function menu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to menu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
end
