classdef robotInfo
    % Her bir robot icin tutulacak butun degerler.
    properties
        %% Robot Info
        id  % Robotun Id'si
        x   % Robotun X koordinati
        y   % Robotun Y koordinati
        mass % Robotun K�tlesi
        
        %% Circle Info
        circleObj   % Robot nesnesinin adresinin tutulacagi degisken
        color       % Robotun random olarak atanan renk degeleri (R,G,B)
        textObj     % Robotun isimlendirilmesinde kullanilan text nesnesinin adresi
        
        %% Arrow Info
        lineInfo    % Kutle cekimde kullanilan cizgi nesnesinin adresi
        arrowInfo   % Ok nesnesinin adresi
        curveInfo   % Aci nesnesinin adresi
        
        %% Grav Info
        gravSlope   % Kutle cekim Algoritmasi Egim Degeri
        gravLength  % Kutle cekim Algoritmasi Uzunluk Degeri
        
        %% Group Info
        groupID     % Robotun Hangi Gruba ait oldugunu gosterir. �nitial: 0
        isLeader    % Robotun Gruba ait Liderlik Bilgisinin Olup Olmadigini Belirtir.
                    % 0 : Hen�z Grup Atamas� yap�lmam��. idle
                    % 1 : Grubun Lideri
                    % -1 : Grup atamas� yap�lm�� ve se�ili robot grup
                    % lideri de�il.
                    
       groupedMass  % Robotlar�n grupland�ktan sonraki k�tleleri
                    % 0 : initial de�er. ( robotlar grupland�klar�n� buradan
                    % anlayacak )
       %% Mass Center Info
       centerOfMassValue % robotun gruplama olduktan sonra a��rl�k merkezi hesaplamas�nda kullan�lacak k�tle de�eri
    end
end