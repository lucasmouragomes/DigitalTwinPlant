function varargout = DigitalTwinPlanta(varargin)
%DIGITALTWINPLANTA MATLAB code file for DigitalTwinPlanta.fig
%
%
%
%
%
%
%
%

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @DigitalTwinPlanta_OpeningFcn, ...
                   'gui_OutputFcn',  @DigitalTwinPlanta_OutputFcn, ...
                   'gui_LayoutFcn',  [], ...
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


% --- Executes just before DigitalTwinPlanta is made visible.
function DigitalTwinPlanta_OpeningFcn(hObject, eventdata, handles, varargin)
    handles.output = hObject;
    guidata(hObject, handles);


% --- Outputs from this function are returned to the command line.
function varargout = DigitalTwinPlanta_OutputFcn(hObject, eventdata, handles)
    varargout{1} = handles.output;


% --- Executes on buttonStart press in buttonStart.
function buttonStart_Callback(hObject, eventdata, handles)

    global stop
    global erroAtual
    global erroAnterior
    global somaErro
    stop = 1;
    erroAtual = 0;
    erroAnterior = 0;
    somaErro = 0;

    %% Configurações do OPC ===============================================
    % Global variables
    global server
    % Connect to OPC Server
    server = opcda('localhost', 'Matrikon.OPC.Simulation.1');
    connect(server)

    % Create an OPC Data Acess Group Object Set Up
    grpSetUp = addgroup(server);

    % Add OPC Data Acess Items to the Group Set Up
    global itemsSetUP
    itemsSetUP = additem(grpSetUp, {'Bucket Brigade.Boolean',
                                    'Random.Boolean',
                                    'Square Waves.Boolean'}, {'single','single','single'});

    % Read OPC Data Acess Items to the Group
    global Reset LigaInv1 LigaInv2

    % Create an OPC Data Acess Group Object
    grpBomba = addgroup(server);

    % Add OPC Data Acess Items to the Group
    global itemsBombas
    itemsBombas = additem(grpBomba, {'Saw-toothed Waves.Int1',
                                     'Saw-toothed Waves.Int2'}, {'single','single'});

    % Read OPC Data Acess Items to the Group
    global Bomba1 Bomba2

    % Create an OPC Data Acess Group Object
    grpNivel = addgroup(server);

    % Add OPC Data Acess Items to the Group
    global itemsNiveis
    itemsNiveis = additem(grpNivel, {'Square Waves.Int1',
                                     'Square Waves.Int2',
                                     'Triangle Waves.UInt1',
                                     'Triangle Waves.UInt2'}, {'single','single','single','single'});

    % Read OPC Data Acess Items to the Group
    global PTQ1_corrigido PTQ2_corrigido PTQ3_corrigido PTQ4_corrigido

    % Create an OPC Data Acess Group Object
    grpValvula = addgroup(server);

    % Add OPC Data Acess Items to the Group
    global itemsValvula
    itemsValvula = additem(grpValvula, {'Saw-toothed Waves.Real4',
                                        'Saw-toothed Waves.Real8',
                                        'Triangle Waves.Int1',
                                        'Triangle Waves.Int2'}, {'single','single','single','single'});
   
    disp('START pressed')
    
    x(1:1000) = 0;
    
    saida = 0;
    sp = 0;
    kp = 0;
    ki = 0;
    kd = 0;
    
    Val1 = 0;
    Val2 = 0;
    Val3 = 0;
    Val4 = 0;
    
    i = 0;
    
    while stop

        % Leitura e Envio dos valores para supervisão ====================
        Reset = read(itemsSetUP(1));
        LigaInv1 = read(itemsSetUP(2));
        LigaInv2 = read(itemsSetUP(3));
        
        Bomba1 = read(itemsBombas(1));
        Bomba2 = read(itemsBombas(2));
        set(handles.valorBomba1, 'string', abs(Bomba1.Value));
        set(handles.valorBomba2, 'string', abs(Bomba2.Value));
        
        PTQ1_corrigido = read(itemsNiveis(1));
        PTQ2_corrigido = read(itemsNiveis(2));
        PTQ3_corrigido = read(itemsNiveis(3));
        PTQ4_corrigido = read(itemsNiveis(4));
        set(handles.nivelTQ01, 'string', abs(PTQ1_corrigido.Value));
        set(handles.nivelTQ02, 'string', abs(PTQ2_corrigido.Value));
        set(handles.nivelTQ03, 'string', abs(PTQ3_corrigido.Value));
        set(handles.nivelTQ04, 'string', abs(PTQ4_corrigido.Value));
        
        if(i == 0)
            set(handles.valvula01, 'string', Val1);
            set(handles.valvula02, 'string', Val2);
            set(handles.valvula03, 'string', Val3);
            set(handles.valvula04, 'string', Val4);
        else
            Val1 = get(handles.valvula01,'String');
            Val2 = get(handles.valvula02,'String');
            Val3 = get(handles.valvula03,'String');
            Val4 = get(handles.valvula04,'String');
            Val1 = str2num(Val1);
            Val2 = str2num(Val2);
            Val3 = str2num(Val3);
            Val4 = str2num(Val4);
            write(itemsValvula(1), Val1);
            write(itemsValvula(2), Val2);
            write(itemsValvula(3), Val3);
            write(itemsValvula(4), Val4);
        end

        % Animação tela ===================================================
        % ---- Alarmes Válvulas ----
        if(Val1 == 0)
            set(handles.val01Alarme, 'ForegroundColor', [1 1 0]);
        else
            set(handles.val01Alarme, 'ForegroundColor', [0 0 0]);
        end
        
        if(Val2 == 0)
            set(handles.val02Alarme, 'ForegroundColor', [1 1 0]);
        else
            set(handles.val02Alarme, 'ForegroundColor', [0 0 0]);
        end
        
        if(Val3 == 0)
            set(handles.val03Alarme, 'ForegroundColor', [1 1 0]);
        else
            set(handles.val03Alarme, 'ForegroundColor', [0 0 0]);
        end
        
        if(Val4 == 0)
            set(handles.val04Alarme, 'ForegroundColor', [1 1 0]);
        else
            set(handles.val04Alarme, 'ForegroundColor', [0 0 0]);
        end
        
        % ---- Alarmes Tanques ----
        if(abs(PTQ1_corrigido.Value) > 90)
            set(handles.nivelAltoPT01Alarme, 'ForegroundColor', [1 1 0]);
        elseif(abs(PTQ1_corrigido.Value) < 10)
            set(handles.nivelBaixoPT01Alarme, 'ForegroundColor', [1 1 0]);
        else
            set(handles.nivelBaixoPT01Alarme, 'ForegroundColor', [0 0 0]);
            set(handles.nivelAltoPT01Alarme, 'ForegroundColor', [0 0 0]);
        end
        
        if(abs(PTQ2_corrigido.Value) > 90)
            set(handles.nivelAltoPT02Alarme, 'ForegroundColor', [1 1 0]);   
        elseif(abs(PTQ2_corrigido.Value) < 10)
            set(handles.nivelBaixoPT02Alarme, 'ForegroundColor', [1 1 0]);
        else
            set(handles.nivelBaixoPT02Alarme, 'ForegroundColor', [0 0 0]);
            set(handles.nivelAltoPT02Alarme, 'ForegroundColor', [0 0 0]);
        end
        
        if(abs(PTQ3_corrigido.Value) > 90)
            set(handles.nivelAltoPT03Alarme, 'ForegroundColor', [1 1 0]);
        elseif(abs(PTQ3_corrigido.Value) < 10)
            set(handles.nivelBaixoPT03Alarme, 'ForegroundColor', [1 1 0]);
        else
            set(handles.nivelBaixoPT03Alarme, 'ForegroundColor', [0 0 0]);
            set(handles.nivelAltoPT03Alarme, 'ForegroundColor', [0 0 0]);
        end
        
        if(abs(PTQ4_corrigido.Value) > 90)
            set(handles.nivelAltoPT04Alarme, 'ForegroundColor', [1 1 0]);
        elseif(abs(PTQ4_corrigido.Value) < 10)
            set(handles.nivelBaixoPT04Alarme, 'ForegroundColor', [1 1 0]);
        else
            set(handles.nivelBaixoPT04Alarme, 'ForegroundColor', [0 0 0]);
            set(handles.nivelAltoPT04Alarme, 'ForegroundColor', [0 0 0]);
        end
        
        % ---- Animação Set Up -----
        if(Reset.Value ~= 0)
            set(handles.StatusReset,'BackgroundColor', [0 1 0]);
        else
            set(handles.StatusReset,'BackgroundColor', [1 0 0]);
        end
        
        if(LigaInv1.Value ~= 0)
            set(handles.StatusInversor1,'BackgroundColor', [0 1 0]);
        else
            set(handles.StatusInversor1,'BackgroundColor', [1 0 0]);
        end
        
        if(LigaInv2.Value ~= 0)
            set(handles.StatusInversor2,'BackgroundColor', [0 1 0]);
        else
            set(handles.StatusInversor2,'BackgroundColor', [1 0 0]);
        end
        
        % ---- Animação Bombas -----
        if(abs(Bomba1.Value) > 0)
            set(handles.Bomba1,'BackgroundColor', [0 1 0]);
        else
            set(handles.Bomba1,'BackgroundColor', [1 0 0]);
        end
        
        if(abs(Bomba2.Value) > 0)
            set(handles.Bomba2,'BackgroundColor', [0 1 0]);
        else
            set(handles.Bomba2,'BackgroundColor', [1 0 0]);
        end
        
        % ---- Animação Válvulas -----
        if(Val1 > 0)
            set(handles.VAL01,'BackgroundColor', [0 1 0]);
        else
            set(handles.VAL01,'BackgroundColor', [1 0 0]);
        end
        
        if(Val2 > 0)
            set(handles.VAL02,'BackgroundColor', [0 1 0]);
        else
            set(handles.VAL02,'BackgroundColor', [1 0 0]);
        end
        
        if(Val3 > 0)
            set(handles.VAL03,'BackgroundColor', [0 1 0]);
        else
            set(handles.VAL03,'BackgroundColor', [1 0 0]);
        end
        
        if(Val4 > 0)
            set(handles.VAL04,'BackgroundColor', [0 1 0]);
        else
            set(handles.VAL04,'BackgroundColor', [1 0 0]);
        end
        
        % ---- Animação nível ----
        set(handles.PTQ1_corrigido,'Xtick',[],'Ytick',[],'Ylim',[0 100]);
        axes(handles.PTQ1_corrigido);
        cla(handles.PTQ1_corrigido);
        rectangle('Position',[0,0,5,(round(100*abs(PTQ1_corrigido.Value)/100))+1],'FaceColor','g');
        
        set(handles.PTQ2_corrigido,'Xtick',[],'Ytick',[],'Ylim',[0 100]);
        axes(handles.PTQ2_corrigido);
        cla(handles.PTQ2_corrigido);
        rectangle('Position',[0,0,5,(round(100*abs(PTQ2_corrigido.Value)/100))+1],'FaceColor','g');
        
        set(handles.PTQ3_corrigido,'Xtick',[],'Ytick',[],'Ylim',[0 100]);
        axes(handles.PTQ3_corrigido);
        cla(handles.PTQ3_corrigido);
        rectangle('Position',[0,0,5,(round(100*abs(PTQ3_corrigido.Value)/100))+1],'FaceColor','g');
        
        set(handles.PTQ4_corrigido,'Xtick',[],'Ytick',[],'Ylim',[0 100]);
        axes(handles.PTQ4_corrigido);
        cla(handles.PTQ4_corrigido);
        rectangle('Position',[0,0,5,(round(100*abs(PTQ4_corrigido.Value)/100))+1],'FaceColor','g');

        % ---- Plot controle ----
        x = [x(2:1000), abs(PTQ3_corrigido.Value)];
        plot(handles.axes1, x,'LineWidth',0.5);
        grid on;
        
        % Cálculo do PID =================================================
        
        sp = get(handles.textsp,'String');
        kp = get(handles.textkp,'String');
        ki = get(handles.textki,'String');
        kd = get(handles.textkd,'String');
        sp = str2num(sp);
        kp = str2num(kp);
        ki = str2num(ki);
        kd = str2num(kd);
        
        QualidadeSinalBomba1 = Bomba1.Quality;
        
        if strcmp(QualidadeSinalBomba1,'Good: Non-specific')
            erroAtual = sp - PTQ3_corrigido.Value;
            somaErro = somaErro + erroAtual;

            saida  = kp*erroAtual + ki*somaErro + kd*(erroAtual - erroAnterior);
            write(itemsBombas(1), 55);

            erroAnterior = erroAtual;
 
        end
        
        i = i+1;

        pause(0.05);
    end


% --- Executes on button press in buttonStop.
function buttonStop_Callback(hObject, eventdata, handles)

    disp('STOP pressed.')
    set(handles.buttonStart,'UserData',0);
    
    global stop;
    stop = 0;
    
    %% Close OPC
    global server;
    disconnect(server);

    delete(server);
    opcreset
    close



function textsp_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function textsp_CreateFcn(hObject, eventdata, handles)

    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end



function textkp_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function textkp_CreateFcn(hObject, eventdata, handles)

    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end



function textki_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function textki_CreateFcn(hObject, eventdata, handles)

    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end



function textkd_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function textkd_CreateFcn(hObject, eventdata, handles)

    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end



function valvula03_Callback(hObject, eventdata, handles)
% hObject    handle to valvula03 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of valvula03 as text
%        str2double(get(hObject,'String')) returns contents of valvula03 as a double


% --- Executes during object creation, after setting all properties.
function valvula03_CreateFcn(hObject, eventdata, handles)
% hObject    handle to valvula03 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function valvula04_Callback(hObject, eventdata, handles)
% hObject    handle to valorBomba1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of valorBomba1 as text
%        str2double(get(hObject,'String')) returns contents of valorBomba1 as a double


% --- Executes during object creation, after setting all properties.
function valvula04_CreateFcn(hObject, eventdata, handles)
% hObject    handle to valorBomba1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function valvula02_Callback(hObject, eventdata, handles)
% hObject    handle to valvula02 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of valvula02 as text
%        str2double(get(hObject,'String')) returns contents of valvula02 as a double


% --- Executes during object creation, after setting all properties.
function valvula02_CreateFcn(hObject, eventdata, handles)
% hObject    handle to valvula02 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function valvula01_Callback(hObject, eventdata, handles)
% hObject    handle to valvula01 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of valvula01 as text
%        str2double(get(hObject,'String')) returns contents of valvula01 as a double


% --- Executes during object creation, after setting all properties.
function valvula01_CreateFcn(hObject, eventdata, handles)
% hObject    handle to valvula01 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
