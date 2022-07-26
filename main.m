function varargout = main(varargin)
% MAIN MATLAB code for main.fig
%      MAIN, by itself, creates a new MAIN or raises the existing
%      singleton*.
%
%      H = MAIN returns the handle to a new MAIN or the handle to
%      the existing singleton*.
%
%      MAIN('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MAIN.M with the given input arguments.
%
%      MAIN('Property','Value',...) creates a new MAIN or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before main_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to main_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help main

% Last Modified by GUIDE v2.5 06-May-2021 18:17:14

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @main_OpeningFcn, ...
                   'gui_OutputFcn',  @main_OutputFcn, ...
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


% --- Executes just before main is made visible.
function main_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to main (see VARARGIN)

% Choose default command line output for main
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes main wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = main_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in togglebutton1.
function togglebutton1_Callback(hObject, eventdata, handles)
    it=1;
    clc
    disNeuronas=0;
    
    Uo=str2double(get(handles.edit2,'String'));
    T2=str2double(get(handles.edit3,'String'));
    NCiudades=str2double(get(handles.edit4,'String'));
    
    T1=str2double(get(handles.edit5,'String'));
    
    x0=str2double(get(handles.edit6,'String'));
    y0=str2double(get(handles.edit7,'String'));
    xf=str2double(get(handles.edit8,'String'));
    yf=str2double(get(handles.edit9,'String'));
    
    Po=[x0; y0];
    Pf=[xf; yf];
    
    Nneuronas=3*NCiudades;
    So=Nneuronas;
    
    if T1 == 0 
        T1=1000/log(So);
    end
    
    W=rand(2, Nneuronas);
    W(1,:)=rescale(W(1, :), 0, 15);
    W(2,:)=rescale(W(2, :), 0, 5);

    W(:, 1)=Po;
    W(:, Nneuronas)=Pf;
    
    if get(handles.radiobutton1,'Value')
        Xx=rescale(rand(1, NCiudades), 0, 15);
        Xy=rescale(rand(1, NCiudades), 0, 5);
        X=[Xx; Xy];
    end
    
    if get(handles.radiobutton2,'Value')
        % define maximum number of allowable mouse clicks to avoid infinite loop
        % and also to preallocate array to hold click data
        maxPoints = NCiudades;

        % define plot limits so it doesn't keep rescaling which might be confusing
        xLimits = [0 500];
        yLimits = [0 100];

        % open new blank figure with defined limits
        figure('Name','Marque su primera clase');
        xlim(xLimits)
        ylim(yLimits)
        hold on

        %

        % instruct user on how to enter points and how to terminate
        disp('Click the mouse wherever in the figure; press ENTER when finished.');

        % preallocate array to hold mouse click coordinates
        mousePointCoords = zeros(maxPoints,2);

        % set up loop to collect and display mouse click points
        count = 0;
        for k = 1:maxPoints
            % get the mouse click point, or terminate if user presses enter
            %  in which case the coordinates will be returned empty
            coords = ginput(1);
            if isempty(coords)
                break
            end

            count = count + 1;
            mousePointCoords(count,:) = coords;
            plot(coords(:,1),coords(:,2),'o','MarkerSize',8);


        end
        % clean up
        hold off
        mousePointCoords = mousePointCoords(1:count,:); % trim off unused array

        X1=mousePointCoords(:,1);

        % define maximum number of allowable mouse clicks to avoid infinite loop
        % and also to preallocate array to hold click data
        close 

        mousePointCoords = mousePointCoords(1:count,:); % trim off unused array

        % display results
        disp(mousePointCoords)

        X=mousePointCoords'; %Filas NCiudaddes Columnas: (x y)
    end
    
    if get(handles.radiobutton3,'Value')
        pre_pos_x=evalin('base','pre_pos_x');
        pre_pos_y=evalin('base','pre_pos_y');
        X=[pre_pos_x'; pre_pos_y'];
    end
    
    X=horzcat(Po, X);
    X=horzcat(X, Pf)
    
    set(handles.uitable1, 'Data', X')
    
    Ganador=zeros(2, NCiudades);
    
    dxw=zeros(2, Nneuronas);
    
    D=zeros(1, Nneuronas);
    d=zeros(1, Nneuronas); 
    
while get(handles.togglebutton1, 'value')
    
    S=So*exp(-(it/T1));
    U=Uo*exp(-(it/T2));

    for k=1:NCiudades+2

        D=sqrt((W(1, :)-X(1, k)).^2+(W(2, :)-X(2, k)).^2);
        [Ganador(1, k), Ganador(2, k)] = min(D);
                
        for i=1:Nneuronas
                d(i)=abs(Ganador(2, k)-i);
                     
                h=exp(-(d(i)^2/(2*S^2)));   %Puede guardarse h(i, j)
                dxw(1, i)=X(1, k)-W(1, i);
                dxw(2, i)=X(2, k)-W(2, i);
                
                if i~=1 && i~=Nneuronas
                    W(1, i)=W(1, i)+(U*h*dxw(1, i));     
                    W(2, i)=W(2, i)+(U*h*dxw(2, i));
                end
        end
 
    end
    
    disNeuronas(it)=sqrt(sum(W(1, :).^2)+sum(W(2, :).^2));
    
    cla (handles.axes1)
    cla (handles.axes2)
    plot(handles.axes1, X(1, :), X(2, :), 'x', W(1, :), W(2, :), 'o', W(1, :), W(2, :))
    hold on
    plot(handles.axes2, disNeuronas)
    drawnow limitrate
    %pause(1e-999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999)
    
    it=it+1;
end

Wn=[];
Xn=X;

for k=1:NCiudades+2
    D=sqrt((W(1, :)-Xn(1, k)).^2+(W(2, :)-Xn(2, k)).^2);
    [Ganador(1, k), Ganador(2, k)] = min(D);
    Wn=horzcat(Wn, W(: , Ganador(2, k)));
end

Wn2=[]
for k=1:Nneuronas
    for r=1:NCiudades+2
        if Wn(:,r)==W(:,k)
            Wn2=horzcat(Wn2, Wn(:, r));
        end
    end
end
Wn2

cla (handles.axes1)  
plot(handles.axes1, X(1, :), X(2, :), 'x', Wn2(1, :), Wn2(2, :), 'o', Wn2(1, :), Wn2(2, :))

assignin('base','x_kohonen', Wn2(1,:));
assignin('base','y_kohonen', Wn2(2,:));




function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double


% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double


% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit4_Callback(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit4 as text
%        str2double(get(hObject,'String')) returns contents of edit4 as a double


% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit5_Callback(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit5 as text
%        str2double(get(hObject,'String')) returns contents of edit5 as a double


% --- Executes during object creation, after setting all properties.
function edit5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit6_Callback(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit6 as text
%        str2double(get(hObject,'String')) returns contents of edit6 as a double


% --- Executes during object creation, after setting all properties.
function edit6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit7_Callback(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit7 as text
%        str2double(get(hObject,'String')) returns contents of edit7 as a double


% --- Executes during object creation, after setting all properties.
function edit7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit8_Callback(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit8 as text
%        str2double(get(hObject,'String')) returns contents of edit8 as a double


% --- Executes during object creation, after setting all properties.
function edit8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit9_Callback(hObject, eventdata, handles)
% hObject    handle to edit9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit9 as text
%        str2double(get(hObject,'String')) returns contents of edit9 as a double


% --- Executes during object creation, after setting all properties.
function edit9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in radiobutton1.
function radiobutton1_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton1


% --- Executes on button press in radiobutton2.
function radiobutton2_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton2


% --- Executes on button press in radiobutton3.
function radiobutton3_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton3
