classdef selectedObj
    % Panelde o an se�ili robot i�in tutulmas� gerekilen de�erler.
    properties
        circleID % Robot se�ildi�inde etraf�n� saran k�rm�z� circle adresini tutan de�i�ken
        robotID % se�ili robota ait id
        laserCircle % se�ili robota ait lazer kapsama alan�n� g�steren dairenin adresini tutan de�i�ken
        linesObj % lazer i�in atanan b�t�n �izgilerin adresini i�eren de�i�ken
        isControlButtonSet % Panelde CTRL tu�una o an bas�l� tutulup tutulmad���n� kontrol eden de�i�ken.
        isMouseDown % Panelde CTRL+mouse s�r�klemesi eventi yap�labilmesi i�in tutulmas� gereken mouse event de�i�keni
        allLength % Sens�rden gelen t�m ���nlar�n uzunluklar�n�n depoland��� de�i�ken
        allSlope % Sens�rden gelen t�m ���nlar�n a��lar�n�n depoland��� de�iken
        allType % Sens�rden gelen t�m ���nlar�n de�di�i objenin hangisi oldu�unu depoland��� de�iken
        figureWindow % Se�ili Robot i�in olu�turulan figure penceresinin adresini tutan de�i�ken
 
        pressedButton % Panele eleman eklemek i�in gerekli tu� komninasyonlar�n� tutan de�i�ken

    end
end