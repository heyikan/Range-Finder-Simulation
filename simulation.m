function varargout = simulation(varargin)

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @simulation_OpeningFcn, ...
                   'gui_OutputFcn',  @simulation_OutputFcn, ...
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
function varargout = simulation_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;


function simulation_OpeningFcn(hObject, eventdata, handles, varargin)


% koordinat duzlemi ayarlandi
xlim manual;
ylim manual;


lx = pref.panelWeight;
ly = pref.panelHeight;

xlim([0 lx]);
ylim([0 ly]);

axis([0,lx,0,ly]);
 axis equal;

 
 % Paneldeki axe adresi alýyor.
% gca : get current axes
panel = gcf;
 

% Panelde üzerine gelinerek seçilecek robotlarý belirten daire nesnesinin
% adresini tutan global deðiþkenin ilk deðeri ve robot id'si 0 a atanýyor.
select = selectedObj;
select.circleID = 0;
select.robotID = 0;
select.laserCircle = 0;
select.linesObj = [];
select.isControlButtonSet = false;
select.pressedButton = 'none';
select.isMouseDown = false;
select.allLength = [];
select.allSlope = [];
select.figureWindow = 0;
setSelectedElement(select);


handles.output = hObject;
guidata(hObject, handles);

set(gcf,'Pointer','fullcross');



% Kütle Çekim için Buton Ýmage ekleniyor.
% X = imread('icons\merkez.jpg');
% set(handles.massCenter,'CData',X);



% Event Listener: on mouse hover eventi ekleniyor
set(panel , 'WindowButtonMotionFcn' , @hoverEvent)
% Event Listener: is mouse clicked eventi ekleniyor
set(panel , 'WindowButtonDownFcn' , {@ClicktoAdd_callback,handles})

set(panel , 'WindowButtonUpFcn' , @mouseDown )
%Event Listener: ScrollDown eventi Ekleniyor.
set(panel , 'WindowScrollWheelFcn' , @panelZoom )
%Event Listener: 
set(panel , 'WindowKeyPressFcn' , @panelNavigation )

set(panel , 'WindowKeyReleaseFcn' , @keyRelease )


function hoverEvent (src,callbackdata)
% hover eventi. Görevleri:
% (1) Koordinatlarý Panelde Görüntüleme
% (2) 
% (3)

    % Seçili robot nesnesinin adresi alýndý.
    selElem = getSelectedElement;
    circle = selElem.circleID;
    
    % Axe nesnesinde  position deðerini al.
    % Position [left bottom width height]
    position = get(gca , 'Position');
    
    pLeft = position(1);
    pBottom = position(2);
    pWidth = position(3);
    pHeight = position(4);
    
    % Paneli al.
    seltype = get(src,'CurrentPoint');
    left = seltype(1);
    bottom = seltype(2);
    
    
        if left > pLeft && left < pLeft + pWidth && bottom > pBottom && bottom < pBottom + pHeight

        posCurr = get(gca , 'CurrentPoint');
        
        X = posCurr(1);
        Y = posCurr(3);
        
        % Koordinat Bilgileri yazýlýyor.
        s1 = num2str( posCurr(1) );
        s2 = num2str(posCurr(3) );
        res = strcat(s1,{' x '},s2);
        set(findobj('Tag' , 'coordinate') , 'String' , res );
        
        [selID , type ] = getMeIdTypeByCoordinate(X , Y);

            % ctrl ye basýlmýþsa be mousedown ise
            if selElem.isControlButtonSet && selElem.isMouseDown
                
                % Robot Objesi Taþýnacak:
                if strcmp(type , 'Robot') 

                    tmp = getRobotObj;

                    % þu an seçili bulunan robot alýndý.
                    s = tmp(selElem.robotID);

                    % mevcut konumdaki robot ve selectedObj siliniyor.
                    deleteRobot(selElem.robotID);

                    % Yeni Robot Ekleniyor.
                    s.circleObj = circles(X,Y, pref.circleRadius , 'facecolor' , s.color); 

                end
              
                
                if strcmp(type , 'Cisim')
                    
                tmp = getCisimObj;
                
                    % þu an seçili bulunan robot alýndý.
                    s = tmp(selElem.robotID);

                    % mevcut konumdaki robot ve selectedObj siliniyor.
                    deleteCisim(selElem.robotID);

                    % Yeni Cisim Ekleniyor.
                    s.rectangleObj = circles(X,Y,pref.cisimRadius,'vertices',4,'rot',45);

                     
                end

                
                % Koordinat Güncelleniyor.
                s.x = X;
                s.y = Y;
                
                
                 if ~strcmp(type , 'none')
                     
                    %robot ID'si daire icine yazi olarak ekleniyor.
                    if s.id > 9
                        s.textObj = text(X-0.1,Y,int2str(s.id));           % text adresi robot nesnesine atildi
                    else
                        s.textObj = text(X,Y,int2str(s.id));
                    end

                    set(s.textObj , 'FontSize',12);
                    set(s.textObj , 'FontWeight','bold');

                 end
                
                
                % Deðiþtirilen deðerler güncelleniyor.
                tmp(selElem.robotID) = s;
                
                if strcmp(type , 'Robot')
                     setRobotObj(tmp);
                end
                
                if strcmp(type , 'Cisim')
                    setCisimObj(tmp);
                end
            
            else
                
                % Elemanýn üzerine gelme durumu
                % Eðer bir cisim var ve etrafýnda circle varsa pointer hand
                % olacak.
                
                if selID ~= 0 && circle == 0 && selID ~= selElem.robotID
                    

                    set(gcf,'Pointer','hand');
                    
                    if strcmp(type , 'Robot')
                        tmp = getRobotObj;
                    end
                    
                    if strcmp(type , 'Cisim')
                        tmp = getCisimObj;
                    end
                    
                    
                    s = tmp(selID);
                    selElem.robotID = selID;
                    
                    if strcmp(type , 'Robot')
                        selElem.circleID = circles(s.x, s.y , pref.circleRadius ,'facecolor' , 'none','edgecolor',[1 0 0],'linewidth',4);
                    end
                    
                    if strcmp(type , 'Cisim')
                        selElem.circleID = circles(s.x, s.y , pref.cisimRadius ,'vertices',4,'rot',45,'facecolor' , 'none','edgecolor',[1 0 0],'linewidth',4);
                    end
                    
                    
                    setSelectedElement(selElem);
                   

                else
                    
                    if circle ~= 0 && selID ~= selElem.robotID
                        
                        
%                         fprintf('sýfýrlýyoruz\n')
                        set(gcf,'Pointer','fullcross');
                        
                        delete(circle);
                        selElem.circleID = 0;
                        selElem.robotID = 0;
                        setSelectedElement(selElem);
                        
%                         selElem
                        
                    end
                end
                


            end
        else
            set(findobj('Tag' , 'coordinate') , 'String' , '' );
            set(gcf,'Pointer','arrow');
            
        end

function ClicktoAdd_callback (src,callbackdata,handles)
    % Axe nesnesinde  position deðerini al.
    % Position [left bottom width height]
    position = get(gca , 'Position');
    
    pLeft = position(1);
    pBottom = position(2);
    pWidth = position(3);
    pHeight = position(4);
    
    % Paneli al.
    seltype = get(src,'CurrentPoint');
    left = seltype(1);
    bottom = seltype(2);
    
    
    
    % seçili robot bilgisi alýnýyor.
    selectedObj = getSelectedElement;
    
    if left > pLeft && left < pLeft + pWidth && bottom > pBottom && bottom < pBottom + pHeight
        posCurr = get(gca , 'CurrentPoint');
        X = posCurr(1);
        Y = posCurr(3);
        
        
        [selID , type ] = getMeIdTypeByCoordinate(X , Y);

       
        % ilk olarak sürükle býrak komutu için control butonuna basýlýp
        % basýlmadýðý kontrol ediliyor.
        if selectedObj.isControlButtonSet
%             fprintf('bu mal tasýnacak/n')
            selectedObj.robotID = selID;
            
            % mouse da týklandý artýk taþýmaya hazýrdýr
            selectedObj.isMouseDown = true;
            setSelectedElement(selectedObj);
            
        else
            
        % Eðer panelde týklanýlan yerde bir robot varsa, bu robot için
        % lazer range finder datasý oluþturulacak.
        if selID ~= 0
            plotLaserRangeFinderForId(selID);
        else
            
            % O an eklenecek olan eleman bilgisi alýnýyor.
            type = selectedObj.pressedButton;
            % Eðer burada bir robot yoksa panele robot eklenecek
            hold on
            addElementToPanel(X , Y , type ,  handles);
            hold off
            
            
            
        end
        end
        
    end
    
function panelZoom (src,callbackdata)
% Axe nesnesinde  position deðerini al.
    % Position [left bottom width height]
    position = get(gca , 'Position');
 
    pLeft = position(1);
    pBottom = position(2);
    pWidth = position(3);
    pHeight = position(4);
    
 % Paneli al.
    seltype = get(src,'CurrentPoint');
    left = seltype(1);
    bottom = seltype(2);
    

    
        if left > pLeft && left < pLeft + pWidth && bottom > pBottom && bottom < pBottom + pHeight
            
            % Panel boyutlarý alýnýyor.
   width = get(gca,'XLim');
    height = get(gca,'YLim');

    zoom = pref.zoomFactor;
            
            % Scroll Up
            if( callbackdata.VerticalScrollCount > 0 )
                
            axis([width(1)+zoom, width(2)-zoom, height(1)+zoom, height(2)-zoom]);
            axis equal;
            end
            
            
            % Scroll Down
            if( callbackdata.VerticalScrollCount < 0 )
                
                axis([width(1)-zoom, width(2)+zoom, height(1)-zoom, height(2)+zoom]);
                axis equal;
            end
            
           
        end
  
function panelNavigation (src,callbackdata)

    keyPressed = callbackdata.Key;
    % Panel boyutlarý alýnýyor.
    width = get(gca,'XLim');
    height = get(gca,'YLim');

 
 if strcmpi(keyPressed,'rightarrow')
     
                axis([width(1)+2.5, width(2)+2.5, height(1), height(2)]);
%                 axis equal;
                
 end
 
 
 
 if strcmpi(keyPressed,'leftarrow')  
     
                axis([width(1)-2.5, width(2)-2.5, height(1), height(2)]);
%                 axis equal;
                
 end
 
  
 if strcmpi(keyPressed,'uparrow') 
     
                axis([width(1), width(2), height(1)+2.5, height(2)+2.5]);
%                 axis equal;
                
 end
 
 
 
 if strcmpi(keyPressed,'downarrow')
     
                axis([width(1), width(2), height(1)-2.5, height(2)-2.5]);
%                 axis equal;
                
 end
 
 % Eðer kontrol tuþuna basýlmýþsa deðer true edilecek.
 if strcmpi(keyPressed,'control')
     
     set(gcf,'Pointer','fleur');
     
     selectedObj = getSelectedElement;
     
     selectedObj.isControlButtonSet = true;
     setSelectedElement(selectedObj);
     
     
 end
 
 % Eðer R tuþuna basýlmýþsa deðer true edilecek
  % Eðer kontrol tuþuna basýlmýþsa deðer true edilecek.
 if strcmpi(keyPressed,'r')
     
     selectedObj = getSelectedElement;
     selectedObj.pressedButton = 'Robot';
     setSelectedElement(selectedObj);
     
     % Eklenecek Elemanýn anlaþýlabilmesi için panlede label set edilecek
     X = imread('icons\robot.jpg');
    buttonObj =  findobj('Tag' , 'currentElement');
     set(buttonObj,'CData',X);
     
     
 end
 
 
  % Eðer o tuþuna basýlmýþsa deðer true edilecek
  % Eðer kontrol tuþuna basýlmýþsa deðer true edilecek.
 if strcmpi(keyPressed,'o')
     
     selectedObj = getSelectedElement;
     selectedObj.pressedButton = 'Cisim';
     setSelectedElement(selectedObj);
     
     % Eklenecek Elemanýn anlaþýlabilmesi için panlede label set edilecek
     X = imread('icons\cisim.jpg');
    buttonObj =  findobj('Tag' , 'currentElement');
     set(buttonObj,'CData',X);
     
     
 end
 
 
 
  % Eðer g tuþuna basýlmýþsa deðer true edilecek
  % Eðer kontrol tuþuna basýlmýþsa deðer true edilecek.
 if strcmpi(keyPressed,'g')
     
     selectedObj = getSelectedElement;
     selectedObj.pressedButton = 'Hedef';
     setSelectedElement(selectedObj);
     
     % Eklenecek Elemanýn anlaþýlabilmesi için panlede label set edilecek
     X = imread('icons\hedef.jpg');
    buttonObj =  findobj('Tag' , 'currentElement');
     set(buttonObj,'CData',X);
     
     
 end
 
 
 
 
   % Eðer p print

 if strcmpi(keyPressed,'p')
     

tmp = getRobotObj;

for i=1:length(tmp)
    
    s = tmp(i);
    s
    
end

% Tüm Cisimler için aranýyor.
tmp = getCisimObj;

for i=1:length(tmp)
    
    s = tmp(i);
    s
end

     
 end
  
 
function keyRelease (src,callbackdata)
     
     
     keyPressed = callbackdata.Key;
     
     selectedObj = getSelectedElement;
     
     if strcmpi(keyPressed,'control')
         set(gcf,'Pointer','arrow');
         selectedObj.isControlButtonSet = false;
         setSelectedElement(selectedObj);
     end
     
function mouseDown(src,callbackdata)
selectedObj = getSelectedElement;
selectedObj.isMouseDown = false;

setSelectedElement(selectedObj);

        
function addElementToPanel(X ,Y ,type,handles)
    
global s;


 if strcmp(type , 'Robot') || strcmp(type , 'none')  
     
    %robot ekleniyor
    s = robotInfo; % Yeni nesne olusturuldu
    s.id = length(getRobotObj) + 1;      % id Atandi

 end
 
 if  strcmp(type , 'Cisim')
     
     %cisim ekleniyor 
     s = cisimInfo;                       % Yeni nesne olusturuldu
     s.id = length(getCisimObj) + 1;      % id Atandi   
     
 end
 
    % Nesnelere Koordinat  Atandý.
    s.x = X;                             % x koorinati Atandi
    s.y = Y;                             % y koorinati Atandi
    

    if strcmp(type , 'Robot') || strcmp(type , 'none') 
        
        s.color = randomColor;
        s.circleObj = circles(X,Y, pref.circleRadius , 'facecolor' , s.color);      % Robot olusturuldu ve adresi nesneye atandi
   
    end
    
    
    if  strcmp(type , 'Cisim')
        
        s.color = randomColor;
        s.rectangleObj = circles(X,Y,pref.cisimRadius,'vertices',4,'rot',45);      % Cisim olusturuldu ve adresi nesneye atandi
        
    end
    

    %robot ID'si daire icine yazi olarak ekleniyor.
    if s.id > 9
        s.textObj = text(X-0.1,Y,int2str(s.id));           % text adresi robot nesnesine atildi
    else
        s.textObj = text(X,Y,int2str(s.id));
    end

    set(s.textObj , 'FontSize',12);
    set(s.textObj , 'FontWeight','bold');


    % Deðiþiklikler kaydediliyor.
    
    if  strcmp(type , 'Robot') || strcmp(type , 'none') 
        setRobotObj([getRobotObj s]);
    end
    if strcmp(type , 'Cisim')
        setCisimObj([getCisimObj s]);
        
    end
    
    
% Belirlenen koorinarlarda robot olup olmadýðýný kontrol eder. eðer robot
% varsa id sini döndürür yoksa 0 döndürür.
function [ roboID , type ] = getMeIdTypeByCoordinate( X , Y )

% Foksiyon robotlar, cisimler ve hedeflerde böyle bir kordinatýn olup
% olmadýðýna bakýyor.
% Eðer Seçilen koordinat gruplanmýþ robotlarýn bulunduðu bir alana denk
% gelmiþse deðer false dönecek.

% Tüm robotlar için aranýyor.
tmp = getRobotObj;
roboID = 0;
type = 'none';

for i=1:length(tmp)
    
    s = tmp(i);

    % iki nokta arasýndaki uzaklýk hesaplanýyor.
    arr = [s.x , s.y ; X , Y];
    distance = pdist(arr , 'euclidean');

    if distance <= pref.circleRadius
        roboID = s.id;
        type = 'Robot';
        break;
        
    end
    
end

% Tüm Cisimler için aranýyor.
tmp = getCisimObj;

for i=1:length(tmp)
    
    s = tmp(i);

    % pref.CisimRadius deðiþkeni köþegen uzaklýðýdýr.
    dikUzaklik = sind(45)* pref.cisimRadius;
    
    % iki nokta arasýndaki uzaklýk hesaplanýyor.
%     arr = [s.x , s.y ; X , Y];
%     distance = pdist(arr , 'euclidean');

    farkX = s.x - X;
    farkY = s.y - Y;

    if (farkX <= dikUzaklik && farkX >= -1 * dikUzaklik) && (farkY <= dikUzaklik && farkY >= -1 * dikUzaklik)
        roboID = s.id;
        type = 'Cisim';
        break;
        
    end
%     
%     if distance <= dikUzaklik
%         roboID = s.id;
%         type = 'Cisim';
%         break;
%         
%     end
    
end


function deleteRobot(id)

tmp = getRobotObj;
s = tmp(id);

delete(s.circleObj);
delete(s.textObj);


function deleteCisim(id)

tmp = getCisimObj;
s = tmp(id);

delete(s.rectangleObj);
delete(s.textObj);


% Rbot idsi ile belirlenen robot için lazer çizgilerini panelede çizer ve
% her çizginin adresini array a atar.
% ANA FONKSIYON
function plotLaserRangeFinderForId(roboID)

% Robotlar alýndý.
tmp = getRobotObj;
s = tmp(roboID);

% seçili robot bilgileri alýndý.
selElem = getSelectedElement;

% mouse hover eventinin oluþturduðu circle çizimi siliniyor.
if selElem.laserCircle ~= 0
    delete(selElem.laserCircle);
end

    % Lazer kapsama alanýný gösteren büyük çember
    selElem.laserCircle = circles(s.x, s.y , laserInfo.range,'facecolor' , 'none','edgecolor',[0 0 1],'linewidth',2);
    setSelectedElement(selElem);


    % robot silinip tekrar yüklenecek. ( Çizgilerin Üzerinde Dursun Diye )
    deleteRobot(s.id);
    
    % Eðer açýk durumda bir figure penceresi varsa kapatýlacak.
    if selElem.figureWindow ~= 0

        % Eðer figure kapatýlmamýþsa silecek
        if ishandle(selElem.figureWindow)
                close(selElem.figureWindow)
        end
    end
    
    % Daha önceden çizilmiþ lazer çizgileri varsa onlar alandan silinecek.
    allLines = selElem.linesObj;
    
    % Daha Önceden Atanmýþ lazer uzunluk bilgileri varsa silinecek
    selElem.allLength = [];
    selElem.allSlope = [];
    selElem.allType = [];
    
    % deðiþiklikler kaydedildi
    setSelectedElement(selElem);

    for angle=1:length(allLines)
        delete(allLines(angle))
    end
    allLines = [];
    
    % Lazerin çevresinde bulunan robotlar bulunup array halinde deðiþkene
    % atanýyor.
%     foundedRobots = findRobotsForLazer(s.x , s.y );
    
    
% lazer ýþýnlarý çiziliyor.

% Sensorden gelen tüm uzunluklar ve tüm açýlar array a atýlýyor.



for angle =1:laserInfo.interval:360
    
    
    X = s.x;
    Y = s.y;
    
    % çizginin nereye kadar çizileceði. çizilecek uzunluk sensörün
    % deðerini belirleyecek.
     initLimitX = s.x+laserInfo.range * cosd(angle);
     initLimitY = s.y+laserInfo.range*sind(angle);
    
        type = 0;
     % fonksiyon açýsý orijini belli olan noktanýn hizasýnda bu herhangi bir
     % obje var mý onu belirler.

        [ limitX , limitY , type] = findLimitBeamDistance( s , angle );
       
        % Doðrular limite göre çiziliyor.
        hold on
        
        if limitX == initLimitX && limitY == initLimitY
            plotObj = plot([X limitX] , [s.y limitY] , 'Color' , 'blue' );
        else
            plotObj = plot([X limitX] , [s.y limitY] , 'Color' , 'red' );
        end
        
        hold off
        

    
    % oluþturulan çizgi bilgisi array'a atýlýyor.
    allLines = [allLines plotObj];
    
    
    arr = [X , Y ; limitX , limitY];
    distance = pdist(arr , 'euclidean');
    
    selElem.allLength = [selElem.allLength distance];
    selElem.allSlope = [selElem.allSlope angle];
    selElem.allType = [selElem.allType type];
    
    setSelectedElement(selElem);
    
end
    

    
     hold on
    % robot tekrar ekleniyor
    s.circleObj = circles(X,Y, pref.circleRadius , 'facecolor' , s.color);      % Robot olusturuldu ve adresi nesneye atandi
    %robot ID'si daire icine yazi olarak ekleniyor.
    if s.id > 9
        s.textObj = text(X-0.1,Y,int2str(s.id));           % text adresi robot nesnesine atildi
    else
        s.textObj = text(X,Y,int2str(s.id));
    end
    
    set(s.textObj , 'FontSize',12);
    set(s.textObj , 'FontWeight','bold');
    hold off
    
    % robot silinip tekar yüklendiði için güncelleniyor.
    tmp(roboID) = s;
    setRobotObj(tmp);
    
    % çizgiler nesneye atanýyor.
    selElem.linesObj = allLines;
%      setSelectedElement(selElem);   
     
     
     tmpSel = getSelectedElement;
     tmpSel.allLength;
     tmpSel.allSlope;
%     

% Açýlýr panelde lazer bilgileri var. excel çýktýsý için buton oluþturuldu.
     selElem.figureWindow = figure;
     mh = uimenu(selElem.figureWindow,'Label','Excel Çýktýsý' , 'Callback' , @exportExcel );
     plot(tmpSel.allSlope,tmpSel.allLength)
     nu = num2str(s.id);
     title(strcat('Laser Range Finder Data For RobotID: ',nu))
     xlabel('angle')
     ylabel('length')
     set(gcf,'Resize','on');
     pos = get(gcf , 'Position');
     pos(1) = 20;
     pos(2) = 20;
     set(gcf , 'Position', pos );
     set(gcf,'name','Plotting Range Finders Value');
     setSelectedElement(selElem); 


function [ limitX , limitY ,type ] = findLimitBeamDistance(s , angle)

    % Fonksiyon argüman olarak seçili robotun adresini ve gönderilen ýþnýn
    % açý deðerini alýr. orijini ve eðimi belli olan doðru parçasý için
    % cisim ve robotun uzaklýðýný hesaplar ve sonuç döner.
    
    type = NNConstants.defaultNNConst;
    
    % lazerin baþlangýç noktalarý belirleniyor.      
    startX = s.x;
    startY = s.y;
    
    % lazerin bitiþ noktalarý belirleniyor.      
    limitX = s.x+laserInfo.range * cosd(angle);
    limitY = s.y+laserInfo.range * sind(angle);

    
    % Fonksiyonda kullanýlacak global deðiþkenler.
    global lines;
    global edges;
    global rect;
    global circle;
    
    % hedef robotun gönderdiði lazere olan maximum uzaklýðý
    global distanceLimit;
    distanceLimit = laserInfo.range;
    
    
    
%   Ýlk Olarak Robotlarda Aranýyor.
    rObj = getRobotObj;
    
    for i=1:length(rObj)
        
        % Sorun þu; robotun merkezindeki noktadan ayrýlan doðrular
        % seçili robotla kesiþim fonksiyonuna giriyor.
        % seçili robotla etkileþime girmemesi lazým.
        rTmp = rObj(i);
        
        % Lazeri için Edge (doðru parçasý) Belirleniyor.
        edges = [startX  startY  limitX limitY ];
        % Çemberin orijini ve yarýcapý belirleniyor.
        circle = [ rTmp.x rTmp.y  pref.circleRadius];
        
        % edge line a dönüþtürülüyor.
        lines = edgeToLine(edges);
        
        % doðru ile çemberin analitiðinden kesiþim noktalarý bulunuyor.
        intsect = intersectLineCircle(lines , circle);
        
        % Eðer Kesiþmiþse ve bu kesiþen seçili robot deðilse.
        if ~isnan(intsect) 
            if rTmp.id ~= s.id
                
                % Kesiþim iþlemi doðrular üzerinde yapýldýðýndan doðru
                % parçasýnýn arkasýndaki daire ile de kesiþimi hesaba
                % katýyor. isPointOnEdge fonksiyonu ile bulunan noktalar bu
                % doðru parçasý üzerinde mi deðil mi ona bakýyoruz.
                onEdge = isPointOnEdge(intsect , edges);
                
                % Eðer matriste herhangi bir sýfýr yoksa.
                %(yani doðru parçasý üzerinde ise)
                if max(onEdge)
                    
                    
                    %Bu kesiþim Noktalarýndan hangisi orijine daha yakýn ona
                    % bakýyoruz...
                    
                    %iki nokta arasýndaki uzaklýk hesaplanýyor.
                    % distance: bu uzaklýklardan en küçüðü (orijine en yakýný seçiliyor.)
                    [distance , index ] = min( [ pdist([startX , startY ; intsect(1,:)] , 'euclidean') pdist([startX , startY ; intsect(2,:)] , 'euclidean') ] );
                    % index: hangi deðer daha küçük onun indexsini tutan deðiþken
                   
                    
                    if (distance < distanceLimit)
                        
                        distanceLimit = distance;
                        % lazerin bitiþ noktalarý belirleniyor.
%                         limitX = distanceLimit * cosd(angle);
%                         limitY = distanceLimit * sind(angle);

%                           [ limitX , limitY ] = intsect(index,:);
                          limitX = intsect(index,1);
                          limitY = intsect(index,2);
                          % neural network için type ayarlanýyor.
                          type = NNConstants.robotNNConst;
                    end
                    
                end
                
            end
        end
        
        
        
    end

%   Cisimlerde Aranýyor.
    cObj = getCisimObj;
     for i=1:length(cObj)
         cTmp = cObj(i);
         
         
         
         % Lazeri için Edge (doðru parçasý) Belirleniyor.
         edges = [startX  startY  limitX limitY ];
         
         % kare için koordinatlar belirleniyor.
         % uzunluk ve geniþlik için dik uzaklýk belirlenmeli.
         du = sind(45)* pref.cisimRadius;
         
         rect = [cTmp.x cTmp.y 2*du 2*du];
         % rectangle kesiþim hesabý için polygona çeviriliyor
         poly = orientedBoxToPolygon(rect);
         
         
        % kesiþim hesaplanýyor.
        intsect = intersectEdgePolygon(edges, poly);

%         assignin('base' , 'ints' , intsect);
        
        % kesiþim gerçekleþmiþse
        if ~isempty(intsect) 
            
            
            %intsect arrayý kesiþmeyen noktalarda empty döndüðünden
            %distance fonksiyonunda sýkýntý oluþturuyor. bu sebeple empty
            %cell lere NaN atamasý yapýyoruz.
            if size(intsect) == [1 2]
                intsect = [intsect ; NaN NaN];
            elseif size(intsect) == [0 2]
                intsect = [NaN NaN ; NaN NaN];
            end
            
         % kesiþim deðerlerinden en küçüðünü ve onun indexini buluyoruz.
            [distance , index ] = min( [ pdist([startX , startY ; intsect(1,:)] , 'euclidean') pdist([startX , startY ; intsect(2,:)] , 'euclidean') ] );
        
        
            
            if (distance < distanceLimit)
                
                distanceLimit = distance;
                % lazerin bitiþ noktalarý belirleniyor.

                
                % [ limitX , limitY ] = intsect(index,:);
                limitX = intsect(index,1);
                limitY = intsect(index,2);
                
                % neural network için type ayarlanýyor.
                type = NNConstants.cisimNNConst;
            end
            
        
        
        
        end
         
     end



% Robotlarin Adreslerini tutan global degisken.
function setRobotObj(val)
global robotObj
robotObj = val;

function r = getRobotObj
global robotObj
r = robotObj;


% Cisimlerin Adreslerini tutan global degisken.
function setCisimObj(val)
global cisimObj
cisimObj = val;

function r = getCisimObj
global cisimObj
r = cisimObj;



% Hedeflerin Adreslerini tutan global deðiþken
function setGoalObj(val)
global goalObj
goalObj = val;

function r = getGoalObj
global goalObj
r = goalObj;



% Seçilen elemana ait bilgilerin bulunduðu deðiþken
function setSelectedElement(val)
global selectObj
selectObj = val;

function r = getSelectedElement
global selectObj
r = selectObj;

% Foksiyon Elemaný Panleden ve ait olduðu nesneden siler.    
function eraseElementToPanel(type , handles)

global s;

if strcmp(type , 'Robot')
    
    % Robot Siliniyor.
    tmp = getRobotObj;
    
    for i=1:length(getRobotObj);
        
        s = tmp(i);
        
        rectObj  = s.circleObj;
        textInfo = s.textObj;
        
        %Deger Siliniyor.
        delete(rectObj);
        delete(textInfo);
        
        clear s;
    end
       
    % array'i bosalt
    setRobotObj([]);
    
    
end

if strcmp(type , 'Cisim')
    
        % Cisim Siliniyor.
    tmp = getCisimObj;
    
    for i=1:length(tmp);
        
        s = tmp(i);
        
        rectObj  = s.rectangleObj;
        textInfo = s.textObj;
        
        %Deger Siliniyor.
        delete(rectObj);
        delete(textInfo);
        
        clear s;
    end
    
    
    % array'i bosalt
    setCisimObj([]);
    
    % selectedElem Sýfýrla
    % Panelde üzerine gelinerek seçilecek robotlarý belirten daire nesnesinin
    % adresini tutan global deðiþkenin ilk deðeri ve robot id'si 0 a atanýyor.
    select = selectedObj;
    select.circleID = 0;
    select.robotID = 0;
    select.laserCircle = 0;
    select.linesObj = [];
    select.isControlButtonSet = false;
    select.pressedButton = 'none';
    select.isMouseDown = false;
    select.allLength = [];
    select.allSlope = [];
    select.allType = [];
    select.figureWindow = 0;
    setSelectedElement(select);
     
    
end

if strcmp(type , 'Hedef')
    
    
    % Hedef Siliniyor.
    tmp = getGoalObj;
    
    for i=1:length(tmp);
        
        s = tmp(i);
        
        rectObj  = s.rectangleObj;
        textInfo = s.textObj;
        
        %Deger Siliniyor.
        delete(rectObj);
        delete(textInfo);
        
        clear s;
    end
    
    % array'i bosalt
    setGoalObj([]);
    
    
end

function saveScenario_Callback(hObject, eventdata, handles)

% Dosya Alýnýyor.

[FileName,PathName] = uiputfile('scenario.sec','Save Scenario');
file = strcat(PathName,FileName);
file = fopen(file,'w');


%Robotlar alýnýyor
tmp = getRobotObj;
for i=1:length(tmp)
    
    s = tmp(i);
    X = s.x;
    Y = s.y;
    type = 'Robot';
    
    fprintf(file ,'%4f , %4f , %s;' , X , Y , type);
    

end


%Cisimler alýnýyor
tmp = getCisimObj;
for i=1:length(tmp)
    
    s = tmp(i);
    X = s.x;
    Y = s.y;
    type = 'Cisim';
    
    fprintf(file ,'%4f , %4f , %s;' , X , Y , type);
    

end


%Hedefler alýnýyor
tmp = getGoalObj;
for i=1:length(tmp)
    
    s = tmp(i);
    X = s.x;
    Y = s.y;
    type = 'Hedef';
    
    fprintf(file ,'%4f , %4f , %s;' , X , Y , type);
    

end

fclose(file);

function loadScenario_Callback(hObject, eventdata, handles)

%Tüm Elemanlar siliniyor ve panel temzileniyor.
[FileName,PathName] = uigetfile('*.sec','Senaryo Seçiniz');
file = strcat(PathName,FileName);
fid = fopen(file,'r');
s = fscanf(fid , '%s');
res = strsplit(s, {',' , ';', ' ','\n'});


eraseElementToPanel('Robot',handles);
eraseElementToPanel('Cisim',handles);
eraseElementToPanel('Hedef',handles);
cla;

for i=1:3:length(res)-1
    X = str2double(res(i));
    Y = str2double(res(i+1));
    type = res(i+2);
    addElementToPanel(X , Y ,type , handles);
end

function importExcel_Callback(hObject, eventdata, handles)
%Tüm Elemanlar siliniyor ve panel temzileniyor.
 [FileName,PathName , filteindex] = uigetfile('*.xls','Senaryo Seçiniz' , 'MultiSelect' , 'on');
 
 if isfloat(FileName), error('No files selected'),end
 if isstr(FileName) FileName={FileName}; end
 
paths = fullfile(PathName, FileName);
% 
% assignin('base' ,'path' , paths )
% assignin('base' ,'file' , FileName )
fullData= [];
fullOutput = [];

for i=1:length(paths)
    
filename = paths{i};
A = xlsread(filename)


fullData = [fullData A(:,2)];
fullOutput = [fullOutput A(:,3) ];

% fullData(length(fullData)) = [];
% fullOutput(length(fullOutput)) = [];

end



assignin('base' ,'fullData' , fullData );
assignin('base' ,'fullOutput' , fullOutput );


% A = (360/(laserInfo.interval)) / NNConstants.inputSize;

% assignin('base' ,'a' , A );

% reshape(A , [10 36]) -- 10 satýr 36 sütüna böl.
inputData = reshape(fullData , [NNConstants.inputSize , (((360/(laserInfo.interval)) / NNConstants.inputSize)* length(paths)) ]);
outputData = mean ( reshape(fullOutput , [NNConstants.inputSize , (((360/(laserInfo.interval)) / NNConstants.inputSize)* length(paths))   ]) );



delColumn = [];
% % bölgede hiçbirþey olmayan alanlar inputa dahil edilmeyecek...
for i=1:length(outputData)
    
    if( outputData(i) == NNConstants.defaultNNConst )
        
%         outputData(i) = [];
%         inputData(: , i) = [];
%         
    delColumn = [delColumn i];
        
    end

end

for i=length(delColumn):-1:1
    
    outputData(delColumn(i)) = [];
    inputData(: , delColumn(i)) = [];
end

% outputData = mean(inputData);


assignin('base' ,'inputData' , inputData );

assignin('base' ,'outputData' , outputData );


function trainNN_Callback(hObject, eventdata, handles)
inputData = evalin('base','inputData');
outputData = evalin('base','outputData');

net = newff(minmax(inputData) , [50 1] , {'logsig' , 'purelin'} , 'trainlm');
net.trainparam.epochs = 2000;
net.trainparam.lr=0.01;
net= train(net ,inputData , outputData)

assignin('base' , 'net' , net);

function kutleCekim_Callback(hObject, eventdata, handles)

% Robotlarýn sahip olduðu toplam kütle çekim deðeri hesaplanýyor.




disp('meraba');


% --------------------------------------------------------------------
function Menu_Callback(hObject, eventdata, handles)
% hObject    handle to Senaryo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Senaryo_Callback(hObject, eventdata, handles)
% hObject    handle to Senaryo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


function exportExcel (src,callbackdata)

% tmpSel = getSelectedElement;
% putvar(tmpSel.allLength);
% assignin('base', 'len' , tmpSel.allLength );
% assignin('base', 'slope' , tmpSel.allSlope );

% col1 = [cellstr('slope') , cellstr('length') ; transpose(num2cell(slope)) , transpose(num2cell(len))];


% Dosya Alýnýyor.
% output dosyalarý pediyodik olarak isimlendirilecek.
index = 1;
alias = 'output';
ext = '.xls';
name = strcat( alias , num2str(index) ,  ext );

while exist(name) == 2
    index = index+1;
    name = strcat( alias , num2str(index) ,  ext );
end


[FileName,PathName] = uiputfile(name,'Save Output');
file = strcat(PathName,FileName);
% file = fopen(file,'w');

%çýktýlar alýnýyor
tmpSel = getSelectedElement;


len  =   tmpSel.allLength;
slope    =   tmpSel.allSlope;
type = tmpSel.allType;

result = [cellstr('slope') , cellstr('length') , cellstr('type'); transpose(num2cell(slope)) , transpose(num2cell(len)) , transpose(num2cell(type)) ];

xlswrite(file , result);

% fclose(file);



% RANGE SIMULASYONU SONU





